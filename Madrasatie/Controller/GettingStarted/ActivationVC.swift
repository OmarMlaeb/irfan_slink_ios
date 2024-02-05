//
//  ActivationVC.swift
//  Madrasati
//
//  Created by Tarek on 5/3/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import CoreData

protocol ActivationVCDelegate{
    func updateSchoolInfo(schooldData: SchoolActivation)
}

class ActivationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var view_box: UIView!
    @IBOutlet weak var bt_info: UIButton!
    @IBOutlet weak var bt_agree: RadioButton!
    @IBOutlet weak var view_agree: UIView!
    @IBOutlet weak var lbl_terms: UILabel!
    @IBOutlet weak var bt_submit: RoundedButton!
    @IBOutlet weak var scanQRButton: RoundedButton!
    @IBOutlet weak var activationCodeTextField: RoundedTextField!
    @IBOutlet weak var backButton: UIButton!
    
    var pages: Page?
    var madrasatiInfo: AboutInfo!
    var back = false
    var settings = false
    var delegate: ActivationVCDelegate?
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    
    var schoolCodes: [String] = ["6f4ea1", "51edf4", "ba61df", "c0b182", "1956bf", "123456"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //smaller font for armenian language
        if languageId == "hy" {
            scanQRButton.titleLabel?.font = .systemFont(ofSize: 11)
        }
        
        customizeView()
        getPages()
        configureTermsLabel()
        hideKeyboardWhenTappedAround()
        activationCodeTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        getMadrasatieInfo()
        if settings{
            backButton.setImage(UIImage(named: "close"), for: .normal)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        }
    }
    
    override func viewDidLayoutSubviews() {
        switch languageId{
        case "ar":
            backButton.setImage(UIImage(named: "calendar-right-arrow"), for: .normal)
        default:
            backButton.setImage(UIImage(named: "calendar-left-arrow"), for: .normal)
        }
    }
    
    
    /// Description:
    /// - This function is used to configure terms and conditions attributed text and add a listener to the text.
    func configureTermsLabel(){
        lbl_terms.text = "I agree on the terms and conditions and privacy policy".localiz()
        let text = lbl_terms.text!
        let attributesText = NSMutableAttributedString(string: text)
        let agreeText = (text as NSString).range(of: "I agree on the".localiz())
        attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 13)!], range: agreeText)
        let andText = (text as NSString).range(of: "and".localiz())
        attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 13)!], range: andText)
        let termsText = (text as NSString).range(of: "terms and conditions".localiz())
        attributesText.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor(red:0.34, green:0.56, blue:0.96, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 13)!], range: termsText)
        let privacyText = (text as NSString).range(of: "privacy policy".localiz())
        attributesText.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor(red:0.34, green:0.56, blue:0.96, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 13)!], range: privacyText)
        lbl_terms.attributedText = attributesText
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        lbl_terms.addGestureRecognizer(gesture)
        lbl_terms.isUserInteractionEnabled = true
    }
    
    
    /// Description:
    /// - Handle Terms and Conditions gesture events:
    @objc func tapLabel(gesture: UITapGestureRecognizer){
        let text = (lbl_terms.text)!
        let termsText = (text as NSString).range(of: "terms and conditions".localiz())
        let privacyText = (text as NSString).range(of: "privacy policy".localiz())
        let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
        
        if (self.pages == nil){
            return
        }
        
        if gesture.didTapAttributedTextInLabel(label: lbl_terms, inRange: termsText) {
            let termViewController = storyboard.instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as! TermsAndConditionsViewController
            termViewController.terms = self.pages?.terms
            self.show(termViewController, sender: self)
        }else if gesture.didTapAttributedTextInLabel(label: lbl_terms, inRange: privacyText){
            let privacyViewController = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            privacyViewController.privacy = self.pages?.privacy
            self.show(privacyViewController, sender: self)
        }
    }
    
    @IBAction func helpButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
        let helpVC = storyboard.instantiateViewController(withIdentifier: "HelpCenterViewController") as! HelpCenterViewController
        helpVC.pages = self.pages
        self.show(helpVC, sender: self)
    }
    
    @IBAction func bt_agreeWasPressed(_ sender: Any) {
        bt_agree.isToggled = !bt_agree.isToggled
        if bt_agree.isToggled {
            view_agree.alpha = 1
            if !activationCodeTextField.text!.isEmpty{
                bt_submit.alpha = 1
                bt_submit.isUserInteractionEnabled = true
            }
            scanQRButton.alpha = 1
            scanQRButton.isUserInteractionEnabled = true
        } else {
            view_agree.alpha = 0
            bt_submit.alpha = 0.2
            bt_submit.isUserInteractionEnabled = false
            scanQRButton.alpha = 0.2
            scanQRButton.isUserInteractionEnabled = false
        }
    }

    
    /// Description:
    /// - Check if agree terms and conditions is checked before submit the school activation code:
    @IBAction func bt_submitWasPressed(_ sender: Any) {
        if activationCodeTextField.text!.isEmpty{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Error".localiz(), message: "Enter activation code to continue".localiz(), actions: [ok], controller: nil, isCancellable: true)
        }else if !bt_agree.isToggled{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Error".localiz(), message: "You need to agree Terms and Conditions".localiz(), actions: [ok], controller: nil, isCancellable: true)
        }
        else{
            let activationCode = activationCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//            if(self.schoolCodes.contains(activationCode)){
                submitActivation(activationCode: activationCode)
//            }
//            else{
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "Error".localiz(), message: "Invalid school code", actions: [ok], controller: nil, isCancellable: true)
//            }
        }
    }
    
    @IBAction func scanQRButtonPressed(_ sender: Any) {
        App.showMessageAlert(self, title: "Coming Soon".localiz(), message: "Feature will be coming soon".localiz(), dismissAfter: 1.5)
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        guard let info = madrasatiInfo else{
//            self.getMadrasatieInfo()
            return
        }
        if let fb = info.social.filter({$0.id == 1}).first{
            guard let fbUrl = URL(string: fb.link) else { return }
            UIApplication.shared.open(fbUrl, options: [:], completionHandler: nil)
        }else{
            App.showMessageAlert(self, title: "", message: "School doesn't have Facebook".localiz(), dismissAfter: 2.0)
        }
    }
    
    @IBAction func webButtonPressed(_ sender: Any) {
        guard let info = madrasatiInfo else{
//            self.getMadrasatieInfo()
            return
        }
        let web = info.website
        guard let webUrl = URL(string: web) else { return }
        UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
    }
    
    @IBAction func phoneButtonPressed(_ sender: Any) {
        guard let info = madrasatiInfo else{
//            self.getMadrasatieInfo()
            return
        }
        if let url = URL(string: "tel://\(info.phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func mapButtonPressed(_ sender: Any) {
        guard let info = madrasatiInfo else{
//            self.getMadrasatieInfo()
            return
        }
        let lat = info.lat
        let long = info.long
        let url = "http://maps.apple.com/maps?saddr=&daddr=\(lat),\(long)"
        guard let urlIn = URL(string:url) else { return }
        UIApplication.shared.open(urlIn, options: [:], completionHandler: nil)
    }
    
    @IBAction func aboutButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        aboutVC.schoolName = "SLink".localiz()
        self.show(aboutVC, sender: self)
    }
    
    
    /// Description:
    /// - If this page was presented from settings it will dismiss, otherwise it will pop to the page that was pushed from.
    @IBAction func backButtonPressed(_ sender: Any) {
        if settings{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    /// Description:
    /// - Initialize page design.
    func customizeView(){
        view_agree.alpha = 0
        view_box.layer.cornerRadius = 15.0
        view_box.layer.borderColor = #colorLiteral(red: 0.8549019608, green: 0.8588235294, blue: 0.862745098, alpha: 1)
        view_box.layer.borderWidth = 1.0
        view_box.layer.masksToBounds = true
        bt_info.layer.borderWidth = 1
        bt_info.layer.borderColor = #colorLiteral(red: 0.8549019608, green: 0.8588235294, blue: 0.862745098, alpha: 1)
        bt_agree.layer.borderWidth = 1
        bt_agree.layer.borderColor = #colorLiteral(red: 0.8549019608, green: 0.8588235294, blue: 0.862745098, alpha: 1)
        view_agree.layer.cornerRadius = view_agree.frame.width / 2
    }
    
    
    /// Description:
    /// - Check if the code field is empty or terms and conditions wasn't agree to disable submit button.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if bt_agree.isToggled{
            bt_submit.alpha = 1
            bt_submit.isUserInteractionEnabled = true
        }else{
            bt_submit.alpha = 0.2
            bt_submit.isUserInteractionEnabled = false
        }
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if textField.text!.isEmpty || (textField.text?.count == 1 && isBackSpace == -92){
            bt_submit.alpha = 0.2
            bt_submit.isUserInteractionEnabled = false
        }
        return true
    }
    
}

