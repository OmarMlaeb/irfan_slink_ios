//
//  OnlineExamGroupModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 7/23/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation

struct OnlineExamGroupModel{
    var id: String
    var name: String
    var startDate: String
    var endDate: String
    var passPercentage: String
    var maximumTime: String
    var batchId: String
    var examType: String
    var examFormat: String
    var optionCount: String
    var linkToJoin: String
    
    public init(id: String, name: String ,startDate: String, endDate: String, passPercentage: String, maximumTime: String, batchId: String, examType: String, examFormat: String, optionCount: String, linkToJoin: String){
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.passPercentage = passPercentage
        self.maximumTime = maximumTime
        self.batchId = batchId
        self.examType = examType
        self.examFormat = examFormat
        self.optionCount = optionCount
        self.linkToJoin = linkToJoin
    }
}
