//
//  Attachment.swift
//  IRFAN Schools
//
//  Created by Maher Jaber on 25/08/2023.
//  Copyright © 2023 IQUAD. All rights reserved.
//

import Foundation
struct AttachmentModel{
    var id: String
    var url: String
    var filename: String
    var width: String
    var height: String
    var type: String
    var size: String
    var small: String
    var medium: String
    var large: String
    var filepath: String
    
    
    public init(id: String, url: String,filename: String,width: String, height: String, type: String,size: String,small: String,medium: String,large: String,filepath: String
    
    ){
        self.id = id
        self.url = url
        self.filename = filename
        self.width = width
        self.height = height
        self.type = type
        self.size = size
        self.small = small
        self.medium = medium
        self.large = large
        self.filepath = filepath
        
}
}
