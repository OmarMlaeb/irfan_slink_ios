//
//  GradesViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 10/16/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import UIKit
import RATreeView
import IQKeyboardManagerSwift

// Description:
/// - Delegate from Grades page to Section page.
protocol GradesViewControllerDelegate{
    func grades()
    func gradesToCalendar()
    func initAverage(exams: [Exam])
    func showTopView()
    func hideTopView()
}

// Description:
/// - Delegate from Grades page to Add Grades page.
protocol AddGradesViewControllerDelegate{
    func QuizInfo(quizId: String, type: String, sectionId: Int, user: User, term: String, subTerm: String, subject: String, level: String, fullMark: Float, editable: Bool)
    func updateStudentList(user: User, batchId: Int)
}

class GradesViewController: UIViewController {
    var visibleItems: [Int] = [1]
    
    enum Colors {
        static let border = UIColor.lightGray
        static let headerBackground = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var averageTitleLabel: UILabel!
    @IBOutlet weak var previousAverageButton: UIButton!
    @IBOutlet weak var nextAverageButton: UIButton!
    @IBOutlet var nextImageView: UIImageView!
    @IBOutlet var previousImageView: UIImageView!
    @IBOutlet weak var averageBottomShadow: UIView!
    @IBOutlet weak var gridView: DataGridView!
    @IBOutlet weak var gridBottomShadow: UIView!
    @IBOutlet weak var remarksLabel: UILabel!
    @IBOutlet weak var remarkTitleLabel: UILabel!
    @IBOutlet weak var remarkBodyLabel: UILabel!
    @IBOutlet weak var remarkSignatureLabel: UILabel!
    @IBOutlet weak var remarkBottomShadowView: UIView!
    @IBOutlet weak var termCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomShadow: UIView!
    @IBOutlet weak var treeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addMarkView: UIView!
    @IBOutlet var treeViewToRemarksTopConstraints: NSLayoutConstraint!
    @IBOutlet var treeViewToCollectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var treeView: RATreeView!
    
    var user: User!
    var averageTimeTable: [TermAverage] = []
    var averageTitle = "Average 1"
    var termRemarkTitle: String = ""
    var termRemarkBody: String = ""
    var subTermArray: [Term] = []
    var currentTerm = Term(id: "0", name: "", avg: 0, classAvg: 0, remarkTile: "", remarkBody: "", teacherName: "", subject: "", color: "", selected: false, subjectsArray: [])
    var numberOfRows = 0
    var treeData: [DataObject] = []
    var subjectArray: [SubjectHeaderItem] = []
    var addGradeDelegate: AddGradesViewControllerDelegate?
    var delegate: GradesViewControllerDelegate?
    var teacherTermArray: [Term] = []
    var averageArray: [Average] = []
    var classObject: Class!
    var appTheme: AppTheme!
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    var refreshControl = UIRefreshControl()
    var canRefresh = true

    /// Description:
    /// - Initialize TreeView.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMarkView.isHidden = true
        treeView.delegate = self
        treeView.dataSource = self
        
        treeView.register(UINib(nibName: String(describing: SubjectTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SubjectTableViewCell.self))
        treeView.register(UINib(nibName: String(describing: SubjectHeaderTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SubjectHeaderTableViewCell.self))
        treeView.scrollView.isScrollEnabled = false
        treeView.treeFooterView = nil
        treeView.treeHeaderView = nil
        treeView.separatorColor = .clear
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localiz())
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        scrollView.addSubview(refreshControl) // not required when using UITableViewController

        print("called5")
        self.numberOfRows = treeView.numberOfRows()/2
        treeViewHeightConstraint.constant = CGFloat((self.numberOfRows*70)+((treeView.numberOfRows() - self.numberOfRows)*57))
    }
    
