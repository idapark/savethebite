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
    let imagePicker = UIImagePickerController()
    let textDetectionUtility = DetectTextManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemManager.populateItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Item", style: .plain, target: self, action: #selector(rightBarButtonTapped))
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
        }
        
        return cell
    }
    
    // MARK: - Navigation Bar Button Action
    
    @objc func rightBarButtonTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Add using camera", style: .default, handler: { [weak self] (action) in
            print("Add using camera pressed")
            self?.presentCamera()
        }))
        alertController.addAction(UIAlertAction(title: "Add manually", style: .default, handler: { (action) in
            // Handle Option 2
            print("Add manually pressed")
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
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
            textDetectionUtility.detectText(in: ciImage) { [weak self] detectedText in
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
}


    
    
