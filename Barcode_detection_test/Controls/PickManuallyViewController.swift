//
//  PickManuallyViewController.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 16.11.2023.
//

import UIKit

class PickManuallyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: PickManuallyViewControllerDelegate?
    
    @IBOutlet weak var barcodeTextFieldFill: UITextField!
    @IBOutlet weak var manualDatePickerFill: UIDatePicker!
    @IBOutlet weak var manualDoneButton: UIButton!
    
    @IBOutlet weak var hiddenNameLabel: UILabel!
    @IBOutlet weak var hiddenTextField: UITextField!
    
    @IBOutlet weak var hiddenTakePictureButton: UIButton!
    
    var cameraCompletionHandler: ((UIImage?) -> Void)?
    
    let imagePicker = UIImagePickerController()
    let productFetcher = ProductFetcher()
    let backButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a new back button
        
        backButton.title = "Back"
        backButton.tintColor = UIColor.red

        // Assign the back button to the navigationItem of the view controller
        self.navigationItem.backBarButtonItem = backButton
        manualDoneButton.addTarget(self, action: #selector(manualDoneButtonTapped), for: .touchUpInside)
        
        let tapGestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGestureKeyboard)
        let tapGestureDatePicker = UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker))
            view.addGestureRecognizer(tapGestureDatePicker)
        addDoneButtonOnKeyboard()
    
        
    }

    @objc func manualDoneButtonTapped() {
        guard let barcode = barcodeTextFieldFill.text, !barcode.isEmpty else {
            print("Barcode field is empty")
            return
        }
        
        let selectedDate = manualDatePickerFill.date

        productFetcher.fetchProduct(barcode: barcode) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let product):
                    //print("Product Name: \(product.product_name)")
                    //print("Image URL: \(product.image_front_url)")

                    // Check if the image URL string is not empty
                    if let urlString = product.image_front_url, !urlString.isEmpty, let url = URL(string: urlString) {
                        self?.loadImage(from: url) { image in
                            if let image = image {
                                self?.showImageAlert(name: product.product_name, picture: image, date1: selectedDate)
                            } else {
                                print("Error loading image")
                            }
                        }
                    } else {
                        // Image URL is empty
                        self?.showNoImageAlert(productName: product.product_name)
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
    
    // MARK: - Different alerts
    
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
    
    func showNoImageAlert(productName: String) {
        
        let selectedDate = manualDatePickerFill.date
        
        let alert = UIAlertController(title: "Image Not Available", message: "The image for \(productName) is not available.", preferredStyle: .alert)

        let takePictureAction = UIAlertAction(title: "Take a Picture", style: .default) { [weak self] _ in
            // Code to initiate taking a picture
            self?.presentCamera { image in
                if let image = image {
                    //let newItem = Item(title: productName, image: image, date: selectedDate)
                    self?.delegate?.didAddNewItem(title: productName, image: image, date: selectedDate)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    // Handle the case where no image was taken
                }
            }
        }

        let addWithoutPictureAction = UIAlertAction(title: "Add without Picture", style: .default) { [weak self] _ in
            //let newItem = Item(title: productName, image: nil, date: selectedDate)
            self?.delegate?.didAddNewItem(title: productName, image: nil, date: selectedDate)
            self?.navigationController?.popViewController(animated: true)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(takePictureAction)
        alert.addAction(addWithoutPictureAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    
    func presentCamera(completion: @escaping (UIImage?) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available")
            completion(nil)
            return
        }
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        self.cameraCompletionHandler = completion // Save the completion handler
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        cameraCompletionHandler?(image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        cameraCompletionHandler?(nil)
    }
    
    
    func showImageAlert(name: String, picture: UIImage, date1: Date) {
        // Add extra newlines to create space for the image
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd.MM.yyyy" // Custom format for date

        let formattedDate = DateFormatter.shared.string(from: date1)

        let message = "\(name)\n\(formattedDate)\n\n\n\n\n\n\n\n\n\n" // Using the formatted date
        let alert = UIAlertController(title: "Is this the product you scanned?", message: message, preferredStyle: .alert)

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = picture

        alert.view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 125), // Adjust this constant based on the space needed
            imageView.widthAnchor.constraint(equalToConstant: 250), // Adjust size as needed
            imageView.heightAnchor.constraint(equalToConstant: 150) // Adjust size as needed
        ])

        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                //let newItem = Item(title: name, image: picture, date: date1)
                self?.delegate?.didAddNewItem(title: name, image: picture, date: date1)
                self?.navigationController?.popViewController(animated: true)
            }
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


