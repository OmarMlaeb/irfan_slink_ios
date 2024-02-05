//
//  StudentRepliesModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 8/6/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation
struct StudentRepliesModel{
    var id: String
    var text: String
    var color: String
    var studentId: String
    var studentName: String
    var teacherId: String
    var attachmentLink: String
    var attachmentContentType: String
    var attachmentContentSize: String
    var attachmentFileName: String
    var studentLink: String
    var studentContentType: String
    var studentContentSize: String
    var studentFileName: String
    var feedbackList: [FeedbackModel]
    var expand: Bool
    var date: String
    var assignmentId: String
    var status: String
    var gender: String
    var orderColor: String
    var assignmentTitle: String
    var assignmentDescription: String
    var assignmentDueDate: String
    var assignmentEstimatedTime: String
    var actualTime: String
    var mark: String
    var fullMark: String
    var assignedStudentId: String
    var attachments: [AttachmentModel]
    var count: Int
    var userId: Int
    
    public init(id: String, text: String,color: String,studentId: String, studentName: String, teacherId: String,attachmentLink: String,attachmentContentType: String,attachmentContentSize: String,attachmentFileName: String,studentLink: String,studentContentType: String,studentContentSize: String,studentFileName: String, feedbackList: [FeedbackModel], expand: Bool, date: String, assignmentId: String, status: String, gender: String, orderColor: String, assignmentTitle: String, assignmentDescription: String, assignmentDueDate: String, assignmentEstimatedTime: String, actualTime: String, mark: String, fullMark:String, assignedStudentId: String, attachments: [AttachmentModel], userId: Int
    ){
        self.id = id
        self.text = text
        self.color = color
        self.studentId = studentId
        self.studentName = studentName
        self.teacherId = teacherId
        self.attachmentLink = attachmentLink
        self.attachmentContentType = attachmentContentType
        self.attachmentContentSize = attachmentContentSize
        self.attachmentFileName = attachmentFileName
        self.studentLink = studentLink
        self.studentContentType = studentContentType
        self.studentContentSize = studentContentSize
        self.studentFileName = studentFileName
        self.feedbackList = feedbackList
        self.expand = expand
        self.date = date
        self.assignmentId = assignmentId
        self.status = status
        self.gender = gender
        self.orderColor = orderColor
        self.assignmentTitle = assignmentTitle
        self.assignmentDescription = assignmentDescription
        self.assignmentDueDate = assignmentDueDate
        self.assignmentEstimatedTime = assignmentEstimatedTime
        self.actualTime = actualTime
        self.mark = mark
        self.fullMark = fullMark
        self.assignedStudentId = assignedStudentId
        self.attachments = attachments
        self.count = 1
        self.userId = userId
}
}
