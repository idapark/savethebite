//
//  TableViewController.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 14.11.2023.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the right bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Item", style: .plain, target: self, action: #selector(rightBarButtonTapped))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section
        return 10 // Example row count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure your cell...
        cell.textLabel?.text = "Row \(indexPath.row)"

        return cell
    }
    
    // MARK: - Navigation Bar Button Action

    @objc func rightBarButtonTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            // Add actions to the alertController
        alertController.addAction(UIAlertAction(title: "Add using camera", style: .default, handler: { (action) in
                // Handle Option 1
            print("Add using camera")
        }))
        alertController.addAction(UIAlertAction(title: "Add manually", style: .default, handler: { (action) in
                // Handle Option 2
            print("Add manually")
        }))
            // Add more options as needed...

            // Add cancel button
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            // For iPad compatibility
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItem
        }

            // Present the action sheet
        self.present(alertController, animated: true, completion: nil)
    }

}


    
    
