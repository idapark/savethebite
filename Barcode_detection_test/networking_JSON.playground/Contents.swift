import Foundation

// Define the model to match the JSON structure
struct ProductData: Codable {
    let product: Product
}

struct Product: Codable {
    let product_name: String
    let image_front_url: String
}

if let url = URL(string: "https://world.openfoodfacts.net/api/v2/product/3017624010701") {
    URLSession.shared.dataTask(with: url) { data, response, error in
        // Check for errors and unwrap data
        if let error = error {
            print("Error fetching data: \(error)")
            return
        }
        
        guard let data = data else {
            print("No data returned")
            return
        }

        do {
            // Parse the JSON data directly from `data`
            let decodedData = try JSONDecoder().decode(ProductData.self, from: data)
            
            // Access the product name and image URL
            let productName = decodedData.product.product_name
            let imageUrl = decodedData.product.image_front_url
            
            print("Product Name: \(productName)")
            print("Image URL: \(imageUrl)")
            
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }.resume() // Don't forget to resume the task
}

