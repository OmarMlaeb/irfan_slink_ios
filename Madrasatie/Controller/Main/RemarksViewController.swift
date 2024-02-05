//
//  RemarksViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/19/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
//import FSCalendar
import ActionSheetPicker_3_0
import SwipeCellKit

// Description:
/// - Delegate from Remarks page to Section page.
protocol RemarksViewControllerDelegate{
    func remarks(calendarType: CalendarStyle?)
    func remarksToCalendar()
    func goToRemarks()
}

class RemarksViewController: UIViewController {

    @IBOutlet weak var remarksTableView: UITableView!
    
    var remarksDelegate: RemarksViewControllerDelegate?
    var fillDefaultColors: [String: [UIColor]] = [:]
    var remarks: [Remark] = []
    var filteredRemarks: [Remark] = []
    var weekRemarks: [Remark] = []
    var teacherEvents: [Subject] = []
    var remarksDetails: [RemarkDetail] = []
    var currentDate = ""
    var eventTitle = "Remarks"
    var selectedDate: [String] = []
//    var startDate = "01-09-1900"
//    var endDate = "30-09-2500"
    var calendarStyle: CalendarStyle? = .week
    var tempCalendarStyle: CalendarStyle? = .week
    
    var user: User!
    var child: Children!
    var batchId: Int!
    var className: String!
    var teacherEdit = false
    var classObject: Class!
    var type = 0
    var selectCalendarDate = ""
    var allRemarks = Remark(id: 1, icon: "", color: "", counter: "", Title: "", remarkDetail: [])
    var createRemark = CreateRemark.init(students: [], subject: "", remarkText: "", id: 0)
    var categories: [RemarkCategory] = []
    var remarkList: [RemarkList] = []
    var remarkTheme: RemarkTheme!
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    var canRefresh = true
    var refreshControl = UIRefreshControl()
    var overrideDate = ""
    var tickPressed = false
    
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
    
    fileprivate lazy var dateFormatter11: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter11Locale: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: self.languageId )
        return formatter
    }()
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localiz())
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        remarksTableView.addSubview(refreshControl) // not required when using UITableViewController

        remarksTableView.delegate = self
        remarksTableView.dataSource = self
    }
    
    @objc func refresh() {
       // Code to refresh table view
        SectionVC.didLoadRemarks = false
        self.getRemarkData()
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
    /// - Call remarks function inside Sections page to update active section id.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.calendarStyle = .week
        self.tempCalendarStyle = .week
        remarksDelegate?.remarks(calendarType: self.calendarStyle)
        if classObject != nil{
            if classObject.batchId == 0 && self.user.userType == 2 && !self.user.classes.isEmpty{
                classObject = self.user.classes.first!
            }
        }else{
            if user.userType == 2 && !self.user.classes.isEmpty{
                classObject = self.user.classes.first!
            }
        }
    }
    
    /// Description:
    /// - Set calendar default scope to weekly view.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.createRemark.students.isEmpty {
            self.remarksTableView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                guard let calendarView = self.remarksTableView.viewWithTag(4) as? FSCalendar  else{
                   return
               }
                let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
                let monthLabel = self.remarksTableView.viewWithTag(3) as! UILabel
                
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
//                monthLabel.text = "\(stringMonth) \(values.year!)"
                
                if self.calendarStyle == .week{
                    calendarView.setScope(.week, animated: false)
                    calendarHeight?.constant = 90
                }else{
                    calendarView.setScope(.month, animated: false)
                }
                self.remarksTableView.reloadData()
                self.remarksTableView.isHidden = false
                
                //set date if from notification
                if self.overrideDate != ""{
                    let goToDate = self.ddateFormatter.date(from: self.overrideDate)
                    calendarView.select(goToDate, scrollToDate: true)
                }
                
                self.getRemarkData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Description:
    /// - Used to group and format events dates with their colors and event details in case the calendar view is weekly and monthly.
    func initializeCalendarDates(){
        var datesArray: [CalendarDate] = []
        let calendarView = remarksTableView?.viewWithTag(4) as? FSCalendar
        for remark in remarks{
            for detail in remark.remarkDetail{
                let date = CalendarDate(date: detail.date, color: detail.iconColor)
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
        
        if self.currentDate != ""{
            self.remarksDetails = []
            for remark in self.remarks{
                for detail in remark.remarkDetail{
                    if detail.date == self.currentDate{
                        self.remarksDetails.append(detail)
                    }
                }
            }
            self.filteredRemarks = Array(Set(self.filteredRemarks))
            
            self.eventTitle = self.currentDate
            self.currentDate = ""
        }else{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.filteredRemarks = []
                self.remarksDetails = []
                for remark in self.remarks{
                    for detail in remark.remarkDetail{
                        self.filteredRemarks.append(remark)
                        self.remarksDetails.append(detail)
                    }
                }
                self.filteredRemarks = Array(Set(self.filteredRemarks))
                
                if calendarView!.scope == .week{
                    self.calendarStyle = .week
                    self.eventTitle = "Remarks".localiz()
                    self.currentDate = ""
                }
                self.remarksTableView.reloadData()
                return
            }
        }
        self.remarksTableView.reloadData()
    }
    

}

// MARK: - XLPagerTabStrip Method:
// Initialize agenda module.
// Handle Students page Delegate function.
extension RemarksViewController: IndicatorInfoProvider, StudentsViewControllerDelegate{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Remarks".localiz(), counter: "", image: UIImage(named: "remarks"), backgroundViewColor: App.hexStringToUIColorCst(hex: "#a171ff", alpha: 1.0), id: App.remarksID)
    }
    
    /// Description:
    /// - Due to library limitation function goToRemarks inside Sections page is called to reopen Remarks page after dismiss Students page.
    func selectedStudents(students: [Student], std: String, parents: [Student]) {
        print("selected students")
        self.createRemark.students = students
        self.remarksTableView.reloadData()
        self.remarksDelegate?.goToRemarks()
    }
}

