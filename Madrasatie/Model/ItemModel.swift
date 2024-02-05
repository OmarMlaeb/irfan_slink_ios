//
//  ItemModel.swift
//  IRFAN Schools
//
//  Created by Maher Jaber on 12/23/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation

struct ItemsModel{
    var color: String
    var name: String
    var image: String
    var selected: Bool
    
    public init(color: String, name: String, image: String, selected: Bool){
        self.color = color
        self.name = name
        self.image = image
        self.selected = selected
    }
}

