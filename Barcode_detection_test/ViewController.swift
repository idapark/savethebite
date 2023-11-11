//
//  ViewController.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 8.11.2023.
//



import Vision
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    let formatDate = "\\d{2} \\d{2} \\d{4}"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    func detectText(in image: CIImage, withFormat format: String) {
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("Error in text detection: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            let detectedText = observations.compactMap { $0.topCandidates(1).first?.string }
            let formattedText = self?.filterText(detectedText, withFormat: format)

            DispatchQueue.main.async {
                // Update UI with formatted text
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

    func filterText(_ texts: [String], withFormat format: String) -> String? {
        let joinedText = texts.joined(separator: " ")
        let regex = try? NSRegularExpression(pattern: format, options: [])
        let results = regex?.matches(in: joinedText, options: [], range: NSRange(joinedText.startIndex..., in: joinedText))
        let formattedStrings = results?.compactMap {
            Range($0.range, in: joinedText).map { String(joinedText[$0]) }
        }

        return formattedStrings?.joined(separator: "\n")
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            guard let ciImage = CIImage(image: image) else {
                fatalError("Couldn't convert UIImage to CIImage.")
            }
            detectText(in: ciImage, withFormat: formatDate)
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
}