// MARK: - UITableView Delegate and DataSource Functions:
// - SwipeTableView Delegate Functions:
extension RemarksViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0,1:
            return 1
        default:
            switch user.userType{
            case 2:
                if teacherEdit{
                    return 4
                }
                return remarksDetails.count
            default:
                return remarksDetails.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let calendarCell = remarksTableView.dequeueReusableCell(withIdentifier: "calendarReuse")
            let calendarBackButton = calendarCell?.viewWithTag(1) as! UIButton
            
            calendarBackButton.dropCircleShadow()
            calendarBackButton.addTarget(self, action: #selector(calendarBackButtonPressed), for: .touchUpInside)
            
            let calendarNextButton = calendarCell?.viewWithTag(6) as! UIButton
            calendarNextButton.dropCircleShadow()
            calendarNextButton.addTarget(self, action: #selector(calendarNextButtonPressed), for: .touchUpInside)
            
            let monthLabel = calendarCell?.viewWithTag(3) as! UILabel
            guard let calendarView = calendarCell?.viewWithTag(4) as? FSCalendar  else{
               return UITableViewCell()
           }
//            calendarView.bottomBorder.isHidden = true
            let calendarNextImageView = calendarCell?.viewWithTag(61) as! UIImageView
            let calendarBackImageView = calendarCell?.viewWithTag(99) as! UIImageView
            if self.languageId == "ar"{
                calendarNextImageView.image = UIImage(named: "calendar-left-arrow")
                calendarBackImageView.image = UIImage(named: "calendar-right-arrow")
            }else{
                calendarNextImageView.image = UIImage(named: "calendar-right-arrow")
                calendarBackImageView.image = UIImage(named: "calendar-left-arrow")
            }
            
//            calendarView.calendarWeekdayView.addBorders(edges: .bottom)
            calendarView.calendarWeekdayView.addBorders(edges: .bottom)
            calendarView.delegate = self
            calendarView.dataSource = self
            calendarView.locale = Locale(identifier: self.languageId )
            calendarView.register(DIYCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
            calendarView.reloadData()
            
            // Setup Calendar Label:
//            setupCalendarLabel(monthLabel: monthLabel, calendarView: calendarView, type: 1)
            let bottomShadowView: UIView? = calendarCell?.viewWithTag(7)
            bottomShadowView?.dropTopShadow()
            calendarCell?.selectionStyle = .none
            return calendarCell!
            
        case 1:
            let remarksCell = remarksTableView.dequeueReusableCell(withIdentifier: "eventsReuse")
            let monthLabel = remarksCell?.viewWithTag(11) as! UILabel
            let addImageView = remarksCell?.viewWithTag(600) as! UIImageView
            let xImageView = remarksCell?.viewWithTag(6001) as! UIImageView
            let addLabel = remarksCell?.viewWithTag(601) as! UILabel
            let addButton = remarksCell?.viewWithTag(602) as! UIButton
            
            addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
            
            switch user.userType{
            case 2:
                addImageView.isHidden = false
                addLabel.isHidden = false
                addButton.isHidden = false
            default:
                addImageView.isHidden = true
                addLabel.isHidden = true
                addButton.isHidden = true
            }
            
            if teacherEdit{
                monthLabel.text = "Choose type".localiz()
                addLabel.text = "Cancel".localiz()
                addImageView.image = UIImage(named: "cancel")
                xImageView.isHidden = false
            }else{
                addLabel.text = "Add".localiz()
                addImageView.image = UIImage(named: "add-school")
                xImageView.isHidden = true
                
                //Get Calendar Month:
                guard let calendarView = remarksTableView.viewWithTag(4) as? FSCalendar else{
                    return UITableViewCell()
                }
                var currentCalendar = Calendar.current
                currentCalendar.locale = Locale(identifier: self.languageId )
                let values = currentCalendar.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.currentPage)
                let month = values.month
                let stringMonth = currentCalendar.monthSymbols[(month ?? 1) - 1]
//                monthLabel.text = stringMonth
                let text = monthLabel.text!
                let attributesText = NSMutableAttributedString(string: text)
                let noUserText = (text as NSString).range(of: "Month of ".localiz())
                attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 14)!], range: noUserText)
                let helpText = (text as NSString).range(of: "\(stringMonth)")
                attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 14)!], range: helpText)
