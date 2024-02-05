//
//  MenuItem.swift
//  Madrasatie
//
//  Created by hisham noureddine on 5/14/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import Foundation

class MenuItem{
    var id: Int
    var name: String
    var value: Int
    var isSelected: Bool

    public init(id: Int, name: String, value: Int, isSelected: Bool) {
        self.id = id
        self.name = name
        self.value = value
        self.isSelected = isSelected
    }
}
