//
//  TabBarViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 6/28/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import CoreData


/// Description:
/// - Delegate from TabBar to Settings page.
protocol TabBarViewControllerDelegate{
    func changeUser(user: User, schoolInfo: SchoolActivation)
    func backToRoot()
}

/// Description:
/// - Delegate from TabBar to Notification page.
protocol TabBarToNotificationsDelegate{
    func changeNotificationsSettings(user: User)
    func changeNotificationsModule(section: String)
}

/// Description:
/// - Delegate from TabBar to Messages page.
protocol TabBarToMessagesDelegate{
    func changeMessagesSettings(user: User)
}

/// Description:
/// - Delegate from TabBar to Home page.
protocol TabBarToHomeDelegate{
    func backToRoot()
    func notificationPressed(sectionId: Int, date: String)
    func pushNotification(sectionId: Int)
}

/// Description:
/// - Delegate from TabBar to Birthday page.
protocol TabBarToBirthdayDelegate{
    func updateUser(user: User)
}

/// Description:
/// - Delegate from TabBar to HelpOverlay page.
protocol TabBarToHelpDelegate{
    func updateActiveModule(moduleID: Int, userType: Int)
}

class TabBarViewController: UIViewController {
    
    var tabController: AZTabBarController!
//    var icons = [UIImage]()
    var sIcons = [String]()
    var user: User!
    var schoolInfo: SchoolActivation!
    var loggedInUser: User!
//    var mainPageTheme: MainPageTheme!
//    var calendarTheme: CalendarTheme!
    var appTheme: AppTheme!
    var pages: Page!
    var delegate: TabBarViewControllerDelegate?
    var notificationDelegate: TabBarToNotificationsDelegate?
    var messagesDelegate: TabBarToMessagesDelegate?
    var homeDelegate: TabBarToHomeDelegate?
    var birthdayDelegate: TabBarToBirthdayDelegate?
    var helpDelegate: TabBarToHelpDelegate?
    var classId = 1
    var imperiumCode = ""
    var userArray: [User] = []
    var pushController: PushController?
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var count = 0
    
    var activeModuleID = 0
    var userType = 0
    var showMessagesTab = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPages()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        /// - This checking was added due to an update to core data. Old users should re-signin after update.
        let suggestedUsers = self.getSuggestions()
        print("user count: \(self.getSuggestions())")
        if !suggestedUsers.isEmpty{
            let modelVersion = UserDefaults.standard.integer(forKey: "VERSION")
            if let users = App.getLoggedInUsers(), modelVersion == App.dbVersion{
                for user in users{
                    print("users username: \(user.userName)")
                }
                self.userArray = users
            }else{
                _ = App.logout()
                print("showLoginPage1")
                App.showLoginPage()
                return
            }
        }else{
            _ = App.logout()
            print("showLoginPage2")
            App.showLoginPage()
            return
        }
        
