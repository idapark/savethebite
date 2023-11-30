//
//  TableViewController.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 14.11.2023.
//

import UIKit
import AVFoundation
import Vision


class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var itemManager = ItemManager()
    // let imagePicker = UIImagePickerController()
    // let textDetectionUtility = DetectBarcodeManager()
    let sheetViewController = CustomSheetViewController()
    var emptyTableViewGifView: UIImageView?
    var emptyTableViewContainerView: UIView?
    var emptyMessageLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = ColoursManager.first
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = ColoursManager.second // Dynamic color for background
        appearance.titleTextAttributes = [.foregroundColor: ColoursManager.third as Any] // Dynamic color for title

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactAppearance = appearance
        }
        itemManager.populateItems()
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
        updateTableViewBackground()
    }
    
    func updateTableViewBackground() {
        let itemCount = itemManager.items.values.flatMap { $0 }.count
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
        return itemManager.items.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = Array(itemManager.items.keys)[section]
        return itemManager.items[date]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Array(itemManager.items.keys)[section]
        // Format the date as needed
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell else {
            fatalError("Expected CustomTableViewCell")
        }
        
        let date = Array(itemManager.items.keys)[indexPath.section]
        if let item = itemManager.items[date]?[indexPath.row] {
            // Configure your cell...
            cell.customCellLabel.text = item.title
            cell.customCellPicture.image = item.image
            cell.layer.cornerRadius = 10 // Adjust this value to your preference
            cell.layer.masksToBounds = true
        }
        print("cellForRowAt: cell is being configured with the correct item and that the item has an image")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = ColoursManager.first // Choose a background color

        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = ColoursManager.third // Set your desired text color
        //headerLabel.font = UIFont.boldSystemFont(ofSize: 16) // Customize font as needed
        headerLabel.font = ColoursManager.font1 // Customize font as needed

        let date = Array(itemManager.items.keys)[section]
        headerLabel.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)

        headerView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16), // Adjust the padding as needed
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16)
        ])

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Adjust the height as needed
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Determine the item to delete from your data source
            let date = Array(itemManager.items.keys)[indexPath.section]
            if var items = itemManager.items[date] {
                items.remove(at: indexPath.row)
                itemManager.items[date] = items

                // Delete the row from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)

                // If there are no more items in the section, you may choose to delete the section or update your UI accordingly
                if items.isEmpty {
                    itemManager.items.removeValue(forKey: date)
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                }
            }
            updateTableViewBackground()
        }
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
                                                message: "Made by Ida Parkkali\nIcons by Icons8\nThank you for testing my app!",
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
    func didAddNewItem(_ item: Item)
}

protocol CustomSheetViewControllerDelegate: AnyObject {
    func didAddNewItem(_ item: Item)
}

extension TableViewController: PickManuallyViewControllerDelegate, CustomSheetViewControllerDelegate {
    func didAddNewItem(_ item: Item) {
        itemManager.addItem(item)
        //tableView.reloadData()
        updateTableViewBackground()
    }
}




    
    
