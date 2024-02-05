//
//  SubjectIHeaderItem.swift
//  Madrasatie
//
//  Created by hisham noureddine on 10/17/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import Foundation

struct SubjectHeaderItem{
    var id: String
    var subjectColor: String
    var subjectIcon: String
    var subjectTitle: String
    var subjectMark: Float
    var subjectCode: String
    var fullMark: Float
    var isOpen: Bool
    var checked: Bool
    var editable: Bool
    var items: [SubSubjectItem]
}
