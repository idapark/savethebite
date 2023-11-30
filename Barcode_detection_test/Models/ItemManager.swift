//
//  ItemManager.swift
//  Barcode_detection_test
//
//  Created by Ida Parkkali on 15.11.2023.
//

import UIKit

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
