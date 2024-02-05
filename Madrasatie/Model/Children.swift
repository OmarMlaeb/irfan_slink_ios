//
//  Children.swift
//  Madrasati
//
//  Created by hisham noureddine on 8/1/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

struct Children{
    var gender: String
    var cycle: String
    var photo: String
    var firstName: String
    var lastName: String
    var batchId: Int
    var imperiumCode: String
    var className: String
    var admissionNo: String
    var bdDate: Date
    var isBdChecked: Bool

    public init(gender: String, cycle: String, photo: String, firstName: String, lastName: String, batchId: Int, imperiumCode: String, className: String, admissionNo: String, bdDate: Date, isBdChecked: Bool) {
        self.gender = gender
        self.cycle = cycle
        self.photo = photo
        self.firstName = firstName
        self.lastName = lastName
        self.batchId = batchId
        self.imperiumCode = imperiumCode
        self.className = className
        self.admissionNo = admissionNo
        self.bdDate = bdDate
        self.isBdChecked = isBdChecked
    }
}
