//
//  TableViewController.swift
//  SaveTheBite
//
//  Created by Ida Parkkali on 14.11.2023.
//
// This class handels the display of items in the TableView


// Import necessary frameworks
import UIKit
import AVFoundation
import Vision
import CoreData
import Lottie

// Define TableViewController class, conforming to necessary protocols for image picking and navigation
class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Properties declaration
    var itemManager: ItemManager!
    let sheetViewController = CustomSheetViewController()
    var emptyTableViewGifView: UIImageView?
    var emptyTableViewContainerView: UIView?
    var emptyMessageLabel: UILabel?
    var items: [Date: [StoredItem]] = [:]
    
    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetching the managed context from the AppDelegate to use Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Initialize itemManager and fetch items to display
        itemManager = ItemManager(managedContext: managedContext)
        items = itemManager.fetchItems()
        let sortedItems = itemManager.fetchItems().sorted(by: { $0.key < $1.key })
        items = Dictionary(uniqueKeysWithValues: sortedItems)

        // Setting background color for the tableView
        tableView.backgroundColor = ColoursManager.first
        
        // Customizing the navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = ColoursManager.second // Dynamic color for background
        appearance.titleTextAttributes = [.foregroundColor: ColoursManager.third as Any]
        
        // Button font and attributes setup
        let buttonFont = UIFont(name: "GillSans-SemiBold", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .font: buttonFont,
            .foregroundColor: ColoursManager.third as Any
        ]
        
        // Set the button appearance for the navigation bar
        appearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes
        appearance.buttonAppearance.highlighted.titleTextAttributes = buttonAttributes
        
        // Set custom font for title
        let customFont = UIFont(name: "GillSans-SemiBold", size: 20.0) ?? UIFont.systemFont(ofSize: 20.0)
        appearance.titleTextAttributes = [.foregroundColor: ColoursManager.third as Any, .font: customFont] // Dynamic color for title

        // Configuring the navigation controller's navigation bar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // Setting up a custom back button
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationItem.backBarButtonItem = backButton

        // Checking for iOS version compatibility for compact appearance
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactAppearance = appearance
        }
        
        // Setting the navigation title
        self.navigationItem.title = "SaveTheBite"
        
        // Adding buttons to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Item", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "About", style: .plain, target: self, action: #selector(leftBarButtonTapped))
        
        // Setup for displaying an empty table view with a custom message and GIF
        emptyTableViewContainerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 300))  // Adjust height as needed
        tableView.addSubview(emptyTableViewContainerView!)
            
        // Initialize and configure the GIF view
        emptyTableViewGifView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200))
        emptyTableViewGifView?.loadGif(name: "techny-shopping-basket-full-of-groceries")
        emptyTableViewGifView?.contentMode = .scaleAspectFit
        emptyTableViewContainerView?.addSubview(emptyTableViewGifView!)

        // Initialize and configure the label for the GIF
        emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 200, width: tableView.bounds.width, height: 100))
        emptyMessageLabel?.text = "Seems like you don't have any items added.\nYou can add items by pressing the\nbutton on the upper right corner."
        emptyMessageLabel?.textAlignment = .center
        emptyMessageLabel?.textColor = .white
        emptyMessageLabel?.font = UIFont.systemFont(ofSize: 16)
        emptyMessageLabel?.numberOfLines = 0
        emptyTableViewContainerView?.addSubview(emptyMessageLabel!)

        emptyTableViewContainerView?.isHidden = true // Hidden by default
        
    }
    
    // Called when the view is about to made visible
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tableView.reloadData()
        items = itemManager.fetchItems()
        updateTableViewBackground()
    }
    
    // Update background based on items count
    func updateTableViewBackground() {
        let groupedItems = itemManager.fetchItems()
        let itemCount = groupedItems.values.flatMap { $0 }.count
        tableView.reloadData()
        emptyTableViewContainerView?.isHidden = itemCount != 0
    }
    
    // Called to notify the view controller that its view has just laid out its subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyTableViewContainerView?.center = CGPoint(x: tableView.center.x, y: tableView.center.y - (emptyTableViewContainerView?.frame.height ?? 0) / 2)
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToPickManually",
           let destinationVC = segue.destination as? PickManuallyViewController {
            destinationVC.delegate = self
        }
    }
    
    
    
    // MARK: - Table view data source
    
    // Number of sections in the tableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.keys.count
    }
    
    // Number of rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedKeys = items.keys.sorted(by: <)
        let date = sortedKeys[section]
        return items[date]?.count ?? 0
    }
    
    // Title for each section header
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Array(items.keys)[section]
        return DateFormatter.shared.string(from: date)
    }
    
    // Configure each cell in the TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell else {
            fatalError("Expected CustomTableViewCell")
        }
        
        let sortedKeys = items.keys.sorted(by: <)
        let date = sortedKeys[indexPath.section]
        if let storedItem = items[date]?[indexPath.row] {
            // Configure cell...
            cell.customCellLabel.text = storedItem.title
            if let imageData = storedItem.image {
                cell.customCellPicture.image = UIImage(data: imageData)
            }
            // Check if the item is expiring in 3 days or less
            let daysToExpiration = daysUntilExpiration(from: storedItem.date!)
            if daysToExpiration <= 3 {
                cell.layer.cornerRadius = 10
                cell.layer.borderWidth = 2
                cell.layer.borderColor = determineHeaderColor(for: date).cgColor
            } else {
                // Reset to default appearance
                cell.layer.cornerRadius = 10
                cell.layer.borderWidth = 0
                cell.layer.borderColor = ColoursManager.first?.cgColor

            }
        }
    
        // for debugging the delete bug
        if let storedItem = items[date]?[indexPath.row] {
            print("Displaying item at section \(indexPath.section), row \(indexPath.row): \(storedItem.title ?? "??")")
        }
        
        return cell
    }
    
    // Configure the view for the header in each section
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // view for header
        let headerView = UIView()
        let sortedKeys = items.keys.sorted(by: <)
        let date = sortedKeys[section]
        headerView.backgroundColor = ColoursManager.first

        // laber for header
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = ColoursManager.third
        headerLabel.font = ColoursManager.font1
        headerLabel.text = DateFormatter.shared.string(from: date)
        headerView.addSubview(headerLabel)

        // message for header
        var warningMessage = ""
        var color: UIColor = ColoursManager.first!

        if let sectionItems = items[date] {
            let currentDate = Date()

            if sectionItems.contains(where: { $0.date! < currentDate }) {
                // Some items have already expired
                warningMessage = "The item has expired"
                color = ColoursManager.fourth!
            } else if sectionItems.contains(where: { daysUntilExpiration(from: $0.date!) <= 3 }) {
                // Some items are about to expire
                warningMessage = "Items are about to expire"
                color = ColoursManager.fifth!
            }
        }

        // add warning icon and fonts to the header
        if !warningMessage.isEmpty {
            let symbolImageView = UIImageView()
            symbolImageView.translatesAutoresizingMaskIntoConstraints = false
            symbolImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            symbolImageView.tintColor = color
            headerView.addSubview(symbolImageView)

            let warningLabel = UILabel()
            warningLabel.translatesAutoresizingMaskIntoConstraints = false
            warningLabel.text = warningMessage
            warningLabel.font = UIFont(name: "GillSans-SemiBold", size: 14)
            warningLabel.textColor = color
            headerView.addSubview(warningLabel)

            symbolImageView.layer.add(pulseAnimation(), forKey: "pulse")

            NSLayoutConstraint.activate([
                symbolImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                symbolImageView.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 8),
                symbolImageView.widthAnchor.constraint(equalToConstant: 20),
                symbolImageView.heightAnchor.constraint(equalToConstant: 20),
                
                warningLabel.centerYAnchor.constraint(equalTo: symbolImageView.centerYAnchor),
                warningLabel.leadingAnchor.constraint(equalTo: symbolImageView.trailingAnchor, constant: 4)
            ])
        }

        NSLayoutConstraint.activate([
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16)
        ])

        return headerView
    }

    // Determine header color based on item expiration
    func determineHeaderColor(for sectionDate: Date) -> UIColor {
        if let sectionItems = items[sectionDate] {
            let closestExpirationDate = sectionItems.compactMap({ $0.date }).min() ?? sectionDate
            let daysToExpiration = daysUntilExpiration(from: closestExpirationDate)
            
            if daysToExpiration < 0 {
                return ColoursManager.fourth! // Expired items
            } else if daysToExpiration <= 3 {
                return ColoursManager.fifth! // Items expiring in 3 days or less
            }
        }
        return ColoursManager.first! // Default color
    }

    // Generate pulse animation for header warning icon
    func pulseAnimation() -> CABasicAnimation {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 1.0
        pulse.toValue = 1.3
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulse.autoreverses = true
        pulse.repeatCount = .greatestFiniteMagnitude
        return pulse
    }
    
    // Set height for section headers
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Adjust the height as needed
    }
    
    // Handle deleting of items
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dateKey = Array(items.keys)[indexPath.section]
            
            if var itemArray = items[dateKey], indexPath.row < itemArray.count {
                // Fetch the Core Data object to delete
                let objectToDelete = itemArray[indexPath.row]
                
                // debugging the delete bug
                print("Deleting item at row: \(indexPath.row)")
                print("Items before deletion: \(itemArray)")
                print("Deleting item: \(objectToDelete)")

                // Delete the object using ItemManager
                itemManager.deleteItem(objectToDelete)

                // Remove the item from the array
                itemArray.remove(at: indexPath.row)

                // Update the items dictionary and UI accordingly
                if itemArray.isEmpty {
                    items.removeValue(forKey: dateKey)
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                } else {
                    items[dateKey] = itemArray
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }

                // Update the empty state view
                updateTableViewBackground()
                
                // debugging the delete bug
                print("Deleting item at row: \(indexPath.row)")
                print("Items before deletion: \(itemArray)")
                print("Deleting item: \(objectToDelete)")
            }
        }
    }
    
    // Calculate days until expiration for an item
    func daysUntilExpiration(from date: Date) -> Int {
        let calendar = Calendar.current
        let startOfCurrentDay = calendar.startOfDay(for: Date())
        let startOfExpirationDay = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: startOfCurrentDay, to: startOfExpirationDay)
        return components.day ?? 0
    }
    
    
    // MARK: - Navigation Bar Button Action
    
    // Action for right bar button
    @objc func rightBarButtonTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // selection for "Add using camera"
        alertController.addAction(UIAlertAction(title: "Add using camera", style: .default, handler: { [weak self] (action) in
            print("Add using camera pressed")
            let sheetViewController = CustomSheetViewController()
            sheetViewController.delegate = self
            sheetViewController.modalPresentationStyle = .formSheet
            if let sheetPresentationController = sheetViewController.sheetPresentationController {
                sheetPresentationController.detents = [.medium()]
                sheetPresentationController.prefersGrabberVisible = true
            }
            self?.present(sheetViewController, animated: true, completion: nil)
        }))
        
        // selection for "Add manually"
        alertController.addAction(UIAlertAction(title: "Add manually", style: .default, handler: { [weak self] (action) in
            self?.performSegue(withIdentifier: "MainToPickManually", sender: self)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Action for left bar button (info about the app and attributions)
    @objc func leftBarButtonTapped() {
        let alertController = UIAlertController(title: "App Info",
                                                message: "Made by Ida Parkkali\nIcons by Icons8\nIllustration by Elisabet Guba from Ouch!\nThank you for testing my app!",
                                                preferredStyle: .alert)
        
        // Action for opening the link
        let linkAction = UIAlertAction(title: "Visit Icons8.com", style: .default) { _ in
            if let url = URL(string: "https://icons8.com") {
                    UIApplication.shared.open(url)
            }
        }

        // Cancel action
        let cancelAction = UIAlertAction(title: "Go back", style: .cancel)

        
        alertController.addAction(linkAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
}

// Protocol definitions (for this file to work with PickManuallyController and CustomSheetViewController)
protocol PickManuallyViewControllerDelegate: AnyObject {
    func didAddNewItem(title: String, image: UIImage?, date: Date)}

protocol CustomSheetViewControllerDelegate: AnyObject {
    func didAddNewItem(title: String, image: UIImage?, date: Date)
}

// Consistency to the PickManuallyViewControllerDelegate and CustomSheetViewControllerDelegate protocols
extension TableViewController: PickManuallyViewControllerDelegate, CustomSheetViewControllerDelegate {
    func didAddNewItem(title: String, image: UIImage?, date: Date) {
        itemManager.addItem(title: title, image: image, date: date)
        items = itemManager.fetchItems()
        updateTableViewBackground()
    }
}

// Extension for shared DateFormatter instance
extension DateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}


