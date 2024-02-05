//
//  CalendarViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 5/17/18.
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
/// - Delegate from Calendar page to Section page.
protocol CalendarViewControllerDelegate{
    func calendar(calendarType: CalendarStyle?)
}

class CalendarViewController: CollapsableTableViewController{
    
    @IBOutlet weak var calendarTableView: UITableView!
    
    var croppingStyle = CropViewCroppingStyle.default
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    
    var eventsArray: [EventDetail] = []
    var filteredEvents: [Event] = []
    var weekEvents: [Event] = []
    var events: [Event] = []
    var eventTitle = ""
    var selectedDate: [String] = []
    var currentDate = ""
    var delegate: CalendarViewControllerDelegate?
    var startDate = "01-09-1900"
    var endDate = "30-09-2500"
    var calendarStyle: CalendarStyle?
    var user: User!
    var child: Children!
    var teacherEdit = false //is add pressed now
    var teacherDepartments: [CalendarSwitch] = []
    var teacherClasses: [CalendarSwitch] = []
    var item: [[CalendarEventItem]] = []
    var isSchoolSwitch = true
    var imagePicker = UIImagePickerController()
    var agendaType = AgendaDetail.agendaType.self
    var editType = 5 //Events
    var teacherSectionArray: [CalendarEventItem] = []
    var teacherDepartmentArray: [CalendarEventItem] = []
    var StudentsBySectionArray: [CalendarEventItem] = []
    var employeesByDepartmentArray: [CalendarEventItem] = []
    var occasion: Occasion!
    var occasionForEdit: EventDetail!
    var batchId: Int!
    var teacherEditEvents: [Event] = []
    var selectCalendarDate = ""
    var allEvent: Event!
    var holidayStartDate: Date? = nil
    var holidayEndDate: Date? = nil
    var eventEndDate: Date? = nil
    var eventStartDate: Date? = nil
    var eventStartTime: Date? = nil
    var eventEndTime: Date? = nil
    var calendarTheme: CalendarTheme!
    var selectedCalendarDate: Date = Date()
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    var isCalendarEditing: Bool = false
    var textTitle = ""
    var textSubject = ""
    var selectedImage : UIImage = UIImage()
    var isSelectedImage = false
    var refreshControl = UIRefreshControl()
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")
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
            return "Meetings".localiz()
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
        case "Meeetings":
            return 7
        case "All Upcoming":
            return 8
        default:
            return 0
        }
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    
    fileprivate lazy var attachmentPickertime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
        }()
    
    fileprivate lazy var ddateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    lazy var dateFormatter1Locale: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.locale = Locale(identifier: "\(self.languageId)")
            return formatter
    }()
    
    fileprivate lazy var dateTimeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy HH:mm:ss"
    //        formatter.locale = Locale(identifier: "\(self.languageId)")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
    }()
    
    fileprivate lazy var dateTimeFormatterLocale: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy HH:mm:ss"
            formatter.locale = Locale(identifier: "\(self.languageId)")
            return formatter
    }()
    
    
    fileprivate lazy var pickerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var pickerDateResultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMMM yyyy"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var pickerTimeResultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var occasionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    var fillDefaultColors: [String: [UIColor]] = [:]
    var canRefresh = true
    var overrideDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarStyle = .week
        initEditEvents()
        if self.user.userType == 2 || self.user.userType == 1{
            self.getSectionsDepartments(user: self.user)
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localiz())
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        print("access calendartableview")
        calendarTableView.addSubview(refreshControl) // not required when using UITableViewController
        calendarTableView.delegate = self
        calendarTableView.dataSource = self
        calendarTableView.tableFooterView = UIView()
        self.calendarTableView.isHidden = true
        imagePicker.delegate = self
    }
    
    @objc func refresh() {
       // Code to refresh table view
        SectionVC.didLoadCalendar = false
        self.getCalendarAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    /// Description:
    /// - Init add events data
    func initEditEvents(){
        teacherEditEvents = []
        var event = Event(id: 1, icon: calendarTheme.eventIcon, color: calendarTheme.eventBg, counter: 2, type: self.agendaType.Events.rawValue, date: "", percentage: 0, detail: [], agendaDetail: [])
        teacherEditEvents.append(event)

        event = Event(id: 2, icon: calendarTheme.holidayIcon, color: calendarTheme.holidayBg, counter: 2, type: self.agendaType.Holidays.rawValue, date: "", percentage: 0, detail: [], agendaDetail: [])
        teacherEditEvents.append(event)

        event = Event(id: 3, icon: calendarTheme.dueIcon, color: calendarTheme.dueBg, counter: 2, type: self.agendaType.Dues.rawValue, date: "", percentage: 0, detail: [], agendaDetail: [])
        teacherEditEvents.append(event)
        
        allEvent = Event(id: 1, icon: "empty", color: "", counter: 0, type: self.agendaType.AllUpcoming.rawValue, date: "", percentage: 0.0, detail: [], agendaDetail: [])
        
        occasion = Occasion(id: nil, startDate: occasionDateFormatter.string(from: Date()), endDate: occasionDateFormatter.string(from: Date()), title: "", description: "", holiday: false, common: true, batches: [], departments: [], meeting: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.calendarStyle = .week
        delegate?.calendar(calendarType: self.calendarStyle)
    }
    
    /// Description:
    /// - Initially calendar view is weekly view:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            if let calendarView = self.calendarTableView.viewWithTag(4) as? FSCalendar{
                let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
                let monthLabel = self.calendarTableView.viewWithTag(3) as! UILabel
                
                //set month label
                var currentCalendar = Calendar.current
                currentCalendar.locale = Locale(identifier: "\(self.languageId)")
                let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.currentPage)
                let stringMonth = currentCalendar.monthSymbols[values.month! - 1]
                
                if Locale.current.languageCode == "hy" {
                    monthLabel.text = "\(App.getArmenianMonth(month: values.month!)) \(values.year!)"
                }else{
                    monthLabel.text = "\(stringMonth) \(values.year!)"
                }
                        
                if self.calendarStyle == .week{
                    calendarView.setScope(.week, animated: false)
                    calendarHeight?.constant = 90
                }else{
                    calendarView.setScope(.month, animated: false)
                }
                self.reloadTableView()
                self.calendarTableView.isHidden = false
                
                //set date if from notification
                if self.overrideDate != ""{
                    let goToDate = self.ddateFormatter.date(from: self.overrideDate)
                    calendarView.select(goToDate, scrollToDate: true)
                }
                
                //load calendar
                print("getCalendarAPI2")
                self.getCalendarAPI()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    /// Description:
    /// - Used to group and format events dates with their colors and event details in case the calendar view is weekly and monthly.
    // MARK: initialize calendar dates
    func initializeCalendarDates(){
        var datesArray: [CalendarDate] = []
        for event in events{
            for detail in event.detail{
                let date = CalendarDate(date: detail.date, color: event.color)
                datesArray.append(date)
            }
        }
        
        let dateArray = Dictionary(grouping: datesArray, by: { $0.date })
        
        var dic: [String: [UIColor]] = [:]
        self.selectedDate.removeAll()
        for key in dateArray{
            self.selectedDate.append(self.dateFormatter.string(from: self.dateTimeFormatter.date(from: key.key) ?? Date()))
            var colors: [UIColor] = []
            for color in key.value{
                colors.append(App.hexStringToUIColor(hex: color.color, alpha: 1.0))
            }
            dic[self.dateFormatter.string(from: self.dateTimeFormatter.date(from: key.key) ?? Date())] = colors
        }
        fillDefaultColors = dic
        
        if self.currentDate != ""{
            self.eventsArray = []
            for event in self.filteredEvents{
                for detail in event.detail{
                    let indexEndOfText = detail.date.index(detail.date.endIndex, offsetBy: -9)
                    let detailDate = String(detail.date[..<indexEndOfText])
                    
                    let indexEndOfText2 = self.currentDate.index(self.currentDate.endIndex, offsetBy: -9)
                    let currentDate = String(self.currentDate[..<indexEndOfText2])
                    
                    if detailDate == currentDate{
                        self.eventsArray.append(detail)
                    }
                }
            }
            self.eventTitle = self.currentDate
            self.currentDate = ""
        }else{
                self.filteredEvents = []
                self.weekEvents = []
                var weekDetails: [EventDetail] = []
                for event in self.events{
                    for detail in event.detail{
                        weekDetails.append(detail)
                        self.filteredEvents.append(event)
                    }
                }
                self.filteredEvents = Array(Set(self.filteredEvents))

                let dayArray = Dictionary(grouping: weekDetails, by: { $0.date })
                for day in dayArray{
                    let event = Event(id: 0, icon: "", color: "", counter: 0, type: nil, date: day.key, percentage: 0, detail: day.value, agendaDetail: [])
                    self.weekEvents.append(event)
                }
                self.weekEvents = Array(Set(self.weekEvents))
                self.currentDate = ""
                self.filteredEvents = Array(Set(self.filteredEvents))
        }
        self.reloadTableView()
    }
    
    
    /// Description:
    /// - Configure Collapse/Expanse table view cells:
    override func sectionHeaderNibName() -> String? {
        return "ProductHeader"
    }
    
    override func singleOpenSelectionOnly() -> Bool {
        return false
    }
    
    override func collapsableTableView() -> UITableView? {
        return calendarTableView
    }
    
    /// Description:
    /// - Calculate start date and end date.
    /// - Call getCalendar function with needed parameters in each user type case.
    func getCalendarAPI(){
        if SectionVC.didLoadCalendar{
            return
        }

        guard let calendarView = self.calendarTableView.viewWithTag(4) as? FSCalendar else{
            return
        }
        var startDate: Date
        let endDate: Date
        if calendarView.scope == .week {
            startDate = calendarView.currentPage
            startDate = calendarView.gregorian.date(byAdding: .day, value: 0, to: startDate) ?? Date()
            endDate = calendarView.gregorian.date(byAdding: .day, value: 6, to: startDate) ?? Date()
        }else {
            //This will return only Start Date and End Date:
            startDate = calendarView.gregorian.date(byAdding: .day, value: 0, to: calendarView.currentPage) ?? Date()
            endDate = calendarView.gregorian.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) ?? Date()
        }
        
        let fromDate = self.dateFormatter.string(from: startDate)
        let toDate = self.dateFormatter.string(from: endDate)
        
        switch self.user.userType{
        case 1,2:
            if self.batchId != nil && self.batchId != 0{
                print("getCalendar called1")
                self.getCalendar(user: self.user, admissionNo: "", startDate: fromDate, endDate: toDate, batchId: self.batchId, calendarTheme: self.calendarTheme)
            }else{
                self.eventsArray.removeAll()
                self.weekEvents.removeAll()
                self.events.removeAll()
                self.filteredEvents.removeAll()
                
                initializeCalendarDates()
                self.reloadTableView()
            }
        case 3:
            self.teacherEdit = false
            print("getCalendar called2")

            self.getCalendar(user: self.user, admissionNo: "", startDate: fromDate, endDate: toDate, batchId: self.user.classes.first?.batchId ?? 0, calendarTheme: self.calendarTheme)
        case 4:
            self.teacherEdit = false
            print("getCalendar called3")
            self.getCalendar(user: self.user, admissionNo: self.user.admissionNo, startDate: fromDate, endDate: toDate, batchId: self.user.classes.first?.batchId ?? 0, calendarTheme: self.calendarTheme)
        default:
            break
        }
    }
    
    
}


