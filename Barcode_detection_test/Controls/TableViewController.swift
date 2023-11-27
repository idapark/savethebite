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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
    
    /*
    func presentCamera() {
        sheetViewController.modalPresentationStyle = .formSheet

        if let sheetPresentationController = sheetViewController.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]  // Adjust this as needed
            sheetPresentationController.prefersGrabberVisible = true
        }

        self.present(sheetViewController, animated: true, completion: nil)
    }
     */
    
    /*
    func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            // Handle camera not available scenario
            print("The camera was not available")
            return
        }
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage, let ciImage = CIImage(image: image) {
            textDetectionUtility.detectBarcode(in: ciImage) { [weak self] detectedText in
                guard let self = self else { return } // Safely unwrapping self
                guard let detectedText = detectedText else {
                    // Handle no text found
                    print("Detected text could not be opened")
                    return
                }
                // Now you can use 'self' here to refer to your TableViewController instance
                // For example, updating a property or calling a method on 'self'
                print("The detected text: \(detectedText)")
                
            }
        }
    }
     */
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
        tableView.reloadData()
    }
}




    
    
