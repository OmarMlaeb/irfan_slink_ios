//
//  ChangePasswordModalVC.swift
//  Madrasati
//
//  Created by Tarek on 5/7/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

protocol ChangePasswordDelegate{
    func saveNewPassword(user: User, password: String)
}

class ChangePasswordModalVC: UIViewController {
    @IBOutlet weak var view_box: UIView!
    @IBOutlet weak var txt_password: LoginRoundedTextField!
    @IBOutlet weak var txt_ConfirmPassword: LoginRoundedTextField!

    @IBOutlet weak var txt_oldPassword: LoginRoundedTextField!
    
    var delegate: ChangePasswordDelegate?
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        customizeView()
    }
    
    func customizeView() {
        view_box.layer.cornerRadius = 15.0
    }
    @IBAction func bt_oldPasswordWasHolded(_ sender: UIButton) {
        txt_oldPassword.isSecureTextEntry = false

    }
    
    @IBAction func bt_oldPasswordWasPressed(_ sender: UIButton) {
        txt_oldPassword.isSecureTextEntry = true

    }
    
    @IBAction func bt_passwordWasPressed(_ sender: Any) {
        txt_password.isSecureTextEntry = true
    }
    
    @IBAction func bt_passwordWasHolded(_ sender: Any) {
        txt_password.isSecureTextEntry = false
    }
    
    @IBAction func bt_confirmPasswordWasPressed(_ sender: Any) {
        txt_ConfirmPassword.isSecureTextEntry = true
    }
    
    @IBAction func bt_confirmPasswordWasHolded(_ sender: Any) {
        txt_ConfirmPassword.isSecureTextEntry = false
    }
    
    @IBAction func cancelForm(_ sender: Any) {
        self.dismiss(animated: true)
    }
    /// Description:
    /// - Check if password and confirm password are the same in call change password function.
    @IBAction func saveButtonPressed(_ sender: Any) {
        if txt_password.text == txt_ConfirmPassword.text{
            changePassword(user: self.user, oldPassword: txt_oldPassword.text!, newPassword: txt_password.text!, confirm: txt_ConfirmPassword.text!)
        }else{
            App.showMessageAlert(self, title: "", message: "Password and Confirm password should be the same".localiz(), dismissAfter: 2.0)
        }
    }
    
    
    /// Description: Change password API
    /// - Call change_password API to submit a new password.
    /// - If success call saveNewPassword delegate function to reset Login page design.
    func changePassword(user: User, oldPassword: String, newPassword: String, confirm: String){
        Request.shared.changePassword(user: user, oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirm) { (message, data, status) in
            if status == App.STATUS_SUCCESS{
                self.dismiss(animated: true) {
                    self.delegate?.saveNewPassword(user: user, password: newPassword)
                }
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Error".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
}

