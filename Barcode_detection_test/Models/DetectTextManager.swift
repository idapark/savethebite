//
//  CameraManager.swift
//  SaveTheBite
//
//  Created by Ida Parkkali on 15.11.2023.
//
// detect the expiration date

import Vision
import UIKit

// DetectTextManager class, a subclass of UIViewController,
// also conforms to UIImagePickerControllerDelegate and UINavigationControllerDelegate
class DetectTextManager: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    // expiration date formats:
    // DD MM YYYY, D MM YYYY, DD M YYYY, D M YYYY, DD MM YY, MM YYYY
    let dates1 = ["\\d{2} \\d{2} \\d{4}", "\\d{1} \\d{2} \\d{4}", "\\d{2} \\d{1} \\d{4}", "\\d{1} \\d{1} \\d{4}", "\\d{2} \\d{2} \\d{2}", "\\d{2} \\d{4}"]
    // DD.MM.YYYY, D.MM.YYYY, DD.M.YYYY, D.M.YYYY, DD.MM.YY, MM.YYYY
    let dates2 = ["\\d{2}.\\d{2}.\\d{4}", "\\d{1}.\\d{2}.\\d{4}", "\\d{2}.\\d{1}.\\d{4}", "\\d{1}.\\d{1}.\\d{4}", "\\d{2}.\\d{2}.\\d{2}", "\\d{2}.\\d{4}"]
    // DD-MM-YYYY, D-MM-YYYY, DD-M-YYYY, D-M-YYYY, DD-MM-YY, MM-YYYY
    let dates3 = ["\\d{2}-\\d{2}-\\d{4}", "\\d{1}-\\d{2}-\\d{4}", "\\d{2}-\\d{1}-\\d{4}", "\\d{1}-\\d{1}-\\d{4}", "\\d{2}-\\d{2}-\\d{2}", "\\d{2}-\\d{4}"]
    // DD/MM/YYYY, D/MM/YYYY, DD/M/YYYY, D/M/YYYY, DD/MM/YY, MM/YYYY
    let dates4 = ["\\d{2}/\\d{2}/\\d{4}", "\\d{1}/\\d{2}/\\d{4}", "\\d{2}/\\d{1}/\\d{4}", "\\d{1}/\\d{1}/\\d{4}", "\\d{2}/\\d{2}/\\d{2}", "\\d{2}/\\d{4}"]
    // DD\MM\YYYY, D\MM\YYYY, DD\M\YYYY, D\M\YYYY, DD\MM\YY, MM\YYYY
    let dates5 = ["\\d{2}\\\\d{2}\\\\d{4}", "\\d{1}\\\\d{2}\\\\d{4}", "\\d{2}\\\\d{1}\\\\d{4}", "\\d{1}\\\\d{1}\\\\d{4}", "\\d{2}\\\\d{2}\\\\d{2}", "\\d{2}\\\\d{4}"]
    // DD.MM., DDMMYY
    let dates6 = ["\\d{2}.\\d{2}.", "\\d{6}"]
    var formatsDate = [] as [String]
    
    // Function to detect expiration date within an image
    func detectText(in image: CIImage, completion: @escaping (String?) -> Void) {
        // Append all date format patterns to the formatsDate array
        formatsDate.append(contentsOf: dates1)
        formatsDate.append(contentsOf: dates2)
        formatsDate.append(contentsOf: dates3)
        formatsDate.append(contentsOf: dates4)
        formatsDate.append(contentsOf: dates5)
        formatsDate.append(contentsOf: dates6)
        
        // Creating a text recognition request
            let request = VNRecognizeTextRequest { [weak self] request, error in
                // Handling errors in text detection
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                    print("Error in text detection: \(error?.localizedDescription ?? "unknown error")")
                    completion(nil)
                    return
                }
                // Extracting the detected text from the observations
                let detectedText = observations.compactMap { $0.topCandidates(1).first?.string }
                // Filtering the detected text to find matches with the specified date formats
                let formattedText = self?.filterText(detectedText, withFormats: self?.formatsDate ?? [])

                // Returning the formatted text in the completion handler
                DispatchQueue.main.async {
                    completion(formattedText)
                }
            }

            // Creating an image request handler and performing the text recognition request
            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform text detection: \(error)")
                completion(nil)
            }
        }

    // Private function to filter detected text based on provided date formats
        private func filterText(_ texts: [String], withFormats formats: [String]) -> String? {
            // Joining all detected text into a single string
            let joinedText = texts.joined(separator: " ")
            
            // Iterating over each date format pattern
            for format in formats {
                let regex = try? NSRegularExpression(pattern: format, options: [])
                // Finding matches in the joined text
                let results = regex?.matches(in: joinedText, options: [], range: NSRange(joinedText.startIndex..., in: joinedText))

                // If matches are found, return them as a joined string
                if let formattedStrings = results?.compactMap({ Range($0.range, in: joinedText).map { String(joinedText[$0]) } }),
                   !formattedStrings.isEmpty {
                    return formattedStrings.joined(separator: "\n")
                }
            }
            // Return nil if no matches are found
            return nil
        }
    }


