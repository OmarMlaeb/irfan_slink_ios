//
//  AgendaViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/17/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import PWSwitch
import ActionSheetPicker_3_0
import SDWebImage
import SwipeCellKit
import ALCameraViewController
import BSImagePicker
import Photos
import Alamofire
import MobileCoreServices
import CropViewController
import TOCropViewController
/// Description:
/// - Delegate from Agenda page to Section page.
protocol AgendaViewControllerDelegate{
    func agenda(calendarType: CalendarStyle?)
    func agendaToCalendar()
}

enum CalendarStyle{
    case week
    case month
}

class AgendaViewController: CollapsableTableViewController, ChartViewDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var agendaTableView: UITableView!
    
    var croppingStyle = CropViewCroppingStyle.default
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    
    var agendaDelegate: AgendaViewControllerDelegate?
    var imagePicker = UIImagePickerController()
    var weekEvents: [Event] = []
    var filteredEvents: [Event] = []
    var eventsArray: [AgendaDetail] = []
    var agendaForEdit : AgendaDetail!
    var events: [Event] = []
    var currentDate = ""
    var eventTitle = ""
    var selectedDate: [String] = []
    var startDate = "01-09-1900"
    var endDate = "30-09-2500"
    var calendarStyle: CalendarStyle?
    var tempCalendarStyle: CalendarStyle?
    var user: User!
    var teacherEdit = false
    var teacherStudentsArray: [CalendarEventItem] = []
    var tempStdArray: [CalendarEventItem] = []
    var agendaType = AgendaDetail.agendaType.self
    var editType = 2 //Classwork
    var teacherEditEvent: [Event] = []
    var addEvent: AgendaExam!
    var teacherSubjectArray: [Subject] = []
    var teacherTermsArray: [Subject] = []
    var assessmentsType: [AssessmentType] = []
    var classId: Int!
    var batchId: Int!
    var selectCalendarDate = ""
    var allStudents = true
    var agendaTheme: AgendaTheme!
    var item: [[CalendarEventItem]] = []
    var percentage: [Double] = [0, 0, 100,0]
    var workload = 0.0
    var selectedStudentd: [String] = []
    var typeName = ""
    var selectedGroup = ""
    var fileType = ""
    var editStudents = true;
    var enableSubmissions = false;
    var enableLateSubmissions = false;
    var enableDiscussions = false;
    var enableGrading = false;

    
    var chartColors: [NSUIColor] = [App.hexStringToUIColorCst(hex: "#a171ff", alpha: 1.0), App.hexStringToUIColorCst(hex: "#faae21", alpha: 1.0), UIColor.clear, App.hexStringToUIColorCst(hex: "#fa487a", alpha: 1.0)]
    var chartLabel: [String] = ["Quiz".localiz(), "Exam".localiz(), "Empty hours".localiz(), "Homework".localiz()]
    var allEvent = Event.init(id: 0, icon: "", color: "", counter: 0, type: nil, date: "", percentage: 0, detail: [], agendaDetail: [])
    var agendaWorkload = AgendaWorkload(homeworkLoad: 0, classworkLoad: 0, quizLoad: 0, examLoad: 0)
    var selectedSubject = Subject.init(id: 0, name: "", code: "", sectionId: 0, sectionName: "", color: "", imperiumCode: "")
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    var pdfURL : URL!
    var compressedDataToPass: NSData!
    var selectedImage : UIImage = UIImage()
    var isFileSelected = false
    var isSelectedImage = false
    var isCalendarEditing = false
    var textSubject = ""
    var refreshControl = UIRefreshControl()
    var resetData = false
    var overrideDate = ""
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")
    var tickPressed = false
   
    var arrayType:[AgendaDetail] = []
    var titleType = ""
    var filename: String = "SLink"


    func getTypeLabel(type: Int) -> String {
        switch type{
        case 1:
            return "Homework".localiz()
        case 2:
            return "Classwork".localiz()
        case 3:
            return "Assessment".localiz()
        case 4:
            return "Exam".localiz()
        case 5:
            return "Events".localiz()
        case 6:
            return "Holidays".localiz()
        case 7:
            return "Dues".localiz()
        case 8:
            return "All upcoming".localiz()
        default:
            return "Reserved"
        }
    }
    
    func getTypeIndex(type: String) -> Int {
        switch type{
        case "Homework":
            return 1
        case "Classwork":
            return 2
        case "Assessment":
            return 3
        case "Exam":
            return 4
        case "Events":
            return 5
        case "Holidays":
            return 6
        case "Dues":
            return 7
        case "All Upcoming":
            return 8
        default:
            return 0
        }
    }
    
    @objc func openOnlineExam(sender: UIButton){
        let cell = sender.superview?.superview?.superview?.superview?.superview as! UITableViewCell
          let index = self.agendaTableView.indexPath(for: cell)
        
        var event: AgendaDetail!
        
        if calendarStyle == .week{
            event = self.weekEvents[index!.section-2].agendaDetail[index!.row]
        }else{
            event = eventsArray[index!.row]
        }
        var url = event.link_to_join
        

            
//        let urlfixed = url.replacingOccurrences(of: " ", with: "%20")
        
        guard let safari = URL(string: url) else { return }
        UIApplication.shared.open(safari)
    
    }
    
    func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for \(title): \(timeElapsed) s.")
    }
    
    fileprivate lazy var onlineExamDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var pickerDateFormatter1: DateFormatter = {
                  let formatter = DateFormatter()
                  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                  formatter.locale = Locale(identifier: "en_US_POSIX")
          //        formatter.locale = Locale(identifier: "\(self.languageId)")
                  return formatter
              }()
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var ddateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter1Locale: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var pickerDateResultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMMM yyyy"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var pickerDateResultFormatterLocale: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMMM yyyy"
        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter11: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter11Locale: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dayFormatterLocale: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var pickerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var attachmentPickertime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var pickerDateFormatterLocale: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    var fillDefaultColors: [String: [UIColor]] = [:]
    var canRefresh = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarStyle = .week
        tempCalendarStyle = .week
        
        agendaTableView.delegate = self
        agendaTableView.dataSource = self
        agendaTableView.tableFooterView = UIView()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localiz())
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        agendaTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        agendaTableView.isHidden = true
        imagePicker.delegate = self
        initTeacherEdit()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -70 { //change 100 to whatever you want
            if canRefresh && !self.refreshControl.isRefreshing {
                self.canRefresh = false
                self.refreshControl.beginRefreshing()
                self.refresh() // your viewController refresh function
            }
        }else if scrollView.contentOffset.y >= 0 {
            self.canRefresh = true
        }
    }
    
    @objc func refresh() {
       // Code to refresh table view
        SectionVC.didLoadAgenda = false
        self.getAgendaData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    /// Description:
    /// - Call getSubjects, getTerms and getSectionStudent functions when user open the page.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendarStyle = .week
        tempCalendarStyle = .week
        self.agendaDelegate?.agenda(calendarType: self.calendarStyle)
    }
    
    /// Description:
    /// - Set calendar default scope to weekly view.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            if let calendarView = self.agendaTableView.viewWithTag(4) as? FSCalendar{
                let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
                let monthLabel = self.agendaTableView.viewWithTag(3) as! UILabel
                if self.calendarStyle == .week{
                    calendarView.setScope(.week, animated: false)
                    calendarHeight?.constant = 90
                    monthLabel.text = "\n"
                }else{
                    calendarView.setScope(.month, animated: false)
                    calendarHeight?.constant = 250
                }
                calendarView.deselect(Date())
                self.reloadTableView()
                self.agendaTableView.isHidden = false
                
                //set date if from notification
                if self.overrideDate != ""{
                    let goToDate = self.ddateFormatter.date(from: self.overrideDate)
                    calendarView.select(goToDate, scrollToDate: true)
                }
                
                self.getAgendaData()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func attachDocument() {
//        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet, kUTTypePNG, kUTTypeJPEG, kUTTypeGIF, "com.microsoft.word.doc" as CFString, "org.openxmlformats.wordprocessingml.document" as CFString, "org.openxmlformats.presentationml.presentation" as CFString, "org.openxmlformats.presentationml.presentation.macroenabled" as CFString, "org.openxmlformats.presentationml.slideshow.macroenabled" as CFString, "org.openxmlformats.presentationml.template" as CFString, "org.openxmlformats.presentationml.template.macroenabled" as CFString, "org.openxmlformats.presentationml.slideshow" as CFString,"com.microsoft.powerpoint.​ppt" as CFString,"com.microsoft.powerpoint.​pot" as CFString, "com.microsoft.powerpoint.​pptx" as CFString,kUTTypeMovie, kUTTypeAudio, kUTTypeVideo, kUTTypeText, kUTTypeGIF, kUTTypePresentation]
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        
        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = false
        }
        
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        
        present(importMenu, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.pdfURL = urls[0]
        self.isFileSelected = true
        self.isSelectedImage = false
        self.filename = self.pdfURL.lastPathComponent
        self.reloadTableView()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    /// Description:
    /// - Used to group and format events dates with their colors and event details in case the calendar view is weekly and monthly, and calculate the workload.
    // MARK: initialize calendar dates
    func initializeCalendarDates(){
        var datesArray: [CalendarDate] = []
        
        let calendarView = agendaTableView?.viewWithTag(4) as? FSCalendar
        for event in events{
            for detail in event.agendaDetail{
                let date = CalendarDate(date: detail.date, color: event.color)
                datesArray.append(date)
            }
        }
        
        let dateArray = Dictionary(grouping: datesArray, by: { $0.date })
        
        var dic: [String: [UIColor]] = [:]
        self.selectedDate.removeAll()
        for key in dateArray{
            self.selectedDate.append(key.key)
            var colors: [UIColor] = []
            for color in key.value{
                colors.append(App.hexStringToUIColor(hex: color.color, alpha: 1.0))
            }
            dic[key.key] = colors
        }
        fillDefaultColors = dic
        print("currentdate: \(self.currentDate)")
        if self.currentDate != ""{
            self.eventsArray = []
            for event in self.events{
                for detail in event.agendaDetail{
                    if detail.date == self.currentDate{
                        self.eventsArray.append(detail)
                    }
                }
            }
            
            percentage = [0,0,100,0]
            let groupedEvents = Dictionary(grouping: self.eventsArray, by: {$0.type})
            print("maher1")
            for events in groupedEvents{
                switch events.key{
                case self.agendaType.Assessment.rawValue:
                    for event in events.value{
                        percentage[0] += event.percentage
                    }
                case self.agendaType.Exam.rawValue:
                    for event in events.value{
                        percentage[1] += event.percentage
                    }
                case self.agendaType.Homework.rawValue:
                    for event in events.value{
                        percentage[3] += event.percentage
                    }
                default:
                    break
                }
            }
            self.workload = percentage[0] + percentage[1] + percentage[3]
            percentage[2] = 100 - self.workload
            
            let dayDate = self.dateFormatter1.date(from: self.currentDate) ?? Date()
            self.eventTitle = self.dateFormatter1Locale.string(from: dayDate)
            
            //changed
            //self.currentDate = ""
        }else{
            print("maher2")
            if let calendar = calendarView, calendar.scope == .week{
                print("maher3")
                self.calendarStyle = .week
                self.weekEvents = []
                var weekDetails: [AgendaDetail] = []
                for event in self.events{
                    for detail in event.agendaDetail{
                        print("week detail: \(detail)")
                        weekDetails.append(detail)
                    }
                }
                print("maher4: ")
                let myArrayOfTuples = Dictionary(grouping: weekDetails, by: { $0.date })
                print("dates dates1: \(myArrayOfTuples)")
                let dayArray = myArrayOfTuples.sorted{
                    guard let d1 = $0.key.shortDateUS, let d2 = $1.key.shortDateUS else { return false }
                    print("d1: \(d1)")
                    print("d2: \(d2)")

                    return d1 < d2
                }

                
                print("dates dates2: \(dayArray)")  // [("12-10-2014", 12), ("03-28-2015", 10), ("04-07-2015", 8), ("04-09-2015", 4), ("04-10-2015", 6), ("12-10-2015", 12)]\n"

                for tuple in myArrayOfTuples {
                    print(tuple)
                }
                
                for day in dayArray{
                    let event = Event(id: 0, icon: "", color: "", counter: 0, type: nil, date: day.key, percentage: 0, detail: [], agendaDetail: day.value)
                    self.weekEvents.append(event)
                }
                print("maher5")
                let dayDate = self.dateFormatter1.date(from: self.currentDate) ?? Date()
                self.eventTitle = self.dateFormatter1Locale.string(from: dayDate)
                
                self.currentDate = ""
            }
        }
        // Configure Filtered Events:
        print("maher6")
        self.filteredEvents = self.events.filter({!$0.agendaDetail.isEmpty})
        self.filteredEvents = Array(Set(self.filteredEvents))
        for event in self.filteredEvents{
            let detail = event.agendaDetail
            for det in detail{
                print("maher7: \(det.title)")

            }
        }
//        self.filteredEvents = self.filteredEvents.sorted(by: { $0.id > $1.id})
        self.reloadTableView()
    }
    
    /// Description:
    /// - Initialize employee edit events.
    func initTeacherEdit(){
        teacherEditEvent = []
        var event = Event(id: 1, icon: self.agendaTheme.examIcon, color: self.agendaTheme.examColor, counter: 0, type: self.agendaType.Exam.rawValue, date: "", percentage: 0, detail: [], agendaDetail: [])
        teacherEditEvent.append(event)
        
        event = Event(id: 2, icon: self.agendaTheme.homeworkIcon, color: self.agendaTheme.homeworkColor, counter: 0, type: self.agendaType.Homework.rawValue, date: "", percentage: 0, detail: [], agendaDetail: [])
        teacherEditEvent.append(event)
        
        event = Event(id: 3, icon: self.agendaTheme.classworkIcon, color: self.agendaTheme.classworkColor, counter: 0, type: self.agendaType.Classwork.rawValue, date: "", percentage: 0, detail: [], agendaDetail: [])
        teacherEditEvent.append(event)
        
        event = Event(id: 4, icon: self.agendaTheme.quizIcon, color: self.agendaTheme.quizColor, counter: 0, type: self.agendaType.Assessment.rawValue, date: "", percentage: 0, detail: [], agendaDetail: [])
        teacherEditEvent.append(event)

        let date = dateFormatter1.string(from: Date())
        let time = App.pickerTimeFormatter.string(from: Date())
        addEvent = AgendaExam(id: 0, title: "", type: "Classwork", students: [], subjectId: 0, startDate: date, startTime: time, endDate: date, endTime: time, description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: false, enableLateSubmissions: false, enableDiscussions: false, enableGrading: false, estimatedTime: 0)
    }
    
    /// Description:
    /// - Configure TableViewExpandCollapse header cell:
    override func sectionHeaderNibName() -> String? {
        return "ProductHeader"
    }
    
    override func singleOpenSelectionOnly() -> Bool {
        return true
    }
    
    override func collapsableTableView() -> UITableView? {
        return agendaTableView
    }
}

// MARK: - XLPagerTabStrip Method:
// Initialize agenda module.
extension AgendaViewController: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Agenda".localiz(), counter: "", image: UIImage(named: "agenda"), backgroundViewColor: App.hexStringToUIColorCst(hex: "#e39cf4", alpha: 1.0), id: App.agendaID)
    }
    
}

extension AgendaViewController: SwipeTableViewCellDelegate, UITextViewDelegate{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
       
