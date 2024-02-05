//
//  SettingsViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/2/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import CoreData
//import GoogleSignIn
import MSAL
import FirebaseCrashlytics
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var settingsArray: [[Setting]] = []
    var pages: Page!
    var schoolInfo: SchoolActivation!
    var user: User!
    let deviceToken = UserDefaults.standard.string(forKey: "DEVICETOKEN")
    let uuid = NSUUID().uuidString.lowercased()
    var userArray: [User] = []
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    
    let kClientID = "bd68a1bb-5e76-4cf7-87d2-aaa49bca0e15"
    let kRedirectUri = "msauth.madrasatie.app.wb://auth"
    let kAuthority = "https://login.microsoftonline.com/common"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kScopes: [String] = ["user.read"] // request permission to read the profile of the signed-in user

    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParameters : MSALWebviewParameters?
    var currentAccount: MSALAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        
        
        
        initSettings()
        getPages()
    }
    
    func initSettings(){
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
        settingsArray = [[
//            Setting(id: 1, name: "Notifications"),
            Setting(id: 2, name: "Language".localiz()),
            Setting(id: 3, name: "Add user".localiz()),
            Setting(id: 4, name: "Add school".localiz())
            ],
        [
//            Setting(id: 5, name: "About Madrasatie".localiz()),
            Setting(id: 6, name: "\("About".localiz()) \(schoolInfo.name)"),
            ],
        [
            Setting(id: 7, name: "Terms and Conditions".localiz()),
            Setting(id: 8, name: "Privacy Policy".localiz()),
            Setting(id: 9, name: "Change Password".localiz()),
            Setting(id: 10, name: "Logout".localiz()),
            Setting(id: 12, name: ("Version: " + version)),
            ]
//            ,
//        [
//            Setting(id: 13, name: "Support Hybrid Learning Model")
//            ]
        ]
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - UITableView Delegate and DataSource Fucntions:
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource, ChangePasswordDelegate{
    func saveNewPassword(user: User, password: String) {
        
        print("username: \(user.userName)")
        print("username: \(password)")

        self.SignIn(userName: user.userName, password: password, schoolUrl: schoolInfo.schoolURL, grantType: "password")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settingsArray[indexPath.section]

//        if(setting[indexPath.row].id == 13){
//            let cell = tableView.dequeueReusableCell(withIdentifier: "supportReuse")
//            let supportLabel = cell?.viewWithTag(5) as! UILabel
//            supportLabel.text = setting[indexPath.row].name
//            supportLabel.textAlignment = .center
//            supportLabel.font = UIFont(name: "OpenSans-Bold", size: 16)
//            supportLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//            cell?.backgroundColor = App.hexStringToUIColorCst(hex: "#f1a41f", alpha: 1.0)
//            return cell!
//        }
//        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsReuse")
                   let separator: UIView? = cell?.viewWithTag(1)
                   let titleLabel = cell?.viewWithTag(5) as! UILabel
                   titleLabel.text = setting[indexPath.row].name
                   switch setting[indexPath.row].id{
                   case 9:
                       titleLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
                       titleLabel.textColor = App.hexStringToUIColorCst(hex: "#ee4037", alpha: 1.0)
                   case 10:
                       titleLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
                       titleLabel.textColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
                   case 12:
                    titleLabel.font = UIFont(name: "OpenSans-Bold", size: 16)
                   default:
                       titleLabel.font = UIFont(name: "OpenSans-Regular", size: 15)
                       titleLabel.textColor = App.hexStringToUIColorCst(hex: "#231f20", alpha: 1.0)
                   }
                   if indexPath.row == setting.count - 1{
                       separator?.isHidden = true
                   }else{
                       separator?.isHidden = false
                   }
                   cell?.selectionStyle = .none
                   return cell!
//        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch settingsArray[indexPath.section][indexPath.row].id{
        case 2:
            let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
            let languageVC = storyboard.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
            languageVC.setting = true
            languageVC.modalPresentationStyle = .fullScreen
            self.show(languageVC, sender: self)
        case 3:
            let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
            print("login2")
            let login = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
//            login.setting = true
            let navController = UINavigationController(rootViewController: login)
            UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in
                navController.modalPresentationStyle = .fullScreen
                self.show(navController, sender: self)
            }, completion: { _ in })
        case 4:
            let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
            let activation = storyboard.instantiateViewController(withIdentifier: "ActivationVC") as! ActivationVC
            activation.settings = true
            let navController = UINavigationController(rootViewController: activation)
            UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in         navController.modalPresentationStyle = .fullScreen
                self.show(navController, sender: self)
            }, completion: { _ in })
        case 5:
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
            aboutVC.schoolName = "SLink"
            aboutVC.modalPresentationStyle = .fullScreen
            self.show(aboutVC, sender: self)
        case 6:
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
            aboutVC.schoolName = schoolInfo.name
            aboutVC.info = self.schoolInfo
            aboutVC.modalPresentationStyle = .fullScreen
            self.show(aboutVC, sender: self)
        case 7:
            let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
            let termsVC = storyboard.instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as! TermsAndConditionsViewController
            termsVC.terms = self.pages.terms
            termsVC.modalPresentationStyle = .fullScreen
            self.show(termsVC, sender: self)
        case 8:
            let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
            let privacyVC = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            privacyVC.privacy = self.pages.privacy
            privacyVC.modalPresentationStyle = .fullScreen
            self.show(privacyVC, sender: self)
        case 9:
