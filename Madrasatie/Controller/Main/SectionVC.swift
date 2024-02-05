//
//  CalendarVC.swift
//  Madrasati
//
//  Created by Tarek on 5/8/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
//import SwiftyAttributes
import LNICoverFlowLayout
import ActionSheetPicker_3_0
import SDWebImage
import CoreData

/// Description:
/// - Delegate from Modules page to Calendar.
protocol SectionVCDelegate{
    func calendarFilterSectionView(type: Int)
    func switchCalendarChildren(user: User, batchId: Int?, children: Children?)
    func calendarBatchId(batchId: Int)
    func updateCalendarTheme(calendarTheme: CalendarTheme)
}

/// Description:
/// - Delegate from Modules page to Agenda.
protocol SectionVCToAgendaDelegate {
    func agendaFilterSectionView(type: Int)
    func switchAgendaChildren(user: User, batchId: Int?, children: Children?)
    func agendaBatchId(user: User, batchId: Int)
    func updateAgendaTheme(theme: AppTheme?)
}

/// Description:
/// - Delegate from Modules page to Remarks.
protocol SectionVCToRemarksDelegate {
    func remarksFilterSectionView(type: Int)
    func switchRemarksChildren(user: User, batchId: Int?, children: Children?)
    func remarksBatchId(batchId: Int)
    func updateRemarkTheme(theme: AppTheme?)
}

//protocol SectionVCToRemarksModuleDelegate {
//    func remarksFilterSectionView(type: Int)
//    func switchRemarksChildren(user: User, batchId: Int?, children: Children?)
//    func remarksBatchId(classs: Class)
//    func updateRemarkTheme(theme: AppTheme?)
//}

/// Description:
/// - Delegate from Modules page to Attendance.
protocol SectionVCToAttendanceDelegate {
    func attendanceFilterSectionView(type: Int)
    func switchAttendanceChildren(user: User, classObject: Class?, children: Children?)
    func attendanceBatchId(batchId: Int)
    func updateAttendanceTheme(appTheme: AppTheme)
}

/// Description:
/// - Delegate from Modules page to Grades.
protocol SectionVCToGradesDelegate{
    func switchGradesChildren(user: User, batchId: Int?, children: Children?)
    func updateAverage(exam: Exam)
    func updateGradesTheme(appTheme: AppTheme)
    func gradesBatchId(batchId: Int)
    func gradesBatchIdPassive(batchId: Int)
}

protocol SectionVCToBlendedLearningDelegate {
    func blendedFilterSectionView(type: Int)
    func switchBlendedLearning(user: User, batchId: Int?, children: Children?)
    func blendedBatchId(user: User, allClasses: [Class], batchId: Int, className: String)
    func updateBlendedTheme(theme: AppTheme?)

}

/// Description:
/// - Delegate from Modules page to TimeTable.
protocol SectionToTimeTableDelegate{
    func updateTimeTable(day: Day)
    func switchTimeTableChildren(user: User, batchId: Int?, children: Children?)
    func timeTableBatchId(user: User, batchId: Int)

}

/// Description:
/// - Delegate from Modules page to Home.
protocol BackToHomeDelegate{
    func backToHomePressed(index: IndexPath)
    func switchSchool(schoolInfo: SchoolActivation)
    func updateTabBarIcon(theme: AppTheme)
    func updateModuleID(moduleID: Int, userType: Int)
}

//added
protocol SectionVCToFeesDelegate{
    func feesFilterSectionView(type: Int)
    func switchFeesChildren(user: User, batchId: Int?, children: Children?)

}
protocol SectionVCToGalleryDelegate {
    func galleryFilterSectionView(type: Int)
    func switchGalleryChildren(user: User, batchId: Int?, children: Children?)

}
protocol SectionVCToTeamsDelegate {
    func teamsFilterSectionView(type: Int)
    func switchTeamsChildren(user: User, batchId: Int?, children: Children?)

}

protocol SectionVCToVirtualClassroomDelegate {
    func virtualFilterSectionView(type: Int)
    func switchVirtualChildren(user: User, batchId: Int?, children: Children?)

}






class SectionVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var lbl_class: UILabel!
    @IBOutlet weak var menu_view: TriangleView!
    @IBOutlet weak var lbl_weeklyView: UILabel!
    @IBOutlet weak var lbl_monthlyView: UILabel!
    @IBOutlet weak var lbl_yearlyView: UILabel!
    @IBOutlet weak var shadow_view: UIView!
    @IBOutlet weak var collection_shadow_view: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var studentIconsCollectionView: UICollectionView!
    @IBOutlet weak var coverFlowLayout: LNICoverFlowLayout!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicture: RoundedImageWithBorder!
    @IBOutlet weak var schoolLogoImageView: UIImageView!
    @IBOutlet weak var classDropDownImageView: UIImageView!
    @IBOutlet weak var classButton: UIButton!
    @IBOutlet weak var yearlyViewButton: UIButton!
    @IBOutlet weak var weeklyTick: UIImageView!
    @IBOutlet weak var monthlyTick: UIImageView!
    @IBOutlet weak var yearlyTick: UIImageView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var menuViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewToMenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var menuHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint! //75
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint! //128
    @IBOutlet var backButton: UIButton!
    //added
    var sections = ["Calendar","Attendance","Agenda","Behaviour","Grades", "Fees", "Gallery", "Microsoft Teams", "Virtual Classroom", "Blended Learning"]
    var studentsArray: [String] = ["profile_picture", "small-profile-1", "small-profile-2"]
    var flag = 0
    var sectionID = 0
    //1=Calendar
    //2=attendance
    //3=agenda
    //4=remarks
    //5=grades
    
    
    var sectionCalendar: [Class] = []
    var sectionAgenda: [Class] = []
    var sectionTimetable: [Class] = []
    var sectionGrades: [Class] = []
    var sectionAttendace: [Class] = []
    var sectionRemarks: [Class] = []
    //added
    var sectionFees:[Class] = []
    var sectionGallery: [Class] = []
    var sectionTeams: [Class] = []
    var sectionVirtual: [Class] = []
    var sectionBlended: [Class] = []
    
    var sectionDelegate: SectionVCDelegate?
    var sectionToAgendaDelegate: SectionVCToAgendaDelegate?
    var sectionToRemarksDelegate: SectionVCToRemarksDelegate?
    var sectionToAttendanceDelegate: SectionVCToAttendanceDelegate?
    var sectionToGradesDelegate: SectionVCToGradesDelegate?
    var sectionToTimeTableDelegate: SectionToTimeTableDelegate?
    //added
    var sectionToFeesDelegate: SectionVCToFeesDelegate?
    var sectionToGalleryDelegate: SectionVCToGalleryDelegate?
    var sectionToTeamsDelegate: SectionVCToTeamsDelegate?
    var sectiontoVirtualDelegate: SectionVCToVirtualClassroomDelegate?
    var sectionToBlendedLearningDelegate: SectionVCToBlendedLearningDelegate?
    var user: User!
    var child: Children!
    var userIndex: IndexPath!
    var backDelegate: BackToHomeDelegate?
    var classIndex = 0
    var schoolInfo: SchoolActivation!
    var userArray: [User] = []
