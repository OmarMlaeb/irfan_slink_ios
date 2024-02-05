//
//  TextFieldPadding.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/10/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 5, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 5, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UITextField{
    @IBInspectable var leftPadding: CGFloat {
        get {
            return self.leftPadding
        }
        set {
            self.setLeftPaddingPoints(newValue)
        }
    }
    
    @IBInspectable var rightPadding: CGFloat {
        get {
            return self.rightPadding
        }
        set {
            self.setRightPaddingPoints(newValue)
        }
    }
}
