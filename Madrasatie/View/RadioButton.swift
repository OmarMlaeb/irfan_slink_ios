//
//  RadioButton.swift
//  Madrasati
//
//  Created by Tarek on 5/4/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

import UIKit

class RadioButton: UIButton {
    var isToggled = false
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    
}