//                monthLabel.attributedText = attributesText
            }
            
            
            let bottomShadowView: UIView? = remarksCell?.viewWithTag(16)
            bottomShadowView?.dropShadow()
            let remarksCollectionView = remarksCell?.viewWithTag(12) as! UICollectionView
            remarksCollectionView.delegate = self
            remarksCollectionView.dataSource = self
            remarksCollectionView.reloadData()
            remarksCell?.selectionStyle = .none
            return remarksCell!
            
        default:
            if teacherEdit{
                switch indexPath.row{
                case 0:
                    let cell = remarksTableView.dequeueReusableCell(withIdentifier: "remarkReuse")
                    let _ = cell?.viewWithTag(510) as! UITextField
                    let remarkButton = cell?.viewWithTag(511) as! UIButton
                    remarkButton.addTarget(self, action: #selector(remarkButtonPressed), for: .touchUpInside)
                    cell?.selectionStyle = .none
                    return cell!
                case 1:
                    let cell = remarksTableView.dequeueReusableCell(withIdentifier: "chooseStudentsReuse")
                    let label = cell?.viewWithTag(515) as! UILabel
                    let arrowImageView = cell?.viewWithTag(716) as! UIImageView
                    if self.languageId == "ar"{
                        arrowImageView.image = UIImage(named: "remarksArrow-ar")
                    }else{
                        arrowImageView.image = UIImage(named: "remarksArrow")
                    }
                    label.text = "Choose student".localiz()
                    cell?.selectionStyle = .none
                    return cell!
                case 2:
                    let cell = remarksTableView.dequeueReusableCell(withIdentifier: "studentReuse")
                    let studentsLabel = cell?.viewWithTag(333) as! UILabel
                    studentsLabel.text = ""
                    for (index,student) in createRemark.students.enumerated(){
                        if index == 0{
                            studentsLabel.text?.append(student.fullName)
                        }else{
                            studentsLabel.text?.append("\n")
                            studentsLabel.text?.append(student.fullName)
                        }
                    }
                    cell?.selectionStyle = .none
                    return cell!
                default:
                    let cell = remarksTableView.dequeueReusableCell(withIdentifier: "saveReuse")
                    let saveButton = cell?.viewWithTag(99) as! UIButton
                    saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
                    cell?.selectionStyle = .none
                    return cell!
                }
            }else{
                let cell = remarksTableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse") as? RemarkTableViewCell
                cell?.tickButton.addTarget(self, action: #selector(tickButtonPressed), for: .touchUpInside)
                
                let remark = self.remarksDetails[indexPath.row]
                let date = self.dateFormatter1.date(from: remark.date)
                cell?.dateLabel.text = self.dateFormatter11Locale.string(from: date ?? Date())
                cell?.descriptionView?.backgroundColor = App.hexStringToUIColor(hex: remark.backgroundColor, alpha: 0.5)
                cell?.descriptionView?.layer.masksToBounds = true
                cell?.descriptionView?.layer.cornerRadius = 8
                if user.userType == 2{
                    cell?.signatureLabel.text = "\(remark.studentName)"
                    cell?.tickView?.isHidden = true
                    cell?.topView?.isHidden = true
                    cell?.bottomView?.isHidden = true
                    cell?.tickImage.isHidden = true
                }else{
                    cell?.signatureLabel.text = "\(remark.tutorName) - \(remark.subject)"
                    cell?.tickView?.isHidden = false
                    cell?.topView?.isHidden = false
                    cell?.bottomView?.isHidden = false
                    cell?.tickImage.isHidden = false
                }
                cell?.titleLabel.text = remark.title
                cell?.descriptionLabel.text = remark.description
                cell?.iconView?.backgroundColor = App.hexStringToUIColor(hex: remark.iconColor, alpha: 1.0)
                cell?.iconView?.layer.masksToBounds = true
                cell?.iconView?.layer.cornerRadius = cell!.iconView!.frame.width / 2
                cell?.iconView?.layer.borderWidth = 3
                cell?.iconView?.layer.borderColor = UIColor.white.cgColor
                cell?.iconImageView.image = UIImage(named: remark.image)
                cell?.topView?.backgroundColor = App.hexStringToUIColorCst(hex: "#808285", alpha: 1.0)
                cell?.bottomView?.backgroundColor = App.hexStringToUIColorCst(hex: "#808285", alpha: 1.0)
                cell?.tickView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#808285", alpha: 1.0).cgColor
                cell?.tickView?.layer.masksToBounds = true
                cell?.tickView?.layer.cornerRadius = cell!.tickView!.frame.width / 2
                if indexPath.row == 0 || user.userType == 2{
                    cell?.topView?.isHidden = true
                }else{
                    cell?.topView?.isHidden = false
                }
                if indexPath.row == self.remarksDetails.count - 1 || user.userType == 2{
                    cell?.bottomView?.isHidden = true
                }else{
                    cell?.bottomView?.isHidden = false
                }
                cell?.tickImage.image = UIImage(named: "tick")
                if remark.ticked{
                    cell?.tickView?.backgroundColor = App.hexStringToUIColor(hex: remark.iconColor, alpha: 1.0)
                    cell?.tickView?.layer.borderWidth = 0
                    cell?.tickImage.isHidden = false
                }else{
                    cell?.tickView?.backgroundColor = .white
                    cell?.tickView?.layer.borderWidth = 1
                    cell?.tickImage.isHidden = true
                }
                
                cell?.selectionStyle = .none
                cell?.delegate = self
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 && indexPath.row == 1 && teacherEdit{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentsViewController") as! StudentsViewController
            studentVC.delegate = self
            studentVC.user = self.user
            studentVC.sectionId = "\(self.classObject.batchId)"
            studentVC.modalPresentationStyle = .fullScreen
            self.present(studentVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let teacherHeader = remarksTableView.dequeueReusableCell(withIdentifier: "teacherHeaderReuse")
        let teacherHeadertitle = teacherHeader?.viewWithTag(500) as! UILabel
        let header = remarksTableView.dequeueReusableCell(withIdentifier: "headerReuse")
        let headerTitle = header?.viewWithTag(30) as! UILabel
        switch section{
        case 0,1:
            return UIView()
        default:
            if teacherEdit{
                teacherHeadertitle.text = "Choose Remark".localiz()
            }
            if let date = self.dateFormatter1.date(from: self.eventTitle){
                headerTitle.text = self.dateFormatter11Locale.string(from: date)
            }else{
                headerTitle.text = self.eventTitle
            }
        }
        header?.contentView.backgroundColor = .white
        teacherHeader?.contentView.backgroundColor = .white
        if teacherEdit{
            return teacherHeader?.contentView
        }
        return header?.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section{
        case 0,1:
            return 0
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
        case 0:
            if calendarStyle == .week{
                return 166
            }
            return 326
        case 1:
            return 148
        default:
            return 136
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// - SwipeTableViewCellDelegate:
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
            let remark = self.remarksDetails[indexPath.row]
            self.removeRemark(user: self.user, remarkId: remark.id)
        }
        deleteAction.backgroundColor = .white
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-x")!.scaleImage(scaledToSize: CGSize(width: 44, height: 44))
        if self.user.userType == 2{
            return [deleteAction]
        }else{
            return nil
        }
    }
    
    /// Description
    /// - Show previous month/week dates inside FSCalendar.
    @objc func calendarBackButtonPressed(sender: UIButton){
        self.tickPressed = false

        guard let calendarView = remarksTableView.viewWithTag(4) as? FSCalendar else{
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
        let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage) ?? Date()
        calendarView.setCurrentPage(currentCalendarPage, animated: true)
    }
    
    /// Description
    /// - Show next month/week dates inside FSCalendar.
    @objc func calendarNextButtonPressed(sender: UIButton){
        self.tickPressed = false

        guard let calendarView = remarksTableView.viewWithTag(4) as? FSCalendar else{
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
        let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage) ?? Date()
        calendarView.setCurrentPage(currentCalendarPage, animated: true)
    }
    
    /// Description:
    /// - Used to mark remark as seen or not.
    @objc func tickButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        if let indexPath = remarksTableView.indexPath(for: cell) {
            let remark = self.remarksDetails[indexPath.row]
            
            
            switch self.user.userType{
            case 3:
                if remark.ticked{
                    unCheckRemark(user: self.user, studentUsername: self.user.userName, id: remark.id)
                }else{
                    checkRemark(user: self.user, studentUsername: self.user.userName, id: remark.id)
                }
            case 4:
                if remark.ticked{
                    unCheckRemark(user: self.user, studentUsername: self.user.admissionNo, id: remark.id)
                }else{
                    checkRemark(user: self.user, studentUsername: self.user.admissionNo, id: remark.id)
                }
            default:
                break
            }
        }
    }
    
    @objc func remarkButtonPressed(sender: UIButton){
        let remarkField = remarksTableView.viewWithTag(510) as! UITextField
        ActionSheetStringPicker.show(withTitle: "Select Remark".localiz(), rows: self.remarkList.map({return $0.text}), initialSelection: 0, doneBlock: {
            picker, ind, values in
            
            if self.remarkList.isEmpty{
                remarkField.text = ""
                return
            }
            remarkField.text = self.remarkList[ind].text
            self.createRemark.remarkText = self.remarkList[ind].text
            self.createRemark.id = self.remarkList[ind].id
            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    @objc func addButtonPressed(sender: UIButton){
        if selectCalendarDate.isEmpty{
            App.showMessageAlert(self, title: "", message: "You need to select a day from the calendar".localiz(), dismissAfter: 1.5)
        }else{
            if teacherEdit {
                self.teacherEdit = false
                self.createRemark.students.removeAll()
                //remove remark
                let textfield = self.remarksTableView.viewWithTag(510) as! UITextField
                textfield.text = ""
            }else{
                self.teacherEdit = true
            }
            self.remarksTableView.reloadData()
        }
    }
    
    @objc func saveButtonPressed(sender: UIButton){
        let subject = self.categories.filter({$0.id == self.type}).first?.name
        self.createRemark.subject = subject ?? ""
        guard let date = self.dateFormatter1.date(from: self.selectCalendarDate) else{
            App.showMessageAlert(self, title: "", message: "You need to select a day from the calendar".localiz(), dismissAfter: 1.5)
            return
        }
        if self.createRemark.remarkText == "" {
            App.showMessageAlert(self, title: "", message: "Choose Remark".localiz(), dismissAfter: 1.5)
            return
        }
        if self.createRemark.students.count == 0{
            App.showMessageAlert(self, title: "", message: "Choose student".localiz(), dismissAfter: 1.5)
            return
        }
        let dateString = self.dateFormatter2.string(from: date)
        self.createRemark(user: self.user, remark: self.createRemark, date: dateString)
    }
    
}

// MARK: - UICollectionView Delegate and DataSource Functions:
extension RemarksViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if teacherEdit{
            return self.categories.count
        }else if filteredRemarks.isEmpty{
            return filteredRemarks.count
        }else{
            return filteredRemarks.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventsCell", for: indexPath)
        let remarkIcon = cell.viewWithTag(21) as! UIImageView
        let counterLabel = cell.viewWithTag(22) as! UILabel
        let remarkColorView: UIView? = cell.viewWithTag(24)
        let tickView: UIView? = cell.viewWithTag(25)
        let tickImageView = cell.viewWithTag(26) as! UIImageView
        let titleLabel = cell.viewWithTag(2525) as! UILabel
        var remark: Remark!
        
        remarkColorView?.layer.masksToBounds = false
        remarkColorView!.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
        titleLabel.isHidden = true
        
        if indexPath.row == filteredRemarks.count && !teacherEdit{
            let padding: CGFloat = 0
            let size = CGSize(width: remarkColorView!.frame.size.width - padding, height: remarkColorView!.frame.size.height - padding)
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: CGPoint.zero, size: size)
            gradient.colors = []
            
            gradient.colors?.append(App.hexStringToUIColor(hex: remarkTheme.happyColor, alpha: 1.0).cgColor)
            gradient.colors?.append(App.hexStringToUIColor(hex: remarkTheme.sadColor, alpha: 1.0).cgColor)
            
            gradient.accessibilityValue = "gradient"
            
            remarkColorView!.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
            
            let shape = CAShapeLayer()
            shape.lineWidth = 2
            
            let diameter: CGFloat = min(gradient.frame.height, gradient.frame.width)
            shape.path = UIBezierPath(ovalIn: CGRect(x: remarkColorView!.frame.width / 2 - diameter / 2 + 3, y: remarkColorView!.frame.height / 2 - diameter / 2 + 3, width: diameter - 6, height: diameter - 6)).cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            gradient.mask = shape
            
            remarkColorView!.layer.addSublayer(gradient)
            remarkColorView!.layer.masksToBounds = true
            remarkColorView?.backgroundColor = .white
            
            counterLabel.isHidden = false
            tickView?.isHidden = true
            tickImageView.isHidden = true
            
//            remarkIcon.image = UIImage(named: allRemarks.icon)
            //download icon image
            let icon = allRemarks.icon
            if icon.contains("http"){
                let url = URL(string: icon)
                App.addImageLoader(imageView: remarkIcon, button: nil)
                remarkIcon.sd_setImage(with: url) { (image, error, cache, url) in
                    App.removeImageLoader(imageView: remarkIcon, button: nil)
                }
            }
            
            counterLabel.text = "\(allRemarks.counter)"
            counterLabel.layer.zPosition = 1
        }else{
            switch user.userType{
            case 2:
                tickView?.isHidden = false
                remarkIcon.isHidden = true
                
                if indexPath.row < self.categories.count{
                    let category: RemarkCategory = self.categories[indexPath.row]
                    counterLabel.text = ""
                    if teacherEdit{
                        titleLabel.isHidden = false
                        titleLabel.text = category.name
                        if type == category.id{
                            tickImageView.isHidden = false
                            tickView?.layer.borderWidth = 0
                            tickView?.backgroundColor = App.hexStringToUIColor(hex: category.color, alpha: 1.0)
                        }else{
                            tickImageView.isHidden = true
                            tickView?.backgroundColor = .white
                            tickView?.layer.borderWidth = 1
                            tickView?.layer.borderColor = App.hexStringToUIColorCst(hex: "#808285", alpha: 1.0).cgColor
                        }
                        remarkColorView?.backgroundColor = App.hexStringToUIColor(hex: category.color, alpha: 1.0)
                    }else{
                        remark = self.filteredRemarks[indexPath.row]
                        remarkIcon.isHidden = false
                        counterLabel.text = "\(remark.remarkDetail.count)"
                        tickView?.isHidden = true
                        tickImageView.isHidden = true
                        remarkColorView?.backgroundColor = App.hexStringToUIColor(hex: remark.color, alpha: 1.0)
                    }
                }else{
                    remark = self.filteredRemarks[indexPath.row]
                    remarkIcon.isHidden = false
                    counterLabel.text = "\(remark.remarkDetail.count)"
                    tickView?.isHidden = true
                    tickImageView.isHidden = true
                    remarkColorView?.backgroundColor = App.hexStringToUIColor(hex: remark.color, alpha: 1.0)
                }
            default:
                remark = self.filteredRemarks[indexPath.row]
                remarkIcon.isHidden = false
                remarkIcon.image = UIImage(named: remark.icon)
                counterLabel.text = "\(remark.remarkDetail.count)"
                remarkColorView?.backgroundColor = App.hexStringToUIColor(hex: remark.color, alpha: 1.0)
                tickView?.isHidden = true
                tickImageView.isHidden = true
            }
            
            remarkColorView?.layer.cornerRadius = remarkColorView!.frame.width / 2
            remarkColorView?.dropCircleShadow()
            remarkColorView!.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.tickPressed = false
        if teacherEdit{
            if type != categories[indexPath.row].id{
                guard let remarkField = remarksTableView.viewWithTag(510) as? UITextField else{
                    return
                }
                remarkField.text = ""
                createRemark.remarkText = ""
            }
            type = categories[indexPath.row].id
            createRemark.subject = categories[indexPath.row].name
            self.remarkList = categories[indexPath.row].remarks
//            let currentOffset = remarksTableView.contentOffset
            collectionView.reloadData()
//            UIView.performWithoutAnimation {
//                collectionView.reloadData()
//            }
//            remarksTableView.setContentOffset(currentOffset, animated: false)
        }else if indexPath.row == self.filteredRemarks.count{
            self.remarksDetails = self.allRemarks.remarkDetail
            self.eventTitle = "All Remarks".localiz()
            let currentOffset = remarksTableView.contentOffset
            UIView.setAnimationsEnabled(false)
            remarksTableView.reloadData()
            UIView.setAnimationsEnabled(true)
            remarksTableView.setContentOffset(currentOffset, animated: false)
        }else{
            self.remarksDetails = self.filteredRemarks[indexPath.row].remarkDetail
            self.eventTitle = "Remarks".localiz()
            let currentOffset = remarksTableView.contentOffset
            UIView.setAnimationsEnabled(false)
            remarksTableView.reloadData()
            UIView.setAnimationsEnabled(true)
            remarksTableView.setContentOffset(currentOffset, animated: false)
        }
    }
    
}

// MARK: - FSCalendar Functions:
extension RemarksViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCell", for: date, at: position)
        cell.backgroundColor = .clear
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: monthPosition)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        self.tickPressed = true
        let tomorrow = Date().lastHour
        print("date1: \(tomorrow)")
        print("date2: \(date)")
        if date < tomorrow {
            if teacherEdit{
                return false
            }
            self.currentDate = dateFormatter1.string(from: date)
            print("date3: \(self.currentDate)")
            print("date4: \(selectCalendarDate)")
            if selectCalendarDate == dateFormatter1.string(from: date){
                selectCalendarDate = ""
            }else{
                self.selectCalendarDate = dateFormatter1.string(from: date)
            }
            self.initializeCalendarDates()
            return true
        }else{
            App.showMessageAlert(self, title: "", message: "You can't select a future date".localiz(), dismissAfter: 1.5)
            selectCalendarDate = ""
            return false
        }
    }
    
    /// Description:
    /// - This function is used after changing calendar week or month to update date label and events details.
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // Setup Calendar Label:
        
        let calendarMonthLabel = self.remarksTableView.viewWithTag(3) as! UILabel
        guard let calendarView = self.remarksTableView.viewWithTag(4) as? FSCalendar else{
            return
        }
        setupCalendarLabel(monthLabel: calendarMonthLabel, calendarView: calendarView, type: 2)
        SectionVC.didLoadRemarks = false
        self.getRemarkData()
    }
    
    /// Description: This function is used to configure date label attributed text.
    ///
    /// - Parameters:
    ///   - calendar: FSCalendar.
    ///   - calendarMonthLabel: Label that we need to configure it.
    ///   - cellIndex: Label cell index 0 or 1.
    func setupCalendarLabel(monthLabel: UILabel, calendarView: FSCalendar, type: Int){
        var currentCalendar = Calendar.current
        currentCalendar.locale = Locale(identifier: self.languageId )
        let values = currentCalendar.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.currentPage)
        let month = values.month
        let year = values.year
        let stringMonth = currentCalendar.monthSymbols[month! - 1]
//        var dateArray = [Date]()
//        for cell in calendarView.visibleCells(){
//            if let date = calendarView.date(for: cell){
//                dateArray.append(date)
//            }
//        }
        
//        if !dateArray.isEmpty{
//            if calendarView.scope == .month{
        if Locale.current.languageCode == "hy" {
            monthLabel.text = "\(App.getArmenianMonth(month: month!)) \(year!)"
        }else{
            monthLabel.text = "\(stringMonth) \(year!)"
        }
//                monthLabel.text = "\(stringMonth) \(year ?? 0)"
        
//            }else{
//                monthLabel.text = "\("Week of".localiz())\n\(stringMonth) \(year ?? 0)"
//                let text = monthLabel.text!
//                let attributesText = NSMutableAttributedString(string: text)
//                let noUserText = (text as NSString).range(of: "Week of".localiz())
//                attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 17)!], range: noUserText)
//                let helpText = (text as NSString).range(of: "\(stringMonth) \(year ?? 0)")
//                attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 15)!], range: helpText)
//                monthLabel.attributedText = attributesText
//            }
//        }
//        if type == 2{
//            let eventsMonthLabel = self.remarksTableView.viewWithTag(11) as! UILabel
//            eventsMonthLabel.text = "\("Month of ".localiz())\(stringMonth)"
//            let text = eventsMonthLabel.text!
//            let attributesText = NSMutableAttributedString(string: text)
//            let noUserText = (text as NSString).range(of: "Month of ".localiz())
//            attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 14)!], range: noUserText)
//            let helpText = (text as NSString).range(of: "\(stringMonth)")
//            attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 14)!], range: helpText)
//            eventsMonthLabel.attributedText = attributesText
//        }
    }
    
    /// Description:
    /// - This function is used to draw colored layer on dates contains an event or more.
    func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let diyCell = cell as! DIYCalendarCell
        let dateString: String = self.dateFormatter1.string(from: date)
        diyCell.titleLabel.font = UIFont(name: "OpenSans-Bold", size: 13)
            // Custom today circle
            //        diyCell.circleImageView.isHidden = !self.gregorian.isDateInToday(date)
            // Configure selection layer
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
                            shape.path = UIBezierPath(ovalIn: CGRect(x: diyCell.contentView.frame.width / 2 - diameter / 2 + 1, y: diyCell.contentView.frame.height / 2 - diameter / 2 + 1, width: diameter - 4, height: diameter - 4)).cgPath
                            shape.strokeColor = UIColor.black.cgColor
                            shape.fillColor = UIColor.clear.cgColor
                            gradient.mask = shape
                            
                            diyCell.contentView.layer.addSublayer(gradient)
                            
                        }else{
                            diyCell.contentView.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
                            selectionType = .none
                        }
                        
                        if dateFormatter1.string(from: date) == selectCalendarDate{
                            cell.titleLabel.textColor = App.hexStringToUIColorCst(hex: "#568ef6", alpha: 1.0)
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
                        cell.titleLabel.textColor = App.hexStringToUIColorCst(hex: "#568ef6", alpha: 1.0)
                    }else{
                        cell.titleLabel.textColor = App.hexStringToUIColorCst(hex: "#6d6e71", alpha: 1.0)
                    }
                    return
                }
                diyCell.selectionLayer.isHidden = false
                diyCell.selectionType = selectionType
                
            } else {
                diyCell.selectionLayer.isHidden = true
                diyCell.contentView.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
            }
    }
    
}