//    var calendarTheme: CalendarTheme!
    var appTheme: AppTheme!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var studentOffset = CGFloat(0)
    var gradesExamArray: [Exam] = []
    var daysArray: [Day] = []
    var classObject: Class!
    var allClasses: [Class] = []
    let authenticator = BiometricAuthentication()
    var controllers: [UIViewController] = []
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    
    static var canChange = true
    static var canChangeClass = true
    static var didLoadCalendar = false
    static var didLoadAttandance = false
    static var didLoadAgenda = false
    static var didLoadGrades = false
    static var didLoadRemarks = false
    //added
    static var didLoadFees = false
    static var didLoadGallery = false
    static var didLoadTeams = false
    static var didLoadVirtual = false
    static var didLoadBlended = false
    var overrideDate = ""
    var count = 0
    
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")

    
    /// Description:
    /// - Init PagerTabStripController's controllers
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        print("entered entered entered")
        
        self.getUserDetail(user: self.user)
        let calendarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        let attendanceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AttendanceViewController") as! AttendanceViewController
        let agendaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AgendaViewController") as! AgendaViewController
        let gradesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GradesViewController") as! GradesViewController
        let remarksVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RemarksViewController") as! RemarksViewController
        let timeTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewTimeTableViewController") as! NewTimeTableViewController
        //added
        let feesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeesViewController") as! FeesViewController
        let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryViewController")as! GalleryViewController
        let teamsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamsViewController")as! TeamsViewController
        let virtualVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VirtualClassroomViewController")as! VirtualClassroomViewController
        let blendedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BlendedLearningViewController")as! BlendedLearningViewController

        print("classindex6")
        if (user.userType == 2 || user.userType == 1) && !user.classes.isEmpty{
            self.classObject = user.classes[classIndex]
        }else{
            self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
        }
        
        //added
        feesVC.feesDelegate = self
        feesVC.user = self.user
        self.sectionToFeesDelegate = feesVC.self
        
        galleryVC.galleryDelegate = self
        galleryVC.user = self.user
        self.sectionToGalleryDelegate = galleryVC.self
        
        teamsVC.teamsDelegate = self
        teamsVC.user = self.user
        self.sectionToTeamsDelegate = teamsVC.self

        virtualVC.virtualDelegate = self
        virtualVC.user = self.user
        self.sectiontoVirtualDelegate = virtualVC.self
        
        blendedVC.blendedDelegate = self
        blendedVC.user = self.user
        blendedVC.appTheme = self.appTheme
        blendedVC.child = self.child
        if user.userType == 2 || user.userType == 1{
            if !self.sectionBlended.isEmpty{
                blendedVC.batchId = self.sectionBlended[classIndex].batchId
                blendedVC.className = self.sectionBlended[classIndex].className
            }else{
                blendedVC.batchId = 0
            }
        }
        print("sectionToBlendedLearningDelegate1")
        self.sectionToBlendedLearningDelegate = blendedVC.self
        
        gradesVC.user = self.user
        gradesVC.delegate = self
        gradesVC.classObject = self.classObject
        gradesVC.appTheme = self.appTheme
        print("sectionToGradesDelegate1")
        if gradesVC.user.userType == 2 || gradesVC.user.userType == 1{
            if !self.sectionGrades.isEmpty{
                gradesVC.classObject.batchId = self.sectionGrades[classIndex].batchId
            }
            else{
                gradesVC.classObject.batchId = 0
            }
        }
        self.sectionToGradesDelegate = gradesVC.self


        
        calendarVC.delegate = self
        calendarVC.user = self.user
        calendarVC.overrideDate = self.overrideDate
        calendarVC.child = self.child
        calendarVC.calendarTheme = self.appTheme.calendarTheme
        if user.userType == 2 || user.userType == 1{
            print("sectionCalendar sectionCalendar: \(self.sectionCalendar)")
            if !self.sectionCalendar.isEmpty{
                calendarVC.batchId = self.sectionCalendar[classIndex].batchId
            }else{
                calendarVC.batchId = 0
            }
        }
        self.sectionDelegate = calendarVC.self
        
        

        attendanceVC.attendanceDelegate = self
        attendanceVC.user = self.user
        attendanceVC.overrideDate = self.overrideDate
        attendanceVC.child = self.child
        attendanceVC.appTheme = self.appTheme
        if user.userType == 2 || user.userType == 1{
            if !self.sectionAttendace.isEmpty{
                attendanceVC.currentClass = self.sectionAttendace[classIndex]
            }else{
                attendanceVC.currentClass = self.allClasses.first
            }
        }
        self.sectionToAttendanceDelegate = attendanceVC.self

        agendaVC.agendaDelegate = self
        agendaVC.user = self.user
        agendaVC.overrideDate = self.overrideDate
        agendaVC.agendaTheme = self.appTheme.agendaTheme
        if user.userType == 2 || user.userType == 1{
            if !self.sectionAgenda.isEmpty{
                agendaVC.batchId = self.sectionAgenda[classIndex].batchId
            }else{
                agendaVC.batchId = 0
            }
        }
        self.sectionToAgendaDelegate = agendaVC.self
        
        
        
        remarksVC.remarksDelegate = self
        remarksVC.user = self.user
        remarksVC.overrideDate = self.overrideDate
        remarksVC.classObject = self.classObject
        if remarksVC.user.userType == 2 || remarksVC.user.userType == 1{
            if !self.sectionRemarks.isEmpty{
                remarksVC.user.classes = self.sectionRemarks
            }
        }
        remarksVC.child = self.child
        remarksVC.remarkTheme = self.appTheme.remarkTheme
        self.sectionToRemarksDelegate = remarksVC.self
        
        timeTableVC.appTheme = self.appTheme
        
        if user.userType == 2 || user.userType == 1{
            if !self.sectionTimetable.isEmpty{
                timeTableVC.sectionId = self.sectionTimetable[classIndex].batchId
            }else{
                timeTableVC.sectionId = 0
            }
        }
        
        
        timeTableVC.user = self.user
        timeTableVC.timeTableDelegate = self
        self.sectionToTimeTableDelegate = timeTableVC.self
        
        controllers = []
        print("sectionid1: \(self.appTheme.activeModule)")

        for module in self.appTheme.activeModule{
            print("sectionid1: \(module.id)")
            switch module.id{
            case App.calendarID:
                controllers.append(calendarVC)
            case App.agendaID:
                controllers.append(agendaVC)
            case App.gradesID:
                controllers.append(gradesVC)
            case App.attendanceID:
                controllers.append(attendanceVC)
            case App.remarksID:
                controllers.append(remarksVC)
            case App.timeTableID:
                print("timetable10")
                controllers.append(timeTableVC)
            case App.feesId:
                controllers.append(feesVC)
            case App.galleryId:
                controllers.append(galleryVC)
            case App.teamsId:
                controllers.append(teamsVC)
//            case App.virtualClassroomId:
//                controllers.append(virtualVC)
            case App.blendedLearningId:
                    controllers.append(blendedVC)
                
            default:
                break
            }
        }
//        return [calendarVC, attendance, agenda, grades, remarks, timeTable]
        return controllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.isScrollEnabled = false
        shadowView.dropShadow()
        menu_view.layer.zPosition = 1
        studentIconsCollectionView.delegate = self
        studentIconsCollectionView.dataSource = self
        studentIconsCollectionView.layer.zPosition = 1
        nameLabel.layer.zPosition = 3
        let url = URL(string: schoolInfo.logo)
        App.addImageLoader(imageView: self.schoolLogoImageView, button: nil)
        schoolLogoImageView.sd_setImage(with: url) { (image, error, cache, url) in
            App.removeImageLoader(imageView: self.schoolLogoImageView, button: nil)
        }
        coloring(label: UILabel())
        customizeView()
        menuTableView.isHidden = true
        menuTableView.tableFooterView = UIView()
        
        print("configClassLabel1")
        self.configClassLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        print("student offset: \(self.studentOffset)")
        DispatchQueue.main.async {
            self.studentIconsCollectionView.setContentOffset(CGPoint(x: self.studentOffset, y: 0), animated: true)
            print("reach reach")

        }
        if (user.userType == 2 || user.userType == 1) && !user.classes.isEmpty{
            print("user.classes: \(user.classes.count)")
            print("classindex: \(classIndex)")
            if user.classes.count > classIndex{
                self.classObject = user.classes[classIndex]
            }
            else{
                self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
            }
           
        }else{
            self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
        }
