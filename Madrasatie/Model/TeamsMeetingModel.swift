//
//  TeamsMeetingModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 6/9/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation
struct TeamsMeetingModel{
    var id: String
    var meetingTitle: String
    var teacherName: String
    var date: String
    var teacherPic: String
  
    
    public init(id: String, meetingTitle: String, teacherName: String,
                date: String, teacherPic: String){
        self.id = id
        self.meetingTitle = meetingTitle
        self.teacherName = teacherName
        self.date = date
        self.teacherPic = teacherPic
    }
}