    @objc func refresh() {
       // Code to refresh table view
       SectionVC.didLoadGrades = false
        print("agenda grades api4")
       self.getGradesAPI()
       reloadPage()
       reloadTreeView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -50 { //change 100 to whatever you want
            if canRefresh && !self.refreshControl.isRefreshing {
                self.canRefresh = false
                self.refreshControl.beginRefreshing()
                self.refresh() // your viewController refresh function
            }
        }else if scrollView.contentOffset.y >= 0 {
            self.canRefresh = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SectionVC.canChangeClass = true
        self.delegate?.grades()
    }
    
    /// Description:
    /// - Set TreeView height.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        print("agenda grades api1")
        self.getGradesAPI()
        reloadPage()
        reloadTreeView()
        SectionVC.didLoadGrades = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    /// Description:
    /// - Reload data inside treeView.
    func reloadTreeView(){
        self.treeData = self.commonInit(items: (self.subjectArray))
        UIView.setAnimationsEnabled(false)
        treeView.reloadData()
        for item in treeData{
            treeView.expandRow(forItem: item, expandChildren: false, with: RATreeViewRowAnimationNone)
        }
        
        self.numberOfRows = treeView.numberOfRows()/2
        treeViewHeightConstraint.constant = CGFloat((self.numberOfRows*70)+((treeView.numberOfRows() - self.numberOfRows)*57))
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
        
        
        UIView.setAnimationsEnabled(true)
    }
    
    /// Description:
    /// - Call grades data API functions based on the selected user.
    func getGradesAPI(){
        if SectionVC.didLoadGrades{
            return
        }
        switch user.userType{
        case 2:
//            if self.classObject.batchId != 0{
                getExams(user: self.user, sectionID: self.classObject.batchId)
//            }else{
//                self.teacherTermArray = []
//                self.subjectArray = []
//                self.averageTitle = ""
//                self.termRemarkTitle = ""
//                self.termRemarkBody = ""
//                self.averageTitleLabel.text = ""
//                self.currentTerm = Term(id: "", name: "", avg: 0, classAvg: 0, remarkTile: "", remarkBody: "", teacherName: "", subject: "", color: "", selected: false, subjectsArray: [])
//                self.gridView.reloadData()
//                self.termCollectionView.reloadData()
//                self.reloadTreeView()
//                self.reloadPage()
//            }
        case 3:
            gradeSettings(user: self.user, sectionId: self.user.batchId)
//            getGrades(user: self.user, studentUsername: self.user.userName)
        case 4:
            gradeSettings(user: self.user, sectionId: self.user.batchId)

//            getGrades(user: self.user, studentUsername: self.user.admissionNo)
        default:
            break
        }
    }
    
    /// Description:
    /// - Reload page view based on the selected user.
    func reloadPage(){
        print("called1")
        self.numberOfRows = treeView.numberOfRows()/2
        treeViewHeightConstraint.constant = CGFloat((self.numberOfRows*70)+((treeView.numberOfRows() - self.numberOfRows)*57))
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
        switch self.user.userType{
        case 2:
            treeViewToRemarksTopConstraints.isActive = false
            treeViewToCollectionTopConstraint.isActive = true
            UIView.animate(withDuration: 0.5) {
                self.view.setNeedsLayout()
            }
            gridView.isHidden = true
            gridBottomShadow.isHidden = true
            averageBottomShadow.layer.masksToBounds = true
            averageBottomShadow.backgroundColor = App.hexStringToUIColorCst(hex: "#D1D3D4", alpha: 0.5)
            collectionViewBottomShadow.isHidden = false
            termCollectionView.isHidden = false
            collectionViewBottomShadow.dropShadow()
            remarksLabel.isHidden = true
            print("remarks2")
            remarkTitleLabel.isHidden = true
            remarkBodyLabel.isHidden = true
//            remarkSignatureLabel.isHidden = true
            remarkBottomShadowView.isHidden = true
        default:
            treeViewToRemarksTopConstraints.isActive = true
            treeViewToCollectionTopConstraint.isActive = false
            UIView.animate(withDuration: 0.5) {
                self.view.setNeedsLayout()
            }
            gridView.isHidden = false
            gridBottomShadow.isHidden = false
            averageBottomShadow.layer.masksToBounds = false
            averageBottomShadow.backgroundColor = .white
            averageBottomShadow.dropTopShadow()
            gridBottomShadow.dropShadow()
            collectionViewBottomShadow.isHidden = true
            termCollectionView.isHidden = true
            self.initDataGrid(dataGridView: gridView)
            gridView.reloadData()
            remarksLabel.isHidden = false
            print("remarks3")
            remarkTitleLabel.isHidden = false
            remarkBodyLabel.isHidden = false
//            remarkSignatureLabel.isHidden = false
            remarkBottomShadowView.isHidden = false
            remarksLabel.text = "Remarks".localiz()
            remarkTitleLabel.text = self.termRemarkTitle
            remarkBodyLabel.text = self.termRemarkBody
            print("remarks1: \(self.termRemarkTitle)")
            print("remarks2: \(self.termRemarkBody)")
//            remarkSignatureLabel.text = "\(currentTerm.teacherName) - \(currentTerm.subject)"
        }
        if self.languageId == "ar"{
            nextImageView.image = UIImage(named: "calendar-left-arrow")
            previousImageView.image = UIImage(named: "calendar-right-arrow")
        }else{
            nextImageView.image = UIImage(named: "calendar-right-arrow")
            previousImageView.image = UIImage(named: "calendar-left-arrow")
        }
        previousAverageButton.dropCircleShadow()
        nextAverageButton.dropCircleShadow()
        averageTitleLabel.text = averageTitle
        self.remarkTitleLabel.text = termRemarkTitle
        self.remarkBodyLabel.text = termRemarkBody
        
        
        termCollectionView.reloadData()
//        self.view.layoutIfNeeded()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMarkSegue"{
            let addMark = segue.destination as! AddMarksViewController
            self.addGradeDelegate = addMark.self
            addMark.delegate = self
            addMark.addGradesDelegate = self
        }
    }
    
    @IBAction func previousAverageButtonPressed(_ sender: Any) {
        guard let titleIndex = self.averageTimeTable.firstIndex(where: {$0.name == self.averageTitle}) else{
            return
        }
        if titleIndex != 0{
            self.averageTitle = self.averageTimeTable[titleIndex-1].name
            self.termRemarkTitle = self.averageTimeTable[titleIndex - 1].termRemarkTitle
            self.termRemarkBody = self.averageTimeTable[titleIndex - 1].termRemarkBody

            if user.userType == 2{
                self.teacherTermArray = self.averageTimeTable[titleIndex-1].values
                if !teacherTermArray.isEmpty{
                    self.currentTerm = teacherTermArray.first!
                    self.subjectArray = currentTerm.subjectsArray
                }else{
                    self.subjectArray = []
                }
            }else{
                self.subTermArray = self.averageTimeTable[titleIndex-1].values
                if let subTerm = subTermArray.first{
                    self.currentTerm = subTerm
                    self.subjectArray = currentTerm.subjectsArray
                }
            }
            print("remarks5")
            self.remarkTitleLabel.text = self.termRemarkTitle
            self.remarkBodyLabel.text = self.termRemarkBody

            self.gridView.reloadData()
            self.reloadTreeView()
            self.reloadPage()
            updateMenuExams(examId: self.averageTimeTable[titleIndex-1].id)
        }
    }
    
