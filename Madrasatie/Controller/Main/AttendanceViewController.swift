//
//  AttendanceViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/9/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
//import FSCalendar

/// Description:
/// - Delegate from Attendance page to Section page.
protocol AttendanceViewControllerDelegate{
    func attendance(user: User, calendarType: CalendarStyle?)
    func backToCalendar()
}

/// Description:
/// - Delegate from Attendace page to request leave page.
protocol RequestLeaveDelegate{
    func requestLeave(percentageArray: [Double], colorArray: [NSUIColor], user: User, fullDay: Bool, selectedPeriods: [Period], date: String, startDate: String, endDate: String)
    func verifyAbsence(percentageArray: [Double], colorArray: [NSUIColor], user: User, id: Int)
}

/// Description:
/// - Delegate from Attendace page to attendace timetable page.
protocol TimeTableDelegate{
    func timeTableData(user: User, children: Children?, subjectTheme: [SubjectTheme]?, date: String)
}

enum AttendanceType{
    case absent
    case present
    case late
}

class AttendanceViewController: UIViewController {

    @IBOutlet weak var attendanceTableView: UITableView!
    @IBOutlet var requestLeaveContainerView: UIView!
    @IBOutlet weak var timeTableContainerView: UIView!
    
    var selectedDate: [String] = []
    var percentage: [Double] = [80, 10, 10]
    var chartColors: [NSUIColor] = [App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0), App.hexStringToUIColorCst(hex: "#ffcb39", alpha: 1.0), App.hexStringToUIColorCst(hex: "#ff5955", alpha: 1.0)]
    var attendanceDelegate: AttendanceViewControllerDelegate?
    var requestDelegate: RequestLeaveDelegate?
    var timeTableDelegate: TimeTableDelegate?
    var startDate = "01-09-1900"
    var endDate = "30-09-2500"
    var calendarStyle: CalendarStyle? = .week
    var attendanceArray: [Attendance] = []
    var user: User!
    var child: Children!
    var studentList: [TeacherAttendance] = []
    var filteredStudentList: [TeacherAttendance] = []
    var teacherEdit = false
    var attendanceDate = Date()
    var filterAttendanceView: AttendanceType?
//    var batchId: Int!
    var currentClass: Class! = Class(classId: 0, batchId: 0, className: "", imperiumCode: "")
    var selectCalendarDate = ""
    var appTheme: AppTheme!
    var daysId: [Int] = []
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    var canRefresh = true
    var refreshControl = UIRefreshControl()
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")

    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
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
    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var titleDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d,  MMMM yyyy"
        formatter.locale = Locale(identifier: self.languageId )
        return formatter
    }()
    
    fileprivate lazy var DayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: self.languageId )
        return formatter
    }()
    
    var fillDefaultColors: [String: [UIColor]] = [:]
    var overrideDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarStyle = .week
        attendanceTableView.delegate = self
        attendanceTableView.dataSource = self
        timeTableContainerView.isHidden = true
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localiz())
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        attendanceTableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh() {
        // Code to refresh table view
        SectionVC.didLoadAttandance = false
        self.getAttandanceAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendarStyle = .week
        self.attendanceDelegate?.attendance(user: self.user, calendarType: self.calendarStyle)
        if self.user.userType != 4{
            self.timeTableContainerView.isHidden = true
            self.requestLeaveContainerView.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -70 { //change 100 to whatever you want
            if canRefresh && !self.refreshControl.isRefreshing {
                self.canRefresh = false
                self.refreshControl.beginRefreshing()
                self.refresh() // your viewController refresh function
            }
        } else if scrollView.contentOffset.y >= 0 {
            self.canRefresh = true
        }
    }

    /// Description:
    /// - Set calendar default scope to weekly view.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            if self.user.userType != 2 || self.user.userType != 1{
                if let calendarView = self.attendanceTableView.viewWithTag(4) as? FSCalendar{
                    let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
                    let monthLabel = self.attendanceTableView.viewWithTag(3) as! UILabel

                    //set month label
                    var currentCalendar = Calendar.current
                    currentCalendar.locale = Locale(identifier: "\(self.languageId)")
                    let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.currentPage)
                    let stringMonth = currentCalendar.monthSymbols[values.month! - 1]
                    monthLabel.text = "\(stringMonth) \(values.year!)"
                    
                    if self.calendarStyle == .week{
                        calendarView.setScope(.week, animated: false)
                        calendarHeight?.constant = 90
                    }else{
                        calendarView.setScope(.month, animated: false)
                        calendarHeight?.constant = 250
                    }
                    self.attendanceTableView.isHidden = false
                    self.attendanceTableView.reloadData()
                    
                    //set date if from notification
                    if self.overrideDate != ""{
                        let goToDate = self.ddateFormatter.date(from: self.overrideDate)
                        calendarView.select(goToDate, scrollToDate: true)
                    }
                }
            }
            self.getAttandanceAPI()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "absenceReason"{
            let absenceReason = segue.destination as! AttendanceRequestLeaveViewController
            absenceReason.delegate = self
            self.requestDelegate = absenceReason.self
        }
        if segue.identifier == "timeTable"{
            let timeTable = segue.destination as! AttendanceTimeTableViewController
            timeTable.delegate = self
            self.timeTableDelegate = timeTable.self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Description:
    /// - Used to init/reload chart colors and percentage.
    /// - Used to group and format attendance events date.
    func reloadAttendance(){
        
        var presentPercentage = self.attendanceArray.filter({$0.type == "present"}).first?.percentage ?? 0.0
        var latePercentage = self.attendanceArray.filter({$0.type == "latency"}).first?.percentage ?? 0.0
        var absentPercentage = self.attendanceArray.filter({$0.type == "absent"}).first?.percentage ?? 0.0
        if(presentPercentage == nil){
            presentPercentage = 0.0
        }
        if(latePercentage == nil){
            latePercentage = 0.0
        }
        if(absentPercentage == nil){
            absentPercentage = 0.0
        }
        print("reloadAttendance")
        print(presentPercentage)
        print(latePercentage)
        print(absentPercentage)
        self.percentage = [presentPercentage ?? 0, latePercentage ?? 0, absentPercentage ?? 0] as! [Double]
        self.chartColors = [App.hexStringToUIColor(hex: appTheme.attendanceTheme.presenceColor, alpha: 1.0), App.hexStringToUIColor(hex: appTheme.attendanceTheme.lateColor, alpha: 1.0), App.hexStringToUIColor(hex: appTheme.attendanceTheme.absenceColor, alpha: 1.0)]
        
        var datesArray: [CalendarDate] = []
        for attendance in attendanceArray{
            if attendance.type != "present"{
                for detail in attendance.details{
                    print("entered entered here")
                    let date = CalendarDate(date: detail.date, color: attendance.color)
                    datesArray.append(date)
                }
            }
        }
        
        let dateArray = Dictionary(grouping: datesArray, by: { $0.date })
        self.selectedDate.removeAll()
        var dic: [String: [UIColor]] = [:]
        for key in dateArray{
            self.selectedDate.append(key.key)
            var colors: [UIColor] = []
            for color in key.value{
                colors.append(App.hexStringToUIColor(hex: color.color, alpha: 1.0))
            }
            dic[key.key] = colors
        }
        fillDefaultColors = dic
        
        attendanceTableView.reloadData()
    }
    
    /// Description:
    /// - Reload employee students.
    func filterAttendance(){
        self.filteredStudentList = []
        switch filterAttendanceView{
        case .present?:
            self.filteredStudentList = self.studentList.filter({$0.status == 1})
        case .late?:
            self.filteredStudentList = self.studentList.filter({$0.status == 2})
        case .absent?:
            self.filteredStudentList = self.studentList.filter({$0.status == 3})
        case .none:
            self.filteredStudentList = self.studentList
        }
        self.attendanceTableView.reloadData()
    }
    
    
    /// Description:
    /// - Init start date and end date.
    /// - Get attandance data for each user type.
    func getAttandanceAPI(){
        if SectionVC.didLoadAttandance {
            return
        }
        
        let fromDate = getCalendarDates().0
        let toDate = getCalendarDates().1
        
            switch self.user.userType{
            
            case 1,2:
//                if self.user.privileges.contains(App.studentAttendanceViewPrivilege){
                if self.currentClass != nil && self.currentClass.batchId != 0{
//                    self.getSectionAttendance(user: self.user, sectionId: self.currentClass.batchId, date: dateFormatter.string(from: attendanceDate))
                    self.getAttendanceList(user: self.user, sectionId: self.currentClass.batchId, date: dateFormatter.string(from: attendanceDate))
                }
            case 3:
                self.getAttendance(user: self.user, studentUsername: self.user.userName, startDate: fromDate, endDate: toDate)
            case 4:
                self.getAttendance(user: self.user, studentUsername: self.user.admissionNo, startDate: fromDate, endDate: toDate)
            default:
                break
            }
        
    }
    
    /// Description:
    /// - Calculate and return start date and end date based on FSCalendar scope.
    func getCalendarDates() -> (String, String){
        let calendarView = self.attendanceTableView.viewWithTag(4) as? FSCalendar
        var fromDate = ""
        var toDate = ""
        if calendarView != nil{
            var startDate: Date
            let endDate: Date
            if calendarView!.scope == .week {
                startDate = calendarView!.currentPage
                startDate = calendarView!.gregorian.date(byAdding: .day, value: 0, to: startDate)!
                endDate = calendarView!.gregorian.date(byAdding: .day, value: 6, to: startDate)!
            } else { // .month
                //Uncomment if you need to get all visible dates:
//                let indexPath = calendarView!.calculator.indexPath(for: calendarView!.currentPage, scope: .month)
//                startDate = calendarView!.calculator.monthHead(forSection: indexPath!.section)!
//                startDate = calendarView!.gregorian.date(byAdding: .day, value: 1, to: startDate)!
//                endDate = calendarView!.gregorian.date(byAdding: .day, value: 41, to: startDate)!
                
                // This will return first and last month dates:
                startDate = calendarView!.gregorian.date(byAdding: .day, value: 0, to: calendarView!.currentPage)!
                endDate = calendarView!.gregorian.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
            }
            
            fromDate = self.dateFormatter.string(from: startDate)
            toDate = self.dateFormatter.string(from: endDate)
        }
        return (fromDate, toDate)
    }
    
}

