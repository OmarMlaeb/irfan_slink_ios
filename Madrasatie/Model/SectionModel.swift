//
//  channelSectionsModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 6/24/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation
struct SectionModel{
    var id: String
    var name: String
    var color: String
    var isTicked: Bool
    var expand: Bool
    var sectionDetailsList = [SectionDetailsModel]()
    var date: String
    var sectionOrder: Int
    var url: String
    var urlTitle: String
    var code: String
    var userId: String
    
 
    
    public init(id: String, name: String, color: String, isTicked: Bool, expand: Bool, sectionDetailsList: [SectionDetailsModel], date: String, sectionOrder: Int, url: String, urlTitle: String, code: String, userId: String){
        self.id = id
        self.name = name
        self.color = color
        self.isTicked = isTicked
        self.expand = expand
        self.sectionDetailsList = sectionDetailsList
        self.date = date
        self.sectionOrder = sectionOrder
        self.url = url
        self.urlTitle = urlTitle
        self.code = code
        self.userId = userId
    }
    
}