//        customizeView()
        weeklyTick.tintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        monthlyTick.tintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        yearlyTick.tintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
    }
    
    override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews()

       DispatchQueue.main.async {
        print("flag flag: \(self.flag)")
            switch self.flag{
            case 2:
                //added
                guard let index = self.controllers.firstIndex(where:{$0 is CalendarViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            
            case 12:
                //added
                guard let index = self.controllers.firstIndex(where:{$0 is FeesViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            case 11:
                guard let index = self.controllers.firstIndex(where:{$0 is GalleryViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            case 13:
                guard let index = self.controllers.firstIndex(where:{$0 is TeamsViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            case 14:
                guard let index = self.controllers.firstIndex(where:{$0 is VirtualClassroomViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            case 15:
                guard let index = self.controllers.firstIndex(where:{$0 is BlendedLearningViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            case 8:
                guard let index = self.controllers.firstIndex(where: {$0 is AttendanceViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            case 3:
                guard let index = self.controllers.firstIndex(where: {$0 is AgendaViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            case 5:
                print("entered grades module1")
                guard let index = self.controllers.firstIndex(where: {$0 is GradesViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            case 9:
                guard let index = self.controllers.firstIndex(where: {$0 is RemarksViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            case 10:
                print("timetable11")

                guard let index = self.controllers.firstIndex(where: {$0 is NewTimeTableViewController}) else{
                    return
                }
                self.moveToViewController(at: index, animated: false)
            default:
                break
            }
            self.flag = 0
       }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        switch self.flag{
//        case "Attendance".localiz():
//            guard let index = self.controllers.firstIndex(where: {$0 is AttendanceViewController}) else{
//                return
//            }
//            moveToViewController(at: index)
//        case "Agenda".localiz():
//            guard let index = self.controllers.firstIndex(where: {$0 is AgendaViewController}) else{
//                return
//            }
//            moveToViewController(at: index)
//        case "Grades".localiz():
//            guard let index = self.controllers.firstIndex(where: {$0 is GradesViewController}) else{
//                return
//            }
//            moveToViewController(at: index)
//        case "Remarks".localiz():
//            guard let index = self.controllers.firstIndex(where: {$0 is RemarksViewController}) else{
//                return
//            }
//            moveToViewController(at: index)
//        case "Timetable".localiz():
//            guard let index = self.controllers.firstIndex(where: {$0 is NewTimeTableViewController}) else{
//                return
//            }
//            moveToViewController(at: index, animated: false)
//        default:
//            break
//        }
//        self.flag = ""
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
//            UIApplication.shared.keyWindow?.viewWithTag(1500)?.removeFromSuperview()
//        }
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
        
        if languageId == "ar"{
            self.backButton.setImage(UIImage(named: "right_arrow"), for: .normal)
        }else{
            self.backButton.setImage(UIImage(named: "left_arrow"), for: .normal)
        }
    }
    
    
  
    
    func unhide(containerView:UIView) {
        UIView.animate(withDuration: 0.2) {
            containerView.alpha = 1
        }
    }
    
    func initData(flag: Int){
        print("flagged: \(flag)")
        self.flag = flag
    }
    
    func coloring(label:UILabel) {
        lbl_weeklyView.textColor = #colorLiteral(red: 0.3647058824, green: 0.3647058824, blue: 0.3647058824, alpha: 1)
        lbl_monthlyView.textColor = #colorLiteral(red: 0.3647058824, green: 0.3647058824, blue: 0.3647058824, alpha: 1)
        lbl_yearlyView.textColor = #colorLiteral(red: 0.3647058824, green: 0.3647058824, blue: 0.3647058824, alpha: 1)
        label.textColor = #colorLiteral(red: 0.4056862593, green: 0.637273252, blue: 0.9729810357, alpha: 1)
    }
    
    
    /// Description
    /// - Update menu data based on current section id.
    @IBAction func bt_menuWasPressed(_ sender: Any) {
        
        switch sectionID{
        case 1,2,3,4:
            if sectionID == 2 && (self.user.userType == 2 || self.user.userType == 1){
                lbl_weeklyView.text = "Present students".localiz()
                lbl_monthlyView.text = "Late students".localiz()
                lbl_yearlyView.text = "Absent students".localiz()
                self.lbl_yearlyView.isHidden = false
                self.yearlyViewButton.isHidden = false
                self.bottomView.isHidden = false
                self.menuViewHeightConstraint.constant = 91
                self.bottomViewToMenuConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
            else{
                lbl_weeklyView.text = "Weekly View".localiz()
                lbl_monthlyView.text = "Monthly View".localiz()
                lbl_yearlyView.text = "Yearly View".localiz()
                self.lbl_yearlyView.isHidden = true
                self.yearlyViewButton.isHidden = true
                self.bottomView.isHidden = true
                self.menuViewHeightConstraint.constant = 60
                self.bottomViewToMenuConstraint.constant = -31
                self.view.layoutIfNeeded()
            }
            self.menu_view.isHidden = !self.menu_view.isHidden
        case 5:
            if gradesExamArray.count < 4{
                menuHeightConstraints.constant = CGFloat(32 * gradesExamArray.count)
                menuTableView.isScrollEnabled = false
            }else{
                menuHeightConstraints.constant = 96
                menuTableView.isScrollEnabled = true
            }
            self.view.layoutIfNeeded()
            menuTableView.reloadData()
            menuTableView.layer.zPosition = 1
            menuTableView.isHidden = !menuTableView.isHidden
        case 6:
            menuHeightConstraints.constant = CGFloat(32 * daysArray.count)
            menuTableView.isScrollEnabled = false
            self.view.layoutIfNeeded()
            menuTableView.reloadData()
            menuTableView.layer.zPosition = 1
            menuTableView.isHidden = !menuTableView.isHidden
            
        case 12:
            if self.user.userType == 4 {
                print("sectionid: \(sectionID)")
                lbl_weeklyView.text = "Categories"
                lbl_monthlyView.text = "Distributed Payments"
                lbl_yearlyView.text = ""
                self.lbl_yearlyView.isHidden = true
                self.yearlyViewButton.isHidden = true
                self.bottomView.isHidden = true
                self.menuViewHeightConstraint.constant = 91
                self.bottomViewToMenuConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
            self.menu_view.isHidden = !self.menu_view.isHidden
        default:
            break
        }
    }
    
    @IBAction func bt_weeklyViewWasPressed(_ sender: Any) {
        self.menu_view.isHidden = !self.menu_view.isHidden
        coloring(label: lbl_weeklyView)
        weeklyTick.isHidden = false
        monthlyTick.isHidden = true
        yearlyTick.isHidden = true
        sendMenuDelegate(type: 1)
    }
    
    @IBAction func bt_monthlyViewWasPressed(_ sender: Any) {
        self.menu_view.isHidden = !self.menu_view.isHidden
        coloring(label: lbl_monthlyView)
        weeklyTick.isHidden = true
        monthlyTick.isHidden = false
        yearlyTick.isHidden = true
        sendMenuDelegate(type: 0)
    }
    
    @IBAction func bt_yearlyViewWasPressed(_ sender: Any) {
        self.menu_view.isHidden = !self.menu_view.isHidden
        coloring(label: lbl_yearlyView)
        sendMenuDelegate(type: 2)
        weeklyTick.isHidden = true
        monthlyTick.isHidden = true
        yearlyTick.isHidden = false
    }
    
    
    /// Description:
    /// - Handle selected values from menu view.
    /// - Call functions in module based on the section id.
    func sendMenuDelegate(type: Int){
        print("sectionsid: \(sectionID)")
        switch sectionID{
        case 1:
            self.sectionDelegate?.calendarFilterSectionView(type: type)
        case 2:
            self.sectionToAttendanceDelegate?.attendanceFilterSectionView(type: type)
        case 3:
            self.sectionToAgendaDelegate?.agendaFilterSectionView(type: type)
        case 4:
            self.sectionToRemarksDelegate?.remarksFilterSectionView(type: type)
        case 12:
            self.sectionToFeesDelegate?.feesFilterSectionView(type: type)
        case 11:
            self.sectionToGalleryDelegate?.galleryFilterSectionView(type: type)
        case 13:
            self.sectionToTeamsDelegate?.teamsFilterSectionView(type: type)
        case 14:
            self.sectiontoVirtualDelegate?.virtualFilterSectionView(type: type)
        case 15:
            print("sectionToBlendedLearningDelegate2")
            self.sectionToBlendedLearningDelegate?.blendedFilterSectionView(type: type)
        default:
            break
        }
    }
    
    //MARK: CLASS BUTTON PRESSED
    /// Description:
    /// - Configure class label text for employee user, based on active module and user privileges:
    @IBAction func classButtonPressed(_ sender: Any) {
        //check if allowed to change class
        if SectionVC.canChangeClass == false{
            return
        }
        
        if user.userType == 2 || user.userType == 1{
            var classArray: [String] = []
            var allClasses = true
            var index = 0
            print("classbutton1: \(self.sectionID)")
            print("classbutton1: \(self.classObject)")
            print("classbutton1: \(self.sectionTimetable)")

            if self.sectionID == 1{//calendar
                index = self.sectionCalendar.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                classArray = self.sectionCalendar.map({$0.className})
            }else if self.sectionID == 3{//agenda
                index = self.sectionAgenda.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                classArray = self.sectionAgenda.map({$0.className})
            }else if self.sectionID == 2{//attendance
                index = self.sectionAttendace.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                classArray = self.sectionAttendace.map({$0.className})
            }else if self.sectionID == 4{//remarks
                index = self.sectionRemarks.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                classArray = self.sectionRemarks.map({$0.className})
            }else if self.sectionID == 5{//grades
                index = self.sectionGrades.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                classArray = self.sectionGrades.map({$0.className})
            }
            else if self.sectionID == 6{//timetable
                index = self.sectionTimetable.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                classArray = self.sectionTimetable.map({$0.className})
            }
            else if self.sectionID == 15{
                index = self.sectionBlended.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                classArray = self.sectionBlended.map({$0.className})
            }
            
            else{
                index = self.user.classes.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                classArray = user.classes.map({$0.className})
                allClasses = false
            }
            
            print("classArray123: \(classArray)")

            ActionSheetStringPicker.show(withTitle: "Choose Class:".localiz(), rows: classArray, initialSelection: index, doneBlock: {
                picker, ind, values in
                
                if values == nil{
                    return
                }
                
                if self.user.classes.isEmpty && !allClasses{
                    self.lbl_class.text = ""
                }else{
                    //allow refresh again for modules
                    SectionVC.didLoadGrades = false
                    SectionVC.didLoadAgenda = false
                    SectionVC.didLoadRemarks = false
                    SectionVC.didLoadCalendar = false
                    SectionVC.didLoadAttandance = false
                    SectionVC.didLoadBlended = false
                    
                    var classs: Class
                    print("classindex1")
                    self.classIndex = ind
                    
                    print("choose1: \(self.sectionID)")
                    
                    if self.sectionID == 1{//calendar
                        classs = self.sectionCalendar[ind]
                        self.classObject = classs
                        if self.sectionCalendar.count > 0{
                            print("choose2: \(self.sectionCalendar.count)")
                            print("calendarBatchId3\(self.sectionCalendar[0].className)")
                            self.sectionDelegate?.calendarBatchId(batchId: classs.batchId)
                        }
                        
                    }else if self.sectionID == 2 {//attendance
                        classs = self.sectionAttendace[ind]
                        self.classObject = classs
                        if self.sectionAttendace.count > 0{
                            print("choose3: \(self.sectionAttendace.count)")
                            self.sectionToAttendanceDelegate?.attendanceBatchId(batchId: classs.batchId)
                        }
                    }else if self.sectionID == 3 {//agenda
                        classs = self.sectionAgenda[ind]
                        self.classObject = classs
                        if self.sectionAgenda.count > 0{
                            print("choose4: \(self.sectionAgenda.count)")
                            self.sectionToAgendaDelegate?.agendaBatchId(user: self.user, batchId: classs.batchId)
                        }
                    }else if self.sectionID == 4 {//remarks
                        classs = self.sectionRemarks[ind]
                        self.classObject = classs
                        if self.sectionRemarks.count > 0{
                            print("choose5: \(self.sectionRemarks.count)")
                            self.sectionToRemarksDelegate?.remarksBatchId(batchId: classs.batchId)
                        }
                    }else if self.sectionID == 5 {//grades
                        classs = self.sectionGrades[ind]
                        self.classObject = classs
                        if self.sectionGrades.count > 0{
                            print("sectionToGradesDelegate2")
                            self.sectionToGradesDelegate?.gradesBatchId(batchId: classs.batchId)
                        }
                    }
                    else if self.sectionID == 6{
                        classs = self.sectionTimetable[ind]
                        self.classObject = classs
                        if self.sectionTimetable.count > 0{
                            print("choose7: \(self.sectionTimetable.count)")
                            print("sectionToTimetableDelegate3")
                            self.sectionToTimeTableDelegate?.timeTableBatchId(user: self.user, batchId: classs.batchId)
                        }
                    }
                    else if self.sectionID == 15{
                        classs = self.sectionBlended[ind]
                        self.classObject = classs
                        if self.sectionBlended.count > 0{
                            print("choose7: \(self.sectionBlended.count)")
                            print("sectionToBlendedLearningDelegate3")
                            self.sectionToBlendedLearningDelegate?.blendedBatchId(user: self.user, allClasses: self.sectionBlended, batchId: classs.batchId, className: classs.className)
                        }
                    }
                    else {
                        classs = self.user.classes[ind]
                        self.classObject = classs
                        
                    
                        
                    }

                    self.lbl_class.text = classs.className
                    
                    self.getTabBarIcons(schoolId: "\(self.schoolInfo?.id ?? 0)", classId: classs.batchId, code: classs.imperiumCode, gender: self.user.gender)
                }
                
                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        }
    }
    
    @IBAction func schoolLogoPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        aboutVC.info = self.schoolInfo
        aboutVC.schoolName = self.schoolInfo.name
        self.show(aboutVC, sender: self)
    }
    
    /// Description:
    /// - Center the middle item by calculate the collection view offset.
    /// - Configure views design.
    func customizeView() {
        if self.userArray.count == 1{
            studentIconsCollectionView.isHidden = true
            profilePicture.isHidden = false
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
            
            print("user profiles: \(icon)")
            if user.photo.unescaped != "" {
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased() == "m"){
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_boy"))
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.4901960784, green: 0.6588235294, blue: 0.4078431373, alpha: 1)
                    }
                    else{
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_girl"))
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.3411764706, blue: 0.3254901961, alpha: 1)
                    }
                }
                else if user.userType == 4{
                    if(user.gender.lowercased() == "m"){
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                    else{
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                }
                else{
                    if(user.gender.lowercased() == "m"){
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.4901960784, blue: 0.8392156863, alpha: 1)
                    }
                    else{
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.968627451, green: 0.3725490196, blue: 0.7882352941, alpha: 1)
                    }
                }
            }else{
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased() == "m"){
                        profilePicture.image = UIImage(named: "teacher_boy")
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.4901960784, green: 0.6588235294, blue: 0.4078431373, alpha: 1)
                    }
                    else{
                        profilePicture.image = UIImage(named: "teacher_girl")
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.3411764706, blue: 0.3254901961, alpha: 1)
                    }
                }
                else if user.userType == 4{
                    if(user.gender.lowercased() == "m"){
                        profilePicture.image = UIImage(named: "student_boy")
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                    else{
                        profilePicture.image = UIImage(named: "student_girl")
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                }
                else{
                    if(user.gender.lowercased() == "m"){
                        profilePicture.image = UIImage(named: "student_boy")
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.4901960784, blue: 0.8392156863, alpha: 1)
                    }
                    else{
                        profilePicture.image = UIImage(named: "student_girl")
                        profilePicture.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.3411764706, blue: 0.3254901961, alpha: 1)
                    }
                }
                
            }
            
            
        }else{
            print("user profiles: ")
            studentIconsCollectionView.isHidden = false
//            profilePicture.isHidden = true
            
            let width = studentIconsCollectionView.collectionViewLayout.collectionViewContentSize.width / CGFloat(studentIconsCollectionView.numberOfItems(inSection: userIndex.section))
            let resultingOffset = (width * CGFloat(userIndex.row))
            DispatchQueue.main.async {
                self.studentIconsCollectionView.setContentOffset(CGPoint(x: resultingOffset, y: 0), animated: false)
            }
        }
        
        if let url = URL(string: schoolInfo.logo){
            App.addImageLoader(imageView: self.schoolLogoImageView, button: nil)
            self.schoolLogoImageView.sd_setImage(with: url) { (image, error, cache, url) in
                App.removeImageLoader(imageView: self.schoolLogoImageView, button: nil)
            }
        }
        
        shadow_view.dropShadow()
        collection_shadow_view.dropShadow()
        
        switchStudent()
    }
    
    /// Description:
    /// - If a single user is logged in, hide the collection and show an imageView.
    /// - Configure class label and picker array data based on the user type and user's privileges.
    func switchStudent(){
        if userArray.count == 1{
            studentIconsCollectionView.isHidden = true
            profilePicture.isHidden = false
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
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased() == "m"){
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_boy"))

                    }
                    else{
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_girl"))

                    }
                }
                else{
                    if(user.gender.lowercased() == "m"){
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))

                    }
                    else{
                        profilePicture.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))

                    }
                }
            }else{
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased() == "m"){
                        profilePicture.image = UIImage(named: "teacher_boy")
                    }
                    else{
                        profilePicture.image = UIImage(named: "teacher_girl")
                    }
                }
                else{
                    if(user.gender.lowercased() == "m"){
                        profilePicture.image = UIImage(named: "student_boy")
                    }
                    else{
                        profilePicture.image = UIImage(named: "student_girl")
                    }
                }
                
            }
            
        }else{
            studentIconsCollectionView.isHidden = false
            profilePicture.isHidden = true
        }
        
        switch self.user.userType{
        case 1,2:
            var isUserClassesEmpty = false
            print("classindex2")
            self.classIndex = 0
            classDropDownImageView.isHidden = false
            nameLabel.text = "\(user.firstName)"
            if !self.user.classes.isEmpty{
                if self.user.classes[classIndex].batchId != 0{
                    lbl_class.text = self.user.classes[classIndex].className
                    self.classObject = self.user.classes[classIndex]
                    self.sectionToRemarksDelegate?.remarksBatchId(batchId: self.classObject.batchId)
                }else{
                    isUserClassesEmpty = true
                }
            }else{
                isUserClassesEmpty = true
            }
            if isUserClassesEmpty{
                if !allClasses.isEmpty {
                    lbl_class.text = allClasses.first?.className ?? ""
                    self.classObject = self.allClasses.first!
                    self.sectionToRemarksDelegate?.remarksBatchId(batchId: self.classObject.batchId)
                }
            }
        case 3:
            classDropDownImageView.isHidden = true
            nameLabel.text = user.firstName
            lbl_class.text = user.classes.first?.className ?? ""
        case 4:
            classDropDownImageView.isHidden = true
            nameLabel.text = user.firstName
            lbl_class.text = user.classes.first?.className ?? ""
        default:
            break
        }
        
    }

    /// Description:
    /// - Call backToHomePressed function in Home page.
    @IBAction func bt_backWasPressed(_ sender: Any) {
        SectionVC.canChange = true
        if self.userArray.count != 1{
            self.backDelegate?.backToHomePressed(index: userIndex ?? IndexPath(row: 0, section: 0))
        }
//        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView{
        case studentIconsCollectionView:
            return self.userArray.count
        default:
            return viewControllers.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        switch collectionView{
        case studentIconsCollectionView:
            return CGSize(width: 90, height: 90)
        default:
            guard let cellWidthValue = cachedCellWidths?[indexPath.row] else {
                fatalError("cachedCellWidths for \(indexPath.row) must not be nil")
            }
            return CGSize(width: cellWidthValue, height: collectionView.frame.size.height)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView{
        case studentIconsCollectionView:
            let iconCell = studentIconsCollectionView.dequeueReusableCell(withReuseIdentifier: "iconReuse", for: indexPath)
            let studentIcon = iconCell.viewWithTag(1) as! UIImageView
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
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased().elementsEqual("m")){
                        studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_boy"))
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.4901960784, green: 0.6588235294, blue: 0.4078431373, alpha: 1)

                    }
                    else{
                        studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "teacher_girl"))
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.3411764706, blue: 0.3254901961, alpha: 1)

                    }
                }
                else if user.userType == 4{
                    
                    if(user.gender.lowercased().elementsEqual("m")){
                        studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)

                    }
                    else{
                        studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)

                    }
                }
                else{
                    if(user.gender.lowercased().elementsEqual("m")){
                        studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.4901960784, blue: 0.8392156863, alpha: 1)

                    }
                    else{
                        studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.968627451, green: 0.3725490196, blue: 0.7882352941, alpha: 1)

                    }
                }
            }else{
               
                if(user.userType == 2 || user.userType == 1){
                    if(user.gender.lowercased().elementsEqual("m")){
                       
                        studentIcon.image = UIImage(named: "teacher_boy")
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.4901960784, green: 0.6588235294, blue: 0.4078431373, alpha: 1)
                    }
                    else{
                        studentIcon.image = UIImage(named: "teacher_girl")
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.9568627451, green: 0.3411764706, blue: 0.3254901961, alpha: 1)
                    }
                }
                else if user.userType == 4{
                    if(user.gender.lowercased().elementsEqual("m")){
                        studentIcon.image = UIImage(named: "student_boy")
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                    else{
                        studentIcon.image = UIImage(named: "student_girl")
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.8039215686, blue: 0.0862745098, alpha: 1)
                    }
                }
                else{
                    if(user.gender.lowercased().elementsEqual("m")){
                        studentIcon.image = UIImage(named: "student_boy")
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.4901960784, blue: 0.8392156863, alpha: 1)
                    }
                    else{
                        studentIcon.image = UIImage(named: "student_girl")
                        studentIcon.layer.borderColor = #colorLiteral(red: 0.968627451, green: 0.3725490196, blue: 0.7882352941, alpha: 1)
                    }
                }
                
            }
            
            if indexPath.row == self.userIndex.row{
                studentIcon.clipsToBounds = true
                studentIcon.layer.borderWidth = 6.0
                
            }else{
                studentIcon.layer.borderWidth = 0.0
            }
            return iconCell
        default:

            /// Desription:
            /// - Configure XLPagerTabStrip collection cell.
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ButtonBarViewCell else {
                fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
            }
            
            collectionViewDidLoad = true
            let childController = viewControllers[indexPath.item] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            let indicatorInfo = childController.indicatorInfo(for: self)
            
            cell.label.text = indicatorInfo.title
            cell.accessibilityLabel = indicatorInfo.accessibilityLabel
            cell.label.font = settings.style.buttonBarItemFont
            cell.label.textColor = settings.style.buttonBarItemTitleColor ?? cell.label.textColor
            cell.counterLabel.font = cell.counterLabel.font
            cell.counterLabel.text = indicatorInfo.counter
            cell.backgroundColorView.backgroundColor = indicatorInfo.backgroundViewColor
