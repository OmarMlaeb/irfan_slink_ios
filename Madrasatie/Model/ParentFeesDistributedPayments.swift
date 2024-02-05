//
//  ParentFeesDistributedPayments.swift
//  Madrasatie
//
//  Created by Maher Jaber on 3/31/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation

struct ParentFeesDistributedPayments{
    
    var count: Int
    var amountValue: String
    var paidAmountValue: String
    var remainingAmountValue: String
    var dueDate: String

    public init(count: Int, amountValue: String, paidAmountValue: String, remainingAmountValue: String, dueDate: String) {
       
        self.count = count
        self.amountValue = amountValue
        self.paidAmountValue = paidAmountValue
        self.remainingAmountValue = remainingAmountValue
        self.dueDate = dueDate
      }
}
