//
//  ProductFetcher.swift
//  SaveTheBite
//
//  Created by Ida Parkkali on 16.11.2023.
//
// used to fetch data in a JSON format using a URL from OpenFoodFacts.org

import Foundation

// Struct for decoding product data from a JSON response
// Uses to Codable for easy decoding
struct ProductData: Codable {
    let product: Product
}

// Struct representing the product information
struct Product: Codable {
    let product_name: String // Name of the product
    let image_front_url: String? // Optional URL for the product's front image
}

// ProductFetcher class responsible for fetching product information
class ProductFetcher {
    
    // Function to fetch product details using a barcode
    func fetchProduct(barcode: String, completion: @escaping (Result<Product, Error>) -> Void) {
        
        // Constructing the URL string for the API request from openfoodfacts.org
        // Replace with the appropriate URL for your API
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode)"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        // Creating a data task to fetch data from the URL
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handling errors in the data task
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensuring data is received
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            // Attempting to decode the JSON data into ProductData
            do {
                let decodedData = try JSONDecoder().decode(ProductData.self, from: data)
                let product = decodedData.product
                // On success, return the product information via the completion handler
                completion(.success(product))
            } catch {
                // Handling errors in JSON decoding
                completion(.failure(error))
            }
        }.resume() // Starting the data task
    }
}
