//
//  HomeVC.swift
//  Madrasati
//
//  Created by Tarek on 5/7/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
//import SwiftyAttributes
import LNICoverFlowLayout
import SDWebImage
import ActionSheetPicker_3_0
import CoreData
import Firebase

/// Description:
/// - Delegate from Home page to TabBar.
protocol HomeVCDelegate{
    func changeUser(user: User, schoolInfo: SchoolActivation)
    func goToNotifications(module: Int)
    func updateTabBarIcon(theme: AppTheme)
    func updateSectionID(sectionID: Int, userType: Int)
}

class HomeVC: UIViewController {

    @IBOutlet weak var colored_view: UIView!
    @IBOutlet weak var shadow_view: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bt_viewMore: RoundedButton!
    @IBOutlet weak var lbl_class: UILabel!
    @IBOutlet weak var middleProfilePicture: RoundedImageWithBorder!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var studentIconsCollectionView: UICollectionView!
    @IBOutlet weak var coverFlowLayout: LNICoverFlowLayout!
    @IBOutlet weak var schoolLogo: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var classDropDownImageView: UIImageView!
    @IBOutlet weak var branchName: UILabel!
    @IBOutlet weak var classButton: UIButton!
    

    
    var sectionCalendar: [Class] = []
    var sectionAgenda: [Class] = []
    var sectionTimetable: [Class] = []

    var sectionGrades: [Class] = []
    var sectionAttendace: [Class] = []
    var sectionRemarks: [Class] = []
    //added
    var sectionFees: [Class] = []
    var sectionGallery: [Class] = []
    var sectionTeams: [Class] = []
    var sectionVirtual: [Class] = []
    var sectionBlendedLearning: [Class] = []
    var sectionAssessment: [Class] = []
    
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")

    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
//    var sections = ["Calendar","Attendance","Agenda","Remarks","Grades"]
    var sections: [Sections] = []
    var studentsArray: [String] = ["profile_picture", "small-profile-1", "small-profile-2", "small-profile-1", "small-profile-2", "small-profile-1", "small-profile-2", "small-profile-1", "small-profile-2", "small-profile-1", "small-profile-2"]
    var user: User!
    var child: Children!
    var userIndex = IndexPath(row: 0, section: 0)
    var classIndex = 0
    var schoolInfo: SchoolActivation!
    var userArray: [User] = []
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var deviceToken = UserDefaults.standard.string(forKey: "DEVICETOKEN")
    let uuid = NSUUID().uuidString.lowercased()
    var homeDelegate: HomeVCDelegate?
//    var batchId = 1
//    var imperiumCode = ""
    var currentClass = Class(batchId: 1, className: "", imperiumCode: "")
    var appTheme: AppTheme!
    var studentOffset = CGFloat(0)
    var loggedInUser: User?
    var allClasses: [Class] = []
    var currentUsersCollectionViewOffset = CGPoint(x: 0, y: 0)
    let authenticator = BiometricAuthentication()
    var pushController: PushController?
    var activeModule = 0
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        self.updateUserDetails(user: self.user)
        self.homeDelegate?.updateSectionID(sectionID: 0, userType: self.user.userType)
        print("getSchoolActivation1: \(userArray.count)")
        self.schoolInfo = App.getSchoolActivation(schoolID: self.user.schoolId)
        customizeView()
        
        let modelVersion = UserDefaults.standard.integer(forKey: "VERSION")

        if let users = App.getLoggedInUsers(), modelVersion == App.dbVersion{
            self.userArray = users
            self.userArray.reverse()
        }else{
            _ = App.logout()
            print("showLoginPage6")
            App.showLoginPage()
            return
        }
        
        if userArray.count == 1{
            middleProfilePicture.isHidden = false
        }else{
            middleProfilePicture.isHidden = true
        }
        AppstoreReviewHandler().tryToGetAppstoreReview()
//        self.branchName.text = schoolInfo.name ?? ""
        self.branchName.isHidden = true
        print("momo \(baseURL)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let modelVersion = UserDefaults.standard.integer(forKey: "VERSION")

        if let users = App.getLoggedInUsers(), modelVersion == App.dbVersion{
            self.userArray = users
            self.userArray.reverse()
        }else{
            _ = App.logout()
            print("showLoginPage6")
            App.showLoginPage()
            return
        }
        
        print("current user", self.user.userName, " ", self.user.firstName)
//        self.recursiveLogin()

        
        //reset form safe
        SectionVC.canChange = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if self.user.userType == 2 || self.user.userType == 1{
            self.getSections(user: self.user)
        }
        self.getNotifications()
    }
    