// MARK: - XLPagerTabStrip Method:
// Initialize calendar module.
extension CalendarViewController: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Calendar".localiz(), counter: "", image: UIImage(named: "calendar"),
                             backgroundViewColor: App.hexStringToUIColorCst(hex: "#7cedab", alpha: 1.0), id: App.calendarID)
    }
    
}

extension CalendarViewController: UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField){
        if(textField.tag == 750){
            if(occasionForEdit != nil){
                occasionForEdit.title = textField.text ?? ""
            }
        }
        if(textField.tag == 715){
            if(occasionForEdit != nil){
                occasionForEdit.description = textField.text ?? ""

            }
        }
        
    }

}


// MARK: - TableView Delegate and DataSource:
extension CalendarViewController: SwipeTableViewCellDelegate, UITextViewDelegate{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch user.userType{
        
        case 1,2://teacher
            if teacherEdit{
                return 11
            }else{
                if weekEvents.isEmpty && eventsArray.isEmpty{
                    return 3
                }
//                return 3
                switch calendarStyle{
                case .week?:
                    return self.weekEvents.count + 2
                case .month?:
                    if weekEvents.isEmpty && eventsArray.isEmpty{
                        return 2
                    }
                    return 3
                case .none:
                    if weekEvents.isEmpty && eventsArray.isEmpty{
                        return 2
                    }
                    return 3
                }
            }
        default://student
            switch calendarStyle{
            case .week?:
                return self.weekEvents.count + 2
            case .month?:
                if weekEvents.isEmpty && eventsArray.isEmpty{
                    return 2
                }
                return 3
            case .none:
                if weekEvents.isEmpty && eventsArray.isEmpty{
                    return 2
                }
                return 3
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("section index: \(section)")

        switch user.userType{
        
        case 1,2://teacher
            switch section{
            case 7:
                return 0
            case 0,1,3,4,5,6,10:
                return 1
            case 2:
                if teacherEdit{
                    return 2
                }else{
                    if eventsArray.isEmpty{
                        return 1
                    }else{
                        return eventsArray.count
                    }
                }
            default:
           
                let menuSection = self.model?[section-8]
                
                return (menuSection?.isVisible ?? false) ? menuSection!.items.count : 0
            }
        default://student
            switch section{
            case 0:
                return 1
            case 1:
                return 1
            default:
                if eventsArray.isEmpty{
                    return 1
                }else{
                    return eventsArray.count
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0: //calendar view
            let calendarCell = calendarTableView.dequeueReusableCell(withIdentifier: "calendarReuse")
            let calendarBackButton = calendarCell?.viewWithTag(1) as! UIButton
            let calendarNextButton = calendarCell?.viewWithTag(6) as! UIButton
//            let monthLabel = calendarCell?.viewWithTag(3) as! UILabel
            guard let calendarView: FSCalendar = calendarCell?.viewWithTag(4) as? FSCalendar else{
                return UITableViewCell()
            }
            let bottomShadowView: UIView? = calendarCell?.viewWithTag(7)
            let calendarNextImageView = calendarCell?.viewWithTag(61) as! UIImageView
            let calendarBackImageView = calendarCell?.viewWithTag(99) as! UIImageView
            
            calendarBackButton.dropCircleShadow()
            calendarBackButton.addTarget(self, action: #selector(calendarBackButtonPressed), for: .touchUpInside)
            calendarNextButton.dropCircleShadow()
            calendarNextButton.addTarget(self, action: #selector(calendarNextButtonPressed), for: .touchUpInside)
            if self.languageId.description == "ar"{
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
            calendarView.locale = Locale(identifier: "\(self.languageId)")
            calendarView.calendarHeaderView.calendar.locale = Locale(identifier: "\(self.languageId)")
            calendarView.register(DIYCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
            calendarView.reloadData()
            
            bottomShadowView?.dropTopShadow()
            calendarCell?.selectionStyle = .none
            return calendarCell!
        case 1: //events count view and add button
            let eventsCell = calendarTableView.dequeueReusableCell(withIdentifier: "eventsReuse")
            let monthLabel = eventsCell?.viewWithTag(11) as! UILabel
            let addImageView = eventsCell?.viewWithTag(600) as! UIImageView
            let xImageView = eventsCell?.viewWithTag(6001) as! UIImageView
            let addLabel = eventsCell?.viewWithTag(601) as! UILabel
            let addButton = eventsCell?.viewWithTag(602) as! UIButton
            addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
            addLabel.text = "Add".localiz()
            addImageView.isHidden = true
            addLabel.isHidden = true
            addButton.isHidden = true
            xImageView.isHidden = true
            
            switch user.userType{
            case 1:
                //check if user has eventmanagementprivilege so he/she can add or edit an event, otherwise hide the add button
                if user.privileges.contains(App.eventManagmentPrivilege){
                    
                    
                    if teacherEdit{
                        addLabel.text = "Cancel".localiz()
                        addImageView.image = UIImage(named: "cancel")
                        xImageView.isHidden = false
                    }else{
                        addLabel.text = "Add".localiz()
                        addImageView.image = UIImage(named: "add-school")
                        xImageView.isHidden = true
                    }
                }else{
                    addImageView.isHidden = true
                    addLabel.isHidden = true
                    addButton.isHidden = true
                    xImageView.isHidden = true
                }
            default:
                addImageView.isHidden = true
                addLabel.isHidden = true
                addButton.isHidden = true
                xImageView.isHidden = true
            }
            
            // Get Calendar Month
            guard let calendarView = calendarTableView.viewWithTag(4) as? FSCalendar else{
                return UITableViewCell()
            }
            var currentCalendar = Calendar.current
            currentCalendar.locale = Locale(identifier: "\(self.languageId)")
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
            let eventsCollectionView: UICollectionView = eventsCell?.viewWithTag(12) as! UICollectionView
            eventsCollectionView.delegate = self
            eventsCollectionView.dataSource = self
            eventsCollectionView.reloadData()
            eventsCell?.selectionStyle = .none
            return eventsCell!
        default:
            switch user.userType{
            
            case 1,2://teacher
                //MARK: EDITS HERE
                if self.teacherEdit{
                    switch indexPath.section{
                    case 2:
                        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "startEndReuse")
                        let startEndLabel = cell?.viewWithTag(700) as! UILabel
                        let eventDateLabel = cell?.viewWithTag(701) as! UILabel
                        let eventDateButton = cell?.viewWithTag(702) as! UIButton
                        let eventTimeLabel = cell?.viewWithTag(703) as! UILabel
                        let eventTimeButton = cell?.viewWithTag(704) as! UIButton
                        let holidayDateLabel = cell?.viewWithTag(2500) as! UILabel
                        let holidayDateButton = cell?.viewWithTag(2501) as! UIButton
                        
                        holidayDateLabel.isHidden = true
                        holidayDateButton.isHidden = true
                        eventDateLabel.isHidden = false
                        eventDateButton.isHidden = false
                        eventTimeLabel.isHidden = false
                        eventTimeButton.isHidden = false
                        eventDateButton.addTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
                        eventTimeButton.addTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
                        switch indexPath.row{
                        case 0://start date cell
                            startEndLabel.text = "Starts".localiz()
                            //set date
                            if isCalendarEditing {//if in edit mode use date from object
                                if editType != self.agendaType.Holidays.rawValue{
                                    if self.eventStartDate != nil {
                                        let startdate = self.pickerDateResultFormatter.string(from: self.eventStartDate!)
                                        eventDateLabel.text = startdate
                                        
                                        self.occasion.startDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: startdate) ?? Date())
                                    }else{
                                        let startdate = self.pickerDateResultFormatter.string(from: self.dateTimeFormatter.date(from: self.occasionForEdit.date) ?? Date())
                                        eventDateLabel.text = startdate
                                        
                                        self.occasion.startDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: startdate) ?? Date())
                                    }
                                }else{
                                    if self.holidayStartDate != nil {
                                        let startdate = self.pickerDateResultFormatter.string(from: self.holidayStartDate!)
                                        holidayDateLabel.text = startdate
                                    
                                        self.occasion.startDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: startdate) ?? Date())
                                    }else{
                                        let startdate = self.pickerDateResultFormatter.string(from: self.dateTimeFormatter.date(from: self.occasionForEdit.date) ?? Date())
                                        holidayDateLabel.text = startdate
                                        
                                        self.occasion.startDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: startdate) ?? Date())
                                    }
                                }
                            }else {//Add mode
                                if editType != self.agendaType.Holidays.rawValue{//if date is selected and type is event
                                    if self.eventStartDate != nil {
                                        let startdate = self.pickerDateResultFormatter.string(from: self.eventStartDate!)
                                        eventDateLabel.text = startdate
                                        
                                        self.occasion.startDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: startdate) ?? Date())
                                    }else{
                                        let startdate = self.pickerDateResultFormatter.string(from: selectedCalendarDate)
                                        eventDateLabel.text = startdate
                                        holidayDateLabel.text = startdate
                                        
                                        self.occasion.startDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: startdate) ?? Date())
                                    }
                                } else {//if date is selected and type is holiday
                                    if self.holidayStartDate != nil {
                                        let startdate = self.pickerDateResultFormatter.string(from: self.holidayStartDate!)
                                        holidayDateLabel.text = startdate
                                    
                                        self.occasion.startDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: startdate) ?? Date())
                                    } else{
                                        let startdate = self.pickerDateResultFormatter.string(from: selectedCalendarDate)
                                        eventDateLabel.text = startdate
                                        holidayDateLabel.text = startdate
                                        
                                        self.occasion.startDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: startdate) ?? Date())
                                    }
                                }
                            }
                            
                            //set time for events only
                            if editType != self.agendaType.Holidays.rawValue{//holiday
                                if isCalendarEditing {
                                    let editdate = self.dateTimeFormatter.date(from: self.occasionForEdit.date)
                                    let starttime = self.pickerTimeResultFormatter.string(from: editdate ?? Date())
                                    eventTimeLabel.text = starttime
                                    self.occasion.startDate.append(" " + self.timeFormatter.string(from: editdate ?? Date()))
                                }else if self.eventStartTime != nil{
                                    eventTimeLabel.text = self.pickerTimeResultFormatter.string(from: self.eventStartTime!)
                                    self.occasion.startDate.append(" " + self.pickerTimeResultFormatter.string(from: self.eventStartTime!))
                                } else {
                                    eventTimeLabel.text = self.pickerTimeResultFormatter.string(from: self.selectedCalendarDate)
                                    self.occasion.startDate.append(" " + self.timeFormatter.string(from: self.selectedCalendarDate))
                                }
                            }
                        default://end date cell
                            startEndLabel.text = "Ends".localiz()
                            //set date
                            if isCalendarEditing {//if in edit mode use date from object
                                if editType != self.agendaType.Holidays.rawValue{
                                    if self.eventEndDate != nil {
                                        let enddate = self.pickerDateResultFormatter.string(from: self.eventEndDate!)
                                        eventDateLabel.text = enddate
                                        
                                        self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
                                    }else{
                                        let enddate = self.pickerDateResultFormatter.string(from: self.dateTimeFormatter.date(from: self.occasionForEdit.enddate) ?? Date())
                                        eventDateLabel.text = enddate
                                        
                                        self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
                                    }
                                }else{
                                    if self.holidayEndDate != nil {
                                        let enddate = self.pickerDateResultFormatter.string(from: self.holidayEndDate!)
                                        holidayDateLabel.text = enddate
                                    
                                        self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
                                    }else{
                                        let enddate = self.pickerDateResultFormatter.string(from: self.dateTimeFormatter.date(from: self.occasionForEdit.enddate) ?? Date())
                                        holidayDateLabel.text = enddate
                                        
                                        self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
                                    }
                                }
                            }else {//Add mode
                                if editType != self.agendaType.Holidays.rawValue{//if date is selected and type is event
                                    if self.eventEndDate != nil {
                                        let enddate = self.pickerDateResultFormatter.string(from: self.eventEndDate!)
                                        eventDateLabel.text = enddate
                                        
                                        self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
                                    }else{
                                        let enddate = self.pickerDateResultFormatter.string(from: selectedCalendarDate)
                                        eventDateLabel.text = enddate
                                        holidayDateLabel.text = enddate
                                        
                                        self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
                                    }
                                } else {//if date is selected and type is holiday
                                    if self.holidayEndDate != nil {
                                        let enddate = self.pickerDateResultFormatter.string(from: self.holidayEndDate!)
                                        holidayDateLabel.text = enddate
                                    
                                        self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
                                    } else{
                                        let enddate = self.pickerDateResultFormatter.string(from: selectedCalendarDate)
                                        eventDateLabel.text = enddate
                                        holidayDateLabel.text = enddate
                                        
                                        self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
                                    }
                                }
                            }
                            
                            //set time for events only
                            if editType != self.agendaType.Holidays.rawValue{//holiday
                                if isCalendarEditing {
                                    let editdate = self.dateTimeFormatter.date(from: self.occasionForEdit.enddate)
                                    let endtime = self.pickerTimeResultFormatter.string(from: editdate ?? Date())
                                    eventTimeLabel.text = endtime
                                    self.occasion.endDate.append(" " + self.timeFormatter.string(from: editdate ?? Date()))
                                } else if self.eventEndTime != nil {
                                    eventTimeLabel.text = self.pickerTimeResultFormatter.string(from: self.eventEndTime!)
                                    self.occasion.endDate.append(" " + self.pickerTimeResultFormatter.string(from: self.eventEndTime!))
                                } else {
                                    eventTimeLabel.text = self.pickerTimeResultFormatter.string(from: self.selectedCalendarDate)
                                    self.occasion.endDate.append(" " + self.timeFormatter.string(from: self.selectedCalendarDate))
                                }
                            }
                            
