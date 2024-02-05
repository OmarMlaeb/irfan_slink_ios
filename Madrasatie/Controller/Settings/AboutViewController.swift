//
//  AboutViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 9/11/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var schoolInfo: AboutInfo!
    var schoolName = "Saint Joseph School"
    var info: SchoolActivation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
        initData()
        if info == nil{
//            getAbout()
        }else{
            self.getSchoolInfo(activationCode: self.info.code)
        }
        self.view.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Description: - Init Madrasatie data.
    func initData(){
        let socialArray: [Social] = [
            Social(id: 1, name: "Facebook".localiz(), icon: "about-fb", link: "www.facebook.com"),
            Social(id: 2, name: "Twitter".localiz(), icon: "about-twitter", link: "www.twitter.com"),
            Social(id: 3, name: "LinkedIn".localiz(), icon: "about-linkedin", link: "www.linkedin.com"),
            Social(id: 4, name: "Google Plus".localiz(), icon: "about-google", link: "www.google.com"),
            Social(id: 5, name: "Instagram".localiz(), icon: "about-insta", link: "www.instagram.com")
        ]
        schoolInfo = AboutInfo(website: "www.champville.com", direction: "Deek el mehdi - Main Street\nBeirut, Lebanon", lat: 0.0, long: 0.0, phoneNumber: "00961 4 123 456", social: socialArray)
        tableView.reloadData()
    }
    
    /// Description: - Init Selected School data.
    func initSchoolInfo(){
        let socialArray: [Social] = [
            Social(id: 1, name: "Facebook".localiz(), icon: "about-fb", link: self.info.facebook),
            Social(id: 2, name: "Twitter".localiz(), icon: "about-twitter", link: self.info.twitter),
            Social(id: 3, name: "LinkedIn".localiz(), icon: "about-linkedin", link: self.info.linkedIn),
            Social(id: 4, name: "Google Plus".localiz(), icon: "about-google", link: self.info.google),
            Social(id: 5, name: "Instagram".localiz(), icon: "about-insta", link: self.info.instagram)
        ]
        print("hello hello hello: \(self.info)")
        schoolInfo = AboutInfo(website: self.info.website, direction: self.info.location, lat: self.info.lat, long: self.info.long, phoneNumber: self.info.phone, social: socialArray)
        tableView.reloadData()
    }
    
    func initNavigation(){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "\("About".localiz()) \(schoolName)"
        let backButton = UIBarButtonItem(title: nil, style: .done, target: self, action: #selector(backButtonPressed))
        let languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
        if languageId == "ar"{
            backButton.image = UIImage(named: "white-nav-back-ar")
        }else{
            backButton.image = UIImage(named: "white-nav-back")
        }
        backButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barTintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        self.navigationController?.navigationBar.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 18)!]
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func phoneNumberLabelTapped(sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel, let phoneNumber = label.text, let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    
    
    // Mark: - UITableView Delegate and DataSource Functions:
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 3{
//            return schoolInfo.social.count
//        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "websiteReuse")
            let webLabel = cell?.viewWithTag(2) as! UILabel
            let icon = cell?.viewWithTag(3) as! UIImageView
            icon.tintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
            webLabel.text = schoolInfo.website
            cell?.selectionStyle = .none
            return cell!
//        case 1:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "locateReuse")
//            let descriptionLabel = cell?.viewWithTag(6) as! UILabel
//            let icon = cell?.viewWithTag(8) as! UIImageView
//            icon.tintColor = App.hexStringToUIColorCst(hex: "#568EF6", alpha: 1.0)
//            descriptionLabel.text = schoolInfo.direction
//            cell?.selectionStyle = .none
//            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "callReuse")
            let phoneLabel1 = cell?.viewWithTag(11) as! UILabel
            let phoneLabel2 = cell?.viewWithTag(13) as! UILabel
            let mobileLabel = cell?.viewWithTag(14) as! UILabel

            let icon = cell?.viewWithTag(12) as! UIImageView
            icon.tintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
            print("school info: \(self.info)")
            phoneLabel1.text = self.info.phone
            phoneLabel2.text = self.info.instagram
            mobileLabel.text = self.info.google
            
            phoneLabel1.isUserInteractionEnabled = true
            phoneLabel2.isUserInteractionEnabled = true
            mobileLabel.isUserInteractionEnabled = true
            
            let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(phoneNumberLabelTapped))
            let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(phoneNumberLabelTapped))
            let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(phoneNumberLabelTapped))

            phoneLabel1.addGestureRecognizer(tapGesture1)