//            cell.contentView.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.contentView.backgroundColor
//            cell.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.backgroundColor
            if let image = indicatorInfo.image {
                cell.imageView.image = image
            }
            if let highlightedImage = indicatorInfo.highlightedImage {
                cell.imageView.highlightedImage = highlightedImage
            }
            print("indicatorid: \(indicatorInfo.id)")
            print(App())

            switch indicatorInfo.id{
            /// Case of Calendar:
            case App.calendarID:
                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.calendarBg, alpha: 1.0)
                if appTheme.homePage.calendarIcon.contains("http"){
                    let url = URL(string: appTheme.homePage.calendarIcon)
                    App.addImageLoader(imageView: cell.imageView, button: nil)
                    cell.imageView.sd_setImage(with: url) { (image, error, chache, url) in
                        App.removeImageLoader(imageView: cell.imageView, button: nil)
                    }
                }else{
                    cell.imageView.image = indicatorInfo.image
                }
            /// Case of Agenda:
            case App.agendaID:
                print("entered agenda: \(App.agendaID)")
                print("entered agenda: \(appTheme.homePage.agendaIcon)")
                print("indicatorInfo: \(indicatorInfo)")

                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.agendaBg, alpha: 1.0)
                if appTheme.homePage.agendaIcon.contains("http"){
                    let url = URL(string: appTheme.homePage.agendaIcon)
                    App.addImageLoader(imageView: cell.imageView, button: nil)
                    cell.imageView.sd_setImage(with: url) { (image, error, cache, url) in
                        App.removeImageLoader(imageView: cell.imageView, button: nil)
                    }
                }else{
                    cell.imageView.image = indicatorInfo.image
                }
            // Case of Attendance:
            case App.attendanceID:
                if appTheme.homePage.attendanceIcon.contains("http"){
                    let url = URL(string: appTheme.homePage.attendanceIcon)
                    App.addImageLoader(imageView: cell.imageView, button: nil)
                    cell.imageView.sd_setImage(with: url) { (image, error, cache, url) in
                        App.removeImageLoader(imageView: cell.imageView, button: nil)
                    }
                }else{
                    cell.imageView.image = indicatorInfo.image
                }
                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.attendanceBg, alpha: 1.0)
            // Case of Grades:
            case App.gradesID:
                if appTheme.homePage.gradeIcon.contains("http"){
                    let url = URL(string: appTheme.homePage.gradeIcon)
                    App.addImageLoader(imageView: cell.imageView, button: nil)
                    cell.imageView.sd_setImage(with: url) { (image, error, chache, url) in
                        App.removeImageLoader(imageView: cell.imageView, button: nil)
                    }
                }else{
                    cell.imageView.image = indicatorInfo.image
                }
                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.gradeBg, alpha: 1.0)
            // Case of TimeTable:
            case App.timeTableID:
                print("timetable1")
                if appTheme.homePage.timeTableIcon.contains("http"){
                    let url = URL(string: appTheme.homePage.timeTableIcon)
                    App.addImageLoader(imageView: cell.imageView, button: nil)
                    cell.imageView.sd_setImage(with: url) { (image, error, cache, url) in
                        App.removeImageLoader(imageView: cell.imageView, button: nil)
                    }
                }else{
                    cell.imageView.image = indicatorInfo.image
                }
                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.timeTableBg, alpha: 1.0)
            case App.galleryId:
                cell.imageView.image = UIImage(named: appTheme.homePage.galleryIcon)
                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.galleryBg, alpha: 1.0)
                
            case App.feesId:
                cell.imageView.image = UIImage(named: appTheme.homePage.feesIcon)
                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.feesBg, alpha: 1.0)
            case App.teamsId:
                cell.imageView.image = UIImage(named: appTheme.homePage.teamsIcon)
                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.teamsBg, alpha: 1.0)
            case App.virtualClassroomId:
                cell.imageView.image = UIImage(named: appTheme.homePage.virtualIcon)
                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.virtualBg, alpha: 1.0)
            case App.blendedLearningId:
            cell.imageView.image = UIImage(named: appTheme.homePage.blendedIcon)
            cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.blendedBg, alpha: 1.0)
                
            

            // Case of Remarks:
            default:
                print("entered default: \(indicatorInfo.id)")

                if appTheme.homePage.remarkIcon.contains("http"){
                    let url = URL(string: appTheme.homePage.remarkIcon)
                    App.addImageLoader(imageView: cell.imageView, button: nil)
                    cell.imageView.sd_setImage(with: url) { (image, error, cache, url) in
                        App.removeImageLoader(imageView: cell.imageView, button: nil)
                    }
                }else{
                    cell.imageView.image = indicatorInfo.image
                }
                cell.backgroundColorView.backgroundColor = App.hexStringToUIColor(hex: appTheme.homePage.remarkBg, alpha: 1.0)
            }
            cell.backgroundColorView.setNeedsDisplay()
            configureCell(cell, indicatorInfo: indicatorInfo)
            
            if pagerBehaviour.isProgressiveIndicator {
                if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                    changeCurrentIndexProgressive(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, 1, true, false)
                }
            } else {
                if let changeCurrentIndex = changeCurrentIndex {
                    changeCurrentIndex(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, false)
                }
            }
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = cell.label.text
//            cell.accessibilityTraits |= UIAccessibilityTraitButton
            cell.accessibilityTraits.insert(UIAccessibilityTraits.button)
