//
//  Period.swift
//  Madrasatie
//
//  Created by hisham noureddine on 10/3/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import Foundation

struct Period{
    var dayId: Int
    var date: String
    var subjectId: String
    var periodId: Int
    var subjectName: String
    var subjectIcon: String
    var subjectCode: String
    var time: String
    var classCode: String
    var selected: Bool
    var endTime: String
    var dayName: String

    public init(dayId: Int, date: String, subjectId: String, periodId: Int, subjectName: String, subjectIcon: String, subjectCode: String, time: String, classCode: String, selected: Bool, endTime: String, dayName: String) {
        self.dayId = dayId
        self.date = date
        self.subjectId = subjectId
        self.periodId = periodId
        self.subjectName = subjectName
        self.subjectIcon = subjectIcon
        self.subjectCode = subjectCode
        self.time = time
        self.classCode = classCode
        self.selected = selected
        self.endTime = endTime
        self.dayName = dayName
    }
}
