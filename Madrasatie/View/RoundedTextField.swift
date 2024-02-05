//
//  RoundedTextField.swift
//  Madrasati
//
//  Created by Tarek on 5/4/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class RoundedTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderStyle = .none
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderWidth = 0.5
        self.layer.borderColor =  #colorLiteral(red: 0.8536118865, green: 0.8602882028, blue: 0.8635701537, alpha: 1)
        self.layer.masksToBounds = false
        self.layer.backgroundColor = UIColor.white.cgColor
    }
    private var padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 30)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
//        return UIEdgeInsetsInsetRect(bounds, padding)
        return bounds.inset(by: padding)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
//        return UIEdgeInsetsInsetRect(bounds, padding)
        return bounds.inset(by: padding)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
//        return UIEdgeInsetsInsetRect(bounds, padding)
        return bounds.inset(by: padding)
    }
    
    func customizeView(){
        
        let placeHolder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)])
        attributedPlaceholder = placeHolder
    }
}

