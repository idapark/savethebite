//
//  TableViewController.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 14.11.2023.
//

import UIKit
import AVFoundation
import Vision
import CoreData


class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //var itemManager = ItemManager()
    var itemManager: ItemManager!
    // let imagePicker = UIImagePickerController()
    // let textDetectionUtility = DetectBarcodeManager()
    let sheetViewController = CustomSheetViewController()
    var emptyTableViewGifView: UIImageView?
    var emptyTableViewContainerView: UIView?
    var emptyMessageLabel: UILabel?
    var items: [Date: [StoredItem]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        itemManager = ItemManager(managedContext: managedContext)

        items = itemManager.fetchItems()
        let sortedItems = itemManager.fetchItems().sorted(by: { $0.key < $1.key })
        items = Dictionary(uniqueKeysWithValues: sortedItems)

        
        self.navigationItem.title = "SaveTheBite"
        
        tableView.backgroundColor = ColoursManager.first
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = ColoursManager.second // Dynamic color for background
        appearance.titleTextAttributes = [.foregroundColor: ColoursManager.third as Any] // Dynamic color for title

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        
        self.navigationItem.backBarButtonItem = backButton

        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactAppearance = appearance
        }
        //itemManager.populateItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Item", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "About", style: .plain, target: self, action: #selector(leftBarButtonTapped))
        
        // Initialize the container view
        emptyTableViewContainerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 300))  // Adjust height as needed
        tableView.addSubview(emptyTableViewContainerView!)
            
        // Initialize and configure the GIF view
        emptyTableViewGifView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200))
        emptyTableViewGifView?.loadGif(name: "techny-shopping-basket-full-of-groceries")
        emptyTableViewGifView?.contentMode = .scaleAspectFit
        emptyTableViewContainerView?.addSubview(emptyTableViewGifView!)

        // Initialize and configure the label
        emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 200, width: tableView.bounds.width, height: 100))
        emptyMessageLabel?.text = "Seems like you don't have any items added.\nYou can add items by pressing the\nbutton on the upper right corner."
        emptyMessageLabel?.textAlignment = .center
        emptyMessageLabel?.textColor = .white
        emptyMessageLabel?.font = UIFont.systemFont(ofSize: 16) // Adjust font size as needed
        emptyMessageLabel?.numberOfLines = 0  // Allows for multiple lines
        emptyTableViewContainerView?.addSubview(emptyMessageLabel!)

        emptyTableViewContainerView?.isHidden = true // Initially hidden
        /*
        emptyTableViewGifView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200))
        emptyTableViewGifView?.loadGif(name: "techny-shopping-basket-full-of-groceries")
        emptyTableViewGifView?.contentMode = .scaleAspectFit
        tableView.addSubview(emptyTableViewGifView!)
        emptyTableViewGifView?.isHidden = true // Initially hidden
         */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tableView.reloadData()
        items = itemManager.fetchItems()
        updateTableViewBackground()
    }
    
    func updateTableViewBackground() {
        let groupedItems = itemManager.fetchItems()
        let itemCount = groupedItems.values.flatMap { $0 }.count
        tableView.reloadData()
        emptyTableViewContainerView?.isHidden = itemCount != 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyTableViewContainerView?.center = CGPoint(x: tableView.center.x, y: tableView.center.y - (emptyTableViewContainerView?.frame.height ?? 0) / 2)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToPickManually",
           let destinationVC = segue.destination as? PickManuallyViewController {
            destinationVC.delegate = self
        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.keys.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedKeys = items.keys.sorted(by: <)
        let date = sortedKeys[section]
        return items[date]?.count ?? 0
    }
    
    //override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        let date = Array(items.keys)[section]
    //        return items[date]?.count ?? 0
    //    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Array(items.keys)[section]
        // Format the date as needed
        return DateFormatter.shared.string(from: date)
        //return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell else {
            fatalError("Expected CustomTableViewCell")
        }
        
        let sortedKeys = items.keys.sorted(by: <)
        let date = sortedKeys[indexPath.section]
        if let storedItem = items[date]?[indexPath.row] {
            // Configure your cell...
            cell.customCellLabel.text = storedItem.title
            if let imageData = storedItem.image {
                cell.customCellPicture.image = UIImage(data: imageData)
            }
            // Check if the item is expiring in 3 days or less
            let daysToExpiration = daysUntilExpiration(from: storedItem.date!)
            if daysToExpiration <= 3 {
                // Change corner color to red
                cell.layer.cornerRadius = 10
                cell.layer.borderWidth = 2
                cell.layer.borderColor = determineHeaderColor(for: date).cgColor
            } else {
                // Reset to default appearance
                cell.layer.cornerRadius = 10
                cell.layer.borderWidth = 0
            }
        }
        print("cellForRowAt: cell is being configured with the correct item and that the item has an image")
        
        return cell
    }
    
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = ColoursManager.first // Choose a background color

        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = ColoursManager.third // Set your desired text color
        headerLabel.font = ColoursManager.font1 // Customize font as needed

        let date = Array(items.keys)[section]
        headerLabel.text = DateFormatter.shared.string(from: date)
        headerView.addSubview(headerLabel)

        if let sectionItems = items[date], sectionItems.contains(where: { daysUntilExpiration(from: $0.date!) <= 3 }) {
            let symbolImageView = UIImageView()
            symbolImageView.translatesAutoresizingMaskIntoConstraints = false
            symbolImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            symbolImageView.tintColor = ColoursManager.fourth
            headerView.addSubview(symbolImageView)
            
            let warningLabel = UILabel()
            warningLabel.translatesAutoresizingMaskIntoConstraints = false
            warningLabel.text = "Items are about to expire"
            warningLabel.font = UIFont.systemFont(ofSize: 14) // Adjust font size as needed
            warningLabel.textColor = ColoursManager.fourth // Adjust color as needed
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
     */
    
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sortedKeys = items.keys.sorted(by: <)
        let date = sortedKeys[section]
        // headerView.backgroundColor = determineHeaderColor(for: date)

        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = ColoursManager.third
        headerLabel.font = ColoursManager.font1
        headerLabel.text = DateFormatter.shared.string(from: date)
        headerView.addSubview(headerLabel)
        
        let symbolImageView = UIImageView()
        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        symbolImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        symbolImageView.tintColor = determineHeaderColor(for: date)
        headerView.addSubview(symbolImageView)
        
        let warningLabel = UILabel()
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.text = "Items are about to expire"
        warningLabel.font = UIFont.systemFont(ofSize: 14) // Adjust font size as needed
        warningLabel.textColor = determineHeaderColor(for: date) // Adjust color as needed
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

        NSLayoutConstraint.activate([
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16)
        ])

        return headerView
    }
    
     */
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sortedKeys = items.keys.sorted(by: <)
        let date = sortedKeys[section]
        headerView.backgroundColor = ColoursManager.first // Choose a background color

        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = ColoursManager.third
        headerLabel.font = ColoursManager.font1
        headerLabel.text = DateFormatter.shared.string(from: date)
        headerView.addSubview(headerLabel)

        var warningMessage = ""
        var color: UIColor = ColoursManager.first! // Default color

        if let sectionItems = items[date] {
            let currentDate = Date()

            if sectionItems.contains(where: { $0.date! < currentDate }) {
                // Some items have already expired
                warningMessage = "The item has expired"
                color = ColoursManager.fourth! // Expired items color
            } else if sectionItems.contains(where: { daysUntilExpiration(from: $0.date!) <= 3 }) {
                // Some items are about to expire
                warningMessage = "Items are about to expire"
                color = ColoursManager.fifth! // Items expiring soon color
            }
        }

        if !warningMessage.isEmpty {
            let symbolImageView = UIImageView()
            symbolImageView.translatesAutoresizingMaskIntoConstraints = false
            symbolImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            symbolImageView.tintColor = color
            headerView.addSubview(symbolImageView)

            let warningLabel = UILabel()
            warningLabel.translatesAutoresizingMaskIntoConstraints = false
            warningLabel.text = warningMessage
            warningLabel.font = UIFont.systemFont(ofSize: 14)
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


    func determineHeaderColor(for sectionDate: Date) -> UIColor {
        // let currentDate = Date()
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
    
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = ColoursManager.first // Choose a background color

        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = ColoursManager.third // Set your desired text color
        //headerLabel.font = UIFont.boldSystemFont(ofSize: 16) // Customize font as needed
        headerLabel.font = ColoursManager.font1 // Customize font as needed

        let date = Array(items.keys)[section]
        headerLabel.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)

        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16), // Adjust the padding as needed
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16)
        ])

        return headerView
    }
     */
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Adjust the height as needed
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dateKey = Array(items.keys)[indexPath.section]
            
            if var itemArray = items[dateKey] {
                // Fetch the Core Data object to delete
                let objectToDelete = itemArray[indexPath.row]

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
            }
        }
    }
    
    func daysUntilExpiration(from date: Date) -> Int {
        let calendar = Calendar.current
        let startOfCurrentDay = calendar.startOfDay(for: Date())
        let startOfExpirationDay = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: startOfCurrentDay, to: startOfExpirationDay)
        return components.day ?? 0
    }
    
    
    // MARK: - Navigation Bar Button Action
    
    @objc func rightBarButtonTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Add using camera", style: .default, handler: { [weak self] (action) in
            print("Add using camera pressed")
            //self?.presentCamera()
            let sheetViewController = CustomSheetViewController()
            sheetViewController.delegate = self  // Set TableViewController as the delegate
            sheetViewController.modalPresentationStyle = .formSheet
            if let sheetPresentationController = sheetViewController.sheetPresentationController {
                sheetPresentationController.detents = [.medium()]  // Adjust this as needed
                sheetPresentationController.prefersGrabberVisible = true
            }
            self?.present(sheetViewController, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Add manually", style: .default, handler: { [weak self] (action) in
            self?.performSegue(withIdentifier: "MainToPickManually", sender: self)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
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

protocol PickManuallyViewControllerDelegate: AnyObject {
    func didAddNewItem(title: String, image: UIImage?, date: Date)}

protocol CustomSheetViewControllerDelegate: AnyObject {
    func didAddNewItem(title: String, image: UIImage?, date: Date)
}

extension TableViewController: PickManuallyViewControllerDelegate, CustomSheetViewControllerDelegate {
    func didAddNewItem(title: String, image: UIImage?, date: Date) {
        itemManager.addItem(title: title, image: image, date: date)
        items = itemManager.fetchItems() // Refresh the items array
            //tableView.reloadData()
        updateTableViewBackground()
    }
}

extension DateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy" // Set your desired format
        return formatter
    }()
}


