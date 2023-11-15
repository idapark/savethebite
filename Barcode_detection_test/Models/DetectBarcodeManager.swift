//
//  DetectBarcodeManager.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 16.11.2023.
//



import Vision
import UIKit

class DetectBarcodeManager {

    func detectBarcode(in image: CIImage, completion: @escaping (String?) -> Void) {
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                print("Error in detecting - \(error)")
                completion(nil)
                return
            }

            guard let observations = request.results as? [VNBarcodeObservation], !observations.isEmpty else {
                print("No barcode detected.")
                completion(nil)
                return
            }

            // Assuming you want to return the first detected barcode value
            if let barcodeValue = observations.first?.payloadStringValue {
                DispatchQueue.main.async {
                    completion(barcodeValue)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform barcode detection: \(error)")
            completion(nil)
        }
    }
}