extension AttendanceViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.user.userType{
        
        case 1,2:
            return 3
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.user.userType{
       
        case 1,2:
            switch section{
            case 0:
                return 1
            case 1:
                return 1
            default:
                return filteredStudentList.count
            }
        case 3:
            let absence = self.attendanceArray.filter({$0.type == "absent"}).first
            let count = absence?.details.filter({$0.verified == false}).count ?? 0
            return count + 2
        default:
            let absence = self.attendanceArray.filter({$0.type == "absent"}).first
            let count = absence?.details.filter({$0.verified == false}).count ?? 0
            return count + 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.user.userType{
        
        case 1,2:
            switch indexPath.section{
            case 0:
                let cell = attendanceTableView.dequeueReusableCell(withIdentifier: "teacherTitleReuse")
                let titleLabel = cell?.viewWithTag(30) as! UILabel
                let backButton = cell?.viewWithTag(31) as! UIButton
                let nextButton = cell?.viewWithTag(32) as! UIButton
                let calendarNextImageView = cell?.viewWithTag(61) as! UIImageView
                let calendarBackImageView = cell?.viewWithTag(99) as! UIImageView
                
                if self.languageId == "ar"{
                    calendarNextImageView.image = UIImage(named: "calendar-left-arrow")
                    calendarBackImageView.image = UIImage(named: "calendar-right-arrow")
                }else{
                    calendarNextImageView.image = UIImage(named: "calendar-right-arrow")
                    calendarBackImageView.image = UIImage(named: "calendar-left-arrow")
                }
                let date1 = self.DayFormatter.string(from: attendanceDate)
                let date2 = self.titleDateFormatter.string(from: attendanceDate).uppercased()
                titleLabel.text = "\(date1) \(date2)"
                backButton.addTarget(self, action: #selector(teacherBackButtonPressed), for: .touchUpInside)
                nextButton.addTarget(self, action: #selector(teacherNextButtonPressed), for: .touchUpInside)
                cell?.selectionStyle = .none
                return cell!
            case 1:
                let presenceCell = attendanceTableView.dequeueReusableCell(withIdentifier: "presenceReuse")
                let monthLabel = presenceCell?.viewWithTag(10) as! UILabel
                let presentView: UIView? = presenceCell?.viewWithTag(11)
                let presentLabel = presenceCell?.viewWithTag(12) as! UILabel
                let presentPercentageLabel = presenceCell?.viewWithTag(13) as! UILabel
                let lateView: UIView? = presenceCell?.viewWithTag(14)
                let lateLabel = presenceCell?.viewWithTag(15) as! UILabel
                let latePercentageLabel = presenceCell?.viewWithTag(16) as! UILabel
                let absentView: UIView? = presenceCell?.viewWithTag(17)
                let absentLabel = presenceCell?.viewWithTag(18) as! UILabel
                let absentPercentageLabel = presenceCell?.viewWithTag(19) as! UILabel
                let shadowView: UIView? = presenceCell?.viewWithTag(20)
                let chartView: PieChartView! = presenceCell?.viewWithTag(295) as? PieChartView
                let stackView = presenceCell?.viewWithTag(1001) as! UIStackView
                let stackLeadingConstraint = stackView.constraints.filter({$0.identifier == "stackViewLeading"}).first
                let chartTrailerConstraint = chartView.constraints.filter({$0.identifier == "chartTrailler"}).first
                if self.view.frame.width == 320{
                    stackLeadingConstraint?.constant = 8
                    chartTrailerConstraint?.constant = 16
                }else{
                    stackLeadingConstraint?.constant = 30
                    chartTrailerConstraint?.constant = 35
                }
                presentLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
                presentPercentageLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
                lateLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
                latePercentageLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
                absentLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
                absentPercentageLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
                
                let presentPercentage = self.attendanceArray.filter({$0.type == "present"}).first?.percentage
                let latePercentage = self.attendanceArray.filter({$0.type == "latency"}).first?.percentage
                let absentPercentage = self.attendanceArray.filter({$0.type == "absent"}).first?.percentage
                
                let date1 = self.DayFormatter.string(from: attendanceDate)
                let date2 = self.titleDateFormatter.string(from: attendanceDate).uppercased()
                monthLabel.text = "\(date1) \(date2)"
                presentView?.layer.borderColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.presenceColor, alpha: 1.0).cgColor
                presentLabel.text = "Present".localiz()
                presentPercentageLabel.text = "\(presentPercentage ?? 0) %"
                presentPercentageLabel.textColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.presenceColor, alpha: 1.0)
                
                lateView?.layer.borderColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.lateColor, alpha: 1.0).cgColor
                lateLabel.text = "Late or Left".localiz()
                latePercentageLabel.textColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.lateColor, alpha: 1.0)
                latePercentageLabel.text = "\(latePercentage ?? 0) %"
                
                absentView?.layer.borderColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.absenceColor, alpha: 1.0).cgColor
                absentLabel.text = "Absent".localiz()
                absentPercentageLabel.textColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.absenceColor, alpha: 1.0)
                absentPercentageLabel.text = "\(absentPercentage ?? 0) %"
                
                shadowView?.dropShadow()
                
                setup(pieChartView: chartView)
                
                presenceCell?.selectionStyle = .none
                presenceCell?.layoutIfNeeded()
                return presenceCell!
            default:
                let cell = attendanceTableView.dequeueReusableCell(withIdentifier: "studentAttendanceReuse")
                let _: UIView? = cell?.viewWithTag(40)
                let studentIcon = cell?.viewWithTag(41) as! UIImageView
                let nameLabel = cell?.viewWithTag(42) as! UILabel
                let lateNameLabel = cell?.viewWithTag(43) as! UILabel
                let lateTimeLabel = cell?.viewWithTag(44) as! UILabel
                let attendanceView: UIView? = cell?.viewWithTag(45)
                let attendanceImageView = cell?.viewWithTag(46) as! UIImageView
                let attendanceButton = cell?.viewWithTag(47) as! UIButton
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: attendanceDate)
                
                let student = filteredStudentList[indexPath.row]
                attendanceButton.addTarget(self, action: #selector(attendanceButtonPressed), for: .touchUpInside)
                
                var icon = student.image.unescaped
                
                if(baseURL?.prefix(8) == "https://"){
                    if(student.image.unescaped.prefix(8) != "https://"){
                        icon = "https://" + icon
                    }
                }
                else if(baseURL?.prefix(7) == "http://"){
                    if (student.image.unescaped.prefix(7) != "http://" ){
                        icon = "http://" + icon
                    }
                }
                
                
                if student.image.unescaped != "" {
                   
                        if(student.gender.lowercased() == "m"){
                            studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))

                        }
                        else{
                            studentIcon.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))

                        }
                    
                }else{
                   
                        if(student.gender.lowercased() == "m"){
                            studentIcon.image = UIImage(named: "student_boy")
                        }
                        else{
                            studentIcon.image = UIImage(named: "student_girl")
                        }
                    
                    
                }
                
                
                nameLabel.text = student.name
                lateNameLabel.text = student.name
                lateTimeLabel.text = "\(student.latencyTime) mins"
                switch student.status{
                case 1:
                    lateNameLabel.isHidden = true
                    lateTimeLabel.isHidden = true
                    nameLabel.isHidden = false
                    if teacherEdit && attendanceDate > yesterday!{
                        attendanceButton.isUserInteractionEnabled = true
                    }else{
                        attendanceButton.isUserInteractionEnabled = false
                    }
                    attendanceView?.backgroundColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.presenceColor, alpha: 1.0)
                    attendanceView?.layer.borderWidth = 0
                    attendanceImageView.image = UIImage(named: "present")
                    studentIcon.layer.borderColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.presenceColor, alpha: 1.0).cgColor
                case 2:
                    lateNameLabel.isHidden = true
                    lateTimeLabel.isHidden = true
                    nameLabel.isHidden = false
                    if teacherEdit && attendanceDate > yesterday!{
                        attendanceButton.isUserInteractionEnabled = true
                    }else{
                        attendanceButton.isUserInteractionEnabled = false
                    }
                    attendanceView?.backgroundColor = .white
                    attendanceView?.layer.borderWidth = 2
                    attendanceView?.layer.borderColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.absenceColor, alpha: 1.0).cgColor
                    attendanceImageView.image = UIImage(named: "absent")
                    studentIcon.layer.borderColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.absenceColor, alpha: 1.0).cgColor
                default:
                    lateNameLabel.isHidden = false
                    lateTimeLabel.isHidden = false
                    nameLabel.isHidden = true
                    attendanceButton.isUserInteractionEnabled = false
                    attendanceView?.backgroundColor = .white
                    attendanceView?.layer.borderWidth = 2
                    attendanceView?.layer.borderColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.lateColor, alpha: 1.0).cgColor
                    attendanceImageView.image = UIImage(named: "late")
                    studentIcon.layer.borderColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.lateColor, alpha: 1.0).cgColor
                }
                cell?.selectionStyle = .none
                return cell!
            }
        default:
            switch indexPath.row {
            case 0:
                let calendarCell = attendanceTableView.dequeueReusableCell(withIdentifier: "calendarReuse")
                let calendarNextButton = calendarCell?.viewWithTag(6) as! UIButton
                let calendarPreviousButon = calendarCell?.viewWithTag(1) as! UIButton
                guard let calendarView: FSCalendar = calendarCell?.viewWithTag(4) as? FSCalendar else{
                    return UITableViewCell()
                }
                let calendarNextImageView = calendarCell?.viewWithTag(611) as! UIImageView
                let calendarBackImageView = calendarCell?.viewWithTag(991) as! UIImageView
                
                if self.languageId == "ar"{
                    calendarNextImageView.image = UIImage(named: "calendar-left-arrow")
                    calendarBackImageView.image = UIImage(named: "calendar-right-arrow")
                }else{
                    calendarNextImageView.image = UIImage(named: "calendar-right-arrow")
                    calendarBackImageView.image = UIImage(named: "calendar-left-arrow")
                }
                
                calendarNextButton.addTarget(self, action: #selector(calendarNextButtonPressed), for: .touchUpInside)
                calendarNextButton.dropCircleShadow()
                calendarPreviousButon.addTarget(self, action: #selector(calendarPreviousButtonPressed), for: .touchUpInside)
                calendarPreviousButon.dropCircleShadow()
//                calendarView.bottomBorder.isHidden = true
                calendarView.calendarWeekdayView.addBorders(edges: .bottom)
                calendarView.delegate = self
                calendarView.dataSource = self
                calendarView.locale = Locale(identifier: self.languageId )
                calendarView.register(DIYCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
                calendarView.reloadData()
                
                let monthLabel = calendarCell?.viewWithTag(3) as! UILabel
                
                // Setup Calendar Label:
                configureCalendarLabel(calendar: calendarView, calendarMonthLabel: monthLabel, cellIndex: 0)
               
                calendarCell?.selectionStyle = .none
                return calendarCell!
            case 1:
                let presenceCell = attendanceTableView.dequeueReusableCell(withIdentifier: "presenceReuse")
                let monthLabel = presenceCell?.viewWithTag(10) as! UILabel
                
                // Setup month label:
                guard let calendarView = attendanceTableView.viewWithTag(4) as? FSCalendar else{
                    return UITableViewCell()
                }
                var currentCalendar = Calendar.current
                currentCalendar.locale = Locale(identifier: self.languageId )
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
                
                let presentView: UIView? = presenceCell?.viewWithTag(11)
                presentView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0).cgColor
                let presentLabel: UILabel = presenceCell?.viewWithTag(12) as! UILabel
                presentLabel.text = "Present".localiz()
                let presentPercentageLabel = presenceCell?.viewWithTag(13) as! UILabel
                
                let presentPercentage = self.attendanceArray.filter({$0.type == "present"}).first?.percentage
                let latePercentage = self.attendanceArray.filter({$0.type == "latency"}).first?.percentage
                let absentPercentage = self.attendanceArray.filter({$0.type == "absent"}).first?.percentage
                
                presentPercentageLabel.text = "\(presentPercentage ?? 0.0) %"
                presentPercentageLabel.textColor = App.hexStringToUIColor(hex: appTheme.attendanceTheme.presenceColor, alpha: 1.0)
                
                let lateView: UIView? = presenceCell?.viewWithTag(14)
                lateView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#ffcb39", alpha: 1.0).cgColor
                let lateLabel: UILabel = presenceCell?.viewWithTag(15) as! UILabel
                lateLabel.text = "Late or Left".localiz()
                let latePercentageLabel = presenceCell?.viewWithTag(16) as! UILabel
                latePercentageLabel.textColor = App.hexStringToUIColorCst(hex: "#ffcb39", alpha: 1.0)
                latePercentageLabel.text = "\(latePercentage ?? 0.0) %"
                
                let absentView: UIView? = presenceCell?.viewWithTag(17)
                absentView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#ff5955", alpha: 1.0).cgColor
                let absentLabel: UILabel = presenceCell?.viewWithTag(18) as! UILabel
                absentLabel.text = "Absent".localiz()
                let absentPercentageLabel = presenceCell?.viewWithTag(19) as! UILabel
                absentPercentageLabel.textColor = App.hexStringToUIColorCst(hex: "#ff5955", alpha: 1.0)
                absentPercentageLabel.text = "\(absentPercentage ?? 0.0) %"
                
                let shadowView: UIView? = presenceCell?.viewWithTag(20)
                shadowView?.dropShadow()
                
                let chartView: PieChartView! = presenceCell?.viewWithTag(295) as? PieChartView
                setup(pieChartView: chartView)
                
                let stackView = presenceCell?.viewWithTag(1001) as! UIStackView
                let stackLeadingConstraint = stackView.constraints.filter({$0.identifier == "stackViewLeading"}).first
                let chartTrailerConstraint = chartView.constraints.filter({$0.identifier == "chartTrailler"}).first
                
                if self.view.frame.width == 320{
                    stackLeadingConstraint?.constant = 8
                    chartTrailerConstraint?.constant = 16
                    presentLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
                    presentPercentageLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
                    lateLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
                    latePercentageLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
                    absentLabel.font = UIFont(name: "OpenSans-Bold", size: 12)
                    absentPercentageLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
                }else{
                    stackLeadingConstraint?.constant = 30
                    chartTrailerConstraint?.constant = 35
                    presentLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
                    presentPercentageLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
                    lateLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
                    latePercentageLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
                    absentLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
                    absentPercentageLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
                }
                
                presenceCell?.selectionStyle = .none
                presenceCell?.layoutIfNeeded()
                return presenceCell!
            default:
                let absence = self.attendanceArray.filter({$0.type == "absent"}).first
                print("absences: \(absence)")
                let count = absence?.details.filter({$0.verified == false}).count ?? 0
                if count > 0 && indexPath.row != count+2{
                    let absence = absence?.details.filter({$0.verified == false})
                    let verifyCell = self.attendanceTableView.dequeueReusableCell(withIdentifier: "verifyAbsenceCellReuse")
                    let backgroundView: UIView? = verifyCell?.viewWithTag(1000)
                    let titleLabel = verifyCell?.viewWithTag(1001) as! UILabel
                    let dateLabel = verifyCell?.viewWithTag(1002) as! UILabel
                    let arrowButton = verifyCell?.viewWithTag(1003) as! UIButton
                    
                    if self.languageId == "ar"{
                        arrowButton.setImage(UIImage(named: "arrow-left"), for: .normal)
                    }else{
                        arrowButton.setImage(UIImage(named: "arrow-right"), for: .normal)
                    }
                    backgroundView?.backgroundColor = App.hexStringToUIColorCst(hex: "#ff5955", alpha: 1.0)
                    titleLabel.text = "Absence".localiz()
                    let date = self.dateFormatter.date(from: absence?[indexPath.row - 2].date ?? "2018-09-19")
                    let dateString = self.dateFormatter1.string(from: date ?? Date())
                    dateLabel.text = dateString
                    let tabGesture = UITapGestureRecognizer(target: self, action: #selector(verifyPressed(_:)))
                    backgroundView?.addGestureRecognizer(tabGesture)
                    verifyCell?.selectionStyle = .none
                    return verifyCell!
                }else{
                    let requestCell = attendanceTableView.dequeueReusableCell(withIdentifier: "absenceReuse")
                    let requestButton = requestCell?.viewWithTag(25) as! UIButton
                    
                    requestButton.addTarget(self, action: #selector(requestButtonPressed), for: .touchUpInside)
                    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                    if selectCalendarDate == "" || dateFormatter1.date(from: self.selectCalendarDate) ?? Date() < yesterday{
                        requestButton.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 0.5)
                        requestButton.isUserInteractionEnabled = false
                    }else{
                        requestButton.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
                        requestButton.isUserInteractionEnabled = true
                    }
                    requestButton.tintColor = .white
                    requestCell?.selectionStyle = .none
                    return requestCell!
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch self.user.userType{
       
        case 1,2:
            if section == 2{
                let cell = attendanceTableView.dequeueReusableCell(withIdentifier: "studentListReuse")
                let _: UIView? = cell?.viewWithTag(35)
                let titleLabel = cell?.viewWithTag(36) as! UILabel
                let studentNumberLabel = cell?.viewWithTag(37) as! UILabel
                let editButton = cell?.viewWithTag(38) as! UIButton
                let imageView = cell?.viewWithTag(50) as! UIImageView
                
                if teacherEdit{
                    imageView.tintColor = App.hexStringToUIColorCst(hex: "#c46666", alpha: 1.0)
                }else{
                    imageView.tintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
                }
                editButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
                if(self.user.userType == 1){
                    editButton.isHidden = false
                    imageView.isHidden = false
                }
                else{
                    editButton.isHidden = true
                    imageView.isHidden = true

                }
                titleLabel.text = "Students List".localiz()
                studentNumberLabel.text = "\(filteredStudentList.count) \("students".localiz())"
                cell?.selectionStyle = .none
                return cell?.contentView
            }else{
                return UIView()
            }
       
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch user.userType{
        case 1,2:
            switch section{
            case 2:
                return 60
            default:
                return 0.01
            }
        default:
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch user.userType{
        case 1,2:
            return 100
        default:
            switch indexPath.section{
            case 0:
                return 250
            default:
                return 100
            }
        }
    }
    
    
    /// Description:
    /// - Setup pie chart view.
    func setup(pieChartView chartView: PieChartView) {
        chartView.usePercentValuesEnabled = false
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.75
        chartView.transparentCircleRadiusPercent = 0
        chartView.chartDescription?.enabled = false
        chartView.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0)
        chartView.drawCenterTextEnabled = false
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 0
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.maxAngle = 360
        chartView.centerAttributedText = nil
        
        chartView.legend.enabled = false
        
        let count = 3
        let entries = (0..<count).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            return PieChartDataEntry(value: self.percentage[i],
                                     label: "")
        }
        
        let set = PieChartDataSet(values: entries, label: nil)
        set.sliceSpace = 0
        set.selectionShift = 5
        set.colors = self.chartColors
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .none
        
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
//        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 11)!)
        data.setValueTextColor(.clear)
        
        chartView.data = data
        
        chartView.setNeedsDisplay()
    }
    
    /// Description
    /// - Show next month/week dates inside FSCalendar.
    @objc func calendarNextButtonPressed(){
        guard let calendarView = attendanceTableView.viewWithTag(4) as? FSCalendar else{
            return
        }
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: self.languageId )
        var dateComponents = DateComponents()
        if calendarView.scope == .month{
            dateComponents.month = 1
        }else{
            dateComponents.weekOfMonth = 1
        }
        let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage)
        calendarView.setCurrentPage(currentCalendarPage!, animated: true)
    }
    
    /// Description
    /// - Show previous month/week dates inside FSCalendar.
    @objc func calendarPreviousButtonPressed(){
        guard let calendarView = attendanceTableView.viewWithTag(4) as? FSCalendar else{
            return
        }
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: self.languageId )
        var dateComponents = DateComponents()
        if calendarView.scope == .month{
            dateComponents.month = -1 // For prev button
        }else{
            dateComponents.weekOfMonth = -1
        }
        let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage)
        calendarView.setCurrentPage(currentCalendarPage!, animated: true)
    }
    
    @objc func verifyPressed(_ sender: UIGestureRecognizer){
        print("verify pressed")
        let touch = sender.location(in: self.attendanceTableView)
        if let indexPath = self.attendanceTableView.indexPathForRow(at: touch) {
            let absence = self.attendanceArray.filter({$0.type == "absent"}).first
            if let absenceVerify = absence?.details.filter({$0.verified == false}){
                let id = absenceVerify[indexPath.row - 2].id
                self.requestDelegate?.verifyAbsence(percentageArray: self.percentage, colorArray: self.chartColors, user: self.user, id: id)
//                self.requestLeaveContainerView.isHidden = false
            }
        }
    }
    
    
    /// Description:
    /// - Call timeTableData function in Attendance timeTable page
    @objc func requestButtonPressed(){
        self.timeTableDelegate?.timeTableData(user: self.user, children: self.child, subjectTheme: self.appTheme.subjectTheme, date: self.selectCalendarDate)
        self.timeTableContainerView.isHidden = false
    }
    
    
    /// Description:
    /// - Reload section students attendance when date has changed.
    @objc func teacherBackButtonPressed(sender: UIButton){
        guard let cell = sender.superview?.superview as? UITableViewCell else{ return }
        let titleLabel = cell.viewWithTag(30) as? UILabel
        let chartLabel = attendanceTableView.viewWithTag(10) as? UILabel
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: attendanceDate)
        attendanceDate = previousDate ?? Date()
        let date1 = self.DayFormatter.string(from: attendanceDate)
        let date2 = self.titleDateFormatter.string(from: attendanceDate).uppercased()
        titleLabel?.text = "\(date1) \(date2)"
        chartLabel?.text = "\(date1) \(date2)"
        
