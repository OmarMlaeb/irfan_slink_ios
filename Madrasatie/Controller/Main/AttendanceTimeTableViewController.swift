//
//  AttendanceTimeTableViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 9/26/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import UIKit
import PWSwitch

/// Description:
/// - Delegate from Attendance timeTable page to Attendance page.
protocol attendanceTimeTableDelegate{
    func timeTableDismiss()
    func submitRequestLeave(fullDay: Bool, selectedPeriods: [Period], startDate: String, endDate: String)
    func daysID(days: [Int])
}

class AttendanceTimeTableViewController: UIViewController, DataGridViewDelegate, DataGridViewDataSource, TimeTableDelegate {
    
    enum Colors {
        static let border = UIColor.lightGray
        static let headerBackground = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    }
    
    @IBOutlet weak var dataGridView: DataGridView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var dataGridViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var fullDaySwitch: PWSwitch!
    @IBOutlet weak var absenceStartTime: UIDatePicker!
    @IBOutlet weak var absenceEndTime: UIDatePicker!
    
    @IBOutlet weak var chosenDate: UILabel!
    
    var user: User!
    var delegate: attendanceTimeTableDelegate?
    var timeTableData: [Periods] = []
    var selectedTimeTableData: [Period] = []
    
    var daysArray: [Day] = [
        Day(id: 1, name: "M".localiz(), selected: false),
        Day(id: 2, name: "T".localiz(), selected: false),
        Day(id: 3, name: "W".localiz(), selected: false),
        Day(id: 4, name: "T".localiz(), selected: false),
        Day(id: 5, name: "F".localiz(), selected: false),
        Day(id: 6, name: "S".localiz(), selected: false),
        Day(id: 7, name: "S".localiz(), selected: false),
        ]

    var fullDay = false /// Used to check if the parent select a full day or periods.
    var startDate = ""
    var endDate = ""
    var subjectTheme: [SubjectTheme]!
    var requestDate: String = ""
    
    var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    override func viewDidLoad() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            super.viewDidLoad()
            
            self.initDataGrid()
            self.dataGridView.columnHeaderHeight = 0
            self.dataGridView.rowHeaderWidth = 0
            self.absenceStartTime.datePickerMode = .time
            self.absenceEndTime.datePickerMode = .time

