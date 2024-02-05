//
//  SectionDetailsModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 6/29/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation
struct SectionDetailsModel{
    var id: String
    var title: String
    var downloadImage: String
    var body: String
    var color: String
    var attachmentLink: String
    var attachmentContentType: String
    var attachmentContentSize: String
    var attachmentFilename: String
    var type: String
    var startDate: String
    var endDate: String
    var duration: String
    var link_type: String
    var link_to_join: String
    var assignmentType: String
    var assignmentStudentList: String
    var assignmentDate: String
    var subjectId: String
    var madrasatieSubTermId: String
    var madrasatieSubSubjectId: String
    var fullMark: String
    var creator: String
    var messageThreadId: String
    var assignmentId: String
    var recipientNumber: String
    var discussionStudent: String
 
    public init(id: String, title: String, downloadImage: String, body: String, color: String, attachmentLink:String, attachmentContentType:String, attachmentContentSize:String, attachmentFilename:String, type: String, startDate: String, endDate: String, duration: String, link_type: String, link_to_join: String, assignmentType: String, assignmentStudentList: String, assignmentDate: String, subjectId: String, madrasatieSubTermId: String, madrasatieSubSubjectId: String, fullMark: String, creator: String, messageThreadId: String, assignmentId: String, recipientNumber: String, discussionStudent: String){
        
        self.id = id
        self.title = title
        self.downloadImage = downloadImage
        self.body = body
        self.color = color
        self.attachmentLink = attachmentLink
        self.attachmentFilename = attachmentFilename
        self.attachmentContentSize = attachmentContentSize
        self.attachmentContentType = attachmentContentType
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.link_type = link_type
        self.link_to_join = link_to_join
        self.assignmentType = assignmentType
        self.assignmentStudentList = assignmentStudentList
        self.assignmentDate = assignmentDate
        self.subjectId = subjectId
        self.madrasatieSubTermId = madrasatieSubTermId
        self.madrasatieSubSubjectId = madrasatieSubSubjectId
        self.fullMark = fullMark
        self.creator = creator
        self.messageThreadId = messageThreadId
        self.assignmentId = assignmentId
        self.recipientNumber = recipientNumber
        self.discussionStudent = discussionStudent
    }
}
