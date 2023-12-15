//
//  CustomSheetViewController.swift
//  SaveTheBite
//
//  Created by Ida Parkkali on 24.11.2023.
//
// This class is used to handle reading barcode and expiration date using a camera

// Importing necessary frameworks
import UIKit
import Lottie

// CustomSheetViewController class definition, conforming to UIImagePickerControllerDelegate and UINavigationControllerDelegate for image handling
class CustomSheetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Enumeration defining the scan modes available in the application
    enum ScanMode {
        case barcode
        case expirationDate
        case none
    }
    
    // Delegate variable for communication with other view controllers
    weak var delegate: CustomSheetViewControllerDelegate?
    
    // Array containing various date formats to handle different date strings
    var dateFormats: [String] {
        // List of different date formats to be recognized
        return [
            "dd MM yyyy", "d MM yyyy", "dd M yyyy", "d M yyyy",
            "dd.MM.yyyy", "d.MM.yyyy", "dd.M.yyyy", "d.M.yyyy",
            "dd-MM-yyyy", "d-MM-yyyy", "dd-M-yyyy", "d-M-yyyy",
            "dd/MM/yyyy", "d/MM/yyyy", "dd/M/yyyy", "d/M/yyyy",
            "MM/yyyy", "dd.MM.yy",
            "dd.MM.", "ddMMyy",
           
        ]
    }
    
    // Current scanning mode, initialized to 'none'
    var currentScanMode: ScanMode = .none
    
    // UI elements declaration
    let animationView = LottieAnimationView()
    let barcodeButton = UIButton()
    let expirationDateButton = UIButton()
    let doneButton = UIButton()
    let barcodeResultLabel = UILabel()
    let expirationDateResultLabel = UILabel()
    let feedbackLabel = UILabel()
    
    // Utility classes for barcode and text detection
    let barcodeDetectionUtility = DetectBarcodeManager()
    let textDetectionUtility = DetectTextManager()
    
    // Image picker for capturing photos from the camera
    let imagePicker = UIImagePickerController()
    
    // Utility class for fetching product information
    let productFetcher = ProductFetcher()

    // Called after the view controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disabling the auto-resizing mask translation for buttons
        // This allows for manual layout using Auto Layout constraints
        barcodeButton.translatesAutoresizingMaskIntoConstraints = false
        expirationDateButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Defining the dimensions and spacing for the buttons
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = view.bounds.width - 40
        let spacing: CGFloat = 20
        
        // Setting the background color of the view
        view.backgroundColor = ColoursManager.first2
        
        // Configuring the barcode button with title, font, and alignment
        barcodeButton.setTitle("Scan\nBarcode", for: .normal)
        barcodeButton.titleLabel?.font = UIFont(name: "Futura-Bold", size: 13)
        barcodeButton.titleLabel?.textAlignment = .center
        barcodeButton.titleLabel?.numberOfLines = 0
        barcodeButton.setTitleColor(ColoursManager.third, for: .normal)
        barcodeButton.backgroundColor = ColoursManager.second
        barcodeButton.addTarget(self, action: #selector(barcodeButtonTapped), for: .touchUpInside)
        barcodeButton.frame = CGRect(x: 20, y: spacing, width: buttonWidth, height: buttonHeight)
        barcodeButton.layer.borderWidth = 2.0
        barcodeButton.layer.cornerRadius = 8
        barcodeButton.layer.borderColor = ColoursManager.second!.cgColor
        view.addSubview(barcodeButton)

        // Configuring the expiration date button with title, font, and alignment
        expirationDateButton.setTitle("Scan\nExpiration Date", for: .normal)
        expirationDateButton.titleLabel?.font = UIFont(name: "Futura-Bold", size: 13)
        expirationDateButton.titleLabel?.textAlignment = .center
        expirationDateButton.titleLabel?.numberOfLines = 0
        expirationDateButton.setTitleColor(ColoursManager.third, for: .normal)
        expirationDateButton.backgroundColor = ColoursManager.second
        expirationDateButton.addTarget(self, action: #selector(expirationDateButtonTapped), for: .touchUpInside)
        expirationDateButton.frame = CGRect(x: 20, y: barcodeButton.frame.maxY + spacing, width: buttonWidth, height: buttonHeight)
        expirationDateButton.layer.borderWidth = 2.0
        expirationDateButton.layer.cornerRadius = 8
        expirationDateButton.layer.borderColor = ColoursManager.second!.cgColor
        view.addSubview(expirationDateButton)

        // Configuring the done button with title, font, and alignment
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "Futura-Bold", size: 15)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.frame = CGRect(x: 20, y: expirationDateButton.frame.maxY + spacing, width: buttonWidth, height: buttonHeight)
        doneButton.setTitleColor(ColoursManager.third, for: .normal)
        doneButton.backgroundColor = ColoursManager.second
        doneButton.layer.borderWidth = 2.0
        doneButton.layer.cornerRadius = 8
        doneButton.layer.borderColor = ColoursManager.second!.cgColor
        view.addSubview(doneButton)
        
        // Configuring the barcode result label with title, font, and alignment
        barcodeResultLabel.translatesAutoresizingMaskIntoConstraints = false
        barcodeResultLabel.textAlignment = .center
        barcodeResultLabel.font = UIFont(name: "Futura", size: 13)
        barcodeResultLabel.layer.borderWidth = 2.0
        barcodeResultLabel.layer.cornerRadius = 8
        barcodeResultLabel.layer.borderColor = ColoursManager.third!.cgColor
        view.addSubview(barcodeResultLabel)

        // Configuring the expiration date result label with title, font, and alignment
        expirationDateResultLabel.translatesAutoresizingMaskIntoConstraints = false
        expirationDateResultLabel.textAlignment = .center
        expirationDateResultLabel.font = UIFont(name: "Futura", size: 13)
        expirationDateResultLabel.layer.borderWidth = 2.0
        expirationDateResultLabel.layer.cornerRadius = 8
        expirationDateResultLabel.layer.borderColor = ColoursManager.third!.cgColor
        view.addSubview(expirationDateResultLabel)

        
        // Configuring the feedback label, initially hidden
        feedbackLabel.isHidden = true
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackLabel.textAlignment = .center
        feedbackLabel.textColor = UIColor.red
        view.addSubview(feedbackLabel)
        
        
        // Setup Auto Layout constraints
        setupConstraints()
    
    }
    
    // Function to set up auto layout constraints
    private func setupConstraints() {
        // Clear any existing constraints if necessary
        view.removeConstraints(view.constraints)

        // Barcode Button Constraints
        NSLayoutConstraint.activate([
            barcodeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            barcodeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            barcodeButton.widthAnchor.constraint(equalToConstant: 100),
            barcodeButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Expiration Date Button Constraints
        NSLayoutConstraint.activate([
            expirationDateButton.topAnchor.constraint(equalTo: barcodeButton.bottomAnchor, constant: 20),
            expirationDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            expirationDateButton.widthAnchor.constraint(equalToConstant: 100),
            expirationDateButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Done Button Constraints
        NSLayoutConstraint.activate([
                doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                doneButton.topAnchor.constraint(equalTo: expirationDateButton.bottomAnchor, constant: 20),
                doneButton.widthAnchor.constraint(equalToConstant: 100),
                doneButton.heightAnchor.constraint(equalToConstant: 50)
            ])

        // Barcode Result Label Constraints
        NSLayoutConstraint.activate([
            barcodeResultLabel.leadingAnchor.constraint(equalTo: barcodeButton.trailingAnchor, constant: 10),
            barcodeResultLabel.centerYAnchor.constraint(equalTo: barcodeButton.centerYAnchor),
            barcodeResultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            barcodeResultLabel.heightAnchor.constraint(equalTo: barcodeButton.heightAnchor)
        ])

        // Expiration Date Result Label Constraints
        NSLayoutConstraint.activate([
            expirationDateResultLabel.leadingAnchor.constraint(equalTo: expirationDateButton.trailingAnchor, constant: 10),
            expirationDateResultLabel.centerYAnchor.constraint(equalTo: expirationDateButton.centerYAnchor),
            expirationDateResultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            expirationDateResultLabel.heightAnchor.constraint(equalTo: expirationDateButton.heightAnchor)
        ])
        
        // Feedback Result Label Constraints
        NSLayoutConstraint.activate([
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 20),
            feedbackLabel.widthAnchor.constraint(equalToConstant: 100),
            feedbackLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // Function called when the barcode button is tapped
    @objc func barcodeButtonTapped() {
        currentScanMode = .barcode
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        // Handling barcode scanning mode and initializing the camera
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false

        present(imagePicker, animated: true)
    }
    
    // Delegate function for handling image picker result
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let image = info[.originalImage] as? UIImage, let ciImage = CIImage(image: image) else { return }

        // Handling image picking result based on the current scanning mode (barcode or expiration date)
        switch currentScanMode {
        case .barcode:
            barcodeDetectionUtility.detectBarcode(in: ciImage) { [weak self] detectedText in
                // Handle barcode detection result
                if let detectedText = detectedText {
                    print("Detected barcode: \(detectedText)")
                    self?.barcodeResultLabel.text = detectedText
                    self?.barcodeResultLabel.textColor = ColoursManager.third
                    // Handle the detected barcode text
                } else {
                    print("No barcode detected")
                    // Handle the case where no barcode is detected
                    self?.barcodeResultLabel.text = "No barcode detected"
                    self?.barcodeResultLabel.textColor = ColoursManager.fourth
                }
            }
        case .expirationDate:
            textDetectionUtility.detectText(in: ciImage) { [weak self] detectedText in
                // Handle text detection result
                if let detectedText = detectedText {
                    print("Detected text: \(detectedText)")
                    // Handle the detected text (expiration date)
                    self?.expirationDateResultLabel.text = detectedText
                    self?.expirationDateResultLabel.textColor =  ColoursManager.third
                } else {
                    print("No text detected")
                    // Handle the case where no text is detected
                    self?.expirationDateResultLabel.text = "Expiration date was not detected"
                    self?.expirationDateResultLabel.textColor = ColoursManager.fourth
                    
                }
            }
        case .none:
            break
        }

        // Reset the scan mode
        currentScanMode = .none
    }
    
    // Function called when the expiration date button is tapped
    @objc func expirationDateButtonTapped() {
        currentScanMode = .expirationDate
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        // Handling expiration date scanning mode and initializing the camera
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false // or true, depending on your need

        present(imagePicker, animated: true)
    }
    
    // Function called when the done button is tapped
    @objc func doneButtonTapped() {
        // Validating barcode and expiration date inputs and fetching product information
        guard let barcode = barcodeResultLabel.text, !barcode.isEmpty else {
            print("Barcode is empty")
            feedbackLabel.isHidden = false
            feedbackLabel.text = "Barcode is empty"
            return
        }

        guard let expirationDateString = expirationDateResultLabel.text, !expirationDateString.isEmpty, let standardizedExpirationDate = standardizedDate(from: expirationDateString) else {
            print("Expiration date is invalid or empty")
            feedbackLabel.isHidden = false
            feedbackLabel.text = "Expiration date is invalid or empty"
            return
        }
        

        productFetcher.fetchProduct(barcode: barcode) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let product):
                    // Handle the success case
                    if let urlString = product.image_front_url, !urlString.isEmpty, let url = URL(string: urlString) {
                        self?.loadImage(from: url) { image in
                            if let image = image {
                                self?.feedbackLabel.isHidden = true
                                print("Successfully got the product based on barcode and expiration date")
                                print("Product Name: \(product.product_name)")
                                print("Image URL: \(String(describing: product.image_front_url))")
                                print("Expiration date of the product (standardized): \(standardizedExpirationDate)")
                                self?.showImageAlert(name: product.product_name, picture: image, date1: standardizedExpirationDate)
                                
                                
                            } else {
                                // problem with image
                                print("Error loading image")
                                self?.feedbackLabel.isHidden = false
                                self?.feedbackLabel.text = "Error loading image"
                            }
                        }
                    } else {
                        // Image URL is empty
                        self?.feedbackLabel.isHidden = false
                        self?.feedbackLabel.text = "Error loading image"
                        
                    }

                case .failure(let error):
                    print("Error fetching product: \(error)")
                    // Handle the error case
                    self?.feedbackLabel.isHidden = false
                    self?.feedbackLabel.text = "Error fetching product"
                }
            }
        }
    }
    
    // Function to show an alert with the image of the scanned product
    func showImageAlert(name: String, picture: UIImage, date1: Date) {

        let formattedDate = DateFormatter.shared.string(from: date1)
        
        // Setting up and displaying an alert with the product image and details
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
        
        // right now only "OK" is allowed, in the future "Cancel" should also be an option
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.playAnimation()
                self?.delegate?.didAddNewItem(title: name, image: picture, date: date1)
                self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)
    }
    
    // Function to play a success animation
    func playAnimation() {
        // Displaying a Lottie animation on successful scanning and saving
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let currentWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }

        currentWindow.addSubview(animationView)

        // Set up the animation view
        animationView.animation = LottieAnimation.named("icons8-success")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.7
        animationView.isHidden = false
        animationView.alpha = 1
        animationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: currentWindow.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: currentWindow.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 200),
            animationView.heightAnchor.constraint(equalToConstant: 200)
        ])

        animationView.play { [weak self] (finished) in
            // Fade out animation after it's done playing
            UIView.animate(withDuration: 1.0, animations: {
                self?.animationView.alpha = 0  // Fade to transparent
            }) { _ in
                self?.animationView.isHidden = true
                self?.animationView.removeFromSuperview()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    // MARK: -  Utility functions for loading an image from a URL and handling date parsing
    
    // Function to load an image from URL
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
    
    // Function to parse and standardize date strings
    func standardizedDate(from dateString: String) -> Date? {
        let currentYear = Calendar.current.component(.year, from: Date())
        let formatter = DateFormatter()

        for format in dateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        // Try parsing short formats and add the current year
        if let shortDate = tryParseShortDate(dateString, withYear: currentYear, formatter: formatter) {
            return shortDate
        }

        return nil
    }

    // Helper function to try parsing dates in short formats
    func tryParseShortDate(_ dateString: String, withYear year: Int, formatter: DateFormatter) -> Date? {
        let shortFormats = ["dd.MM.", "dd.MM.yy", "ddMMyy", "MM/yyyy"]
        let defaultDay = "01" // Default day to use when day is missing

        for format in shortFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                if format == "MM/yyyy" {
                    // For "MM/yyyy" format, add the default day
                    formatter.dateFormat = "dd.MM.yyyy"
                    let newDateString = defaultDay + "." + formatter.string(from: date)
                    return formatter.date(from: newDateString)
                } else if format.contains("yy") {
                    // For "dd.MM.yy" and "ddMMyy" formats, append the century to the year
                    let newDateString = convertToFourDigitYearString(from: dateString, year: year, formatter: formatter)
                    formatter.dateFormat = "dd.MM.yyyy"
                    return formatter.date(from: newDateString)
                }
            }
        }

        return nil
    }

    // Function to convert a two-digit year string to a four-digit year string
    func convertToFourDigitYearString(from dateString: String, year: Int, formatter: DateFormatter) -> String {
        let twoDigitYear = year % 100   // Get the last two digits of the current year

        formatter.dateFormat = "yy"
        if let yearFromDate = formatter.date(from: String(twoDigitYear)) {
            formatter.dateFormat = "yyyy"
            let fourDigitYear = formatter.string(from: yearFromDate)

            return dateString.replacingOccurrences(of: String(twoDigitYear), with: fourDigitYear)
        }

        return dateString
    }
}