//        getSectionAttendance(user: self.user, sectionId: self.currentClass.batchId, date: dateFormatter.string(from: attendanceDate))
        getAttendanceList(user: self.user, sectionId: self.currentClass.batchId, date: dateFormatter.string(from: attendanceDate))
    }
    
    /// Description:
    /// - Reload section students attendance when date has changed.
    @objc func teacherNextButtonPressed(sender: UIButton){
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date(), matchingPolicy: .strict, repeatedTimePolicy: .first, direction: .forward)
        if attendanceDate < date!{
            let cell = sender.superview?.superview as! UITableViewCell
            let titleLabel = cell.viewWithTag(30) as! UILabel
            let chartLabel = attendanceTableView.viewWithTag(10) as! UILabel
            let nextDate = calendar.date(byAdding: .day, value: 1, to: attendanceDate)
            attendanceDate = nextDate ?? Date()
            let date1 = self.DayFormatter.string(from: attendanceDate)
            let date2 = self.titleDateFormatter.string(from: attendanceDate).uppercased()
            titleLabel.text = "\(date1) \(date2)"
            chartLabel.text = "\(date1) \(date2)"
            
//            getSectionAttendance(user: self.user, sectionId: self.currentClass.batchId, date: dateFormatter.string(from: attendanceDate))
            getAttendanceList(user: self.user, sectionId: self.currentClass.batchId, date: dateFormatter.string(from: attendanceDate))
        }
    }
    
    /// Description:
    /// - Called when employee needs to add/remove attendance.
    @objc func attendanceButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        let indexPath = attendanceTableView.indexPath(for: cell)
        if self.user.privileges.contains(App.studentAttendancePrivilege){
            if filteredStudentList[indexPath!.row].status == 1{
                print("student selected: \(filteredStudentList[indexPath!.row])")
                addAbsence(user: self.user, studentUsername: filteredStudentList[indexPath!.row].admissionNo, date: dateFormatter.string(from: attendanceDate), arrayIndex: indexPath!.row, sectionId: filteredStudentList[indexPath!.row].sectionId)
            }else{
                removeAbsence(user: self.user, studentUsername: filteredStudentList[indexPath!.row].admissionNo, date: dateFormatter.string(from: attendanceDate), arrayIndex: indexPath!.row)
            }
//            reloadTableView()
            self.filterAttendance()
        }else{
            App.showMessageAlert(self, title: "", message: "You are not allowed to add/remove absence".localiz(), dismissAfter: 1.5)
        }
    }
    
    
    /// Description:
    /// - Called when employee needs to enable add/remove attendace
    @objc func editButtonPressed(sender: UIButton){
        if self.user.privileges.contains(App.studentAttendancePrivilege){
            teacherEdit = !teacherEdit
            reloadTableView()
        }else{
            App.showMessageAlert(self, title: "", message: "You are not allowed to add/remove absence".localiz(), dismissAfter: 1.5)
        }
    }
    
    func reloadTableView(){
        let currentOffset = attendanceTableView.contentOffset
        UIView.setAnimationsEnabled(false)
        attendanceTableView.reloadData()
        UIView.setAnimationsEnabled(true)
        self.attendanceTableView.setContentOffset(currentOffset, animated: true)
    }
    
}

