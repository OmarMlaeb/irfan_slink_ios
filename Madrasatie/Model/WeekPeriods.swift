//
//  WeekPeriods.swift
//  Madrasatie
//
//  Created by hisham noureddine on 3/5/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import Foundation

struct WeekPeriods{
    var dayId: Int
    var periodArray: [Period]

    public init(dayId: Int, periodArray: [Period]) {
        self.dayId = dayId
        self.periodArray = periodArray
    }
}