    @IBAction func nextAverageButtonPressed(_ sender: Any) {
        guard let titleIndex = self.averageTimeTable.firstIndex(where: {$0.name == self.averageTitle}) else{
            return
        }
        if titleIndex != self.averageTimeTable.count - 1{
            self.averageTitle = self.averageTimeTable[titleIndex+1].name
            self.termRemarkTitle = self.averageTimeTable[titleIndex + 1].termRemarkTitle
            self.termRemarkBody = self.averageTimeTable[titleIndex + 1].termRemarkBody
            if user.userType == 2{
                self.teacherTermArray = self.averageTimeTable[titleIndex+1].values
                if !teacherTermArray.isEmpty{
                    self.currentTerm = teacherTermArray.first!
                    self.subjectArray = currentTerm.subjectsArray
                }else{
                    self.subjectArray = []
                }
            }else{
                self.subTermArray = self.averageTimeTable[titleIndex+1].values
                if let subTerm = subTermArray.first{
                    self.currentTerm = subTerm
                    self.subjectArray = currentTerm.subjectsArray
                }
            }
            print("remarks6")
            self.remarkTitleLabel.text = self.termRemarkTitle
            self.remarkBodyLabel.text = self.termRemarkBody
            
            self.gridView.reloadData()
            self.reloadTreeView()
            self.reloadPage()
            updateMenuExams(examId: self.averageTimeTable[titleIndex+1].id)
        }
    }
    
    /// Description:
    /// - Call initAverage function inside Sections page to update the selected exam menu.
    func updateMenuExams(examId: String){
        var examArray: [Exam] = []
        for average in self.averageTimeTable{
            if average.id == examId{
                let object = Exam.init(id: average.id, name: average.name, selected: true)
                examArray.append(object)
            }else{
                let object = Exam.init(id: average.id, name: average.name, selected: false)
                examArray.append(object)
            }
        }
        self.delegate?.initAverage(exams: examArray)
    }
    
}

// MARK: - XLPagerTabStrip Method:
// Initialize Grades module.
extension GradesViewController: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Grades".localiz(), counter: "", image: UIImage(named: "grades"), backgroundViewColor: App.hexStringToUIColorCst(hex: "#f69c9c", alpha: 1.0), id: App.gradesID)
    }
    
}

// MARK: - DataGrid View functions:
extension GradesViewController: DataGridViewDelegate, DataGridViewDataSource{
    func numberOfColumnsInDataGridView(_ dataGridView: DataGridView) -> Int {
        if user.userType == 2{
            return 0
        }
        return subTermArray.count
    }
    
    func numberOfRowsInDataGridView(_ dataGridView: DataGridView) -> Int {
        if user.userType == 2{
            return 0
        }
        return 2
    }
    
    func dataGridView(_ dataGridView: DataGridView, viewForHeaderForColumn column: Int) -> DataGridViewColumnHeaderCell {
        let cell = dataGridView.dequeueReusableHeaderViewWithReuseIdentifier("columnReuse", forColumn: column) as! ColumnHeaderCell
        cell.headerButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 10)
        cell.headerButton.titleLabel?.numberOfLines = 0
        cell.headerButton.tintColor = .white
        cell.headerButton.setTitleColor(.white, for: .normal)
        print("celll: \(subTermArray[column].name)")
        print("average: \(subTermArray[column].avg)")
        UIView.performWithoutAnimation {
            cell.headerButton.setTitle(subTermArray[column].name, for: .normal)
            cell.headerButton.layoutIfNeeded()
        }
        cell.headerButton.addTarget(self, action: #selector(subTermPressed), for: .touchUpInside)
        cell.headerButton.layer.cornerRadius = cell.headerButton.frame.height / 2
        cell.headerButton.backgroundColor = App.hexStringToUIColor(hex: subTermArray[column].color, alpha: 1.0)
        cell.headerButton.dropCircleShadow()
        
        return cell
    }
    
    func dataGridView(_ dataGridView: DataGridView, viewForHeaderForRow row: Int) -> DataGridViewRowHeaderCell {
        let cell = dataGridView.dequeueReusableHeaderViewWithReuseIdentifier("rowReuse", forRow: row) as! RowHeaderCell
        cell.rowHeaderTitle.isHidden = true
        cell.averageHeaderTitle.titleLabel?.numberOfLines = 0
        cell.averageHeaderTitle.titleLabel?.lineBreakMode = .byWordWrapping
        var backgroundColor = ""
        UIView.performWithoutAnimation {
            if row == 0{
                cell.averageHeaderTitle.setTitle("Avg".localiz(), for: .normal)
                backgroundColor = "#014e80"
            }else{
                cell.averageHeaderTitle.setTitle("Class\nAvg.".localiz(), for: .normal)
                backgroundColor = "#236ce2"
            }
            cell.averageHeaderTitle.layoutIfNeeded()
        }
        cell.averageHeaderTitle.titleLabel?.textAlignment = .center
        cell.averageHeaderTitle.layer.cornerRadius = cell.averageHeaderTitle.frame.height / 2
        cell.averageHeaderTitle.backgroundColor = App.hexStringToUIColor(hex: backgroundColor, alpha: 1.0)
        cell.averageHeaderTitle.dropCircleShadow()
        cell.layoutIfNeeded()
        return cell
    }
    
