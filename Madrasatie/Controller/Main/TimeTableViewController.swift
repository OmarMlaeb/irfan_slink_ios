//
//  TimeTableViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 1/11/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit

protocol TimeTableViewControllerDelegate{
    func timeTable(user: User)
    func timeTableMenu(daysArray: [Day], selected: Int)
}

enum TimeTableType{
    case daily
    case all
    case none
}

/// Description: This is an old TimeTable Module Class.
class TimeTableViewController: UIViewController {
    
    enum Colors {
        static let border = UIColor.lightGray
        static let headerBackground = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataGridView: DataGridView!
    @IBOutlet var dataGridViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var nextViewButton: UIButton!
    @IBOutlet weak var previousViewButton: UIButton!
    
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
    var filteredTimeTableData: [Period] = []
    var appTheme: AppTheme!
    var user: User!
    var timeTableDelegate: TimeTableViewControllerDelegate?
    var timeTableViewType: TimeTableType?
    var selectedDay: Day = Day.init(id: 0, name: "All", selected: true)
    
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
        
        dataGridView.registerNib(UINib(nibName: "DataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DataCell")
        dataGridView.registerNib(UINib(nibName: "DailyDataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DailyDataCell")
        dataGridView.registerNib(UINib(nibName: "TextDataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextDataCell")
        dataGridView.registerNib(UINib(nibName: "EmptyDataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        dataGridView.registerNib(UINib(nibName: "ColumnHeaderCell", bundle: nil), forHeaderOfKind: .ColumnHeader, withReuseIdentifier: "columnReuse")
        dataGridView.registerNib(UINib(nibName: "RowHeaderCell", bundle: nil), forHeaderOfKind: .RowHeader, withReuseIdentifier: "rowReuse")
        dataGridView.registerNib(UINib(nibName: "CornerHeaderCell", bundle: nil), forHeaderOfKind: .CornerHeader, withReuseIdentifier: "cornerReuse")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTimeTableAPI()
        timeTableDelegate?.timeTable(user: self.user)
    }
    
    func initDataGrid(){
        dataGridView.delegate = self
        dataGridView.dataSource = self
        
        let dataGridAppearance = DataGridView.glyuck_appearanceWhenContained(in: TimeTableViewController.self)!
        dataGridAppearance.row1BackgroundColor = nil
        dataGridAppearance.row2BackgroundColor = nil
        
        let cornerHeaderAppearance = DataGridViewCornerHeaderCell.glyuck_appearanceWhenContained(in: TimeTableViewController.self)!
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
        
        let rowHeaderAppearance = DataGridViewRowHeaderCell.glyuck_appearanceWhenContained(in :TimeTableViewController.self)!
        rowHeaderAppearance.backgroundColor = Colors.headerBackground
        rowHeaderAppearance.borderLeftWidth = 1 / UIScreen.main.scale
        rowHeaderAppearance.borderBottomWidth = 1 / UIScreen.main.scale
        rowHeaderAppearance.borderRightWidth = 1 / UIScreen.main.scale
        rowHeaderAppearance.borderLeftColor = Colors.border
        rowHeaderAppearance.borderBottomColor = Colors.border
        rowHeaderAppearance.borderRightColor = Colors.border
        
        let rowHeaderLabelAppearane = UILabel.glyuck_appearanceWhenContained(in: TimeTableViewController.self, class2: DataGridViewRowHeaderCell.self)!
        rowHeaderLabelAppearane.appearanceTextAlignment = .right
        
        let columnHeaderAppearance = DataGridViewColumnHeaderCell.glyuck_appearanceWhenContained(in: TimeTableViewController.self)!
        columnHeaderAppearance.backgroundColor = Colors.headerBackground
        columnHeaderAppearance.borderTopWidth = 0 / UIScreen.main.scale
        columnHeaderAppearance.borderBottomWidth = 1 / UIScreen.main.scale
        columnHeaderAppearance.borderRightWidth = 0 / UIScreen.main.scale
        columnHeaderAppearance.borderTopColor = Colors.border
        columnHeaderAppearance.borderBottomColor = Colors.border
        columnHeaderAppearance.borderRightColor = Colors.border
        
        let cellAppearance = DataGridViewContentCell.glyuck_appearanceWhenContained(in: TimeTableViewController.self)!
        cellAppearance.borderRightWidth = 1 / UIScreen.main.scale
        cellAppearance.borderRightColor = UIColor(white: 0.73, alpha: 1)
        cellAppearance.borderBottomWidth = 1 / UIScreen.main.scale
        cellAppearance.borderBottomColor = UIColor(white: 0.73, alpha: 1)
        cellAppearance.borderTopWidth = 1 / UIScreen.main.scale
        cellAppearance.borderTopColor = UIColor(white: 0.73, alpha: 1)
        
        columnHeaderAppearance.backgroundColor = UIColor(white: 0.95, alpha: 1)
        let labelAppearance = UILabel.glyuck_appearanceWhenContained(in: TimeTableViewController.self)!
        labelAppearance.appearanceFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
        labelAppearance.appearanceTextAlignment = .center
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        if self.selectedDay.id != self.daysArray.first?.id{
            let index = self.daysArray.firstIndex(of: self.selectedDay)
            if index == nil{
                guard let dayId = self.daysArray.last?.id else { return }
                self.selectedDay.id = dayId
            }else{
                if index! > 0{
                    let dayId = self.daysArray[index! - 1].id
                    self.selectedDay.id = dayId
                }else{
                    return
                }
            }
            reloadGridData()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if self.selectedDay.id != 0{
            let index = self.daysArray.firstIndex(of: self.selectedDay)
            if index == self.daysArray.count - 1{
                self.selectedDay.id = 0
            }else{
                self.selectedDay.id = self.daysArray[index!+1].id
            }
            reloadGridData()
        }
    }
    
    func updateTimeTableView(){
        switch self.timeTableViewType{
        case .all?:
            dataGridView.columnHeaderHeight = 60
        case .daily?:
            dataGridView.columnHeaderHeight = 0.01
        default:
            break
        }
        self.dataGridView.layoutIfNeeded()
        dataGridView.reloadData()
    }
    
    func reloadGridData(){
        var name = ""
        self.timeTableViewType = .daily
        switch self.selectedDay.id{
        case 0:
            name = "TIMETABLE"
            self.timeTableViewType = .all
        case 1:
            name = "MONDAY"
        case 2:
            name = "TUESDAY"
        case 3:
            name = "WEDNESDAY"
        case 4:
            name = "THUSDAY"
        case 5:
            name = "FRIDAY"
        case 6:
            name = "SATURDAY"
        default:
            name = "SAUNDAY"
        }
        self.selectedDay.name = name
        self.titleLabel.text = self.selectedDay.name
        
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
//        switch user.userType{
//        case 2:
//        case 3,4:
            self.getTimeTable(user: self.user, subjectTheme: appTheme.subjectTheme)
//        default:
//            break
//        }
    }
    
}

// XLPagerTabStrip Method:
extension TimeTableViewController: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Timetable".localiz(), counter: "", image: UIImage(named: "timeTableDefault"), backgroundViewColor: App.hexStringToUIColorCst(hex: "#79cbf7", alpha: 1.0), id: 10)
    }
    
}

extension TimeTableViewController: DataGridViewDelegate, DataGridViewDataSource{
    func numberOfColumnsInDataGridView(_ dataGridView: DataGridView) -> Int {
        if self.timeTableViewType == .daily{
            return 1
        }
        return daysArray.count
    }
    
    func numberOfRowsInDataGridView(_ dataGridView: DataGridView) -> Int {
        if self.timeTableViewType == .daily{
            return filteredTimeTableData.count
        }
        return self.timeTableData.count
    }
    
    func dataGridView(_ dataGridView: DataGridView, viewForHeaderForColumn column: Int) -> DataGridViewColumnHeaderCell {
        let cell = dataGridView.dequeueReusableHeaderViewWithReuseIdentifier("columnReuse", forColumn: column) as! ColumnHeaderCell
        var title = ""
        if !self.daysArray.isEmpty{
            title = daysArray[column].name
        }
        UIView.performWithoutAnimation {
            cell.headerButton.setTitle(title, for: .normal)
            cell.headerButton.titleLabel?.font = UIFont(name: "OpenSans", size: 12)
            cell.headerButton.layoutIfNeeded()
        }
//        cell.headerButton.addTarget(self, action: #selector(columnHeaderPressed), for: .touchUpInside)
        cell.headerButton.cornerRadius = cell.headerButton.frame.height/2
        cell.contentView.backgroundColor = .white
        return cell
    }
    
    func dataGridView(_ dataGridView: DataGridView, viewForHeaderForRow row: Int) -> DataGridViewRowHeaderCell {
        let cell = dataGridView.dequeueReusableHeaderViewWithReuseIdentifier("rowReuse", forRow: row) as! RowHeaderCell
        UIView.performWithoutAnimation {
            if self.timeTableViewType == .all{
                cell.rowHeaderTitle.setTitle(self.timeTableData[row].time, for: .normal)
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
        let emptyCell = dataGridView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! EmptyDataGridCollectionViewCell
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
                    if self.user.userType == 2 || user.userType == 1{
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
            textCell.border.bottomColor = Colors.border
            textCell.border.rightColor = Colors.border
            textCell.border.topColor = Colors.border
            textCell.titleTextLabel.appearanceFont = UIFont(name: "OpenSans", size: 9)

            if timeTableData.count > indexPath.dataGridRow{
                let timeTableRows = self.timeTableData[indexPath.dataGridRow]
                if timeTableRows.periodArray.count > indexPath.dataGridColumn{
                    let period = timeTableRows.periodArray[indexPath.dataGridColumn]
                    if period.subjectName.isEmpty{
                        textCell.titleTextLabel.isHidden = true
                        textCell.backgroundColor = App.hexStringToUIColorCst(hex: "#f1f2f2", alpha: 0.5)
                    }else{
                        textCell.titleTextLabel.isHidden = false
                        textCell.backgroundColor = .white
                        if self.user.userType == 2 || self.user.userType == 1{
                            textCell.configureWithData("\(period.subjectName) - \(period.classCode)", forIndexPath: indexPath)
                        }else{
                            textCell.configureWithData(period.subjectName, forIndexPath: indexPath)
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
    
    func dataGridView(_ dataGridView: DataGridView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
}

extension TimeTableViewController: SectionToTimeTableDelegate{
    func timeTableBatchId(user: User, batchId: Int) {
        
    }
    
    func updateTimeTable(day: Day) {
        self.selectedDay.id = day.id
        self.reloadGridData()
    }
    
    func switchTimeTableChildren(user: User, batchId: Int?, children: Children?) {
        self.user = user
        getTimeTableAPI()
    }
    
}

//TimeTable APIS:
extension TimeTableViewController{
    func getTimeTable(user: User, subjectTheme: [SubjectTheme]){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.getAttendanceTimeTable(user: user, theme: subjectTheme, date: Date()) { (message, data, status) in
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
                
//                var dataArray = Dictionary(grouping: data!, by: { $0.time })
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
                            dayTitle = "M".localiz()
                        case 2,4:
                            dayTitle = "T".localiz()
                        case 3:
                            dayTitle = "W".localiz()
                        case 5:
                            dayTitle = "F".localiz()
                        default:
                            dayTitle = "S".localiz()
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
                    case "Mon":
                        today = 1
                    case "Tue":
                        today = 2
                    case "Wed":
                        today = 3
                    case "Thu":
                        today = 4
                    case "Fri":
                        today = 5
                    case "Sat":
                        today = 6
                    default:
                        today = 0
                    }
                    let days = self.daysArray.map({return $0.id})
                    if days.contains(today){
                        self.selectedDay.id = today
                    }else{
                        self.selectedDay.id = self.daysArray.first!.id
                    }
                    self.reloadGridData()
                    self.timeTableDelegate?.timeTableMenu(daysArray: self.daysArray, selected: self.selectedDay.id)
                }
                
                if dataArray.keys.count < 4{
                    self.dataGridViewHeightConstraints.constant = CGFloat(dataArray.keys.count * 100)
                }else{
                    self.dataGridViewHeightConstraints.constant = CGFloat(dataArray.keys.count * 76)
                }
                
                self.view.layoutIfNeeded()
//                self.dataGridView.reloadData()
                self.reloadGridData()
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
}
