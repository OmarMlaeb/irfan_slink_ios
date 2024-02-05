//
//  DiscussionMessageModel.swift
//  IRFAN Schools
//
//  Created by Maher Jaber on 11/15/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation

struct DiscussionMessageModel: Hashable{
    var id: String
    var senderId: String
    var senderName: String
    var senderLink: String
    var senderFilename: String
    var senderContentType: String
    var senderFilesize: String
    var messageId: String
    var messageText: String
    var nbOfRecipients: String
    var messageDate: String
    var color: String
    var gender: String
    
   
    
    public init(id: String, senderId: String, senderName: String, senderLink: String, senderFilename: String, senderContentType: String, senderFilesize: String, messageId: String, messageText: String, nbOfRecipients: String, messageDate: String, color: String, gender: String){
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.senderLink = senderLink
        self.senderFilename = senderFilesize
        self.senderContentType = senderContentType
        self.senderFilesize = senderFilesize
        self.messageId = messageId
        self.messageText = messageText
        self.nbOfRecipients = nbOfRecipients
        self.messageDate = messageDate
        self.color = color
        self.gender = gender
        
    }
}