//            view.addSubview(phoneLabel1)
            
            phoneLabel2.addGestureRecognizer(tapGesture2)
//            view.addSubview(phoneLabel2)
            
            mobileLabel.addGestureRecognizer(tapGesture3)
//            view.addSubview(mobileLabel)
            


            cell?.selectionStyle = .none
            return cell!
        default:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "socialReuse")
//            let socialIcon = cell?.viewWithTag(20) as! UIImageView
//            let socialName = cell?.viewWithTag(21) as! UILabel
//            let social = schoolInfo.social[indexPath.row]
//            socialIcon.image = UIImage(named: social.icon)
//            socialIcon.tintColor = App.hexStringToUIColorCst(hex: "#568EF6", alpha: 1.0)
//            socialName.text = social.name
//            cell?.selectionStyle = .none
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 3{
            let header = tableView.dequeueReusableCell(withIdentifier: "socialHeaderReuse")
            let headerTitle = header?.viewWithTag(15) as! UILabel
            headerTitle.text = "Social media accounts".localiz()
            return header?.contentView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            if let webUrl = URL(string: schoolInfo.website){
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            }
//        case 1:
//            let lat = schoolInfo.lat
//            let long = schoolInfo.long
//            let url = "http://maps.apple.com/maps?saddr=&daddr=\(lat),\(long)"
//            guard let urlIn = URL(string:url) else { return }
//            UIApplication.shared.open(urlIn, options: [:], completionHandler: nil)

        case 1:
            let phone = schoolInfo.phoneNumber
            if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        default:
            if let url = URL(string: schoolInfo.social[indexPath.row].link){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else{
                App.showMessageAlert(self, title: "", message: "\("This School doesn't have".localiz()) \(schoolInfo.social[indexPath.row].name)", dismissAfter: 2.0)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3{
            return 44
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3{
            return 0.01
        }
        return 15
    }
    
    /// Description: Get About
    /// - Call "getMadrasatieInfo" API and update Madrasatie data.
    func getAbout(){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.getSchoolInfo() { (message, aboutData, status) in
            if status == 200{
                self.schoolInfo = aboutData!
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.tableView.reloadData()
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    /// Description: Get School Info
    /// - Call "getMadrasatieInfo" API and update current school data.
    /// - Update info into Core Data.
    func getSchoolInfo(activationCode: String){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.GetSchoolURL(activationCode: activationCode) { (message, schoolData, status) in
            if status == 200{
                self.info = schoolData
                let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
                //let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOLDATA")
                let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
                let school = try? managedContext.fetch(userFetchRequest) as! [SCHOOL]
                
                var schoolIds: [Int] = []
                if school != nil{
                    for object in school! {
                        schoolIds.append(Int(object.id))
                    }
                }
                let schoolInfo = schoolData
                    
                if school != nil && !schoolIds.contains(schoolData.id){
                    for object in school! {
                        if Int(object.id) == self.info.id{
                            object.setValue(schoolData.id, forKey: "id")
                            object.setValue(schoolData.logo, forKey: "logo")
                            object.setValue(schoolData.schoolURL, forKey: "url")
                            object.setValue(schoolData.schoolId, forKey: "schoolId")
                            object.setValue(schoolData.lat, forKey: "lat")
                            object.setValue(schoolData.long, forKey: "long")
                            object.setValue(schoolData.location, forKey: "location")
                            object.setValue(schoolData.name, forKey: "name")
                            object.setValue(schoolData.phone, forKey: "phone")
                            object.setValue(schoolData.facebook, forKey: "facebook")
                            object.setValue(schoolData.google, forKey: "google")
                            object.setValue(schoolData.instagram, forKey: "instagram")
                            object.setValue(schoolData.linkedIn, forKey: "linkedIn")
                            object.setValue(schoolData.twitter, forKey: "twitter")
                            object.setValue(schoolData.website, forKey: "website")
                            object.setValue(schoolData.code, forKey: "code")
                            do {
                                try managedContext.save()
                            } catch {}
                        }
                    }
                }
                self.initSchoolInfo()
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
