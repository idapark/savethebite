//
//  ItemManager.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 15.11.2023.
//

import UIKit
import CoreData

class ItemManager {
    let managedContext: NSManagedObjectContext
    
    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }

    func fetchItems() -> [Date: [StoredItem]] {
        let fetchRequest: NSFetchRequest<StoredItem> = StoredItem.fetchRequest()
        let calendar = Calendar.current
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            var items: [Date: [StoredItem]] = [:]
            
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
            
            return items
            
        } catch let error as NSError {
            print("Could not fetch items: \(error), \(error.userInfo)")
            return [:]
        }
    }

    func addItem(title: String, image: UIImage?, date: Date) {
        let newItem = StoredItem(context: managedContext)
        newItem.title = title
        newItem.date = date
        
        if let image = image, let imageData = image.pngData() {
            newItem.image = imageData
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save new item: \(error), \(error.userInfo)")
        }
    }
    
    func deleteItem(_ item: StoredItem) {
            managedContext.delete(item)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not delete item: \(error), \(error.userInfo)")
            }
        }

        // If you need to delete by identifier
    func deleteItem(withId identifier: String) {
        let fetchRequest: NSFetchRequest<StoredItem> = StoredItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", identifier)
            
        do {
            let items = try managedContext.fetch(fetchRequest)
            if let itemToDelete = items.first {
                managedContext.delete(itemToDelete)
                try managedContext.save()
            }
        } catch let error as NSError {
            print("Error while deleting item: \(error), \(error.userInfo)")
        }
    }
}



/*
import UIKit
import CoreData

struct Item {
    var title: String
    var image: UIImage?
    var date: Date
}


class ItemManager {
    var items: [Date: [Item]] = [:]

    func populateItems() {
        let item1 = Item(title: "Test1", image: UIImage(systemName: "waterbottle"), date: Date())
        let item2 = Item(title: "Test2", image: UIImage(systemName: "carrot"), date: Date(timeIntervalSinceReferenceDate: -123456789.0))

        addItem(item1)
        addItem(item2)
    }

    func addItem(_ item: Item) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: item.date)
        guard let dateKey = calendar.date(from: components) else { return }

        if items[dateKey] == nil {
            items[dateKey] = []
        }
        items[dateKey]?.append(item)
        print("Item added: \(item.title), Date: \(dateKey)")
    }

    // Add other data management methods as needed
}
*/
