//
//  DocumentsModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 9/1/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//


import Foundation

struct DocumentsModel{
    var id: String
    var name: String
    var attachmentLink: String
    var attachmentContentType: String
    var attachmentContentSize: String
    var attachmentFileName: String
    
    public init(id: String, name: String,attachmentLink: String,attachmentContentType: String,attachmentContentSize: String,attachmentFileName: String){
        self.id = id
        self.name = name
        self.attachmentLink = attachmentLink
        self.attachmentContentType = attachmentContentType
        self.attachmentContentSize = attachmentContentSize
        self.attachmentFileName = attachmentFileName
    }
}

