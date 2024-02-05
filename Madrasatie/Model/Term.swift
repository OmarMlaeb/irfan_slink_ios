//
//  Term.swift
//  Madrasatie
//
//  Created by hisham noureddine on 10/23/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import Foundation

struct Term {
    var id: String
    var name: String
    var avg: Float
    var classAvg: Float
    var remarkTile: String
    var remarkBody: String
    var teacherName: String
    var subject: String
    var color: String
    var selected: Bool
    var subjectsArray: [SubjectHeaderItem]
}