    func dataGridView(_ dataGridView: DataGridView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dataGridView.dequeueReusableCellWithReuseIdentifier("DataCell", forIndexPath: indexPath) as! DataGridCollectionViewCell
        cell.border.bottomWidth = 1 / UIScreen.main.scale
        cell.border.rightWidth = 0 / UIScreen.main.scale
        cell.border.bottomColor = Colors.border
        cell.border.rightColor = Colors.border
//        cell.cellIcon.sizeToFit()
//        cell.cellIcon.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true

        if indexPath.dataGridRow == 0{
            if(subTermArray[indexPath.dataGridColumn].avg.rounded() == 0.0){
                cell.cellIcon.setTitle("-", for: .normal)
                

            }
            else{
                let avg = (subTermArray[indexPath.dataGridColumn].avg * 100).rounded() / 100
                print("average number: \(avg)")
                cell.cellIcon.setTitle("\(avg)", for: .normal)
            }
        }else{
            if(subTermArray[indexPath.dataGridColumn].classAvg == 0.0){
                cell.cellIcon.setTitle("-", for: .normal)

            }
            else{
                let avg = (subTermArray[indexPath.dataGridColumn].classAvg * 100).rounded() / 100

                print("total total classAVG: \(avg)")
                cell.cellIcon.setTitle("\(avg)", for: .normal)
            }
            
        }
                
        cell.cellIcon.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 12)
        cell.cellIcon.setTitleColor(App.hexStringToUIColorCst(hex: "#5d5d5d", alpha: 1.0), for: .normal)
        cell.configureIndexPath(indexPath: indexPath)
    
//        cell.cellIcon.addTarget(self, action: #selector(averagePressed), for: .touchUpInside)
        return cell
    }
    
    func dataGridView(_ dataGridView: DataGridView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func initDataGrid(dataGridView: DataGridView){
        dataGridView.delegate = self
        dataGridView.dataSource = self
        
        let dataGridAppearance = DataGridView.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
        dataGridAppearance.row1BackgroundColor = nil
        dataGridAppearance.row2BackgroundColor = nil
        
        let cornerHeaderAppearance = DataGridViewCornerHeaderCell.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
        cornerHeaderAppearance.backgroundColor = Colors.headerBackground
        cornerHeaderAppearance.borderLeftWidth = 0 / UIScreen.main.scale
        cornerHeaderAppearance.borderTopWidth = 0 / UIScreen.main.scale
        cornerHeaderAppearance.borderRightWidth = 0 / UIScreen.main.scale
        cornerHeaderAppearance.borderBottomWidth = 0 / UIScreen.main.scale
        cornerHeaderAppearance.borderLeftColor = Colors.border
        cornerHeaderAppearance.borderTopColor = Colors.border
        cornerHeaderAppearance.borderRightColor = Colors.border
        cornerHeaderAppearance.borderBottomColor = Colors.border
        
        let rowHeaderAppearance = DataGridViewRowHeaderCell.glyuck_appearanceWhenContained(in :AttendanceTimeTableViewController.self)!
        rowHeaderAppearance.backgroundColor = Colors.headerBackground
        rowHeaderAppearance.borderLeftWidth = 0 / UIScreen.main.scale
        rowHeaderAppearance.borderBottomWidth = 0 / UIScreen.main.scale
        rowHeaderAppearance.borderRightWidth = 0 / UIScreen.main.scale
        rowHeaderAppearance.borderLeftColor = Colors.border
        rowHeaderAppearance.borderBottomColor = Colors.border
        rowHeaderAppearance.borderRightColor = Colors.border
        
        let rowHeaderLabelAppearane = UILabel.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self, class2: DataGridViewRowHeaderCell.self)!
        rowHeaderLabelAppearane.appearanceTextAlignment = .right
        
        let columnHeaderAppearance = DataGridViewColumnHeaderCell.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
        columnHeaderAppearance.backgroundColor = Colors.headerBackground
        columnHeaderAppearance.borderTopWidth = 0 / UIScreen.main.scale
        columnHeaderAppearance.borderBottomWidth = 0 / UIScreen.main.scale
        columnHeaderAppearance.borderRightWidth = 0 / UIScreen.main.scale
        columnHeaderAppearance.borderTopColor = Colors.border
        columnHeaderAppearance.borderBottomColor = Colors.border
        columnHeaderAppearance.borderRightColor = Colors.border
        
        let cellAppearance = DataGridViewContentCell.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
        cellAppearance.borderRightWidth = 0 / UIScreen.main.scale
        cellAppearance.borderRightColor = UIColor(white: 0.73, alpha: 1)
        cellAppearance.borderBottomWidth = 1 / UIScreen.main.scale
        cellAppearance.borderBottomColor = UIColor(white: 0.73, alpha: 1)
        
        columnHeaderAppearance.backgroundColor = UIColor(white: 0.95, alpha: 1)
        let labelAppearance = UILabel.glyuck_appearanceWhenContained(in: AttendanceTimeTableViewController.self)!
        labelAppearance.appearanceFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
        labelAppearance.appearanceTextAlignment = .center
        
        dataGridView.columnHeaderHeight = 42
        dataGridView.rowHeaderWidth = 60
        //        dataGridView.rowHeight = 40
        dataGridView.registerNib(UINib(nibName: "DataGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DataCell")
        dataGridView.registerNib(UINib(nibName: "ColumnHeaderCell", bundle: nil), forHeaderOfKind: .ColumnHeader, withReuseIdentifier: "columnReuse")
        dataGridView.registerNib(UINib(nibName: "RowHeaderCell", bundle: nil), forHeaderOfKind: .RowHeader, withReuseIdentifier: "rowReuse")
        //        dataGridView.registerNib(UINib(nibName: "CornerHeaderCell", bundle: nil), forHeaderOfKind: .CornerHeader, withReuseIdentifier: "cornerReuse")
    }
    
    @objc func subTermPressed(sender: UIButton){
        print("pressed pressed")
        let cell = sender.superview?.superview as! ColumnHeaderCell
//        let term = self.averageTimeTable[cell.indexPath.dataGridRow].values[cell.indexPath.dataGridColumn]
        let subTerm = self.subTermArray[cell.indexPath.dataGridRow]
        
        self.currentTerm = subTerm
        self.termRemarkTitle = self.currentTerm.remarkTile
        self.termRemarkBody = self.currentTerm.remarkBody
        
        print("subterm1: \(self.currentTerm.name)")
        print("subterm2: \(self.currentTerm.remarkTile)")
        print("subterm3: \(self.currentTerm.remarkBody)")
        
//        self.remarkTitleLabel.text = self.currentTerm.remarkTile
//        self.remarkBodyLabel.text = self.currentTerm.remarkBody
        
        self.subjectArray = subTerm.subjectsArray
        self.reloadTreeView()
        self.reloadPage()
    }
    
}


// MARK: - //RATreeView Delegate and DataSource Functions:
extension GradesViewController: RATreeViewDataSource, RATreeViewDelegate{
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
       