//            guard let url = URL(string: "https://madrasatiesupport.freshdesk.com/support/tickets/new") else { return }
//            UIApplication.shared.open(url)
            let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier:"ChangePasswordModalVC") as! ChangePasswordModalVC
            vc.modalTransitionStyle = .crossDissolve
            vc.delegate = self
            vc.user = self.user
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
            break
        case 10:
            let ok = UIAlertAction(title: "OK", style: .default) { (alert: UIAlertAction!) in
                self.removeUser()
//                GIDSignIn.sharedInstance()?.signOut()
                    if(self.userArray.count == 1){
                        let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
                        print("login3")
                        let login = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        let navController = UINavigationController(rootViewController: login)
                        UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in
                            navController.modalPresentationStyle = .fullScreen
                            self.show(navController, sender: self)
                        }, completion: { _ in })
                    }
                else{
                    App.showSplashScreen()
                }
               
            }
            let cancel = UIAlertAction(title: "CANCEL".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "", message: "Are you sure do you want to logout ?".localiz(), actions: [ok, cancel], controller: nil, isCancellable: true)
            break
        case 11:
            App.showMessageAlert(self, title: "", message: "Please contact your school".localiz(), dismissAfter: 1.5)

//            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
//            let faqVC = storyboard.instantiateViewController(withIdentifier: "FaqViewController") as! FaqViewController
//            faqVC.faqArray = self.pages.faq
//            faqVC.modalPresentationStyle = .fullScreen
//            self.show(faqVC, sender: self)
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "headerReuse")
        let titleLabel = header?.viewWithTag(10) as! UILabel
        titleLabel.text = "About"
        titleLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        header?.contentView.backgroundColor = .white
        return header?.contentView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = App.hexStringToUIColorCst(hex: "#f1f2f2", alpha: 1.0)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 || section == 3{
            return 0.01
        }
        return 15
    }
    
    func SignIn(userName: String, password: String, schoolUrl: String, grantType: String){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.SignIn(userName: userName, password: password, schoolUrl: schoolUrl, grantType: grantType) { (message, userData, status) in
            if status == 200{
//                self.updateUserDetails(id: userData!.userId, token: userData!.token, schoolUrl: schoolUrl, password: userData!.password)
                print("user user: \(self.user)")
                
                let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

                // Step 1: Fetch the user you want to update
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")


                do {
                    if let users = try managedContext.fetch(fetchRequest) as? [USER] {
                            if users != nil{
                                for user in users{
                                    print("user user1: \(self.user.userId)")

                                    let idd = user.integer(forKey: "userId")
                                    print("user user2: \(idd)")

                                    if(idd == user.userId){
                                        user.password = password
                                    }
                                    print("user user3: \(user.password)")

                                }
                            }
                            
                            // Step 3: Save the managed object context to persist the changes
                            do {
                                try managedContext.save()
                                print("User updated successfully: \(users)")
                            } catch {
                                print("Error saving user update: \(error.localizedDescription)")
                            }
                        
                    }
                } catch {
                    print("Error fetching user: \(error.localizedDescription)")
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
    
    func updateUserDetails(id: Int, token: String, schoolUrl: String, password: String){
            let indicatorView = App.loading()
            indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            indicatorView.tag = 100
            self.view.addSubview(indicatorView)
    
        Request.shared.getUserDetails(id: id, token: token, schoolUrl: schoolUrl, password: password, completion: { (message, userData, status) in
                if status == 200{
                    print("entered updateUserDetails")
                    print(userData)
                    self.user = userData
                    self.saveUser(userData: userData)
                    print("user user1: \(self.user)")

                    /// modelVersion variable is the core data model version, used to check if the core data model has been changed to delete users data and resign in again.
                  
    
                    if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                    }
                }
                else{
                    if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                    }
                }
            })
        }
    
    func getUsersID() -> [Int]{
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
        let users = try? managedContext.fetch(userFetchRequest) as! [USER]
        var usersID: [Int] = []
        if users != nil{
            for user in users!{
                usersID.append(user.integer(forKey: "userId"))
            }
        }
        return usersID
    }
    
    func saveUser(userData: User?){
        //add user to firebase
        let userIdentifier = (UserDefaults.standard.string(forKey: "BASEURL")?.description ?? "nourl") + " - " + (userData?.userName ?? "N/A")
//        Crashlytics.sharedInstance().setUserIdentifier(userIdentifier)
        Crashlytics.crashlytics().setUserID(userIdentifier)
//        Crashlytics.Crashlytics.setUserIdentifier(userIdentifier)
        print("reacher reacher1")


        if userData?.userType == 4{
            guard let child = userData?.childrens.filter({$0.admissionNo == self.user.childrens.first?.admissionNo}).first else { return }
            let children = Children(gender: child.gender, cycle: child.cycle, photo: child.photo, firstName: child.firstName, lastName: child.lastName, batchId: child.batchId, imperiumCode: child.imperiumCode, className: child.className, admissionNo: child.admissionNo, bdDate: child.bdDate, isBdChecked: child.isBdChecked)
            
            self.user = User(token: userData!.token,userName: self.user.userName, schoolId: self.schoolInfo.schoolId, firstName: child.firstName, lastName: child.lastName, userId: userData!.userId, email: userData!.email, googleToken: userData!.googleToken, gender: child.gender, cycle: child.cycle, photo: child.photo, userType: userData!.userType, batchId: child.batchId, imperiumCode: child.imperiumCode, className: child.className, childrens: [children], classes: [], privileges: userData!.privileges, firstLogin: userData!.firstLogin, admissionNo: child.admissionNo, bdDate: child.bdDate, isBdChecked: child.isBdChecked, blocked: userData!.blocked, password: userData!.password)
        }else{
            self.user = User(token: userData!.token, userName: userData!.userName, schoolId: self.schoolInfo.schoolId, firstName: userData!.firstName, lastName: userData!.lastName, userId: userData!.userId, email: userData!.email, googleToken: userData!.googleToken, gender: userData!.gender, cycle: userData!.cycle, photo: userData!.photo, userType: userData!.userType, batchId: userData!.batchId, imperiumCode: userData!.imperiumCode, className: userData!.className, childrens: userData!.childrens, classes: userData!.classes, privileges: userData!.privileges, firstLogin: userData!.firstLogin, admissionNo: userData!.admissionNo, bdDate: userData?.bdDate ?? Date(), isBdChecked: userData?.isBdChecked ?? false, blocked: userData!.blocked, password: userData!.password)
        }
        
//            if self.rememberMeButton.isToggled{
//                UserDefaults.standard.set(true, forKey: "REMEMBERME")
//            }
            let usersId = self.getUsersID()
            print("reacher reacher")
            print(usersId)
            if !usersId.contains(self.user.userId){
                if user.userType == 4{
                    for child in userData!.childrens{
                        let classEntity = NSEntityDescription.entity(forEntityName: "CLASS", in: self.managedContext)
                        let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                        childClass.batchId = Int64(child.batchId)
                        childClass.classname = child.className
                        childClass.imperiumCode = child.imperiumCode
                        
                        let userEntity = NSEntityDescription.entity(forEntityName: "USER", in: self.managedContext)
                        let newUser = NSManagedObject(entity: userEntity!, insertInto: self.managedContext)
                        newUser.setValue(child.batchId, forKey: "batchId")
                        newUser.setValue(child.className, forKey: "classname")
                        newUser.setValue(child.cycle, forKey: "cycle")
                        newUser.setValue(child.firstName, forKey: "firstName")
                        newUser.setValue(child.gender, forKey: "gender")
                        newUser.setValue(child.imperiumCode, forKey: "imperiumCode")
                        newUser.setValue(child.lastName, forKey: "lastName")
                        newUser.setValue(child.photo, forKey: "photo")
                        newUser.setValue(child.bdDate, forKey: "dob")
                        newUser.setValue(child.isBdChecked, forKey: "isBdChecked")
                        newUser.setValue(self.user.privileges, forKey: "privileges")
                        newUser.setValue(self.user.schoolId, forKey: "schoolId")
                        newUser.setValue(child.admissionNo, forKey: "studentUsername")
                        newUser.setValue(self.user.token, forKey: "token")
                        newUser.setValue(self.user.userId, forKey: "userId")
                        newUser.setValue(self.user.userName, forKey: "username")
                        newUser.setValue(self.user.userType, forKey: "userType")
                        newUser.setValue(self.user.blocked, forKey: "blocked")
                        newUser.setValue(self.user.password, forKey: "password")
                        newUser.setValue(NSOrderedSet(object: childClass), forKey: "classes")
                        do{
                            try self.managedContext.save()
                        }catch{}
                    }
                }else{
                    let classEntity = NSEntityDescription.entity(forEntityName: "CLASS", in: self.managedContext)
                    var classArray = [NSManagedObject]()
                    if self.user.userType == 2{
                        for classObject in self.user.classes{
                            let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                            childClass.batchId = Int64(classObject.batchId)
                            childClass.classname = classObject.className
                            childClass.imperiumCode = classObject.imperiumCode
                            classArray.append(childClass)
                        }
                    }else{
                        let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                        childClass.batchId = Int64(self.user.batchId)
                        childClass.classname = self.user.className
                        childClass.imperiumCode = self.user.imperiumCode
                        classArray.append(childClass)
                    }
                    let userEntity = NSEntityDescription.entity(forEntityName: "USER", in: self.managedContext)
                    let newUser = NSManagedObject(entity: userEntity!, insertInto: self.managedContext)
                    newUser.setValue(self.user.batchId, forKey: "batchId")
                    newUser.setValue(self.user.className, forKey: "classname")
                    newUser.setValue(self.user.cycle, forKey: "cycle")
                    newUser.setValue(self.user.firstName, forKey: "firstName")
                    newUser.setValue(self.user.gender, forKey: "gender")
                    newUser.setValue(self.user.imperiumCode, forKey: "imperiumCode")
                    newUser.setValue(self.user.lastName, forKey: "lastName")
                    newUser.setValue(self.user.photo, forKey: "photo")
                    newUser.setValue(self.user.privileges, forKey: "privileges")
                    newUser.setValue(self.user.schoolId, forKey: "schoolId")
                    newUser.setValue(self.user.admissionNo, forKey: "studentUsername")
                    newUser.setValue(self.user.token, forKey: "token")
                    newUser.setValue(self.user.userId, forKey: "userId")
                    newUser.setValue(self.user.userName, forKey: "username")
                    newUser.setValue(self.user.userType, forKey: "userType")
                    newUser.setValue(self.user.bdDate, forKey: "dob")
                    newUser.setValue(self.user.isBdChecked, forKey: "isBdChecked")
                    newUser.setValue(self.user.blocked, forKey: "blocked")
                    newUser.setValue(self.user.password, forKey: "password")
                    newUser.setValue(NSOrderedSet(array: classArray), forKey: "classes")
                    do{
                        try self.managedContext.save()
                    }catch{}
                }
            }else{
                let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
                let users = try? self.managedContext.fetch(userFetchRequest) as! [USER]
                if users != nil{
                    for object in users!{
                        if object.username == self.user.userName{
                            if self.user.userType == 4{
                                for child in self.user.childrens{
                                    if object.studentUsername == child.admissionNo{
                                        let classEntity = NSEntityDescription.entity(forEntityName: "CLASS", in: self.managedContext)
                                        let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                                        childClass.batchId = Int64(child.batchId)
                                        childClass.classname = child.className
                                        childClass.imperiumCode = child.imperiumCode
                                        
                                        object.setValue(child.batchId, forKey: "batchId")
                                        object.setValue(child.className, forKey: "classname")
                                        object.setValue(child.cycle, forKey: "cycle")
                                        object.setValue(child.firstName, forKey: "firstName")
                                        object.setValue(child.gender, forKey: "gender")
                                        object.setValue(child.imperiumCode, forKey: "imperiumCode")
                                        object.setValue(child.lastName, forKey: "lastName")
                                        object.setValue(child.photo, forKey: "photo")
                                        object.setValue(child.bdDate, forKey: "dob")
                                        object.setValue(child.isBdChecked, forKey: "isBdChecked")
                                        object.setValue(self.user.privileges, forKey: "privileges")
                                        object.setValue(self.schoolInfo.schoolId, forKey: "schoolId")
                                        object.setValue(child.admissionNo, forKey: "studentUsername")
                                        object.setValue(self.user.token, forKey: "token")
                                        object.setValue(self.user.userId, forKey: "userId")
                                        object.setValue(self.user.userName, forKey: "username")
                                        object.setValue(self.user.userType, forKey: "userType")
                                        object.setValue(self.user.blocked, forKey: "blocked")
                                        object.setValue(self.user.password, forKey: "password")
                                        object.setValue(NSOrderedSet(object: childClass), forKey: "classes")
                                        do{
                                            try self.managedContext.save()
                                        }catch{}
                                    }
                                }
                            }else{
                                let classEntity = NSEntityDescription.entity(forEntityName: "CLASS", in: self.managedContext)
                                var ChildArray = [NSManagedObject]()
                                if self.user.userType == 2{
                                    for classObject in self.user.classes{
                                        let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                                        childClass.batchId = Int64(classObject.batchId)
                                        childClass.classname = classObject.className
                                        childClass.imperiumCode = classObject.imperiumCode
                                        ChildArray.append(childClass)
                                    }
                                }else{
                                    let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                                    childClass.batchId = Int64(self.user.batchId)
                                    childClass.classname = self.user.className
                                    childClass.imperiumCode = self.user.imperiumCode
                                    ChildArray.append(childClass)
                                }
                                
                                object.setValue(self.user.batchId, forKey: "batchId")
                                object.setValue(self.user.className, forKey: "classname")
                                object.setValue(self.user.cycle, forKey: "cycle")
                                object.setValue(self.user.firstName, forKey: "firstName")
                                object.setValue(self.user.gender, forKey: "gender")
                                object.setValue(self.user.imperiumCode, forKey: "imperiumCode")
                                object.setValue(self.user.lastName, forKey: "lastName")
                                object.setValue(self.user.photo, forKey: "photo")
                                object.setValue(self.user.bdDate, forKey: "dob")
                                object.setValue(self.user.isBdChecked, forKey: "isBdChecked")
                                object.setValue(self.user.privileges, forKey: "privileges")
                                object.setValue(self.schoolInfo.schoolId, forKey: "schoolId")
                                object.setValue(self.user.admissionNo, forKey: "studentUsername")
                                object.setValue(self.user.token, forKey: "token")
                                object.setValue(self.user.userId, forKey: "userId")
                                object.setValue(self.user.userName, forKey: "username")
                                object.setValue(self.user.userType, forKey: "userType")
                                object.setValue(self.user.blocked, forKey: "blocked")
                                object.setValue(self.user.password, forKey: "password")
                                object.setValue(NSOrderedSet(array: ChildArray), forKey: "classes")
                            }
                        }
                    }
                }
            }
            do{
                try self.managedContext.save()
            }catch{}
            
//            self.saveSuggestions()
//            self.getTabBarIcons(schoolId: "\(self.schoolInfo!.id)", classId: self.user.batchId, code: self.user.imperiumCode, gender: self.user.gender)
//            self.setDeviceToken(user: self.user, deviceId: self.uuid, deviceToken: self.deviceToken ?? "")
        
    }
    
    
    /// Description:
    /// - Delete user's data from core data.
    func removeUser(){
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
        let users = try? managedContext.fetch(userFetchRequest) as! [USER]
        if users != nil{
            for object in users!{
                
                let username = object.username ?? ""
                let token = object.token ?? ""
                print("username: \(username)")
                print("token: \(token)")
                if(username == self.user.userName){
                    managedContext.delete(object)
                    Request.shared.removeDeviceToken(user: self.user, deviceId: self.uuid, deviceToken: self.deviceToken ?? "") {(message, data, status) in }
                }
                
                do{
                    try managedContext.save()
                }catch{}
            }
        }
    }
    
    /// Description: Get Pages
    /// - Request to GetPages API and get terms and conditions, privacy policy, help center and faq questions data.
    func getPages(){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.getPages() { (message, pagesData, status) in
            if status == 200{
                self.pages = pagesData!
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message!, actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
}

// MARK: - Handle TabBar Delegate Functions:
extension SettingsViewController: TabBarViewControllerDelegate{
    func changeUser(user: User, schoolInfo: SchoolActivation) {
        self.user = user
        self.schoolInfo = schoolInfo
    }
    
    func backToRoot() {
        self.navigationController?.popViewController(animated: true)
    }
}