//            cell.accessibilityTraits |= UIAccessibilityTraitHeader
            cell.accessibilityTraits.insert(UIAccessibilityTraits.header)
            
            /// Description:
            /// - Below used for Active/Inactive Modules:
            var activeModules: [Int] = []
            for module in self.appTheme.activeModule{
                if module.status == 1{
                    activeModules.append(module.id)
                }
            }
            if activeModules.contains(indicatorInfo.id ?? 0){
                    cell.contentView.alpha = 1
                    cell.isUserInteractionEnabled = true
            }else{
                cell.contentView.alpha = 0.3
                cell.isUserInteractionEnabled = false
            }
            
            /// Active timeTable Module:
            if indicatorInfo.id == 11{
                print("timetable2")
                cell.contentView.alpha = 1
                cell.isUserInteractionEnabled = true
            }
            
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("pressed\(indexPath.item)")
        switch collectionView{
        case studentIconsCollectionView:
            break
        default:
            /// Description: Move to selected Module.
            /// - Check for attendance privileges.
            /// - Update user classes.
            
            //check if change allowed
            if SectionVC.canChange == false {
                App.showMessageAlert(self, title: "", message: "Please finish or close the form".localiz(), dismissAfter: 3.0)
                return
            }
            
            guard indexPath.item != currentIndex else { return }
            
            let attendanceIndex = self.controllers.firstIndex(where: {$0 is AttendanceViewController})
            let blendedIndex = self.controllers.firstIndex(where: {$0 is BlendedLearningViewController})

            if (self.user.userType == 1 || self.user.userType == 2) && !self.user.privileges.contains("student_attendance_view_privilege") && indexPath.item == attendanceIndex{
                App.showMessageAlert(self, title: "", message: "You do not have the required privilegs to view or interact with this module. for more details please contact your school management".localiz(), dismissAfter: 3.0)
            }
            else if self.user.userType == 4 && indexPath.item == blendedIndex{
                App.showMessageAlert(self, title: "", message: "You do not have the required privilegs to view or interact with this module. for more details please contact your school management".localiz(), dismissAfter: 3.0)
            }
            else{
                buttonBarView.moveTo(index: indexPath.item, animated: true, swipeDirection: .none, pagerScroll: .yes)
                shouldUpdateButtonBarView = false
                
                let oldIndexPath = IndexPath(item: currentIndex, section: 0)
                let newIndexPath = IndexPath(item: indexPath.item, section: 0)
                
                let cells = cellForItems(at: [oldIndexPath, newIndexPath], reloadIfNotVisible: collectionViewDidLoad)
                
                if pagerBehaviour.isProgressiveIndicator {
                    if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                        changeCurrentIndexProgressive(cells.first!, cells.last!, 1, true, true)
                    }
                } else {
                    if let changeCurrentIndex = changeCurrentIndex {
                        changeCurrentIndex(cells.first!, cells.last!, true)
                    }
                }
                print("moveToViewController: \(indexPath.item)")
                moveToViewController(at: indexPath.item)
            }
            
