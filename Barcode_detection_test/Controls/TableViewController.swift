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
            populateItems()
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Item", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        }

        

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = Array(items.keys)[section]
        return items[date]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Array(items.keys)[section]
        // Format the date as needed
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell else {
            fatalError("Expected CustomTableViewCell")
        }

        let date = Array(items.keys)[indexPath.section]
        if let item = items[date]?[indexPath.row] {
            // Configure your cell...
            cell.customCellLabel.text = item.title
            cell.customCellPicture.image = item.image
        }

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


    
    
