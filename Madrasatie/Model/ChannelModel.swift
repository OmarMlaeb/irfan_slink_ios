//
//  ChannelsModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 6/24/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation

import Foundation
struct ChannelModel{
    var channelId: String
    var channelCode: String
    var channelName: String
    var channelColor: String
    var channelDate: String
    var channelPublished: Bool
    var sectionsList = [SectionModel]()
    var userId: String
    
  
    
    public init(channelId: String, channelCode: String, channelName: String, channelColor: String, channelDate: String, channelPublished: Bool,sectionsList: [SectionModel], userId: String){
        self.channelId = channelId
        self.channelCode = channelCode
        self.channelName = channelName
        self.channelColor = channelColor
        self.sectionsList = sectionsList
        self.channelDate = channelDate
        self.channelPublished = channelPublished
        self.userId = userId
    }
}