//            if (indexPath.item != attendanceIndex || indexPath.item != agendaIndex) && !self.user.classes.isEmpty && (self.sectionID == 2 || self.sectionID == 3){
//                classIndex = 0
//            if !self.user.classes.isEmpty{
//                if self.user.classes.count > classIndex{
//                    self.classObject = self.user.classes[classIndex]
//                    self.lbl_class.text = self.classObject.className
//                }
//            }else if !self.allClasses.isEmpty{
//                self.classObject = self.allClasses.first
//                self.lbl_class.text = self.classObject.className
//            }
//            }
        }
    }
    
    /// Description:
    /// - This function is used to calculate the selected user index.
    /// - Call checkAuthentication function to check if user need a validation to confirm selection or not.
    /// - Call backToHomePressed function in Home page to update new user index.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch scrollView{
        case studentIconsCollectionView:
            let center = CGPoint(x: studentIconsCollectionView.frame.maxX / 2, y: studentIconsCollectionView.frame.maxY / 2)
            let middleIndex = studentIconsCollectionView.indexPathForItem(at: center)
            var nextUser: User?
            if middleIndex != nil && studentIconsCollectionView.visibleCells.count == 2{
                nextUser = self.userArray[middleIndex!.row]
                userIndex = middleIndex
            }else if middleIndex == nil && studentIconsCollectionView.visibleCells.count == 2{
                let indexPaths = studentIconsCollectionView.indexPathsForVisibleItems.sorted{$0.row < $1.row}
                let indexPath = indexPaths.last!
                nextUser = self.userArray[indexPath.row]
                userIndex = indexPath
            }else if middleIndex == nil && studentIconsCollectionView.visibleCells.count == 3{
                let indexPaths = studentIconsCollectionView.indexPathsForVisibleItems.sorted{$0.row < $1.row}
                let indexPath = indexPaths[1]
                nextUser = self.userArray[indexPath.row]
                userIndex = indexPath
            }
            MessagesViewController.didLoadMessages = false
            SectionVC.canChange = true

            guard let newUser = nextUser else{ return }
            self.checkAuthentication(currentUser: self.user, newUser: newUser) { (isValid) in
                if isValid{
                    self.user = newUser
                    self.studentOffset = self.studentIconsCollectionView.contentOffset.x
                    let width = self.studentIconsCollectionView.collectionViewLayout.collectionViewContentSize.width / CGFloat(self.studentIconsCollectionView.numberOfItems(inSection: self.userIndex.section))
                    let resultingOffset = (width * CGFloat(self.userIndex.row))
                    self.studentOffset = resultingOffset
                    print("getSchoolActivation4")

                    let school = App.getSchoolActivation(schoolID: self.user.schoolId)
                    self.schoolInfo = school
                    self.customizeView()
                    UserDefaults.standard.set(school!.schoolURL, forKey: "BASEURL")
                    self.getUserDetail(user: self.user)
                    self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
                }else{
                    self.studentIconsCollectionView.setContentOffset(CGPoint(x: self.studentOffset, y: 0), animated: true)
                    return
                }
                self.backDelegate?.backToHomePressed(index: self.userIndex ?? IndexPath(row: 0, section: 0))
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

//MARK: GO TO MODULES
extension SectionVC: CalendarViewControllerDelegate, AttendanceViewControllerDelegate, AgendaViewControllerDelegate, RemarksViewControllerDelegate,
GradesViewControllerDelegate, NewTimeTableViewControllerDelegate, FeesViewControllerDelegate, GalleryViewControllerDelegate, TeamsViewControllerDelegate,
VirtualClassroomViewControllerDelegate, BlendedLearningViewControllerDelegate{
    func galleryPressed(calendarType: CalendarStyle?) {
        print("entered here")
        self.menu_view.isHidden = true
        self.sectionID = 11
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    
    func feesPressed(calendarType: CalendarStyle?) {
        print("entered here")
        self.menu_view.isHidden = true
        self.sectionID = 12
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    func teamsPressed(calendarType: CalendarStyle?) {
        self.menu_view.isHidden = true
        self.sectionID = 13
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    func virtualPressed(calendarType: CalendarStyle?) {
        self.menu_view.isHidden = true
        self.sectionID = 14
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    func blendedPressed() {
        print("configClassLabel2")
           self.menu_view.isHidden = true
           self.sectionID = 15
        
        print("blended learning blended learning")
        self.sectionID = 15
        buttonBarView.selectedBar.backgroundColor = App.hexStringToUIColor(hex: self.appTheme.homePage.blendedBg, alpha: 1.0)
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
       }
    
    func goToBlended(){
        print("entered blended learning2")
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            guard let index = self.controllers.firstIndex(where: {$0 is BlendedLearningViewController}) else{
                return
            }
            self.moveToViewController(at: index)
        }
    }
    
    
    
    /// Description:
    ///
    /// - Parameter calendarType: Calendar view type: can be weekly view or monthly view.
    /// - Update view design when each module is selected.
    /// - Call updateModuleID fucntion in Home page.
    
    // Calendar Section Is Active:
    func calendar(calendarType: CalendarStyle?) {
        print("calendarpressed")
        self.menu_view.isHidden = true
        self.sectionID = 1
        
        buttonBarView.selectedBar.backgroundColor = App.hexStringToUIColor(hex: self.appTheme.homePage.calendarBg, alpha: 1.0)
        if calendarType == .week{
            coloring(label: self.lbl_weeklyView)
            weeklyTick.isHidden = false
            monthlyTick.isHidden = true
            yearlyTick.isHidden = true
        }else{
            coloring(label: self.lbl_monthlyView)
            weeklyTick.isHidden = true
            monthlyTick.isHidden = false
            yearlyTick.isHidden = true
        }
        
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    
   
    //Attendance Section Is Active:
    func attendance(user: User, calendarType: CalendarStyle?) {
        print("blended learning blended learning")
        self.sectionID = 2
        buttonBarView.selectedBar.backgroundColor = App.hexStringToUIColor(hex: self.appTheme.homePage.attendanceBg, alpha: 1.0)
        if user.userType == 2 || user.userType == 1{
            coloring(label: UILabel())
            weeklyTick.isHidden = true
            monthlyTick.isHidden = true
            yearlyTick.isHidden = true
            self.menu_view.isHidden = true
        }else{
            if calendarType == .week{
                coloring(label: self.lbl_weeklyView)
                weeklyTick.isHidden = false
                monthlyTick.isHidden = true
                yearlyTick.isHidden = true
            }else{
                coloring(label: self.lbl_monthlyView)
                weeklyTick.isHidden = true
                monthlyTick.isHidden = false
                yearlyTick.isHidden = true
            }
        }
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    
    //Agenda Section Is Active:
    func agenda(calendarType: CalendarStyle?) {
        self.menu_view.isHidden = true
        self.sectionID = 3
        buttonBarView.selectedBar.backgroundColor = App.hexStringToUIColor(hex: self.appTheme.homePage.agendaBg, alpha: 1.0)
        if calendarType == .week{
            coloring(label: self.lbl_weeklyView)
            weeklyTick.isHidden = false
            monthlyTick.isHidden = true
            yearlyTick.isHidden = true
        }else{
            coloring(label: self.lbl_monthlyView)
            weeklyTick.isHidden = true
            monthlyTick.isHidden = false
            yearlyTick.isHidden = true
        }
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    
    //Remarks Section Is Active:
    func remarks(calendarType: CalendarStyle?) {
        self.menu_view.isHidden = true
        self.sectionID = 4
        buttonBarView.selectedBar.backgroundColor = App.hexStringToUIColor(hex: self.appTheme.homePage.remarkBg, alpha: 1.0)
        if calendarType == .week{
            coloring(label: self.lbl_weeklyView)
            weeklyTick.isHidden = false
            monthlyTick.isHidden = true
            yearlyTick.isHidden = true
        }else{
            coloring(label: self.lbl_monthlyView)
            weeklyTick.isHidden = true
            monthlyTick.isHidden = false
            yearlyTick.isHidden = true
        }
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    
    //Remaks section after dismiss:
    func goToRemarks() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            guard let index = self.controllers.firstIndex(where: {$0 is RemarksViewController}) else{
                return
            }
            self.moveToViewController(at: index)
        }
    }
    
    
    
    
    //Grades Section Is Active:
    func grades() {
        print("configClassLabel3")
        self.menu_view.isHidden = true
        self.sectionID = 5
        buttonBarView.selectedBar.backgroundColor = App.hexStringToUIColor(hex: self.appTheme.homePage.gradeBg, alpha: 1.0)
        self.configClassLabel()
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    
    //TimeTable Section Is Active:
    func timeTable(user: User) {
        print("timetable3")

        self.sectionID = 6
        buttonBarView.selectedBar.backgroundColor = App.hexStringToUIColor(hex: self.appTheme.homePage.timeTableBg, alpha: 1.0)
        
        self.backDelegate?.updateModuleID(moduleID: self.sectionID, userType: self.user.userType)
    }
    
    func timeTableMenu(daysArray: [Day], selected: Int) {
        print("timetable4")

        self.daysArray = daysArray
        self.daysArray.append(Day.init(id: 7, name: "All".localiz(), selected: false))
        var days: [Day] = []
        for day in self.daysArray{
            var dayObject = day
            if day.id == selected{
                dayObject.selected = true
            }else{
                dayObject.selected = false
            }
            days.append(dayObject)
        }
        self.daysArray = days
        self.menuTableView.reloadData()
    }
    
    //Move To Calendar Module is case a disabled module is active for new user:
    func backToCalendar() {
        print("moveToCalendar1")
        moveToCalendar()
    }
    
    func agendaToCalendar() {
        print("moveToCalendar2")
        moveToCalendar()
    }
    
    func remarksToCalendar() {
        print("moveToCalendar3")
        moveToCalendar()
    }
    
    func gradesToCalendar() {
        print("moveToCalendar4")
        moveToCalendar()
    }
    func blendedToCalendar() {
        print("moveToCalendar5")
        moveToCalendar()
    }
    
    func moveToCalendar(){
        
        guard let index = self.controllers.firstIndex(where: {$0 is CalendarViewController}) else{
            return
        }
        moveToViewController(at: index)
    }
    
    // Grades Module:
    // - Update menu items "gradesExamArray"
    func initAverage(exams: [Exam]) {
        self.gradesExamArray = exams
        self.menuTableView.reloadData()
        self.menuTableView.isHidden = true
    }
    
    // Grades Module update view when user close view grades page:
    func showTopView() {
        self.shadowView.isHidden = false
        self.collection_shadow_view.isHidden = false
        self.collectionViewHeightConstraint.constant = 75
        self.topViewHeightConstraint.constant = 128
        self.view.layoutIfNeeded()
    }
    
    // Grades Module update view when user need to open view grades:
    func hideTopView() {
        self.shadowView.isHidden = true
        self.collection_shadow_view.isHidden = true
        self.collectionViewHeightConstraint.constant = 0
        self.topViewHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    /// Description:
    /// - Configure class for employee user based on the active module and privileges.
    /// - Update the selected value on the active module by calling the needed delegate function.
    func configClassLabel(){
        if self.user.userType == 2 || user.userType == 1{
            print("BatchId0: \(self.sectionID)")
            self.classDropDownImageView.isHidden = false
            if self.sectionID == 3{//agenda
                if !self.sectionAgenda.isEmpty{
                    print("agendaBatchId2")
                    let index = self.sectionAgenda.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                    self.classObject = self.sectionAgenda[index]
                    self.lbl_class.text = self.sectionAgenda[index].className
                    self.sectionToAgendaDelegate?.agendaBatchId(user: user, batchId: self.classObject.batchId)
                }else{
                    self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
                    self.lbl_class.text = ""
                }
            }else if self.sectionID == 2{//attendance
                if !self.sectionAttendace.isEmpty {
                    let index = self.sectionAttendace.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                    self.classObject = self.sectionAttendace[index]
                    self.lbl_class.text = self.sectionAttendace[index].className
                    self.sectionToAttendanceDelegate?.attendanceBatchId(batchId: self.classObject.batchId)
                }else{
                    self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
                    self.lbl_class.text = ""
                }
            }else if self.sectionID == 4{//remarks
                if !self.sectionRemarks.isEmpty {
                    let index = self.sectionRemarks.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                    self.classObject = self.sectionRemarks[index]
                    self.lbl_class.text = self.sectionRemarks[index].className
                    self.sectionToRemarksDelegate?.remarksBatchId(batchId: self.classObject.batchId)
                }else{
                    self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
                    self.lbl_class.text = ""
                }
            }else if self.sectionID == 5{//grades
                if !self.sectionGrades.isEmpty{
                    print("gradesbatchid1")
                    let index = self.sectionGrades.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                    self.classObject = self.sectionGrades[index]
                    self.lbl_class.text = self.sectionGrades[index].className
                    print("sectionToGradesDelegate3")
                    self.sectionToGradesDelegate?.gradesBatchId(batchId: self.classObject.batchId)
                }else{
                    self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
                    self.lbl_class.text = ""
                }
            }else if self.sectionID == 1{//Calendar
                if !self.sectionCalendar.isEmpty{
                    print("calendarBatchId2")
                    let index = self.sectionCalendar.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                    self.classObject = self.sectionCalendar[index]
                    self.lbl_class.text = self.sectionCalendar[index].className
                    self.sectionDelegate?.calendarBatchId(batchId: self.classObject.batchId)
                }else{
                    self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
                    self.lbl_class.text = ""
                }
            }
            else if self.sectionID == 15{
                if !self.sectionBlended.isEmpty{
                    print("blendedbatchid:");
                    let index = self.sectionBlended.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                    self.classObject = self.sectionBlended[index]
                    self.lbl_class.text = self.sectionBlended[index].className
                    print("sectionToBlendedLearningDelegate4")
                    self.sectionToBlendedLearningDelegate?.blendedBatchId(user: user, allClasses: self.sectionBlended, batchId: self.classObject.batchId, className: self.classObject.className)
                }else{
                    self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
                    self.lbl_class.text = ""
                }
            }
            else if self.sectionID == 6{
                if !self.sectionTimetable.isEmpty{
                    print("timeTablebatchid:");
                    let index = self.sectionTimetable.firstIndex(where: {$0.batchId == self.classObject.batchId}) ?? 0
                    self.classObject = self.sectionTimetable[index]
                    self.lbl_class.text = self.sectionTimetable[index].className
                    print("sectionToTimetableDelegate4")
                    self.sectionToTimeTableDelegate?.timeTableBatchId(user: user, batchId: self.classObject.batchId)
                }else{
                    self.classObject = Class(batchId: 0, className: "", imperiumCode: "")
                    self.lbl_class.text = ""
                }
            }
            else{//timetable?
                print("timetable5")

                if !self.user.classes.isEmpty && self.user.classes.count > classIndex{
                    self.classObject = self.user.classes[classIndex]
                    lbl_class.text = self.user.classes[classIndex].className

                }else{
                    print("classindex3")
                    classIndex = 0
                    self.classObject = self.user.classes.first ?? Class(batchId: 0, className: "", imperiumCode: "")
                    lbl_class.text = self.classObject.className
                }
            }
        }else{//other users
            print("classindex4")
            classIndex = 0
            self.classObject = Class.init(batchId: self.user.batchId, className: self.user.className, imperiumCode: self.user.imperiumCode)
            lbl_class.text = self.classObject.className
        }
    }
}


// MARK: - API Calls:
extension SectionVC{
    
    /// Description:
    /// - Get all classes data in case of employee.
    /// - Call saveUserData function to update modules with the selected user.
    func getUserDetail(user: User){
        print("getUserDetail222")
        if self.user.userType == 2 || user.userType == 1{
            self.getSections(user: self.user, completion: { (allClasses) in
                print("classindex5")
                self.classIndex = 0
                self.saveUserData()
                print("configClassLabel4")

                self.configClassLabel()
            })
        }else{
            self.saveUserData()
        }
    }
    
    /// Description: Get SChool Info
    /// - Call "getSchoolURL" API to get the selected user's school info.
    /// - Update school data into Core Data.
    /// - Call getTabBarIcons function based on the selected user type to get colors and icons data.
    func getSchoolInfo(activationCode: String){
        Request.shared.GetSchoolURL(activationCode: activationCode) { (message, schoolData, status) in
            if status == 200{
                let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
                let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
                let school = try? managedContext.fetch(userFetchRequest) as! [SCHOOL]
                var schoolIds: [Int] = []
                if school != nil{
                    for object in school! {
                        schoolIds.append(Int(object.id))
                    }
                }
                if !schoolIds.contains(schoolData.id){
                    let schoolEntity = NSEntityDescription.entity(forEntityName: "SchoolData", in: managedContext)
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
                self.buttonBarView.reloadData()
                self.backDelegate?.switchSchool(schoolInfo: self.schoolInfo)
                self.customizeView()
                switch self.user.userType{
                case 1,2:
                    if self.schoolInfo != nil && !self.user.classes.isEmpty{
                        self.getTabBarIcons(schoolId: "\(self.schoolInfo!.id)", classId: self.user.classes[self.classIndex].batchId, code: self.user.classes[self.classIndex].imperiumCode, gender: self.user.gender)
                    }
                    if self.sectionID == 4 && self.user.privileges.contains(App.subjectMasterPrivilege){
                        if !self.allClasses.isEmpty{
//                            self.lbl_class.text = self.allClasses.first?.className ?? ""
                            self.lbl_class.text = self.allClasses.first?.className ?? ""
                        }
                    }
                case 3,4:
                    self.getTabBarIcons(schoolId: "\(self.schoolInfo?.id ?? 0)", classId: self.user.classes.first?.batchId ?? 0, code: self.user.imperiumCode, gender: self.user.gender)
                default:
                    break
                }
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                if let viewWithTag = self.view.viewWithTag(100){
                    viewWithTag.removeFromSuperview()
                }
            }
        }
    }
    
    /// Description: Get Class Icons
    /// - Call "getClassIcons" API to get colors and icons data.
    /// - Update colors and icons variable in each module by calling the needed delegate functions.
    func getTabBarIcons(schoolId: String, classId: Int, code: String, gender: String){
        print("subject selected here")
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.GetClassIcons(user: self.user, schoolID: schoolId, classID: classId, code: code, gender: gender) { (message,data,status) in
            if status == 200{
                print("sectionToGradesDelegate4: \(self.sectionID)")
                self.appTheme = data
                print("app app theme2: \(self.appTheme)")

                self.buttonBarView.reloadData()
                switch(self.sectionID){
                case 2:
                    self.sectionDelegate?.updateCalendarTheme(calendarTheme: self.appTheme.calendarTheme)
                    break
                case 3:
                    self.sectionToAgendaDelegate?.updateAgendaTheme(theme: self.appTheme)
                    break
                case 5:
                    self.sectionToGradesDelegate?.updateGradesTheme(appTheme: self.appTheme)
                    break
                case 15:
                    self.sectionToBlendedLearningDelegate?.updateBlendedTheme(theme: self.appTheme)
                    break
                case 8:
                    self.sectionToAttendanceDelegate?.updateAttendanceTheme(appTheme: self.appTheme)
                    break
                case 9:
                    self.sectionToRemarksDelegate?.updateRemarkTheme(theme: self.appTheme)
                    break
                default:
                    self.sectionDelegate?.updateCalendarTheme(calendarTheme: self.appTheme.calendarTheme)
                    break
                }
                print("sectionToBlendedLearningDelegate5")
                self.backDelegate?.updateTabBarIcon(theme: self.appTheme)
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
    
    /// Description: Get Sections
    /// - Get all classes data.
    func getSections(user: User, completion: @escaping([Class]) -> Void){

        Request.shared.getSectionsPerModule(user: user) { (message, sectionData, status) in
            if status == 200{
                self.sectionCalendar.removeAll()
                self.sectionAgenda.removeAll()
                self.sectionTimetable.removeAll()
                self.sectionGrades.removeAll()
                self.sectionAttendace.removeAll()
                self.sectionRemarks.removeAll()
                self.sectionBlended.removeAll()
                for section in sectionData!{
                    let classIn = Class.init(batchId: section.batchId, className: section.displayName, imperiumCode: section.imperiumCode)
                   
                    switch section.module{
                    case 1://calendar
                        print("batchid1: \(classIn.className)")
                        self.sectionCalendar.append(classIn)
                    case 2://attendance
                        self.sectionAttendace.append(classIn)
                    case 3://agenda
                        self.sectionAgenda.append(classIn)
                        self.sectionBlended.append(classIn)

                    case 4://remarks
                        self.sectionRemarks.append(classIn)
                    case 5://grades
                        self.sectionGrades.append(classIn)
                    case 6:
                        self.sectionTimetable.append(classIn)
                    default:
                        self.sectionCalendar.append(classIn)
                    }
                    
                }
                if self.sectionCalendar.count > 0{
                    print("calendarBatchId1")
                    self.sectionDelegate?.calendarBatchId(batchId: self.sectionCalendar.first?.batchId ?? 0)
                }
                if self.sectionAttendace.count > 0{
                    self.sectionToAttendanceDelegate?.attendanceBatchId(batchId: self.sectionAttendace.first?.batchId ?? 0)
                }
                if self.sectionAgenda.count > 0{
                    self.sectionToAgendaDelegate?.agendaBatchId(user: user, batchId: self.sectionAgenda.first?.batchId ?? 0)
                }
                if self.sectionTimetable.count > 0{
                    self.sectionToTimeTableDelegate?.timeTableBatchId(user: user, batchId: self.sectionTimetable.first?.batchId ?? 0)
                }
                if self.sectionRemarks.count > 0{
                    self.sectionToRemarksDelegate?.remarksBatchId(batchId: self.sectionRemarks.first?.batchId ?? 0)
                }
                if self.sectionGrades.count > 0{
                    print("sectionToGradesDelegate5")
                    self.sectionToGradesDelegate?.gradesBatchId(batchId: self.sectionGrades.first?.batchId ?? 0)
                }
                if self.sectionBlended.count > 0{
                    print("batchid2: \(self.sectionBlended.first?.batchId ?? 0)")
                    print("sectionToBlendedLearningDelegate6")
                    self.sectionToBlendedLearningDelegate?.blendedBatchId(user: user, allClasses: self.sectionBlended, batchId: self.sectionBlended.first?.batchId ?? 0, className: self.sectionBlended.first?.className ?? "")
                }
                
                self.allClasses = self.sectionCalendar
                completion(self.allClasses)
            }
        }
    }
    
    /// Description: Update User Data in modules:
    /// - Update user infos into all modules page by calling the needed function for each case.
    func saveUserData(){
        print("entered userdetails1")

        self.switchStudent()
        self.studentIconsCollectionView.reloadData()
        self.getSchoolInfo(activationCode: self.schoolInfo.code)
        
        let clas = self.user.classes.first
        switch self.user.userType{
        case 1,2:
            //Calendar:
            let emptyChildren = Children(gender: "", cycle: "", photo: "", firstName: "", lastName: "", batchId: 0, imperiumCode: "", className: "", admissionNo: "", bdDate: Date(), isBdChecked: false)
            if self.user.classes.isEmpty{
                let emptyClass = Class(batchId: 0, className: "", imperiumCode: "")
                self.user.classes = [emptyClass]
            }
            print("delegate1")
            self.sectionDelegate?.switchCalendarChildren(user: self.user, batchId: self.user.classes[self.classIndex].batchId, children: emptyChildren)
            
            //Attendance:
            var attendanceClass = self.user.classes[self.classIndex]
            if attendanceClass.batchId == 0{
                if !self.allClasses.isEmpty{
                    attendanceClass = self.allClasses.first!
                }
            }
            self.sectionToAttendanceDelegate?.switchAttendanceChildren(user: self.user, classObject: attendanceClass, children: emptyChildren)
            
            //Agenda:
            var agendaClass = self.user.classes[self.classIndex]
            print("agendaClass: \(agendaClass)")
            if agendaClass.batchId == 0{
                if !self.allClasses.isEmpty{
                    agendaClass = self.allClasses.first!
                }
            }
            self.sectionToAgendaDelegate?.switchAgendaChildren(user: self.user, batchId: agendaClass.batchId, children: emptyChildren)
            
            //Remarks:
            if self.user.classes[self.classIndex].batchId == 0{
                if !self.allClasses.isEmpty{
                    self.sectionToRemarksDelegate?.switchRemarksChildren(user: self.user, batchId: self.allClasses.first?.batchId ?? 0, children: emptyChildren)
                }
            }else{
                self.sectionToRemarksDelegate?.switchRemarksChildren(user: self.user, batchId: self.user.classes[self.classIndex].batchId, children: emptyChildren)
            }
            
            //Grades:
            var gradesClass = self.user.classes[self.classIndex]
            if gradesClass.batchId == 0{
                if !self.allClasses.isEmpty{
                    gradesClass = self.allClasses.first!
                }
            }
            print("sectionToGradesDelegate6")
            self.sectionToGradesDelegate?.switchGradesChildren(user: self.user, batchId: gradesClass.batchId, children: emptyChildren)
            
            //TimeTable:
            print("timetable6")

            self.sectionToTimeTableDelegate?.switchTimeTableChildren(user: self.user, batchId: self.user.classes[self.classIndex].batchId, children: emptyChildren)
            
            self.sectionToGalleryDelegate?.switchGalleryChildren(user: self.user, batchId: self.user.classes[self.classIndex].batchId, children: emptyChildren)
            
            self.sectionToFeesDelegate?.switchFeesChildren(user: self.user, batchId: self.user.classes[self.classIndex].batchId, children: emptyChildren)
            
            self.sectionToTeamsDelegate?.switchTeamsChildren(user: self.user, batchId: self.user.classes[self.classIndex].batchId, children: emptyChildren)
            
            self.sectiontoVirtualDelegate?.switchVirtualChildren(user: self.user, batchId: self.user.classes[self.classIndex].batchId, children: emptyChildren)
            
            
            var blendedClass = self.user.classes[self.classIndex]
            if blendedClass.batchId == 0{
                if !self.allClasses.isEmpty{
                    blendedClass = self.allClasses.first!
                }
            }
            
            if self.user.classes[self.classIndex].batchId == 0{
                if !self.allClasses.isEmpty{
                    print("sectionToBlendedLearningDelegate7")
                    self.sectionToBlendedLearningDelegate?.switchBlendedLearning(user: self.user, batchId: self.allClasses.first?.batchId ?? 0, children: emptyChildren)
                }
            }else{
                print("sectionToBlendedLearningDelegate8")
                self.sectionToBlendedLearningDelegate?.switchBlendedLearning(user: self.user, batchId: self.user.classes[self.classIndex].batchId, children: emptyChildren)
            }

        case 3:
            //Calendar:
            let emptyChildren = Children(gender: "", cycle: "", photo: "", firstName: "", lastName: "", batchId: 0, imperiumCode: "", className: "", admissionNo: "", bdDate: Date(), isBdChecked: false)
            print("delegate2")
            self.sectionDelegate?.switchCalendarChildren(user: self.user, batchId: clas?.batchId, children: emptyChildren)
            
            //Attendance:
            self.sectionToAttendanceDelegate?.switchAttendanceChildren(user: self.user, classObject: clas, children: emptyChildren)
            
            //Agenda:
            self.sectionToAgendaDelegate?.switchAgendaChildren(user: self.user, batchId: clas?.batchId, children: emptyChildren)
            
            //Remarks:
            self.sectionToRemarksDelegate?.switchRemarksChildren(user: self.user, batchId: clas?.batchId, children: emptyChildren)
            
            //Grades:
            print("sectionToGradesDelegate7")
            self.sectionToGradesDelegate?.switchGradesChildren(user: self.user, batchId: clas?.batchId, children: emptyChildren)
            
            //TimeTable:
            print("timetable7")

            self.sectionToTimeTableDelegate?.switchTimeTableChildren(user: self.user, batchId: clas?.batchId, children: emptyChildren)
            
            self.sectionToGalleryDelegate?.switchGalleryChildren(user: self.user, batchId: clas?.batchId, children: emptyChildren)
           
            self.sectionToFeesDelegate?.switchFeesChildren(user: self.user, batchId: clas?.batchId, children: emptyChildren)
           
            self.sectionToTeamsDelegate?.switchTeamsChildren(user: self.user, batchId: clas?.batchId, children: emptyChildren)
            
            self.sectiontoVirtualDelegate?.switchVirtualChildren(user: self.user, batchId: clas?.batchId, children: emptyChildren)
            print("sectionToBlendedLearningDelegate9")
            self.sectionToBlendedLearningDelegate?.switchBlendedLearning(user: self.user, batchId: clas?.batchId, children: emptyChildren)

        case 4:
            //Calendar:
            print("delegate3")
            self.sectionDelegate?.switchCalendarChildren(user: self.user, batchId: clas?.batchId, children: self.child)
            
            //Attendance:
            self.sectionToAttendanceDelegate?.switchAttendanceChildren(user: self.user, classObject: clas, children: self.child)
            
            //Agenda:
            self.sectionToAgendaDelegate?.switchAgendaChildren(user: self.user, batchId: clas?.batchId, children: self.child)
            
            //Remarks:
            self.sectionToRemarksDelegate?.switchRemarksChildren(user: self.user, batchId: clas?.batchId, children: self.child)
            
            //Grades:
            print("sectionToGradesDelegate8")
            self.sectionToGradesDelegate?.switchGradesChildren(user: self.user, batchId: clas?.batchId, children: self.child)
            
            //TimeTable:
            print("timetable8")

            self.sectionToTimeTableDelegate?.switchTimeTableChildren(user: self.user, batchId: clas?.batchId, children: self.child)
            
            self.sectionToGalleryDelegate?.switchGalleryChildren(user: self.user, batchId: clas?.batchId, children: self.child)
                      
            self.sectionToFeesDelegate?.switchFeesChildren(user: self.user, batchId: clas?.batchId, children: self.child)
            
            self.sectionToTeamsDelegate?.switchTeamsChildren(user: self.user, batchId: clas?.batchId, children: self.child)

            self.sectiontoVirtualDelegate?.switchVirtualChildren(user: self.user, batchId: clas?.batchId, children: self.child)
            print("sectionToBlendedLearningDelegate10")
            self.sectionToBlendedLearningDelegate?.switchBlendedLearning(user: self.user, batchId: clas?.batchId, children: self.child)
                  
        default:
            break
        }
    }
    
}

/// Description:
/// - TableView is used for Grades and TimeTable menu data.
// MARK: - UITableViewDelegate, UITableViewDataSource:
extension SectionVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionID == 6{
            return daysArray.count
        }
        return gradesExamArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "examReuse")
        let titleLabel = cell?.viewWithTag(1) as! UILabel
        let tickImageView = cell?.viewWithTag(2) as! UIImageView
        
        if sectionID == 6{
            let day = daysArray[indexPath.row]
            let name = day.name
            
            titleLabel.text = name
            if day.selected{
                tickImageView.isHidden = false
                titleLabel.textColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
            }else{
                tickImageView.isHidden = true
                titleLabel.textColor = App.hexStringToUIColorCst(hex: "#5d5d5d", alpha: 1.0)
            }
        }else{
            titleLabel.text = gradesExamArray[indexPath.row].name
            if gradesExamArray[indexPath.row].selected{
                tickImageView.isHidden = false
                titleLabel.textColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
            }else{
                tickImageView.isHidden = true
                titleLabel.textColor = App.hexStringToUIColorCst(hex: "#5d5d5d", alpha: 1.0)
            }
        }
        
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sectionID == 6{
            daysArray = daysArray.map({
                var day = $0
                day.selected = false
                return day
            })
            daysArray[indexPath.row].selected = true
            menuTableView.reloadData()
            print("timetable9")

            self.sectionToTimeTableDelegate?.updateTimeTable(day: daysArray[indexPath.row])
            menuTableView.isHidden = true
        }else{
            gradesExamArray = gradesExamArray.map({
                var exam = $0
                exam.selected = false
                return exam
            })
            gradesExamArray[indexPath.row].selected = true
            print("sectionToGradesDelegate9")
            sectionToGradesDelegate?.updateAverage(exam: gradesExamArray[indexPath.row])
            menuTableView.reloadData()
            menuTableView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
}

//Handle Notifications:
extension SectionVC{
    func openModule(sectionID: Int){
        switch sectionID{
        case App.NotiAttendance:
            guard let index = self.controllers.firstIndex(where: {$0 is AttendanceViewController}) else{
                return
            }
            moveToViewController(at: index)
        case App.NotiAgenda:
            guard let index = self.controllers.firstIndex(where: {$0 is AgendaViewController}) else{
                return
            }
            moveToViewController(at: index)
        case App.NotiExamination:
            print("entered grades module2")
            guard let index = self.controllers.firstIndex(where: {$0 is GradesViewController}) else{
                return
            }
            moveToViewController(at: index)
        case App.NotiRemarks:
            guard let index = self.controllers.firstIndex(where: {$0 is RemarksViewController}) else{
                return
            }
            moveToViewController(at: index)
        case App.NotiCalendar:
            guard let index = self.controllers.firstIndex(where: {$0 is CalendarViewController}) else{
                return
            }
            moveToViewController(at: index)
        case App.NotiInternalMessages:
            guard let index = self.controllers.firstIndex(where: {$0 is MessagesViewController}) else{
                return
            }
            moveToViewController(at: index)
            
        case App.NotiBlended:
            guard let index = self.controllers.firstIndex(where: {$0 is BlendedLearningViewController}) else{
                return
            }
            moveToViewController(at: index)
            
        default:
            break
        }
    }
}