// MARK: - Handle Sections page delegate functions:
extension RemarksViewController: SectionVCToRemarksDelegate{
    // Description:
    ///
    /// - Parameter type: selected menu index.
    /// - This function is called when user select an item from option menu to reload Remarks data.
    func remarksFilterSectionView(type: Int) {
        guard let calendarView = remarksTableView.viewWithTag(4) as? FSCalendar else{
            return
        }
        let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
        let monthLabel = remarksTableView.viewWithTag(3) as! UILabel
//        self.startDate = "01-09-1900"
//        self.endDate = "30-09-2500"
        switch type{
        //Monthly View:
        case 0:
            self.calendarStyle = .month
            self.tempCalendarStyle = .month
            calendarView.setScope(.month, animated: true)
            calendarHeight?.constant = 250
//            self.view.superview?.superview?.insertSubview(self.loading, at: 1)
            self.remarksTableView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.remarksTableView.isHidden = false
                SectionVC.didLoadRemarks = false
                self.getRemarkData()
            }
        //Weekly View:
        case 1:
            
            self.calendarStyle = .week
            self.tempCalendarStyle = .week
            calendarView.setScope(.week, animated: true)
            calendarHeight?.constant = 90
            monthLabel.text = "\n"
//            self.view.superview?.superview?.insertSubview(self.loading, at: 1)
            self.remarksTableView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.remarksTableView.isHidden = false
                SectionVC.didLoadRemarks = false
                self.getRemarkData()
            }
        //Yearly View:
        case 2:
            calendarView.setScope(.month, animated: true)
            self.calendarStyle = .month
//            let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.today ?? Date())
//            let month = values.month ?? 0
//            let year = values.year ?? 0
//            if month > 10{
//                self.startDate = "01-09-\(year)"
//                self.endDate = "30-09-\(year+1)"
//            }else{
//                self.startDate = "01-09-\(year-1)"
//                self.endDate = "30-09-\(year)"
//            }
            calendarHeight?.constant = 250
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                SectionVC.didLoadRemarks = false
                self.getRemarkData()
            }
        default:
            break
        }
    }
    
    /// Description:
    ///
    /// - Parameters:
    ///   - batchId: In case the user is parent batch well be nil.
    ///   - children: In case the user is employee children will be nil.
    /// - This function is called from Section page when user changed.
    func switchRemarksChildren(user: User, batchId: Int?, children: Children?) {
        self.user = user
        teacherEdit = false
        self.categories = []
        if remarksTableView != nil{
            switch self.user.userType{
            case 2:
                if batchId == 0 && !self.user.classes.isEmpty{
                    classObject = self.user.classes.first!
                    self.batchId = classObject.batchId
                }else{
                    self.batchId = batchId
                }
            case 4:
                self.child = children
            default:
                break
            }
            
            SectionVC.didLoadRemarks = false
            self.getRemarkData()
        }
    }
    
    /// Description:
    /// - Call and reload remarks data functions.
    /// - Calculate start date and end date.
    func getRemarkData(){
        if SectionVC.didLoadRemarks {
            return
        }
        guard let calendarView = self.remarksTableView.viewWithTag(4) as? FSCalendar else{ return }
        
        var startDate: Date
        let endDate: Date
        if calendarView.scope == .week{
            startDate = calendarView.currentPage
            startDate = calendarView.gregorian.date(byAdding: .day, value: 0, to: startDate)!
            endDate = calendarView.gregorian.date(byAdding: .day, value: 6, to: startDate)!
        }else{
            startDate = calendarView.gregorian.date(byAdding: .day, value: 0, to: calendarView.currentPage)!
            endDate = calendarView.gregorian.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        }
        
        let fromDate = self.dateFormatter.string(from: startDate)
        let toDate = self.dateFormatter.string(from: endDate)
        
        switch self.user.userType{
        case 2:
            var classID = self.classObject.batchId
            if classID == 0 && batchId != nil{
                classID = batchId
            }
            if classID != 0{
                self.viewSectionRemark(user: self.user, startDate: fromDate, endDate: toDate, className: self.classObject.className, batchID: classID)
            }
        case 3:
            self.getRemarks(user: self.user, studentUsername: self.user.userName, startDate: fromDate, endDate: toDate, remarkTheme: remarkTheme)
        case 4:
            self.getRemarks(user: self.user, studentUsername: self.user.admissionNo, startDate: fromDate, endDate: toDate, remarkTheme: remarkTheme)
        default:
            break
        }
    }
    
    /// Description:
    /// - This function is called from Section page when class changed.
    func remarksBatchId(batchId: Int) {
        if self.remarksTableView != nil{
            self.classObject.batchId = batchId
//            SectionVC.didLoadRemarks = false
            self.getRemarkData()
        }
    }
    
    /// Description:
    /// - This function is called from Section page when colors and icons changed.
    func updateRemarkTheme(theme: AppTheme?) {
//        if remarksTableView != nil{
//            if let theme = theme, theme.activeModule.contains(where: {$0.id == App.remarksID && $0.status == 1}){
//                self.remarkTheme = theme.remarkTheme
//                SectionVC.didLoadRemarks = false
//                self.getRemarkData()
//            }else{
//                remarksDelegate?.remarksToCalendar()
//            }
//        }
    }
    
}