        if let item = item as? DataObject{
            return item.children.count
        }else{
            print("children: \(self.treeData.count)")
            return self.treeData.count
        }
    }

    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? DataObject{
            return item.children[index]
        }else{
            return treeData[index] as AnyObject
        }
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let level = treeView.levelForCell(forItem: item as Any)
        if level == 0{
            let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: SubjectHeaderTableViewCell.self)) as! SubjectHeaderTableViewCell
            let item = item as! DataObject
            
            print("items2: \(item.title)")
            if item.icon.contains("http"){
                let url = URL(string: item.icon)
                cell.subjectImageView.sd_setImage(with: url, completed: nil)
            }else if item.icon != ""{
                cell.subjectImageView.image = UIImage(named: item.icon)
            }else{
                cell.subjectImageView.image = UIImage()
            }
            cell.subjectGroupLabel.text = item.subjectTile
            
            let itemIndex = treeData.firstIndex(where: {$0 === item})
            switch itemIndex{
            case 0:
                cell.lineView.isHidden = true
            default:
                if user.userType == 2{
                    cell.lineView.isHidden = true
                }else{
                    cell.lineView.isHidden = false
                }
            }
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: SubjectTableViewCell.self)) as! SubjectTableViewCell
            let item = item as! DataObject
            var parent: DataObject
            var index = -1
            switch level{
            case 1:
                parent = treeView.parent(forItem: item) as! DataObject
            case 2:
                let child = treeView.parent(forItem: item) as! DataObject
                parent = treeView.parent(forItem: child) as! DataObject
            default:
                let child = treeView.parent(forItem: item) as! DataObject
                let childParent = treeView.parent(forItem: child) as! DataObject
                parent = treeView.parent(forItem: childParent) as! DataObject
            }
            let parentIndex = treeData.firstIndex(where: {$0 === parent})
            if parentIndex == treeData.count-1{
                index = self.subjectArray.count-1
            }else{
                for data in treeData{
                    index = data.children.firstIndex(where: {$0 === item}) ?? -1
                    index += 1
                }
            }
            
            let currentSection = index
            
            if item.isOpen{
                cell.expendButton.setImage(UIImage(named: "-"), for: .normal)
            }else{
                cell.expendButton.setImage(UIImage(named: "+"), for: .normal)
            }
            var color = item.color
            if color.isEmpty{
                color = "#fa487a"
            }
            cell.setup(withItem: item, title: item.title, mark: item.mark, backgroundColor: color, level: level, userType: user.userType, currentSection: currentSection, maxSection: self.subjectArray.count, checked: item.checked, user: self.user)
            cell.tickButton.addTarget(self, action: #selector(tickButtonPressed), for: .touchUpInside)
            cell.enterGradeButton.addTarget(self, action: #selector(enterGradesButtonPressed), for: .touchUpInside)
            cell.selectionStyle = .none
            if parentIndex == 0 || (parentIndex == treeData.count-1 && level == 2) || self.user.userType == 2{
                cell.topView.isHidden = true
            }else{
                cell.topView.isHidden = false
            }
            
            return cell
        }
    }
    
    /// Description: Init TreeView Data
    /// - This function take data returned from the API and tranform them into special shape that works with TreeView.
    func commonInit(items: [SubjectHeaderItem]) -> [DataObject] {
        var dataObject: [DataObject] = []
        for (i,subject) in items.enumerated(){
            print("subject title: \(subject.subjectTitle)")

            var dataArray: [DataObject] = []
            for item in subject.items{
                var childArray: [DataObject] = []
                for term in item.terms{
                    let child = DataObject.init(id: term.termId, name: term.termName, code: subject.subjectCode, mark: term.termsMark, fullMark: term.fullMark, subTerms: [], color: subject.subjectColor, isOpen: false, subjectIcon: "", subjectTitle: subject.subjectTitle, checked: subject.checked, editable: term.editable)
                    childArray.append(child)
                }
                let dataObject = DataObject.init(id: item.id, name: item.subName, code: subject.subjectCode, mark: item.subMark, fullMark: item.fullMark, subTerms: childArray, color: subject.subjectColor, isOpen: item.isOpen, subjectIcon: "", subjectTitle: subject.subjectTitle, checked: subject.checked, editable: item.editable)
                dataArray.append(dataObject)
            }
            let headerObject = DataObject.init(id: subject.id, name: subject.subjectTitle, code: subject.subjectCode, mark: subject.subjectMark, fullMark: subject.fullMark, subTerms: dataArray, color: subject.subjectColor, isOpen: subject.isOpen, subjectIcon: subject.subjectIcon, subjectTitle: subject.subjectTitle, checked: subject.checked, editable: subject.editable)
            var subjectHeader = ""
            if i == 0{
                subjectHeader = "Subject Group".localiz()
            }
            let dataObjectArray = DataObject.init(id: subject.id, name: subject.subjectTitle, code: subject.subjectCode, mark: subject.subjectMark, fullMark: subject.fullMark,child: [headerObject], color: subject.subjectColor, isOpen: subject.isOpen, subjectIcon: subject.subjectIcon, subjectTitle: subjectHeader, checked: subject.checked, editable: subject.editable)
            dataObject.append(dataObjectArray)
        }
        
        return dataObject
    }
    
    func treeView(_ treeView: RATreeView, heightForRowForItem item: Any) -> CGFloat {
        let level = treeView.levelForCell(forItem: item)
        switch level{
        case 0:
            return 70
        default:
            return UITableView.automaticDimension
        }
    }
    
    func treeView(_ treeView: RATreeView, didSelectRowForItem item: Any) {
        treeView.deselectRow(forItem: item, animated: false)
        guard let item = item as? DataObject else{
            return
        }
        
        let level = treeView.levelForCell(forItem: item)
        if level != 0{
            item.isOpen = !item.isOpen
            let cell = treeView.cell(forItem: item) as! SubjectTableViewCell
            if item.isOpen{
                UIView.animate(withDuration: 0.2) { () -> Void in
                    cell.expendButton.transform = CGAffineTransform(rotationAngle: CGFloat(App.radians(180.0)))
                }
                cell.expendButton.setImage(UIImage(named: "-"), for: .normal)
            }else{
                UIView.animate(withDuration: 0.2) { () -> Void in
                    cell.expendButton.transform = CGAffineTransform.identity
                }
                cell.expendButton.setImage(UIImage(named: "+"), for: .normal)
            }
        }
    }
    
    func treeView(_ treeView: RATreeView, shouldExpandRowForItem item: Any) -> Bool {
        let level = treeView.levelForCell(forItem: item)
        if level == 0{
            return false
        }else{
            return true
        }
    }
    
    func treeView(_ treeView: RATreeView, shouldCollapaseRowForItem item: Any) -> Bool {
        let level = treeView.levelForCell(forItem: item)
        if level == 0{
            return false
        }else{
            return true
        }
    }
    
    func treeView(_ treeView: RATreeView, canEditRowForItem item: Any) -> Bool {
        return false
    }
    
    func treeView(_ treeView: RATreeView, didExpandRowForItem item: Any) {
        print("called2")
        self.numberOfRows = treeView.numberOfRows()/2
        treeViewHeightConstraint.constant = CGFloat((self.numberOfRows*70)+((treeView.numberOfRows() - self.numberOfRows)*57))
        UIView.animate(withDuration: 0.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func treeView(_ treeView: RATreeView, didCollapseRowForItem item: Any) {
        print("called3")
        self.numberOfRows = treeView.numberOfRows()/2
        treeViewHeightConstraint.constant = CGFloat((self.numberOfRows*70)+((treeView.numberOfRows() - self.numberOfRows)*57))
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func enterGradesButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! SubjectTableViewCell
        guard let item = treeView.item(for: cell) as? DataObject else{
            return
        }
        let level = treeView.level(for: cell)
        var type = ""
        switch level{
        case 1:
            type = "exam"
        case 2:
            type = "sub_exam"
        case 3:
            type = "assessment"
        default:
            break
        }
        
        print("item code: \(item.code)")
        addGradeDelegate?.QuizInfo(quizId: item.id, type: type, sectionId: self.classObject.batchId, user: self.user, term: self.averageTitle, subTerm: self.currentTerm.name, subject: item.code, level: item.title, fullMark: item.fullMark, editable: item.editable)
        addMarkView.isHidden = false
        self.addMarkView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.addMarkView.alpha = 1
        }
        SectionVC.canChangeClass = false
    }
    
    @objc func tickButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! SubjectTableViewCell
        guard let item = treeView.item(for: cell) as? DataObject else{
            return
        }
        if item.checked{
//            print(item.id)
        }else{
//            print(item.id)
        }
    }
}

