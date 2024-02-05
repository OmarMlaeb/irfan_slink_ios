//
//  Event.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/3/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

struct Event: Hashable {
    var id: Int
    var icon: String
    var color: String
    var counter: Int
    var type: Int?
    var date: String
    var percentage: Double
    var detail: [EventDetail]
    var agendaDetail: [AgendaDetail]
    
//    var hashValue: Int {
//        return self.id
//    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    
}