    func recursiveLogin() {
        // Perform your desired tasks here
        print("Function called at \(Date())")
        
        for us in self.userArray{
            
            self.SignIn(userName: us.userName, password: us.password, schoolUrl: self.schoolInfo.schoolURL, grantType: "password")

        }


        // Schedule the function to be called again after 12 hours (43200 seconds)
//        DispatchQueue.main.async {
//            DispatchQueue.global().asyncAfter(deadline: .now() + 20 * 60 * 60) {
//                self.recursiveLogin()
//            }
//        }
    }
    
    
    func getNotifications(){
        if self.appTheme != nil && self.user != nil{
            switch self.user.userType{
            case 1,2:
                self.getNotificationCount(user: self.user, studentUsername: "", appTheme: self.appTheme)
            case 3:
                self.getNotificationCount(user: self.user, studentUsername: self.user.userName, appTheme: self.appTheme)
            case 4:
                self.getNotificationCount(user: self.user, studentUsername: self.user.admissionNo, appTheme: self.appTheme)
            default:
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //allow refresh again for modules
        SectionVC.didLoadGrades = false
        SectionVC.didLoadAgenda = false
        SectionVC.didLoadRemarks = false
        SectionVC.didLoadCalendar = false
        SectionVC.didLoadAttandance = false
        //added
        SectionVC.didLoadFees = false
        SectionVC.didLoadGallery = false
        SectionVC.didLoadTeams = false
        SectionVC.didLoadVirtual = false
        SectionVC.didLoadBlended = false
        
    
        
        
        
        
        
        UIApplication.shared.keyWindow?.viewWithTag(1500)?.removeFromSuperview()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        coverFlowLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        coverFlowLayout.itemSize = CGSize(width: 90, height: 90)
        
        coverFlowLayout.maxCoverDegree = 0
        coverFlowLayout.coverDensity = 0.06
        coverFlowLayout.minCoverScale = 0.63
        coverFlowLayout.minCoverOpacity = 1
        
        studentIconsCollectionView.setNeedsLayout()
        studentIconsCollectionView.layoutIfNeeded()
        studentIconsCollectionView.reloadData()
    }
    
    /// Description:
    /// - This function is used to center the middle item by calculate the collection view offset.
    func selectStudent(){
        var width = CGFloat(0)
        if self.view.frame.width == 414{
            width = studentIconsCollectionView.collectionViewLayout.collectionViewContentSize.width / CGFloat(studentIconsCollectionView.numberOfItems(inSection: self.userIndex.section)) + 40
        }else{
            width = studentIconsCollectionView.collectionViewLayout.collectionViewContentSize.width / CGFloat(studentIconsCollectionView.numberOfItems(inSection: self.userIndex.section))
        }
        let resultingOffset = (width * CGFloat(self.userIndex.row))
        DispatchQueue.main.async {
            self.studentIconsCollectionView.setContentOffset(CGPoint(x: resultingOffset, y: 0), animated: true)
        }
        self.user = self.userArray[self.userIndex.row]
        self.getUserDetail(user: self.user)
        studentIconsCollectionView.reloadData()
        self.currentUsersCollectionViewOffset = CGPoint(x: resultingOffset, y: 0)
    }
//

    func SignIn(userName: String, password: String, schoolUrl: String, grantType: String){
        
        
        
        Request.shared.SignIn(userName: userName, password: password, schoolUrl: schoolUrl, grantType: grantType) { (message, userData, status) in
            if status == 200{
                
                let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

                // Step 1: Fetch the user you want to update
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")


                do {
                    if let users = try managedContext.fetch(fetchRequest) as? [USER] {
                            if users != nil{
                                for user in users{
                                    let idd = user.integer(forKey: "userId")
                                    
                                    print("idd: \(userName)")
                                    print("userId: \(user.username)")
                                    print("token: \(userData!.token)")
                                    if(userName == user.username){
                                        user.token = userData!.token
                                    }
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
                
//                if grantType == "nopassword"{
//                    self.getPhoneAndEmail(userName: userName, user: self.user)
//                }else{
//                    self.saveUser(userData: userData)
//                }
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            
        }
    }
    
    func updateUserDetails(id: Int, token: String, schoolUrl: String, password: String){
            
    
        Request.shared.getUserDetails(id: id, token: token, schoolUrl: schoolUrl, password: password, completion: { (message, userData, status) in
                if status == 200{
                    print("entered updateUserDetails")
                    print(userData)
                    self.user = userData
                    self.saveUser(userData: userData)
                    self.customizeView()
                    print("user user1: \(self.user)")

                    /// modelVersion variable is the core data model version, used to check if the core data model has been changed to delete users data and resign in again.
                  
    
                  
                }
               
            })
        }
    
    /// Description: Get Sections
    /// - Get all classes data.
    func getSections(user: User){
        Request.shared.getSectionsPerModule(user: user) { (message, sectionData, status) in
            if status == 200{
                self.sectionCalendar.removeAll()
                self.sectionAgenda.removeAll()
                self.sectionTimetable.removeAll()
                self.sectionGrades.removeAll()
                self.sectionAttendace.removeAll()
                self.sectionRemarks.removeAll()
                self.sectionFees.removeAll()
                self.sectionBlendedLearning.removeAll()
                for section in sectionData!{
                    let classIn = Class.init(batchId: section.batchId, className: section.displayName, imperiumCode: section.imperiumCode)
                    switch section.module{
                    case 1://calendar
                        self.sectionCalendar.append(classIn)
                    case 2://attendance
                        self.sectionAttendace.append(classIn)
                    case 3://agenda
                        self.sectionAgenda.append(classIn)
                        self.sectionBlendedLearning.append(classIn)
                    case 4://remarks
                        self.sectionRemarks.append(classIn)
                    case 6://timetable
                        self.sectionTimetable.append(classIn)
                    case 5://grades
                        self.sectionGrades.append(classIn)
                    default:
                        print("entered calendarmode")
                        self.sectionCalendar.append(classIn)
                    }
                    
                }
                //added
//                let classIn = Class.init(batchId: 98, className: "Fees", imperiumCode: "0")
//                self.sectionFees.append(classIn)
//
//                let galleryClass = Class.init(batchId: 97, className: "Gallery", imperiumCode: "-1")
//                self.sectionGallery.append(galleryClass)
//
//                let teamsClass = Class.init(batchId: 96, className: "Microsoft Teams", imperiumCode: "-2")
//                self.sectionTeams.append(teamsClass)
//
//                let virtualClass = Class.init(batchId: 95, className: "VirtualClassroom", imperiumCode: "-3")
//                self.sectionVirtual.append(virtualClass)
//
//                let blendedClass = Class.init(batchId: 94, className: "Blended Learning", imperiumCode: "-4")
//                self.sectionBlendedLearning.append(blendedClass)
                
            }
        }
    }
    
    /// Description:
    /// - This function is used to initialize home page sections.
    /// - Set module colors and icons returned from GetClassIcons API.
    /// - Set default modules icons if it wasn't returned from GetClassIcons API.
    func initSections(){
//        var sectionObject = Sections(image: "calendar-home", title: "Calendar", counter: "", color: "#06c6b3")
//        sections.append(sectionObject)
//
//        sectionObject = Sections(image: "attendance-home", title: "Attendance", counter: "", color: "#ff5955")
//        sections.append(sectionObject)
        print("module_id: \(self.appTheme.activeModule)")

        if appTheme != nil{
            sections = []
            
            var sectionObject: Sections!
            print("module_id: \(self.appTheme.activeModule)")

            for module in self.appTheme.activeModule{
                print("module_id: \(App.agendaID)")
                switch module.id{
                case App.calendarID:
                    let calendarIcon = appTheme.homePage.calendarIcon
                    
                    sectionObject = Sections(id: App.calendarID, image: calendarIcon, title: "Calendar".localiz(), counter: "\(appTheme.calendarTheme.notificationCount)", color: appTheme.homePage.calendarBg)
                    sections.append(sectionObject)
                case App.agendaID:
                    let agendaIcon = appTheme.homePage.agendaIcon
                   
                    sectionObject = Sections(id: App.agendaID,image: agendaIcon, title: "Agenda".localiz(), counter: "\(appTheme.agendaTheme.notificationCount)", color: appTheme.homePage.agendaBg)
                    sections.append(sectionObject)
                case App.gradesID:
                    let gradeIcon = appTheme.homePage.gradeIcon
                  
                    sectionObject = Sections(id: App.gradesID, image: gradeIcon, title: "Grades".localiz(), counter: "\(appTheme.gradesTheme.notificationCount)", color: appTheme.homePage.gradeBg)
                    sections.append(sectionObject)
                case App.attendanceID:
                    let attendanceIcon = appTheme.homePage.attendanceIcon
                   
                    sectionObject = Sections(id: App.attendanceID, image: attendanceIcon, title: "Attendance".localiz(), counter: "\(appTheme.attendanceTheme.notificationCount)", color: appTheme.homePage.attendanceBg)
                    sections.append(sectionObject)
                case App.remarksID:
                    let remarkIcon = appTheme.homePage.remarkIcon
                  
                    sectionObject = Sections(id: App.remarksID,image: remarkIcon, title: "Behavior".localiz(), counter: "\(appTheme.remarkTheme.notificationCount)", color: appTheme.homePage.remarkBg)
                    sections.append(sectionObject)
                    
                case App.gclassID:
                    let gclassIcon = appTheme.homePage.gclassIcon
                     
                    
                     let sectionObject = Sections(id: App.gclassID, image: gclassIcon, title: "Google Classroom".localiz(), counter:  "0", color: appTheme.homePage.gclassBg)
                     sections.append(sectionObject)
                    break;
                    
                case App.timeTableID:
                    let timeTableIcon = appTheme.homePage.timeTableIcon
                    
                    
                    sectionObject = Sections(id: App.timeTableID,image: timeTableIcon, title: "Timetable".localiz(), counter: "\(appTheme.timeTableNotificationCount)", color: appTheme.homePage.timeTableBg)
                    sections.append(sectionObject)
                    break;
                    
                //added
                case App.feesId:
                    let feesIcon = appTheme.homePage.feesIcon
                        let feesObject = Sections(id: App.feesId, image: feesIcon, title: "Fees".localiz(), counter: "0", color: appTheme.homePage.feesBg)
                        sections.append(feesObject)
                    break;
                    
                case App.galleryId:
                    let galleryIcon = appTheme.homePage.galleryIcon
                    let galleryObject = Sections(id: App.galleryId, image: galleryIcon, title: "Gallery", counter: "0", color: appTheme.homePage.galleryBg)
                    sections.append(galleryObject)
                    break;
                    
                case App.teamsId:
                    let teamsIcon = appTheme.homePage.teamsIcon
                    let teamsObject = Sections(id: App.teamsId, image: teamsIcon, title: "Microsoft Teams", counter: "0", color: appTheme.homePage.teamsBg)
                    sections.append(teamsObject)
                    break;
                    
                case App.virtualClassroomId:
                    let virtualIcon = appTheme.homePage.virtualIcon
                    let virtualObject = Sections(id: App.virtualClassroomId, image: virtualIcon, title: "Virtual Classroom", counter: "0",
                                                 color: appTheme.homePage.virtualBg)
                    sections.append(virtualObject)
                    break
                    
                case App.blendedLearningId:
                        let blendedIcon = appTheme.homePage.blendedIcon
                        let blendedObject = Sections(id: App.blendedLearningId, image: blendedIcon, title: "Blended Learning", counter: "0",
                                                     color: appTheme.homePage.blendedBg)
                        sections.append(blendedObject)
                    
                    break;
                case App.assessmentId:
                    let assessmentIcon = appTheme.homePage.assessmentIcon
                    let assessmentObject = Sections(id: App.assessmentId, image: assessmentIcon, title: "Assessment", counter: appTheme.activeModule.first(where: {$0.id == App.assessmentId})?.link ?? "",
                                                 color: appTheme.homePage.assessmentBg)
                    sections.append(assessmentObject)
                    
                    break;
                    

                default:
                    break
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func initView(){
        studentIconsCollectionView.delegate = self
        studentIconsCollectionView.dataSource = self
        studentIconsCollectionView.layer.zPosition = 1
        nameLabel.layer.zPosition = 3
        collectionView.delegate = self
        collectionView.dataSource = self
        
        shadow_view.dropShadow()
        colored_view.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
//        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
//        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    func customizeView() {
        let url = URL(string: schoolInfo?.logo ?? "")
        App.addImageLoader(imageView: self.schoolLogo, button: nil)
        self.schoolLogo.sd_setImage(with: url) { (image, error, chache, url) in
            App.removeImageLoader(imageView: self.schoolLogo, button: nil)
        }
        studentIconsCollectionView.reloadData()
        self.switchStudent()
    }
    
    /// Description:
    /// - If a single user is logged in, hide the collection and show an imageView.
    /// - In case the user don't have a profile picture, add the default gender icon returned from GetClassIcons API.
    /// - Configure class label and picker based on the user type.
    /// - Call updateSectionID in TabBar in order to update the user info and module id of Help overlay page.
    func switchStudent(){
        var studentClass = ""
        if userArray.count == 1{
            studentIconsCollectionView.isHidden = true
            middleProfilePicture.isHidden = false

            var icon = user.photo.unescaped
    
            
            
            if user.photo.unescaped != "" {
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased() == "m"){
                        middleProfilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_boy"))
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.4901960784, green: 0.6588235294, blue: 0.4078431373, alpha: 1)
                    }
                    else{
                        middleProfilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_girl"))
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.3411764706, blue: 0.3254901961, alpha: 1)
                    }
                }
                else if user.userType == 4{
                    if(user.gender.lowercased() == "m"){
                        middleProfilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                    else{
                        middleProfilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                }
                else{
                    if(user.gender.lowercased() == "m"){
                        middleProfilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.4901960784, blue: 0.8392156863, alpha: 1)
                    }
                    else{
                        middleProfilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.968627451, green: 0.3725490196, blue: 0.7882352941, alpha: 1)
                    }
                }
            }else{
                
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased() == "m"){
                        middleProfilePicture.image = UIImage(named: "teacher_boy")
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.4901960784, green: 0.6588235294, blue: 0.4078431373, alpha: 1)
                    }
                    else{
                        middleProfilePicture.image = UIImage(named: "teacher_girl")
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.3411764706, blue: 0.3254901961, alpha: 1)
                    }
                }
                else if user.userType == 4{
                    if(user.gender.lowercased() == "m"){
                        middleProfilePicture.image = UIImage(named: "student_boy")
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                    else{
                        middleProfilePicture.image = UIImage(named: "student_girl")
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                }
                else{
                    if(user.gender.lowercased() == "m"){
                        middleProfilePicture.image = UIImage(named: "student_boy")
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.4901960784, blue: 0.8392156863, alpha: 1)
                    }
                    else{
                        middleProfilePicture.image = UIImage(named: "student_girl")
                        middleProfilePicture.layer.borderColor = #colorLiteral(red: 0.968627451, green: 0.3725490196, blue: 0.7882352941, alpha: 1)
                    }
                }
            }
        }else{
            studentIconsCollectionView.isHidden = false
            middleProfilePicture.isHidden = true
        }
        switch self.user.userType{
        case 1, 2:
            classDropDownImageView.isHidden = true
            classButton.isHidden = true
            print("classindex7")
            self.classIndex = 0
            self.currentClass = user.classes.first ?? Class(batchId: 1, className: "", imperiumCode: "")
            studentClass = self.currentClass.className
//            if studentClass.isEmpty{
//                classDropDownImageView.isHidden = true
//            }
            nameLabel.text = user.firstName
            lbl_class.text = studentClass
            lbl_class.isHidden = true
        case 3:
            print("student student: \(self.currentClass)")
            print("student student: \(user.classes)")

            classDropDownImageView.isHidden = true
            classButton.isHidden = false
            self.currentClass = user.classes.first ?? Class(batchId: 1, className: "", imperiumCode: "")
            nameLabel.text = user.firstName
            lbl_class.text = self.currentClass.className
            lbl_class.isHidden = false
        case 4:
            
            print("parent parent::: \(self.currentClass)")
            print("parent parent1::: \(user)")

            classDropDownImageView.isHidden = true
            classButton.isHidden = false
            self.currentClass = user.classes.first ?? Class(batchId: 1, className: "", imperiumCode: "")
            print("parent parent::: \(self.currentClass)")

            nameLabel.text = user.firstName
            if(self.currentClass != nil && self.currentClass.batchId != nil && self.currentClass.batchId != 1){
                lbl_class.text = self.currentClass.className

            }
            lbl_class.isHidden = false
        default:
            break
        }
        
        self.homeDelegate?.updateSectionID(sectionID: self.activeModule, userType: self.user.userType)
    }
    
    @IBAction func schoolLogoPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        aboutVC.info = self.schoolInfo
        aboutVC.schoolName = self.schoolInfo.name
        self.show(aboutVC, sender: self)
    }
    
    @IBAction func bt_viewMoreWasPressed(_ sender: Any) {
        //bt_viewMore.alpha = 0
    }
    
    /// Description:
    /// - Update employee class info from picker.
    /// - Get colors and icons for the selected class.
    @IBAction func classButtonPressed(_ sender: Any) {
        if user.userType == 2 || user.userType == 1{
            var classArray: [String] = []
            for classIn in user.classes{
                classArray.append(classIn.className)
            }
            
            print("classArray123: \(classArray)")
//            classArray = self.allClasses.map({$0.className})
            ActionSheetStringPicker.show(withTitle: "Choose Class:".localiz(), rows: classArray, initialSelection: classIndex, doneBlock: {
                picker, ind, values in
                
                if self.user.classes.isEmpty{
                    self.lbl_class.text = ""
                }else{
                    print("classindex8")
                    self.classIndex = ind
                    let classIn = self.user.classes[ind]
                    self.lbl_class.text = classIn.className
                    
//                    self.getTabBarIcons(schoolId: "\(self.schoolInfo!.id)", classId: classIn.batchId, code: classIn.imperiumCode, gender: self.user.gender)
                }
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        }
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView{
        case self.collectionView:
            return sections.count
        default:
            return self.userArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("maher2: \(collectionView)")
        switch collectionView{
        case self.collectionView:
            let padding: CGFloat = 0
            let collectionViewSize = collectionView.frame.size.width - padding
            return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
        default:
            return CGSize(width: 90, height: 90)
        }
    }
    
    @objc func notiNumPressed(sender: UIButton){
        let module_id = sender.tag
        self.homeDelegate?.goToNotifications(module: module_id)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView{
        case self.collectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionCell", for: indexPath) as? SectionCell
            let section = sections[indexPath.row]
            if Locale.current.languageCode == "hy" {
                cell?.lbl_title.font = cell?.lbl_title.font.withSize(15)
            }else{
                cell?.lbl_title.font = cell?.lbl_title.font.withSize(18)
            }
            cell?.lbl_title.text = section.title
            print("maher3 section: \(section.image)")

//            if section.image.contains("http"){
//                let url = URL(string: section.image)
//                App.addImageLoader(imageView: cell?.img_icon, button: nil)
//                cell?.img_icon!.sd_setImage(with: url, completed: { (image, error, cache, url) in
//                    App.removeImageLoader(imageView: cell?.img_icon, button: nil)
//                })
//            }else{
                cell?.img_icon.image = UIImage(named: section.image)
//            }
            
            cell?.triangle_view.triangleColor = App.hexStringToUIColor(hex: section.color, alpha: 1.0)
            cell?.lbl_number.setTitle(section.counter,for: .normal)
            cell?.lbl_number.tag = section.id
            cell?.lbl_number.addTarget(self, action: #selector(notiNumPressed), for: .touchUpInside)
            
            cell?.notificationView.backgroundColor = App.hexStringToUIColor(hex: section.color, alpha: 1.0)
            
            if section.counter == "0"{
                cell?.notificationView.isHidden = true
            }else{
                cell?.notificationView.isHidden = false
            }
            
            /// Check for Active/Inactive Modules:
            var activeModules: [Int] = []
            for module in appTheme.activeModule{
                print("module status: \(module)")
                if module.status == 1{
                    activeModules.append(module.id)
                }
            }
            
            if activeModules.contains(section.id){
//                if self.user.userType == 2 && !self.user.privileges.contains("student_attendance_view_privilege") && section.id == 8{
//                    cell?.img_icon.alpha = 0.3
//                    cell?.triangle_view.alpha = 0.3
//                    cell?.isUserInteractionEnabled = false
//                }else{
                    cell?.img_icon.alpha = 1
                    cell?.triangle_view.alpha = 1
//                    cell?.isUserInteractionEnabled = true
//                }
            }else{
                cell?.img_icon.alpha = 0.3
                cell?.triangle_view.alpha = 0.3
//                cell?.isUserInteractionEnabled = false
            }
            // Timetable Item:
//            if section.id == 10{
//                cell?.img_icon.alpha = 1
//                cell?.triangle_view.alpha = 1
//                cell?.isUserInteractionEnabled = true
//            }
            cell?.triangle_view.setNeedsDisplay()
            return cell!
        default:
            let iconCell = studentIconsCollectionView.dequeueReusableCell(withReuseIdentifier: "iconReuse", for: indexPath)
            let studentIcon = iconCell.viewWithTag(1) as! UIImageView
            //reverse user order
//            self.userArray.reverse()
//            print("self.userArray",self.userArray)
            let user = self.userArray[indexPath.row]
            
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
                print("user profile1: \(icon)")
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased() == "m"){
                        studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_boy"))
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.4901960784, green: 0.6588235294, blue: 0.4078431373, alpha: 1)
                    }
                    else{
                        studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_girl"))
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.3411764706, blue: 0.3254901961, alpha: 1)
                    }
                }
                else{
                    if user.userType == 4{
                        if(user.gender.lowercased() == "m"){
                            studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))
                            studentIcon.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)

                        }
                        else{
                            studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))
                            studentIcon.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)

                        }
                    }
                    else{
                        if(user.gender.lowercased() == "m"){
                            studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))
                            studentIcon.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.4901960784, blue: 0.8392156863, alpha: 1)

                        }
                        else{
                            studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))
                            studentIcon.layer.borderColor = #colorLiteral(red: 0.968627451, green: 0.3725490196, blue: 0.7882352941, alpha: 1)

                        }
                    }
                   
                }
            }else{
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased() == "m"){
                        studentIcon.image = UIImage(named: "teacher_boy")
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.4901960784, green: 0.6588235294, blue: 0.4078431373, alpha: 1)
                    }
                    else{
                        studentIcon.image = UIImage(named: "teacher_girl")
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.3411764706, blue: 0.3254901961, alpha: 1)
                    }
                }
                else{
                    if user.userType == 4{
                        if(user.gender.lowercased() == "m"){
                            studentIcon.image = UIImage(named: "student_boy")
                            studentIcon.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)

                        }
                        else{
                            studentIcon.image = UIImage(named: "student_girl")
                            studentIcon.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)

                        }
                    }
                    else{
                        if(user.gender.lowercased() == "m"){
                            studentIcon.image = UIImage(named: "student_boy")
                            studentIcon.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.4901960784, blue: 0.8392156863, alpha: 1)
                        }
                        else{
                            studentIcon.image = UIImage(named: "student_girl")
                            studentIcon.layer.borderColor = #colorLiteral(red: 0.968627451, green: 0.3725490196, blue: 0.7882352941, alpha: 1)
                        }
                    }
                    
                }
                
            }
            
            if indexPath.row == self.userIndex.row{
                studentIcon.clipsToBounds = true
                studentIcon.layer.borderWidth = 6.0
                
            }else{
                studentIcon.layer.borderWidth = 0.0
            }
            iconCell.contentView.setNeedsDisplay()
            return iconCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("maher4\(collectionView)")

        switch collectionView{
        case self.collectionView:
            
            if(self.user.blocked){
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "", message: "Your account has been blocked. Please contact your school".localiz(), actions: [ok])
            }
            else{
                let section = sections[indexPath.row]
                var activeModules: [Int] = []
                for module in appTheme.activeModule{
                    if module.status == 1{
                        activeModules.append(module.id)
                    }
                }
                
                if section.id == 99{
                    let yourUrl = "googleclassroom://user?username=johndoe"
                    if UIApplication.shared.canOpenURL(URL(string:yourUrl)!) {
                        UIApplication.shared.open( URL(string: yourUrl)!, options: [:])
                    } else { //redirect to app store
                        UIApplication.shared.open( URL(string: "itms-apps://itunes.apple.com/app/924620788")!, options: [:])
                    }
                    return
                }
                
                
                if section.id == 13{
                    let yourUrl = "ms-teams://user?username=johndoe"
                    if UIApplication.shared.canOpenURL(URL(string:yourUrl)!) {
                        UIApplication.shared.open( URL(string: yourUrl)!, options: [:])
                    } else { //redirect to app store
                        UIApplication.shared.open( URL(string: "itms-apps://itunes.apple.com/app/1113153706")!, options: [:])
                    }
                    return
                }
                
                if section.id == 20{
                    
                    guard let url = URL(string: section.counter) else { return }
                    UIApplication.shared.open(url)
                    
                    return
                }
                
                /// The below used to check for privileges:
                if (self.user.userType == 2 || self.user.userType == 1) && !self.user.privileges.contains("student_attendance_view_privilege") && sections[indexPath.row].id == App.attendanceID{
                    App.showMessageAlert(self, title: "", message: "You do not have the required privilegs to view or interact with this module. for more details please contact your school management".localiz(), dismissAfter: 3)
                }else if self.user.userType == 4  && sections[indexPath.row].id == App.blendedLearningId{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "", message: "You do not have the required privilegs to view or interact with this module. for more details please contact your school management".localiz(), actions: [ok])
                }
            
                else if !activeModules.contains(section.id){
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    let vote = UIAlertAction(title: "Vote to enable".localiz(), style: .default, handler: nil)
    //                { (UIAlertAction) in
    //                    self.voteForActivate(user: self.user, schooldID: self.schoolInfo.id, moduleID: section.id)
    //                }
                    App.showAlert(self, title: "", message: "This module is not activated from your school".localiz(), actions: [ok,vote])
                }else{
                    //1=Calendar
                    //2=attendance
                    //3=agenda
                    //4=remarks
                    //5=grades
                    
                    var moduleId: Int
                    print("sectionid: \(section.id)")
                    switch section.id{
                        //added
                    case 12:
                        self.allClasses = self.sectionFees
                        moduleId = 0
                    case 11:
                        self.allClasses = self.sectionGallery
                        moduleId = -1
                    case 13:
                        print("entered section")
                        self.allClasses = self.sectionTeams
                        moduleId = -2
                    case 14:
                        self.allClasses = self.sectionVirtual
                        moduleId = -3
                    case 15:
                        self.allClasses = self.sectionBlendedLearning
                        moduleId = 15
                    case 2:
                        self.allClasses = self.sectionCalendar
                        moduleId = 1
                    case 8:
                        self.allClasses = self.sectionAttendace
                        moduleId = 2
                    case 3:
                        self.allClasses = self.sectionAgenda
                        moduleId = 3
                    case 6:
                        self.allClasses = self.sectionTimetable
                        moduleId = 6
                    case 9:
                        self.allClasses = self.sectionRemarks
                        moduleId = 4
                    case 5:
                        self.allClasses = self.sectionGrades
                        moduleId = 5
                    default:
                        print("entered section2")
                        self.allClasses = self.sectionCalendar
                        moduleId = section.id
                    }
                    
                    /// - Reset notifications count when user open a module.
                    if self.user.userType == 4{
                        self.resetNotificationsCount(user: self.user, studentUsername: self.user.admissionNo, moduleId: moduleId)
                    }else{
                        self.resetNotificationsCount(user: self.user, studentUsername: "", moduleId: moduleId)
                    }
                    
                    /// - Parameters sent to SectionVC:
                    ///   - userIndex: Current user position inside users collection view.
                    ///   - userArray: Logedin users.
                    ///   - schoolInfo: Current user school infos.
                    ///   - appTheme: Icons and colors for current user and class.
                    ///   - studentOffset: Users collection view current offset.
                    ///   - classIndex: Employee selected class position inside user's classes.
                    ///   - classObject: Used when employee classes are not empty.
                    ///   - allClasses: School classes returned from "get_sections_and_departments" API
                    let vc = storyboard?.instantiateViewController(withIdentifier: "SectionVC") as! SectionVC
                    vc.initData(flag: section.id)
                    vc.user = self.user
                    if self.child != nil{
                        vc.child = self.child
                    }
                    vc.userIndex = self.userIndex
                    vc.backDelegate = self
                    vc.userArray = self.userArray
                    vc.schoolInfo = self.schoolInfo
                    vc.appTheme = self.appTheme
                    self.studentOffset = studentIconsCollectionView.contentOffset.x
                    vc.studentOffset = self.studentOffset
                    vc.sectionID = moduleId
                    if user.userType == 2 || user.userType == 1{
                        vc.sectionRemarks = self.sectionRemarks
                        vc.sectionGrades = self.sectionGrades
                        vc.sectionAgenda = self.sectionAgenda
                        vc.sectionTimetable = self.sectionTimetable
                        vc.sectionAttendace = self.sectionAttendace
                        vc.sectionCalendar = self.sectionCalendar
                        vc.sectionFees = self.sectionFees
                        vc.sectionBlended = self.sectionBlendedLearning
                        print("classindex9")
                        vc.classIndex = self.classIndex
                        if !self.user.classes.isEmpty && self.user.classes.count > self.classIndex{
                            vc.classObject = self.user.classes[self.classIndex]
                        }
                        vc.allClasses = self.allClasses
                    }
                    vc.modalPresentationStyle = .fullScreen
                    show(vc, sender: self)
                }
            }
            
            
        default:
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    /// Description:
    /// - This function is used to calculate the selected user index.
    /// - Call checkAuthentication function to check if user need a validation to confirm selection or not.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch scrollView{
        case studentIconsCollectionView:
            let center = CGPoint(x: studentIconsCollectionView.frame.maxX / 2, y: studentIconsCollectionView.frame.maxY / 2)
            let middleIndex = studentIconsCollectionView.indexPathForItem(at: center)
            var newUser: User!
            if middleIndex != nil && studentIconsCollectionView.visibleCells.count == 2{
                newUser = self.userArray[middleIndex!.row]
                userIndex = middleIndex!
            }else if middleIndex == nil && studentIconsCollectionView.visibleCells.count == 2{
                let indexPaths = studentIconsCollectionView.indexPathsForVisibleItems.sorted{$0.row < $1.row}
                let indexPath = indexPaths.last!
                newUser = self.userArray[indexPath.row]
                userIndex = indexPath
            }else if middleIndex == nil && studentIconsCollectionView.visibleCells.count == 3{
                let indexPaths = studentIconsCollectionView.indexPathsForVisibleItems.sorted{$0.row < $1.row}
                let indexPath = indexPaths[1]
                newUser = self.userArray[indexPath.row]
                userIndex = indexPath
            }
            MessagesViewController.didLoadMessages = false
            SectionVC.canChange = true
            
            self.checkAuthentication(currentUser: self.user, newUser: newUser) { (isValid) in
                if isValid{
                    self.user = newUser
                    self.currentUsersCollectionViewOffset = self.studentIconsCollectionView.contentOffset
                    let width = self.studentIconsCollectionView.collectionViewLayout.collectionViewContentSize.width / CGFloat(self.studentIconsCollectionView.numberOfItems(inSection: self.userIndex.section))
                    let resultingOffset = (width * CGFloat(self.userIndex.row))
                    self.studentOffset = resultingOffset
                    print("getSchoolActivation2")
                    let school = App.getSchoolActivation(schoolID: self.user.schoolId)
                    self.schoolInfo = school
                    self.customizeView()
                    UserDefaults.standard.set(school!.schoolURL, forKey: "BASEURL")
                    self.getUserDetail(user: self.user)
//                    self.getNotifications()
                    if self.user.userType == 2 || self.user.userType == 1{
                        self.getSections(user: self.user)
                    }
                }else{
                    self.studentIconsCollectionView.setContentOffset(self.currentUsersCollectionViewOffset, animated: true)
                    return
                }
            }
            
        default:
            break
        }
    }
    
    /// Description:
    ///
    /// - Parameters:
    ///   - currentUser: User that was selected before swipe to change user.
    ///   - newUser: User swiped to.
    ///   - completion: true means that the user can swich to the new one.
    /// - Use phone security validation to check authentication.
    func checkAuthentication(currentUser: User, newUser: User, completion: @escaping(_ isValide: Bool) -> Void){
        if currentUser.userType == 3 && newUser.userType != 3{
            if !authenticator.canEvaluatePolicy() {
                completion(false)
            }else{
                authenticator.authenticateUser() {
                    message in
                    DispatchQueue.main.async {
                        if let _ = message {
                            completion(false)
                        }else{
                            completion(true)
                        }
                    }
                }
            }
        }else{
            completion(true)
        }
    }
}

