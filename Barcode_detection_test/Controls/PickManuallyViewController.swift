//
//  PickManuallyViewController.swift
//  SaveTheBite
//
//  Created by Ida Parkkali on 16.11.2023.
//
// This class is used to handle adding barcode and expiration date manually

// Importing necessary UIKit framework
import UIKit

// PickManuallyViewController class, conforming to UIImagePickerControllerDelegate and UINavigationControllerDelegate
class PickManuallyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Delegate variable for communication with other view controllers
    weak var delegate: PickManuallyViewControllerDelegate?
    
    // Outlets for user interface elements
    @IBOutlet weak var barcodeTextFieldFill: UITextField! // Text field for entering barcode manually
    @IBOutlet weak var manualDatePickerFill: UIDatePicker! // Date picker for selecting expiration date
    @IBOutlet weak var manualDoneButton: UIButton! // Button to complete the manual entry process
    
    // Additional hidden UI elements for manual product entry
    @IBOutlet weak var hiddenNameLabel: UILabel!
    @IBOutlet weak var hiddenTextField: UITextField!
    @IBOutlet weak var hiddenTakePictureButton: UIButton!
    
    // Completion handler for camera functionality
    var cameraCompletionHandler: ((UIImage?) -> Void)?
    
    // Image picker for capturing photos
    let imagePicker = UIImagePickerController()
    // Product fetcher for retrieving product information
    let productFetcher = ProductFetcher()
    // Back button for navigation
    let backButton = UIBarButtonItem()

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up the back button
        backButton.title = "Back"
        self.navigationItem.backBarButtonItem = backButton
        
        // Adding action to the 'Done' button
        manualDoneButton.addTarget(self, action: #selector(manualDoneButtonTapped), for: .touchUpInside)
        
        // Adding gesture recognizers to dismiss keyboard and date picker
        let tapGestureKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGestureKeyboard)
        let tapGestureDatePicker = UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker))
            view.addGestureRecognizer(tapGestureDatePicker)
        
        // Adding a 'Done' button to the keyboard
        addDoneButtonOnKeyboard()
    }

    // Function called when the 'Done' button is tapped
    @objc func manualDoneButtonTapped() {
        // Validating barcode input
        guard let barcode = barcodeTextFieldFill.text, !barcode.isEmpty else {
            print("Barcode field is empty")
            return
        }
        
        // Retrieving selected date from the date picker
        let selectedDate = manualDatePickerFill.date
        
        // Fetching product information based on the barcode
        productFetcher.fetchProduct(barcode: barcode) { [weak self] result in
            DispatchQueue.main.async {
                // Handling the result of the product fetch
                switch result {
                case .success(let product):
                    // Processing successful product fetch
                    if let urlString = product.image_front_url, !urlString.isEmpty, let url = URL(string: urlString) {
                        // Loading product image if available
                        self?.loadImage(from: url) { image in
                            // Displaying image alert with the product details
                            if let image = image {
                                self?.showImageAlert(name: product.product_name, picture: image, date1: selectedDate)
                            } else {
                                print("Error loading image")
                            }
                        }
                    } else {
                        // Handling cases where image URL is empty
                        self?.showNoImageAlert(productName: product.product_name)
                    }

                case .failure(let error):
                    // Handling errors in product fetch
                    print("Error fetching product: \(error)")
                    self?.showAlert()
                }
            }
        }
    }
    
    // Function to load an image from a URL
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
    
    // Function to add a 'Done' button to the keyboard
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
    
    // Function to show an alert in case of an error fetching product details
    func showAlert() {
        // Creating an alert for the error scenario
        let alert = UIAlertController(title: "Error", message: "Failed to fetch product details.", preferredStyle: .alert)

        // Defining 'Try Again' action to allow the user to retry fetching the product
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.barcodeTextFieldFill.text = ""
        }
        alert.addAction(tryAgainAction)

        // Defining action to manually add the product name
        let addManuallyAction = UIAlertAction(title: "Add Product Name Manually", style: .default) { [weak self] _ in
            self?.showManualEntryFields()
        }
        alert.addAction(addManuallyAction)

        // Presenting the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // Function to show additional UI elements for manual entry
    func showManualEntryFields() {
        // Unhide UI elements that allow the user to enter product name manually and take a picture
        // doesn't actually add items yet, just shows the option
        hiddenNameLabel.isHidden = false
        hiddenTextField.isHidden = false
        hiddenTakePictureButton.isHidden = false
    }
    
    // Function to show an alert when no image is available for the product
    func showNoImageAlert(productName: String) {
        
        let selectedDate = manualDatePickerFill.date
        
        // Creating an alert to inform the user that no image is available
        let alert = UIAlertController(title: "Image Not Available", message: "The image for \(productName) is not available.", preferredStyle: .alert)

        // Defining actions for the alert
        let takePictureAction = UIAlertAction(title: "Take a Picture", style: .default) { [weak self] _ in
            // Code to initiate taking a picture
            self?.presentCamera { image in
                if let image = image {
                    // Call the delegate method to handle the new item with the captured image
                    self?.delegate?.didAddNewItem(title: productName, image: image, date: selectedDate)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                }
            }
        }

        let addWithoutPictureAction = UIAlertAction(title: "Add without Picture", style: .default) { [weak self] _ in
            // Call the delegate method to handle the new item without an image
            self?.delegate?.didAddNewItem(title: productName, image: nil, date: selectedDate)
            self?.navigationController?.popViewController(animated: true)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // Adding actions to the alert
        alert.addAction(takePictureAction)
        alert.addAction(addWithoutPictureAction)
        alert.addAction(cancelAction)

        // Presenting the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // Function to present the camera interface
    func presentCamera(completion: @escaping (UIImage?) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available")
            completion(nil)
            return
        }
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        self.cameraCompletionHandler = completion
        present(imagePicker, animated: true)
    }
    
    // Delegate function called when an image has been picked or captured
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        cameraCompletionHandler?(image)
    }

    // Delegate function called when the image picker is cancelled without selecting an image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        cameraCompletionHandler?(nil)
    }
    
    // Function to show an alert with product details and an image
    func showImageAlert(name: String, picture: UIImage, date1: Date) {

        let formattedDate = DateFormatter.shared.string(from: date1)

        let message = "\(name)\n\(formattedDate)\n\n\n\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: "Is this the product you scanned?", message: message, preferredStyle: .alert)

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = picture

        alert.view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 125),
            imageView.widthAnchor.constraint(equalToConstant: 250),
            imageView.heightAnchor.constraint(equalToConstant: 150)
        ])

        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.delegate?.didAddNewItem(title: name, image: picture, date: date1)
                self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)
    }

    // Functions to dismiss the keyboard and the date picker
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func dismissDatePicker() {
        view.endEditing(true)
    }

}


