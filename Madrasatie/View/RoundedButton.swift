//
//  RoundedButton.swift
//  Madrasati
//
//  Created by Tarek on 5/3/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit


/// Description:
/// Class that set corner radius to UIButton.
class RoundedButton: UIButton {
    override func awakeFromNib() {
       self.layer.cornerRadius = 25
    }
}
