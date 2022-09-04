//
//  Item+CoreDataClass.swift
//
//
//  Created by Mahi Al Jawad on 4/9/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

public class Item: NSManagedObject {
    func setItem(
        title: String,
        isChecked: Bool = false,
        category: Category?
    ) {
        self.title = title
        self.isChecked = isChecked
        parentCategory = category
    }
}
