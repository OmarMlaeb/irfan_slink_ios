//
//  AgendaDetail.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/17/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

struct AgendaDetail: Hashable{
    var id: Int
    var date: String
    var teacher: String
    var allow_update: Bool
    var students: String
    var type: Int
    var title: String
    var subject_name: String
    var full_mark: String
    var sub_term: String
    var assessment_type: String
    var description: String
    var backgroudColor: String
    var topColor: String
    var ticked: Bool
    var expand: Bool
    var percentage: Double
    var attachment_link: String
    var startDate: String
    var endDate: String
    var duration: String
    var link_to_join: String
    var enableSubmissions: Bool
    var enableLateSubmissions: Bool
    var enableDiscussions: Bool
    var enableGrading: Bool
    var estimatedTime: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: AgendaDetail, rhs: AgendaDetail) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum agendaType: Int {
        case Homework = 1
        case Classwork = 2
        case Assessment = 3
        case Exam = 4
        case Events = 5
        case Holidays = 6
        case Dues = 7
        case AllUpcoming = 8
        
        var description: String {
            switch self{
            case .Homework:
                return "Homework"
            case .Classwork:
                return "Classwork"
            case .Assessment:
                return "Assessment"
            case .Exam:
                return "Exam"
            case .Events:
                return "Events"
            case .Holidays:
                return "Holiday"
            case .Dues:
                return "Dues"
            case .AllUpcoming:
                return "All Upcoming"
            }
        }
    }
}
