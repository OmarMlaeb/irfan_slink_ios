//
//  KeyboardDismiss.swift
//  Madrasati
//
//  Created by Tarek on 5/4/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
extension UIViewController {
    /// Description:
    /// - Extenxion to hide the default keyboard when touch outside the editable view.
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
