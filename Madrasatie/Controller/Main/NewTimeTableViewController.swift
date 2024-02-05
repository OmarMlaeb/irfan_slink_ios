//
//  NewTimeTableViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 3/5/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit

/// Description:
/// - Delegate from TimeTable page to Section page.
protocol NewTimeTableViewControllerDelegate{
    func timeTable(user: User)
    func timeTableMenu(daysArray: [Day], selected: Int)
}

enum NewTimeTableType{
    case daily
    case all
    case none
}

class NewTimeTableViewController: UIViewController {
    
    enum Colors {
        static let border = UIColor.lightGray
        static let headerBackground = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataGridView: DataGridView!
    @IBOutlet var dataGridViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var nextViewButton: UIButton!
    @IBOutlet weak var previousViewButton: UIButton!
    @IBOutlet var rightArrowImageView: UIImageView!
    @IBOutlet var leftArrowImageView: UIImageView!
    
    var daysArray: [Day] = [
        Day(id: 1, name: "M".localiz(), selected: false),
        Day(id: 2, name: "T".localiz(), selected: false),
        Day(id: 3, name: "W".localiz(), selected: false),
        Day(id: 4, name: "T".localiz(), selected: false),
        Day(id: 5, name: "F".localiz(), selected: false),
        Day(id: 6, name: "S".localiz(), selected: false),
        Day(id: 7, name: "S".localiz(), selected: false),
        ]
    
    var subjectTheme: [SubjectTheme]!
    var timeTableData: [Periods] = []
    var allTimeTableData: [WeekPeriods] = []
    var timeArray: [String] = []
    var filteredTimeTableData: [Period] = []
    var appTheme: AppTheme!
    var user: User!
    var sectionId: Int = 0
    var timeTableDelegate: NewTimeTableViewControllerDelegate?
    var timeTableViewType: NewTimeTableType?
    var selectedDay: Day = Day.init(id: 7, name: "All", selected: true)
    var WeeklyPeriodCount = 0
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    
    var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataGrid()
        
        titleLabel.appearanceFont = UIFont(name: "OpenSans-Bold", size: 17)
        
        previousViewButton.dropCircleShadow()
        nextViewButton.dropCircleShadow()
        
        dataGridView.columnHeaderHeight = 60
        dataGridView.rowHeaderWidth = 60
        timeTableViewType = .all
        