            switch user.userType{
           
            case 1,2:
                if teacherEdit{
                    switch editType{
                    case self.agendaType.Assessment.rawValue:
                        return 17
                    case self.agendaType.Exam.rawValue:
                        return 17
                    default:
                       return 17
                    }
                }else{
                    if weekEvents.isEmpty && eventsArray.isEmpty{
                        if !selectCalendarDate.isEmpty{
                            return 3
                        }else{
                            return 3
                        }
                    }else if !self.selectCalendarDate.isEmpty{
                        switch calendarStyle{
                        case .week?:
                            return self.weekEvents.count + 3
                        case .month?:
                            return 4
                        case .none:
                            return 4
                        }
                    }else{
                        switch calendarStyle{
                        case .week?:
                            return self.weekEvents.count + 2
                        case .month?:
                            return 3
                        case .none:
                            return 3
                        }
                    }
                }
            default://student
                switch calendarStyle{
                case .week?:
                    return self.weekEvents.count + 2
                case .month?:
                    return 3
                case .none:
                    return 3
                }
            }

      
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section{
            case 0:
                return 1
            case 1:
                return 1
            default:
                switch user.userType{
                
                case 1,2:
                    switch section{
                    case 0,1:
                        return 1
                    case 2:
                        if !self.selectCalendarDate.isEmpty || teacherEdit{
                            return 1
                        }else{
                            if calendarStyle == .week{
                                if self.weekEvents.isEmpty {
                                    return 1
                                }else{
                                    return self.weekEvents[section-2].agendaDetail.count
                                }
                            }else{
                                if self.eventsArray.isEmpty{
                                    return 1
                                }else{
                                    return eventsArray.count
                                }
                            }
                        }
                    default:
                        if !teacherEdit{
                            if calendarStyle == .week{
                                if selectCalendarDate.isEmpty{
                                    return self.weekEvents[section-2].agendaDetail.count
                                }
                                return self.weekEvents[section-3].agendaDetail.count
                            }else{
                                return eventsArray.count
                            }
                        }
                        if section == 8 {
                            let menuSection = self.model?[section-8]
                            return (menuSection?.isVisible ?? false) ? menuSection!.items.count : 0
                        }
                        return 1
                    }
                default:
                    if calendarStyle == .week{
                        return self.weekEvents[section-2].agendaDetail.count
                    }else{
                        return eventsArray.count
                    }
                }
            }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            switch indexPath.section{
                    case 0:
                        let calendarCell = agendaTableView.dequeueReusableCell(withIdentifier: "calendarReuse")
                        let calendarBackButton = calendarCell?.viewWithTag(1) as! UIButton
                        let calendarNextButton = calendarCell?.viewWithTag(6) as! UIButton
                        let monthLabel = calendarCell?.viewWithTag(3) as! UILabel
                        guard let calendarView = calendarCell?.viewWithTag(4) as? FSCalendar else{
                            return UITableViewCell()
                        }
                        let calendarNextImageView = calendarCell?.viewWithTag(61) as! UIImageView
                        let calendarBackImageView = calendarCell?.viewWithTag(99) as! UIImageView
                        
                        calendarBackButton.dropCircleShadow()
                        calendarBackButton.addTarget(self, action: #selector(calendarBackButtonPressed), for: .touchUpInside)
                        calendarNextButton.dropCircleShadow()
                        calendarNextButton.addTarget(self, action: #selector(calendarNextButtonPressed), for: .touchUpInside)
                        if self.languageId == "ar"{
                            calendarNextImageView.image = UIImage(named: "calendar-left-arrow")
                            calendarBackImageView.image = UIImage(named: "calendar-right-arrow")
                        }else{
                            calendarNextImageView.image = UIImage(named: "calendar-right-arrow")
                            calendarBackImageView.image = UIImage(named: "calendar-left-arrow")
                        }
            //            calendarView.bottomBorder.isHidden = true
                        calendarView.calendarWeekdayView.addBorders(edges: .bottom)
                        calendarView.delegate = self
                        calendarView.dataSource = self
                        calendarView.locale = Locale(identifier: "\(self.languageId )")
                        calendarView.calendarHeaderView.calendar.locale = Locale(identifier: "\(self.languageId )")
                        calendarView.register(DIYCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
                        calendarView.reloadData()
                        
                        // Setup Calendar Label:
                        configureCalendarLabel(calendar: calendarView, calendarMonthLabel: monthLabel, cellIndex: 0)
                        
                        let bottomShadowView: UIView? = calendarCell?.viewWithTag(7)
                        bottomShadowView?.dropTopShadow()
                        calendarCell?.selectionStyle = .none
                        return calendarCell!
                    case 1:
                        let eventsCell = agendaTableView.dequeueReusableCell(withIdentifier: "eventsReuse")
                        let monthLabel = eventsCell?.viewWithTag(11) as! UILabel
                        let addImageView = eventsCell?.viewWithTag(600) as! UIImageView
                        let xImageView = eventsCell?.viewWithTag(6001) as! UIImageView
                        let addLabel = eventsCell?.viewWithTag(601) as! UILabel
                        let addButton = eventsCell?.viewWithTag(602) as! UIButton
                        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                        
                        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
                        switch user.userType{
                        case 1,2:
                            addImageView.isHidden = false
                            addLabel.isHidden = false
                            addButton.isHidden = false
                            if self.selectCalendarDate != ""{
                                if let date = dateFormatter1.date(from: self.selectCalendarDate), date > yesterday{
                                    addLabel.alpha = 1
                                    addImageView.alpha = 1
                                    addButton.isUserInteractionEnabled = true
                                }else{
                                    addLabel.alpha = 0.5
                                    addImageView.alpha = 0.5
                                    addButton.isUserInteractionEnabled = false
                                }
                            }else{
                                addLabel.alpha = 0.5
                                addImageView.alpha = 0.5
                                addButton.isUserInteractionEnabled = false
                            }
                            if teacherEdit{
                                addLabel.alpha = 1
                                addImageView.alpha = 1
                                addButton.isUserInteractionEnabled = true
                                addLabel.text = "Cancel".localiz()
                                addImageView.image = UIImage(named: "cancel")
                                xImageView.isHidden = false
                            }else{
                                addLabel.text = "Add".localiz()
                                addImageView.image = UIImage(named: "add-school")
                                xImageView.isHidden = true
            //                    if self.user.privileges.contains(App.subjectMasterPrivilege){
                                addLabel.alpha = 1
                                addImageView.alpha = 1
                                addButton.isUserInteractionEnabled = true
                            }
                        default:
                            addImageView.isHidden = true
                            addLabel.isHidden = true
                            addButton.isHidden = true
                            xImageView.isHidden = true
                        }
                        
                        // Get Calendar Month
                        guard let calendarView = agendaTableView.viewWithTag(4) as? FSCalendar else{
                            return UITableViewCell()
                        }
                        var currentCalendar = Calendar.current
                        currentCalendar.locale = Locale(identifier: "\(self.languageId )")
                        let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.currentPage)
                        let month = values.month
                        let stringMonth = currentCalendar.monthSymbols[month! - 1]
                        monthLabel.text = "\("Month of ".localiz())\(stringMonth)"
                        let text = monthLabel.text!
                        let attributesText = NSMutableAttributedString(string: text)
                        let noUserText = (text as NSString).range(of: "Month of ".localiz())
                        attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 14)!], range: noUserText)
                        let helpText = (text as NSString).range(of: "\(stringMonth)")
                        attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 14)!], range: helpText)
                        monthLabel.attributedText = attributesText
                        
                        let bottomShadowView: UIView? = eventsCell?.viewWithTag(16)
                        bottomShadowView?.dropShadow()
                        let eventsCollectionView = eventsCell?.viewWithTag(12) as! UICollectionView
                        eventsCollectionView.delegate = self
                        eventsCollectionView.dataSource = self
                        eventsCollectionView.reloadData()
                        eventsCell?.selectionStyle = .none
                        return eventsCell!
                    default:
                        switch user.userType{
                     
                        case 1,2:
                            if teacherEdit{
                                if editType == self.agendaType.Assessment.rawValue{
                                    switch indexPath.section{
                                    case 2:
                                        //Assessment due date
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "startEndReuse")
                                        let titleLabel = cell?.viewWithTag(700) as! UILabel
                                        let dateLabel = cell?.viewWithTag(701) as! UILabel
                                        let dateButton = cell?.viewWithTag(702) as! UIButton
                                        let timeLabel = cell?.viewWithTag(703) as! UILabel

                                        titleLabel.text = "Due Date".localiz()
                                        print("selectCalendarDate: \(selectCalendarDate)")
                                        
                                        if isCalendarEditing{
                                            print("eventdate: \( self.agendaForEdit)")

                                            let date = self.dateFormatter1Locale.date(from: self.agendaForEdit.date)
                                            print("eventdate: \( date)")

                                            dateLabel.text = self.pickerDateResultFormatterLocale.string(from: date ?? Date())
                                            
                                        }else{
                                            print("eventdate: \( self.selectCalendarDate)")

                                            if !self.selectCalendarDate.isEmpty{
                                                let date = self.dateFormatter1Locale.date(from: self.selectCalendarDate)
                                                dateLabel.text = self.pickerDateResultFormatterLocale.string(from: date ?? Date())
                                            }else{
                                                dateLabel.text = "Select Due Date".localiz()
                                            }
                                        }
                                        
                                      
                                        timeLabel.text = self.addEvent.startTime
                                        timeLabel.isHidden = true
                                        dateButton.isUserInteractionEnabled = false
                                        cell?.selectionStyle = .none
                                        return cell!
//                                    case 3:
//                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
//                                        let titleTextField = cell?.viewWithTag(730) as! UITextField
//                                        titleTextField.delegate = self
//                                        if isCalendarEditing{
//                                            titleTextField.placeholder = ""
//                                            titleTextField.text = self.agendaForEdit.title
//                                        }else{
//                                            titleTextField.placeholder = "Assignment title is typed here".localiz()
//                                            titleTextField.text = self.addEvent.title
//                                        }
//                                        titleTextField.keyboardType = .default
//                                        cell?.selectionStyle = .none
//                                        return cell!
                                    case 3:
                                        //assessment subject
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
                                        let dropdownField = cell?.viewWithTag(715) as! UITextField
                                        let _ = cell?.viewWithTag(716) as! UIImageView
                                        let dropdownButton = cell?.viewWithTag(717) as! UIButton
                                        if isCalendarEditing{
                                            dropdownField.placeholder = ""
                                            dropdownField.text = self.agendaForEdit.subject_name
                                            if self.selectedSubject.name != "" {
                                                dropdownField.text = self.selectedSubject.name
                                            }
                                        }else{
                                            dropdownField.placeholder = ""
                                            dropdownField.text = self.selectedSubject.name
                                        }
                                        dropdownButton.accessibilityIdentifier = "subject"
                                        dropdownButton.addTarget(self, action: #selector(dropDownFieldPressed), for: .touchUpInside)
                                        cell?.selectionStyle = .none
                                        return cell!
                                    //Assessment Mark:
                                    case 4:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                                        let titleTextField = cell?.viewWithTag(730) as! UITextField
                                        titleTextField.delegate = self
                                        if isCalendarEditing{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = self.agendaForEdit.full_mark
                                        }else{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = self.addEvent.mark.description
                                        }
                                        titleTextField.keyboardType = .numberPad
                                        cell?.selectionStyle = .none
                                        return cell!
                                    //Assessment Title Cell:
                                    case 5:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                                        let titleTextField = cell?.viewWithTag(730) as! UITextField
                                        titleTextField.delegate = self
                                        if isCalendarEditing{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = self.agendaForEdit.title
                                        }else{
                                            titleTextField.placeholder = "Quiz title is typed here".localiz()
                                            titleTextField.text = self.addEvent.title
                                        }
                                        titleTextField.keyboardType = .default
                                        cell?.selectionStyle = .none
                                        return cell!
                                    //Assessment subterm cell:
//                                    case 7:
//                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
//                                        let dropdownField = cell?.viewWithTag(715) as! UITextField
//                                        let _ = cell?.viewWithTag(716) as! UIImageView
//                                        let dropdownButton = cell?.viewWithTag(717) as! UIButton
//                                        print("exam group: \(self.selectedGroup)")
//                                        if isCalendarEditing{
//                                            dropdownField.placeholder = "Choose exam group here".localiz()
//                                            dropdownField.text = self.selectedGroup
//                                        }else{
//                                            dropdownField.placeholder = "Choose exam group here".localiz()
//                                            dropdownField.text = self.selectedGroup
//                                        }
//                                        dropdownButton.accessibilityIdentifier = "subterm"
//                                        dropdownButton.addTarget(self, action: #selector(dropDownFieldPressed), for: .touchUpInside)
//                                        cell?.selectionStyle = .none
//                                        return cell!
//                                    //Assessment Type:
//                                    case 8:
//                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
//                                        let dropdownField = cell?.viewWithTag(715) as! UITextField
//                                        let _ = cell?.viewWithTag(716) as! UIImageView
//                                        let dropdownButton = cell?.viewWithTag(717) as! UIButton
//
//                                        if isCalendarEditing{
//
//                                            dropdownField.placeholder = ""
//                                            dropdownField.text = self.agendaForEdit.assessment_type
//                                            if self.typeName != "" {
//                                                dropdownField.text = self.typeName
//                                            }
//                                        }else{
//                                            if self.resetData{
//                                                self.addEvent.assessmentTypeId = 0
//                                                self.typeName = ""
//                                                self.resetData = false
//                                            }
//                                            dropdownField.placeholder = ""
//                                            dropdownField.text = self.typeName
//                                        }
//                                        dropdownButton.accessibilityIdentifier = "type"
//                                        dropdownButton.addTarget(self, action: #selector(dropDownFieldPressed), for: .touchUpInside)
//                                        cell?.selectionStyle = .none
//                                        return cell!
                                    //Write About Quiz Cell:
                                    case 6:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "writeReuse")
                                        let textView = cell?.viewWithTag(720) as! UITextView
                                        if isCalendarEditing{
                                            textView.text = self.agendaForEdit.description
                                        }else{
                                            textView.text = self.addEvent.description
                                        }
                                        textView.delegate = self
                                        cell?.selectionStyle = .none
                                        return cell!
                                        
                                    case 7:
                                    let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse")
                                    let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                    let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                    
                                    if isCalendarEditing{
                                        var students = self.agendaForEdit.students
                                        students = String(students.dropFirst())
                                        students = String(students.dropLast())
                                        let arrayStudents = students.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
                                        print("arrayStudents ", arrayStudents)
                                        
                                        if students != "" {
                                            studentSwitch.setOn(allStudents, animated: true)
                                        
                                        
                                            
                                            let sectionVisible0 = self.model?[0].isVisible ?? false
                                            self.model = [ItemsHeader(isVisible: sectionVisible0, items: self.teacherStudentsArray, title: "Student List".localiz())]
                                        }else{
                                            studentSwitch.setOn(allStudents, animated: true)
//
                                            
                                            let sectionVisible0 = self.model?[0].isVisible ?? false
                                            self.model = [ItemsHeader(isVisible: sectionVisible0, items: self.teacherStudentsArray, title: "Student List".localiz())]
                                        }
                                    }else{
                                        studentSwitch.setOn(allStudents, animated: true)
                                    }
                                    
                                    titleLabel.text = "All Students".localiz()
                                    studentSwitch.addTarget(self, action: #selector(allStudentsSwitchPressed), for: .touchUpInside)
                                    cell?.selectionStyle = .none
                                    return cell!
                                        
                                    //Choose Student:
                                    case 8:
                                     let cell = agendaTableView.dequeueReusableCell(withIdentifier: "studentReuse")
                                     let titleLabel = cell?.viewWithTag(740) as! UILabel
                                     let studentSwitch = cell?.viewWithTag(741) as! PWSwitch
                                     let student = model![indexPath.section - 8].items[indexPath.row]
                                     
                                     studentSwitch.addTarget(self, action: #selector(studentSwitchPressed), for: .touchUpInside)
                                     titleLabel.text = student.title
                                     //                                        studentSwitch.setOn(student.active, animated: true)
                                     if allStudents{
                                         studentSwitch.isEnabled = false
                                     }else{
                                         studentSwitch.isEnabled = true
                                     }
                                     cell?.selectionStyle = .none
                                     return cell!
                                        
                                        
                                    case 9:
                                        
                                     let cell = agendaTableView.dequeueReusableCell(withIdentifier: "pictureReuse")
                                     let uploadLabel = cell?.viewWithTag(720) as! UILabel
                                     let imageView = cell?.viewWithTag(721) as! UIImageView
                                     let imageButton = cell?.viewWithTag(722) as! UIButton
                                     if self.isFileSelected == true{
                                         print("url ",self.pdfURL)
                                         let filetype = self.pdfURL.description.suffix(4).lowercased()
                                         if filetype == ".pdf"{
                                             imageView.image = UIImage(named: "pdf_logo")
                                         }else if filetype == "docx"{
                                             imageView.image = UIImage(named: "word_logo")
                                         }else if filetype == "xlsx"{
                                             imageView.image = UIImage(named: "excel_logo")
                                         }
                                         else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                             imageView.image = UIImage(named: "powerpoint")
                                         }
                                         else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                             imageView.image = UIImage(named: "video")
                                     
                                         }
                                         else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                                     || filetype == ".wma" || filetype == ".aac"{
                                             imageView.image = UIImage(named: "audio")
                                         }
                                         else{
                                             imageView.image = UIImage(named: "doc_logo")
                                         }
                                     }else if self.isSelectedImage{
                                         imageView.image = selectedImage
                                     }else{
                                         imageView.image = UIImage(named: "add-picture")
                                     }
                                     uploadLabel.text = "Attach a file".localiz()
                                     imageButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
                                     cell?.selectionStyle = .none
                                     return cell!
                                    //Save Cell:
                                        
                                    case 10:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                                        let titleTextField = cell?.viewWithTag(730) as! UITextField
                                        titleTextField.delegate = self
                                        if isCalendarEditing{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = String(self.agendaForEdit.estimatedTime)
                                        }else{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = self.addEvent.estimatedTime.description
                                        }
                                        titleTextField.keyboardType = .numberPad
                                        cell?.selectionStyle = .none
                                        return cell!
                                    case 11:
                                     
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse1")
                                            let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                            
                               
//                                            studentSwitch.setOn(allStudents, animated: true)
                                            
                                        if isCalendarEditing{
                                            if(self.agendaForEdit.enableSubmissions){
                                                self.enableSubmissions = true
                                                studentSwitch.setOn(true, animated: true)
                                            }
                
                                        }
                                        
                                            
                                            titleLabel.text = "Enable Submissions".localiz()
                                            studentSwitch.addTarget(self, action: #selector(enableSubmissionsSwitchPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                        
                                    case 12:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse2")
                                        let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                        let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                        
                           
//                                            studentSwitch.setOn(allStudents, animated: true)
                                        if isCalendarEditing{
                                            if(self.agendaForEdit.enableLateSubmissions){
                                                self.enableLateSubmissions = true
                                                studentSwitch.setOn(true, animated: true)
                                            }
                
                                        }
                                        
                                        titleLabel.text = "Enable Late Submissions".localiz()
                                        studentSwitch.addTarget(self, action: #selector(enableLateSubmissionsSwitchPressed), for: .touchUpInside)
                                        cell?.selectionStyle = .none
                                        return cell!
                                    case 13:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse3")
                                        let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                        let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                        
                           
                                        if isCalendarEditing{
                                            if(self.agendaForEdit.enableDiscussions){
                                                self.enableDiscussions = true
                                                studentSwitch.setOn(true, animated: true)
                                            }
                
                                        }
                                        
                                        titleLabel.text = "Enable Discussions".localiz()
                                        studentSwitch.addTarget(self, action: #selector(enableDiscussionsSwitchPressed), for: .touchUpInside)
                                        cell?.selectionStyle = .none
                                        return cell!
                                    case 14:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse4")
                                        let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                        let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                        
                           
//                                            studentSwitch.setOn(allStudents, animated: true)
                                        
                                        if isCalendarEditing{
                                            if(self.agendaForEdit.enableGrading){
                                                self.enableGrading = true
                                                studentSwitch.setOn(true, animated: true)
                                            }
                
                                        }
                                        
                                        titleLabel.text = "Enable Grading".localiz()
                                        studentSwitch.addTarget(self, action: #selector(enableGradingSwitchPressed), for: .touchUpInside)
                                        cell?.selectionStyle = .none
                                        return cell!
                                    case 15:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                                        let titleTextField = cell?.viewWithTag(730) as! UITextField
                                        titleTextField.delegate = self
                                        if isCalendarEditing{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = String(self.agendaForEdit.full_mark)
                                        }else{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = self.addEvent.mark.description
                                        }
                                        titleTextField.keyboardType = .numberPad
                                        cell?.selectionStyle = .none
                                        return cell!
                                   
                                    default:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "saveReuse")
                                        let saveButton = cell?.viewWithTag(725) as! UIButton
                                        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
                                        cell?.selectionStyle = .none
                                        return cell!
                                    }
                                }else{
                                    switch indexPath.section{
                                    //Start End Cells:
                                    case 2:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "startEndReuse")
                                        let titleLabel = cell?.viewWithTag(700) as! UILabel
                                        let dateLabel = cell?.viewWithTag(701) as! UILabel
                                        let dateButton = cell?.viewWithTag(702) as! UIButton
                                        let timeLabel = cell?.viewWithTag(703) as! UILabel
                                        
                                        titleLabel.text = "Due Date".localiz()
                                        
                                        if isCalendarEditing{
                                            print("eventdate: \( self.agendaForEdit)")

                                            let date = self.dateFormatter1Locale.date(from: self.agendaForEdit.date)
                                            print("eventdate: \( date)")

                                            dateLabel.text = self.pickerDateResultFormatterLocale.string(from: date ?? Date())
                                            
                                        }else{
                                            if !self.selectCalendarDate.isEmpty{
                                                let date = self.dateFormatter1Locale.date(from: self.selectCalendarDate)
                                                dateLabel.text = self.pickerDateResultFormatterLocale.string(from: date ?? Date())
                                            }else{
                                                dateLabel.text = "Select Due Date".localiz()
                                            }
                                        }
                                        timeLabel.text = self.addEvent.startTime
                                        timeLabel.isHidden = true
                                        dateButton.isUserInteractionEnabled = false
                                        cell?.selectionStyle = .none
                                        return cell!
                                    
                                    case 3:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                                        let titleTextField = cell?.viewWithTag(730) as! UITextField
                                        titleTextField.delegate = self
                                        if isCalendarEditing{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = self.agendaForEdit.title
                                        }else{
                                            titleTextField.placeholder = "Assignment title is typed here".localiz()
                                            titleTextField.text = self.addEvent.title
                                        }
                                        titleTextField.keyboardType = .default
                                        cell?.selectionStyle = .none
                                        return cell!
                                        
                                    //Exam Group Cell - Exam Subject Cell:
                                    case 4:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
                                        let dropdownField = cell?.viewWithTag(715) as! UITextField
                                        let _ = cell?.viewWithTag(716) as! UIImageView
                                        let dropdownButton = cell?.viewWithTag(717) as! UIButton
                                        if isCalendarEditing{
                                            dropdownField.placeholder = ""
                                            dropdownField.text = self.agendaForEdit.subject_name
                                            if selectedSubject.name != "" {
                                                dropdownField.text = self.selectedSubject.name
                                            }
                                        }else{
                                            dropdownField.placeholder = ""
                                            dropdownField.text = self.selectedSubject.name
                                        }
                                        dropdownButton.accessibilityIdentifier = "exam"
                                        dropdownButton.addTarget(self, action: #selector(dropDownFieldPressed), for: .touchUpInside)
                                        cell?.selectionStyle = .none
                                        return cell!
                                    case 5:
                                        if editType == self.agendaType.Exam.rawValue{
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "writeReuse")
                                            let descriptionTextView = cell?.viewWithTag(720) as! UITextView
                                            descriptionTextView.delegate = self
                                            if isCalendarEditing {
                                                descriptionTextView.text = self.agendaForEdit.description.description
                                            } else {
                                                descriptionTextView.text = self.textSubject
                                            }
                                            cell?.selectionStyle = .none
                                            return cell!
                                        }else{
                                            //empty cell if homework or assignment and set height to zero
                                            let cell = UITableViewCell()
                                            cell.selectionStyle = .none
                                            return cell
                                        }
                                    //MARK: EDITS HERE
                                    //Write About Exam Cell:
                                    case 6:
                                        if editType == self.agendaType.Exam.rawValue{
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse1")
                                            let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                            
                               
//                                            studentSwitch.setOn(allStudents, animated: true)
                                            if isCalendarEditing{
                                                self.enableSubmissions = true
                                                if(self.agendaForEdit.enableSubmissions){
                                                    studentSwitch.setOn(true, animated: true)
                                                }
                    
                                            }
                                            
                                            titleLabel.text = "Enable Submissions".localiz()
                                            studentSwitch.addTarget(self, action: #selector(enableSubmissionsSwitchPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                        }
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "writeReuse")
                                        let descriptionTextView = cell?.viewWithTag(720) as! UITextView
                                        descriptionTextView.delegate = self
                                        if isCalendarEditing {
                                            descriptionTextView.text = self.agendaForEdit.description.description
                                        } else {
                                            descriptionTextView.text = self.textSubject
                                        }
                                        cell?.selectionStyle = .none
                                        return cell!
                                    //Save Cell: || All Students:
                                    case 7:
                                        if editType == self.agendaType.Exam.rawValue{
                                            
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse")
                                            let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                            
                                            if isCalendarEditing{
                                                var students = self.agendaForEdit.students
                                                students = String(students.dropFirst())
                                                students = String(students.dropLast())
                                                let arrayStudents = students.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
                                                print("arrayStudents ", arrayStudents)
                                                
                                                if students != "" {
                                                    studentSwitch.setOn(allStudents, animated: true)
                                                
                                                
                                                    
                                                    let sectionVisible0 = self.model?[0].isVisible ?? false
                                                    self.model = [ItemsHeader(isVisible: sectionVisible0, items: self.teacherStudentsArray, title: "Student List".localiz())]
                                                }else{
                                                    studentSwitch.setOn(allStudents, animated: true)
        //
                                                    
                                                    let sectionVisible0 = self.model?[0].isVisible ?? false
                                                    self.model = [ItemsHeader(isVisible: sectionVisible0, items: self.teacherStudentsArray, title: "Student List".localiz())]
                                                }
                                            }else{
                                                studentSwitch.setOn(allStudents, animated: true)
                                            }
                                            
                                            titleLabel.text = "All Students".localiz()
                                            studentSwitch.addTarget(self, action: #selector(allStudentsSwitchPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                            
                                           
                                        }else{
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse")
                                            let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                            
                                            if isCalendarEditing{
                                                var students = self.agendaForEdit.students
                                                students = String(students.dropFirst())
                                                students = String(students.dropLast())
                                                let arrayStudents = students.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
                                                print("arrayStudents ", arrayStudents)
                                                
                                                if students != "" {
                                                    studentSwitch.setOn(allStudents, animated: true)
                                                   
                                                  
                                                    
                                                    let sectionVisible0 = self.model?[0].isVisible ?? false
                                                    self.model = [ItemsHeader(isVisible: sectionVisible0, items: self.teacherStudentsArray, title: "Student List".localiz())]
                                                }else{
                                                    studentSwitch.setOn(allStudents, animated: true)
//
                                                    
                                                    let sectionVisible0 = self.model?[0].isVisible ?? false
                                                    self.model = [ItemsHeader(isVisible: sectionVisible0, items: self.teacherStudentsArray, title: "Student List".localiz())]
                                                }
                                            }else{
                                                studentSwitch.setOn(allStudents, animated: true)
                                            }
                                            
                                            titleLabel.text = "All Students".localiz()
                                            studentSwitch.addTarget(self, action: #selector(allStudentsSwitchPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                        }
                                    //Choose Student:
                                    case 8:
                                        if editType == self.agendaType.Exam.rawValue{
                                            
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "studentReuse")
                                            let titleLabel = cell?.viewWithTag(740) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(741) as! PWSwitch
                                            let student = model![indexPath.section - 8].items[indexPath.row]
                                            
                                            studentSwitch.addTarget(self, action: #selector(studentSwitchPressed), for: .touchUpInside)
                                            titleLabel.text = student.title
                                            //                                        studentSwitch.setOn(student.active, animated: true)
                                            if allStudents{
                                                studentSwitch.isEnabled = false
                                            }else{
                                                studentSwitch.isEnabled = true
                                            }
                                            cell?.selectionStyle = .none
                                            return cell!
                                  
                                            
                                        }else{
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "studentReuse")
                                            let titleLabel = cell?.viewWithTag(740) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(741) as! PWSwitch
                                            let student = model![indexPath.section - 8].items[indexPath.row]
                                            
                                            studentSwitch.addTarget(self, action: #selector(studentSwitchPressed), for: .touchUpInside)
                                            titleLabel.text = student.title
                                            //                                        studentSwitch.setOn(student.active, animated: true)
                                            if allStudents{
                                                studentSwitch.isEnabled = false
                                            }else{
                                                studentSwitch.isEnabled = true
                                            }
                                            cell?.selectionStyle = .none
                                            return cell!
                                        }
                                        
                                    case 9:
                                        
                                            
                                            
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "pictureReuse")
                                            let uploadLabel = cell?.viewWithTag(720) as! UILabel
                                            let imageView = cell?.viewWithTag(721) as! UIImageView
                                            let imageButton = cell?.viewWithTag(722) as! UIButton
                                            if self.isFileSelected == true{
                                                print("url ",self.pdfURL)
                                                let filetype = self.pdfURL.description.suffix(4).lowercased()
                                                if filetype == ".pdf"{
                                                    imageView.image = UIImage(named: "pdf_logo")
                                                }else if filetype == "docx"{
                                                    imageView.image = UIImage(named: "word_logo")
                                                }else if filetype == "xlsx"{
                                                    imageView.image = UIImage(named: "excel_logo")
                                                }
                                                else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                                    imageView.image = UIImage(named: "powerpoint")
                                                }
                                                else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                                    imageView.image = UIImage(named: "video")
                                            
                                                }
                                                else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                                            || filetype == ".wma" || filetype == ".aac"{
                                                    imageView.image = UIImage(named: "audio")
                                                }
                                                else{
                                                    imageView.image = UIImage(named: "doc_logo")
                                                }
                                            }else if self.isSelectedImage{
                                                imageView.image = selectedImage
                                            }else{
                                                imageView.image = UIImage(named: "add-picture")
                                            }
                                            uploadLabel.text = "Attach a file".localiz()
                                            imageButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                           
            //                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "attachReuse")
            //                            let attachButton = cell?.viewWithTag(1725) as! UIButton
            //                            if isFileSelected {
            //                                attachButton.setTitle("File attached".localiz(), for: .normal)
            //                            }else{
            //                                attachButton.setTitle("Attach".localiz(), for: .normal)
            //                            }
            //                            attachButton.addTarget(self, action: #selector(attachButtonPressed), for: .touchUpInside)
            //                            cell?.selectionStyle = .none
            //                            return cell!
                                    //Save Cell:
                                        
                              
                                       
                                    case 10:
                                        if editType == self.agendaType.Exam.rawValue{
                                            
                                            
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                                            let titleTextField = cell?.viewWithTag(730) as! UITextField
                                            titleTextField.delegate = self
                                            if isCalendarEditing{
                                                titleTextField.placeholder = ""
                                                titleTextField.text = String(self.agendaForEdit.estimatedTime)
                                            }else{
                                                titleTextField.placeholder = ""
                                                titleTextField.text = self.addEvent.estimatedTime.description
                                            }
                                            titleTextField.keyboardType = .numberPad
                                            cell?.selectionStyle = .none
                                            return cell!
                                            
                                            
                                        }else{
                                            
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                                            let titleTextField = cell?.viewWithTag(730) as! UITextField
                                            titleTextField.delegate = self
                                            if isCalendarEditing{
                                                titleTextField.placeholder = ""
                                                titleTextField.text = String(self.agendaForEdit.estimatedTime)
                                            }else{
                                                titleTextField.placeholder = ""
                                                titleTextField.text = self.addEvent.estimatedTime.description
                                            }
                                            titleTextField.keyboardType = .numberPad
                                            cell?.selectionStyle = .none
                                            return cell!
                                            
                                        }
                                      
                                        
                                    case 11:
                                        if editType == self.agendaType.Exam.rawValue{
                                            
                                            
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse1")
                                            let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                            
                               
//                                            studentSwitch.setOn(allStudents, animated: true)
                                            if isCalendarEditing{
                                                if(self.agendaForEdit.enableSubmissions){
                                                    self.enableSubmissions = true
                                                    studentSwitch.setOn(true, animated: true)
                                                }
                    
                                            }
                                            
                                            titleLabel.text = "Enable Submissions".localiz()
                                            studentSwitch.addTarget(self, action: #selector(enableSubmissionsSwitchPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                        
                                            
                                        }else{
                                            
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse1")
                                            let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                            
                                            if isCalendarEditing{
                                                if(self.agendaForEdit.enableSubmissions){
                                                    self.enableSubmissions = true
                                                    studentSwitch.setOn(true, animated: true)
                                                }
                    
                                            }
                                            //                                            studentSwitch.setOn(allStudents, animated: true)
                                            
                                            
                                            titleLabel.text = "Enable Submissions".localiz()
                                            studentSwitch.addTarget(self, action: #selector(enableSubmissionsSwitchPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                        }
                                      
                                        
                                    case 12:
                                        if editType == self.agendaType.Exam.rawValue{
                                            
                                            
                                            
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse2")
                                            let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                            
                               
//                                            studentSwitch.setOn(allStudents, animated: true)
                                            if isCalendarEditing{
                                                if(self.agendaForEdit.enableLateSubmissions){
                                                    self.enableLateSubmissions = true
                                                    studentSwitch.setOn(true, animated: true)
                                                }
                    
                                            }
                                            
                                            titleLabel.text = "Enable Late Submissions".localiz()
                                            studentSwitch.addTarget(self, action: #selector(enableLateSubmissionsSwitchPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                           
                                            
                                            
                                        
                                        }else{
                                            
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse2")
                                            let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                            if isCalendarEditing{
                                                if(self.agendaForEdit.enableLateSubmissions){
                                                    self.enableLateSubmissions = true
                                                    studentSwitch.setOn(true, animated: true)
                                                }
                    
                                            }
                                            
                                            titleLabel.text = "Enable Late Submissions".localiz()
                                            studentSwitch.addTarget(self, action: #selector(enableLateSubmissionsSwitchPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                        }
                                    case 13:
                                      
                                        
                                            let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse3")
                                            let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                            let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                            
                               
                                        if isCalendarEditing{
                                            if(self.agendaForEdit.enableDiscussions){
                                                self.enableDiscussions = true
                                                studentSwitch.setOn(true, animated: true)
                                            }
                
                                        }
                                            
                                            titleLabel.text = "Enable Discussions".localiz()
                                            studentSwitch.addTarget(self, action: #selector(enableDiscussionsSwitchPressed), for: .touchUpInside)
                                            cell?.selectionStyle = .none
                                            return cell!
                                        
                                       
                                    case 14:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "allStudentReuse4")
                                        let titleLabel = cell?.viewWithTag(7300) as! UILabel
                                        let studentSwitch = cell?.viewWithTag(732) as! PWSwitch
                                        
                           
                                        if isCalendarEditing{
                                            if(self.agendaForEdit.enableGrading){
                                                self.enableGrading = true
                                                studentSwitch.setOn(true, animated: true)
                                            }
                
                                        }
                                        
                                        titleLabel.text = "Enable Grading".localiz()
                                        studentSwitch.addTarget(self, action: #selector(enableGradingSwitchPressed), for: .touchUpInside)
                                        cell?.selectionStyle = .none
                                        return cell!
                                    
                                    case 15:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                                        let titleTextField = cell?.viewWithTag(730) as! UITextField
                                        titleTextField.delegate = self
                                        if isCalendarEditing{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = String(self.agendaForEdit.full_mark)
                                        }else{
                                            titleTextField.placeholder = ""
                                            titleTextField.text = self.addEvent.mark.description
                                        }
                                        titleTextField.keyboardType = .numberPad
                                        cell?.selectionStyle = .none
                                        return cell!
                                        
                                   
                                    default:
                                        let cell = agendaTableView.dequeueReusableCell(withIdentifier: "saveReuse")
                                        let saveButton = cell?.viewWithTag(725) as! UIButton
                                        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
                                        cell?.selectionStyle = .none
                                        return cell!
                                    }
                                }
                            }else{
                                var event: AgendaDetail!
                                if calendarStyle == .week{
                                    if self.weekEvents.isEmpty{
                                        let cell = UITableViewCell()
                                        cell.textLabel?.text = "No Events for selected criteria".localiz()
                                        cell.textLabel?.textAlignment = .center
                                        cell.selectionStyle = .none
                                        return cell
                                    }else{
                                        if(self.weekEvents[indexPath.section-2].agendaDetail.count > indexPath.row){
                                            event = self.weekEvents[indexPath.section-2].agendaDetail[indexPath.row]
                                            let date = self.dateFormatter1.date(from: event.date)
                                        }
                                       
                                    }
                                }else{
                                    if self.eventsArray.isEmpty{
                                        let cell = UITableViewCell()
                                        cell.textLabel?.text = "No Events for selected criteria".localiz()
                                        cell.textLabel?.textAlignment = .center
                                        cell.selectionStyle = .none
                                        return cell
                                    }else{
                                        event = eventsArray[indexPath.row]
                                        let date = self.dateFormatter1.date(from: event.date)
                                        
                                    }
                                }
                               
                                if selectCalendarDate.isEmpty{
                                    if(event.type == 5 || event.type == 6){
                                        let cell = self.agendaTableView.dequeueReusableCell(withIdentifier: "sectionDetailReuse")
                                        let dateLabel = cell?.viewWithTag(40)as!UILabel
                                        dateLabel.isHidden = true

                                        let titleView2 = cell?.viewWithTag(908) as! UIView
                    //                    let titleColor = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].color
                                        let titleColor = "#4A74BA"
                                      
                                        titleView2.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 0.15)
                                        
                                        let titleLabel = cell?.viewWithTag(44) as! UILabel
                                        titleLabel.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                        
                                        let plusImage = cell?.viewWithTag(45) as! UIImageView
                                        
                                        let plusButton = cell?.viewWithTag(46) as! UIButton
                                        
                                        let startDate = cell?.viewWithTag(321) as!UILabel
                                        startDate.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                        
                                        let endDate = cell?.viewWithTag(322) as!UILabel
                                        endDate.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                        
                                        let duration = cell?.viewWithTag(323) as!UILabel
                                        duration.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                        
                                        let bodyBackground = cell?.viewWithTag(70) as!UIStackView
                                        
                                        let startButton = cell?.viewWithTag(333) as! UIButton
                                        let downloadButton = cell?.viewWithTag(71) as! UIButton
                                        
                                        startDate.isHidden = false
                                        endDate.isHidden = false
                                        duration.isHidden = false
                                        startButton.isHidden = false
                                        
                                        
                                        let startDate1 = self.onlineExamDateFormatter.string(from: self.pickerDateFormatter1.date(from: event.startDate) ?? Date())
                                        let endDate1 = self.onlineExamDateFormatter.string(from: self.pickerDateFormatter1.date(from: event.endDate) ?? Date())
                                        
                                        startDate.text = "-Starts: " + startDate1
                                        endDate.text = "-Ends: " + endDate1
                                        duration.text = "-Duration: " + event.duration
                //                        sectionBody.isHidden = true
                                        downloadButton.isHidden = true
                                        plusButton.isHidden = true
                                        plusImage.isHidden = true
                                        
                                        //backgroundView.isHidden = false
                                        //  let back = backgroundView.heightAnchor.constraint(equalToConstant: 20)
                                        //  back.isActive = true

                                        startButton.setImage(UIImage(named: "online_exam_download"), for: .normal)
                                        startButton.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                        startButton.layer.borderWidth = 0
                                        startButton.layer.masksToBounds = false
                                        startButton.layer.borderColor = UIColor.black.cgColor
                                        startButton.layer.cornerRadius = startButton.frame.height/2
                                        startButton.clipsToBounds = true
                                        startButton.removeTarget(nil, action: nil, for: .allEvents)
                                        startButton.addTarget(self, action: #selector(openOnlineExam), for: .touchUpInside)
                                        titleLabel.text = event.title
                                        return cell!
                                        
                                        
                                        
                                    }
                                    else{
                                        let eventDetailCell = agendaTableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse") as! AgendaTableViewCell
                                       
                                       let studentButton = eventDetailCell.openStudentsButton
                                        if(user.userType == 4){
                                            studentButton?.isHidden = true
                                        }
                                        else{
                                            if(event.enableSubmissions == true){
                                                studentButton?.isHidden = false
                                            }
                                            else{
                                                studentButton?.isHidden = true

                                            }
                                        }
                                        studentButton?.addTarget(self, action: #selector(openStudentsController), for: .touchUpInside)
                                        
                                        
                                        eventDetailCell.tickView?.isHidden = true
                                        eventDetailCell.tickImageView.isHidden = true
                                        eventDetailCell.tickButton.isHidden = true
                                        eventDetailCell.topView?.isHidden = true
                                        eventDetailCell.bottomLineView?.isHidden = true
                                        //set onclick
                                        eventDetailCell.tickButton.addTarget(self, action: #selector(tickButtonPressed), for: .touchUpInside)
                                        eventDetailCell.tickButton.isEnabled = false
                                        eventDetailCell.downloadButton.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
                                        eventDetailCell.descriptionLabel.handleURLTap{ url in
//                                            let urlfixed = url.absoluteString.replacingOccurrences(of: " ", with: "%20")
                                            guard let safari = URL(string: url.absoluteString) else { return }
                                            UIApplication.shared.open(safari)
                                        }
                                        var event: AgendaDetail!
                                        if calendarStyle == .week{
                                            if self.weekEvents.isEmpty{
                                                let cell = UITableViewCell()
                                                cell.textLabel?.text = "No Events for selected criteria".localiz()
                                                cell.textLabel?.textAlignment = .center
                                                cell.selectionStyle = .none
                                                return cell
                                            }else{
                                                event = self.weekEvents[indexPath.section-2].agendaDetail[indexPath.row]
                                                let date = self.dateFormatter1.date(from: event.date)
                                                eventDetailCell.dateLabel.text = self.dateFormatter11Locale.string(from: date ?? Date())
                                                if indexPath.row != 0{
                                                    eventDetailCell.dateLabel.text = ""
                                                }
                                            }
                                        }else{
                                            if self.eventsArray.isEmpty{
                                                let cell = UITableViewCell()
                                                cell.textLabel?.text = "No Events for selected criteria".localiz()
                                                cell.textLabel?.textAlignment = .center
                                                cell.selectionStyle = .none
                                                return cell
                                            }else{
                                                event = eventsArray[indexPath.row]
                                                let date = self.dateFormatter1.date(from: event.date)
                                                eventDetailCell.dateLabel.text = self.dateFormatter11Locale.string(from: date ?? Date())
                                            }
                                        }
                                        
                                        eventDetailCell.descriptionView?.backgroundColor = App.hexStringToUIColorCst(hex: "\(event.backgroudColor)", alpha: 0.5)
//                                        eventDetailCell.descriptionLabel.text =
                                        
                                        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                                            .documentType: NSAttributedString.DocumentType.html,
                                            .characterEncoding: String.Encoding.utf8.rawValue  // Specify the character encoding
                                        ]
                                        
                                        if let attributedString = try? NSAttributedString(
                                                  data: event.description.data(using: .utf8)!,
                                                  options: options,
                                                  documentAttributes: nil
                                              ) {
                                            eventDetailCell.descriptionLabel.attributedText = attributedString
                                              }
                                        
                                        eventDetailCell.titleView?.backgroundColor = App.hexStringToUIColorCst(hex: "\(event.topColor)", alpha: 1.0)
                                        eventDetailCell.titleLabel.text = event.title + " - " + event.subject_name
                                        eventDetailCell.titleButton.addTarget(self, action: #selector(titleButtonPressed), for: .touchUpInside)
                                        //hide text and download button
                                        if event.expand == true{
                                            if event.attachment_link == "" {
                                                eventDetailCell.downloadButton.isHidden = true
                                            }else{
                                                eventDetailCell.downloadButton.isHidden = false
                                            }
                                            eventDetailCell.descriptionLabel.isHidden = false
                                        }else{
                                            eventDetailCell.downloadButton.isHidden = true
                                            eventDetailCell.descriptionLabel.isHidden = true
                                        }
                                        let topConstraint = eventDetailCell.descriptionView?.constraints.filter({$0.identifier == "topConstraint"}).first
                                        
                                        if !event.expand {
                                            eventDetailCell.titleImageView.image = UIImage(named: "+")
                                            eventDetailCell.bottomView?.isHidden = true
                                            topConstraint?.isActive = false
                                        }else{
                                            eventDetailCell.titleImageView.image = UIImage(named: "-")
                                            eventDetailCell.bottomView?.isHidden = false
                                            if topConstraint == nil {
                                                let constraint = eventDetailCell.bottomView?.topAnchor.constraint(equalTo: eventDetailCell.titleView!.bottomAnchor, constant: 0)
                                                constraint?.identifier = "topConstraint"
                                                constraint?.isActive = true
                                            }
                                            else {
                                                topConstraint?.isActive = true
                                            }
                                        }
                                        eventDetailCell.selectionStyle = .none
                                        eventDetailCell.delegate = self
                                        return eventDetailCell
                                    }
                                
                                }else{
                                    
                                    if indexPath.section == 2{
                                        if self.eventsArray.isEmpty{
                                            let cell = UITableViewCell()
                                            cell.selectionStyle = .none
                                            return cell
                                        }
                                        let chartCell = agendaTableView.dequeueReusableCell(withIdentifier: "chartReuse")
                                        let pieChart = chartCell?.viewWithTag(735) as! PieChartView
                                        pieChart.delegate = self
                                        pieChart.backgroundColor = .clear
                                        pieChart.layer.zPosition = 1
                                        assignbackground(view: chartCell!.contentView)
                                        setup(pieChartView: pieChart)
                                        chartCell?.selectionStyle = .none
                                        return chartCell!
                                    }else{
                                        if(event.type == 5 || event.type == 6){
                                            let cell = self.agendaTableView.dequeueReusableCell(withIdentifier: "sectionDetailReuse")
                                            let dateLabel = cell?.viewWithTag(40)as!UILabel
                                            dateLabel.isHidden = true

                                            let titleView2 = cell?.viewWithTag(908) as! UIView
                        //                    let titleColor = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].color
                                            let titleColor = "#4A74BA"
                                          
                                            titleView2.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 0.15)
                                            
                                            let titleLabel = cell?.viewWithTag(44) as! UILabel
                                            titleLabel.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                            
                                            let plusImage = cell?.viewWithTag(45) as! UIImageView
                                            
                                            let plusButton = cell?.viewWithTag(46) as! UIButton
                                            
                                            let startDate = cell?.viewWithTag(321) as!UILabel
                                            startDate.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                            
                                            let endDate = cell?.viewWithTag(322) as!UILabel
                                            endDate.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                            
                                            let duration = cell?.viewWithTag(323) as!UILabel
                                            duration.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                            
                                            let bodyBackground = cell?.viewWithTag(70) as!UIStackView
                                            
                                            let startButton = cell?.viewWithTag(333) as! UIButton
                                            let downloadButton = cell?.viewWithTag(71) as! UIButton
                                            
                                            startDate.isHidden = false
                                            endDate.isHidden = false
                                            duration.isHidden = false
                                            startButton.isHidden = false
                                            
                                            
                                            let startDate1 = self.onlineExamDateFormatter.string(from: self.pickerDateFormatter1.date(from: event.startDate) ?? Date())
                                            let endDate1 = self.onlineExamDateFormatter.string(from: self.pickerDateFormatter1.date(from: event.endDate) ?? Date())
                                            
                                            startDate.text = "-Starts: " + startDate1
                                            endDate.text = "-Ends: " + endDate1
                                            duration.text = "-Duration: " + event.duration
                    //                        sectionBody.isHidden = true
                                            downloadButton.isHidden = true
                                            plusButton.isHidden = true
                                            plusImage.isHidden = true
                                            
                                            //backgroundView.isHidden = false
                                            //  let back = backgroundView.heightAnchor.constraint(equalToConstant: 20)
                                            //  back.isActive = true

                                            startButton.setImage(UIImage(named: "online_exam_download"), for: .normal)
                                            startButton.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                            startButton.layer.borderWidth = 0
                                            startButton.layer.masksToBounds = false
                                            startButton.layer.borderColor = UIColor.black.cgColor
                                            startButton.layer.cornerRadius = startButton.frame.height/2
                                            startButton.clipsToBounds = true
                                            startButton.removeTarget(nil, action: nil, for: .allEvents)
                                            startButton.addTarget(self, action: #selector(openOnlineExam), for: .touchUpInside)
                                            titleLabel.text = event.title
                                            return cell!
                                            
                                            
                                            
                                        }
                                        else{
                                            let eventDetailCell = agendaTableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse") as! AgendaTableViewCell
                                            let studentButton = eventDetailCell.openStudentsButton
                                            if(user.userType == 4){
                                                studentButton?.isHidden = true
                                            }
                                            else{
                                                if(event.enableSubmissions == true){
                                                    studentButton?.isHidden = false
                                                }
                                                else{
                                                    studentButton?.isHidden = true

                                                }
                                            }
                                           
                                            studentButton?.addTarget(self, action: #selector(openStudentsController), for: .touchUpInside)
                                            eventDetailCell.tickView?.isHidden = true
                                            eventDetailCell.tickImageView.isHidden = true
                                            eventDetailCell.tickButton.isHidden = true
                                            eventDetailCell.topView?.isHidden = true
                                            eventDetailCell.bottomLineView?.isHidden = true
                                            //set onclick
                                            eventDetailCell.tickButton.addTarget(self, action: #selector(tickButtonPressed), for: .touchUpInside)

                                            eventDetailCell.downloadButton.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
                                           
                                                                     
                                            eventDetailCell.descriptionLabel.handleURLTap{ url in
//                                                let urlfixed = url.absoluteString.replacingOccurrences(of: " ", with: "%20")
                                                guard let safari = URL(string: url.absoluteString) else { return }
                                                UIApplication.shared.open(safari)
                                            }
                                            
                                            var event: AgendaDetail!
                                
                                            if calendarStyle == .week{
                                                event = self.weekEvents[indexPath.section-3].agendaDetail[indexPath.row]
                                                let eventArray = self.events.filter{$0.color == event.topColor}
                                                eventDetailCell.dateLabel.text = getTypeLabel(type: (eventArray.first?.type)!)
                                            }else{
                                                event = eventsArray[indexPath.row]
                                                eventDetailCell.dateLabel.text = getTypeLabel(type: event.type)
                                            }
                                            
                                            print("events events: \(event)")
                                            if(event.enableSubmissions || event.enableLateSubmissions || event.ticked){
                                                eventDetailCell.tickButton.isEnabled = false
                                            }
                                            else{
                                                eventDetailCell.tickButton.isEnabled = true

                                            }
                                            
                                            eventDetailCell.descriptionView?.backgroundColor = App.hexStringToUIColorCst(hex: "\(event.backgroudColor)", alpha: 0.5)
                                            
                                            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                                                .documentType: NSAttributedString.DocumentType.html,
                                                .characterEncoding: String.Encoding.utf8.rawValue  // Specify the character encoding
                                            ]
                                            
                                            if let attributedString = try? NSAttributedString(
                                                      data: event.description.data(using: .utf8)!,
                                                      options: options,
                                                      documentAttributes: nil
                                                  ) {
                                                eventDetailCell.descriptionLabel.attributedText = attributedString
                                                  }
                                            
                                            eventDetailCell.titleView?.backgroundColor = App.hexStringToUIColorCst(hex: "\(event.topColor)", alpha: 1.0)
                                            eventDetailCell.titleLabel.text = event.title + " - " + event.subject_name
                                            eventDetailCell.titleButton.addTarget(self, action: #selector(titleButtonPressed), for: .touchUpInside)
                                            //hide text and download button
                                            if event.expand == true{
                                                if event.attachment_link == "" {
                                                    eventDetailCell.downloadButton.isHidden = true
                                                }else{
                                                    eventDetailCell.downloadButton.isHidden = false
                                                }
                                                eventDetailCell.descriptionLabel.isHidden = false
                                            }else{
                                                eventDetailCell.downloadButton.isHidden = true
                                                eventDetailCell.descriptionLabel.isHidden = true
                                            }
                                            let topConstraint = eventDetailCell.descriptionView?.constraints.filter({$0.identifier == "topConstraint"}).first
                                            
                                            if !event.expand {
                                                eventDetailCell.titleImageView.image = UIImage(named: "+")
                                                eventDetailCell.bottomView?.isHidden = true
                                                topConstraint?.isActive = false
                                            }else{
                                                eventDetailCell.titleImageView.image = UIImage(named: "-")
                                                eventDetailCell.bottomView?.isHidden = false
                                                if topConstraint == nil {
                                                    let constraint = eventDetailCell.bottomView?.topAnchor.constraint(equalTo: eventDetailCell.titleView!.bottomAnchor, constant: 0)
                                                    constraint?.identifier = "topConstraint"
                                                    constraint?.isActive = true
                                                }
                                                else {
                                                    topConstraint?.isActive = true
                                                }
                                            }
                                            eventDetailCell.selectionStyle = .none
                                            eventDetailCell.delegate = self
                                            return eventDetailCell
                                        }
                          
                                    }
                                }
                            }
                        default:
                            var event: AgendaDetail!
                            if calendarStyle == .week{
                                event = self.weekEvents[indexPath.section-2].agendaDetail[indexPath.row]
                            }else{
                                event = eventsArray[indexPath.row]
                            }
                            
                            if(event.type == 5 || event.type == 6){
                                let cell = self.agendaTableView.dequeueReusableCell(withIdentifier: "sectionDetailReuse")
                                let dateLabel = cell?.viewWithTag(40)as!UILabel
                                dateLabel.isHidden = true

                                let titleView2 = cell?.viewWithTag(908) as! UIView
            //                    let titleColor = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].color
                                let titleColor = "#4A74BA"
                              
                                titleView2.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 0.15)
                                
                                let titleLabel = cell?.viewWithTag(44) as! UILabel
                                titleLabel.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                
                                let plusImage = cell?.viewWithTag(45) as! UIImageView
                                
                                let plusButton = cell?.viewWithTag(46) as! UIButton
                                
                                let startDate = cell?.viewWithTag(321) as!UILabel
                                startDate.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                
                                let endDate = cell?.viewWithTag(322) as!UILabel
                                endDate.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                
                                let duration = cell?.viewWithTag(323) as!UILabel
                                duration.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                
                                let bodyBackground = cell?.viewWithTag(70) as!UIStackView
                                
                                let startButton = cell?.viewWithTag(333) as! UIButton
                                let downloadButton = cell?.viewWithTag(71) as! UIButton
                                
                                startDate.isHidden = false
                                endDate.isHidden = false
                                duration.isHidden = false
                                startButton.isHidden = false
                                
                                
                                let startDate1 = self.onlineExamDateFormatter.string(from: self.pickerDateFormatter1.date(from: event.startDate) ?? Date())
                                let endDate1 = self.onlineExamDateFormatter.string(from: self.pickerDateFormatter1.date(from: event.endDate) ?? Date())
                                
                                startDate.text = "-Starts: " + startDate1
                                endDate.text = "-Ends: " + endDate1
                                duration.text = "-Duration: " + event.duration
        //                        sectionBody.isHidden = true
                                downloadButton.isHidden = true
                                plusButton.isHidden = true
                                plusImage.isHidden = true
                                
                                //backgroundView.isHidden = false
                                //  let back = backgroundView.heightAnchor.constraint(equalToConstant: 20)
                                //  back.isActive = true

                                startButton.setImage(UIImage(named: "online_exam_download"), for: .normal)
                                startButton.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                                startButton.layer.borderWidth = 0
                                startButton.layer.masksToBounds = false
                                startButton.layer.borderColor = UIColor.black.cgColor
                                startButton.layer.cornerRadius = startButton.frame.height/2
                                startButton.clipsToBounds = true
                                startButton.removeTarget(nil, action: nil, for: .allEvents)
                                startButton.addTarget(self, action: #selector(openOnlineExam), for: .touchUpInside)
                                titleLabel.text = event.title
                                return cell!
                                
                                
                                
                            }
                            else{
                                let eventDetailCell = agendaTableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse") as! AgendaTableViewCell
                                
                                let studentButton = eventDetailCell.openStudentsButton
                                if(user.userType == 4){
                                    studentButton?.isHidden = true
                                }
                                else{
                                    if(event.enableSubmissions == true){
                                        studentButton?.isHidden = false
                                    }
                                    else{
                                        studentButton?.isHidden = true

                                    }
                                }
                                
                                studentButton?.addTarget(self, action: #selector(openStudentsController), for: .touchUpInside)
                            
                                eventDetailCell.tickView?.isHidden = false
                                eventDetailCell.tickImageView.isHidden = false
                                eventDetailCell.tickButton.isHidden = false
                                
                                eventDetailCell.descriptionLabel.handleURLTap{ url in
//                                    let urlfixed = url.absoluteString.replacingOccurrences(of: " ", with: "%20")
                                    guard let safari = URL(string: url.absoluteString) else { return }
                                    UIApplication.shared.open(safari)
                                }
                               
                                //set onclick
                                eventDetailCell.tickButton.addTarget(self, action: #selector(tickButtonPressed), for: .touchUpInside)
                                eventDetailCell.downloadButton.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
                                
                                var event: AgendaDetail!
                                
                               
                                
                                if calendarStyle == .week{
                                    event = self.weekEvents[indexPath.section-2].agendaDetail[indexPath.row]
                                }else{
                                    event = eventsArray[indexPath.row]
                                }
                                
                                print("events events: \(event)")
                                if(event.enableSubmissions || event.enableLateSubmissions || event.ticked){
                                    eventDetailCell.tickButton.isEnabled = false
                                }
                                else{
                                    eventDetailCell.tickButton.isEnabled = true

                                }
                                let date = self.dateFormatter1.date(from: event.date)
                                eventDetailCell.dateLabel.text = self.dateFormatter11Locale.string(from: date ?? Date())

                                eventDetailCell.descriptionView?.backgroundColor = App.hexStringToUIColorCst(hex: "\(event.backgroudColor)", alpha: 0.5)
                                
                                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                                    .documentType: NSAttributedString.DocumentType.html,
                                    .characterEncoding: String.Encoding.utf8.rawValue  // Specify the character encoding
                                ]
                                
                                if let attributedString = try? NSAttributedString(
                                          data: event.description.data(using: .utf8)!,
                                          options: options,
                                          documentAttributes: nil
                                      ) {
                                    eventDetailCell.descriptionLabel.attributedText = attributedString
                                      }
                                
                                eventDetailCell.titleView?.backgroundColor = App.hexStringToUIColorCst(hex: "\(event.topColor)", alpha: 1.0)
                                eventDetailCell.titleLabel.text = event.title + " - " + event.subject_name
                                eventDetailCell.titleButton.addTarget(self, action: #selector(titleButtonPressed), for: .touchUpInside)
                                //hide text and download button
                                if event.expand == true{
                                    if event.attachment_link == "" {
                                        eventDetailCell.downloadButton.isHidden = true
                                    }else{
                                        eventDetailCell.downloadButton.isHidden = false
                                    }
                                    eventDetailCell.descriptionLabel.isHidden = false
                                }else{
                                    eventDetailCell.downloadButton.isHidden = true
                                    eventDetailCell.descriptionLabel.isHidden = true
                                }
                                let topConstraint = eventDetailCell.descriptionView?.constraints.filter({$0.identifier == "topConstraint"}).first
                                
                                if !event.expand {
                                    eventDetailCell.titleImageView.image = UIImage(named: "+")
                                    eventDetailCell.bottomView?.isHidden = true
                                    topConstraint?.isActive = false
                                }else{
                                    eventDetailCell.titleImageView.image = UIImage(named: "-")
                                    eventDetailCell.bottomView?.isHidden = false
                                    if topConstraint == nil {
                                        let constraint = eventDetailCell.bottomView?.topAnchor.constraint(equalTo: eventDetailCell.titleView!.bottomAnchor, constant: 0)
                                        constraint?.identifier = "topConstraint"
                                        constraint?.isActive = true
                                    }
                                    else {
                                        topConstraint?.isActive = true
                                    }
                                }
                                if indexPath.row == 0{
                                    eventDetailCell.topView?.isHidden = true
                                }else{
                                    eventDetailCell.topView?.isHidden = false
                                }
                                eventDetailCell.tickView?.layer.cornerRadius = eventDetailCell.tickView!.frame.width / 2
                                eventDetailCell.tickImageView.image = UIImage(named: "tick")
                                if event.ticked{
                                    eventDetailCell.tickImageView.isHidden = false
                                    eventDetailCell.tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "\(event.topColor)", alpha: 1.0)
                                    eventDetailCell.tickView?.layer.borderWidth = 0
                                }else{
                                    eventDetailCell.tickImageView.isHidden = true
                                    eventDetailCell.tickView?.backgroundColor = .clear
                                    eventDetailCell.tickView?.layer.borderWidth = 1
                                    eventDetailCell.tickView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#808285", alpha: 1.0).cgColor
                                }
                                
                                if calendarStyle == .week{
                                    if indexPath.row == self.weekEvents[indexPath.section-2].agendaDetail.count - 1{
                                        eventDetailCell.bottomLineView?.isHidden = true
                                    }else{
                                        eventDetailCell.bottomLineView?.isHidden = false
                                    }
                                }else{
                                    if indexPath.row == eventsArray.count - 1{
                                        eventDetailCell.bottomLineView?.isHidden = true
                                    }else{
                                        eventDetailCell.bottomLineView?.isHidden = false
                                    }
                                }
                                eventDetailCell.selectionStyle = .none
                                return eventDetailCell
                            }
               
                        }
                    }
        
       
        
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        self.textSubject = textView.text ?? ""
        addEvent.description = textView.text ?? ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch user.userType{
        
        case 1,2:
            if teacherEdit{
                let header = agendaTableView.dequeueReusableCell(withIdentifier: "teacherHeaderReuse")
                let headerTitle = header?.viewWithTag(710) as! UILabel
              
                if editType == self.agendaType.Assessment.rawValue{
                    switch section{
         
                    case 3:
                        headerTitle.text = "Exam Subject".localiz()
                    case 4:
                        headerTitle.text = "Mark".localiz()
                    case 5:
                        headerTitle.text = "Quiz Title".localiz()
                    case 6:
                        headerTitle.text = "Write about the quiz".localiz()
                    case 15:
                        headerTitle.text = "Mark".localiz()
                    case 10:
                        headerTitle.text = "Estimated Time".localiz()
                    default:
                        if section == 8 {
                            var view: CollapsableSectionHeaderProtocol?
                            if let reuseID = self.sectionHeaderReuseIdentifier() {
                                view = Bundle.main.loadNibNamed(reuseID, owner: nil, options: nil)!.first as? CollapsableSectionHeaderProtocol
                            }
                            view?.tag = section
                            view?.interactionDelegate = self
                            
                            let menuSection = self.model?[section-8]
                            view?.sectionTitleLabel.text = (menuSection?.title ?? "").uppercased()
                            view?.close(true)
                            view?.containerView.backgroundColor = .white
                            return view as? UIView
                        }
                        return UIView()
                    }
                }
             
                else{
                    switch section{
                    case 3:
                        headerTitle.text = "Assignment Title"
                    case 4:
                        let typelabel = self.getTypeLabel(type: editType)
                        headerTitle.text = "\(typelabel) \("Subject".localiz())"
                    
                    case 5:
                        let typename = getTypeLabel(type: editType)
                        headerTitle.text = "\("Write about the".localiz()) \(typename.lowercased())"
                    case 15:
                        headerTitle.text = "Mark".localiz()
                    case 10:
                        headerTitle.text = "Estimated Time".localiz()

                    default:
                        if section == 8{
                            var view: CollapsableSectionHeaderProtocol?
                            if let reuseID = self.sectionHeaderReuseIdentifier() {
                                view = Bundle.main.loadNibNamed(reuseID, owner: nil, options: nil)!.first as? CollapsableSectionHeaderProtocol
                            }
                            view?.tag = section
                            view?.interactionDelegate = self
                            
                            let menuSection = self.model?[section-8]
                            view?.sectionTitleLabel.text = (menuSection?.title ?? "").uppercased()
                            view?.close(true)
                            view?.containerView.backgroundColor = .white
                            return view as? UIView
                        }
                        return UIView()
                    }
                }
                return header?.contentView
            }else{
                let header = agendaTableView.dequeueReusableCell(withIdentifier: "headerReuse")
                let headerTitle = header?.viewWithTag(30) as! UILabel
                switch section{
                case 0,1:
                    return UIView()
                case 2:
                    if selectCalendarDate.isEmpty{
                        if calendarStyle == .week && !self.weekEvents.isEmpty{
                            let dayDate = self.dateFormatter1.date(from: self.weekEvents[section-2].date) ?? Date()
                            let dayString = self.dayFormatterLocale.string(from: dayDate)
                            headerTitle.text = dayString
                        }else{
                            headerTitle.text = self.eventTitle.localiz().capitalized
                        }
                        print("week week1: \(headerTitle.text!)")

                    }else{
                        return UIView()
                    }
                header?.contentView.backgroundColor = .white
                return header?.contentView
                default:
                    if calendarStyle == .week{
                        var dayString = ""
                        if !self.weekEvents.isEmpty{
                            if selectCalendarDate.isEmpty{
                                let dayDate = self.dateFormatter1.date(from: self.weekEvents[section-2].date)
                                dayString = self.dayFormatterLocale.string(from: dayDate ?? Date())
                            }else{
                                let dayDate = self.dateFormatter1.date(from: self.weekEvents[section-3].date)
                                dayString = self.dayFormatterLocale.string(from: dayDate ?? Date())
                            }
                            headerTitle.text = dayString
                        }else{
                            headerTitle.text = self.eventTitle.capitalized
                        }
                    }else{
                        headerTitle.text = self.eventTitle.capitalized
                    }
                    print("week week2: \(headerTitle.text!)")
                    header?.contentView.backgroundColor = .white
                    return header?.contentView
                }
            }
        default:
            let header = agendaTableView.dequeueReusableCell(withIdentifier: "headerReuse")
            let headerTitle = header?.viewWithTag(30) as! UILabel
            switch section{
            case 0,1:
                return UIView()
            default:
                if calendarStyle == .week{
                    let dayDate = self.dateFormatter1.date(from: self.weekEvents[section-2].date)
                    let dayString = self.dayFormatterLocale.string(from: dayDate ?? Date())
                    headerTitle.text = dayString
                }else{
                    headerTitle.text = self.eventTitle.capitalized
                }
            }
            header?.contentView.backgroundColor = .white
            return header?.contentView
        }
    }
    
    //MARK: heightForHeaderInSection
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch user.userType{
   
        case 1,2:
            if teacherEdit{
                if(self.enableGrading == true){
                    if editType == self.agendaType.Assessment.rawValue{
                        switch section{
                        case 3,5,6,8,10,15:
                            return 44
                        default:
                            return 0.01
                        }
                    }else if editType == self.agendaType.Exam.rawValue{
                        switch section{
                        case 3,4,5,8,10,15:
                            return 44
                        default:
                            return 0.01
                        }
                    }else{//homework and classwork
                        //section 4 is hidden to avoid more complex implementation
                        switch section{
                        case 3,4,5,8,10,15:
                            return 44
                        default:
                            return 0.01
                        }
                    }
                }
                else{
                    if editType == self.agendaType.Assessment.rawValue{
                        switch section{
                        case 3,5,6,8,10:
                            return 44
                        default:
                            return 0.01
                        }
                    }else if editType == self.agendaType.Exam.rawValue{
                        switch section{
                        case 3,4,5,8,10:
                            return 44
                        default:
                            return 0.01
                        }
                    }else{//homework and classwork
                        //section 4 is hidden to avoid more complex implementation
                        switch section{
                        case 3,4,5,8,10:
                            return 44
                        default:
                            return 0.01
                        }
                    }
                }
             
            }else{
                switch section{
                case 0,1:
                    return 0.01
                case 2:
                    if selectCalendarDate.isEmpty{
                        return 44
                    }else{
                        return 0.01
                    }
                default:
                    return 44
                }
            }
        default:
            switch section{
            case 0,1:
                return 0.01
            default:
                return 44
            }
        }
    }
    

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if (self.user.userType == 2 || self.user.userType == 1) && self.teacherEdit && (editType == self.agendaType.Homework.rawValue || editType == self.agendaType.Classwork.rawValue) && indexPath.section == 5{
                       return 0.01
                }
        if (self.user.userType == 2 || self.user.userType == 1) && self.teacherEdit && editType == self.agendaType.Assessment.rawValue && indexPath.section == 4{
                       return 0.01
                }
        if(self.editType == self.agendaType.Exam.rawValue && indexPath.section == 6 && self.teacherEdit){
            return 0
        }
        if(self.teacherEdit){
            if(self.enableGrading == false){
                if(indexPath.section == 15){
                    return 0
                }
            }
          
        }
            return UITableView.automaticDimension
       
       
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
       
            if indexPath.section == 0{
                return 250
            }else{
                return 100
            }
      
        
    }
    
    /// Description:
    /// - SwipeCellKit configuration inside tableview edit actions function.
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        guard orientation == .right else { return nil }
        let indexPathTop = indexPath
        
        let deleteAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
            var event: AgendaDetail!
            
            let alert = UIAlertController(title: "Are you sure?".localiz(), message: "Are you sure you want to delete this event ?".localiz(),         preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel".localiz(), style: UIAlertAction.Style.default, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "OK".localiz(),style: UIAlertAction.Style.default,handler: {(_: UIAlertAction!) in
                if self.calendarStyle == .week{
                    if self.weekEvents.isEmpty{
                        event = self.eventsArray[indexPathTop.row]
                    }else if self.selectCalendarDate.isEmpty{
                        event = self.weekEvents[indexPathTop.section - 2].agendaDetail[indexPathTop.row]
                    }else{
                        event = self.weekEvents[indexPathTop.section - 3].agendaDetail[indexPathTop.row]
                    }
                    
                }else{
                    event = self.eventsArray[indexPathTop.row]
                }
                self.removeExam(user: self.user, exam: event)
            }))
            self.present(alert, animated: true, completion: nil)
        
        }
        deleteAction.backgroundColor = .white
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-x")!.scaleImage(scaledToSize: CGSize(width: 44, height: 44))
        
        let edit = SwipeAction(style: .destructive, title: "") { action, indexPath in
            var event: AgendaDetail!
            if self.calendarStyle == .week{
                if self.weekEvents.isEmpty{
                    event = self.eventsArray[indexPathTop.row]
                }else if self.selectCalendarDate.isEmpty{
                    event = self.weekEvents[indexPathTop.section - 2].agendaDetail[indexPathTop.row]
                }else{
                    event = self.weekEvents[indexPathTop.section - 3].agendaDetail[indexPathTop.row]
                }
                
            }else{
                event = self.eventsArray[indexPathTop.row]
            }
            self.editButtonPressed(user: self.user, agenda: event)
        }
        
        edit.image = UIImage(named: "editbutton")!.scaleImage(scaledToSize: CGSize(width: 44, height: 44))
        edit.backgroundColor = .white
        
        if user.userType == 2 || user.userType == 1{
            if self.calendarStyle == .week{
                if self.weekEvents.isEmpty{
                    if self.eventsArray[indexPathTop.row].allow_update == true{
                        //check if date is old
                        let date = self.dateFormatter1.date(from: self.eventsArray[indexPathTop.row].date)
                        let midnightDate = NSDate()
                        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
                        let newDate = cal.startOfDay(for: midnightDate as Date)
                        
                        
                        if (date?.timeIntervalSince(newDate).sign == .minus) {
                            return nil
                        }
                        return [deleteAction, edit]
                    } else {
                        return nil
                    }
                } else if self.selectCalendarDate.isEmpty{
                    if self.weekEvents[indexPathTop.section - 2].agendaDetail[indexPathTop.row].allow_update == true {
                        let date = self.dateFormatter1.date(from: self.weekEvents[indexPathTop.section - 2].agendaDetail[indexPathTop.row].date)
                        
                        let midnightDate = NSDate()
                        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
                        let newDate = cal.startOfDay(for: midnightDate as Date)
                        
                        
                        if (date?.timeIntervalSince(newDate).sign == .minus) {
                            return nil
                        }
                        
                        return [deleteAction, edit]
                    } else {
                        return nil
                    }
                } else {
                    if self.weekEvents[indexPathTop.section - 3].agendaDetail[indexPathTop.row].allow_update == true{
                        let date = self.dateFormatter1.date(from: self.weekEvents[indexPathTop.section - 3].agendaDetail[indexPathTop.row].date)
                        
                        let midnightDate = NSDate()
                        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
                        let newDate = cal.startOfDay(for: midnightDate as Date)
                        
                        
                        if (date?.timeIntervalSince(newDate).sign == .minus) {
                            return nil
                        }
                        
                        return [deleteAction, edit]
                    } else {
                        return nil
                    }
                }
                
            }else{
                if self.eventsArray[indexPathTop.row].allow_update == true{
                    let date = self.dateFormatter1.date(from: self.eventsArray[indexPathTop.row].date)
                    
                    let midnightDate = NSDate()
                    let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
                    let newDate = cal.startOfDay(for: midnightDate as Date)
                    
                
                    if (date?.timeIntervalSince(newDate).sign == .minus) {
                        return nil
                    }
                    return [deleteAction, edit]
                } else {
                    return nil
                }
            }
        }else{
            return nil
        }
    }
    
    @objc func openStudentsController(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        if let indexPath = agendaTableView.indexPath(for: cell) {
            var event: AgendaDetail!
            
            
            if calendarStyle == .week{
                event = self.weekEvents[indexPath.section-2].agendaDetail[indexPath.row]
            }else{
                event = eventsArray[indexPath.row]
            }
            
            if(self.user.userType == 2 || self.user.userType == 1){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentRepliesViewController") as! StudentRepliesViewController
                print("color: \(event.topColor)")
                print("color: \(self.user)")
                print("color: \(event)")
                print("color: \(String(event.id))")
                print("color: \(String(batchId))")
             
                
                
                studentVC.color = event.topColor
                studentVC.user = self.user
                studentVC.asst = event
                studentVC.assignmentId = String(event.id)
                studentVC.batchId = String(batchId)
                studentVC.modalPresentationStyle = .fullScreen
                self.present(studentVC, animated: true, completion: nil)
                
            }
            else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentRepliesViewController") as! StudentRepliesViewController
                studentVC.color = event.topColor
                studentVC.user = self.user
                studentVC.asst = event
                studentVC.assignmentId = String(event.id)
                studentVC.modalPresentationStyle = .fullScreen
                self.present(studentVC, animated: true, completion: nil)
            }
        }
        
    }
    
    /// Description
    /// - Show previous month/week dates inside FSCalendar.
    @objc func calendarBackButtonPressed(sender: UIButton){
        guard let calendarView = agendaTableView.viewWithTag(4) as? FSCalendar else{
            return
        }
        self.tickPressed = false
       
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        if calendarView.scope == .month{
            dateComponents.month = -1 // For prev button
        }else{
            dateComponents.weekOfMonth = -1
        }
        let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage) ?? Date()
        calendarView.setCurrentPage(currentCalendarPage, animated: true)
    }
    
    /// Description
    /// - Show next month/week dates inside FSCalendar.
    @objc func calendarNextButtonPressed(sender: UIButton){
        guard let calendarView = agendaTableView.viewWithTag(4) as? FSCalendar else{
                   return
               }
        self.tickPressed = false
       
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        if calendarView.scope == .month{
            dateComponents.month = 1
        }else{
            dateComponents.weekOfMonth = 1
        }
        let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage) ?? Date()
        calendarView.setCurrentPage(currentCalendarPage, animated: true)
    }
    
    
    /// Description:
    /// - Used to Expand/Collapse exam details.
    @objc func titleButtonPressed(sender: UIButton) {
        guard let calendarView = agendaTableView.viewWithTag(4) as? FSCalendar else{
           return
       }
        let cell = sender.superview?.superview?.superview as! AgendaTableViewCell
        if let indexPath = agendaTableView.indexPath(for: cell) {
            var event: AgendaDetail!
            if calendarView.scope == .week{
                if calendarStyle == .month{
                    event = eventsArray[indexPath.row]
                    event.expand = !event.expand
                    eventsArray[indexPath.row] = event
//                    self.agendaTableView.reloadRows(at: [indexPath], with: .automatic)
                    self.agendaTableView.reloadData()
                }else{
                    if (user.userType == 2 || user.userType == 1) && !selectCalendarDate.isEmpty{
                        event = weekEvents[indexPath.section-3].agendaDetail[indexPath.row]
                        event.expand = !event.expand
                        weekEvents[indexPath.section-3].agendaDetail[indexPath.row] = event
                    }else{
                        event = weekEvents[indexPath.section-2].agendaDetail[indexPath.row]
                        event.expand = !event.expand
                        weekEvents[indexPath.section-2].agendaDetail[indexPath.row] = event
                    }
                    self.agendaTableView.reloadData()
                }
            }else{
                event = eventsArray[indexPath.row]
                event.expand = !event.expand
                eventsArray[indexPath.row] = event
                self.agendaTableView.reloadData()
            }
        }
    }
    
    @objc func downloadButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        if let indexPath = agendaTableView.indexPath(for: cell) {
            var event: AgendaDetail!
            
            if calendarStyle == .week{
                event = self.weekEvents[indexPath.section-2].agendaDetail[indexPath.row]
            }else{
                event = eventsArray[indexPath.row]
            }
            if(event.attachment_link != ""){
                var url = event.attachment_link
               

//                let urlfixed = url.replacingOccurrences(of: " ", with: "%20")
                
                guard let safari = URL(string: url) else { return }
                UIApplication.shared.open(safari)
            }
        }
    }
    
    /// Description:
    /// - Used to mark exam as seen or not.
    @objc func tickButtonPressed(sender: UIButton){
        
        let alert = UIAlertController(title: "Actual Time", message: "Enter Actual Time.", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: NSLocalizedString("SUBMIT", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
            
            let cell = sender.superview?.superview as! UITableViewCell
            if let indexPath = self.agendaTableView.indexPath(for: cell) {
                var event: AgendaDetail!
                if self.calendarStyle == .week{
                    event = self.weekEvents[indexPath.section-2].agendaDetail[indexPath.row]
                }else{
                    event = self.eventsArray[indexPath.row]
                }
                var type = ""
                if self.getTypeLabel(type: event.type) == "Assessment"{
                    type = "exam"
                }else{
                    type = "assignment"
                }
                
                type = self.getTypeLabel(type: event.type)
                
                print("event: \(event)")
                switch self.user.userType{
                case 3:
                    if !event.ticked{
                        self.checkEvent(user: self.user, assignedStudentId: event.students, actualTime: "10")
                    }
    //                else{
    //                    unCheckEvent(user: self.user, studentUsername: self.user.userName, type: type, id: event.id)
    //                }
                case 4:
                    if !event.ticked{
                        self.checkEvent(user: self.user, assignedStudentId: event.students, actualTime: type)
                    }
    //                else{
    //                    unCheckEvent(user: self.user, studentUsername: self.user.admissionNo, type: type, id: event.id)
    //                }
                default:
                    break
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    //MARK: drop down select
    /// Description:
    /// - Update needed textfield from picker array based on the current edit type and selected field index.
    @objc func dropDownFieldPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = agendaTableView.indexPath(for: cell)
        let dropdownField = cell.viewWithTag(715) as! UITextField
        var array: [String] = []
        var title = ""
        if editType == self.agendaType.Assessment.rawValue{
            switch indexPath?.section{
            case 3:
                for subject in teacherSubjectArray{
                    array.append(subject.name)
                }
                title = "subject".localiz()
            
            default://7
                for type in assessmentsType{
                    array.append(type.name)
                }
                title = "assessment type".localiz()
            }
        }else{
            if indexPath?.section == 4{//in homework or classwork
                for subject in teacherSubjectArray{
                    array.append(subject.name)
                }
                title = "subject".localiz()
            }else{//4 in Exam
                for terms in teacherTermsArray{
                    array.append(terms.name)
                }
                title = "subterm".localiz()
            }
        }
        ActionSheetStringPicker.show(withTitle: "\("Choose".localiz()) \(title):", rows: array, initialSelection: 0, doneBlock: {
            picker, ind, values in
            if sender.accessibilityIdentifier == "subject"{
                self.resetData = true
            }
            if array.isEmpty{
                dropdownField.text = ""
                return
            }
            dropdownField.text = array[ind]
            switch indexPath?.section{
            case 4:
                let subjectArray = self.teacherSubjectArray.filter({$0.name == array[ind]})
                if !subjectArray.isEmpty{
                    let subjectId = subjectArray.first!.id
                    self.addEvent.subjectId = subjectId
                    self.selectedSubject = subjectArray.first!
                    if self.teacherTermsArray.first?.id != nil{
                        self.getAssessment(user: self.user, subjectId: subjectId, termId: self.teacherTermsArray.first!.id)
                    }
                }
                
            default://3
                let subjectArray = self.teacherSubjectArray.filter({$0.name == array[ind]})
                if !subjectArray.isEmpty{
                    let subjectId = subjectArray.first!.id
                    self.addEvent.subjectId = subjectId
                    self.selectedSubject = subjectArray.first!
                    if self.teacherTermsArray.first?.id != nil{
                        self.getAssessment(user: self.user, subjectId: subjectId, termId: self.teacherTermsArray.first!.id)
                    }
                }
            }
            self.reloadTableView()

            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    @objc func dateButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        let dateLabel = cell.viewWithTag(701) as! UILabel
        
        let datePicker = ActionSheetDatePicker(title: "Select a Date:".localiz(), datePickerMode: UIDatePicker.Mode.date, selectedDate: Date(), doneBlock: {
            picker, value, index in
            
            if let value = value{
                let result = self.pickerDateFormatter.date(from: "\(value)") ?? Date()
                let date = self.pickerDateResultFormatterLocale.string(from: result)
                dateLabel.text = date
                
                self.addEvent.endDate = self.dateFormatter1.string(from: result)
            }
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!.superview)
        datePicker?.minimumDate = Date()
        
        datePicker?.show()
    }
    
    @objc func timeButtonPressed(sender: UIButton){
//        let cell = sender.superview?.superview as! UITableViewCell
//        let indexPath = agendaTableView.indexPath(for: cell)
//        let timeLabel = cell.viewWithTag(703) as! UILabel
//
//        let timePicker = ActionSheetDatePicker(title: "Select a Time:", datePickerMode: UIDatePickerMode.time, selectedDate: Date(), doneBlock: {
//            picker, value, index in
//
//            let result = App.pickerDateFormatter.date(from: "\(value!)")
//            let date = App.pickerTimeFormatter.string(from: result!)
//            timeLabel.text = date
//
//            if indexPath?.row == 0{
//                self.addEvent.startTime = App.timeFormatter.string(from: result!)
//            }else{
//                self.addEvent.endTime = App.timeFormatter.string(from: result!)
//            }
//            return
//        }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!.superview)
//
//        timePicker?.show()
    }
    
    @objc func attachButtonPressed(sender: UIButton){
        let alert = UIAlertController(title: "Upload picture".localiz(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take photo".localiz(), style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from library".localiz(), style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction(title: "Attach a file".localiz(), style: .default, handler: { _ in
            self.attachDocument()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel".localiz(), style: .cancel, handler: nil))
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Description:
    /// - Check for fields validation in each case.
    @objc func saveButtonPressed(sender: UIButton){
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
        switch editType{
        case self.agendaType.Exam.rawValue:
             if addEvent.subjectId == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Select a subject".localiz(), actions: [ok])
            }else if addEvent.description.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Write a description".localiz(), actions: [ok])
            }else if selectCalendarDate.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Select a due date on the calendar".localiz(), actions: [ok])
            }else if self.enableGrading && addEvent.mark == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Write a mark".localiz(), actions: [ok])
            }else{
                self.addEvent.startDate = App.dateFormatter.string(from: self.dateFormatter1.date(from: selectCalendarDate) ?? Date())
                self.addEvent.enableSubmissions = enableSubmissions
                self.addEvent.enableLateSubmissions = enableLateSubmissions
                self.addEvent.enableDiscussions = enableDiscussions
                self.addEvent.enableGrading = enableGrading

                if isCalendarEditing{
                    self.editAssignment(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                }else{
                    self.createAssignment(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                }
            }
        case self.agendaType.Homework.rawValue, self.agendaType.Classwork.rawValue:
            if addEvent.subjectId == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Select a subject".localiz(), actions: [ok])
            }else if addEvent.description.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Write a description".localiz(), actions: [ok])
            }else if selectCalendarDate.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Select a due date on the calendar".localiz(), actions: [ok])
            }else if self.enableGrading && addEvent.mark == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Write a mark".localiz(), actions: [ok])
            }else{
                self.addEvent.startDate = App.dateFormatter.string(from: self.dateFormatter1.date(from: selectCalendarDate) ?? Date())
                print(self.addEvent.startDate)
                print(selectCalendarDate)
                if !allStudents{
                    selectedStudentd = []
                    for student in model![0].items.filter({$0.active == true}){
                        selectedStudentd.append(student.id)
                    }
                    
                    if selectedStudentd.isEmpty{
                        App.showAlert(self, title: "Error".localiz(), message: "You need to select students".localiz(), actions: [ok])
                    }else{
                        self.addEvent.students = selectedStudentd
                        self.addEvent.enableSubmissions = enableSubmissions
                        self.addEvent.enableLateSubmissions = enableLateSubmissions
                        self.addEvent.enableDiscussions = enableDiscussions
                        self.addEvent.enableGrading = enableGrading
                        
                        print("addEvent: \(self.addEvent)")
                        if self.isFileSelected || self.isSelectedImage{
                            if isCalendarEditing{
                                self.editAssignmentWithFile(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                            }else{
                                self.createAssignmentWithFile(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                            }
                        }else{
                            if isCalendarEditing{
                                self.editAssignment(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                            }else{
                                self.createAssignment(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                            }
                        }
                    }
                }else{
                    self.addEvent.students = model![0].items.map({return $0.id})
                    self.addEvent.enableSubmissions = enableSubmissions
                    self.addEvent.enableLateSubmissions = enableLateSubmissions
                    self.addEvent.enableDiscussions = enableDiscussions
                    self.addEvent.enableGrading = enableGrading
                    if self.isFileSelected || self.isSelectedImage{
                        if isCalendarEditing{
                            self.editAssignmentWithFile(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                        }else{
                            self.createAssignmentWithFile(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                        }
                    }else{
                        if isCalendarEditing{
                            self.editAssignment(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                        }else{
                            self.createAssignment(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                        }
                    }
                }
            }
        default:
            //Quiz/Assessment
            self.addEvent.enableSubmissions = enableSubmissions
            self.addEvent.enableLateSubmissions = enableLateSubmissions
            self.addEvent.enableDiscussions = enableDiscussions
            self.addEvent.enableGrading = enableGrading
            
            if addEvent.subjectId == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Select a subject".localiz(), actions: [ok])
            }else if addEvent.description.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Write a description".localiz(), actions: [ok])
            }else if self.enableGrading && addEvent.mark == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Write a mark".localiz(), actions: [ok])
            }else if addEvent.title.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Write a title".localiz(), actions: [ok])
            }else if selectCalendarDate.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Select a due date on the calendar".localiz(), actions: [ok])
            }else{
                self.addEvent.startDate = App.dateFormatter.string(from: self.dateFormatter1.date(from: selectCalendarDate) ?? Date())
                if isCalendarEditing{
                    self.editAssignment(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                }else{
                    self.createAssignment(user: self.user, event: self.addEvent, sectionId: String(self.batchId!))
                }
            }
        }
    }
    
    @objc func addButtonPressed(){
        if self.teacherEdit {
            self.teacherEdit = false
            self.resetSavedData()
        }else{
            let dateIn = (self.dateFormatter1.date(from: self.selectCalendarDate) ?? Date()).toLocalTime()
            let currentDateString = self.dateFormatter1.string(from: Date())
            let currentDateIn = (self.dateFormatter1.date(from: currentDateString) ?? Date()).toLocalTime()
            
            if selectCalendarDate == "" {
                App.showMessageAlert(self, title: "", message: "You need to select a day from the calendar".localiz(), dismissAfter: 1.5)
            }else if dateIn < currentDateIn {
                App.showMessageAlert(self, title: "", message: "You can't select a past date".localiz(), dismissAfter: 1.5)
            }else{
                self.teacherEdit = true
                //disable section change in sectionvc
                SectionVC.canChange = false
            }
            self.textSubject = ""
        }
        if isCalendarEditing{
            self.isCalendarEditing = false
            self.allStudents = true
        }
        
        self.agendaTableView.reloadData()
    }
    
    func editButtonPressed(user: User, agenda: AgendaDetail) {
//        resetSavedData()
        print("agenda edited: \(agenda)")
        editStudents = true
        self.agendaForEdit = agenda
        //setup addevent stuff
        self.addEvent.id = self.agendaForEdit.id
        self.addEvent.description = self.agendaForEdit.description
        self.addEvent.title = self.agendaForEdit.title
        if self.agendaForEdit.full_mark != "" {
            self.addEvent.mark = Double(self.agendaForEdit.full_mark)!
        }
        if let subject = self.teacherSubjectArray.first(where: {$0.name == self.agendaForEdit.subject_name}){
            self.addEvent.subjectId = subject.id
            print("subject subject: \(subject)")
            print("subject subject: \(self.addEvent)")


        }
        if let term = self.teacherTermsArray.first(where: {$0.name == self.agendaForEdit.sub_term}){
            self.addEvent.groupId = term.id
            self.selectedGroup = term.name
            print("exam exam group4: \(self.selectedGroup)")
        }
        if let assessment = self.assessmentsType.first(where: {$0.name == self.agendaForEdit.assessment_type}){
            self.addEvent.assessmentTypeId = assessment.id
        }
        
        self.teacherEdit = true
        self.isCalendarEditing = true
        //disable section change in sectionvc
        SectionVC.canChange = false
        
        //check if students array is custom
        var students = self.agendaForEdit.students
        students = String(students.dropFirst())
        students = String(students.dropLast())
        
        if students != "" {
            self.allStudents = false
        }else{
            self.allStudents = true
        }
        if(self.allStudents){
            for i in 0...self.teacherStudentsArray.count - 1{
                self.teacherStudentsArray[i].active = true
            }
        }
        else{
            for i in 0...self.teacherStudentsArray.count - 1{
                let arrayStudents = students.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
                if arrayStudents.contains(self.teacherStudentsArray[i].id){
                        if let row = self.teacherStudentsArray.firstIndex(where: {$0.id == self.teacherStudentsArray[i].id}) {
                            self.teacherStudentsArray[row].active = true
                        }
                    }else{
                        if let row = self.teacherStudentsArray.firstIndex(where: {$0.id == self.teacherStudentsArray[i].id}) {
                            self.teacherStudentsArray[row].active = false
                        }
                    }
                
            }
        }
        

        
        //set the edit type
        self.editType = self.agendaForEdit.type
        
        if self.editType == self.agendaType.Exam.rawValue{
            addEvent.type = "Exam"
        }else if self.editType == self.agendaType.Assessment.rawValue{
            addEvent.type = "Assessment"
        }else if self.editType == self.agendaType.Homework.rawValue{
            addEvent.type = "Homework"
        }else if self.editType == self.agendaType.Classwork.rawValue{
            addEvent.type = "Classwork"
        }
        
        self.agendaTableView.reloadData()
    }
    
    func resetSavedData(){
        //end edit
        self.teacherEdit = false
        //remove stored data
        self.pdfURL = nil
        self.compressedDataToPass = nil
        self.selectedImage = UIImage()
        self.isFileSelected = false
        self.isSelectedImage = false
        print("exam exam group1")
        self.selectedGroup = ""
        self.selectedSubject.name = ""
        self.typeName = ""
        self.agendaForEdit = nil
        print("chosen subject3")
        self.selectedSubject = Subject.init(id: 0, name: "", code: "", sectionId: 0, sectionName: "", color: "", imperiumCode: "")
        
        let textView = self.agendaTableView.viewWithTag(720) as? UITextView
        let textField = self.agendaTableView.viewWithTag(730) as? UITextField
        let dropdownField = self.agendaTableView.viewWithTag(715) as? UITextField
        textView?.text = ""
        textField?.text = ""
        dropdownField?.text = ""
        
        let date = self.dateFormatter1.string(from: Date())
        let time = App.pickerTimeFormatter.string(from: Date())
        self.currentDate = self.dateFormatter1.string(from: Date())
        self.addEvent = AgendaExam(id: 0, title: "", type: "Classwork", students: [], subjectId: 0, startDate: date, startTime: time, endDate: date, endTime: time, description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: false, enableLateSubmissions: false, enableDiscussions: false, enableGrading: false, estimatedTime: 0)
        
        self.editType = self.agendaType.Classwork.rawValue
        SectionVC.didLoadAgenda = false
        
        //enable section change in sectionvc
        SectionVC.canChange = true
        
        //reset selected students
        self.allStudents = true
        self.selectedStudentd.removeAll()
        
    }
    
    @objc func allStudentsSwitchPressed(sender: PWSwitch){
        self.allStudents = !self.allStudents
        self.editStudents = false
        if(tempStdArray.isEmpty){
            self.tempStdArray = self.teacherStudentsArray
        }
        if(self.allStudents){
            self.tempStdArray = self.teacherStudentsArray
            for i in 0...self.teacherStudentsArray.count - 1{
                self.teacherStudentsArray[i].active = true
            }
        }
        else{
            self.teacherStudentsArray = self.tempStdArray
        }
    }
    
    
    @objc func enableSubmissionsSwitchPressed(sender: PWSwitch){
        self.enableSubmissions = !self.enableSubmissions
        print(self.enableSubmissions)

    }
    
    @objc func enableLateSubmissionsSwitchPressed(sender: PWSwitch){
        self.enableLateSubmissions = !self.enableLateSubmissions
        print(self.enableLateSubmissions)

    }
    
    @objc func enableDiscussionsSwitchPressed(sender: PWSwitch){
        self.enableDiscussions = !self.enableDiscussions
        print(self.enableDiscussions)

    }
    
    @objc func enableGradingSwitchPressed(sender: PWSwitch){
        self.enableGrading = !self.enableGrading
        self.agendaTableView.reloadData()
        print(self.enableGrading)
    }
    @objc func studentSwitchPressed(sender: PWSwitch){
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = agendaTableView.indexPath(for: cell)
     

        let active = model![indexpath!.section - 8].items[indexpath!.row].active
        model![indexpath!.section - 8].items[indexpath!.row].active = !active
        
        if(self.teacherStudentsArray.count > 0){
            for i in 0...self.teacherStudentsArray.count - 1{
                if(self.teacherStudentsArray[i].id == model![indexpath!.section - 8].items[indexpath!.row].id){
                    self.teacherStudentsArray[i].active = model![indexpath!.section - 8].items[indexpath!.row].active
                }
            }
            
        }
        
    }
    
    
    /// Description:
    /// - Add background circle to configure workload pie chart appearance.
    func assignbackground(view: UIView){
        for view in view.subviews{
            if view.tag == 1000{
                view.removeFromSuperview()
            }
        }
        let background = UIImage(named: "circle")
        var imageView : UIImageView!
        
        switch self.view.frame.width{
        //Iphone XMAX - IPhone Plus:
        case 414:
            imageView = UIImageView(frame: CGRect(x: view.frame.center.x/2 - 17.5, y: view.frame.center.y/2 - 47, width: 243, height: 243))
        //IPhone 5S:
        case 320:
            imageView = UIImageView(frame: CGRect(x: view.frame.center.x/2 - 20.1, y: view.frame.center.y/2 - 26.7, width: 200, height: 200))
        //IPhone X - Iphone:
        default:
            imageView = UIImageView(frame: CGRect(x: view.frame.center.x/2 - 14, y: view.frame.center.y/2 - 34, width: 215, height: 215))
        }
        
        imageView.tag = 1000
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
//        imageView.center = view.center
        view.addSubview(imageView)
//        view.layer.zPosition = 1
//        view.superview!.sendSubview(toBack: imageView)
    }
    
    
    /// Description:
    /// - Setup PieChat.
    func setup(pieChartView chartView: PieChartView) {
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = true
        chartView.holeRadiusPercent = 0
        chartView.transparentCircleRadiusPercent = 0
        chartView.chartDescription?.enabled = false
        // IPhone 5S
        if self.view.frame.width == 320{
            chartView.setExtraOffsets(left: 30, top: 0, right: 30, bottom: 0)
        }else{
            chartView.setExtraOffsets(left: 40, top: 0, right: 40, bottom: 0)
        }
        chartView.drawCenterTextEnabled = false
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 0
        chartView.rotationEnabled = false
        chartView.maxAngle = 360
        chartView.centerAttributedText = nil
        chartView.highlightPerTapEnabled = true
        chartView.legend.enabled = false
        chartView.backgroundColor = .clear
        
        let count = 4
        let entries = (0..<count).map { (i) -> PieChartDataEntry in
        //IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            if self.percentage[i] != 0{
                return PieChartDataEntry(value: self.percentage[i], label: self.chartLabel[i])
            }
            return PieChartDataEntry(value: self.percentage[i], label: nil)
        }
        
        let set = PieChartDataSet(values: entries, label: nil)
        set.sliceSpace = 0
        set.selectionShift = 5
        set.colors = self.chartColors
        
        set.valueLinePart1OffsetPercentage = 0
        if self.percentage[2] == 100{
            set.valueLinePart1Length = 1.6
        }else{
            //IPhone 5S:
            if self.view.frame.width == 320{
                set.valueLinePart1Length = 1.3
            }else{
                set.valueLinePart1Length = 1.25
            }
        }
        set.valueLinePart2Length = 1
        set.xValuePosition = .outsideSlice
        set.yValuePosition = .outsideSlice
        set.valueLineColor = .clear
        
        let data = PieChartData(dataSet: set)
        
//        pFormatter.numberStyle = .none
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.zeroSymbol = ""
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        //IPhone 5S:
        if self.view.frame.width == 320{
            data.setValueFont(UIFont(name: "OpenSans", size: 10)!)
        }else{
            data.setValueFont(UIFont(name: "OpenSans", size: 11)!)
        }
        data.setValueTextColor(App.hexStringToUIColorCst(hex: "#6d6e71", alpha: 1.0))
        
        data.setDrawValues(true)
        
        chartView.data = data
        
        chartView.setNeedsDisplay()
    }
    
    
    /// Description:
    /// - Update events based on the selected value.
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        initEventArray()
        switch highlight.x{
        case 0.0:
            let examEvents = self.eventsArray.filter({$0.type == self.agendaType.Assessment.rawValue || $0.type == self.agendaType.Assessment.rawValue})
            self.eventsArray = examEvents
        case 1.0:
            let examEvents = self.eventsArray.filter({$0.type == self.agendaType.Exam.rawValue})
            self.eventsArray = examEvents
        case 3.0:
            let examEvents = self.eventsArray.filter({$0.type == self.agendaType.Homework.rawValue})
            self.eventsArray = examEvents
        default:
            self.eventsArray = []        }
        self.reloadTableView()
    }
    
    
    /// Description:
    /// Update pie chart view percentage values.
    func initEventArray(){
        self.eventsArray = []
        for event in self.events{
            for detail in event.agendaDetail{
                if detail.date == self.selectCalendarDate{
                    self.eventsArray.append(detail)
                }
            }
        }
        
        percentage = [0,0,100,0]
        let groupedEvents = Dictionary(grouping: self.eventsArray, by: {$0.type})
        for events in groupedEvents{
            switch events.key{
            case self.agendaType.Assessment.rawValue:
                for event in events.value{
                    percentage[0] += event.percentage
                }
            case self.agendaType.Exam.rawValue:
                for event in events.value{
                    percentage[1] += event.percentage
                }
            case self.agendaType.Homework.rawValue:
                for event in events.value{
                    percentage[3] += event.percentage
                }
            default:
                break
            }
        }
        self.workload = percentage[0] + percentage[1] + percentage[3]
        percentage[2] = 100 - self.workload
    }
    
    func reloadTableView(){
        let currentOffset = agendaTableView.contentOffset
        UIView.setAnimationsEnabled(false)
        agendaTableView.reloadData()
        UIView.setAnimationsEnabled(true)
        agendaTableView.setContentOffset(currentOffset, animated: true)
    }
    
}


// MARK: - UICollecionView functions:
extension AgendaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if teacherEdit{
            return 4
        }else{
            if filteredEvents.isEmpty{
                return filteredEvents.count
            }
            return filteredEvents.count + 1
        }
    }
    
    //MARK: Collection View For Events
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventsCell", for: indexPath)
        let eventIcon = cell.viewWithTag(21) as! UIImageView
        let counterLabel = cell.viewWithTag(22) as! UILabel
        let titleLabel = cell.viewWithTag(23) as! UILabel
        let eventColorView: UIView? = cell.viewWithTag(24)
        let tickView: UIView? = cell.viewWithTag(25)
        let tickImageView = cell.viewWithTag(26) as! UIImageView
        let todayString = self.dateFormatter1.string(from: Date())
        eventColorView!.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
        eventColorView?.layer.masksToBounds = false
        titleLabel.font = UIFont(name: "OpenSans-Light", size: 11)
        cell.isUserInteractionEnabled = true
        cell.contentView.alpha = 1
        
        if teacherEdit{
            if self.selectCalendarDate != "" && self.dateFormatter1.date(from: self.selectCalendarDate) ?? Date() < self.dateFormatter1.date(from: todayString) ?? Date(){
                tickView?.isHidden = false
                tickImageView.isHidden = true
                tickView?.backgroundColor = .white
                tickView?.layer.borderWidth = 0
                let icon = teacherEditEvent[indexPath.row].icon
                if icon.contains("http"){
                    let url = URL(string: icon)
                    App.addImageLoader(imageView: eventIcon, button: nil)
                    eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                        App.removeImageLoader(imageView: eventIcon, button: nil)
                    }
                }else{
                    eventIcon.image = UIImage(named: icon)
                }
                counterLabel.isHidden = true
                titleLabel.text = getTypeLabel(type: teacherEditEvent[indexPath.row].type!)
                eventColorView?.backgroundColor = App.hexStringToUIColor(hex: teacherEditEvent[indexPath.row].color, alpha: 1.0)
                cell.contentView.alpha = 0.5
                cell.isUserInteractionEnabled = false
            }else if self.selectCalendarDate == todayString{//for same day only classwork allowed
                //in case of edit, dont show other than the edit type
                if isCalendarEditing{
                    if self.agendaForEdit.type == self.agendaType.Classwork.rawValue{
                        editType = self.agendaType.Classwork.rawValue
                        addEvent.type = "Classwork"
                        tickView?.isHidden = false
                        tickImageView.isHidden = false
                        tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
                        tickView?.layer.borderWidth = 0
                        let icon = teacherEditEvent[indexPath.row].icon
                        if icon.contains("http"){
                            let url = URL(string: icon)
                            App.addImageLoader(imageView: eventIcon, button: nil)
                            eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                                App.removeImageLoader(imageView: eventIcon, button: nil)
                            }
                        }else{
                            eventIcon.image = UIImage(named: icon)
                        }
                        counterLabel.isHidden = true
                        titleLabel.text = getTypeLabel(type: teacherEditEvent[indexPath.row].type!)
                        eventColorView?.backgroundColor = App.hexStringToUIColor(hex: teacherEditEvent[indexPath.row].color, alpha: 1.0)
                    }else{
                        cell.isHidden = true
                    }
                }else if teacherEditEvent[indexPath.row].type == self.agendaType.Classwork.rawValue{
                    editType = self.agendaType.Classwork.rawValue
                    addEvent.type = "Classwork"
                    tickView?.isHidden = false
                    tickImageView.isHidden = false
                    tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
                    tickView?.layer.borderWidth = 0
                    let icon = teacherEditEvent[indexPath.row].icon
                    if icon.contains("http"){
                        let url = URL(string: icon)
                        App.addImageLoader(imageView: eventIcon, button: nil)
                        eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                            App.removeImageLoader(imageView: eventIcon, button: nil)
                        }
                    }else{
                        eventIcon.image = UIImage(named: icon)
                    }
                    counterLabel.isHidden = true
                    titleLabel.text = getTypeLabel(type: teacherEditEvent[indexPath.row].type!)
                    eventColorView?.backgroundColor = App.hexStringToUIColor(hex: teacherEditEvent[indexPath.row].color, alpha: 1.0)
                    cell.isHidden = false
                }else{
                    tickView?.isHidden = false
                    tickImageView.isHidden = true
                    tickView?.backgroundColor = .white
                    tickView?.layer.borderWidth = 1
                    tickView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0).cgColor
                    let icon = teacherEditEvent[indexPath.row].icon
                    if icon.contains("http"){
                        let url = URL(string: icon)
                        App.addImageLoader(imageView: eventIcon, button: nil)
                        eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                            App.removeImageLoader(imageView: eventIcon, button: nil)
                        }
                    }else{
                        eventIcon.image = UIImage(named: icon)
                    }
                    counterLabel.isHidden = true
                    titleLabel.text = getTypeLabel(type: teacherEditEvent[indexPath.row].type!)
                    eventColorView?.backgroundColor = App.hexStringToUIColor(hex: teacherEditEvent[indexPath.row].color, alpha: 1.0)
                    cell.contentView.alpha = 0.5
                    cell.isUserInteractionEnabled = false
                    cell.isHidden = false
                }
            }
            
            //EDIT HERE
            
            else{
                //in case of edit, dont show other than the edit type
                if isCalendarEditing{
                    tickView?.isHidden = false
                    tickImageView.isHidden = false
                tickView?.backgroundColor = .white
                    tickView?.layer.borderWidth = 1
                tickView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0).cgColor
                    let icon = teacherEditEvent[indexPath.row].icon
                    if icon.contains("http"){
                        let url = URL(string: icon)
                        App.addImageLoader(imageView: eventIcon, button: nil)
                        eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                            App.removeImageLoader(imageView: eventIcon, button: nil)
                        }
                    }else{
                        eventIcon.image = UIImage(named: icon)
                    }
                    counterLabel.isHidden = true
                    titleLabel.text = getTypeLabel(type: teacherEditEvent[indexPath.row].type!)
                    eventColorView?.backgroundColor = App.hexStringToUIColor(hex: teacherEditEvent[indexPath.row].color, alpha: 1.0)
                    cell.isHidden = false
                    if editType == teacherEditEvent[indexPath.row].type{
 //                   if self.agendaForEdit.type == teacherEditEvent[indexPath.row].type {
//                        tickView?.isHidden = false
//                        tickImageView.isHidden = false
                    tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
//                        tickView?.layer.borderWidth = 1
//                    tickView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#568ef6", alpha: 1.0).cgColor
                        
//                    }else{
//                        cell.isHidden = true
//                    }
                    }
                }else if editType == teacherEditEvent[indexPath.row].type{
                    tickView?.isHidden = false
                    tickImageView.isHidden = false
                    tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
                    tickView?.layer.borderWidth = 0
                    let icon = teacherEditEvent[indexPath.row].icon
                    if icon.contains("http"){
                        let url = URL(string: icon)
                        App.addImageLoader(imageView: eventIcon, button: nil)
                        eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                            App.removeImageLoader(imageView: eventIcon, button: nil)
                        }
                    }else{
                        eventIcon.image = UIImage(named: icon)
                    }
                    counterLabel.isHidden = true
                    titleLabel.text = getTypeLabel(type: teacherEditEvent[indexPath.row].type!)
                    eventColorView?.backgroundColor = App.hexStringToUIColor(hex: teacherEditEvent[indexPath.row].color, alpha: 1.0)
                    cell.isHidden = false
                }else{
                    tickView?.isHidden = false
                    tickImageView.isHidden = true
                    tickView?.backgroundColor = .white
                    tickView?.layer.borderWidth = 1
                    tickView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0).cgColor
                    let icon = teacherEditEvent[indexPath.row].icon
                    if icon.contains("http"){
                        let url = URL(string: icon)
                        App.addImageLoader(imageView: eventIcon, button: nil)
                        eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                            App.removeImageLoader(imageView: eventIcon, button: nil)
                        }
                    }else{
                        eventIcon.image = UIImage(named: icon)
                    }
                    counterLabel.isHidden = true
                    titleLabel.text = getTypeLabel(type: teacherEditEvent[indexPath.row].type!)
                    eventColorView?.backgroundColor = App.hexStringToUIColor(hex: teacherEditEvent[indexPath.row].color, alpha: 1.0)
                    cell.isHidden = false
                }
                
                cell.contentView.alpha = 0.5
                let teacherEvent: Event = teacherEditEvent[indexPath.row]
                if (100 - workload) >= self.agendaWorkload.examLoad && teacherEvent.type == self.agendaType.Exam.rawValue{
                    cell.contentView.alpha = 1
                }else if (100 - workload) >= self.agendaWorkload.quizLoad && teacherEvent.type == self.agendaType.Assessment.rawValue{
                    cell.contentView.alpha = 1
                }else if (100 - workload) >= self.agendaWorkload.homeworkLoad && teacherEvent.type == self.agendaType.Homework.rawValue{
                    cell.contentView.alpha = 1
                }else if teacherEvent.type == self.agendaType.Classwork.rawValue{
                    cell.contentView.alpha = 1
                }
            }
            
            
            
            
            
        }else if indexPath.row == filteredEvents.count{
            cell.isHidden = false
            let padding: CGFloat = 0
            let size = CGSize(width: eventColorView!.frame.size.width - padding, height: eventColorView!.frame.size.height - padding)
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: CGPoint.zero, size: size)
            gradient.colors = []
            
            for event in teacherEditEvent{
                gradient.colors?.append(App.hexStringToUIColor(hex: event.color, alpha: 1.0).cgColor)
            }
            gradient.accessibilityValue = "gradient"
            
            eventColorView!.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
            
            let shape = CAShapeLayer()
            shape.lineWidth = 2
            
            let diameter: CGFloat = min(gradient.frame.height, gradient.frame.width)
            shape.path = UIBezierPath(ovalIn: CGRect(x: eventColorView!.frame.width / 2 - diameter / 2 + 3, y: eventColorView!.frame.height / 2 - diameter / 2 + 1, width: diameter - 6, height: diameter - 6)).cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            gradient.mask = shape
            
            eventColorView!.layer.addSublayer(gradient)
            eventColorView!.layer.masksToBounds = true
            eventColorView?.backgroundColor = .white
            
            counterLabel.isHidden = false
            tickView?.isHidden = true
            tickImageView.isHidden = true
            eventIcon.image = UIImage(named: allEvent.icon)
            counterLabel.text = "\(allEvent.counter)"
            titleLabel.text = getTypeLabel(type: allEvent.type!)
            titleLabel.font = UIFont(name: "OpenSans-Light", size: 11)
        }else{
            cell.isHidden = false
            tickView?.isHidden = true
            tickImageView.isHidden = true
            counterLabel.isHidden = false
            let icon = filteredEvents[indexPath.row].icon
            if icon.contains("http"){
                let url = URL(string: icon)
                App.addImageLoader(imageView: eventIcon, button: nil)
                eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                    App.removeImageLoader(imageView: eventIcon, button: nil)
                }
            }else{
                eventIcon.image = UIImage(named: icon)
            }
            counterLabel.text = "\(filteredEvents[indexPath.row].counter)"
            if filteredEvents[indexPath.row].type == self.agendaType.Assessment.rawValue{
                titleLabel.text = "Quiz".localiz()
            }else{
                titleLabel.text = getTypeLabel(type: filteredEvents[indexPath.row].type!)
            }
            eventColorView?.backgroundColor = App.hexStringToUIColor(hex: filteredEvents[indexPath.row].color, alpha: 1.0)
        }
        eventColorView?.isHidden = false
        eventColorView?.layer.cornerRadius = eventColorView!.frame.height / 2
        eventColorView?.dropCircleShadow()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
        if indexPath.row == filteredEvents.count && !teacherEdit{
            print("type1")
            self.currentDate = ""
            self.tickPressed = false
           
            print("type1: \(self.tickPressed)")
            self.eventsArray = self.allEvent.agendaDetail
            self.eventsArray = Array(Set(self.eventsArray))
            self.eventsArray = self.eventsArray.sorted(by: {self.dateFormatter1.date(from: $0.date) ?? Date() < self.dateFormatter1.date(from: $1.date) ?? Date()})
            self.eventTitle = getTypeLabel(type: self.allEvent.type!)
            calendarStyle = .month
            
        }else{
            if teacherEdit{
                print("type3")
                print("exam exam group2")
                selectedGroup = ""
//                self.addEvent.groupId = 0
                let teacherEvent: Event = teacherEditEvent[indexPath.row]
                if (100 - workload) >= self.agendaWorkload.examLoad && teacherEvent.type == self.agendaType.Exam.rawValue{
                    editType = teacherEvent.type!
                    addEvent.type = "Exam"
                }else if (100 - workload) >= self.agendaWorkload.quizLoad && teacherEvent.type == self.agendaType.Assessment.rawValue{
                    editType = teacherEvent.type!
                    addEvent.type = "Assessment"
                }else if (100 - workload) >= self.agendaWorkload.homeworkLoad && teacherEvent.type == self.agendaType.Homework.rawValue{
                    editType = teacherEvent.type!
                    addEvent.type = "Homework"
                }else if teacherEvent.type == self.agendaType.Classwork.rawValue{
                    editType = teacherEvent.type!
                    addEvent.type = "Classwork"
                }
                
//                if isCalendarEditing {
//                    if editType == teacherEditEvent[indexPath.row].type{
//                        print("dodo")
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventsCell", for: indexPath)
//
//                    let tickView: UIView? = cell.viewWithTag(25)
//                    let tickImageView = cell.viewWithTag(26) as! UIImageView
//
//                    tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#568ef6", alpha: 1.0)
//                        tickView?.layer.borderWidth = 1
//                    tickView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#568ef6", alpha: 1.0).cgColor
//                    }
//                }
                
            }else{
                self.currentDate = ""
                print("type2")
                self.tickPressed = false
               
                print("type2: \(self.tickPressed)")
                calendarStyle = .month
                self.eventsArray = filteredEvents[indexPath.row].agendaDetail
                self.eventTitle = getTypeLabel(type: filteredEvents[indexPath.row].type!)
                self.arrayType = self.eventsArray
                self.titleType = self.eventTitle
                
            }
        }
        self.reloadTableView()
        //calendarStyle = temp
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: - Select Picture:
extension AgendaViewController: UIImagePickerControllerDelegate, CropViewControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true , completion: nil )
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if(info[UIImagePickerController.InfoKey.mediaType] as! CFString == kUTTypeImage){
            guard let selectedImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
            
            let cropController = CropViewController(croppingStyle: croppingStyle, image: selectedImage)
            
            cropController.delegate = self
            
            if croppingStyle == .circular {
                if picker.sourceType == .camera {
                    picker.pushViewController(cropController, animated: true)

//                    picker.dismiss(animated: true, completion: {
//                        self.present(cropController, animated: true, completion: nil)
//                    })
                } else {
                    picker.pushViewController(cropController, animated: true)
                }
            }
            else { //otherwise dismiss, and then present from the main controller
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                    //self.navigationController!.pushViewController(cropController, animated: true)
                })
            }
            
           
