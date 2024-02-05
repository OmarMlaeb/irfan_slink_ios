//
//  ParentFeesCategories.swift
//  Madrasatie
//
//  Created by Maher Jaber on 3/31/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation

struct ParentFeesCategories{
    
    var title: String
    var date: String
    var condition: String
    var remainingAmount: String
    var totalAmount: String
    var totalDiscount: String

    public init(title: String, date: String, condition: String, remainingAmount: String, totalAmount: String, totalDiscount: String) {
       
        self.title = title
        self.date = date
        self.condition = condition
        self.remainingAmount = remainingAmount
        self.totalAmount = totalAmount
        self.totalDiscount = totalDiscount
      }
}
