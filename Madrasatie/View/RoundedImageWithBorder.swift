//
//  RoundedImageWithBorder.swift
//  Madrasati
//
//  Created by Tarek on 5/7/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class RoundedImageWithBorder: UIImageView {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 7.0
        self.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}
