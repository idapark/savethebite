//
//  ProductFetcher.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 16.11.2023.
//

import Foundation

// Define your models to match the JSON structure
struct ProductData: Codable {
    let product: Product
}

struct Product: Codable {
    let product_name: String
    let image_front_url: String?
}

class ProductFetcher {
    
    func fetchProduct(barcode: String, completion: @escaping (Result<Product, Error>) -> Void) {
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(barcode)"
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(ProductData.self, from: data)
                let product = decodedData.product
                completion(.success(product))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
