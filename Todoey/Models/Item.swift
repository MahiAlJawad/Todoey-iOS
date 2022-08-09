//
//  Item.swift
//  Todoey
//
//  Created by Mahi Al Jawad on 9/8/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation


struct Item {
    let description: String
    var isChecked: Bool = false
    
    init(_ description: String) {
        self.description = description
    }
}
