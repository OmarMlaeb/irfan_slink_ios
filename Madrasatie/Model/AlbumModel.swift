//
//  AlbumModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 4/28/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation

struct AlbumModel{
    var id: String
    //var date: String
    //var imageType: String
    var albumName: String
    //var size: String
    var image: String
    //var nameList: String
    var dateCreated: String
    var dateModified: String
    var description: String
    var datePublished: String
    //var colorAlbum: String
    //var checked: Bool
    var albumCount: Int

    public init(id: String, albumName: String, image: String, dateCreated: String, dateModified: String, description: String, datePublished: String, albumCount: Int) {
       
        self.id = id
        self.albumName = albumName
        self.image = image
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.description = description
        self.datePublished = datePublished
        self.albumCount = albumCount
      }
}
