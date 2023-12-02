//
//  StoredItem+CoreDataProperties.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 2.12.2023.
//
//

import Foundation
import CoreData


extension StoredItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredItem> {
        return NSFetchRequest<StoredItem>(entityName: "StoredItem")
    }

    @NSManaged public var title: String?
    @NSManaged public var image: Data?
    @NSManaged public var date: Date?

}

extension StoredItem : Identifiable {

}