//                            if editType == self.agendaType.Holidays.rawValue{//holiday
//                                //set end date if holiday
//                                //holiday doesn't need time specification
//                                if self.holidayEndDate != nil {
//                                    let enddate = self.pickerDateResultFormatter.string(from: self.holidayEndDate!)
//                                    holidayDateLabel.text = enddate
//                                    self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date()) + " 00:00"
//                                } else {
//                                    let enddate = self.pickerDateResultFormatter.string(from: self.selectedCalendarDate)
//                                    holidayDateLabel.text = enddate
//                                    self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date()) + " 00:00"
//                                }
//                            } else {//event
//                                //set end date if event
//                                if self.eventEndDate != nil {
//                                    let enddate = self.pickerDateResultFormatter.string(from: self.eventEndDate!)
//                                    eventDateLabel.text = enddate
//                                    self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
//                                } else {
//                                    let enddate = self.pickerDateResultFormatter.string(from: self.selectedCalendarDate)
//                                    eventDateLabel.text = enddate
//                                    self.occasion.endDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: enddate) ?? Date())
//                                }
//                                //set end time if event
//                                if isCalendarEditing {
//                                    if self.eventEndTime != nil{
//                                        let endtime = self.pickerTimeResultFormatter.string(from: self.eventEndTime!)
//                                        eventTimeLabel.text = endtime
//                                        self.occasion.endDate.append(" " + self.pickerTimeResultFormatter.string(from: self.eventEndTime!))
//                                    } else {
//                                        let editdate = self.dateTimeFormatter.date(from: self.occasionForEdit.enddate)
//                                        let endtime = self.pickerTimeResultFormatter.string(from: editdate ?? Date())
//                                        eventTimeLabel.text = endtime
//                                        self.occasion.endDate.append(" " + self.timeFormatter.string(from: editdate ?? Date()))
//                                    }
//                                }else{
//                                    if self.eventEndTime != nil{
//                                        let endtime = self.pickerTimeResultFormatter.string(from: self.eventEndTime!)
//                                        eventTimeLabel.text = endtime
//                                        self.occasion.endDate.append(" " + self.pickerTimeResultFormatter.string(from: self.eventEndTime!))
//                                    } else {
//                                        let endtime = self.pickerTimeResultFormatter.string(from: self.selectedCalendarDate)
//                                        eventTimeLabel.text = endtime
//                                        self.occasion.endDate.append(" " + self.timeFormatter.string(from: self.selectedCalendarDate))
//                                    }
//                                }
//                            }
                        }
                        if editType == self.agendaType.Holidays.rawValue{
                            eventDateLabel.isHidden = true
                            eventDateButton.isHidden = true
                            eventTimeLabel.isHidden = true
                            eventTimeButton.isHidden = true
                            holidayDateLabel.isHidden = false
                            holidayDateButton.isHidden = false
                            holidayDateButton.addTarget(self, action: #selector(holidayDatePressed), for: .touchUpInside)
                        }
                        cell?.selectionStyle = .none
                        return cell!
                    case 3: //event title textfield
                        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "eventTitleReuse")
                        let textview = cell?.viewWithTag(750) as! UITextField
                        textview.text = ""
                        textview.delegate = self
                        textview.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
                        
                        cell?.selectionStyle = .none
                        if isCalendarEditing {
                            textview.text = occasionForEdit.title
                        } else {
                            textview.text = self.textTitle
                        }
                        return cell!
                    case 4: //write about event textfield
                        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "writeEventReuse")
                        let textview = cell?.viewWithTag(715) as! UITextView
                        textview.text = ""
                        textview.delegate = self
                        cell?.selectionStyle = .none
                        if isCalendarEditing {
                            textview.text = occasionForEdit.description
                        } else {
                            textview.text = self.textSubject
                        }
                        return cell!
                    case 5: //upload picture box
                        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "pictureReuse")
                        let uploadLabel = cell?.viewWithTag(720) as! UILabel
                        let imageView = cell?.viewWithTag(721) as! UIImageView
                        let imageButton = cell?.viewWithTag(722) as! UIButton
                        if isCalendarEditing {
                            if self.isSelectedImage == true{
                                imageView.image = selectedImage
                            }else{
                                var icon = occasionForEdit.image.unescaped
                              
                                print("image escaped: \(icon)")

                                imageView.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "add-picture"))
                            }
                        } else {
                            if self.isSelectedImage == true{
                                imageView.image = selectedImage
                            }else{
                                imageView.image = UIImage(named: "add-picture")
                            }
                        }
                        uploadLabel.text = "Upload a picture".localiz()
                        imageButton.addTarget(self, action: #selector(uploadImageButtonPressed), for: .touchUpInside)
                        cell?.selectionStyle = .none
                        return cell!
                    case 6:
                        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "schoolReuse")
                        let schoolLabel = cell?.viewWithTag(730) as! UILabel
                        let schoolSwitch = cell?.viewWithTag(731) as! PWSwitch
                        
                        if isCalendarEditing{
                            var batches = self.occasionForEdit.batches
                            batches = String(batches.dropFirst())
                            batches = String(batches.dropLast())
                            var departments = self.occasionForEdit.departments
                            departments = String(departments.dropFirst())
                            departments = String(departments.dropLast())
                            let arrayBatches = batches.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
                            let arrayDepartments = departments.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
                            
                            if batches != "" || departments != "" {
                                schoolSwitch.setOn(isSchoolSwitch, animated: true)
                                
                                for object in teacherSectionArray{
                                    if arrayBatches.contains(object.id){
                                        if let row = self.teacherSectionArray.firstIndex(where: {$0.id == object.id}) {
                                            self.teacherSectionArray[row].active = true
                                        }
                                    }else{
                                        if let row = self.teacherSectionArray.firstIndex(where: {$0.id == object.id}) {
                                            self.teacherSectionArray[row].active = false
                                        }
                                    }
                                }

                                for object in teacherDepartmentArray{
                                    if arrayDepartments.contains(object.id){
                                        if let row = self.teacherDepartmentArray.firstIndex(where: {$0.id == object.id}) {
                                            self.teacherDepartmentArray[row].active = true
                                        }
                                    }else{
                                        if let row = self.teacherDepartmentArray.firstIndex(where: {$0.id == object.id}) {
                                            self.teacherDepartmentArray[row].active = false
                                        }
                                    }
                                }
                                
                                let sectionVisible0 = self.model?[0].isVisible ?? false
                                let sectionVisible1 = self.model?[1].isVisible ?? false
                                self.model = [
                                    ItemsHeader(isVisible: sectionVisible0, items: self.teacherDepartmentArray, title: "Departments".localiz()),
                                    ItemsHeader(isVisible: sectionVisible1, items: self.teacherSectionArray, title: "Classes".localiz()),
                                ]
                            }else{
                                schoolSwitch.setOn(isSchoolSwitch, animated: true)
                                
                                //reset the active status to false here
                                for object in teacherSectionArray{
                                    if let row = self.teacherSectionArray.firstIndex(where: {$0.id == object.id}) {
                                        self.teacherSectionArray[row].active = false
                                    }
                                }
                                
                                for object in teacherDepartmentArray{
                                    if let row = self.teacherDepartmentArray.firstIndex(where: {$0.id == object.id}) {
                                        self.teacherDepartmentArray[row].active = false
                                    }
                                }
                                
                                let sectionVisible0 = self.model?[0].isVisible ?? false
                                let sectionVisible1 = self.model?[1].isVisible ?? false
                                self.model = [
                                    ItemsHeader(isVisible: sectionVisible0, items: self.teacherDepartmentArray, title: "Departments".localiz()),
                                    ItemsHeader(isVisible: sectionVisible1, items: self.teacherSectionArray, title: "Classes".localiz()),
                                ]
                            }
                        }else{
                            schoolSwitch.setOn(isSchoolSwitch, animated: true)
                            
                            let sectionVisible0 = self.model?[0].isVisible ?? false
                            let sectionVisible1 = self.model?[1].isVisible ?? false
                            self.model = [
                                ItemsHeader(isVisible: sectionVisible0, items: self.teacherDepartmentArray, title: "Departments".localiz()),
                                ItemsHeader(isVisible: sectionVisible1, items: self.teacherSectionArray, title: "Classes".localiz()),
                            ]
                        }
                        
                        schoolLabel.text = "School".localiz()
                        schoolSwitch.addTarget(self, action: #selector(schoolSwitchPressed), for: .touchUpInside)
                        cell?.selectionStyle = .none
                        return cell!
                    case 7: //write about event textfield
                        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "writeEventReuse")
                      
                        return cell!
                    case 8:
                        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "departmentReuse")
                        let titleLabel = cell?.viewWithTag(740) as! UILabel
                        let switchView = cell?.viewWithTag(741) as! PWSwitch
                        
                        switchView.addTarget(self, action: #selector(departmentSwitchPressed), for: .touchUpInside)
                        let department = model![indexPath.section - 8].items[indexPath.row]
                        titleLabel.text = department.title
                        switchView.setOn(department.active, animated: true)

                        if isSchoolSwitch{
                            switchView.isEnabled = false
                        }else{
                            switchView.isEnabled = true
                        }
                        cell?.selectionStyle = .none
                        return cell!
                    case 9:
                        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "departmentReuse")
                        let titleLabel = cell?.viewWithTag(740) as! UILabel
                        let switchView = cell?.viewWithTag(741) as! PWSwitch
                        
                        switchView.addTarget(self, action: #selector(classSwitchPressed), for: .touchUpInside)
                        
                        let department = model![indexPath.section - 8].items[indexPath.row]
                        titleLabel.text = department.title
                        switchView.setOn(department.active, animated: true)
                        if isSchoolSwitch{
                            switchView.isEnabled = false
                        }else{
                            switchView.isEnabled = true
                        }
                        cell?.selectionStyle = .none
                        return cell!
                    default:
                        let cell = calendarTableView.dequeueReusableCell(withIdentifier: "saveReuse")
                        let saveButton = cell?.viewWithTag(745) as! UIButton
                        saveButton.layer.cornerRadius = saveButton.frame.height / 2
                        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
                        cell?.selectionStyle = .none
                        return cell!
                    }
                }else{
                    let eventDetailCell = calendarTableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse") as! CalendarTableViewCell
//                    let backgroundView: UIView? = eventDetailCell?.viewWithTag(40)
                    
                    if !eventsArray.isEmpty{
                        let events = eventsArray[indexPath.row]
                        eventDetailCell.cellBackgroundView?.backgroundColor = App.hexStringToUIColor(hex: events.backgroudColor, alpha: 0.5)
                        eventDetailCell.topView?.backgroundColor = App.hexStringToUIColor(hex: events.topColor, alpha: 1.0)
                        eventDetailCell.titleLabel.text = events.title
                        let date = self.dateTimeFormatter.date(from: events.date)
                        var dateString = ""
                        if events.topColor != calendarTheme.eventBg{
                            dateString = self.dateFormatter1Locale.string(from: date ?? Date())
                        }else{
                            dateString = self.dateTimeFormatterLocale.string(from: date ?? Date())
                        }
                        eventDetailCell.dateLabel.text = dateString
                        if self.languageId.description == "ar"{
                            eventDetailCell.dateLabel.textAlignment = .left
                        }
                        
                        if events.topColor == self.calendarTheme.eventBg{
                            let icon = events.image.unescaped
                            if icon == ""{
                                if self.calendarTheme.defaultEventIcon.contains("http"){
                                    let url = URL(string: self.calendarTheme.defaultEventIcon)
                                    App.addImageLoader(imageView: eventDetailCell.holidayIcon, button: nil)
                                    eventDetailCell.holidayIcon.sd_setImage(with: url) { (image, error, cache, url) in
                                        App.removeImageLoader(imageView: eventDetailCell.holidayIcon, button: nil)
                                    }
                                }else{
                                    eventDetailCell.holidayIcon.image = UIImage(named: "whiteEvent")
                                }
                            }else{
                                var icon = events.image.unescaped
                                
                                eventDetailCell.holidayIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "whiteEvent"))
                            }
                        }else{
                            let icon = events.image.unescaped
                            if icon == ""{
                                if self.calendarTheme.defaultHolidayIcon.contains("http"){
                                    let url = URL(string: self.calendarTheme.defaultHolidayIcon)
                                    App.addImageLoader(imageView: eventDetailCell.holidayIcon, button: nil)
                                    eventDetailCell.holidayIcon.sd_setImage(with: url) { (image, error, cache, url) in
                                        App.removeImageLoader(imageView: eventDetailCell.holidayIcon, button: nil)
                                    }
                                }else{
                                    eventDetailCell.holidayIcon.image = UIImage(named: "holiday-default")
                                }
                            }else{
                                var icon = events.image.unescaped
                             
                                eventDetailCell.holidayIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "holiday-default"))
