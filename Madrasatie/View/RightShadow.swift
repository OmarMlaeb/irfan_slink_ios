//
//  RightShadow.swift
//  Madrasatie
//
//  Created by hisham noureddine on 8/13/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

class RightShadow: UIView {
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 0)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 1.0
        self.layer.masksToBounds = false
    }
    
}
