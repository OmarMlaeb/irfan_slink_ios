//
//  Holiday.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/2/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

struct EventDetail: Hashable{
    var id: Int
    var title: String
    var type: Int
    var date: String
    var enddate: String
    var image: String
    var batches: String
    var departments: String
    var description: String
    var backgroudColor: String
    var topColor: String
    var allow_update: Bool
    
//    var hashValue: Int {
//        return self.id
//    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: EventDetail, rhs: EventDetail) -> Bool {
        return lhs.id == rhs.id
    }
}