//                                eventDetailCell.holidayIcon.image = icon
                            }
                        }
                        
//                        let descriptionLabel: UILabel = eventDetailCell?.viewWithTag(45) as! UILabel
                        eventDetailCell.descriptionLabel.text = events.description
                        eventDetailCell.selectionStyle = .none
                        eventDetailCell.delegate = self
                        return eventDetailCell
                    } else {
                        let cell = UITableViewCell()
                        cell.textLabel?.text = "No Events for selected criteria".localiz()
                        cell.textLabel?.textAlignment = .center
                        cell.selectionStyle = .none
                        return cell
                    }
                }
            default:
                if !eventsArray.isEmpty{
                    let eventDetailCell = calendarTableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse") as! CalendarTableViewCell
                    let events = eventsArray[indexPath.row]
                    
                    eventDetailCell.cellBackgroundView?.backgroundColor = App.hexStringToUIColor(hex: events.backgroudColor, alpha: 0.5)
                    eventDetailCell.topView?.backgroundColor = App.hexStringToUIColor(hex: events.topColor, alpha: 1.0)
                    eventDetailCell.titleLabel.text = events.title
                    eventDetailCell.descriptionLabel.text = events.description
                    let date = self.dateTimeFormatter.date(from: events.date)
                    var dateString = ""
                    if events.topColor != calendarTheme.eventBg{
                        dateString = self.dateFormatter1Locale.string(from: date ?? Date())
                    }else{
                        dateString = self.dateTimeFormatterLocale.string(from: date ?? Date())
                    }
                    eventDetailCell.dateLabel.text = dateString
                    if events.topColor == self.calendarTheme.eventBg{
                        let icon = App.eventBase64Convert(base64String: events.image.unescaped)
                        if icon == UIImage(named: "whiteEvent"){
                            if self.calendarTheme.defaultEventIcon.contains("http"){
                                let url = URL(string: self.calendarTheme.defaultEventIcon)
                                App.addImageLoader(imageView: eventDetailCell.holidayIcon, button: nil)
                                eventDetailCell.holidayIcon.sd_setImage(with: url) { (image, error, cache, url) in
                                    App.removeImageLoader(imageView: eventDetailCell.holidayIcon, button: nil)
                                }
                            } else {
                                eventDetailCell.holidayIcon.image = icon
                            }
                        } else {
                            eventDetailCell.holidayIcon.image = icon
                        }
                    } else {
                        let icon = App.holidayBase64Convert(base64String: events.image.unescaped)
                        if icon == UIImage(named: "holiday-default"){
                            if self.calendarTheme.defaultHolidayIcon.contains("http"){
                                let url = URL(string: self.calendarTheme.defaultHolidayIcon)
                                App.addImageLoader(imageView: eventDetailCell.holidayIcon, button: nil)
                                eventDetailCell.holidayIcon.sd_setImage(with: url) { (image, error, cache, url) in
                                    App.removeImageLoader(imageView: eventDetailCell.holidayIcon, button: nil)
                                }
                            } else {
                                eventDetailCell.holidayIcon.image = icon
                            }
                        } else {
                            eventDetailCell.holidayIcon.image = icon
                        }
                    }
                    
                    eventDetailCell.selectionStyle = .none
                    eventDetailCell.delegate = self
                    return eventDetailCell
                }else{
                    let cell = UITableViewCell()
                    cell.textLabel?.text = "No Events for selected criteria".localiz()
                    cell.textLabel?.textAlignment = .center
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        self.textSubject = textView.text ?? ""
        
        if(textView.tag == 715){
            if(occasionForEdit != nil){
                occasionForEdit.description = textView.text ?? ""
            }
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        self.textTitle = textField.text ?? ""
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.user.userType{
      
        case 1,2:
            let header = calendarTableView.dequeueReusableCell(withIdentifier: "teacherHeaderReuse")
            let titleLabel = header?.viewWithTag(710) as! UILabel
            switch section{
            case 2:
                if teacherEdit{
                    return UIView()
                }else{
                    let header = calendarTableView.dequeueReusableCell(withIdentifier: "headerReuse")
                    let headerTitle = header?.viewWithTag(30) as! UILabel
                    if calendarStyle == .week{
                        if !weekEvents.isEmpty{
                            let date = self.dateTimeFormatter.date(from: self.eventTitle)
                            if date != nil{
                                //date locale
                                let title = self.dateFormatter1Locale.string(from: date ?? Date())
                                headerTitle.text = title
                            }else{
                                headerTitle.text = self.eventTitle
                            }
                        }
                    }else{
                        let date = self.dateTimeFormatter.date(from: self.eventTitle)
                        if date != nil{
                            //date locale
                            let title = self.dateFormatter1Locale.string(from: date ?? Date())
                            headerTitle.text = title
                        }else{
                            headerTitle.text = self.eventTitle
                        }
                    }
                    header?.contentView.backgroundColor = .white
                    return header?.contentView
                }
            case 3:
                titleLabel.text = "Event title".localiz()
            case 4:
                titleLabel.text = "Write about the event".localiz()
            case 8,9:
                
                // Init Collapse/Expand sections:
                var view: CollapsableSectionHeaderProtocol?
                if let reuseID = self.sectionHeaderReuseIdentifier() {
                    view = Bundle.main.loadNibNamed(reuseID, owner: nil, options: nil)!.first as? CollapsableSectionHeaderProtocol
                }
                view?.tag = section
                view?.interactionDelegate = self
                
                let menuSection = self.model?[section-8]
                view?.sectionTitleLabel.text = (menuSection?.title ?? "").capitalized
                view?.close(true)
                view?.containerView.backgroundColor = .white
                return view as? UIView
            default:
                return UIView()
            }
            header?.contentView.backgroundColor = .white
            return header?.contentView
        default:
            let header = calendarTableView.dequeueReusableCell(withIdentifier: "headerReuse")
            let headerTitle = header?.viewWithTag(30) as! UILabel
            switch section{
            case 0,1:
                return UIView()
            default:
                let date = self.dateTimeFormatter.date(from: self.eventTitle)
                if date != nil{
                    //date locale
                    let title = self.dateFormatter1Locale.string(from: date ?? Date())
                    headerTitle.text = title
                }else{
                    headerTitle.text = self.eventTitle
                }
            }
            header?.contentView.backgroundColor = .white
            return header?.contentView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch user.userType{
        
        case 1,2:
            switch section{
            case 0,1,5,6:
                return 0.01
            case 2:
                if teacherEdit{
                    return 0.01
                }
                return 44
            default:
                return 44
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 7){
            return 0
        }
        else{
            return UITableView.automaticDimension

        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
        case 0:
            return 250
        default:
            return 100
        }
    }
    
    
    /// Description:
    /// - SwipeCellKit configuration inside tableview edit actions function.
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
            let event = self.eventsArray[indexPath.row]
            self.deleteOccasion(user: self.user, occasionId: event.id)
        }
        deleteAction.image = UIImage(named: "delete-x")!.scaleImage(scaledToSize: CGSize(width: 44, height: 44))
        deleteAction.backgroundColor = .white
        
        let edit = SwipeAction(style: .destructive, title: "") { action, indexPath in
            self.editButtonPressed(index: indexPath.row)
        }
        edit.image = UIImage(named: "editbutton")!.scaleImage(scaledToSize: CGSize(width: 44, height: 44))
        edit.backgroundColor = .white
        
        //self.eventsArray[indexPath.row].allow_update == true
//        if (self.user.userType == 2 || self.user.userType == 1) && !(self.eventsArray[indexPath.row].type == self.agendaType.Dues.rawValue) && self.eventsArray[indexPath.row].allow_update == true{
//            return [deleteAction, edit]
//        }else{
//            return nil
//        }
        
//        if (self.user.userType == 2 || self.user.userType == 1) && self.eventsArray[indexPath.row].allow_update == true{
//            return [deleteAction, edit]
//        }else{
            return nil
//        }
    }
    
    //TODO: DISABLE THESE BUTTONS WHILE THE API IS LOADING TO AVOID MULTIPLE CALLS
    /// Description
    /// - Show previous month/week dates inside FSCalendar.
    @objc func calendarBackButtonPressed(sender: UIButton){
        guard let calendarView = calendarTableView.viewWithTag(4) as? FSCalendar else{
            return
        }
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        if calendarView.scope == .month{
            dateComponents.month = -1 // For prev button
        }else{
            dateComponents.weekOfMonth = -1
        }
        let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage)
        calendarView.setCurrentPage(currentCalendarPage!, animated: true)
    }
    
    /// Description
    /// - Show next month/week dates inside FSCalendar.
    @objc func calendarNextButtonPressed(sender: UIButton){
        guard let calendarView = calendarTableView.viewWithTag(4) as? FSCalendar else{
            return
        }
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        if calendarView.scope == .month{
            dateComponents.month = 1
        }else{
            dateComponents.weekOfMonth = 1
        }
        let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage)
        calendarView.setCurrentPage(currentCalendarPage!, animated: true)
    }
    
    @IBAction func addButtonPressed(sender:UIButton) {
        if selectCalendarDate.isEmpty && !isCalendarEditing && !teacherEdit{
            App.showMessageAlert(self, title: "", message: "You need to select a day from the calendar".localiz(), dismissAfter: 1.5)
        }else{
            if(teacherEdit){ //was in edit mode
                teacherEdit = false //close edit mode
                //reset the active status to false here
                self.resetSavedData()
            } else {
                teacherEdit = true //start add mode
                SectionVC.canChange = false
            }
            
            if(isCalendarEditing){
                self.isSchoolSwitch = true
                self.isCalendarEditing = false
            }
            self.initializeCalendarDates()
            self.calendarTableView.reloadData()
        }
    }
    
    func editButtonPressed(index: Int) {
        self.occasionForEdit = eventsArray[index]
        //set the edit type
        self.editType = self.occasionForEdit.type
        
        teacherEdit = !teacherEdit
        
        //check if departments or batches array are custom
        var batches = eventsArray[index].batches
        batches = String(batches.dropFirst())
        batches = String(batches.dropLast())
        var departments = eventsArray[index].departments
        departments = String(departments.dropFirst())
        departments = String(departments.dropLast())
        
        if batches != "" || departments != "" {
            self.isSchoolSwitch = false
        }else{
            self.isSchoolSwitch = true
        }
        
        self.isCalendarEditing = true
        self.initializeCalendarDates()
        self.calendarTableView.reloadData()
    }
    
    /// Description:
    /// - The functions below are used in case the user is an Employee:
    @objc func saveButtonPressed(sender: UIButton){
//        sender.isEnabled = false
        let eventTitleTextField = calendarTableView.viewWithTag(750) as! UITextField
        let eventTextView = calendarTableView.viewWithTag(715) as! UITextView
        let eventImage = calendarTableView.viewWithTag(721) as! UIImageView
        let schoolSwitch = calendarTableView.viewWithTag(731) as! PWSwitch
        
        if eventTitleTextField.text!.isEmpty || eventTextView.text.isEmpty{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Error".localiz(), message: "Add title and description".localiz(), actions: [ok], controller: nil, isCancellable: true)
        }else{
            self.occasion.title = eventTitleTextField.text!
            self.occasion.description = eventTextView.text!
            print("edit type: \(self.editType)")
            if self.editType == self.agendaType.Holidays.rawValue{
                self.occasion.holiday = true
            }else{
                self.occasion.holiday = false
            }
            
            if self.editType == self.agendaType.Dues.rawValue{
                self.occasion.meeting = true
            }else{
                self.occasion.meeting = false
            }
            
            
            
            //check which departments included
            if schoolSwitch.on{
                self.occasion.common = true
            }else{
                
                print("departments list: \(model![0].items)")
                print("sections list: \(model![1].items)")

                self.occasion.common = false
//                var sectionsArray: [String] = []
//                var departmentsArray: [String] = []
//                //TODO check if switching these is correct
//                let filteredDepartment = model![0].items.filter({$0.active == true})
//                let filteredSections = model![1].items.filter({$0.active == true})
//
//                for section in filteredSections{
//                    sectionsArray.append(section.id)
//                }
//                self.occasion.batches = sectionsArray
//                for department in filteredDepartment{
//                    departmentsArray.append(department.id)
//                }
//                self.occasion.departments = departmentsArray
                
                let idStringsEmployees = self.employeesByDepartmentArray.map { String($0.id) }
//                let idStringsEmployee = idStringsEmployees.joined(separator: ", ")
                self.occasion.departments = idStringsEmployees

                
                let idStringsStudents = self.StudentsBySectionArray.map { String($0.id) }
//                let idStringsStudent = idStringsStudents.joined(separator: ", ")
                self.occasion.batches = idStringsStudents
            }
                        
            //check if add or edit event
            if isCalendarEditing {//edit event
                //add the id to occasion
                self.occasion.id = self.occasionForEdit.id
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm"
                
                let dateStart = (df.date(from: self.occasion.startDate) ?? Date()).toLocalTime()
                let dateEnd = (df.date(from: self.occasion.endDate) ?? Date()).toLocalTime()

                print(self.occasion)
                print(dateEnd)
                print(dateStart)
                
                let currentDateString = df.string(from: Date())
                let currentDateIn = (df.date(from: currentDateString) ?? Date()).toLocalTime()
                
               
                    
                if dateStart < currentDateIn {
                    App.showMessageAlert(self, title: "", message: "You can't select a past date".localiz(), dismissAfter: 1.5)
                }
                else if dateEnd < dateStart {
                    App.showMessageAlert(self, title: "", message: "Start Date must be before End Date".localiz(), dismissAfter: 1.5)
                }
                else{
                    if !self.isSelectedImage{
                        self.editEvent(user: self.user, image: UIImage(), occasion: self.occasion)
                    }else{
                        self.editEvent(user: self.user, image: eventImage.image!, occasion: self.occasion)
                    }
                }
               
            } else{//add event
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm"
                
                let dateStart = (df.date(from: self.occasion.startDate) ?? Date()).toLocalTime()
                let dateEnd = (df.date(from: self.occasion.endDate) ?? Date()).toLocalTime()

                print(self.occasion)
                print(dateEnd)
                print(dateStart)
                
                let currentDateString = df.string(from: Date())
                let currentDateIn = (df.date(from: currentDateString) ?? Date()).toLocalTime()
                
               
                    
                if dateStart < currentDateIn {
                    App.showMessageAlert(self, title: "", message: "You can't select a past date".localiz(), dismissAfter: 1.5)
                }
                else if dateEnd < dateStart {
                    App.showMessageAlert(self, title: "", message: "Start Date must be before End Date".localiz(), dismissAfter: 1.5)
                }
                else{
                    if !self.isSelectedImage{
                        self.saveEvent(user: self.user, image: UIImage(), occasion: self.occasion)
                    }else{
                        self.saveEvent(user: self.user, image: eventImage.image!, occasion: self.occasion)
                    }
                }
                

            }
        }
    }
    
    func resetSavedData(){
        //remove stored data
        self.occasionForEdit = nil
        self.eventStartDate = nil
        self.eventEndDate = nil
        self.holidayStartDate = nil
        self.holidayEndDate = nil
        self.eventStartTime = nil
        self.eventEndTime = nil
        self.textTitle = ""
        self.textSubject = ""
        self.isSelectedImage = false
        SectionVC.canChange = true
        self.isSchoolSwitch = true
        
        //reset the active status to false here
        for object in teacherSectionArray{
            if let row = self.teacherSectionArray.firstIndex(where: {$0.id == object.id}) {
                self.teacherSectionArray[row].active = false
            }
        }
        
        for object in teacherDepartmentArray{
            if let row = self.teacherDepartmentArray.firstIndex(where: {$0.id == object.id}) {
                self.teacherDepartmentArray[row].active = false
            }
        }
    }
    
    @objc func holidayDatePressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        let holidayDateLabel = cell.viewWithTag(2500) as! UILabel
        let indexPath = self.calendarTableView.indexPath(for: cell)
        
        if indexPath?.row == 0{
            let datePicker = ActionSheetDatePicker(title: "Select a Date:".localiz(), datePickerMode: UIDatePicker.Mode.date, selectedDate: Date(), doneBlock: {
                picker, value, index in
                
                let result = self.pickerDateFormatter.date(from: "\(value ?? Date())")
                let date = self.pickerDateResultFormatter.string(from: result ?? Date())
                holidayDateLabel.text = date
                self.holidayStartDate = result!
                
                let occasionDate = self.occasionDateFormatter.string(from: result ?? Date())
                
                self.occasion.endDate = "\(occasionDate)"
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!.superview)
            datePicker?.minimumDate = Date()
            
            datePicker?.show()
        }else{
            let datePicker = ActionSheetDatePicker(title: "Select a Date:".localiz(), datePickerMode: UIDatePicker.Mode.date, selectedDate: Date(), doneBlock: {
                picker, value, index in
                
                let result = self.pickerDateFormatter.date(from: "\(value ?? Date())")
                let date = self.pickerDateResultFormatter.string(from: result ?? Date())
                holidayDateLabel.text = date
                self.holidayEndDate = result!
                
                let occasionDate = self.occasionDateFormatter.string(from: result ?? Date())
                
                self.occasion.endDate = "\(occasionDate)"
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!.superview)
            datePicker?.minimumDate = Date()
            
            datePicker?.show()
        }
    }
    
    @objc func dateButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        let dateLabel = cell.viewWithTag(701) as! UILabel
        let indexPath = self.calendarTableView.indexPath(for: cell)
        
        if indexPath?.row == 0{
            let datePicker = ActionSheetDatePicker(title: "Select a Date:".localiz(), datePickerMode: UIDatePicker.Mode.date, selectedDate: self.selectedCalendarDate, doneBlock: {
                picker, value, index in
                
                let result = self.pickerDateFormatter.date(from: "\(value ?? Date())")
                let date = self.pickerDateResultFormatter.string(from: result ?? Date())
                dateLabel.text = date
                self.eventStartDate = result!
                
                let occasionDate = self.dateFormatter.string(from: result ?? Date())
                let timeLabel = cell.viewWithTag(703) as! UILabel
                let occasionTime = self.timeFormatter.string(from: self.pickerTimeResultFormatter.date(from: timeLabel.text ?? "01-09-1900") ?? Date())
                
                self.occasion.startDate = "\(occasionDate) \(occasionTime)"
                
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!.superview)
            datePicker?.minimumDate = Date()
            datePicker?.show()
            
//            if self.selectCalendarDate != ""{
//                self.occasion.startDate = self.dateFormatter.string(from: self.dateTimeFormatter.date(from: self.selectCalendarDate) ?? Date())
//            }
        }else{
            let datePicker = ActionSheetDatePicker(title: "Select a Date:".localiz(), datePickerMode: UIDatePicker.Mode.date, selectedDate: self.selectedCalendarDate, doneBlock: {
                picker, value, index in
                
                let result = self.pickerDateFormatter.date(from: "\(value ?? Date())")
                let date = self.pickerDateResultFormatter.string(from: result ?? Date())
                dateLabel.text = date
                self.eventEndDate = result!
                
                let occasionDate = self.dateFormatter.string(from: result ?? Date())
                let timeLabel = cell.viewWithTag(703) as! UILabel
                let occasionTime = self.timeFormatter.string(from: self.pickerTimeResultFormatter.date(from: timeLabel.text ?? "01-09-1900") ?? Date())
                
                self.occasion.endDate = "\(occasionDate) \(occasionTime)"
                
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!.superview)
            datePicker?.minimumDate = Date()
            datePicker?.show()
        }
    }
    
    @objc func timeButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        let timeLabel = cell.viewWithTag(703) as! UILabel
        if editType != self.agendaType.Holidays.rawValue{
            let time = self.pickerTimeResultFormatter.date(from: (timeLabel.text) ?? "12:00 am")
            let timePicker = ActionSheetDatePicker(title: "Select a Time:".localiz(), datePickerMode: UIDatePicker.Mode.time, selectedDate: time, doneBlock: {
                picker, value, index in
                let index = self.calendarTableView.indexPath(for: cell)
                
                let result = self.pickerDateFormatter.date(from: "\(value ?? Date())")
                if index?.row == 0{
                    self.eventStartTime = result
                }else{
                    self.eventEndTime = result
                }
                
                let time = self.pickerTimeResultFormatter.string(from: result ?? Date())
                timeLabel.text = time
                
                let occasionTime = self.timeFormatter.string(from: result ?? Date())
                let dateLabel = cell.viewWithTag(701) as! UILabel
                let occasionDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: dateLabel.text ?? "01-09-1900") ?? Date())
                
                if index?.row == 0{
                    self.occasion.startDate = "\(occasionDate) \(occasionTime)"
                }else{
                    self.occasion.endDate = "\(occasionDate) \(occasionTime)"
                }
                return
            }, cancel: {ActionStringCancelBlock in return}, origin: sender.superview!.superview)
            timePicker?.show()
        }
    }
    
    
    /// Description:
    /// - Show alert with option to take picture or upload one from phone gallery.
    @objc func uploadImageButtonPressed(sender: UIButton){
        let alert = UIAlertController(title: "Upload picture".localiz(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take photo".localiz(), style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from library".localiz(), style: .default, handler: { _ in
            self.openGallary()
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
    
    @objc func schoolSwitchPressed(sender: UIButton){
        isSchoolSwitch = !isSchoolSwitch
        self.reloadTableView()
    }
    
    
    @objc func departmentSwitchPressed(sender: PWSwitch){
        print("entered entered")
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = calendarTableView.indexPath(for: cell)
        if indexpath?.section == 8{
            self.teacherDepartmentArray[indexpath?.row ?? 0].active = !self.teacherDepartmentArray[indexpath?.row ?? 0].active

            if( self.teacherDepartmentArray[indexpath?.row ?? 0].active == true){
                self.getEmployeesByDepartment(user: self.user, departmentId: self.teacherDepartmentArray[indexpath?.row ?? 0].id)
            }
            else{
                self.employeesByDepartmentArray = self.employeesByDepartmentArray.filter {$0.title != String(self.teacherDepartmentArray[indexpath?.row ?? 0].id)}

            }
            
            print("department department: \(self.employeesByDepartmentArray)")
            
       
            
//            let id = model![indexpath!.section - 7].items[indexpath!.row].id
//            let active = model![indexpath!.section - 7].items[indexpath!.row].active
//            model![indexpath!.section - 7].items[indexpath!.row].active = !active
//            if let row = self.teacherDepartmentArray.firstIndex(where: {$0.id == id}) {
//                self.teacherDepartmentArray[row].active = !active
//            }
        }
    }

    @objc func classSwitchPressed(sender: PWSwitch){
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = calendarTableView.indexPath(for: cell)
        
        if indexpath?.section == 9{
            self.teacherSectionArray[indexpath?.row ?? 0].active = !self.teacherSectionArray[indexpath?.row ?? 0].active
            
            if(self.teacherSectionArray[indexpath?.row ?? 0].active == true){
                self.getStudentsBySection(user: self.user, sectionId: self.teacherSectionArray[indexpath?.row ?? 0].id)
                self.getParentsBySection(user: self.user, sectionId: self.teacherSectionArray[indexpath?.row ?? 0].id)

            }
            else{
                self.StudentsBySectionArray = self.StudentsBySectionArray.filter {$0.title != String(self.teacherSectionArray[indexpath?.row ?? 0].id)}

            }

//            let id = model![indexpath!.section - 7].items[indexpath!.row].id
//            let active = model![indexpath!.section - 7].items[indexpath!.row].active
//            model![indexpath!.section - 7].items[indexpath!.row].active = !active
//            if let row = self.teacherSectionArray.firstIndex(where: {$0.id == id}) {
//                self.teacherSectionArray[row].active = !active
//            }
        }
    }
    
}

// MARK: - Collection view functions:
extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if teacherEdit{
            return 3
        }else{
            if filteredEvents.isEmpty{
                return filteredEvents.count
            }
            return filteredEvents.count + 1
        }
    }
    
    //events icons with counter
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventsCell", for: indexPath)
        let eventIcon = cell.viewWithTag(21) as! UIImageView
        let counterLabel = cell.viewWithTag(22) as! UILabel
        let titleLabel = cell.viewWithTag(23) as! UILabel
        let allTitleLabel = cell.viewWithTag(231) as! UILabel
        let tickView: UIView? = cell.viewWithTag(25) //tick border
        let tickImageView = cell.viewWithTag(26) as! UIImageView //tick
        let backgroundView: UIView? = cell.viewWithTag(123)
        
        backgroundView?.layer.cornerRadius = backgroundView!.frame.width / 2
        titleLabel.font = UIFont(name: "OpenSans-Light", size: 11)
        allTitleLabel.font = UIFont(name: "OpenSans-Light", size: 11)
        backgroundView!.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
        backgroundView!.layer.masksToBounds = false
        allTitleLabel.isHidden = true
        titleLabel.isHidden = false
        if teacherEdit{
//            if teacherEditEvents[indexPath.row].type == self.agendaType.Dues.rawValue{
//                tickView?.isHidden = true
//                tickImageView.isHidden = true
//                //download icon image for dues
//                let icon = teacherEditEvents[indexPath.row].icon
//                if icon.contains("http"){
//                    let url = URL(string: teacherEditEvents[indexPath.row].icon)
//                    App.addImageLoader(imageView: eventIcon, button: nil)
//                    eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
//                        App.removeImageLoader(imageView: eventIcon, button: nil)
//                    }
//
//                }else{
//                    eventIcon.image = UIImage(named: icon)
//                }
//                counterLabel.isHidden = true
//                titleLabel.text = getTypeLabel(type: teacherEditEvents[indexPath.row].type ?? 8)
//                allTitleLabel.text = getTypeLabel(type: teacherEditEvents[indexPath.row].type ?? 8)
//            } else
            
            if editType == teacherEditEvents[indexPath.row].type {
                tickView?.isHidden = false
                tickImageView.isHidden = false
                tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
                tickView?.layer.borderWidth = 0
                //download icon image
                let icon = teacherEditEvents[indexPath.row].icon
                if icon.contains("http"){
                    let url = URL(string: teacherEditEvents[indexPath.row].icon)
                    App.addImageLoader(imageView: eventIcon, button: nil)
                    eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                        App.removeImageLoader(imageView: eventIcon, button: nil)
                    }

                }else{
                    eventIcon.image = UIImage(named: icon)
                }
                counterLabel.isHidden = true
                titleLabel.text = getTypeLabel(type: teacherEditEvents[indexPath.row].type ?? 8)
                allTitleLabel.text = getTypeLabel(type: teacherEditEvents[indexPath.row].type ?? 8)
            }else{
                tickView?.isHidden = false
                tickImageView.isHidden = true
                tickView?.backgroundColor = .white
                tickView?.layer.borderWidth = 1
                tickView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0).cgColor
                //download icon image
                let icon = teacherEditEvents[indexPath.row].icon
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
                titleLabel.text = getTypeLabel(type: teacherEditEvents[indexPath.row].type ?? 8)
                allTitleLabel.text = getTypeLabel(type: teacherEditEvents[indexPath.row].type ?? 8)
            }
            backgroundView?.backgroundColor = App.hexStringToUIColor(hex: teacherEditEvents[indexPath.row].color, alpha: 1.0)
        }else if indexPath.row == filteredEvents.count{
            allTitleLabel.isHidden = false
            titleLabel.isHidden = true
            let padding: CGFloat = 0
            let size = CGSize(width: backgroundView!.frame.size.width - padding, height: backgroundView!.frame.size.height - padding)
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: CGPoint.zero, size: size)
            gradient.colors = []
            
            for event in teacherEditEvents{
                gradient.colors?.append(App.hexStringToUIColor(hex: event.color, alpha: 1.0).cgColor)
            }
            gradient.accessibilityValue = "gradient"
            
            backgroundView!.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
            
            let shape = CAShapeLayer()
            shape.lineWidth = 2
            
            let diameter: CGFloat = min(gradient.frame.height, gradient.frame.width)
            shape.path = UIBezierPath(ovalIn: CGRect(x: backgroundView!.frame.width / 2 - diameter / 2 + 3, y: backgroundView!.frame.height / 2 - diameter / 2 + 1, width: diameter - 6, height: diameter - 6)).cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            gradient.mask = shape
            
            backgroundView!.layer.addSublayer(gradient)
            backgroundView!.layer.masksToBounds = true
            backgroundView?.backgroundColor = .white
            
            counterLabel.isHidden = false
            tickView?.isHidden = true
            tickImageView.isHidden = true
            eventIcon.image = UIImage(named: allEvent.icon)
            counterLabel.text = "\(allEvent.counter)"
            titleLabel.text = getTypeLabel(type: allEvent.type ?? 8) //8 for all upcoming in case of nil
            allTitleLabel.text = getTypeLabel(type: allEvent.type ?? 8)
            titleLabel.font = UIFont(name: "OpenSans-Light", size: 10)//8.5
            allTitleLabel.font = UIFont(name: "OpenSans-Light", size: 10)
        }else{
            counterLabel.isHidden = false
            tickView?.isHidden = true
            tickImageView.isHidden = true
            if filteredEvents[indexPath.row].icon.contains("http"){
                let url = URL(string: filteredEvents[indexPath.row].icon)
                App.addImageLoader(imageView: eventIcon, button: nil)
                eventIcon.sd_setImage(with: url) { (image, error, cache, url) in
                    App.removeImageLoader(imageView: eventIcon, button: nil)
                }
            }else{
                eventIcon.image = UIImage(named: filteredEvents[indexPath.row].icon)
            }
            counterLabel.text = "\(filteredEvents[indexPath.row].counter)"
            titleLabel.text = getTypeLabel(type: filteredEvents[indexPath.row].type ?? 8)
            allTitleLabel.text = getTypeLabel(type: filteredEvents[indexPath.row].type ?? 8)
            backgroundView?.backgroundColor = App.hexStringToUIColor(hex: filteredEvents[indexPath.row].color, alpha: 1.0)
        }
        backgroundView!.dropCircleShadow()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == filteredEvents.count && !teacherEdit{
            self.eventsArray = self.allEvent.detail
            self.eventsArray = Array(Set(self.eventsArray))
            self.eventTitle = getTypeLabel(type: self.allEvent.type ?? 8)
        }else{
            if teacherEdit{
//                if teacherEditEvents[indexPath.row].type != self.agendaType.Dues.rawValue{
                    editType = teacherEditEvents[indexPath.row].type!
//                }
            }else{
                self.eventsArray = filteredEvents[indexPath.row].detail
                self.eventsArray = Array(Set(self.eventsArray))
                self.eventTitle = getTypeLabel(type: filteredEvents[indexPath.row].type ?? 8)
            }
        }
        reloadTableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 64, height: 87)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    /// Description:
    /// - Reload table view without changing his offset.
    func reloadTableView(){
        let currentOffset = calendarTableView.contentOffset
        UIView.setAnimationsEnabled(false)
        calendarTableView.reloadData()
        UIView.setAnimationsEnabled(true)
        calendarTableView.setContentOffset(currentOffset, animated: false)
    }
    
}


