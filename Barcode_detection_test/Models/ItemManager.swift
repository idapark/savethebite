//
//  ItemManager.swift
//  SaveTheBite
//
//  Created by Ida Parkkali on 15.11.2023.
//
// Class responsible for managing StoredItem entities in CoreData

import UIKit
import CoreData


class ItemManager {
    // Managed object context for interacting with CoreData
    let managedContext: NSManagedObjectContext
    
    // Initializer accepting a managed object context
    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }

    // Function to fetch StoredItems from CoreData, sorted by date
    func fetchItems() -> [Date: [StoredItem]] {
        // Creating a fetch request for StoredItem entities
        let fetchRequest: NSFetchRequest<StoredItem> = StoredItem.fetchRequest()
        let calendar = Calendar.current
        
        do {
            // Executing the fetch request
            let results = try managedContext.fetch(fetchRequest)
            var items: [Date: [StoredItem]] = [:]
            
            // Organizing fetched items into a dictionary by date
            for result in results {
                if let date = result.date {
                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                    if let dateKey = calendar.date(from: components) {
                        if items[dateKey] == nil {
                            items[dateKey] = []
                        }
                        items[dateKey]?.append(result)
                    }
                }
            }
            for result in results {
                // Logging the fetched items
                print("Fetched item: \(result.title ?? "?")")
            }
            
            return items // Returning the organized items
            
        } catch let error as NSError {
            // Logging and handling errors
            print("Could not fetch items: \(error), \(error.userInfo)")
            return [:]
        }
    }

    // Function to add a new StoredItem to CoreData
    func addItem(title: String, image: UIImage?, date: Date) {
        let newItem = StoredItem(context: managedContext) // Creating a new StoredItem
        newItem.title = title // Setting the title
        newItem.date = date // Setting the date
        
        // If an image is provided, convert it to Data and store it
        if let image = image, let imageData = image.pngData() {
            newItem.image = imageData
        }

        // Attempting to save the context to persist the new item
        do {
            try managedContext.save()
        } catch let error as NSError {
            // Handling save errors
            print("Could not save new item: \(error), \(error.userInfo)")
        }
    }
    
    // Function to delete a StoredItem from CoreData
    func deleteItem(_ item: StoredItem) {
            managedContext.delete(item)  // Deleting the item from the context
            do {
                try managedContext.save() // Saving the context to reflect the deletion
            } catch let error as NSError {
                // Handling deletion errors
                print("Could not delete item: \(error), \(error.userInfo)")
            }
        }

    // Function to delete a StoredItem by its identifier
    func deleteItem(withId identifier: String) {
        let fetchRequest: NSFetchRequest<StoredItem> = StoredItem.fetchRequest()
        // Setting a predicate to find the item by its identifier
        fetchRequest.predicate = NSPredicate(format: "id == %@", identifier)
            
        do {
            let items = try managedContext.fetch(fetchRequest) // Fetching items matching the identifier
            if let itemToDelete = items.first {
                managedContext.delete(itemToDelete) // Deleting the fetched item
                try managedContext.save() // Saving the context
            }
        } catch let error as NSError {
            // Handling errors during fetch and deletion
            print("Error while deleting item: \(error), \(error.userInfo)")
        }
    }
}