// MARK: - UICollectionView Functions:
extension GradesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teacherTermArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "termCollectionReuse", for: indexPath)
        let termNameButton = cell.viewWithTag(25) as! UIButton
        let termView: UIView? = cell.viewWithTag(26)
        let term = teacherTermArray[indexPath.row]
        UIView.performWithoutAnimation {
            termNameButton.setTitle(term.name, for: .normal)
            termNameButton.layoutIfNeeded()
        }
        
        termNameButton.backgroundColor = App.hexStringToUIColor(hex: term.color, alpha: 1.0)
        termNameButton.layer.cornerRadius = termNameButton.layer.frame.height / 2
        termNameButton.addTarget(self, action: #selector(titleButtonPressed), for: .touchUpInside)
        if term.selected{
            termView?.isHidden = false
            termView?.backgroundColor = App.hexStringToUIColor(hex: term.color, alpha: 1.0)
        }else{
            termView?.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select collectionview")
        teacherTermArray = teacherTermArray.map{
            var term = $0
            term.selected = false
            return term
        }
        teacherTermArray[indexPath.row].selected = true
        collectionView.reloadData()
        self.currentTerm = teacherTermArray[indexPath.row]
        
       
        self.subjectArray = currentTerm.subjectsArray
        self.reloadTreeView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Make sure that the number of items is worth the computing effort.
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
            let dataSourceCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
            dataSourceCount > 0 else {
                return .zero
        }
        
        let cellCount = CGFloat(dataSourceCount)
        let itemSpacing = flowLayout.minimumInteritemSpacing
        let cellWidth = flowLayout.itemSize.width + itemSpacing
        var insets = flowLayout.sectionInset
        
        // Make sure to remove the last item spacing or it will
        // miscalculate the actual total width.
        let totalCellWidth = (cellWidth * cellCount) - itemSpacing
        let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
        
        // If the number of cells that exist take up less room than the
        // collection view width, then center the content with the appropriate insets.
        // Otherwise return the default layout inset.
        guard totalCellWidth < contentWidth else {
            return insets
        }
        
        // Calculate the right amount of padding to center the cells.
        let padding = (contentWidth - totalCellWidth) / 2.0
        insets.left = padding
        insets.right = padding
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.01
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.01
    }
    
    @objc func titleButtonPressed(sender: UIButton){
        print("remarks7")

        let cell = sender.superview?.superview as! UICollectionViewCell
        let index = self.termCollectionView.indexPath(for: cell)
        teacherTermArray = teacherTermArray.map{
            var term = $0
            term.selected = false
            return term
        }
        teacherTermArray[index!.row].selected = true
        termCollectionView.reloadData()
        self.currentTerm = teacherTermArray[index!.row]
        
        
        self.subjectArray = currentTerm.subjectsArray
        self.reloadTreeView()
    }
}

// MARK: - Handle Sections page and Add Remarks page delegate functions:
extension GradesViewController: AddRemarksViewControllerDelegate, SectionVCToGradesDelegate{
    
    func removeLoading() {
    }
    
