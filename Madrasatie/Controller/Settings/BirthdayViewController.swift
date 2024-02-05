//
//  BirthdayViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 4/9/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit

class BirthdayViewController: UIViewController {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var schoolLogoImageView: UIImageView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    var user: User?
    var confettiView1: SAConfettiView!
    var confettiView2: SAConfettiView!
    var confettiView3: SAConfettiView!
    var timer = Timer()
    var imageArray: [UIImage]{
        return [
            UIImage(named: "green-balloon")!,
            UIImage(named: "red-balloon")!,
            UIImage(named: "blue-balloon")!,
            UIImage(named: "orange-balloon")!
        ]
    }
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")

    var confettiColors: [UIColor]{
        return [
            UIColor(red:1.00, green:0.95, blue:0.00, alpha:1.0),
            UIColor(red:0.40, green:1.00, blue:0.35, alpha:1.0),
            UIColor(red:0.28, green:0.76, blue:0.96, alpha:1.0),
            UIColor(red:0.93, green:0.25, blue:0.22, alpha:1.0)
        ]
    }

    /// Description: - Initialize Confitti Views.
    override func viewDidLoad() {
        super.viewDidLoad()
        initPage()
        
        // Create confetti view
        confettiView1 = SAConfettiView(frame: CGRect(x: self.view.frame.width * 0.6, y: 182, width: 200, height: 200))
        confettiView2 = SAConfettiView(frame: CGRect(x: self.view.frame.width * 0.1, y: 182, width: 200, height: 200))
        confettiView3 = SAConfettiView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        // Set colors (default colors are red, green and blue)
        confettiView1.colors = confettiColors
        confettiView2.colors = confettiColors
        confettiView3.colors = confettiColors
        
        // Set intensity (from 0 - 1, default intensity is 0.5)
        confettiView1.intensity = 1
        confettiView2.intensity = 1
        confettiView3.intensity = 1
        
        // Set type
        confettiView1.type = .confetti
        confettiView2.type = .confetti
        confettiView3.type = .confetti
        
        // For custom image
        // confettiView.type = .Image(UIImage(named: "diamond")!)
        
        // Add subview
        view.insertSubview(confettiView1, at: 0)
        view.insertSubview(confettiView2, at: 0)
        view.insertSubview(confettiView3, at: 0)
        
        confettiView1.startConfetti()
        confettiView2.startConfetti()
        confettiView3.startConfetti()
        
        if user?.userType == 4{
            self.checkBirthday(studentUsername: user?.admissionNo ?? "")
        }else{
            self.checkBirthday(studentUsername: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateBallon), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        confettiView3.center = self.view.center
    }
    
    func initPage(){
        guard let user = self.user else{ return }
        if user.userType == 2{
            userLabel.text = "\(user.firstName) \(user.lastName)"
        }else{
            userLabel.text = "\(user.firstName) \(user.lastName)\n\(user.classes.first?.className ?? "")"
        }
        
        let schoolInfo = App.getSchoolActivation(schoolID: user.schoolId)
        if let schoolUrl = URL(string: schoolInfo?.logo ?? ""){
            schoolLogoImageView.sd_setImage(with: schoolUrl, completed: nil)
        }
        
        var icon = user.photo.unescaped
                
        if(baseURL?.prefix(8) == "https://"){
            if(user.photo.unescaped.prefix(8) != "https://"){
                icon = "https://" + icon
            }
        }
        else if(baseURL?.prefix(7) == "http://"){
            if (user.photo.unescaped.prefix(7) != "http://" ){
                icon = "http://" + icon
            }
        }
        
        
        if user.photo.unescaped != "" {
            userProfileImageView.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "avatar"))
        }else{
            userProfileImageView.image = UIImage(named: "avatar")
        }
        
        
        if user.gender.lowercased() == "m"{
            self.view.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        }else{
            self.view.backgroundColor = App.hexStringToUIColorCst(hex: "#ec008c", alpha: 1.0)
        }
    }
    
    @objc func animateBallon(){
        let x = CGFloat.random(min: 0, max: self.view.frame.width)
        let ballomImageView = UIImageView(frame: CGRect(x: x, y: self.view.frame.height + 200, width: 200, height: 200))
        ballomImageView.image = imageArray.randomElement()
        ballomImageView.contentMode = .scaleAspectFit
        self.view.insertSubview(ballomImageView, at: 0)
        
        let angle = CGFloat.random(min: -CGFloat.pi/18, max: CGFloat.pi/18)
        
        UIView.animate(withDuration: 5, animations: {
            ballomImageView.center.y = -200
            ballomImageView.transform = CGAffineTransform(rotationAngle: angle)
        }) { (Bool) in
            ballomImageView.removeFromSuperview()
        }
    }
    
    @IBAction func xButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Handle Tab Bar Delegate Function:
extension BirthdayViewController: TabBarToBirthdayDelegate{
    func updateUser(user: User) {
        self.user = user
        if self.userLabel != nil{
            initPage()
        }
    }
}

// API Call:
extension BirthdayViewController{
    
    /// Description:
    /// - Call "check_bday_page" API to mark birthday as checked.
    func checkBirthday(studentUsername: String){
        Request.shared.checkBirthday(user: self.user!, studentUsername: studentUsername) { (message, data, status) in
        }
    }
}