//            print("entered here image picker")
//            self.selectedImage = selectedImage
//            self.isSelectedImage = true
//            self.isFileSelected = false
    //        let imageView = self.addFormTableView.viewWithTag(721) as! UIImageView
    //        imageView.image = selectedImage
            
            if #available(iOS 11.0, *) {
                if let asset = info[.phAsset] as? PHAsset, let fileName = asset.value(forKey: "filename") as? String {
                    filename = fileName
                } else if let url = info[.imageURL] as? URL {
                    filename = url.lastPathComponent
                }
            } else {
                filename = "SLink"
            }
            
            print("filename: \(filename)")
            
            self.agendaTableView.reloadData()
        }
        else{
            self.pdfURL = info[UIImagePickerController.InfoKey.mediaURL]as? NSURL as URL?
            let filetype = self.pdfURL.description.suffix(4).lowercased()
            
            if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                
                let data = try! Data(contentsOf: pdfURL! as URL)
                
                print("File size before compression: \(data)")

                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                
                compressVideo(inputURL: pdfURL as! URL, outputURL: compressedURL) { (exportSession) in
                                guard let session = exportSession else {
                                    return
                                }

                                switch session.status {
                                case .unknown:
                                    break
                                case .waiting:
                                    break
                                case .exporting:
                                    break
                                case .completed:
                                    guard let compressedData = NSData(contentsOf: compressedURL) else {
                                        return
                                    }
                                    self.compressedDataToPass = compressedData
                                    print("File size after compression: \(self.compressedDataToPass.length)")
                                case .failed:
                                    break
                                case .cancelled:
                                    break
                                }
                            }
            }
            
            
            
            do{
                let asset = AVURLAsset(url: self.pdfURL! as URL , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                filename = self.pdfURL.lastPathComponent
//                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
//                let thumbnail = UIImage(cgImage: cgImage)
                self.selectedImage = UIImage(named: "video")!
                self.isFileSelected = true
                self.isSelectedImage = false
                self.agendaTableView.reloadData()
            }
            catch let error {
                    print("*** Error generating thumbnail: \(error.localizedDescription)")
                }
            
        }
        
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
            let urlAsset = AVURLAsset(url: inputURL, options: nil)
            guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
                handler(nil)

                return
            }

            exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously { () -> Void in
                handler(exportSession)
            }
        }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
           self.croppedRect = cropRect
           self.croppedAngle = angle
           updateImageViewWithImage(image, fromCropViewController: cropViewController)
       }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            self.croppedRect = cropRect
            self.croppedAngle = angle
            updateImageViewWithImage(image, fromCropViewController: cropViewController)
        }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        //            self.isFileSelected = false
        
        self.selectedImage = image
        self.isSelectedImage = true
        self.isFileSelected = false
        let imageView = agendaTableView.viewWithTag(721) as! UIImageView
            imageView.image = image
        //        self.isSelectedImage = true
        //        let imageView = calendarTableView.viewWithTag(721) as! UIImageView
        //        imageView.image = selectedImage
            layoutImageView()
            
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            
            if cropViewController.croppingStyle != .circular {
                imageView.isHidden = true
                
                cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                       toView: imageView,
                                                       toFrame: CGRect.zero,
                                                       setup: { self.layoutImageView() },
                                                       completion: {
                                                        imageView.isHidden = false })
            }
            else {
                imageView.isHidden = false
                cropViewController.dismiss(animated: true, completion: nil)
                
            }
        }
    
    public func layoutImageView() {
        let imageView = agendaTableView.viewWithTag(721) as! UIImageView
            guard imageView.image != nil else { return }
            
            let padding: CGFloat = 20.0
            
            var viewFrame = self.view.bounds
            viewFrame.size.width -= (padding * 2.0)
            viewFrame.size.height -= ((padding * 2.0))
            
            var imageFrame = CGRect.zero
            imageFrame.size = imageView.image!.size;
            
            if imageView.image!.size.width > viewFrame.size.width || imageView.image!.size.height > viewFrame.size.height {
                let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
                imageFrame.size.width *= scale
                imageFrame.size.height *= scale
                imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
                imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
                imageView.frame = imageFrame
            }
            else {
                imageView.frame = imageFrame;
                imageView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            }
        }
    
    func openCamera() {
//        var minimumSize: CGSize = CGSize(width: 60, height: 60)
//
//        var croppingParameters: CroppingParameters {
//            return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: minimumSize)
//        }
//
//        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
//            // Do something with your image here.
//            if image != nil{
//                self?.selectedImage = image!
//                self?.isSelectedImage = true
//                self?.isFileSelected = false
//                let attach = self?.attachmentPickertime.string(from: Date())
//                if(self?.filename != nil){
//                    self!.filename = "Madrasatie\(attach!)"
//                }
//                else{
//                    self?.filename = "SLink"
//                }
//
//
//                let imageView = self?.agendaTableView.viewWithTag(721) as! UIImageView
//                imageView.image = image
//            }
//            self?.dismiss(animated: true, completion: nil)
//        }
//        present(cameraViewController, animated: true, completion: nil)
        
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //imagePicker.allowsEditing = true
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - FSCalendat functions:
extension AgendaViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter.string(from: date)
        if let color = self.fillDefaultColors[key]{
            return color.first
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCell", for: date, at: position)
        cell.backgroundColor = .clear
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: monthPosition)
    }
    
    //MARK: selecting a date
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        self.currentDate = dateFormatter1.string(from: date)
        print("date1: \(self.currentDate)")
        print("date2: \(selectCalendarDate)")
        print("date3: \(currentDate)")
        self.tickPressed = true
       
        
        if selectCalendarDate == currentDate {
            if teacherEdit{
                return false
            }
            self.currentDate = ""
            selectCalendarDate = ""
            self.addEvent.startDate = ""
        }else{
            self.selectCalendarDate = dateFormatter1.string(from: date)
            print("date4: \(self.selectCalendarDate)")
            self.addEvent.startDate = self.selectCalendarDate
            print("date5: \(self.addEvent.startDate)")
            if teacherEdit{
                let todayString = dateFormatter1.string(from: Date())
                print("date6: \(todayString)")
                if self.selectCalendarDate == todayString{
                    editType = self.agendaType.Classwork.rawValue
                    addEvent.type = "Classwork"
                }
                self.reloadTableView()
            }
        }
        
        calendarStyle = .month
        self.initializeCalendarDates()

        return true
    }
    
    /// Description:
    /// - This function is used after changing calendar week or month to update date label and events details.
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // Setup Calendar Label
        let calendarMonthLabel = self.agendaTableView.viewWithTag(3) as! UILabel
        configureCalendarLabel(calendar: calendar, calendarMonthLabel: calendarMonthLabel, cellIndex: 1)
        
        SectionVC.didLoadAgenda = false
        self.getAgendaData()
    }
    
    /// Description: This function is used to configure date label attributed text.
    ///
    /// - Parameters:
    ///   - calendar: FSCalendar.
    ///   - calendarMonthLabel: Label that we need to configure it.
    ///   - cellIndex: Label cell index 0 or 1.
    func configureCalendarLabel(calendar: FSCalendar, calendarMonthLabel: UILabel, cellIndex: Int){
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            var currentCalendar = Calendar.current
            currentCalendar.locale = Locale(identifier: "\(self.languageId )")
            let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendar.currentPage)
            let month = values.month
            let year = values.year
            let stringMonth = currentCalendar.monthSymbols[month! - 1]
