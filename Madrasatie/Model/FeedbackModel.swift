//
//  FeedbackModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 8/6/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation

struct FeedbackModel{
    var id: String
    var text: String
    var textColor: String
    var color: String
    var senderId: String
    var senderName: String
    var receiverId: String
    var receiverName: String
    var attachmentLink: String
    var attachmentContentType: String
    var attachmentContentSize: String
    var attachmentFileName: String
    var date: String
    
    public init(id: String, text: String,textColor: String, color: String,senderId: String,senderName: String, receiverId: String,receiverName: String,attachmentLink: String,attachmentContentType: String,attachmentContentSize: String,attachmentFileName: String, date: String){
        self.id = id
        self.text = text
        self.textColor = textColor
        self.color = color
        self.senderId = senderId
        self.senderName = senderName
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.attachmentLink = attachmentLink
        self.attachmentContentType = attachmentContentType
        self.attachmentContentSize = attachmentContentSize
        self.attachmentFileName = attachmentFileName
        self.date = date
    }
}