            self.fullDaySwitch.addTarget(self, action: #selector(self.fullDayLeave), for: .touchUpInside)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // You can change the locale based on your needs

            self.startDate = dateFormatter.string(from: Date())
            self.endDate = dateFormatter.string(from: Date())

            
            /// Description:
            /// - Register data grid cells.
//            self.dataGridView.registerNib(UINib(nibName: "DataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DataCell")
//            self.dataGridView.registerNib(UINib(nibName: "EmptyDataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "emptyCell")
//            self.dataGridView.registerNib(UINib(nibName: "ColumnHeaderCell", bundle: nil), forHeaderOfKind: .ColumnHeader, withReuseIdentifier: "columnReuse")
//            self.dataGridView.registerNib(UINib(nibName: "RowHeaderCell", bundle: nil), forHeaderOfKind: .RowHeader, withReuseIdentifier: "rowReuse")
//            self.dataGridView.registerNib(UINib(nibName: "CornerHeaderCell", bundle: nil), forHeaderOfKind: .CornerHeader, withReuseIdentifier: "cornerReuse")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
           
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // You can change the locale based on your needs

            let time1 = dateFormatter.date(from: self.startDate)
            let time2 = dateFormatter.date(from: self.endDate)


            // Create a Calendar instance to work with dates and times
            let calendar = Calendar.current

            // Compare the two times
            let comparisonResult = calendar.compare(time1 ?? Date(), to: time2 ?? Date(), toGranularity: .minute)

            // Check the comparison result
            if comparisonResult == .orderedAscending {
                print("time1 is earlier than time2")
            } else if comparisonResult == .orderedDescending {
                print("time1 is later than time2")
            } else {
                print("time1 and time2 are the same")
            }
            
            if(self.fullDay == true){
                self.submitButton.alpha = 1
                self.submitButton.isUserInteractionEnabled = true
            }
            else if(self.fullDay == false && self.startDate != "" && self.endDate != "" && (comparisonResult == .orderedAscending)){
                self.submitButton.alpha = 1
                self.submitButton.isUserInteractionEnabled = true
            }
            else{
                self.submitButton.alpha = 0.5
                self.submitButton.isUserInteractionEnabled = false
            }
            
        }
    }
    
    @objc func fullDayLeave(sender: PWSwitch){
        self.fullDay = !self.fullDay
        
        if(self.fullDay == true){
            self.absenceStartTime.isUserInteractionEnabled = false
            self.absenceEndTime.isUserInteractionEnabled = false
        }
        else{
            self.absenceStartTime.isUserInteractionEnabled = true
            self.absenceEndTime.isUserInteractionEnabled = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // You can change the locale based on your needs

        let time1 = dateFormatter.date(from: self.startDate)
        let time2 = dateFormatter.date(from: self.endDate)


        // Create a Calendar instance to work with dates and times
        let calendar = Calendar.current

        // Compare the two times
        let comparisonResult = calendar.compare(time1 ?? Date(), to: time2 ?? Date(), toGranularity: .minute)

        // Check the comparison result
        if comparisonResult == .orderedAscending {
            print("time1 is earlier than time2")
        } else if comparisonResult == .orderedDescending {
            print("time1 is later than time2")
        } else {
            print("time1 and time2 are the same")
        }
        
        if(self.fullDay == true){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else if(self.fullDay == false && self.startDate != "" && self.endDate != "" && (comparisonResult == .orderedAscending)){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else{
            self.submitButton.alpha = 0.5
            self.submitButton.isUserInteractionEnabled = false
        }

    }
    
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        let dayPeriod = Dictionary(grouping: selectedTimeTableData, by: {$0.dayId})
        for day in dayPeriod{
            if day.value.count == timeTableData.count{
                self.fullDay = true
            }
        }
        
        delegate?.submitRequestLeave(fullDay: self.fullDay, selectedPeriods: self.selectedTimeTableData, startDate: self.startDate, endDate: self.endDate)
    }
    
    @IBAction func startTimeValueChanged(_ sender: UIDatePicker) {
        print("hello hello")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // You can change the locale based on your needs

            let selectedTime = dateFormatter.string(from: sender.date)
            print("Selected time: \(selectedTime)")
        self.startDate = selectedTime

        let time1 = dateFormatter.date(from: self.startDate)
        let time2 = dateFormatter.date(from: self.endDate)


        // Create a Calendar instance to work with dates and times
        let calendar = Calendar.current

        // Compare the two times
        let comparisonResult = calendar.compare(time1 ?? Date(), to: time2 ?? Date(), toGranularity: .minute)

        // Check the comparison result
        if comparisonResult == .orderedAscending {
            print("time1 is earlier than time2")
        } else if comparisonResult == .orderedDescending {
            print("time1 is later than time2")
        } else {
            print("time1 and time2 are the same")
        }
        
        if(self.fullDay == true){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else if(self.fullDay == false && self.startDate != "" && self.endDate != "" && (comparisonResult == .orderedAscending)){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else{
            self.submitButton.alpha = 0.5
            self.submitButton.isUserInteractionEnabled = false
        }
        
    }
    
    @IBAction func endTimeValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // You can change the locale based on your needs

            let selectedTime = dateFormatter.string(from: sender.date)
            print("Selected time: \(selectedTime)")
        self.endDate = selectedTime
      

        let time1 = dateFormatter.date(from: self.startDate)
        let time2 = dateFormatter.date(from: self.endDate)


        // Create a Calendar instance to work with dates and times
        let calendar = Calendar.current

        // Compare the two times
        let comparisonResult = calendar.compare(time1 ?? Date(), to: time2 ?? Date(), toGranularity: .minute)

        // Check the comparison result
        if comparisonResult == .orderedAscending {
            print("time1 is earlier than time2")
        } else if comparisonResult == .orderedDescending {
            print("time1 is later than time2")
        } else {
            print("time1 and time2 are the same")
        }
        
        if(self.fullDay == true){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else if(self.fullDay == false && self.startDate != "" && self.endDate != "" && (comparisonResult == .orderedAscending)){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else{
            self.submitButton.alpha = 0.5
            self.submitButton.isUserInteractionEnabled = false
        }

        
    }
    
    /// Description:
    /// - Configure DataGrid View:
    func initDataGrid(){
//        dataGridView.delegate = self
//        dataGridView.dataSource = self
        
//        let dataGridAppearance = DataGridView.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
//        dataGridAppearance.row1BackgroundColor = nil
//        dataGridAppearance.row2BackgroundColor = nil
        
//        let cornerHeaderAppearance = DataGridViewCornerHeaderCell.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
//        cornerHeaderAppearance.backgroundColor = Colors.headerBackground
//        cornerHeaderAppearance.borderLeftWidth = 0 / UIScreen.main.scale
//        cornerHeaderAppearance.borderTopWidth = 1 / UIScreen.main.scale
//        cornerHeaderAppearance.borderRightWidth = 0 / UIScreen.main.scale
//        cornerHeaderAppearance.borderBottomWidth = 1 / UIScreen.main.scale
//        cornerHeaderAppearance.borderLeftColor = Colors.border
//        cornerHeaderAppearance.borderTopColor = Colors.border
//        cornerHeaderAppearance.borderRightColor = Colors.border
//        cornerHeaderAppearance.borderBottomColor = Colors.border
//
//        let rowHeaderAppearance = DataGridViewRowHeaderCell.glyuck_appearanceWhenContained(in :AttendanceTimeTableViewController.self)!
//        rowHeaderAppearance.backgroundColor = Colors.headerBackground
//        rowHeaderAppearance.borderLeftWidth = 1 / UIScreen.main.scale
//        rowHeaderAppearance.borderBottomWidth = 1 / UIScreen.main.scale
//        rowHeaderAppearance.borderRightWidth = 1 / UIScreen.main.scale
//        rowHeaderAppearance.borderLeftColor = Colors.border
//        rowHeaderAppearance.borderBottomColor = Colors.border
//        rowHeaderAppearance.borderRightColor = Colors.border
        
//        let rowHeaderLabelAppearane = UILabel.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self, class2: DataGridViewRowHeaderCell.self)!
//        rowHeaderLabelAppearane.appearanceTextAlignment = .right
//
//        let columnHeaderAppearance = DataGridViewColumnHeaderCell.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
//        columnHeaderAppearance.backgroundColor = Colors.headerBackground
//        columnHeaderAppearance.borderTopWidth = 1 / UIScreen.main.scale
//        columnHeaderAppearance.borderBottomWidth = 0 / UIScreen.main.scale
//        columnHeaderAppearance.borderRightWidth = 0 / UIScreen.main.scale
//        columnHeaderAppearance.borderTopColor = Colors.border
//        columnHeaderAppearance.borderBottomColor = Colors.border
//        columnHeaderAppearance.borderRightColor = Colors.border
//
//        let cellAppearance = DataGridViewContentCell.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
//        cellAppearance.borderRightWidth = 1 / UIScreen.main.scale
//        cellAppearance.borderRightColor = UIColor(white: 0.73, alpha: 1)
//        cellAppearance.borderBottomWidth = 1 / UIScreen.main.scale
//        cellAppearance.borderBottomColor = UIColor(white: 0.73, alpha: 1)
//
//        columnHeaderAppearance.backgroundColor = UIColor(white: 0.95, alpha: 1)
//        let labelAppearance = UILabel.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
//        labelAppearance.appearanceFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
//        labelAppearance.appearanceTextAlignment = .center
    }
    
    /// Description:
    /// - Data Grid View Data Source:
    func numberOfColumnsInDataGridView(_ dataGridView: DataGridView) -> Int {
        return daysArray.count
    }
    
    func numberOfRowsInDataGridView(_ dataGridView: DataGridView) -> Int {
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
            cell.headerButton.layoutIfNeeded()
        }
        cell.headerButton.addTarget(self, action: #selector(columnHeaderPressed), for: .touchUpInside)
        cell.headerButton.layer.cornerRadius = cell.headerButton.frame.height/2
        return cell
    }
    
    func dataGridView(_ dataGridView: DataGridView, viewForHeaderForRow row: Int) -> DataGridViewRowHeaderCell {
        let cell = dataGridView.dequeueReusableHeaderViewWithReuseIdentifier("rowReuse", forRow: row) as! RowHeaderCell
        UIView.performWithoutAnimation {
            cell.rowHeaderTitle.setTitle(self.timeTableData[row].time, for: .normal)
            cell.rowHeaderTitle.layoutIfNeeded()
        }
        cell.averageHeaderTitle.isHidden = true
        return cell
    }
    
    func cornerHeaderViewForIndexPath(_ indexPath: IndexPath) -> DataGridViewCornerHeaderCell {
        let cell = dataGridView.dequeueReusableCornerHeaderViewWithReuseIdentifier("cornerReuse") as! CornerHeaderCell
        cell.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return cell
    }
    
    func dataGridView(_ dataGridView: DataGridView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let emptyCell = dataGridView.dequeueReusableCellWithReuseIdentifier("emptyCell", forIndexPath: indexPath) as! EmptyDataGridCollectionViewCell
        emptyCell.backgroundColor = .white
        
        let cell = dataGridView.dequeueReusableCellWithReuseIdentifier("DataCell", forIndexPath: indexPath) as! DataGridCollectionViewCell
        cell.border.bottomWidth = 1 / UIScreen.main.scale
        cell.border.rightWidth = 1 / UIScreen.main.scale
        cell.border.bottomColor = Colors.border
        cell.border.rightColor = Colors.border
        
        /// Handle empty periods by returning an empty cell:
//        print("indexPath.dataGridRow",indexPath.dataGridRow)
//        print("indexPath.dataGridColumn",indexPath.dataGridColumn)
        let timeTableRows: Periods = self.timeTableData[indexPath.dataGridRow]
        if(indexPath.dataGridColumn < timeTableRows.periodArray.count){
            let period: Period = timeTableRows.periodArray[indexPath.dataGridColumn]
            cell.configureWithData(period.subjectIcon, forIndexPath: indexPath)
            if period.selected{
                cell.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 0.5)
            }else{
                cell.backgroundColor = .white
            }
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellPressed)))
        }
        cell.cellIcon.isUserInteractionEnabled = false
        return cell
    }
    
    func dataGridView(_ dataGridView: DataGridView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    @objc func cellPressed(sender: UITapGestureRecognizer){
        let cell = sender.view as! DataGridCollectionViewCell
        if cell.backgroundColor == App.hexStringToUIColorCst(hex: "#014e80", alpha: 0.5){
            cell.backgroundColor = .white
        }else{
            cell.backgroundColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 0.5)
        }
        
        self.timeTableData[cell.indexPath.dataGridRow].periodArray[cell.indexPath.dataGridColumn].selected = !self.timeTableData[cell.indexPath.dataGridRow].periodArray[cell.indexPath.dataGridColumn].selected
        self.selectedTimeTableData.removeAll()
        for periods in self.timeTableData{
            for period in periods.periodArray{
                if period.selected{
                    self.selectedTimeTableData.append(period)
                }
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // You can change the locale based on your needs

        let time1 = dateFormatter.date(from: self.startDate)
        let time2 = dateFormatter.date(from: self.endDate)


        // Create a Calendar instance to work with dates and times
        let calendar = Calendar.current

        // Compare the two times
        let comparisonResult = calendar.compare(time1 ?? Date(), to: time2 ?? Date(), toGranularity: .minute)

        // Check the comparison result
        if comparisonResult == .orderedAscending {
            print("time1 is earlier than time2")
        } else if comparisonResult == .orderedDescending {
            print("time1 is later than time2")
        } else {
            print("time1 and time2 are the same")
        }
        
        if(self.fullDay == true){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else if(self.fullDay == false && self.startDate != "" && self.endDate != "" && (comparisonResult == .orderedAscending)){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else{
            self.submitButton.alpha = 0.5
            self.submitButton.isUserInteractionEnabled = false
        }
    }
    
    
    /// Description:
    /// - Mark/Unmark days periods.
    /// - Update selected period array.
    @objc func columnHeaderPressed(sender: UIButton){
        let cell = sender.superview?.superview as! ColumnHeaderCell
        daysArray[cell.indexPath.dataGridRow].selected = !daysArray[cell.indexPath.dataGridRow].selected
        if !daysArray[cell.indexPath.dataGridRow].selected{
            for (row,periods) in self.timeTableData.enumerated(){
                for (column,period) in periods.periodArray.enumerated(){
                    if period.dayId == self.daysArray[cell.indexPath.dataGridRow].id{
                        self.timeTableData[row].periodArray[column].selected = false
                    }
                }
            }
        }else{
            for (row,periods) in self.timeTableData.enumerated(){
                for (column,period) in periods.periodArray.enumerated(){
                    if period.dayId == self.daysArray[cell.indexPath.dataGridRow].id{
                        self.timeTableData[row].periodArray[column].selected = true
                    }
                }
            }
        }
        self.selectedTimeTableData.removeAll()
        for (row,periods) in self.timeTableData.enumerated(){
            for (column,period) in periods.periodArray.enumerated(){
                if self.timeTableData[row].periodArray[column].selected == true{
                    self.selectedTimeTableData.append(period)
                }
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // You can change the locale based on your needs

        let time1 = dateFormatter.date(from: self.startDate)
        let time2 = dateFormatter.date(from: self.endDate)


        // Create a Calendar instance to work with dates and times
        let calendar = Calendar.current

        // Compare the two times
        let comparisonResult = calendar.compare(time1 ?? Date(), to: time2 ?? Date(), toGranularity: .minute)

        // Check the comparison result
        if comparisonResult == .orderedAscending {
            print("time1 is earlier than time2")
        } else if comparisonResult == .orderedDescending {
            print("time1 is later than time2")
        } else {
            print("time1 and time2 are the same")
        }
        
        if(self.fullDay == true){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else if(self.fullDay == false && self.startDate != "" && self.endDate != "" && (comparisonResult == .orderedAscending)){
            self.submitButton.alpha = 1
            self.submitButton.isUserInteractionEnabled = true
        }
        else{
            self.submitButton.alpha = 0.5
            self.submitButton.isUserInteractionEnabled = false
        }
        
        dataGridView.reloadData()
    }
    
    @objc func backButtonPressed(sender: UIButton){
        delegate?.timeTableDismiss()
    }
    
    
    /// Description:
    /// - This function is called from Attendance page in order to reload attendance timeTable data.
    func timeTableData(user: User, children: Children?, subjectTheme: [SubjectTheme]?, date: String) {
        let emptyChild = Children.init(gender: "", cycle: "", photo: "", firstName: "", lastName: "", batchId: 0, imperiumCode: "", className: "", admissionNo: "", bdDate: Date(), isBdChecked: false)
        self.user = user
        self.subjectTheme = subjectTheme
        self.requestDate  = date
        self.chosenDate.text = self.requestDate
        self.user.childrens = [children ?? emptyChild]
//        if let date = self.dateFormatter1.date(from: date){
//            self.getTimeTable(user: self.user, subjectTheme: self.subjectTheme, date: date)
//        }
    }
    
    
    /// Description:
    /// - This call "get_timetable" data.
    /// - Group the data to mach datagrid functionality.
    func getTimeTable(user: User, subjectTheme: [SubjectTheme], date: Date){
        self.dataGridView.isHidden = true
        Request.shared.getAttendanceTimeTable(user: user, theme: subjectTheme, date: date) { (message, data, status) in
            if status == 200{
                var dataArray = Dictionary(grouping: data!, by: { $0.time })
                dataArray = dataArray.filter({self.timeFormatter.date(from: $0.key) != nil})
                
                let sortedDataArray = dataArray.sorted(by: {self.timeFormatter.date(from: $0.key)?.compare(self.timeFormatter.date(from: $1.key)!) == .orderedAscending})
                
                self.timeTableData.removeAll()
                self.daysArray.removeAll()
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
                self.delegate?.daysID(days: self.daysArray.map({$0.id}))
                self.daysArray = Array(Set(self.daysArray))
                self.daysArray = self.daysArray.sorted{$0.id < $1.id}
                
                if dataArray.count < 4{
                    self.dataGridViewHeightConstraints.constant = CGFloat(dataArray.keys.count * 66)
                }else{
                    self.dataGridViewHeightConstraints.constant = CGFloat(dataArray.keys.count * 63)
                }
//                self.view.layoutIfNeeded()
                self.dataGridView.reloadData()
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.dataGridView.isHidden = false
        }
    }

}