//            var dateArray = [Date]()
//            var dates = [Date]()
//            for cell in calendar.visibleCells(){
//                dateArray.append(calendar.date(for: cell)!)
//                if !cell.isPlaceholder{
//                    dates.append(calendar.date(for: cell)!)
//                }
//            }
            
//            if dateArray != []{
//                let firstDateString = self.dateFormatter.string(from: dateArray.min()!)
//                let lastDateString = self.dateFormatter.string(from: dateArray.max()!)
//                let firstDate = firstDateString.split(separator: "-").first
//                let lastDate = lastDateString.split(separator: "-").first
//                if calendar.scope == .month{
            if Locale.current.languageCode == "hy" {
                calendarMonthLabel.text = "\(App.getArmenianMonth(month: month!)) \(year!)"
            }else{
                calendarMonthLabel.text = "\(stringMonth) \(year!)"
            }
        
//            calendarMonthLabel.text = "\(stringMonth) \(year ?? 0)"
//                }else{
//                    calendarMonthLabel.text = "\("Week of".localiz())\n\(stringMonth) \(year ?? 0)"
//                    let text = calendarMonthLabel.text!
//                    let attributesText = NSMutableAttributedString(string: text)
//                    let noUserText = (text as NSString).range(of: "Week of".localiz())
//                    attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 17)!], range: noUserText)
//                    let helpText = (text as NSString).range(of: "\(stringMonth) \(year ?? 0)")
//                    attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 15)!], range: helpText)
//                    calendarMonthLabel.attributedText = attributesText
//                }
//            }
            