// MARK: - XLPagerTabStrip Method
// Initialize Attendance module.
extension AttendanceViewController: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Attendance".localiz(), counter: "", image: UIImage(named: "attendance"), backgroundViewColor: App.hexStringToUIColorCst(hex: "#fbb870", alpha: 1.0), id: App.attendanceID)
    }
}


// MARK: - Configure FSCalendar.
extension AttendanceViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCell", for: date, at: position)
        cell.backgroundColor = .clear

        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {

        self.configure(cell: cell, for: date, at: monthPosition)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//        let day = self.DayFormatter.string(from: date)
//        var dayId = 0
//        switch day{
//        case "Mon":
//            dayId = 1
//        case "Tue":
//            dayId = 2
//        case "Wed":
//            dayId = 3
//        case "Thu":
//            dayId = 4
//        case "Fri":
//            dayId = 5
//        case "Sat":
//            dayId = 6
//        case "Sun":
//            dayId = 7
//        default:
//            break
//        }
//        if self.user.userType == 4 && !self.daysId.contains(dayId){
//            App.showMessageAlert(self, title: "", message: "You can not select this day", dismissAfter: 2.0)
//            return false
//        }else{
            if selectCalendarDate == dateFormatter1.string(from: date){
                selectCalendarDate = ""
            }else{
                self.selectCalendarDate = dateFormatter1.string(from: date)
            }
        print("selectCalendarDate: \(selectCalendarDate)")
            self.reloadAttendance()
            return true
//        }
    }
    
    /// Description:
    /// - This function is used to draw colored layer on dates contains an event or more.
    func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let diyCell = (cell as! DIYCalendarCell)
        let dateString = self.dateFormatter.string(from: date)
        // Custom today circle
        //        diyCell.circleImageView.isHidden = !self.gregorian.isDateInToday(date)
        // Configure selection layer
        diyCell.titleLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
        if position == .current {
            
            var selectionType = SelectionType.none
            if self.selectedDate.contains(dateString) {
                let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
                let previousDateString = self.dateFormatter.string(from: previousDate)
                let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
                let nextDateString = self.dateFormatter.string(from: nextDate)
                
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
    
    /// Description:
    /// - This function is used after changing calendar week or month to update date label and attendance details.
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // Setup Calendar Label:
        print("pressed4")

        let calendarMonthLabel = self.attendanceTableView.viewWithTag(3) as! UILabel
        configureCalendarLabel(calendar: calendar, calendarMonthLabel: calendarMonthLabel, cellIndex: 1)
        
        SectionVC.didLoadAttandance = false
        self.getAttandanceAPI()
//        self.reloadAttendance()
    }
    
    /// Description: This function is used to configure date label attributed text.
    ///
    /// - Parameters:
    ///   - calendar: FSCalendar.
    ///   - calendarMonthLabel: Label that we need to configure it.
    ///   - cellIndex: Label cell index 0 or 1.
    func configureCalendarLabel(calendar: FSCalendar, calendarMonthLabel: UILabel, cellIndex: Int){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            var currentCalendar = Calendar.current
            currentCalendar.locale = Locale(identifier: self.languageId )
            let values = currentCalendar.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendar.currentPage)
            let month = values.month
            let year = values.year
            let stringMonth = currentCalendar.monthSymbols[month! - 1]
//            var dateArray = [Date]()
//            for cell in calendar.visibleCells(){
//                dateArray.append(calendar.date(for: cell)!)
//            }
            
//            if dateArray != []{
//                let firstDateString = self.dateFormatter2.string(from: dateArray.min()!)
//                let lastDateString = self.dateFormatter2.string(from: dateArray.max()!)
//                let firstDate = firstDateString.split(separator: "-").first
//                let lastDate = lastDateString.split(separator: "-").first
//                if calendar.scope == .month{
            if Locale.current.languageCode == "hy" {
                calendarMonthLabel.text = "\(App.getArmenianMonth(month: month!)) \(year!)"
            }else{
                calendarMonthLabel.text = "\(stringMonth) \(year!)"
            }
            
//            calendarMonthLabel.text = "\(stringMonth) \(year!)"
            
//                }else{
//                    calendarMonthLabel.text = "\(firstDate ?? "") - \(lastDate ?? "")\n\(stringMonth) \(year!)"
//                    calendarMonthLabel.text = "\(stringMonth) \(year!)"
//                    let text = calendarMonthLabel.text!
//                    let attributesText = NSMutableAttributedString(string: text)
//                    let noUserText = (text as NSString).range(of: "\(firstDate ?? "") - \(lastDate ?? "")")
//                    let noUserText = (text as NSString).range(of: "Week of".localiz())
//                    attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 17)!], range: noUserText)
//                    let helpText = (text as NSString).range(of: "\(stringMonth) \(year!)")
//                    attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 15)!], range: helpText)
//                    calendarMonthLabel.attributedText = attributesText
//                }
//            }
//            if cellIndex != 0{
//                let presenceMonthLabel = self.attendanceTableView.viewWithTag(10) as! UILabel
//                presenceMonthLabel.text = "\("Month of ".localiz())\(stringMonth)"
//                let text = presenceMonthLabel.text!
//                let attributesText = NSMutableAttributedString(string: text)
//                let noUserText = (text as NSString).range(of: "Month of ".localiz())
//                attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 14)!], range: noUserText)
//                let helpText = (text as NSString).range(of: "\(stringMonth)")
//                attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 14)!], range: helpText)
//                presenceMonthLabel.attributedText = attributesText
//            }
        }
    }
    
}


