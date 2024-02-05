//
//  Day.swift
//  Madrasatie
//
//  Created by hisham noureddine on 11/13/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import Foundation

struct Day: Hashable{
    var id: Int
    var name: String
    var selected: Bool
    
    var hashValue: Int {
        return self.id
    }
    
    static func ==(lhs: Day, rhs: Day) -> Bool {
        return lhs.id == rhs.id
    }
}