// MARK: - API Calls:
extension HomeVC{
    
    /// Description:
    ///
    /// - Parameter user: Current user.
    /// - Call switchStudent function to update user info.
    /// - Call getSchoolInfo function to update school data into core data.
    /// - Call getTabBarIcons function to update colors and icons for the selected user and class.
    func getUserDetail(user: User){
        UserDefaults.standard.set(self.schoolInfo.schoolURL, forKey: "BASEURL")
        self.switchStudent()
        self.setDeviceToken(user: self.user, deviceId: self.uuid, deviceToken: self.deviceToken ?? "")
        self.getSchoolInfo(activationCode: self.schoolInfo.code)
        print("getSchoolActivation3")

        if let schoolObject = App.getSchoolActivation(schoolID: self.user.schoolId){
            self.getTabBarIcons(schoolId: "\(schoolObject.id)", classId: self.currentClass.batchId, code: self.currentClass.imperiumCode, gender: self.user.gender)
        }
    }
    
    func updateUserDetails(user: User){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        
        Request.shared.getUserDetails(id: user.userId, token: user.token, schoolUrl: self.schoolInfo.schoolURL, password: user.password, completion: { (message, userData, status) in
                if status == 200{
                    print("entered updateUserDetails")
                    print(userData)
                    self.user = userData
                    self.saveUser(userData: userData)
                    self.customizeView()
                    print("user user1: \(self.user)")

                    /// modelVersion variable is the core data model version, used to check if the core data model has been changed to delete users data and resign in again.
                  
                    let modelVersion = UserDefaults.standard.integer(forKey: "VERSION")
                    
                    if let users = App.getLoggedInUsers(), modelVersion == App.dbVersion{
                        self.userArray = users
                        self.userArray.reverse()
                    }else{
                        _ = App.logout()
                        print("showLoginPage6")
                        App.showLoginPage()
                        return
                    }
    
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
//        Request.shared.getUserDetails(user: user, schoolURL: self.schoolInfo.schoolURL) { (message, userData, status) in
//            if status == 200{
//                self.saveUser(userData: userData)
//                self.customizeView()
//                /// modelVersion variable is the core data model version, used to check if the core data model has been changed to delete users data and resign in again.
//                let modelVersion = UserDefaults.standard.integer(forKey: "VERSION")
//                if let users = App.getLoggedInUsers(), modelVersion == App.dbVersion{
//                    self.userArray = users
//                    self.userArray.reverse()
//                }else{
//                    _ = App.logout()
//                    print("showLoginPage6")
//                    App.showLoginPage()
//                    return
//                }
//                if self.loggedInUser != nil && self.userArray.count > 1{
//                    let index = self.userArray.firstIndex(where: {$0.userName == self.loggedInUser!.userName})
//                    self.user = self.userArray[index!]
//                    self.getUserDetail(user: self.user)
//                    self.userIndex = IndexPath(row: index!, section: 0)
//                }else if self.user == nil{
//                    self.userIndex = IndexPath(row: 0, section: 0)
//                    if let firstUser = self.userArray.first{
//                        self.user = firstUser
//                        self.getUserDetail(user: self.user)
//                    }else{
//                        _ = App.logout()
//                        print("showLoginPage7")
//                        App.showLoginPage()
//                        return
//                    }
//                }else{
//                    self.loggedInUser = self.user
//                    self.selectStudent()
//                }
//
//                if let viewWithTag = self.view.viewWithTag(100){
//                    viewWithTag.removeFromSuperview()
//                }
//            }
//            else{
//                if let viewWithTag = self.view.viewWithTag(100){
//                    viewWithTag.removeFromSuperview()
//                }
//            }
//        }
    }
    
    /// Description:
    /// - Fetch user userID from core data.
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
    
    /// Description:
    /// - Save user data and class data to core data.
    func saveUser(userData: User?){
        //add user to firebase
        let userIdentifier = (UserDefaults.standard.string(forKey: "BASEURL")?.description ?? "nourl") + " - " + (userData?.userName ?? "N/A")
        
//        Crashlytics.sharedInstance().setUserIdentifier(userIdentifier)
        Crashlytics.crashlytics().setUserID(userIdentifier)
        
        print("user data maher: \(userData)")
        if userData?.userType == 4{//if parent
            guard let child = userData?.childrens.filter({$0.admissionNo != ""}).first else { return }
            
            print("user data maher111: \(child)")

            
            
            self.user = User(token: userData!.token,userName: self.user.userName, schoolId: self.schoolInfo.schoolId, firstName: child.firstName, lastName: child.lastName, userId: userData!.userId, email: userData!.email, googleToken: userData!.googleToken, gender: child.gender, cycle: child.cycle, photo: child.photo, userType: userData!.userType, batchId: child.batchId, imperiumCode: child.imperiumCode, className: child.className, childrens: userData!.childrens, classes: [], privileges: userData!.privileges, firstLogin: userData!.firstLogin, admissionNo: child.admissionNo, bdDate: child.bdDate, isBdChecked: child.isBdChecked, blocked: userData!.blocked, password: userData!.password)
        }else{//if student or employee
            self.user = User(token: userData!.token, userName: userData!.userName, schoolId: self.schoolInfo.schoolId, firstName: userData!.firstName, lastName: userData!.lastName, userId: userData!.userId, email: userData!.email, googleToken: userData!.googleToken, gender: userData!.gender, cycle: userData!.cycle, photo: userData!.photo, userType: userData!.userType, batchId: userData!.batchId, imperiumCode: userData!.imperiumCode, className: userData!.className, childrens: userData!.childrens, classes: userData!.classes, privileges: userData!.privileges, firstLogin: userData!.firstLogin, admissionNo: userData!.admissionNo, bdDate: userData?.bdDate ?? Date(), isBdChecked: userData?.isBdChecked ?? false, blocked: userData!.blocked, password: userData!.password)
        }
        
            let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
            let users = try? self.managedContext.fetch(userFetchRequest) as! [USER]
            if users != nil{
                for object in users!{
                    print("children children1::: \(object)")
                    if object.username == self.user.userName{
                        print("children children2::: \(object.username)")
                        print("children children3::: \(self.user.userName)")

                        if self.user.userType == 4{//parent update child
                            for child in self.user.childrens{
                                print("children children4::: \(child)")
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
                                    object.setValue(self.user.email, forKey: "email")
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
                            if self.user.userType == 2 || self.user.userType == 1{
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
                            object.setValue(self.user.email, forKey: "email")
                            object.setValue(self.user.userName, forKey: "username")
                            object.setValue(self.user.userType, forKey: "userType")
                            object.setValue(self.user.blocked, forKey: "blocked")
                            object.setValue(self.user.password, forKey: "password")
                            object.setValue(NSOrderedSet(array: ChildArray), forKey: "classes")
                        }
                    }
                }
            }
        
        print("users users logged: \(self.userArray)")
        if(self.userArray.count > 0){
            self.user = self.userArray[0]
        }
            //reload collectionview
            self.studentIconsCollectionView.reloadData()
            do{
                try self.managedContext.save()
            }catch{}
        
    }
    
    /// Description: Set Device Token
    ///
    /// - Parameters:
    ///   - deviceId: UUID
    ///   - deviceToken: AWS token
    /// - Request to "set_token" API.
    func setDeviceToken(user: User, deviceId: String, deviceToken: String){
        Request.shared.setDeviceToken(user: user, deviceId: deviceId, deviceToken: deviceToken) { (message, data, status) in
            if status != 200{
//                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR", message: message ?? "", actions: [ok])
            }
        }
    }
    
    
    /// Description: Get SChool Info
    /// - This function used to call "getSchoolURL" API.
    /// - Update school info data into core data.
    /// - Call change user function in TabBar page to update user's data.
    func getSchoolInfo(activationCode: String){
//        let indicatorView = App.loading()
//        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
        
        Request.shared.GetSchoolURL(activationCode: activationCode) { (message, schoolData, status) in
            if status == 200{
                let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
//                let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOLDATA")
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
                    print("new school new1: \(schoolData)")
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
                }else{
                    let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
                    let schools = try? self.managedContext.fetch(schoolFetchRequest) as! [SCHOOL]
                    if schools != nil{
                        for object in schools!{
                            if Int(object.id) == schoolData.id{
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
                }
                self.schoolInfo = schoolData
                self.customizeView()
                self.homeDelegate?.changeUser(user: self.user, schoolInfo: self.schoolInfo)
            }
            else{
                print("error ", "getSchoolInfo")
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
//            UIApplication.shared.keyWindow?.viewWithTag(1500)?.removeFromSuperview()
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
}

// MARK: - BackToHomeDelegate, TabBarToHomeDelegate:
extension HomeVC: BackToHomeDelegate, TabBarToHomeDelegate{
    
    /// Description:
    /// - This function is used to update active module id.
    /// - Call updateSectionID function in TabBar
    func updateModuleID(moduleID: Int, userType: Int) {
        self.activeModule = moduleID
        self.homeDelegate?.updateSectionID(sectionID: moduleID, userType: userType)
    }
    
    /// Description:
    /// - This function is used to update school data variable.
    /// - Call changeUser function in TabBar
    func switchSchool(schoolInfo: SchoolActivation) {
        self.schoolInfo = schoolInfo
        self.homeDelegate?.changeUser(user: self.user, schoolInfo: self.schoolInfo)
    }
    
    /// Description:
    /// - This function is called from module page.
    /// - Used to update students collection view offset.
    /// - Reset section id in TabBar page by calling updateSectionID function.
    func backToHomePressed(index: IndexPath) {
        let width = studentIconsCollectionView.collectionViewLayout.collectionViewContentSize.width / CGFloat(studentIconsCollectionView.numberOfItems(inSection: index.section))
        let resultingOffset = (width * CGFloat(index.row))
        DispatchQueue.main.async {
            self.studentIconsCollectionView.setContentOffset(CGPoint(x: resultingOffset, y: 0), animated: true)
        }
        self.userIndex = index
        self.user = self.userArray[self.userIndex.row]
        self.getUserDetail(user: self.user)
        studentIconsCollectionView.reloadData()
        self.homeDelegate?.updateSectionID(sectionID: 0, userType: self.user.userType)
    }
    
    func backToRoot() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /// Description:
    /// - Used to handle notifications:
    func notificationPressed(sectionId: Int, date: String) {
        openSection(sectionId: sectionId, date: date)
    }
    
    /// Description:
    /// - Open selected module.
    func openSection(sectionId: Int, date: String){
        var flag = 0
        switch sectionId{
        case App.NotiCalendar:
            flag = 2
        case App.NotiAgenda:
            flag = 3
        case App.NotiExamination:
            flag = 5
        case App.NotiAttendance:
            flag = 8
        case App.NotiRemarks:
            flag = 9
        case App.NotiBlended:
            flag = 15
        default:
            flag = 0
            break
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "SectionVC") as! SectionVC
        vc.initData(flag: flag)
        vc.overrideDate = date
        vc.user = self.user
        if self.child != nil{
            vc.child = self.child
        }
        print("userindex: \(self.userIndex)")
        vc.userIndex = self.userIndex
        vc.backDelegate = self
        
        vc.userArray = self.userArray
        vc.schoolInfo = self.schoolInfo
        vc.appTheme = self.appTheme
        if studentIconsCollectionView != nil{
            self.studentOffset = studentIconsCollectionView.contentOffset.x
        }
        vc.studentOffset = self.studentOffset
        if user.userType == 2 || user.userType == 1{
            print("classindex10")
            vc.classIndex = self.classIndex
            vc.allClasses = self.allClasses
        }
        show(vc, sender: self)
    }
    
    func pushNotification(sectionId: Int) {
        self.pushController = .module(moduleID: sectionId)
    }
    
    
    /// Description:
    /// - Call updateTabBarIcon in TabBar page.
    func updateTabBarIcon(theme: AppTheme) {
        self.homeDelegate?.updateTabBarIcon(theme: theme)
    }
    
    /// Description: Get Class Icon API.
    /// - Request to "getClassIcons" API in order to update icons and colors.
    /// - Call getNotificationCount function.
    func getTabBarIcons(schoolId: String, classId: Int, code: String, gender: String){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.GetClassIcons(user: self.user, schoolID: schoolId, classID: classId, code: code, gender: gender) { (message,data,status) in
            if status == 200{
                self.appTheme = data
                print("app app theme1: \(self.appTheme)")
                switch self.user.userType{
                case 1,2:
                    self.getNotificationCount(user: self.user, studentUsername: "", appTheme: self.appTheme)
                case 3:
                    self.getNotificationCount(user: self.user, studentUsername: self.user.userName, appTheme: self.appTheme)
                case 4:
                    self.getNotificationCount(user: self.user, studentUsername: self.user.admissionNo, appTheme: self.appTheme)
                default:
                    break
                }
            }
            else{
                print("getTabBarIcons Error", message?.description ?? "default message", status)
            }
            UIApplication.shared.keyWindow?.viewWithTag(1500)?.removeFromSuperview()
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    
    /// Description: Update User Icon
    ///
    /// - Update user's profile photo into core data.
    func updateUserIcon(genderIcon: String){
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
        let users = try? self.managedContext.fetch(userFetchRequest) as! [USER]
        if users != nil{
            for object in users!{
                if object.username == self.user.userName{
                    object.setValue(genderIcon, forKey: "photo")
                }
            }
        }
        do{
            try self.managedContext.save()
        }catch{}
        if let usersArray = App.getLoggedInUsers(){
            self.userArray = usersArray
        }
        self.studentIconsCollectionView.reloadData()
    }
    
    /// Description: Get Classes
    ///
    /// - This API is called to get all school classes related to user's privileges.
//    func getSections(user: User){
//        Request.shared.getSections(user: user) { (message, sectionData, status) in
//            if status == 200{
//                self.allClasses = sectionData!
//            }
//            else{
//                print("error ", "getSections")
//            }
//        }
//    }
    
    /// Description:
    /// - Request to "get_notification_count" to get modules notifications count.
    /// - Handle push notification if exist.
    func getNotificationCount(user: User, studentUsername: String, appTheme: AppTheme){
        Request.shared.getNotificationCount(user: user, studentUsername: studentUsername, appTheme: appTheme) { (message, data, status) in
            if status == 200{
                self.appTheme = data!
                self.initSections()
                self.collectionView.reloadData()
                self.homeDelegate?.updateTabBarIcon(theme: self.appTheme)
                
                if let push = self.pushController{
                    switch push{
                    case .module(let moduleId):
                        self.pushController = nil
                        self.openSection(sectionId: moduleId, date: "")
                        self.uncheckNotification(user: self.user, id: moduleId)
                    }
                }
            }
            else{
                print("error ","getNotificationCount")
            }
        }
    }
    
    /// Description: Uncheck Notifications
    /// - Request to "uncheck_notification" API in case of push notification.
    func uncheckNotification(user: User, id: Int){
        Request.shared.uncheckNotifications(user: user, notificationId: id) { (message, data, status) in
        }
    }
    
    /// Description: Vote For Activate Module
    /// - Request to "vote" API when user want to vote for activate inactive modules.
    func voteForActivate(user: User, schooldID: Int, moduleID: Int){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        Request.shared.VoteForActivate(user: user, schoolID: schooldID, moduleID: moduleID) { (message, data, status) in
            if status == App.STATUS_SUCCESS{
                App.showMessageAlert(self, title: "", message: "Success", dismissAfter: 1.5)
            }else{
                print("error ", "voteForActivate")
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    /// Description: Reset Notifications Count
    /// - Request to "reset_notifications_count" API in order to reset selected model notifications.
    func resetNotificationsCount(user: User, studentUsername: String, moduleId: Int){
        Request.shared.resetNotificationCount(user: user, studentUsername: studentUsername, moduleId: moduleId) { (message, data, status) in
        }
    }
    
}