    /// Description:
    /// - Called from AddGrades page to show Grades view.
    func backToGrades() {
        UIView.animate(withDuration: 0.5) {
            self.addMarkView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.addMarkView.isHidden = true
        }
        self.delegate?.showTopView()
        IQKeyboardManager.shared.resignFirstResponder()
    }
    
    /// Description:
    ///
    /// - Parameters:
    ///   - batchId: In case the user is parent batch well be nil.
    ///   - children: In case the user is employee children will be nil.
    /// - This function is called from Section page when user changed.
    func switchGradesChildren(user: User, batchId: Int?, children: Children?) {
        self.user = user
        self.classObject.batchId = batchId ?? 0
        if self.treeViewHeightConstraint != nil{
            backToGrades()
            SectionVC.didLoadGrades = false
            print("agenda grades api2")
            self.getGradesAPI()
        }
    }
    
    /// Description:
    /// - Called from Sections page when user select an item from the option menu to update page data.
    func updateAverage(exam: Exam) {
        guard let titleIndex = self.averageTimeTable.firstIndex(where: {$0.name == exam.name}) else{
            return
        }
        self.averageTitle = self.averageTimeTable[titleIndex].name
        self.termRemarkTitle = self.averageTimeTable[titleIndex].termRemarkTitle
        self.termRemarkBody = self.averageTimeTable[titleIndex].termRemarkBody
        if user.userType == 2{
            self.teacherTermArray = self.averageTimeTable[titleIndex].values
            if !teacherTermArray.isEmpty{
                self.subjectArray = teacherTermArray.first!.subjectsArray
            }else{
                self.subjectArray = []
            }
        }else{
            self.subTermArray = self.averageTimeTable[titleIndex].values
        }
        
        print("remarks1")
        self.remarkTitleLabel.text = self.termRemarkTitle
        self.remarkBodyLabel.text = self.termRemarkBody
        
        self.gridView.reloadData()
        self.reloadTreeView()
        self.reloadPage()
        backToGrades()
        updateMenuExams(examId: self.averageTimeTable[titleIndex].id)
    }
    
    /// Description:
    /// - This function is called from Section page when colors and icons changed.
    func updateGradesTheme(appTheme: AppTheme) {
        self.appTheme = appTheme
        if self.treeViewHeightConstraint != nil{
            if self.appTheme!.activeModule.contains(where: {$0.id == App.gradesID && $0.status == 1}){
                print("entered updateGradesTheme1")
                getGradesAPI()
            }else{
                print("entered updateGradesTheme2")
                delegate?.gradesToCalendar()
            }
        }
    }
    
    /// Description:
    /// - This function is called from Section page when class changed.
    func gradesBatchId(batchId: Int) {
        if self.treeViewHeightConstraint != nil{
            self.classObject.batchId = batchId
            self.addGradeDelegate?.updateStudentList(user: self.user, batchId: classObject.batchId)
//            SectionVC.didLoadGrades = false
            print("agenda grades api3")
            self.getGradesAPI()
        }
    }
    
    func gradesBatchIdPassive(batchId: Int) {
        if self.treeViewHeightConstraint != nil{
            self.classObject.batchId = batchId
        }
    }
    
    func addLoading() {
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
    }

}

// MARK: - API Calls:
extension GradesViewController{
    