//            if cellIndex != 0{
//                let eventsMonthLabel = self.agendaTableView.viewWithTag(11) as! UILabel
//                eventsMonthLabel.text = "\("Month of ".localiz())\(stringMonth)"
//                let text = eventsMonthLabel.text!
//                let attributesText = NSMutableAttributedString(string: text)
//                let noUserText = (text as NSString).range(of: "Month of ".localiz())
//                attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 14)!], range: noUserText)
//                let helpText = (text as NSString).range(of: "\(stringMonth)")
//                attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 14)!], range: helpText)
//                eventsMonthLabel.attributedText = attributesText
//            }
//        }
    }
    
    /// Description:
    /// - This function is used to draw colored layer on dates contains an event or more.
    func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let diyCell = (cell as! DIYCalendarCell)
        let dateString: String = self.dateFormatter1.string(from: date)
        // Custom today circle
        //        diyCell.circleImageView.isHidden = !self.gregorian.isDateInToday(date)
        // Configure selection layer
        diyCell.titleLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
        if position == .current {
            
            var selectionType = SelectionType.none
            if self.selectedDate.contains(dateString) {
                let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
                let previousDateString = self.dateFormatter1.string(from: previousDate)
                let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
                let nextDateString = self.dateFormatter1.string(from: nextDate)
                
                let key = self.dateFormatter1.string(from: date)
                var color = self.fillDefaultColors[key]
                var previousColor = self.fillDefaultColors[previousDateString]
                var nextColor = self.fillDefaultColors[nextDateString]
                if previousColor != nil{
                    previousColor = Array(Set(previousColor!))
                }
                if nextColor != nil{
                    nextColor = Array(Set(nextColor!))
                }
                
                if color != nil{
                    color = Array(Set(color!))
                    if color?.count == 1{
                        diyCell.contentView.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
                        diyCell.selectionLayer.fillColor = color?.first?.cgColor
                        cell.titleLabel.textColor = .white
                        
                        if self.selectedDate.contains(previousDateString) && self.selectedDate.contains(nextDateString){
                            if previousColor?.first == nextColor?.first && previousColor?.first == color?.first && previousColor?.count == 1 && nextColor?.count == 1{
                                selectionType = .middle
                            }else if previousColor?.first == color?.first && previousColor?.count == 1 && color?.first != nextColor?.first{
                                selectionType = .rightBorder
                            }else if previousColor?.first != color?.first && color?.first == nextColor?.first && nextColor?.count == 1{
                                selectionType = .leftBorder
                            }else{
                                selectionType = .single
                            }
                        }
                        else if self.selectedDate.contains(previousDateString) && !self.selectedDate.contains(nextDateString) {
                            if previousColor?.first == color?.first && previousColor?.count == 1{
                                selectionType = .rightBorder
                            }else{
                                selectionType = .single
                            }
                        }
                        else if !self.selectedDate.contains(previousDateString) && self.selectedDate.contains(nextDateString) {
                            if nextColor?.first == color?.first && nextColor?.count == 1{
                                selectionType = .leftBorder
                            }else{
                                selectionType = .single
                            }
                        }
                        else if !self.selectedDate.contains(previousDateString) && !self.selectedDate.contains(nextDateString) {
                            selectionType = .single
                        }
                        else {
                            selectionType = .none
                        }
                    }else if color!.count > 1{
                        cell.titleLabel.textColor = App.hexStringToUIColorCst(hex: "#6d6e71", alpha: 1.0)
                        
                        let padding: CGFloat = 0
                        let size = CGSize(width: diyCell.frame.size.width - padding, height: diyCell.frame.size.height - padding)
                        let gradient = CAGradientLayer()
                        gradient.frame = CGRect(origin: CGPoint.zero, size: size)
                        gradient.colors = []
                        for c in color!{
                            gradient.colors?.append(c.cgColor)
                        }
                        gradient.accessibilityValue = "gradient"
                        
                        diyCell.contentView.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
                        
                        let shape = CAShapeLayer()
                        shape.lineWidth = 2
                        
                        let diameter: CGFloat = min(gradient.frame.height, gradient.frame.width)
                        shape.path = UIBezierPath(ovalIn: CGRect(x: diyCell.contentView.frame.width / 2 - diameter / 2 + 3, y: diyCell.contentView.frame.height / 2 - diameter / 2 + 1, width: diameter - 6, height: diameter - 6)).cgPath
                        shape.strokeColor = UIColor.black.cgColor
                        shape.fillColor = UIColor.clear.cgColor
                        gradient.mask = shape
                        
                        diyCell.contentView.layer.addSublayer(gradient)
                        
                    }else{
                        diyCell.contentView.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
                        selectionType = .none
                    }
                    
                    if dateFormatter1.string(from: date) == selectCalendarDate{
                        cell.titleLabel.textColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
                    }
                }
            }
            else {
                cell.titleLabel.textColor = App.hexStringToUIColorCst(hex: "#6d6e71", alpha: 1.0)
                diyCell.contentView.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
                selectionType = .none
            }
            if selectionType == .none {
                diyCell.selectionLayer.isHidden = true
                if dateFormatter1.string(from: date) == selectCalendarDate{
                    cell.titleLabel.textColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
                }else{
                    cell.titleLabel.textColor = App.hexStringToUIColorCst(hex: "#6d6e71", alpha: 1.0)
                }
                return
            }
            diyCell.selectionLayer.isHidden = false
            diyCell.selectionType = selectionType
            
        }else {
            diyCell.selectionLayer.isHidden = true
            diyCell.contentView.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
        }
    }
    
}


