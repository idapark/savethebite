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
    
    var currentScanMode: ScanMode = .none
    
    let barcodeButton = UIButton()
    let expirationDateButton = UIButton()
    let doneButton = UIButton()
    
    let barcodeDetectionUtility = DetectBarcodeManager()
    let textDetectionUtility = DetectTextManager()
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        barcodeButton.translatesAutoresizingMaskIntoConstraints = false
        expirationDateButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = view.bounds.width - 40  // Example width
        let spacing: CGFloat = 20

        // Setup and add the barcode button
        barcodeButton.setTitle("Scan Barcode", for: .normal)
        barcodeButton.addTarget(self, action: #selector(barcodeButtonTapped), for: .touchUpInside)
        barcodeButton.frame = CGRect(x: 20, y: spacing, width: buttonWidth, height: buttonHeight)
        view.addSubview(barcodeButton)

        // Setup and add the expiration date button
        expirationDateButton.setTitle("Scan Expiration Date", for: .normal)
        expirationDateButton.addTarget(self, action: #selector(expirationDateButtonTapped), for: .touchUpInside)
        expirationDateButton.frame = CGRect(x: 20, y: barcodeButton.frame.maxY + spacing, width: buttonWidth, height: buttonHeight)
        view.addSubview(expirationDateButton)

        // Setup and add the done button
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.frame = CGRect(x: 20, y: expirationDateButton.frame.maxY + spacing, width: buttonWidth, height: buttonHeight)
        view.addSubview(doneButton)

        // Layout the buttons
        // You should use Auto Layout or manually set the frame of the buttons
        NSLayoutConstraint.activate([
            // Barcode button constraints
            barcodeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            barcodeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            barcodeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Expiration date button constraints
            expirationDateButton.topAnchor.constraint(equalTo: barcodeButton.bottomAnchor, constant: 20),
            expirationDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            expirationDateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Done button constraints
            doneButton.topAnchor.constraint(equalTo: expirationDateButton.bottomAnchor, constant: 20),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
    
    /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage, let ciImage = CIImage(image: image) {
            barcodeDetectionUtility.detectBarcode(in: ciImage) { [weak self] detectedText in
                guard let self = self else { return }
                if let detectedText = detectedText {
                    print("Detected barcode: \(detectedText)")
                    // Handle the detected barcode text
                } else {
                    print("No barcode detected")
                    // Handle the case where no barcode is detected
                }
            }
        }
    }
     */

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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage, let ciImage = CIImage(image: image) {
            textDetectionUtility.detectText(in: ciImage) { [weak self] detectedText in
                guard let self = self else { return }
                
            }
        }
    }
     */

    @objc func doneButtonTapped() {
        // Handle done button tap
        dismiss(animated: true, completion: nil)
    }
}
