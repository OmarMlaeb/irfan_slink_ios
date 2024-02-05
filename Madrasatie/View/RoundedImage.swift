//
//  RoundedImage.swift
//  Madrasati
//
//  Created by Tarek on 5/8/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class RoundedImage: UIImageView {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
