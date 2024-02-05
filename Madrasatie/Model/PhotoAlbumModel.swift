//
//  PhotoAlbumModel.swift
//  Madrasatie
//
//  Created by Maher Jaber on 4/28/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation
struct PhotoAlbumModel{
    var id: String
    var imageLink: String
    var imageContentType: String
    var imageSize: String
    var createdAt: String
    var description: String
    var imageName: String
    
    public init(id: String, imageLink: String, imageContentType: String, imageSize: String, createdAt: String, description: String, imageName: String){
        self.id = id
        self.imageLink = imageLink
        self.imageContentType = imageContentType
        self.imageSize = imageSize
        self.createdAt = createdAt
        self.description = description
        self.imageName = imageName
    }
}
