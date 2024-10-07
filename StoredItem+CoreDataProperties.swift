//
//  StoredItem+CoreDataProperties.swift
//  SaveTheBite
//
//  Created by Ida Parkkali on 2.12.2023.
//
//
// Extension for the StoredItem entity in CoreData

import Foundation
import CoreData


extension StoredItem {

    // Class function to create a fetch request for StoredItem entities
    // This method is used to retrieve StoredItem objects from CoreData
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredItem> {
        return NSFetchRequest<StoredItem>(entityName: "StoredItem")
    }

    @NSManaged public var title: String?
    @NSManaged public var image: Data?
    @NSManaged public var date: Date?

}

extension StoredItem : Identifiable {

}