// MARK: - UITextField Fucntions.
/// Used to update addEvent variable data.
extension AgendaViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cell = textField.superview?.superview as! UITableViewCell
        let indexPath = agendaTableView.indexPath(for: cell)
        
        print(indexPath?.section)
        switch indexPath?.section{
        case 4, 15:
            let stringMark = "\(textField.text ?? "")\(string)"
            if let mark = Double(stringMark){
                addEvent.mark = mark
            }
        case 10,12,14:
            
            // Define a character set for valid input (in this case, digits)
            let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")

            // Check if the replacement string contains only characters from the allowed set
            let isValidInput = string.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil

            if(isValidInput){
                let stringTime = "\(textField.text ?? "")\(string)"
                if let time = Int(stringTime){
                    addEvent.estimatedTime = time
                }
            }
           
        case 3,5,6:
            let title = "\(textField.text ?? "")\(string)"
            addEvent.title = title
        default:
            return false
        }
        return true
    }
}

// MARK: - Handle Sections page delegate function:
extension AgendaViewController: SectionVCToAgendaDelegate{
   
    
    /// Description:
    ///
    /// - Parameter type: selected menu index.
    /// - This function is called when user select an item from option menu to reload agenda data.
    func agendaFilterSectionView(type: Int) {
        guard let calendarView = agendaTableView.viewWithTag(4) as? FSCalendar else{
           return
       }
        let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
        let monthLabel = agendaTableView.viewWithTag(3) as! UILabel
        self.startDate = "01-09-1900"
        self.endDate = "30-09-2500"
        switch type{
        //Monthly View:
        case 0:
            self.calendarStyle = .month
            self.tempCalendarStyle = .month
            calendarView.setScope(.month, animated: true)
            calendarHeight?.constant = 250
        //Weekly View:
        case 1:
            print("weekly view entered")
            self.calendarStyle = .week
            self.tempCalendarStyle = .week
            calendarView.setScope(.week, animated: true)
            calendarHeight?.constant = 90
            monthLabel.text = "\n"
        //Yearly View:
        case 2:
            calendarView.setScope(.month, animated: true)
            self.calendarStyle = .month
            let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.today ?? Date())
            let month = values.month
            let year = values.year
            if month! > 10{
                self.startDate = "01-09-\(year!)"
                self.endDate = "30-09-\(year!+1)"
            }else{
                self.startDate = "01-09-\(year!-1)"
                self.endDate = "30-09-\(year!)"
            }
            calendarHeight?.constant = 250
        default:
            break
        }
        SectionVC.didLoadAgenda = false
        self.getAgendaData()
    }
    
    /// Description:
    ///
    /// - Parameters:
    ///   - batchId: In case the user is parent batch well be nil.
    ///   - children: In case the user is employee children will be nil.
    /// - This function is called from Section page when user changed.
    func switchAgendaChildren(user: User, batchId: Int?, children: Children?) {
        self.user = user
        self.batchId = batchId
        self.teacherEdit = false
        print("chosen subject1")
        self.selectedSubject = Subject.init(id: 0, name: "", code: "", sectionId: 0, sectionName: "", color: "", imperiumCode: "")
        
        SectionVC.didLoadAgenda = false
        if self.agendaTableView != nil{
            self.getAgendaData()
        }
    }
    
    
    /// Description:
    /// - Call and reload agenda data functions.
    /// - Calculate start date and end date.
    func getAgendaData(){
        if SectionVC.didLoadAgenda {
            return
        }
        
        guard let calendarView = self.agendaTableView.viewWithTag(4) as? FSCalendar else { return }
        var startDate: Date
        let endDate: Date
        print("calendar style: \(calendarStyle!)")
        if tempCalendarStyle == .week {
            
            print("CURRENT PAGE ", calendarView.currentPage)
            
            startDate = calendarView.currentPage
            startDate = calendarView.gregorian.date(byAdding: .day, value: 0, to: startDate)!
            endDate = calendarView.gregorian.date(byAdding: .day, value: 6, to: startDate)!
            print("entered week")
        } else { // .month
            //This will return First and Last month Dates:
            startDate = calendarView.gregorian.date(byAdding: .day, value: 0, to: calendarView.currentPage)!
            endDate = calendarView.gregorian.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
            print("entered month")
        }
        
        let fromDate = App.dateFormatter.string(from: startDate)
        let toDate = App.dateFormatter.string(from: endDate)
        if(tempCalendarStyle != nil){
            print("temp calendar: \(tempCalendarStyle!)")

        }
        print("start date: \(fromDate)")
        print("end date: \(toDate)")
        
        switch self.user.userType{
        case 1,2:
            print("case1: \(self.batchId)")
            if self.batchId != nil && self.batchId != 0{
                self.viewSectionAssignment(user: self.user, sectionId: self.batchId!, startDate: fromDate, endDate: toDate, agendaTheme: self.agendaTheme)
                self.getSectionStudent(user: user, sectionId: self.batchId!)
            }else{
                self.weekEvents.removeAll()
                self.eventsArray.removeAll()
                self.events.removeAll()

                self.initializeCalendarDates()
                self.reloadTableView()
            }
        case 3:
            self.getAgenda(user: self.user, studentUsername: self.user.userName, startDate: fromDate, endDate: toDate, agendaTheme: self.agendaTheme)
        case 4:
            self.getAgenda(user: self.user, studentUsername: self.user.admissionNo, startDate: fromDate, endDate: toDate, agendaTheme: self.agendaTheme)
        default:
            break
        }
    }
    
    /// Description:
    /// - This function is called from Section page when class changed.
    func agendaBatchId(user: User, classId: Int, batchId: Int) {
        print("weekly pressed")
        self.user = user
        self.classId = classId
        self.batchId = batchId
//        SectionVC.didLoadAgenda = false
        if self.agendaTableView != nil{
            if classId == 0 && batchId == 0 && user.classes.isEmpty && (user.userType == 2 || user.userType == 1){
//                self.agendaDelegate?.agendaToCalendar()
            }else{
                self.getAgendaData()
                print("chosen subject2")
//                self.selectedSubject = Subject.init(id: 0, name: "", code: "", sectionId: 0, sectionName: "", color: "", imperiumCode: "")
            }
        }
    }
    
    /// Description:
    /// - This function is called from Section page when colors and icons changed.
    func updateAgendaTheme(theme: AppTheme?) {
        if let theme = theme{
            self.agendaTheme = theme.agendaTheme
//            if agendaTableView != nil{
//                if theme.activeModule.contains(where: {$0.id == App.agendaID && $0.status == 1}){
//                    getAgendaData()
//                }else{
//                    agendaDelegate?.agendaToCalendar()
//                }
//            }
        }
    }
}

