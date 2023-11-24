//
//  CustomSheetViewController.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 24.11.2023.
//
import UIKit

class CustomSheetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    enum ScanMode {
        case barcode
        case expirationDate
        case none
    }
    
    var dateFormats: [String] {
        return [
            "dd MM yyyy", "d MM yyyy", "dd M yyyy", "d M yyyy",
            "dd.MM.yyyy", "d.MM.yyyy", "dd.M.yyyy", "d.M.yyyy",
            "dd-MM-yyyy", "d-MM-yyyy", "dd-M-yyyy", "d-M-yyyy",
            "dd/MM/yyyy", "d/MM/yyyy", "dd/M/yyyy", "d/M/yyyy",
            "MM/yyyy",
            "dd.MM.", "ddMMyy", // Short formats without year
            // Include other formats as needed
        ]
    }
    
    var currentScanMode: ScanMode = .none
    
    let barcodeButton = UIButton()
    let expirationDateButton = UIButton()
    let doneButton = UIButton()
    let barcodeResultLabel = UILabel()
    let expirationDateResultLabel = UILabel()
    
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

        // Setup and add the barcode button
        barcodeButton.setTitle("Scan\nBarcode", for: .normal)
        barcodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        barcodeButton.titleLabel?.textAlignment = .center       // Center the text
        barcodeButton.titleLabel?.numberOfLines = 0
        barcodeButton.addTarget(self, action: #selector(barcodeButtonTapped), for: .touchUpInside)
        barcodeButton.frame = CGRect(x: 20, y: spacing, width: buttonWidth, height: buttonHeight)
        barcodeButton.layer.borderWidth = 2.0
        barcodeButton.layer.cornerRadius = 8
        barcodeButton.layer.borderColor = UIColor.label.cgColor
        view.addSubview(barcodeButton)

        // Setup and add the expiration date button
        expirationDateButton.setTitle("Scan\nExpiration Date", for: .normal)
        expirationDateButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        expirationDateButton.titleLabel?.textAlignment = .center       // Center the text
        expirationDateButton.titleLabel?.numberOfLines = 0
        expirationDateButton.addTarget(self, action: #selector(expirationDateButtonTapped), for: .touchUpInside)
        expirationDateButton.frame = CGRect(x: 20, y: barcodeButton.frame.maxY + spacing, width: buttonWidth, height: buttonHeight)
        expirationDateButton.layer.borderWidth = 2.0
        expirationDateButton.layer.cornerRadius = 8
        expirationDateButton.layer.borderColor = UIColor.label.cgColor
        view.addSubview(expirationDateButton)

        // Setup and add the done button
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.frame = CGRect(x: 20, y: expirationDateButton.frame.maxY + spacing, width: buttonWidth, height: buttonHeight)
        doneButton.layer.borderWidth = 2.0
        doneButton.layer.cornerRadius = 8
        doneButton.layer.borderColor = UIColor.label.cgColor
        view.addSubview(doneButton)
        
        // Configure the barcode result label
        barcodeResultLabel.translatesAutoresizingMaskIntoConstraints = false
        barcodeResultLabel.textAlignment = .center
        barcodeResultLabel.layer.borderWidth = 2.0
        barcodeResultLabel.layer.cornerRadius = 8
        barcodeResultLabel.layer.borderColor = UIColor.label.cgColor
        view.addSubview(barcodeResultLabel)

        // Configure the expiration date result label
        expirationDateResultLabel.translatesAutoresizingMaskIntoConstraints = false
        expirationDateResultLabel.textAlignment = .center
        expirationDateResultLabel.layer.borderWidth = 2.0
        expirationDateResultLabel.layer.cornerRadius = 8
        expirationDateResultLabel.layer.borderColor = UIColor.label.cgColor
        view.addSubview(expirationDateResultLabel)
        
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
                    // Handle the detected barcode text
                } else {
                    print("No barcode detected")
                    // Handle the case where no barcode is detected
                }
            }
        case .expirationDate:
            textDetectionUtility.detectText(in: ciImage) { [weak self] detectedText in
                // Handle text detection result
                if let detectedText = detectedText {
                    print("Detected text: \(detectedText)")
                    // Handle the detected text (expiration date)
                    self?.expirationDateResultLabel.text = detectedText
                } else {
                    print("No text detected")
                    // Handle the case where no text is detected
                    
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
            return
        }

        guard let expirationDateString = expirationDateResultLabel.text, !expirationDateString.isEmpty, let standardizedExpirationDate = standardizedDate(from: expirationDateString) else {
            print("Expiration date is invalid or empty")
            return
        }
        

        productFetcher.fetchProduct(barcode: barcode) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let product):
                    // Handle the success case
                    // Optionally use expirationDate here as needed
                    // ...
                    print("Successfully got the product based on barcode and expiration date")
                    print("Product Name: \(product.product_name)")
                    print("Image URL: \(String(describing: product.image_front_url))")
                    print("Expiration date of the product (standardized): \(standardizedExpirationDate)")

                case .failure(let error):
                    print("Error fetching product: \(error)")
                    // Handle the error case
                    // ...
                }
            }
        }
    }
    
    func standardizedDate(from dateString: String) -> String? {
        let currentYear = Calendar.current.component(.year, from: Date())
        let formatter = DateFormatter()

        for format in dateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                formatter.dateFormat = "dd.MM.yyyy"
                return formatter.string(from: date)
            }
        }

        // Try parsing short formats and add the current year
        if let shortDate = tryParseShortDate(dateString, withYear: currentYear, formatter: formatter) {
            return shortDate
        }

        return nil // Return nil if no format matched
    }

    func tryParseShortDate(_ dateString: String, withYear year: Int, formatter: DateFormatter) -> String? {
        let shortFormats = ["dd.MM.", "ddMMyy", "MM/yyyy"] // Include "MM/yyyy"
        let defaultDay = "01" // Default day to use when day is missing

        for format in shortFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                if format == "MM/yyyy" {
                    // For "MM/yyyy" format, prepend the default day
                    formatter.dateFormat = "dd.MM.yyyy"
                    return defaultDay + "." + formatter.string(from: date)
                } else {
                    // For other short formats, append the current year
                    return formatter.string(from: date) + ".\(year)"
                }
            }
        }

        return nil
    }
}

extension DateFormatter {
    static let yourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // Set the date format according to how your date is being displayed
        formatter.dateFormat = "dd/MM/yyyy" // Modify this as per your date format
        return formatter
    }()
}