    /// Description:
    /// - Call "get_grades" API and update menu data in Sections page.
    func gradeSettings(user: User, sectionId: Int){
        
//        let indicatorView = App.loading()
//        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
        
//        if !self.refreshControl.isRefreshing{
//            self.view.superview?.superview?.insertSubview(self.loading, at: 1)
//        }
        self.gridView.isHidden = true
        self.treeView.isHidden = true
        Request.shared.getGradeSettings(user: user, sectionId: sectionId) { (messge, data, status) in
            if status == 200{
                if let viewWithTag = self.view.viewWithTag(100){
                    viewWithTag.removeFromSuperview()
                }
                    let fullMark = data["fullMark"].stringValue
                    self.getGrades(user: user, sectionId: sectionId, fullMark: fullMark, appTheme: self.appTheme)

             
            }else{
                if !self.refreshControl.isRefreshing{
                               self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
                           }else{
                               self.refreshControl.endRefreshing()
                           }
            }
            self.gridView.reloadData()
            self.reloadTreeView()
            self.reloadPage()
            self.gridView.isHidden = false
            self.treeView.isHidden = false
//            if !self.refreshControl.isRefreshing{
//                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
//            }else{
//                self.refreshControl.endRefreshing()
//            }
//            if let viewWithTag = self.view.viewWithTag(100){
//                viewWithTag.removeFromSuperview()
//            }
        }
        
    }
    /// Description:
    /// - Call "get_grades" API and update menu data in Sections page.
    func getGrades(user: User, sectionId: Int, fullMark: String, appTheme: AppTheme){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
//        if !self.refreshControl.isRefreshing{
//            self.view.superview?.superview?.insertSubview(self.loading, at: 1)
//        }
        self.gridView.isHidden = true
        self.treeView.isHidden = true
        Request.shared.getGrades(user: user, sectionId: sectionId, fullMark: fullMark, theme: appTheme) { (messge, data, status) in
            if status == 200{
                if let viewWithTag = self.view.viewWithTag(100){
                    viewWithTag.removeFromSuperview()
                }
                print("grades grades: \(data)")
                self.averageTimeTable = data!
                let subTerms = self.averageTimeTable.first?.values
                if subTerms != nil{
                    if !subTerms!.isEmpty{
                        self.subTermArray = subTerms!
                        self.subjectArray = subTerms!.first!.subjectsArray
                        self.averageTitle = self.averageTimeTable.first!.name
                        self.termRemarkTitle = self.averageTimeTable.first!.termRemarkTitle
                        self.termRemarkBody = self.averageTimeTable.first!.termRemarkBody
                        var examArray: [Exam] = []
                        for (index,average) in self.averageTimeTable.enumerated(){
                            if index == 0{
                                let object = Exam.init(id: average.id, name: average.name, selected: true)
                                examArray.append(object)
                            }else{
                                let object = Exam.init(id: average.id, name: average.name, selected: false)
                                examArray.append(object)
                            }
                        }
                        self.delegate?.initAverage(exams: examArray)
                    }
                }
            }else{
                if !self.refreshControl.isRefreshing{
                               self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
                           }else{
                               self.refreshControl.endRefreshing()
                           }
            }
            self.gridView.reloadData()
            self.reloadTreeView()
            self.reloadPage()
            self.gridView.isHidden = false
            self.treeView.isHidden = false
//            if !self.refreshControl.isRefreshing{
//                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
//            }else{
//                self.refreshControl.endRefreshing()
//            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
        
    }
    
    /// Description:
    /// - Call "get_exams" API and update menu data in Sections page.
    func getExams(user: User, sectionID: Int){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 18756
        self.view.addSubview(indicatorView)
        
        if !self.refreshControl.isRefreshing{
            self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        }
        self.termCollectionView.isHidden = true
        self.treeView.isHidden = true
        Request.shared.getExams(user: user, sectionId: sectionID, theme: appTheme) { (message, data, status) in
            if status == 200{
                if let viewWithTag = self.view.viewWithTag(18756){
                    viewWithTag.removeFromSuperview()
                }
                self.averageTimeTable = data!
                let subTerms = self.averageTimeTable.first?.values
                
                print("subterm: ", subTerms)
                print("subterm: ", self.averageTimeTable)
                print("subterm: ", self.averageTimeTable.first)

                if self.averageTimeTable != nil{
                    if subTerms != nil{
                        if subTerms != nil && !subTerms!.isEmpty{
                            self.teacherTermArray = subTerms!
                            self.subjectArray = subTerms!.first!.subjectsArray
                            self.averageTitle = self.averageTimeTable.first!.name
                            self.termRemarkTitle = self.averageTimeTable.first!.termRemarkTitle
                            self.termRemarkBody = self.averageTimeTable.first!.termRemarkBody
                            
                            self.averageTitleLabel.text = self.averageTitle
                            self.currentTerm = self.teacherTermArray.first!
                            var examArray: [Exam] = []
                            for (index,average) in self.averageTimeTable.enumerated(){
                                if index == 0{
                                    let object = Exam.init(id: average.id, name: average.name, selected: true)
                                    examArray.append(object)
                                }else{
                                    let object = Exam.init(id: average.id, name: average.name, selected: false)
                                    examArray.append(object)
                                }
                            }
                            self.delegate?.initAverage(exams: examArray)
                        }
                        else if(!self.averageTimeTable.isEmpty){
        //                        self.teacherTermArray = self.averageTimeTable.first!.
        //                        self.subjectArray = self.averageTimeTable.first!.subjectsArray
                                self.averageTitle = self.averageTimeTable.first!.name
                                self.termRemarkTitle = self.averageTimeTable.first!.termRemarkTitle
                                self.termRemarkBody = self.averageTimeTable.first!.termRemarkBody
                                
                                self.averageTitleLabel.text = self.averageTitle
        //                        self.currentTerm = self.teacherTermArray.first!
                                var examArray: [Exam] = []
                                for (index,average) in self.averageTimeTable.enumerated(){
                                    if index == 0{
                                        let object = Exam.init(id: average.id, name: average.name, selected: true)
                                        examArray.append(object)
                                    }else{
                                        let object = Exam.init(id: average.id, name: average.name, selected: false)
                                        examArray.append(object)
                                    }
                                }
                                self.delegate?.initAverage(exams: examArray)
                            
                        }
                        else{
                            self.teacherTermArray = []
                            self.subjectArray = []
                            self.averageTitle = ""
                            self.termRemarkTitle = ""
                            self.termRemarkBody = ""
                            self.averageTitleLabel.text = ""
                            self.currentTerm = Term(id: "", name: "", avg: 0, classAvg: 0, remarkTile: "", remarkBody: "", teacherName: "", subject: "", color: "", selected: false, subjectsArray: [])
                            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                            App.showAlert(self, title: "Error".localiz(), message: message ?? "", actions: [ok])
                        }
                    }
                    else{
                        self.teacherTermArray = []
                        self.subjectArray = []
                        self.averageTitle = ""
                        self.termRemarkTitle = ""
                        self.termRemarkBody = ""
                        self.averageTitleLabel.text = ""
                        self.currentTerm = Term(id: "", name: "", avg: 0, classAvg: 0, remarkTile: "", remarkBody: "", teacherName: "", subject: "", color: "", selected: false, subjectsArray: [])
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                        App.showAlert(self, title: "Error".localiz(), message: message ?? "", actions: [ok])
                    }


                }
            }else{
                self.teacherTermArray = []
                self.subjectArray = []
                self.averageTitle = ""
                self.termRemarkTitle = ""
                self.termRemarkBody = ""
                self.averageTitleLabel.text = ""
                self.currentTerm = Term(id: "", name: "", avg: 0, classAvg: 0, remarkTile: "", remarkBody: "", teacherName: "", subject: "", color: "", selected: false, subjectsArray: [])
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Error".localiz(), message: message ?? "", actions: [ok])
            }
            self.gridView.reloadData()
            self.termCollectionView.reloadData()
            self.reloadTreeView()
            self.reloadPage()
            self.treeView.isHidden = false
            self.termCollectionView.isHidden = false
            if !self.refreshControl.isRefreshing{
                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            }else{
                self.refreshControl.endRefreshing()
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
        if !self.refreshControl.isRefreshing{
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }else{
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - Handle AddGrades page delegate:
/// - Update view while enter and leave AddGrades page.
extension GradesViewController: AddGradesDelegate{
    func showTopView() {
        self.delegate?.showTopView()
    }
    
    func hideTopView() {
        self.delegate?.hideTopView()
    }
}
