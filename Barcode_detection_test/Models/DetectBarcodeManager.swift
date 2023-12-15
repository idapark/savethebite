//
//  DetectBarcodeManager.swift
//  SaveTheBite
//
//  Created by Ida Parkkali on 16.11.2023.
//
// DetectBarcodeManager class for barcode detection within an image


import Vision
import UIKit


class DetectBarcodeManager {

    // Function to detect a barcode in a given CIImage
    // Uses Vision framework to perform the detection
    func detectBarcode(in image: CIImage, completion: @escaping (String?) -> Void) {
        // Creating a barcode detection request
        let request = VNDetectBarcodesRequest { request, error in
            // Handling errors in barcode detection
            if let error = error {
                print("Error in detecting - \(error)")
                completion(nil)
                return
            }

            // Extracting barcode observations from the request results
            guard let observations = request.results as? [VNBarcodeObservation], !observations.isEmpty else {
                print("No barcode detected.")
                completion(nil)
                return
            }

            // Assuming that the first detected barcode value is what you want (highest propability of being correct)
            if let barcodeValue = observations.first?.payloadStringValue {
                DispatchQueue.main.async {
                    completion(barcodeValue) // Returning the detected barcode value
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil) // Return nil if no payload string value is found
                }
            }
        }

        // Creating an image request handler with the given image
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            // Performing the barcode detection request
            try handler.perform([request])
        } catch {
            print("Failed to perform barcode detection: \(error)")
            completion(nil) // Return nil if the request fails to perform
        }
    }
}