// MARK: - FSCalendar Configuration:
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCell", for: date, at: position)
        cell.backgroundColor = .clear
        return cell
    }

//    func calendar (_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
//        print ("boundingRectWillChange", bounds)
//        calendar.frame = (CGRect)(origin: calendar.frame.origin,size: bounds.size)
//        self.view.layoutIfNeeded ()
//    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: monthPosition)
    }
    
    //calendar on click
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        self.currentDate = dateTimeFormatter.string(from: date)
        self.occasion.startDate = self.occasionDateFormatter.string(from: date)
        
        self.selectedCalendarDate = date
        if selectCalendarDate == self.currentDate{
            if teacherEdit{
                return false
            }
            self.currentDate = ""
            selectCalendarDate = ""
        }else{
            self.selectCalendarDate = dateTimeFormatter.string(from: date)
            if teacherEdit{
                let currentOffset = calendarTableView.contentOffset
                UIView.setAnimationsEnabled(false)
                calendarTableView.reloadSections([2], with: .none)
                UIView.setAnimationsEnabled(true)
                calendarTableView.setContentOffset(currentOffset, animated: true)
            }
        }

        self.initializeCalendarDates()
        let dateString = self.dateTimeFormatter.string(from: date)
        if self.selectedDate.contains(dateString) && !self.eventsArray.isEmpty && !teacherEdit{
            self.calendarTableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
        }