// MARK: - API Calls:
extension RemarksViewController{
    /// Description: Get Student Remarks
    /// - Call "get_student_remarks" API to students and parents Remarks data.
    /// - Add All Remarks event.
    func getRemarks(user: User, studentUsername: String, startDate: String, endDate: String, remarkTheme: RemarkTheme){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        self.remarksTableView.isHidden = true
        Request.shared.getRemarks(user: user, studentUsername: studentUsername, startDate: startDate, endDate: endDate, remarkTheme: remarkTheme) { (message, remarksData, status) in
            if status == 200{
                SectionVC.didLoadRemarks = true
                self.remarks = remarksData!
                var allRemarksCount = 0
                var allRemarksDetails: [RemarkDetail] = []
                for remark in self.remarks{
                    allRemarksCount += remark.remarkDetail.count
                    for detail in remark.remarkDetail{
                        allRemarksDetails.append(detail)
                    }
                }
                allRemarksDetails = allRemarksDetails.sorted(by: {self.dateFormatter1.date(from: $0.date) ?? Date() < self.dateFormatter1.date(from: $1.date) ?? Date()})
                self.allRemarks = Remark(id: 1, icon: "empty", color: "", counter: "\(allRemarksCount)", Title: "All Remarks".localiz(), remarkDetail: allRemarksDetails)
                self.remarksDetails = self.allRemarks.remarkDetail
                self.eventTitle = self.allRemarks.Title
                
                if(self.tickPressed){
                let tomorrow = Date().lastHour
                print("date1: \(tomorrow)")
                //print("date2: \(date)")
                    if self.teacherEdit{
                        self.teacherEdit = false
                    }
                    //self.currentDate = dateFormatter1.string(from: date)
                    self.currentDate = self.selectCalendarDate
                    print("date3: \(self.currentDate)")
                    print("date4: \(self.selectCalendarDate)")
                   
                    self.initializeCalendarDates()
                self.tickPressed = false
                
                }
                else{
                    print("entered here2")
                    self.initializeCalendarDates()
                }
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.remarksTableView.reloadData()
            self.remarksTableView.isHidden = false
            
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            self.refreshControl.endRefreshing()
        }
    }
    
    /// Description: Check Remark
    /// - Call "check_remark" to mark remark as checked.
    func checkRemark(user: User, studentUsername: String, id: Int){
        Request.shared.checkRemark(user: user, studentUsername: studentUsername, id: id) { (message, data, status) in
            if status == 200{
                SectionVC.didLoadRemarks = false
                self.getRemarkData()
            }
        }
    }
    
    /// Description: Uncheck Remark
    /// - Call "uncheck_remark" to mark remark as unchecked.
    func unCheckRemark(user: User, studentUsername: String, id: Int){
        Request.shared.UnCheckRemark(user: user, studentUsername: studentUsername, id: id) { (message, data, status) in
            if status == 200{
                SectionVC.didLoadRemarks = false
                self.getRemarkData()
            }
        }
    }
    
    /// Description: View Section Remark
    /// - Call "view_section_remarks" API to get employee Remarks data for the selection section.
    /// - Add All Remarks Event.
    func viewSectionRemark(user: User, startDate: String, endDate: String, className: String, batchID: Int){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        self.remarksTableView.isHidden = true
        Request.shared.viewSectionRemark(user: user, startDate: startDate, endDate: endDate, className: className, batchId: batchID) { (message, remarksData, status) in
            if status == 200{
                SectionVC.didLoadRemarks = true
                self.getRemarksList(user: self.user)
                self.remarks = remarksData!

                var allRemarksCount = 0
                var allRemarksDetails: [RemarkDetail] = []
                for remark in self.remarks{
                    allRemarksCount += remark.remarkDetail.count
                    for detail in remark.remarkDetail{
                        allRemarksDetails.append(detail)
                    }
                }
                allRemarksDetails = allRemarksDetails.sorted(by: {self.dateFormatter1.date(from: $0.date) ?? Date() < self.dateFormatter1.date(from: $1.date) ?? Date()})
                self.allRemarks = Remark(id: 1, icon: "empty", color: "", counter: "\(allRemarksCount)", Title: "All Remarks".localiz(), remarkDetail: allRemarksDetails)
                self.remarksDetails = self.allRemarks.remarkDetail
                self.eventTitle = self.allRemarks.Title

                self.initializeCalendarDates()
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok], controller: nil, isCancellable: true)
            }
            self.remarksTableView.reloadData()
            self.remarksTableView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
                self.refreshControl.endRefreshing()
            })
           
        }
    }
    
    /// Description: Create Remark
    /// - Call "add_remark" API to submit remark data.
    func createRemark(user: User, remark: CreateRemark, date: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        self.remarksDelegate?.goToRemarks()
        Request.shared.addRemark(user: user, remark: remark, date: date) { (message, data, status) in
            if status == 200{
                App.showMessageAlert(self, title: "", message: "Remark Saved!".localiz(), dismissAfter: 1.5)
                self.createRemark = CreateRemark.init(students: [], subject: "", remarkText: "", id: 0)
                let textfield = self.remarksTableView.viewWithTag(510) as! UITextField
                textfield.text = ""
                self.teacherEdit = false
                SectionVC.didLoadRemarks = false
                self.getRemarkData()
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            UIApplication.shared.keyWindow?.viewWithTag(1500)?.removeFromSuperview()
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            self.loading.removeFromSuperview()
        }
    }
    
    /// Description: Get Remark List
    /// - Call "get_remarks_list" API to get ramarks categories data.
    func getRemarksList(user: User){
        Request.shared.getRemarkList(user: user) { (message, data, status) in
            if status == 200{
                self.categories = data!
                if !self.categories.isEmpty && self.type == 0{
                    self.remarkList = self.categories.first!.remarks
                    self.type = self.categories.first!.id
                }
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok], controller: nil, isCancellable: true)
            }
        }
    }
    
    /// Description: Remove Remark
    /// - Call "remove_remark" API to remove as assessment.
    func removeRemark(user: User, remarkId: Int){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.removeRemark(user: user, remarkId: remarkId) { (message, data, status) in
            if status == 200{
                SectionVC.didLoadRemarks = false
                self.getRemarkData()
            }
            else{
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok], controller: nil, isCancellable: true)
            }
            UIApplication.shared.keyWindow?.viewWithTag(1500)?.removeFromSuperview()
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            self.loading.removeFromSuperview()
        }
    }
    
}
