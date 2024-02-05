//
//  TextFieldPadding.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/10/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

class TextFieldPadding: UITextField {
    override func awakeFromNib() {
        self.setLeftPaddingPoints(10)
        self.setRightPaddingPoints(10)
    }
    
}