// MARK: - Handle delegate functions from attendance timeTable page and  request leave page:
extension AttendanceViewController: AttendanceRequestLeaveViewControllerDelegate, attendanceTimeTableDelegate{
    
    /// Description:
    /// - This function is called from request leave page to dismiss request view when parent finish submitting a leave request.
    func reasonDismiss(submitted: Bool) {
        self.requestLeaveContainerView.isHidden = true
        self.timeTableContainerView.isHidden = submitted
        SectionVC.didLoadAttandance = false
        self.getAttandanceAPI()
    }
    
    
    /// Description:
    /// - This function is called from timeTable page.
    func timeTableDismiss() {
        self.timeTableContainerView.isHidden = true
    }
    
    
    /// Description:
    /// - This function is called when user press on request leave button from request leave page.
    func submitRequestLeave(fullDay: Bool, selectedPeriods: [Period], startDate: String, endDate: String) {
        self.requestDelegate?.requestLeave(percentageArray: self.percentage, colorArray: self.chartColors, user: self.user, fullDay: fullDay, selectedPeriods: selectedPeriods, date: self.dateFormatter.string(from: self.dateFormatter1.date(from: self.selectCalendarDate) ?? Date()), startDate: startDate, endDate: endDate)
        self.requestLeaveContainerView.isHidden = false
        self.timeTableContainerView.isHidden = true
    }
    
    
    /// Description:
    ///
    /// - Parameter days: init dayId variable from attendance timeTable page
    func daysID(days: [Int]) {
        self.daysId = days
    }
}