extension ActivationVC{
    
    /// Description:
    /// - Request to Get School URL API, and go to login page.
    /// - On success: save the data into core data.
    /// - Save the current school url into userDefaults.
    func submitActivation(activationCode: String){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.GetSchoolURL(activationCode: activationCode) { (message, schoolData, status) in
            if status == 200{
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
                if !schoolIds.contains(schoolData.id){
                    let schoolEntity = NSEntityDescription.entity(forEntityName: "SCHOOL", in: managedContext)
                    let newSchool = NSManagedObject(entity: schoolEntity!, insertInto: managedContext)
                    newSchool.setValue(schoolData.id, forKey: "id")
                    newSchool.setValue(schoolData.logo, forKey: "logo")
                    newSchool.setValue(schoolData.schoolURL, forKey: "url")
                    newSchool.setValue(schoolData.schoolId, forKey: "schoolId")
                    newSchool.setValue(schoolData.lat, forKey: "lat")
                    newSchool.setValue(schoolData.long, forKey: "long")
                    newSchool.setValue(schoolData.location, forKey: "location")
                    newSchool.setValue(schoolData.name, forKey: "name")
                    newSchool.setValue(schoolData.phone, forKey: "phone")
                    newSchool.setValue(schoolData.facebook, forKey: "facebook")
                    newSchool.setValue(schoolData.google, forKey: "google")
                    newSchool.setValue(schoolData.instagram, forKey: "instagram")
                    newSchool.setValue(schoolData.linkedIn, forKey: "linkedIn")
                    newSchool.setValue(schoolData.twitter, forKey: "twitter")
                    newSchool.setValue(schoolData.website, forKey: "website")
                    newSchool.setValue(schoolData.code, forKey: "code")
                    do {
                        try managedContext.save()
                    } catch {}
                }
                UserDefaults.standard.set(schoolData.schoolURL, forKey: "BASEURL")
                UserDefaults.standard.set(schoolData.id, forKey: "SCHOOLID")
                if self.back{
                    self.delegate?.updateSchoolInfo(schooldData: schoolInfo)
                    self.navigationController?.popViewController(animated: true)
                }else{
                    print("login5")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    vc.schoolInfo = schoolInfo
                    self.show(vc, sender: self)
                }
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
    
    
    /// Description:
    /// - Request to GetPages API and get terms and conditions, privacy policy, help center and faq questions data.
    func getPages(){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.getPages() { (message, pagesData, status) in
            if status == 200{
                self.pages = pagesData!
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
    
    /// Get Madrasatie Info:
    /// Description:
    /// - Request to GetSchoolInfo API to get the current school infos.
    func getMadrasatieInfo(){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.getSchoolInfo() { (message, aboutData, status) in
            if status == 200{
                self.madrasatiInfo = aboutData!
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