//        if (!eventsArray.isEmpty || !weekEvents.isEmpty || !filteredEvents.isEmpty) && !teacherEdit{
//            calendarTableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
//        }
        return true
    }
    
    
    /// Description:
    /// - This function is used after changing calendar week or month to update date label and events details.
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // Setup Calendar Label:
        let monthLabel = self.calendarTableView.viewWithTag(3) as! UILabel
        configureCalendarDate(calendar: calendar, calendarMonthLabel: monthLabel, cellIndex: 1)
        
        SectionVC.didLoadCalendar = false
        self.getCalendarAPI()
    }
    
    /// Description: This function is used to configure date label attributed text.
    ///
    /// - Parameters:
    ///   - calendar: FSCalendar.
    ///   - calendarMonthLabel: Label that we need to configure it.
    ///   - cellIndex: Label cell index 0 or 1.
    func configureCalendarDate(calendar: FSCalendar, calendarMonthLabel: UILabel, cellIndex: Int){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            var currentCalendar = Calendar.current
            currentCalendar.locale = Locale(identifier: "\(self.languageId)")
            let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendar.currentPage)
            let month = values.month
            let year = values.year
            let stringMonth = currentCalendar.monthSymbols[month! - 1]
            
            if Locale.current.languageCode == "hy" {
                calendarMonthLabel.text = "\(App.getArmenianMonth(month: month!)) \(year!)"
            }else{
                calendarMonthLabel.text = "\(stringMonth) \(year!)"
            }
        }
    }
    
    /// Description:
    /// - This function is used to draw colored layer on dates contains an event or more.
    func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        guard let diyCell = cell as? DIYCalendarCell else {return}
        let dateString: String = self.dateFormatter.string(from: date)
        // Configure selection layer
        diyCell.titleLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
        if position == .current {
            
            var selectionType = SelectionType.none
            if self.selectedDate.contains(dateString) {
                let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date) ?? Date()
                let previousDateString = self.dateTimeFormatter.string(from: previousDate)
                let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date) ?? Date()
                let nextDateString = self.dateTimeFormatter.string(from: nextDate)
                
                let key = self.dateFormatter.string(from: date)
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
                            }else if previousColor?.first == color?.first && previousColor?.count == 1 && (color?.first != nextColor?.first || nextColor?.count != 1){
                                selectionType = .rightBorder
                            }else if (previousColor?.first != color?.first || previousColor?.count != 1) && color?.first == nextColor?.first && nextColor?.count == 1{
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
                    
                    if dateTimeFormatter.string(from: date) == selectCalendarDate{
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
                if dateTimeFormatter.string(from: date) == selectCalendarDate{
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


// MARK: - Handle Sections Page Functions:
extension CalendarViewController: SectionVCDelegate{
    
    //MARK: called when weekly and monthly pressed
    /// Description:
    /// - This function is called from SectionVC page after choosing weekly or monthly views to update FSCalendar views.
    /// - Call getCalendarAPI function to update events data.
    func calendarFilterSectionView(type: Int) {
        print("calendar switch2")
        if let calendarView = calendarTableView.viewWithTag(4) as? FSCalendar{
            let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
//            let monthLabel = calendarTableView.viewWithTag(3) as! UILabel
            self.startDate = "01-09-1900"
            self.endDate = "30-09-2500"
            
            self.calendarTableView.isHidden = true
            switch type{
            //Monthly View:
            case 0:
                self.calendarStyle = .month
                calendarView.setScope(.month, animated: true)
                calendarHeight?.constant = 250
            //Weekly View:
            case 1:
                self.calendarStyle = .week
                calendarView.setScope(.week, animated: true)
                calendarHeight?.constant = 90
//                monthLabel.text = "\n"
                
            //Yearly View:
            case 2:
                calendarView.setScope(.month, animated: true)
                self.calendarStyle = .month
                let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.today!)
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
            SectionVC.didLoadCalendar = false
            print("getCalendarAPI4")
            self.getCalendarAPI()
        }
    }
    
    /// Description:
    ///
    /// - Parameters:
    ///   - batchId: In case the user is parent batch well be nil.
    ///   - children: In case the user is employee children will be nil.
    /// - This function is called from Section page when user changed.
    func switchCalendarChildren(user: User, batchId: Int?, children: Children?) {
        print("calendar switch1")
        self.user = user
        if self.calendarTableView != nil{
            print("entered calendar switch1")
            switch self.user.userType{
            case 1,2:
                self.batchId = batchId
                getSectionsDepartments(user: self.user)
            case 4:
                self.batchId = children?.batchId
                self.child = children
            default:
                break
            }
            SectionVC.didLoadCalendar = false
            self.getCalendarAPI()
        }
    }
    
    /// Description:
    ///
    /// - This function is called from Section page when class changed.
    func calendarBatchId(batchId: Int) {
        print("calendar switch3")
        self.batchId = batchId
//        SectionVC.didLoadCalendar = false
        if self.user.userType == 2 || self.user.userType == 1{
            if self.calendarTableView != nil{
                self.initEditEvents()
                guard let calendarView = self.calendarTableView.viewWithTag(4) as? FSCalendar else{ return }
                var dateArray = [Date]()
                for cell in calendarView.visibleCells(){
                    if !cell.isPlaceholder{
                        dateArray.append(calendarView.date(for: cell)!)
                    }
                }
                let fromDate = self.dateFormatter.string(from: dateArray.min() ?? Date())
                let toDate = self.dateFormatter.string(from: dateArray.max() ?? Date())
                self.updateCalendar(user: self.user, admissionNo: "", startDate: fromDate, endDate: toDate, batchId: self.batchId, calendarTheme: self.calendarTheme)
            }
        }
    }
    
    /// Description:
    /// - This function is called from Section page when colors and icons changed.
    func updateCalendarTheme(calendarTheme: CalendarTheme) {
        print("calendar switch4")
        self.calendarTheme = calendarTheme
    }
    
}

// MARK: - Select Picture:
extension CalendarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true , completion: nil )
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true)
        guard let selectedImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: selectedImage)
        
        cropController.delegate = self
        
       // self.selectedImage = selectedImage
        
        //If profile picture, push onto the same navigation stack
                if croppingStyle == .circular {
                    if picker.sourceType == .camera {
                        picker.pushViewController(cropController, animated: true)
//                        picker.dismiss(animated: true, completion: {
//                            self.present(cropController, animated: true, completion: nil)
//                        })
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
            
        
        
//        self.isSelectedImage = true
//        let imageView = calendarTableView.viewWithTag(721) as! UIImageView
//        imageView.image = selectedImage
//
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
        
        self.selectedImage = image
        self.isSelectedImage = true
        let imageView = calendarTableView.viewWithTag(721) as! UIImageView
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
        let imageView = calendarTableView.viewWithTag(721) as! UIImageView
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
//                let attach = self?.attachmentPickertime.string(from: Date())
//                if(self?.filename != nil){
//                    self!.filename = "Madrasatie\(attach!)"
//                }
//                else{
//                    self?.filename = "SLink"
//                }
//
//                let imageView = self?.calendarTableView.viewWithTag(721) as! UIImageView
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
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - API Calls:
extension CalendarViewController{
    
    /// Description:
    ///
    /// - Parameters:
    ///   - calendarTheme: Calendar colors and icons are set while parsing API response.
    /// - This function calls "get_occasions" API to get calendar events data.
    func getCalendar(user: User, admissionNo: String, startDate: String, endDate: String, batchId: Int, calendarTheme: CalendarTheme){
        if !self.refreshControl.isRefreshing {
            self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        }
        
        Request.shared.getCalendar(user: user, admissionNo: admissionNo, startDate: startDate, endDate: endDate, batchId: batchId, calendarTheme: calendarTheme) { (message, eventsData, status) in
            if status == 200{
                SectionVC.didLoadCalendar = true
                self.events = eventsData!
                var allEventCounter = 0
                var allEventsDetails: [EventDetail] = []
                for event in self.events{
                    allEventCounter += event.detail.count
                    for detail in event.detail{
                        allEventsDetails.append(detail)
                    }
                }
                
                //this is causing crash on 2.1.2
//                allEventsDetails = allEventsDetails.sorted(by: {self.dateTimeFormatter.date(from: $0.date) ?? Date() < self.dateTimeFormatter.date(from: $1.date) ?? Date()})
                allEventsDetails = allEventsDetails.sorted(by: {self.dateTimeFormatter.date(from: $0.date)! < self.dateTimeFormatter.date(from: $1.date)!})
                self.allEvent = Event(id: 1, icon: "empty", color: "", counter: allEventCounter, type: self.agendaType.AllUpcoming.rawValue, date: "", percentage: 0.0, detail: allEventsDetails, agendaDetail: [])
                self.eventsArray = []
                self.weekEvents = []
                self.eventTitle = ""
                self.eventsArray = self.allEvent.detail
                self.eventsArray = Array(Set(self.eventsArray))
                self.eventsArray = self.eventsArray.sorted(by: {self.dateTimeFormatter.date(from: $0.date) ?? Date() < self.dateTimeFormatter.date(from: $1.date) ?? Date()})
                
                self.eventTitle = self.getTypeLabel(type: self.allEvent.type ?? 8)
                self.initializeCalendarDates()
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.calendarTableView.isHidden = false
            self.calendarTableView.reloadData()
            if !self.refreshControl.isRefreshing {
                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    func updateCalendar(user: User, admissionNo: String, startDate: String, endDate: String, batchId: Int, calendarTheme: CalendarTheme){
        if !self.refreshControl.isRefreshing {
            self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        }
        Request.shared.getCalendar(user: user, admissionNo: admissionNo, startDate: startDate, endDate: endDate, batchId: batchId, calendarTheme: calendarTheme) { (message, eventsData, status) in
            if status == 200{
                self.events = eventsData!
                var allEventCounter = 0
                var allEventsDetails: [EventDetail] = []
                for event in self.events{
                    allEventCounter += event.detail.count
                    for detail in event.detail{
                        allEventsDetails.append(detail)
                    }
                }
                
                allEventsDetails = allEventsDetails.sorted(by: {self.dateTimeFormatter.date(from: $0.date) ?? Date() < self.dateTimeFormatter.date(from: $1.date) ?? Date()})
                self.allEvent = Event(id: 1, icon: "empty", color: "", counter: allEventCounter, type: self.agendaType.AllUpcoming.rawValue, date: "", percentage: 0.0, detail: allEventsDetails, agendaDetail: [])
                self.eventsArray = []
                self.weekEvents = []
                self.eventTitle = ""
                self.eventsArray = self.allEvent.detail
                self.eventsArray = Array(Set(self.eventsArray))
                self.eventsArray = self.eventsArray.sorted(by: {self.dateTimeFormatter.date(from: $0.date) ?? Date() < self.dateTimeFormatter.date(from: $1.date) ?? Date()})
                
                self.eventTitle = self.getTypeLabel(type: self.allEvent.type ?? 8)
                self.initializeCalendarDates()
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.calendarTableView.isHidden = false
            self.calendarTableView.reloadData()
            if !self.refreshControl.isRefreshing {
                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    /// Description:
    /// - This function call "get_sections_and_departments" API to get sections and departments data.
    func getSectionsDepartments(user: User){
        Request.shared.getDepartments(user: user) { (message, departmentData, status) in
            if status == 200{
                self.teacherDepartmentArray = departmentData!
            }
            else{
                print("error", "getSectionsDepartments")
            }
        }
        
        Request.shared.getSections(user: user) { (message, sectionData, status) in
            if status == 200{
                self.teacherSectionArray = sectionData!
                
            }
            else{
                print("error", "getSectionsDepartments")
            }
        }
    }
    
    func getEmployeesByDepartment(user: User, departmentId: String){
        Request.shared.getEmployeesByDepartment(user: user, departmentId: departmentId) { (message, departmentData, status) in
            if status == 200{
          
                self.employeesByDepartmentArray = self.employeesByDepartmentArray + departmentData!
                print("test test test1: \(self.employeesByDepartmentArray   )")

            }
            else{
                print("error", "getSectionsDepartments")
            }
        }
        
       
    }
    
    func getStudentsBySection(user: User, sectionId: String){
        Request.shared.getStudentsBySection(user: user, sectionId: sectionId) { (message, sectionsData, status) in
            if status == 200{
                self.StudentsBySectionArray = self.StudentsBySectionArray + sectionsData!

                print("test test test2: \(self.StudentsBySectionArray   )")

            }
            else{
                print("error", "getSectionsDepartments")
            }
        }
        
       
    }
    
    func getParentsBySection(user: User, sectionId: String){
        Request.shared.getParentsBySection(user: user, sectionId: sectionId) { (message, sectionsData, status) in
            if status == 200{
                self.StudentsBySectionArray = self.StudentsBySectionArray + sectionsData!

                print("test test test2: \(self.StudentsBySectionArray   )")

            }
            else{
                print("error", "getSectionsDepartments")
            }
        }
        
       
    }

    
    
    /// - This function call "get_sections_and_departments" API to get sections and departments data.
  
    
    /// Description:
    /// - This function call "create_occasion" API when employee needs to submit an event.
    func saveEvent(user: User, image: UIImage, occasion: Occasion){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        SectionVC.canChange = true
        Request.shared.createOccasion(user: user, profile: image, occasion: occasion, filename: self.filename) { (message, result, status) in
            if status == 200{
                App.showMessageAlert(self, title: "", message: "Saved!".localiz(), dismissAfter: 1.0)
                //reset the saved stuff
                self.resetSavedData()
                
                self.emptyTableFields()
                SectionVC.didLoadCalendar = false
                self.getCalendarAPI()
            } else {
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
    /// - This function call "update_occasion" API when employee needs to edit an event.
    func editEvent(user: User, image: UIImage, occasion: Occasion){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        SectionVC.canChange = true
        Request.shared.updateOccasion(user: user, profile: image, occasion: occasion, filename: self.filename) { (message, result, status) in
            if status == 200{
                App.showMessageAlert(self, title: "", message: "Updated!".localiz(), dismissAfter: 1.0)
                //reset the saved stuff
                self.resetSavedData()
                
                self.emptyTableFields()
                SectionVC.didLoadCalendar = false
                self.getCalendarAPI()
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
    /// Description:
    /// - This function call "delete_occasion" API when employee want to remove an event.
    func deleteOccasion(user: User, occasionId: Int){
        let alert = UIAlertController(title: "Are you sure?".localiz(), message: "Are you sure you want to delete this event ?".localiz(),         preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel".localiz(), style: UIAlertAction.Style.default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "OK".localiz(),style: UIAlertAction.Style.default,handler: {(_: UIAlertAction!) in
            self.view.superview?.superview?.insertSubview(self.loading, at: 1)
            Request.shared.deleteOccasion(user: user, occasionId: occasionId) { (message, result, status) in
                if status == 200{
                    App.showMessageAlert(self, title: "", message: "Occasion deleted!".localiz(), dismissAfter: 1.0)
                    SectionVC.didLoadCalendar = false
                    self.getCalendarAPI()
                }
                else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                }
                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Description:
    /// - Reset page data after submit an event.
    func emptyTableFields(){
        let addEventIcon = self.calendarTableView.viewWithTag(721) as! UIImageView
        let textView = self.calendarTableView.viewWithTag(715) as! UITextView
        let textField = self.calendarTableView.viewWithTag(750) as! UITextField
        
        self.occasion = Occasion(id: nil, startDate: self.occasionDateFormatter.string(from: Date()), endDate: self.occasionDateFormatter.string(from: Date()), title: "", description: "", holiday: false, common: true, batches: [], departments: [], meeting: false)
        
        addEventIcon.image = UIImage(named: "add-picture")
        textView.text = ""
        textField.text = ""
        self.teacherEdit = false
    }
    
}