// MARK: - Handle Section page delegate functions.
extension AttendanceViewController: SectionVCToAttendanceDelegate{
    
    /// Description:
    ///
    /// - Parameter type: selected menu index.
    /// - This function is called when user select an item from option menu to reload attendance data.
    func attendanceFilterSectionView(type: Int) {
        switch self.user.userType{
    
        case 1,2:
            switch type{
            // Absent Students:
            case 0:
                filterAttendanceView = .absent
            // Present Students:
            case 1:
                filterAttendanceView = .present
            // Late Students:
            case 2:
                filterAttendanceView = .late
            default:
                filterAttendanceView = .none
        }
            self.filterAttendance()
        default://student
            if let calendarView = attendanceTableView.viewWithTag(4) as? FSCalendar{
                self.attendanceTableView.isHidden = false
                
                let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
                let monthLabel = attendanceTableView.viewWithTag(3) as! UILabel
                self.startDate = "01-09-1900"
                self.endDate = "30-09-2500"
//                self.attendanceTableView.isHidden = true
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
                    monthLabel.text = "\n"
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
                SectionVC.didLoadAttandance = false
                self.getAttandanceAPI()
            }
        }
    }
    
    
    /// Description:
    ///
    /// - Parameters:
    ///   - batchId: In case the user is parent batch well be nil.
    ///   - children: In case the user is employee children will be nil.
    /// - This function is called from Section page when user changed.
    func switchAttendanceChildren(user: User, classObject: Class?, children: Children?) {
        self.user = user
        if self.attendanceTableView != nil{
            self.timeTableContainerView.isHidden = true
            self.requestLeaveContainerView.isHidden = true
            switch self.user.userType{
            case 1,2:
                self.currentClass = classObject
                if (self.user.userType == 2 || self.user.userType == 1) && !self.user.privileges.contains("student_attendance_view_privilege"){
                    App.showMessageAlert(self, title: "", message: "You do not have the required privilegs to view or interact with this module. for more details please contact your school management".localiz(), dismissAfter: 3.0)
                        self.attendanceDelegate?.backToCalendar()
                    return
                }
            case 4:
                self.child = children
                if !self.selectCalendarDate.isEmpty{
                 self.timeTableDelegate?.timeTableData(user: self.user, children: self.child, subjectTheme: self.appTheme.subjectTheme, date: self.selectCalendarDate)
                }
                
                self.view.superview?.superview?.insertSubview(self.loading, at: 1)
//                self.attendanceTableView.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    switch self.calendarStyle{
                    case .week?:
                        self.attendanceFilterSectionView(type: 1)
                        return
                    default:
                        self.attendanceFilterSectionView(type: 0)
                        return
                    }
                }
            default:
                break
            }
            self.attendanceTableView.reloadData()
            SectionVC.didLoadAttandance = false
            self.getAttandanceAPI()
        }
    }
    
    /// Description:
    /// - This function is called from Section page when class changed.
    func attendanceBatchId(batchId: Int) {
//        SectionVC.didLoadAttandance = false
        if attendanceTableView != nil{
                self.currentClass.batchId = batchId
                getAttandanceAPI()
            
            
        }
    }
    
    /// Description:
    /// - This function is called from Section page when colors and icons changed.
    func updateAttendanceTheme(appTheme: AppTheme) {
        self.appTheme = appTheme
//        if self.attendanceTableView != nil{
//            if self.appTheme.activeModule.contains(where: {$0.id == App.attendanceID && $0.status == 1}){
//                SectionVC.didLoadAttandance = false
//                self.getAttandanceAPI()
//                if self.user.userType == 4{
//                    if !self.selectCalendarDate.isEmpty{
//                        self.timeTableDelegate?.timeTableData(user: self.user, children: self.child, subjectTheme: self.appTheme.subjectTheme, date: self.selectCalendarDate)
//                    }
//                }
//            }else{
//                attendanceDelegate?.backToCalendar()
//            }
//        }
    }
    
}

