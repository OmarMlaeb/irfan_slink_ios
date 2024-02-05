//
//  StudentsViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 9/5/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import PWSwitch

protocol StudentsViewControllerDelegate{
    func selectedStudents(students: [Student], std: String, parents: [Student])
}

class StudentsViewController: UIViewController, TableViewIndexDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chooseButton: UIButton!
    
    var studentList: [SortStudent] = []
    var section: [String] = []
    var tableViewIndexController: TableViewIndexController!
    var delegate: StudentsViewControllerDelegate?
    var students: [Student] = []
    var employees: [Student] = []
    var sectionId = ""
    var departmentId = ""
    var user: User!
    var term = "0"
    var type = ""
    var parents: [Student] = []
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")

    
    /// Description:
    /// - Init TableViewIndex and call getStudentList functions.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableViewIndexController = TableViewIndexController(scrollView: tableView)
        tableViewIndexController.tableViewIndex.delegate = self
        tableViewIndexController.tableViewIndex.isUserInteractionEnabled = true
        print("StudentsViewController sectionId", sectionId)
        if(sectionId == ""){
            print("dep employees: \(self.employees)")
            if(self.students.count == 0){
                getEmployeesByDepartment(user: user, departmentId: departmentId)

            }
            else{
                
//                self.sortStudents()
                self.tableView.isHidden = false
            }
        }
        else{
            getStudentsBySection(user: user, sectionId: sectionId)
            
        }
        
       
        
    }
    
    /// Description:
    /// - Call Table view index setup functions.
    override func viewDidAppear(_ animated: Bool) {
        updateIndexVisibility()
        updateHighlightedItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func addStudentParent(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = self.tableView.indexPath(for: cell)
        
        self.studentList[indexpath?.section ?? 0].students[indexpath?.row ?? 0].parent = !self.studentList[indexpath?.section ?? 0].students[indexpath?.row ?? 0].parent
        
    }
    /// Description
    /// - Sort students data to match with table view index.
    func sortStudents(students: [Student]){
        print("students first: \(students)")
        var stds = students.sorted {$0.index < $1.index}
        let array = Dictionary(grouping: stds, by: { $0.index})
        studentList = []
        for s in array{
            stds = []
            for st in s.value{
                stds.append(st)
            }
            let list = SortStudent(index: s.key, students: stds)
            studentList.append(list)
        }
        studentList = studentList.sorted(by: {$0.index < $1.index})

        print("studentList: \(studentList)")
        tableView.reloadData()
        tableViewIndexController.tableViewIndex.reloadData()
    }
    
    @IBAction func chooseButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            if(self.departmentId == ""){
                self.term = "1"
            }
            else{
                self.term = "0"
            }
            var students: [Student] = []
            for list in self.studentList{
                for student in list.students{
                    if student.selected{
                        students.append(student)
                    }
                }
            }
            for student in students{
                if(student.parent){
                    self.parents.append(student)
                }
            }
            self.delegate?.selectedStudents(students: students, std: self.term, parents: self.parents)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            var students: [Student] = []
            for list in self.studentList{
                for student in list.students{
                    if student.selected{
                        students.append(student)
                    }
                }
            }
            self.delegate?.selectedStudents(students: [], std: self.term, parents: [])
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return studentList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count count: \(studentList[section].students.count)")
        return studentList[section].students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("count count: \(studentList[indexPath.section].students.count)")

        let cell = tableView.dequeueReusableCell(withIdentifier: "studentReuse")
        let studentImage = cell?.viewWithTag(1) as! UIImageView
        let nameLabel = cell?.viewWithTag(2) as! UILabel
        let borderView = cell?.viewWithTag(3) as! UIImageView
        
        let uiSwitch = cell?.viewWithTag(741) as! PWSwitch
        uiSwitch.isHidden = true
        if(type == "inbox"){
            uiSwitch.isHidden = false
        }

        uiSwitch.addTarget(self, action: #selector(addStudentParent), for: .touchUpInside)
        let student = studentList[indexPath.section].students[indexPath.row]
        
        var icon = student.photo.unescaped
       
        
        if student.photo.unescaped != "" {
           
                if(student.gender.lowercased() == "m"){
                    studentImage.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))

                }
                else{
                    studentImage.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))

                }
            
        }else{
           
                if(student.gender.lowercased() == "m"){
                    studentImage.image = UIImage(named: "student_boy")
                }
                else{
                    studentImage.image = UIImage(named: "student_girl")
                }
            
            
        }
        
        nameLabel.text = student.fullName
        
        if student.selected{
            nameLabel.textColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
            borderView.isHidden = false
        }else{
            nameLabel.textColor = App.hexStringToUIColorCst(hex: "#6d6e71", alpha: 1.0)
            borderView.isHidden = true
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return studentList[section].index
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        studentList[indexPath.section].students[indexPath.row].selected = !studentList[indexPath.section].students[indexPath.row].selected
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.reloadData()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    /// TableView Index Functions:
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        tableView.sectionIndexColor = App.hexStringToUIColorCst(hex: "#6d6e71", alpha: 1.0)
        return self.studentList.map({return $0.index})
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateIndexVisibility()
        updateHighlightedItems()
    }
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) -> Bool {
        let originalOffset = tableView.contentOffset
        let sectionIndex = index
        if sectionIndex != NSNotFound {
            let rowCount = tableView.numberOfRows(inSection: sectionIndex)
            let indexPath = IndexPath(row: rowCount > 0 ? 0 : NSNotFound, section: sectionIndex)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        return tableView.contentOffset != originalOffset
    }
    
    func updateIndexVisibility() {
        guard let visibleIndexes = tableView.indexPathsForVisibleRows else {
            return
        }
        for indexPath in visibleIndexes {
            let cellFrame = view.convert(tableView.rectForRow(at: indexPath), to: nil)
            
            if view.convert(uncoveredTableViewFrame(), to: nil).intersects(cellFrame) {
                tableViewIndexController.setHidden(true, animated: true)
                return
            }
        }
        tableViewIndexController.setHidden(false, animated: true)
    }
    
    func updateHighlightedItems() {
        let frame = uncoveredTableViewFrame()
        var visibleSections = Set<Int>()
        
        for section in 0..<tableView.numberOfSections {
            if (frame.intersects(tableView.rect(forSection: section)) ||
                frame.intersects(tableView.rectForHeader(inSection: section))) {
                visibleSections.insert(section)
            }
        }
        let sortedSections = visibleSections.sorted()
        UIView.animate(withDuration: 0.25, animations: {
            for (index, item) in self.tableViewIndexController.tableViewIndex.items.enumerated() {
                let section = index
                let shouldHighlight = visibleSections.count > 0 && section >= sortedSections.first! && section <= sortedSections.last!
                
                item.tintColor = shouldHighlight ? UIColor.red : nil
            }
        })
    }
    
    func uncoveredTableViewFrame() -> CGRect {
        return CGRect(x: tableView.bounds.origin.x, y: tableView.bounds.origin.y + topLayoutGuide.length,
                      width: tableView.bounds.width, height: tableView.bounds.height - topLayoutGuide.length)
    }
    
}


//API Calls:
extension StudentsViewController{


    
    func getEmployeesByDepartment(user: User, departmentId: String){
        Request.shared.getEmployeesByDepartment2(user: user, departmentId: departmentId) { (message, departmentData, status) in
            if status == 200{
          
                self.employees = departmentData!
                self.sortStudents(students: self.employees)

                print("test test test1: \(self.employees[0]   )")

            }
            else{
                print("error", "getSectionsDepartments")
            }
        }
        
       
    }
    
    func getStudentsBySection(user: User, sectionId: String){
        Request.shared.getStudentsBySection2(user: user, sectionId: sectionId) { (message, sectionsData, status) in
            if status == 200{
                self.students = sectionsData!
                print("students selected: \(self.students)")
                self.sortStudents(students: self.students)
                
                self.tableView.reloadData()

            }
            else{
                print("error", "getSectionsDepartments")
            }
        }
        
       
    }

    
}
