//
//  AgendaExam.swift
//  Madrasatie
//
//  Created by hisham noureddine on 8/17/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

struct AgendaExam{
    var id: Int
    var title: String
    var type: String
    var students: [String]
    var subjectId: Int
    var startDate: String
    var startTime: String
    var endDate: String
    var endTime: String
    var description: String
    var assignmentId: Int
    var assessmentTypeId: Int
    var groupId: Int
    var mark: Double
    var enableSubmissions: Bool
    var enableLateSubmissions: Bool
    var enableDiscussions: Bool
    var enableGrading: Bool
    var estimatedTime: Int
}