        /// - If userArray is empty, users can't be found and should login again.
        /// - User is nil means that the app was closed and Remember me checked.
        /// - Call getTabBarIcons functions to get user icons and colors.
        if user == nil{
            if let firstUser = userArray.last{
                self.user = firstUser
                self.getUnreadMessages(user: self.user)
                print("getSchoolActivation5")

                self.schoolInfo = App.getSchoolActivation(schoolID: self.user.schoolId)
                if self.schoolInfo != nil{
                    self.getTabBarIcons(schoolId: "\(self.schoolInfo.id)", classId: self.classId, code: self.imperiumCode, gender: self.user.gender)
                }else{
                    _ = App.logout()
                    print("showLoginPage3")
                    App.showLoginPage()
                    return
                }
            }
            else{
                _ = App.logout()
                print("showLoginPage4")
                App.showLoginPage()
                return
            }
        }else{
            if appTheme != nil{
                initializeTabBar()
            }else{
                print("getSchoolActivation6")

                if let schoolObject = App.getSchoolActivation(schoolID: self.user.schoolId){
                    self.getTabBarIcons(schoolId: "\(schoolObject.id)", classId: self.classId, code: self.imperiumCode, gender: self.user.gender)
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /// - User can't be found. He need to login again:
        if self.user == nil{
            _ = App.logout()
            print("showLoginPage5")
            App.showLoginPage()
            return
        }
        /// - This is used to check if push notification available to open specific module:
        if let push = pushController{
            switch push{
            case .module(let moduleID):
                self.notificationPressed(moduleId: moduleID, date: "")
                self.pushController = nil
            }
        }
        
        /// - Check if user's birthday is today and not viewd to open Birthdau module:
        if App.birthdayFormatter.string(from: self.user.bdDate) == App.birthdayFormatter.string(from: Date()) && !self.user.isBdChecked{
            self.user.isBdChecked = true
            self.updateBirthdayData()
            let birthdayVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "BirthdayViewController") as! BirthdayViewController
            birthdayVC.user = self.user
            self.birthdayDelegate = birthdayVC.self
            let nav = UINavigationController(rootViewController: birthdayVC)
            nav.navigationBar.isTranslucent = false
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func getUnreadMessages(user: User) {
        Request.shared.getUnreadMessages(user: user) { (message, count, status) in
            if(status == 200){
                self.count = count ?? 0
            }
        }
    }
    
    /// Description:
    /// - This functiopn is used to update user's birthday into core data when he close Birthday page.
    func updateBirthdayData(){
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
        let users = try? self.managedContext.fetch(userFetchRequest) as! [USER]
        if users != nil{
            for object in users!{
                if object.username == self.user.userName{
                    if self.user.userType == 4{
                        for child in self.user.childrens{
                            if object.studentUsername == child.admissionNo{
                                object.setValue(true, forKey: "isBdChecked")
                            }
                        }
                    }else{
                        object.setValue(self.user.isBdChecked, forKey: "isBdChecked")
                    }
                    do{
                        try self.managedContext.save()
                    }catch{}
                }
            }
        }
    }
    
    /// Description:
    /// - Fetch users username data from core data.
    func getSuggestions() -> [String]{
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SUGGESTION")
        let users = try? managedContext.fetch(userFetchRequest) as! [SUGGESTION]
        var array: [String] = []
        if users != nil{
            for user in users!{
                array.append(user.username!)
            }
        }
        return array
    }
    
    /// Description:
    /// - Fetch schools data from core data.
    /// - Find the current selected school data from the schoold id saved into userDefaults.
    func getSchoolInfo(){
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
        let school = try? managedContext.fetch(schoolFetchRequest) as! [SCHOOL]
        let schoolId = self.user.schoolId
        if school != nil{
            for object in school! {
                if object.schoolId == schoolId{
                    schoolInfo = SchoolActivation(id: Int(object.id), logo: object.logo!, schoolURL: object.url!, schoolId: object.schoolId!, name: object.name!, website: object.website!, location: object.location!, lat: object.lat, long: object.long, facebook: object.facebook!, twitter: object.twitter!, linkedIn: object.linkedIn!, google: object.google!, instagram: object.instagram!, phone: object.phone!, code: object.code!)
                    UserDefaults.standard.set(self.schoolInfo.schoolURL, forKey: "BASEURL")
                }
            }
        }
    }
    
    // update school url
    func getSchoolUrl(activationCode: String){
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
            if !schoolIds.contains(schoolData.id){
                let schoolEntity = NSEntityDescription.entity(forEntityName: "SCHOOL", in: managedContext)
                let newSchool = NSManagedObject(entity: schoolEntity!, insertInto: managedContext)
                print("new school new2: \(schoolData)")

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
        
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "ERROR2".localiz(), message: message ?? "", actions: [ok])
        }
        if let viewWithTag = self.view.viewWithTag(100){
            viewWithTag.removeFromSuperview()
        }
    }
    }
    

    /// Description:
    /// - Call initTabBarIcon function to update the tab bar icons.
    /// - Setup the needed controllers into AZTabBar.
    ///
    func initializeTabBar(){
        initTabBarIcon()
        self.userType = self.user.userType
        
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let home = UINavigationController(rootViewController: homeVC)
        homeVC.user = self.user
        homeVC.schoolInfo = self.schoolInfo
        homeVC.appTheme = self.appTheme
        homeVC.homeDelegate = self
        if self.loggedInUser != nil{
            homeVC.loggedInUser = self.loggedInUser
        }
        self.homeDelegate = homeVC.self
        home.navigationBar.isTranslucent = false
        
        let messageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
        let message = UINavigationController(rootViewController: messageVC)
        messageVC.user = self.user
        self.messagesDelegate = messageVC.self
        
        message.navigationBar.isTranslucent = false
        
        let notificationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        let notification = UINavigationController(rootViewController: notificationVC)
        notificationVC.user = self.user
        self.notificationDelegate = notificationVC.self
        notificationVC.delegate = self
        notification.navigationBar.isTranslucent = false
        

        
        
        let settingsVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        let settings = UINavigationController(rootViewController: settingsVC)
        settingsVC.pages = self.pages
        settingsVC.schoolInfo = self.schoolInfo
        settingsVC.userArray = self.userArray
        settingsVC.user = self.user
        self.delegate = settingsVC.self
        settings.navigationBar.isTranslucent = false
        
        let helpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
        let help = UINavigationController(rootViewController: helpVC)
        helpVC.userType = self.userType
        helpVC.moduleID = self.activeModuleID
        self.helpDelegate = helpVC.self
        help.navigationBar.isTranslucent = false

        var icons = [String]()
        if showMessagesTab {
            icons.append("tab-item-1")
            icons.append("tab-item-2")
            icons.append("tab-item-3")
            icons.append("tab-item-4")
            icons.append("tab-item-5")
        }else{
            icons.append("tab-item-1")
            icons.append("tab-item-3")
            icons.append("tab-item-4")
            icons.append("tab-item-5")
        }
        
        tabController = AZTabBarController.insert(into: self, withTabIconNames: icons, andSelectedIconNames: icons)
        tabController.delegate = self
        
        //remove this temporarly
        if showMessagesTab {
            tabController.setViewController(home, atIndex: 0)
            tabController.setViewController(message, atIndex: 1)
            tabController.setViewController(notification, atIndex: 2)
            tabController.setViewController(settings, atIndex: 3)
            tabController.setViewController(help, atIndex: 4)
        }else{
            tabController.setViewController(home, atIndex: 0)
            tabController.setViewController(notification, atIndex: 1)
            tabController.setViewController(settings, atIndex: 2)
            tabController.setViewController(help, atIndex: 3)
        }
        
        tabController.buttonsBackgroundColor = .clear
        tabController.ignoreIconColors = true
    }
    
    
    // Function to add badge to a tab item
   
    
    /// Description:
    /// - This function is used to update tab bar icons array retuned from "Get Class Icons" API.
    func initTabBarIcon(){
        sIcons = []
    }

}

extension TabBarViewController: AZTabBarDelegate{
    /// Description:
    /// - If a module is active and user select home tab it will back to home page.
    /// - If a setting page is active and the user select settings icon it will back to settings page.
    /// - Change the alpha to the selected tab.
    func tabBar(_ tabBar: AZTabBarController, didSelectTabAtIndex index: Int) {
        switch index{
        case 0:
            if self.tabController.selectedIndex == index{
                homeDelegate?.backToRoot()
            }
        case 2:
            self.notificationDelegate?.changeNotificationsModule(section: "All")
        default:
            break
        }
        
        for button in tabBar.buttons{
            button.alpha = 0.5
        }
        tabBar.buttons[index].alpha = 1
    }
}


// MARK: - API Calls:
extension TabBarViewController{
    
