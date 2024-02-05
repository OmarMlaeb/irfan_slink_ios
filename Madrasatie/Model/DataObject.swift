//
//  DataObject.swift
//  Madrasatie
//
//  Created by hisham noureddine on 10/25/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import Foundation

class DataObject{
    var id: String
    var title: String
    var code: String
    var mark: Float
    var fullMark: Float
    var color: String
    var children: [DataObject]
    var isOpen: Bool
    var icon: String
    var subjectTile: String
    var checked: Bool
    var editable: Bool
    
    init(id: String, name: String, code: String, mark: Float, fullMark: Float, subTerms: [DataObject], color: String, isOpen: Bool, subjectIcon: String, subjectTitle: String, checked: Bool, editable: Bool) {
        self.id = id
        self.title = name
        self.code = code
        self.mark = mark
        self.fullMark = fullMark
        self.children = subTerms
        self.color = color
        self.isOpen = isOpen
        self.icon = subjectIcon
        self.subjectTile = subjectTitle
        self.checked = checked
        self.editable = editable
    }
    
    convenience init(id: String, name: String, code: String, mark: Float, fullMark: Float, child: [DataObject], color: String, isOpen: Bool, subjectIcon: String, subjectTitle: String, checked: Bool, editable: Bool) {
        self.init(id: id, name: name, code: code, mark: mark, fullMark: fullMark, subTerms: child, color: color, isOpen: isOpen, subjectIcon: subjectIcon, subjectTitle: subjectTitle, checked: checked, editable: editable)
    }
    
    func addChild(_ child: DataObject) {
        self.children.append(child)
    }
    
    func removeChild(_ child: DataObject) {
        self.children = self.children.filter( {$0 !== child})
    }
}
