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
    
    @IBOutlet weak var hiddenNameLabel: UILabel!
    @IBOutlet weak var hiddenTextField: UITextField!
    
    @IBOutlet weak var hiddenTakePictureButton: UIButton!
    

    let productFetcher = ProductFetcher()

    override func viewDidLoad() {
        super.viewDidLoad()
        manualDoneButton.addTarget(self, action: #selector(manualDoneButtonTapped), for: .touchUpInside)
        
        let tapGestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGestureKeyboard)
        let tapGestureDatePicker = UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker))
            view.addGestureRecognizer(tapGestureDatePicker)
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
                    if let url = URL(string: product.image_front_url) {
                        self?.loadImage(from: url) { image in
                            if let image = image {
                                // Use your UIImage here
                                self?.showImageAlert(name: product.product_name, picture: image)
                            } else {
                                print("Error loading image")
                            }
                        }
                    }
                

                case .failure(let error):
                    print("Error fetching product: \(error)")
                    self?.showAlert()
                }
            }
        }
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
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
    
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to fetch product details.", preferredStyle: .alert)

        // Try Again Action
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.barcodeTextFieldFill.text = ""
            // Any additional code if needed when 'Try Again' is tapped
        }
        alert.addAction(tryAgainAction)

        // Add Product Name Manually Action
        let addManuallyAction = UIAlertAction(title: "Add Product Name Manually", style: .default) { [weak self] _ in
            self?.showManualEntryFields()
        }
        alert.addAction(addManuallyAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    func showManualEntryFields() {
        // Assuming you have outlets for these UI elements
        hiddenNameLabel.isHidden = false
        hiddenTextField.isHidden = false
        hiddenTakePictureButton.isHidden = false
        
    }
    
    func showImageAlert(name: String, picture: UIImage) {
        // Add extra lines in the message for spacing
        let message = name + "\n\n\n\n\n\n"
        let alert = UIAlertController(title: "Is this the product you scanned?", message: message, preferredStyle: .alert)

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        imageView.contentMode = .scaleAspectFit
        imageView.image = picture

        alert.view.addSubview(imageView)

        // Adjust the image view constraints or frame
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 80), // Adjust this constant as needed
            imageView.widthAnchor.constraint(equalToConstant: 250),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }



    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func dismissDatePicker() {
        view.endEditing(true)
        //manualDatePickerFill.resignFirstResponder()
    }


}

