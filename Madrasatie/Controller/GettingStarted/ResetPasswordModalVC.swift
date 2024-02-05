//
//  ResetPasswordModalVC.swift
//  Madrasati
//
//  Created by Tarek on 5/7/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

protocol ResetPasswordDelegate {
    func forgetPassword(username: String, type: String)
}

class ResetPasswordModalVC: UIViewController {
    @IBOutlet weak var view_box: UIView!
    @IBOutlet weak var bt_contactSchool: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var email = ""
    var phone = ""
    var user: User!
    var schoolInfo: SchoolActivation!
    var delegate: ResetPasswordDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        customizeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailLabel.text = email
        phoneLabel.text = phone
    }
    
    func customizeView() {
        view_box.layer.cornerRadius = 15.0
      bt_contactSchool.roundCorners([.bottomRight,.bottomLeft], radius: 15.0)
    }
    
    @IBAction func contactSchoolButtonPressed(_ sender: Any) {
        let phone = schoolInfo.phone
        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            App.showMessageAlert(self, title: "", message: "Phone number not available", dismissAfter: 1.5)
        }
    }
    
    @IBAction func bt_cancelWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func emailButtonPressed(_ sender: Any) {
        sendOTP(type: "email", user: self.user)
    }
    
    @IBAction func phoneButtonPressed(_ sender: Any) {
        sendOTP(type: "sms", user: self.user)
    }
    
    
//    func getPhoneAndEmail(userName: String){
//        let indicatorView = App.loading()
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
//        Request.shared.GetPhoneEmail(username: userName) { (message, emailData, phoneData, status)  in
//            if status == 200{
//                self.emailLabel.text = emailData
//                self.phoneLabel.text = phoneData
//            }
//            else{
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
//            }
//            if let viewWithTag = self.view.viewWithTag(100){
//                viewWithTag.removeFromSuperview()
//            }
//        }
//    }
    
    
    /// Description:
    /// - Parameters:
    ///   - type: "email" to send an email or "sms" to send an sms.
    /// - Call "forgot_password" API to send OTP to the choosen type.
    /// - On Success, call delegate function "forgetPassword" in order to change the design view to reset the password and submit the OTP.
    func sendOTP(type: String, user: User){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        Request.shared.SendOTP(type: type, user: user) { (message, data, status)  in
            if status == 200{
                self.delegate?.forgetPassword(username: self.email, type: type)
                self.dismiss(animated: true, completion: nil)
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
}
