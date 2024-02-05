//
//  Student.swift
//  Madrasatie
//
//  Created by hisham noureddine on 9/5/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

class Student{
    var index: String
    var id: String
    var fullName: String
    var photo: String
    var mark: Float
    var selected: Bool
    var gender: String
    var parent: Bool

    public init(index: String, id: String, fullName: String, photo: String, mark: Float, selected: Bool, gender: String, parent: Bool) {
        self.index = index
        self.id = id
        self.fullName = fullName
        self.photo = photo
        self.mark = mark
        self.selected = selected
        self.gender = gender
        self.parent = parent
    }
    
    var hashValue: String {
        return self.index
    }
    
    static func ==(lhs: Student, rhs: Student) -> Bool {
        return lhs.index == rhs.index
    }
}
