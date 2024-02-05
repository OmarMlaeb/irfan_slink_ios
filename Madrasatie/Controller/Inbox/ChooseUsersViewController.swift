//
//  ChooseUsersViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 5/14/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit

protocol ChooseUsersViewControllerDelegate{
    func selectedUsers(users: [Student])
}

class ChooseUsersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var menuTableView: UITableView!
    
    var usersList: [SortStudent] = []
    var section: [String] = []
    var tableViewIndexController: TableViewIndexController!
    var delegate: ChooseUsersViewControllerDelegate?
    var students: [Student] = []
    var menuArray: [MenuItem] = [
        MenuItem(id: 1, name: "Students", value: 157, isSelected: true),
        MenuItem(id: 2, name: "Parents", value: 200, isSelected: false),
        MenuItem(id: 3, name: "Employees", value: 40, isSelected: false)
    ]
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")

    /// Description: Init TableViewIndex.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewIndexController = TableViewIndexController(scrollView: tableView)
        tableViewIndexController.tableViewIndex.delegate = self
        tableViewIndexController.tableViewIndex.isUserInteractionEnabled = true
        
        initUsersList()
        chooseButton.dropCircleShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initNavBar()
        self.setMessageMenu()
        self.title = "Choose a student"
    }
    
    /// Description:
    /// - Call functions to configure TableViewIndex.
    override func viewDidAppear(_ animated: Bool) {
        updateIndexVisibility()
        updateHighlightedItems()
    }
    
    override func optionButtonPressed(_ sender: UIButton) {
        if menuTableView.isHidden{
            menuTableView.isHidden = false
            menuTableView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.menuTableView.alpha = 1
            }
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.menuTableView.alpha = 0
            }) { (succes) in
                self.menuTableView.isHidden = true
            }
        }
    }
    
    func initUsersList(){
        students = []
        var student = Student(index: "A", id: "1", fullName: "Amanda Doe", photo: "small-profile-2", mark: 0, selected: false, gender: "m", parent: false)
        students.append(student)
        
        student = Student(index: "A", id: "2", fullName: "Andrew Doe", photo: "small-profile-2", mark: 0, selected: false, gender: "m", parent: false)
        students.append(student)
        
        student = Student(index: "B", id: "3", fullName: "Brianna Doe", photo: "small-profile-2", mark: 0, selected: false, gender: "m", parent: false)
        students.append(student)
        
        student = Student(index: "B", id: "4", fullName: "Bron Doe", photo: "small-profile-2", mark: 0, selected: false, gender: "m", parent: false)
        students.append(student)
        
        student = Student(index: "B", id: "5", fullName: "Brianna Doe", photo: "small-profile-2", mark: 0, selected: false, gender: "m", parent: false)
        students.append(student)
        
        student = Student(index: "C", id: "6", fullName: "C Doe", photo: "small-profile-2", mark: 0, selected: false, gender: "m", parent: false)
        students.append(student)
        
        student = Student(index: "D", id: "7", fullName: "D Doe", photo: "small-profile-2", mark: 0, selected: false, gender: "m", parent: false)
        students.append(student)
        
        self.sortStudents()
    }
    
    /// Description
    /// - Sort students data to match with table view index.
    func sortStudents(){
        students = students.sorted {$0.index < $1.index}
        let array = Dictionary(grouping: students, by: { $0.index})
        usersList = []
        for s in array{
            students = []
            for st in s.value{
                students.append(st)
            }
            let list = SortStudent(index: s.key, students: students)
            usersList.append(list)
        }
        usersList = usersList.sorted(by: {$0.index < $1.index})
        tableView.reloadData()
        tableViewIndexController.tableViewIndex.reloadData()
    }
    
    @IBAction func selectAllButtonPressed(_ sender: Any){
        usersList.forEach({$0.students.forEach({$0.selected = true})})
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.reloadData()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    @IBAction func chooseButtonPressed(_ sender: Any){
        self.dismiss(animated: true) {
            var users: [Student] = []
            for list in self.usersList{
                for student in list.students{
                    if student.selected{
                        users.append(student)
                    }
                }
            }
            self.delegate?.selectedUsers(users: users)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any){
        self.dismiss(animated: true) {
            self.delegate?.selectedUsers(users: [])
        }
    }

}

// MARK: - UITableView Delegate and DataSource Functions:
extension ChooseUsersViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView{
        case self.tableView:
            return usersList.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView{
        case self.tableView:
            return usersList[section].students.count
        default:
            return menuArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView{
        case self.tableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell")
            let studentImage = cell?.viewWithTag(1) as! UIImageView
            let nameLabel = cell?.viewWithTag(2) as! UILabel
            let borderView = cell?.viewWithTag(3) as! UIImageView
            let student = usersList[indexPath.section].students[indexPath.row]
                        
            var icon = student.photo.unescaped
           
            if(baseURL?.prefix(8) == "https://"){
                if(student.photo.unescaped.prefix(8) != "https://"){
                    icon = "https://" + icon
                }
            }
            else if(baseURL?.prefix(7) == "http://"){
                if (student.photo.unescaped.prefix(7) != "http://" ){
                    icon = "http://" + icon
                }
            }
            
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
            return cell!
        default:
            let cell = menuTableView.dequeueReusableCell(withIdentifier: "menuCell")
            let titleLabel = cell?.viewWithTag(1) as! UILabel
            let tickImageView = cell?.viewWithTag(2) as! UIImageView
            
            let item = menuArray[indexPath.row]
            titleLabel.text = "(\(item.value)) \(item.name)"
            if item.isSelected{
                tickImageView.isHidden = false
                titleLabel.textColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
            }else{
                tickImageView.isHidden = true
                titleLabel.textColor = App.hexStringToUIColorCst(hex: "#5D5D5D", alpha: 1.0)
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableView{
        case self.tableView:
            return usersList[section].index
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView{
        case self.tableView:
            return 72
        default:
            return 32
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView{
        case self.tableView:
            usersList[indexPath.section].students[indexPath.row].selected = !usersList[indexPath.section].students[indexPath.row].selected
            let currentOffset = tableView.contentOffset
            UIView.setAnimationsEnabled(false)
            tableView.reloadData()
            UIView.setAnimationsEnabled(true)
            tableView.setContentOffset(currentOffset, animated: false)
        default:
            self.menuArray.forEach({$0.isSelected = false})
            self.menuArray[indexPath.row].isSelected = true
            self.menuTableView.reloadData()
        }
    }
}

// MARK: - TableViewIndex Delegate Functions
extension ChooseUsersViewController: TableViewIndexDelegate{
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        switch tableView{
        case self.tableView:
            tableView.sectionIndexColor = App.hexStringToUIColorCst(hex: "#6d6e71", alpha: 1.0)
            return self.usersList.map({return $0.index})
        default:
            return nil
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateIndexVisibility()
        updateHighlightedItems()
    }
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) -> Bool {
        switch tableView{
        case self.tableView:
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
        default:
            return false
        }
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
