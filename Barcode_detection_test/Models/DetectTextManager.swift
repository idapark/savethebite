//
//  CameraManager.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 15.11.2023.
//

import Vision
import UIKit

class DetectTextManager: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
        
        @IBOutlet weak var imageView: UIImageView!
        let imagePicker = UIImagePickerController()
        
        // expiration date formats:
        // DD MM YYYY, D MM YYYY, DD M YYYY, D M YYYY, DD MM YY
        // DD.MM.YYYY, D.MM.YYYY, DD.M.YYYY, D.M.YYYY, DD.MM.YY
        let formatsDate = ["\\d{2} \\d{2} \\d{4}", "\\d{1} \\d{2} \\d{4}", "\\d{2} \\d{1} \\d{4}", "\\d{1} \\d{1} \\d{4}", "\\d{2} \\d{2} \\d{2}", "\\d{2}.\\d{2}.\\d{4}", "\\d{1}.\\d{2}.\\d{4}", "\\d{2}.\\d{1}.\\d{4}", "\\d{1}.\\d{1}.\\d{4}", "\\d{2}.\\d{2}.\\d{2}", "\\d{6}"]
        
        override func viewDidLoad() {
            super.viewDidLoad()
            imagePicker.delegate = self
            
        }
        
        func detectText(in image: CIImage, withFormats formats: [String]) {
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                    print("Error in text detection: \(error?.localizedDescription ?? "unknown error")")
                    return
                }

                let detectedText = observations.compactMap { $0.topCandidates(1).first?.string }
                let formattedText = self?.filterText(detectedText, withFormats: formats)

                DispatchQueue.main.async {
                    self?.navigationItem.title = formattedText
                }
            }

            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform text detection: \(error)")
            }
        }

        func filterText(_ texts: [String], withFormats formats: [String]) -> String? {
            let joinedText = texts.joined(separator: " ")

            for format in formats {
                let regex = try? NSRegularExpression(pattern: format, options: [])
                let results = regex?.matches(in: joinedText, options: [], range: NSRange(joinedText.startIndex..., in: joinedText))

                if let formattedStrings = results?.compactMap({ Range($0.range, in: joinedText).map { String(joinedText[$0]) } }),
                   !formattedStrings.isEmpty {
                    return formattedStrings.joined(separator: "\n")
                }
            }

            return nil
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                imageView.image = image
                imagePicker.dismiss(animated: true, completion: nil)
                guard let ciImage = CIImage(image: image) else {
                    fatalError("Couldn't convert UIImage to CIImage.")
                }
                detectText(in: ciImage, withFormats: formatsDate)
            }
        }
        
        @IBAction func cameraTapped(_ sender: Any) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }

