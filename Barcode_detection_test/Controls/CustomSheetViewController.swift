//
//  CustomSheetViewController.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 24.11.2023.
//
import UIKit
import Lottie

class CustomSheetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    enum ScanMode {
        case barcode
        case expirationDate
        case none
    }
    
    weak var delegate: CustomSheetViewControllerDelegate?
    
    var dateFormats: [String] {
        return [
            "dd MM yyyy", "d MM yyyy", "dd M yyyy", "d M yyyy",
            "dd.MM.yyyy", "d.MM.yyyy", "dd.M.yyyy", "d.M.yyyy",
            "dd-MM-yyyy", "d-MM-yyyy", "dd-M-yyyy", "d-M-yyyy",
            "dd/MM/yyyy", "d/MM/yyyy", "dd/M/yyyy", "d/M/yyyy",
            "MM/yyyy", "dd.MM.yy",
            "dd.MM.", "ddMMyy", // Short formats without year
            // Include other formats as needed
        ]
    }
    
    var currentScanMode: ScanMode = .none
    let animationView = LottieAnimationView()
    
    let barcodeButton = UIButton()
    let expirationDateButton = UIButton()
    let doneButton = UIButton()
    let barcodeResultLabel = UILabel()
    let expirationDateResultLabel = UILabel()
    let feedbackLabel = UILabel()
    
    let barcodeDetectionUtility = DetectBarcodeManager()
    let textDetectionUtility = DetectTextManager()
    let imagePicker = UIImagePickerController()
    let productFetcher = ProductFetcher()

    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeButton.translatesAutoresizingMaskIntoConstraints = false
        expirationDateButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = view.bounds.width - 40  // Example width
        let spacing: CGFloat = 20
        
        view.backgroundColor = ColoursManager.first2

        
        //Setup and add the barcode button
        barcodeButton.setTitle("Scan\nBarcode", for: .normal)
        barcodeButton.titleLabel?.font = UIFont(name: "Futura-Bold", size: 13)
        barcodeButton.titleLabel?.textAlignment = .center       // Center the text
        barcodeButton.titleLabel?.numberOfLines = 0
        barcodeButton.setTitleColor(ColoursManager.third, for: .normal)
        barcodeButton.backgroundColor = ColoursManager.second
        barcodeButton.addTarget(self, action: #selector(barcodeButtonTapped), for: .touchUpInside)
        barcodeButton.frame = CGRect(x: 20, y: spacing, width: buttonWidth, height: buttonHeight)
        barcodeButton.layer.borderWidth = 2.0
        barcodeButton.layer.cornerRadius = 8
        barcodeButton.layer.borderColor = ColoursManager.second!.cgColor
        view.addSubview(barcodeButton)

        // Setup and add the expiration date button
        expirationDateButton.setTitle("Scan\nExpiration Date", for: .normal)
        expirationDateButton.titleLabel?.font = UIFont(name: "Futura-Bold", size: 13)
        expirationDateButton.titleLabel?.textAlignment = .center       // Center the text
        expirationDateButton.titleLabel?.numberOfLines = 0
        expirationDateButton.setTitleColor(ColoursManager.third, for: .normal)
        expirationDateButton.backgroundColor = ColoursManager.second
        expirationDateButton.addTarget(self, action: #selector(expirationDateButtonTapped), for: .touchUpInside)
        expirationDateButton.frame = CGRect(x: 20, y: barcodeButton.frame.maxY + spacing, width: buttonWidth, height: buttonHeight)
        expirationDateButton.layer.borderWidth = 2.0
        expirationDateButton.layer.cornerRadius = 8
        expirationDateButton.layer.borderColor = ColoursManager.second!.cgColor
        view.addSubview(expirationDateButton)

        // Setup and add the done button
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
        
        // Configure the barcode result label
        barcodeResultLabel.translatesAutoresizingMaskIntoConstraints = false
        barcodeResultLabel.textAlignment = .center
        barcodeResultLabel.font = UIFont(name: "Futura", size: 13)
        barcodeResultLabel.layer.borderWidth = 2.0
        barcodeResultLabel.layer.cornerRadius = 8
        barcodeResultLabel.layer.borderColor = ColoursManager.third!.cgColor
        view.addSubview(barcodeResultLabel)

        // Configure the expiration date result label
        expirationDateResultLabel.translatesAutoresizingMaskIntoConstraints = false
        expirationDateResultLabel.textAlignment = .center
        expirationDateResultLabel.font = UIFont(name: "Futura", size: 13)
        expirationDateResultLabel.layer.borderWidth = 2.0
        expirationDateResultLabel.layer.cornerRadius = 8
        expirationDateResultLabel.layer.borderColor = ColoursManager.third!.cgColor
        view.addSubview(expirationDateResultLabel)

        
        // Configure the feedback label
        feedbackLabel.isHidden = true
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackLabel.textAlignment = .center
        feedbackLabel.textColor = UIColor.red
        view.addSubview(feedbackLabel)
        
        
        // Setup Auto Layout constraints
        setupConstraints()
    
    }
    
    private func setupConstraints() {
        // Clear any existing constraints if necessary
        view.removeConstraints(view.constraints)

        // Barcode Button Constraints
        NSLayoutConstraint.activate([
            barcodeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            barcodeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            barcodeButton.widthAnchor.constraint(equalToConstant: 100), // Set a fixed width
            barcodeButton.heightAnchor.constraint(equalToConstant: 50) // Set a fixed height
        ])

        // Expiration Date Button Constraints
        NSLayoutConstraint.activate([
            expirationDateButton.topAnchor.constraint(equalTo: barcodeButton.bottomAnchor, constant: 20),
            expirationDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            expirationDateButton.widthAnchor.constraint(equalToConstant: 100), // Set a fixed width
            expirationDateButton.heightAnchor.constraint(equalToConstant: 50) // Set a fixed height
        ])

        // Done Button Constraints
        NSLayoutConstraint.activate([
                doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Horizontally center in view
                doneButton.topAnchor.constraint(equalTo: expirationDateButton.bottomAnchor, constant: 20), // Position below the expiration date button
                doneButton.widthAnchor.constraint(equalToConstant: 100), // Set a fixed width
                doneButton.heightAnchor.constraint(equalToConstant: 50) // Set a fixed height
            ])

        // Barcode Result Label Constraints
        NSLayoutConstraint.activate([
            barcodeResultLabel.leadingAnchor.constraint(equalTo: barcodeButton.trailingAnchor, constant: 10),
            barcodeResultLabel.centerYAnchor.constraint(equalTo: barcodeButton.centerYAnchor),
            barcodeResultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            barcodeResultLabel.heightAnchor.constraint(equalTo: barcodeButton.heightAnchor) // Set label height equal to button height
        ])

        // Expiration Date Result Label Constraints
        NSLayoutConstraint.activate([
            expirationDateResultLabel.leadingAnchor.constraint(equalTo: expirationDateButton.trailingAnchor, constant: 10),
            expirationDateResultLabel.centerYAnchor.constraint(equalTo: expirationDateButton.centerYAnchor),
            expirationDateResultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            expirationDateResultLabel.heightAnchor.constraint(equalTo: expirationDateButton.heightAnchor) // Set label height equal to button height
        ])
        
        // Feedback Result Label Constraints
        NSLayoutConstraint.activate([
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 20), // Position
            feedbackLabel.widthAnchor.constraint(equalToConstant: 100), // Set a fixed width
            feedbackLabel.heightAnchor.constraint(equalToConstant: 50) // Set a fixed height height
        ])
    }

    @objc func barcodeButtonTapped() {
        currentScanMode = .barcode
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }

        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false // or true, depending on your need

        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let image = info[.originalImage] as? UIImage, let ciImage = CIImage(image: image) else { return }

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
    


    @objc func expirationDateButtonTapped() {
        // Handle expiration date button tap
        currentScanMode = .expirationDate
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }

        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false // or true, depending on your need

        present(imagePicker, animated: true)
    }
    
    /*
    @objc func doneButtonTapped() {
        // Handle done button tap
        
        dismiss(animated: true, completion: nil)
    }
     */
    @objc func doneButtonTapped() {
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
                    // Optionally use expirationDate here as needed
                    // ...
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
                self?.playAnimation()
                self?.delegate?.didAddNewItem(title: name, image: picture, date: date1)
                self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)
    }
    
    func playAnimation() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let currentWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }

        currentWindow.addSubview(animationView)

        // Set up the animation view
        animationView.animation = LottieAnimation.named("icons8-success")  // Your animation file name
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.7
        animationView.isHidden = false
        animationView.alpha = 1  // Start fully visible
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

        return nil // Return nil if no format matched
    }

    func tryParseShortDate(_ dateString: String, withYear year: Int, formatter: DateFormatter) -> Date? {
        let shortFormats = ["dd.MM.", "dd.MM.yy", "ddMMyy", "MM/yyyy"] // Include "dd.MM.yy" and "ddMMyy"
        let defaultDay = "01" // Default day to use when day is missing

        for format in shortFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                if format == "MM/yyyy" {
                    // For "MM/yyyy" format, prepend the default day
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

    func convertToFourDigitYearString(from dateString: String, year: Int, formatter: DateFormatter) -> String {
        // let century = year / 100 * 100  // Get the century part of the current year
        let twoDigitYear = year % 100   // Get the last two digits of the current year

        formatter.dateFormat = "yy"
        if let yearFromDate = formatter.date(from: String(twoDigitYear)) {
            formatter.dateFormat = "yyyy"
            let fourDigitYear = formatter.string(from: yearFromDate)

            return dateString.replacingOccurrences(of: String(twoDigitYear), with: fourDigitYear)
        }

        return dateString // Return original string if conversion is not possible
    }
}


// might not be needed?
/*
 extension DateFormatter {
 static let yourFormatter: DateFormatter = {
 let formatter = DateFormatter()
 // Set the date format according to how your date is being displayed
 formatter.dateFormat = "dd/MM/yyyy" // Modify this as per your date format
 return formatter
 }()
 }
 */