    /// Description: Get Class Icons
    /// - Call getClassIcons API to get icons and colors of the selected schoold and class.
    /// - Call initializeTabBar function that set tab bar icons on success.
    func getTabBarIcons(schoolId: String, classId: Int, code: String, gender: String){
        Request.shared.GetClassIcons(user: self.user, schoolID: schoolId, classID: classId, code: code, gender: gender) { (message,data,status) in
            if status == 200{
                self.appTheme = data
                print("app app theme3: \(self.appTheme)")

                self.initializeTabBar()
            } else{
                print("entered entered entered")
                print(message)
                print(data)
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR3".localiz(), message: message!, actions: [ok])
            }
        }
    }
    
    /// Description: Get Pages
    /// - Request to GetPages API and get terms and conditions, privacy policy, help center and faq questions data.
    func getPages(){
        Request.shared.getPages() { (message, pagesData, status) in
//            indicatorView.removeFromSuperview()
            if status == 200{
                self.pages = pagesData!
            }else{
//                // Create the alert controller
//                let alertController = UIAlertController(title: "Error4", message: "Could not reach server", preferredStyle: .alert)
//
//                // Create the actions
//                let okAction = UIAlertAction(title: "Retry", style: UIAlertAction.Style.default) {
//                    UIAlertAction in
//                    self.getPages()
//                }
//
//                // Add the actions
//                alertController.addAction(okAction)
//
//                // Present the controller
//                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension TabBarViewController: HomeVCDelegate, NotificationsViewControllerDelegate{
    /// Description:
    /// - This function is called from Home page after changing the active module or go back from modules page to home page.
    /// - This function call updateActiveModule function that update the user info and module id of Help overlay page.
    func updateSectionID(sectionID: Int, userType: Int) {
        self.activeModuleID = sectionID
        self.userType = userType
        self.helpDelegate?.updateActiveModule(moduleID: self.activeModuleID, userType: self.userType)
    }
    
    /// Description:
    /// - This function is called from Home page after changing the selected user and get his icons and colors from Get Class Icons API.
    /// - Update appTheme variable.
    /// - Setup tab bar icons.
    func changeUser(user: User, schoolInfo: SchoolActivation) {
        self.user = user
        self.getUnreadMessages(user: self.user)
        self.schoolInfo = schoolInfo
        self.delegate?.changeUser(user: self.user, schoolInfo: schoolInfo)
        self.notificationDelegate?.changeNotificationsSettings(user: self.user)
        self.messagesDelegate?.changeMessagesSettings(user: self.user)
        self.birthdayDelegate?.updateUser(user: self.user)
    }
    
    /// Description:
    /// - This function is called from Home page after the request from Get Class Icons API arrived.
    /// - Update appTheme variable.
    /// - Setup tab bar icons.
    func updateTabBarIcon(theme: AppTheme) {
        self.appTheme = theme
    }
    
    func goToNotifications(module: Int){
        /*
         static var calendarID = 2
         static var attendanceID = 8
         static var agendaID = 3
         static var remarksID = 9
         static var gradesID = 5
         static var timeTableID = 10
         */
        var sectionString = ""
        switch module{
            case 2:
                sectionString = "Calendar"
                break
            case 8:
                sectionString = "Attendance"
                break
            case 3:
                sectionString = "Agenda"
                break
            case 9:
                sectionString = "Remarks"
                break
            case 5:
                sectionString = "Grades"
                break
            case 6:
                sectionString = "Messages"
                break
            case 10:
                sectionString = "Timetable"
                break
            case 15:
            sectionString = "Blended Learning"
            break
            
            default:
                sectionString = "Calendar"
                break
        }

        self.notificationDelegate?.changeNotificationsModule(section: sectionString)
        self.tabController.setIndex(2)
        
    }
    
    /// Description:
    /// - This function is called from Notification page.
    /// - Go to Home Page wich is the first tab bar index.
    /// - Open specific model based on the selected module id.
    func notificationPressed(moduleId: Int, date: String) {
        if(tabController != nil){
            if moduleId == App.NotiInternalMessages {
                self.tabController.setIndex(1)
            }else{
                self.tabController.setIndex(0)
                self.homeDelegate?.notificationPressed(sectionId: moduleId, date: date)
            }
        }
    }
    
    /// Description:
    /// - This function is called to open a specific module when handle a notification.
    func pushNotification(moduleId: Int){
        self.homeDelegate?.pushNotification(sectionId: moduleId)
    }
    
}