        /// Register data grid cells:
        dataGridView.registerNib(UINib(nibName: "DataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DataCell")
        dataGridView.registerNib(UINib(nibName: "DailyDataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DailyDataCell")
        dataGridView.registerNib(UINib(nibName: "TextDataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextDataCell")
        dataGridView.registerNib(UINib(nibName: "EmptyDataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "emptyCell")
        dataGridView.registerNib(UINib(nibName: "ColumnHeaderCell", bundle: nil), forHeaderOfKind: .ColumnHeader, withReuseIdentifier: "columnReuse")
        dataGridView.registerNib(UINib(nibName: "RowHeaderCell", bundle: nil), forHeaderOfKind: .RowHeader, withReuseIdentifier: "rowReuse")
        dataGridView.registerNib(UINib(nibName: "CornerHeaderCell", bundle: nil), forHeaderOfKind: .CornerHeader, withReuseIdentifier: "cornerReuse")
        
        dataGridView.collectionView.showsHorizontalScrollIndicator = false
        dataGridView.collectionView.showsVerticalScrollIndicator = false
        
        if languageId == "ar"{
            self.rightArrowImageView.image = UIImage(named: "calendar-left-arrow")
            self.leftArrowImageView.image = UIImage(named: "calendar-right-arrow")
        }else{
            self.rightArrowImageView.image = UIImage(named: "calendar-right-arrow")
            self.leftArrowImageView.image = UIImage(named: "calendar-left-arrow")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTimeTableAPI()
        timeTableDelegate?.timeTable(user: self.user)
    }
    
    /// Initialize DataGrid View:
    func initDataGrid(){
        dataGridView.delegate = self
        dataGridView.dataSource = self
        
        let dataGridAppearance = DataGridView.glyuck_appearanceWhenContained(in: NewTimeTableViewController.self)!
        dataGridAppearance.row1BackgroundColor = nil
        dataGridAppearance.row2BackgroundColor = nil
        
        let cornerHeaderAppearance = DataGridViewCornerHeaderCell.glyuck_appearanceWhenContained(in: NewTimeTableViewController.self)!
        cornerHeaderAppearance.backgroundColor = Colors.headerBackground
        cornerHeaderAppearance.borderLeftWidth = 0 / UIScreen.main.scale
        cornerHeaderAppearance.borderTopWidth = 0 / UIScreen.main.scale
        cornerHeaderAppearance.borderRightWidth = 0 / UIScreen.main.scale
        cornerHeaderAppearance.borderBottomWidth = 1 / UIScreen.main.scale
        cornerHeaderAppearance.borderLeftColor = Colors.border
        cornerHeaderAppearance.borderTopColor = Colors.border
        cornerHeaderAppearance.borderRightColor = Colors.border
        cornerHeaderAppearance.borderBottomColor = Colors.border
        cornerHeaderAppearance.backgroundColor = .white
        
        let rowHeaderAppearance = DataGridViewRowHeaderCell.glyuck_appearanceWhenContained(in: NewTimeTableViewController.self)!
        rowHeaderAppearance.backgroundColor = Colors.headerBackground
        rowHeaderAppearance.borderLeftWidth = 1 / UIScreen.main.scale
        rowHeaderAppearance.borderBottomWidth = 1 / UIScreen.main.scale
        rowHeaderAppearance.borderRightWidth = 1 / UIScreen.main.scale
        rowHeaderAppearance.borderLeftColor = Colors.border
        rowHeaderAppearance.borderBottomColor = Colors.border
        rowHeaderAppearance.borderRightColor = Colors.border
        
        let rowHeaderLabelAppearane = UILabel.glyuck_appearanceWhenContained(in: NewTimeTableViewController.self, class2: DataGridViewRowHeaderCell.self)!
        rowHeaderLabelAppearane.appearanceTextAlignment = .right
        
        let columnHeaderAppearance = DataGridViewColumnHeaderCell.glyuck_appearanceWhenContained(in: NewTimeTableViewController.self)!
        columnHeaderAppearance.backgroundColor = Colors.headerBackground
        columnHeaderAppearance.borderTopWidth = 0 / UIScreen.main.scale
        columnHeaderAppearance.borderBottomWidth = 1 / UIScreen.main.scale
        columnHeaderAppearance.borderRightWidth = 0 / UIScreen.main.scale
        columnHeaderAppearance.borderTopColor = Colors.border
        columnHeaderAppearance.borderBottomColor = Colors.border
        columnHeaderAppearance.borderRightColor = Colors.border
        
        let cellAppearance = DataGridViewContentCell.glyuck_appearanceWhenContained(in: NewTimeTableViewController.self)!
        cellAppearance.borderRightWidth = 1 / UIScreen.main.scale
        cellAppearance.borderRightColor = UIColor(white: 0.73, alpha: 1)
        cellAppearance.borderBottomWidth = 1 / UIScreen.main.scale
        cellAppearance.borderBottomColor = UIColor(white: 0.73, alpha: 1)
        cellAppearance.borderTopWidth = 1 / UIScreen.main.scale
        cellAppearance.borderTopColor = UIColor(white: 0.73, alpha: 1)
        
        columnHeaderAppearance.backgroundColor = UIColor(white: 0.95, alpha: 1)
        let labelAppearance = UILabel.glyuck_appearanceWhenContained(in: NewTimeTableViewController.self)!
        labelAppearance.appearanceFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
        labelAppearance.appearanceTextAlignment = .center
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        if self.selectedDay.id != self.daysArray.first?.id{
            let index = self.daysArray.firstIndex(of: self.selectedDay)
            if index == nil{
                guard let day = self.daysArray.last else { return }
                self.selectedDay = day
            }else{
                if index! > 0{
                    let day = self.daysArray[index! - 1]
                    self.selectedDay = day
                }else{
                    return
                }
            }
            reloadGridData()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if self.selectedDay.id != 7{
            let index = self.daysArray.firstIndex(of: self.selectedDay)
            if index != nil{
                if index == self.daysArray.count - 1{
                    self.selectedDay.id = 7
                }else{
                    self.selectedDay = self.daysArray[(index ?? 0)+1]
                }
            }
            reloadGridData()
        }
    }
    
    /// Description:
    /// - Update DataGrid view to week view or daily view.
    func updateTimeTableView(){
        switch self.timeTableViewType{
        case .all?:
            dataGridView.columnHeaderHeight = 0.01
        case .daily?:
            dataGridView.columnHeaderHeight = 0.01
        default:
            break
        }
        self.dataGridView.layoutIfNeeded()
        dataGridView.reloadData()
    }
    
    /// Description:
    /// - Configure DataGrid data.
    func reloadGridData(){
        var name = ""
        self.timeTableViewType = .daily
        self.updateDataGridHeight(count: self.WeeklyPeriodCount)
        switch self.selectedDay.id{
        case 0:
            name = self.selectedDay.name.capitalized
        case 1:
            name = self.selectedDay.name.capitalized
        case 2:
            name = self.selectedDay.name.capitalized
        case 3:
            name = self.selectedDay.name.capitalized
        case 4:
            name = self.selectedDay.name.capitalized
        case 5:
            name = self.selectedDay.name.capitalized
        case 6:
            name = self.selectedDay.name.capitalized
        default:
            name = "TIMETABLE".localiz()
            self.timeTableViewType = .all
            self.updateDataGridHeight(count: self.allTimeTableData.count)
        }
        self.selectedDay.name = name
        self.titleLabel.text = self.selectedDay.name.localiz()
        
        var data: [Period] = []
        for period in timeTableData{
            let array = period.periodArray
            let filtered = array.filter({$0.dayId == self.selectedDay.id})
            for object in filtered{
                data.append(object)
            }
        }
        self.timeTableDelegate?.timeTableMenu(daysArray: self.daysArray, selected: self.selectedDay.id)
        data = data.sorted(by: {self.timeFormatter.date(from: $0.time)?.compare(self.timeFormatter.date(from: $1.time)!) == .orderedAscending})
        self.filteredTimeTableData = data
        updateTimeTableView()
    }
    
    func getTimeTableAPI(){
        self.getTimeTable(user: self.user, subjectTheme: appTheme.subjectTheme)
    }
    
}

// MARK: - XLPagerTabStrip Method:
// Initialize TimeTable module.
extension NewTimeTableViewController: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Timetable".localiz(), counter: "", image: UIImage(named: "timeTableDefault"), backgroundViewColor: App.hexStringToUIColorCst(hex: "#79cbf7", alpha: 1.0), id: App.timeTableID)
    }
    
}

extension NewTimeTableViewController: DataGridViewDelegate, DataGridViewDataSource{
    func numberOfColumnsInDataGridView(_ dataGridView: DataGridView) -> Int {
        if self.timeTableViewType == .daily{
            return 1
        }
//        return daysArray.count
        return timeArray.count
    }
    
    func numberOfRowsInDataGridView(_ dataGridView: DataGridView) -> Int {
        if self.timeTableViewType == .daily{
            return filteredTimeTableData.count
        }
//        return self.timeTableData.count
        return self.allTimeTableData.count
    }
    
    func dataGridView(_ dataGridView: DataGridView, viewForHeaderForColumn column: Int) -> DataGridViewColumnHeaderCell {
        let cell = dataGridView.dequeueReusableHeaderViewWithReuseIdentifier("columnReuse", forColumn: column) as! ColumnHeaderCell
        var title = ""
        if self.timeTableViewType == .daily{
            title = daysArray[column].name
            UIView.performWithoutAnimation {
                cell.headerTextButton.isHidden = true
                cell.headerButton.isHidden = false
                cell.headerButton.setTitle(title, for: .normal)
                cell.headerButton.titleLabel?.font = UIFont(name: "OpenSans", size: 12)
                cell.headerButton.layoutIfNeeded()
            }
        }else{
            title = timeArray[column]
            UIView.performWithoutAnimation {
                cell.headerButton.isHidden = true
                cell.headerTextButton.isHidden = false
                cell.headerTextButton.setTitle(title, for: .normal)
                cell.headerTextButton.titleLabel?.font = UIFont(name: "OpenSans", size: 10)
                cell.headerTextButton.layoutIfNeeded()
            }
        }
        
        cell.headerButton.cornerRadius = cell.headerButton.frame.height/2
        cell.contentView.backgroundColor = .white
        return cell
    }
    
    func dataGridView(_ dataGridView: DataGridView, viewForHeaderForRow row: Int) -> DataGridViewRowHeaderCell {
        let cell = dataGridView.dequeueReusableHeaderViewWithReuseIdentifier("rowReuse", forRow: row) as! RowHeaderCell
        UIView.performWithoutAnimation {
            if self.timeTableViewType == .all{
                var title = ""
                switch self.allTimeTableData[row].dayId{
                case 1:
                    let day = self.daysArray.filter({$0.id == self.allTimeTableData[row].dayId}).first
                    title = "\(day?.name.first ?? "M")"
//                    title = "M".localiz()
                case 2:
                    let day = self.daysArray.filter({$0.id == self.allTimeTableData[row].dayId}).first
                    title = "\(day?.name.first ?? "T")"
                case 3:
                    let day = self.daysArray.filter({$0.id == self.allTimeTableData[row].dayId}).first
                    title = "\(day?.name.first ?? "W")"
                case 4:
                    let day = self.daysArray.filter({$0.id == self.allTimeTableData[row].dayId}).first
                    title = "\(day?.name.first ?? "T")"
                case 5:
                    let day = self.daysArray.filter({$0.id == self.allTimeTableData[row].dayId}).first
                    title = "\(day?.name.first ?? "F")"
                default:
                    let day = self.daysArray.filter({$0.id == self.allTimeTableData[row].dayId}).first
                    title = "\(day?.name.first ?? "S")"
                }
                cell.rowHeaderTitle.setTitle(title, for: .normal)
            }else{
                cell.rowHeaderTitle.setTitle(self.filteredTimeTableData[row].time, for: .normal)
            }
            cell.rowHeaderTitle.titleLabel?.font = UIFont(name: "OpenSans", size: 12)
            cell.rowHeaderTitle.layoutIfNeeded()
        }
        cell.averageHeaderTitle.isHidden = true
        cell.contentView.backgroundColor = .white
        return cell
    }
    
    func dataGridView(_ dataGridView: DataGridView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = dataGridView.dequeueReusableCellWithReuseIdentifier("emptyCell", forIndexPath: indexPath) as! EmptyDataGridCollectionViewCell
        emptyCell.backgroundColor = .white
        //        let cell = dataGridView.dequeueReusableCellWithReuseIdentifier("DataCell", forIndexPath: indexPath) as! DataGridCollectionViewCell
        let dailyCell = dataGridView.dequeueReusableCellWithReuseIdentifier("DailyDataCell", forIndexPath: indexPath) as! DailyDataGridCollectionViewCell
        let textCell = dataGridView.dequeueReusableCellWithReuseIdentifier("TextDataCell", forIndexPath: indexPath) as! TextDataGridCollectionViewCell
        
        switch self.timeTableViewType{
        case .daily?:
            dailyCell.border.bottomWidth = 1 / UIScreen.main.scale
            dailyCell.border.rightWidth = 1 / UIScreen.main.scale
            dailyCell.border.topWidth = 1 / UIScreen.main.scale
            dailyCell.border.bottomColor = Colors.border
            dailyCell.border.rightColor = Colors.border
            dailyCell.border.topColor = Colors.border
            dailyCell.cellLabel.appearanceFont = UIFont(name: "OpenSans-Bold", size: 12)
            
            if self.filteredTimeTableData.count > indexPath.dataGridRow{
                let period = self.filteredTimeTableData[indexPath.dataGridRow]
                if period.subjectName.isEmpty{
                    dailyCell.cellIcon.isHidden = true
                    dailyCell.cellLabel.isHidden = true
                    dailyCell.backgroundColor = App.hexStringToUIColorCst(hex: "#f1f2f2", alpha: 0.5)
                }else{
                    dailyCell.cellIcon.isHidden = false
                    dailyCell.cellLabel.isHidden = false
                    dailyCell.backgroundColor = .white
                    if self.user.userType == 2{
                        dailyCell.configureWithData(period.subjectIcon, title: "\(period.subjectName) - \(period.classCode)", forIndexPath: indexPath)
                    }else{
                        dailyCell.configureWithData(period.subjectIcon, title: period.subjectName, forIndexPath: indexPath)
                    }
                }
                
                dailyCell.cellIcon.isUserInteractionEnabled = false
                return dailyCell
            }else{
                return emptyCell
            }
        default:
            textCell.border.bottomWidth = 1 / UIScreen.main.scale
            textCell.border.rightWidth = 1 / UIScreen.main.scale
            textCell.border.topWidth = 1 / UIScreen.main.scale
            textCell.border.bottomColor = Colors.border
            textCell.border.rightColor = Colors.border
            textCell.border.topColor = Colors.border
            textCell.titleTextLabel.appearanceFont = UIFont(name: "OpenSans", size: 9)
            
            if allTimeTableData.count > indexPath.dataGridRow{
                let timeTableRows = self.allTimeTableData[indexPath.dataGridRow]
                if timeTableRows.periodArray.count > indexPath.dataGridColumn{
                    let period = timeTableRows.periodArray[indexPath.dataGridColumn]
                    if period.periodId == 0{
                        textCell.titleTextLabel.isHidden = true
                        textCell.backgroundColor = App.hexStringToUIColorCst(hex: "#f1f2f2", alpha: 0.5)
                    }else{
                        textCell.titleTextLabel.isHidden = false
                        textCell.backgroundColor = .white
                        if self.user.userType == 2{
                            textCell.configureWithData("P\(indexPath.dataGridColumn+1)\n\(period.time) - \(period.endTime)\n\(period.subjectName) - \(period.classCode)", forIndexPath: indexPath)
                        }else{
                            textCell.configureWithData("P\(indexPath.dataGridColumn+1)\n\(period.time) - \(period.endTime)\n\(period.subjectName)", forIndexPath: indexPath)
                        }
                    }
                    return textCell
                }else{
                    return emptyCell
                }
            }else{
                return emptyCell
            }
        }
    }
    
    func dataGridView(_ dataGridView: DataGridView, heightForRow row: Int) -> CGFloat {
        return 66
    }
    
    func dataGridView(_ dataGridView: DataGridView, widthForColumn column: Int) -> CGFloat {
        if self.timeTableViewType == .daily{
            return self.dataGridView.frame.width - self.dataGridView.rowHeaderWidth
        }else{
            return 80
        }
    }
    
    func dataGridView(_ dataGridView: DataGridView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
}

// MARK: - Handle Sections page delegate functions:
extension NewTimeTableViewController: SectionToTimeTableDelegate{
    func timeTableBatchId(user: User, batchId: Int) {
        self.sectionId = batchId
        self.user = user
        getTimeTableAPI()

        
    }
    
    func updateTimeTable(day: Day) {
        self.selectedDay = day
        self.reloadGridData()
    }
    
    func switchTimeTableChildren(user: User, batchId: Int?, children: Children?) {
        self.user = user
        self.sectionId = batchId ?? 0
        getTimeTableAPI()
    }
    
}


// MARK: - API Calls:
extension NewTimeTableViewController{
    
    /// Description:
    /// - Call "teacher_timetable" or "get_timetable" APIs based on the selected user's type.
    /// - Group the data to mach datagrid functionality.
    func getTimeTable(user: User, subjectTheme: [SubjectTheme]){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.getTimeTable(user: user, sectionId: self.sectionId, theme: subjectTheme, date: Date()) { (message, data, status) in
            
            print("reply reply: \(message)")
            print("reply reply: \(data)")

            if status == 200{
                let dayArray = Dictionary(grouping: data!, by: { $0.dayId })
                var filteredData: [Period] = []
                for day in dayArray{
                    let value = day.value.map({return $0.subjectName})
                    if Array(Set(value)) != [""]{
                        for period in day.value{
                            filteredData.append(period)
                        }
                    }
                }
                
                let allTimeArray = dayArray.sorted(by: {$0.key < $1.key})
                self.allTimeTableData = []
                self.timeArray = []
                for day in allTimeArray{
                    let value = day.value.map({return $0.subjectName})
                    if Array(Set(value)) != [""]{
                    }
                    for period in day.value{
                        self.timeArray.append(period.time)
                    }
                    let tableData = WeekPeriods(dayId: day.key, periodArray: day.value)
                    self.allTimeTableData.append(tableData)
                }
                self.timeArray = Array(Set(self.timeArray))
                
                var dataArray = Dictionary(grouping: filteredData, by: { $0.time })
                dataArray = dataArray.filter({self.timeFormatter.date(from: $0.key) != nil})
                let sortedDataArray = dataArray.sorted(by: {self.timeFormatter.date(from: $0.key)?.compare(self.timeFormatter.date(from: $1.key)!) == .orderedAscending})
                
                self.timeTableData = []
                self.daysArray = []
                for sortedArray in sortedDataArray{
                    var periodArray: [Period] = []
                    
                    for period in sortedArray.value{
                        periodArray.append(period)
                        var dayTitle = ""
                        switch period.dayId{
                        case 1:
                            dayTitle = period.dayName
                        case 2:
                            dayTitle = period.dayName
                        case 3:
                            dayTitle = period.dayName
                        case 4:
                            dayTitle = period.dayName
                        case 5:
                            dayTitle = period.dayName
                        default:
                            dayTitle = period.dayName
                        }
                        let day = Day.init(id: period.dayId, name: dayTitle, selected: false)
                        self.daysArray.append(day)
                    }
                    let tableData = Periods(time: sortedArray.key, periodArray: periodArray)
                    self.timeTableData.append(tableData)
                }
                
                self.daysArray = Array(Set(self.daysArray))
                self.daysArray = self.daysArray.sorted{$0.id < $1.id}
                
                if !self.daysArray.isEmpty{
                    var today = 0
                    switch App.dayFormatter.string(from: Date()){
                    case "Mon", "lun.", "اثنين":
                        today = 1
                    case "Tue", "mar.", "ثلاثاء":
                        today = 2
                    case "Wed", "mer.", "أربعاء":
                        today = 3
                    case "Thu", "jeu.", "خميس":
                        today = 4
                    case "Fri", "ven.", "جمعة":
                        today = 5
                    case "Sat", "sam.", "سبت":
                        today = 6
                    default:
                        today = 0
                    }
                    let days = self.daysArray.map({return $0.id})
                    if days.contains(today){
                        if let day = self.daysArray.filter({$0.id == today}).first{
                            self.selectedDay = day
                        }else{
                            self.selectedDay = self.daysArray.first!
                        }
                    }else{
                        self.selectedDay = self.daysArray.first!
                    }
                    self.reloadGridData()
                    self.timeTableDelegate?.timeTableMenu(daysArray: self.daysArray, selected: self.selectedDay.id)
                }
                self.WeeklyPeriodCount = dataArray.keys.count
                self.updateDataGridHeight(count: self.WeeklyPeriodCount)
                
                self.view.layoutIfNeeded()
                self.reloadGridData()
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
    
    /// Description:
    /// - This is used to update dataGrid view height.
    func updateDataGridHeight(count: Int){
        if count < 4{
            self.dataGridViewHeightConstraints.constant = CGFloat(count * 100)
        }else{
            self.dataGridViewHeightConstraints.constant = CGFloat(count * 76)
        }
    }
    
}

