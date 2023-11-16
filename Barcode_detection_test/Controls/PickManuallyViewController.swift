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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        addDoneButtonOnKeyboard()
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
    
    func addDoneButtonOnKeyboard() {
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()

            barcodeTextFieldFill.inputAccessoryView = doneToolbar
        }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }


}

