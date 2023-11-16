//
//  PickManuallyViewController.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 16.11.2023.
//

import UIKit

class PickManuallyViewController: UIViewController {
    
    @IBOutlet weak var barcodeTextFieldFill: UITextField!
    @IBOutlet weak var manualDatePickerFill: UIDatePicker!
    @IBOutlet weak var manualDoneButton: UIButton!

    let productFetcher = ProductFetcher()

    override func viewDidLoad() {
        super.viewDidLoad()
        manualDoneButton.addTarget(self, action: #selector(manualDoneButtonTapped), for: .touchUpInside)
    }

    @objc func manualDoneButtonTapped() {
        guard let barcode = barcodeTextFieldFill.text, !barcode.isEmpty else {
            // Handle empty barcode field
            print("Barcode field is empty")
            return
        }

        productFetcher.fetchProduct(barcode: barcode) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let product):
                    print("Product Name: \(product.product_name)")
                    print("Image URL: \(product.image_front_url)")
                    // Here you can handle adding the product to your inventory or UI

                case .failure(let error):
                    print("Error fetching product: \(error)")
                    // Handle the error, show an error message, etc.
                }
            }
        }
    }

}