// MARK: - API Calls:
extension AttendanceViewController{
    
    /// Description:
    /// - This Call "get_student_absences" API to get user attendace data.
    func getAttendance(user: User, studentUsername: String, startDate: String, endDate: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.getAttendance(user: user, studentUsername: studentUsername, startDate: startDate, endDate: endDate) { (message, attendanceData, status) in
            if status == 200{
                SectionVC.didLoadAttandance = true
                print("attendance: \(attendanceData!)")
                self.attendanceArray = attendanceData!
                self.reloadAttendance()
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.attendanceTableView.isHidden = false
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            self.refreshControl.endRefreshing()
        }
    }
    
    
    /// Description: Teacher Section Attendance
    /// - This call "get_section_absences" to get attenadnce average for the current section.
    func getSectionAttendance(user: User, sectionId: Int, date: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.getSectionAbsence(user: user, sectionId: sectionId, date: date) { (message, attendanceData, status) in
            if status == 200{
                SectionVC.didLoadAttandance = true
                self.attendanceArray = attendanceData!
                self.reloadAttendance()
            }
            else if status != 401{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: { (UIAlertAction) in
                    self.attendanceDelegate?.backToCalendar()
                })
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.attendanceTableView.isHidden = false
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            self.refreshControl.endRefreshing()
        }
    }
    
    /// Description: Get student List
    /// - This call "get_section_students" API to get selected sections students for employee users.
    func getAttendanceList(user: User, sectionId: Int, date: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.getAttendanceList(user: user, sectionId: sectionId, date: date) { (message, studentListData, perc, status) in
            if status == 200{
                SectionVC.didLoadAttandance = true
                self.studentList = studentListData!
                self.filteredStudentList = self.studentList
                self.teacherEdit = false
                self.attendanceArray = perc!
                self.reloadAttendance()
                self.attendanceTableView.reloadData()
            }
            else if status != 401{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.attendanceTableView.isHidden = false
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            self.refreshControl.endRefreshing()
        }
    }
    
    /// Description: Add Absence
    /// - Call "add_absence" API to add mark student as absent.
    func addAbsence(user: User, studentUsername: String, date:String, arrayIndex: Int, sectionId: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.addAbsence(user: user, studentUsername: studentUsername, date: date, sectionId: sectionId) { (message, data, status) in
            if status == 200{
                self.filteredStudentList[arrayIndex].status = 2
                for (index,student) in self.studentList.enumerated(){
                    if student.admissionNo == self.filteredStudentList[arrayIndex].admissionNo{
                        self.studentList[index].status = 2
                    }
                }
                self.getAttendanceList(user: self.user, sectionId: self.currentClass.batchId, date: self.dateFormatter.string(from: self.attendanceDate))
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Alert".localiz(), message: message ?? "", actions: [ok])
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
    /// Description: remove Absence
    /// - Call "remove_absence" API to add mark student as present.
    func removeAbsence(user: User, studentUsername: String, date:String, arrayIndex: Int){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.removeAbsence(user: user, studentUsername: studentUsername, date: date) { (message, data, status) in
            if status == 200{
                self.filteredStudentList[arrayIndex].status = 1
                for (index,student) in self.studentList.enumerated(){
                    if student.admissionNo == self.filteredStudentList[arrayIndex].admissionNo{
                        self.studentList[index].status = 1
                    }
                }
                self.getAttendanceList(user: self.user, sectionId: self.currentClass.batchId, date: self.dateFormatter.string(from: self.attendanceDate))
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Alert".localiz(), message: message ?? "", actions: [ok])
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
}