// MARK: - API Calls:
extension AgendaViewController{
    /// Description: Get Agenda Data
    /// - Call "get_student_assignments" API to get assessment data and then sort them before initializeCalendarDates.
    func getAgenda(user: User, studentUsername: String, startDate: String, endDate: String, agendaTheme: AgendaTheme){
        
        if !self.refreshControl.isRefreshing {
            self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        }
        Request.shared.getAgenda(user: user, studentUsername: studentUsername, startDate: startDate, endDate: endDate, agendaTheme: agendaTheme) { (message, agendaData, status) in
            if status == 200{
                SectionVC.didLoadAgenda = true
                self.weekEvents = []
                self.eventsArray = []
                self.events = agendaData!
                
                var allEventsCounter = 0
                var allEventsDetails: [AgendaDetail] = []
                for event in self.events{
                    allEventsCounter += event.agendaDetail.count
                    for detail in event.agendaDetail{
                        allEventsDetails.append(detail)
                    }
                }
                allEventsDetails = allEventsDetails.sorted(by: {self.dateFormatter1.date(from: $0.date) ?? Date() < self.dateFormatter1.date(from: $1.date) ?? Date()})
                self.allEvent = Event(id: 1, icon: "empty", color: "", counter: allEventsCounter, type: self.agendaType.AllUpcoming.rawValue, date:"", percentage: 0.0, detail: [], agendaDetail: allEventsDetails)
                self.eventsArray = self.allEvent.agendaDetail
                self.eventsArray = Array(Set(self.eventsArray))
                 self.eventsArray = self.eventsArray.sorted(by: {self.dateFormatter1.date(from: $0.date) ?? Date() < self.dateFormatter1.date(from: $1.date) ?? Date()})
                self.eventTitle = self.getTypeLabel(type: self.allEvent.type!)
                
                if(self.tickPressed){
                    self.currentDate = self.selectCalendarDate
                    print("date1: \(self.currentDate)")
                    print("date2: \(self.selectCalendarDate)")
                    print("date3: \(self.currentDate)")
                        print("date4: \(self.selectCalendarDate)")
                        self.addEvent.startDate = self.selectCalendarDate
                        print("date5: \(self.addEvent.startDate)")
                        if self.teacherEdit{
                            let todayString = self.dateFormatter1.string(from: Date())
                            print("date6: \(todayString)")
                            if self.selectCalendarDate == todayString{
                                self.editType = self.agendaType.Classwork.rawValue
                                self.addEvent.type = "Classwork"
                            }
                            self.reloadTableView()
                        }
                    //}
                    self.calendarStyle = .month
                    self.initializeCalendarDates()
                    self.tickPressed = false
                    //self.calendarStyle = temp
                    
                }
              
                else{
                    print("entered here2")
                    self.initializeCalendarDates()
                }
                //self.initializeCalendarDates()
                //self.agendaTableView.reloadData()
            } else {
                print("entered error 1")
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }

            if !self.refreshControl.isRefreshing {
                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    /// Description: Check Events
    /// - Call "check_assignment" to mark an assessment as checked.
    func checkEvent(user: User, assignedStudentId: String, actualTime: String ){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.checkAgenda(user: user, assignedStudentId: assignedStudentId, actualTime: actualTime) { (message, data, status) in
            if status == 200{
                SectionVC.didLoadAgenda = false
                self.getAgendaData()
            }
            else{
                print("entered error 2")

                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
    /// Description: Uncheck Events
    /// - Call "uncheck_assignment" to mark an assessment as unchecked.
    func unCheckEvent(user: User, studentUsername: String, type: String, id: Int){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.unCheckAgenda(user: user, studentUsername: studentUsername, type: type, id: id) { (message, data, status) in
            if status == 200{
                SectionVC.didLoadAgenda = false
                self.getAgendaData()
            }
            else{
                print("entered error 3")

                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
    /// Description: Get Teacher Subject
    /// - Call "get_teacher_subjects" to mark an assessment as unchecked.
    /// - Select the first subject by default.
    func getSubjects(user: User, sectionId: Int){
        Request.shared.getTeacherSubject(user: user, sectionId: sectionId) { (message, subjectData, status) in
            if status == 200{
                self.teacherSubjectArray = subjectData!
                if !self.teacherSubjectArray.isEmpty{
                    self.selectedSubject = self.teacherSubjectArray.first!
                    let date = self.dateFormatter1.string(from: Date())
                    let time = App.pickerTimeFormatter.string(from: Date())
                    self.addEvent = AgendaExam(id: 0, title: "", type: "Classwork", students: [], subjectId: self.selectedSubject.id, startDate: date, startTime: time, endDate: date, endTime: time, description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: false, enableLateSubmissions: false, enableDiscussions: false, enableGrading: false, estimatedTime: 0)
                }
                
//                self.getTerms(user: user, sectionId: self.batchId ?? 0)
            }
            else{
                print("entered error 4")

                print("error getTeacherSubject")
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR4".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    // Get Teacher Terms:
    /// Description: Get Teacher Terms
    /// - Call "get_sub_terms" API to get terms data and select the first term by default.
    func getTerms(user: User, sectionId: Int){
        Request.shared.getTeacherTerms(user: user, sectionId: sectionId) { (message, termsData, status) in
            if status == 200{
                self.teacherTermsArray = termsData!
                if !self.teacherTermsArray.isEmpty && !self.teacherSubjectArray.isEmpty{
                   self.getAssessment(user: self.user, subjectId: self.teacherSubjectArray.first!.id, termId: self.teacherTermsArray.first!.id)
                }
            }
            else{
                print("entered error 5")

                print("error getTeacherTerms")
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR5".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    // Get Assessment Type:
    
    /// Description: Get Assessment Type
    /// - Call "get_assessment_types" API and get assessment type data.
    func getAssessment(user: User, subjectId: Int, termId: Int){
        Request.shared.getAssessmentType(user: user, subjectId: subjectId, termId: termId) { (message, assessmentData, status) in
            if status == 200{
                self.assessmentsType = assessmentData!
                self.reloadTableView()
            }
            else{
                print("entered error 6")

                print("error getAssessmentType")
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR6".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    /// Description: View Section Assignment
    /// - Call "view_section_assignments" API and get section assessment for employee users.
    /// - Init all upcoming event and then initializeCalendarDates.
    func viewSectionAssignment(user: User, sectionId: Int, startDate: String, endDate: String, agendaTheme: AgendaTheme){
        
        if !self.refreshControl.isRefreshing {
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        }
        
        print("STARTTT DATE ", startDate, " end DATEEE ", endDate)
        
        Request.shared.viewSectionAssignment(user: user, sectionId: sectionId, startDate: startDate, endDate: endDate, agendaTheme: agendaTheme) { (message, agendaData, agendaWorkload, status) in
            if status == 200{
                SectionVC.didLoadAgenda = true
                self.agendaWorkload = agendaWorkload!
                self.weekEvents = []
                self.eventsArray = []
                self.events = agendaData!
                self.chartColors = [App.hexStringToUIColor(hex: self.agendaTheme.quizColor, alpha: 1.0), App.hexStringToUIColor(hex: self.agendaTheme.examColor, alpha: 1.0), UIColor.clear, App.hexStringToUIColor(hex: self.agendaTheme.homeworkColor, alpha: 1.0)]
                
                var allEventsCounter = 0
                var allEventsDetails: [AgendaDetail] = []
                for event in self.events{
                    allEventsCounter += event.agendaDetail.count
                    for detail in event.agendaDetail{
                        allEventsDetails.append(detail)
                    }
                }
                allEventsDetails = allEventsDetails.sorted(by: {self.dateFormatter1.date(from: $0.date) ?? Date() < self.dateFormatter1.date(from: $1.date) ?? Date()})
                self.allEvent = Event(id: 1, icon: "empty", color: "", counter: allEventsCounter, type: self.agendaType.AllUpcoming.rawValue, date: "", percentage: 0.0, detail: [], agendaDetail: allEventsDetails)
                self.eventsArray = self.allEvent.agendaDetail
                self.eventsArray = Array(Set(self.eventsArray))
                self.eventsArray = self.eventsArray.sorted(by: {self.dateFormatter1.date(from: $0.date) ?? Date() < self.dateFormatter1.date(from: $1.date) ?? Date()})
                self.eventTitle = self.getTypeLabel(type: self.allEvent.type!)
                let calendarView = self.agendaTableView.viewWithTag(4) as? FSCalendar
                if calendarView != nil && calendarView?.scope == .week{
                    self.currentDate = ""
                    self.selectCalendarDate = ""
                }
                self.initializeCalendarDates()
                self.getSubjects(user: user, sectionId: self.batchId ?? 0)
            }
            else{
                print("entered error 7: \(message)")

                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }

            if !self.refreshControl.isRefreshing {
                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            }
            self.refreshControl.endRefreshing()
            self.reloadTableView()
        }
    }
    /// Description: Create Assignment
    /// - Call "create_assignment" to submit data and create an assessment.
    func createAssignment(user: User, event: AgendaExam, sectionId: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        SectionVC.canChange = true
        Request.shared.createAssignment(user: user, agenda: event, sectionId: sectionId) { (message, agendaData, status) in
            if status == 200{
                App.showMessageAlert(self, title: "Success".localiz(), message: "Saved!".localiz(), dismissAfter: 2.0)
                self.resetSavedData()
                self.getAgendaData()
            }
            else{
                print("entered error 8")

                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
    func editAssignment(user: User, event: AgendaExam, sectionId: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        SectionVC.canChange = true
        Request.shared.editAssignment(user: user, agenda: event, sectionId: sectionId) { (message, agendaData, status) in
            if status == 200{
                App.showMessageAlert(self, title: "Success".localiz(), message: "Saved!".localiz(), dismissAfter: 2.0)
                self.resetSavedData()
                self.getAgendaData()
            }
            else{
                print("entered error 9")

                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
    /// Description: Create Assignment
    /// - Call "create_assignment" to submit data and create an assessment.
    func createAssignmentWithFile(user: User, event: AgendaExam, sectionId: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        SectionVC.canChange = true
        Request.shared.createAssignmentWithFile(user: user, file: self.pdfURL, fileCompressed: compressedDataToPass, image: self.selectedImage, isSelectedImage: self.isSelectedImage, agenda: event, filename: self.filename, sectionId: sectionId) { (message, agendaData, status) in
            if status == 200{
                App.showMessageAlert(self, title: "Success".localiz(), message: "Saved!".localiz(), dismissAfter: 2.0)
                self.resetSavedData()
                self.getAgendaData()
            }
            else{
                print("entered error 10")

                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
    func editAssignmentWithFile(user: User, event: AgendaExam, sectionId: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        SectionVC.canChange = true
        Request.shared.editAssignmentWithFile(user: user, file: self.pdfURL, image: self.selectedImage, isSelectedImage: self.isSelectedImage, agenda: event, filename: self.filename, sectionId: sectionId, fileCompressed: compressedDataToPass) { (message, agendaData, status) in
            if status == 200{
                App.showMessageAlert(self, title: "Success".localiz(), message: "Saved!".localiz(), dismissAfter: 2.0)
                self.resetSavedData()
                self.getAgendaData()
            }
            else{
                print("entered error 11")

                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
    /// Description: Get Section Student
    /// - Call "get_section_students" API and get section students.
    func getSectionStudent(user: User, sectionId: Int){
        Request.shared.getSectionStudent(user: user, sectionId: sectionId) { (message, studentData, status) in
            if status == 200{
                self.teacherStudentsArray = studentData!
                self.model = [ItemsHeader(isVisible: false, items: studentData!, title: "Student List".localiz())]
            }
            else{
                print("entered error 12")

                print("error getSectionStudent")
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR12".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    /// Description: Remove Exam
    /// - Call "delete_assignment" to remove as assessment.
    func removeExam(user: User, exam: AgendaDetail){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.removeAssignment(user: user, assignmentId: exam.id) { (message, studentData, status) in
            if status == 200{
                SectionVC.didLoadAgenda = false
                self.getAgendaData()
            }
            else{
                print("entered error 13")

                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
}

extension Date {
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}

extension String {
    static let shortDateUS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    var shortDateUS: Date? {
        return String.shortDateUS.date(from: self)
    }
}

