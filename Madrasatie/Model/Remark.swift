//
//  Remark.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/20/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

struct Remark: Hashable{
    var id: Int
    var icon: String
    var color: String
    var counter: String
    var Title: String
    var remarkDetail: [RemarkDetail]
    
//    var hashValue: Int {
//        return self.id
//    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Remark, rhs: Remark) -> Bool {
        return lhs.id == rhs.id
    }
}
