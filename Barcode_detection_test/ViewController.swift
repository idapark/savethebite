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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    
    func detectBarcode(in image: CIImage) {
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            if let error = error {
                print("Error in detecting - \(error)")
                return
            }

            guard let observations = request.results as? [VNBarcodeObservation] else {
                print("No barcode detected.")
                return
            }

            for observation in observations {
                if let barcodeValue = observation.payloadStringValue {
                    // Do something with the barcode value
                    print("Barcode value: \(barcodeValue)")

                    DispatchQueue.main.async {
                        self?.navigationItem.title = barcodeValue
                        // You can perform other UI updates here
                    }
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform barcode detection: \(error)")
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            guard let ciImage = CIImage(image: image) else {
                fatalError("Couldn't convert UIImage to CIImage.")
            }
            detectBarcode(in: ciImage)
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
}


