//
//  AddRemarksViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 10/26/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

// Description:
/// - Delegate from Add Grades page to Grades page.
protocol AddRemarksViewControllerDelegate{
    func backToGrades()
    func addLoading()
    func removeLoading()
}

// Description:
/// - Delegate from Add Grades page to Grades page.
protocol AddGradesDelegate{
    func hideTopView()
    func showTopView()
}

class AddMarksViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var studentsArray: [Student] = []
    var averageTitle = "Average 1 - E3"
    var subjectTitle = "Freanch - Quiz 2"
    var maximumMark: Float = 100
    var activeField = 0
    var delegate: AddRemarksViewControllerDelegate?
    var addGradesDelegate: AddGradesDelegate?
    var user: User!
    var sectionId: Int = 0
    var type = ""
    var quizId = ""
    var editable = false
    let numberFormatter = NumberFormatter()
    let languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        numberFormatter.numberStyle = .decimal
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.backToGrades()
        SectionVC.canChangeClass = true
    }
    
    /// Description:
    ///
    /// - Parameters:
    ///   - mark: Selected Mark
    ///   - markField: Selected TextField
    /// - Called to update mark color and format.
    func checkMark(_ mark: Float, markField: UITextField) {
        
        switch mark {
        case 0:
            markField.text = ""
            markField.attributedPlaceholder = NSAttributedString(string: "\(mark)", attributes: [NSAttributedString.Key.foregroundColor: App.hexStringToUIColorCst(hex: "#ed1c24", alpha: 1.0)])
        case let mark where mark < maximumMark / 2:
            markField.textColor = App.hexStringToUIColorCst(hex: "#ed1c24", alpha: 1.0)
        case let mark where mark > maximumMark / 2:
            markField.textColor = App.hexStringToUIColorCst(hex: "#8dc63f", alpha: 1.0)
        default:
            markField.textColor = App.hexStringToUIColorCst(hex: "#fbb040", alpha: 1.0)
        }
        
        print("markssss: \(mark)")
        if mark == 0.0{
            print("entered markssss: \(mark)")
            markField.text = "-"
        }else{
            markField.text = "\(mark)"
        }
    }

}

// MARK: - UITableView Delegate and DataSource Functions:
extension AddMarksViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 1:
            return studentsArray.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "quizTitleReuse")
            let backButton = cell?.viewWithTag(1) as! UIButton
            let averageLabel = cell?.viewWithTag(2) as! UILabel
            let subjectLabel = cell?.viewWithTag(3) as! UILabel
            if self.languageId == "ar"{
                backButton.setImage(UIImage(named: "calendar-right-arrow"), for: .normal)
            }else{
                backButton.setImage(UIImage(named: "calendar-left-arrow"), for: .normal)
            }
            backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
            averageLabel.text = self.averageTitle
            subjectLabel.text = self.subjectTitle
            cell?.selectionStyle = .none
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentReuse")
            let studentImageView = cell?.viewWithTag(10) as! UIImageView
            let studentNameLabel = cell?.viewWithTag(11) as! UILabel
            let plusButton = cell?.viewWithTag(12) as! UIButton
            let minusButton = cell?.viewWithTag(13) as! UIButton
            let markField = cell?.viewWithTag(14) as! UITextField
            let _: UIView? = cell?.viewWithTag(15)
            let bottomView: UIView? = cell?.viewWithTag(16)
            let student = studentsArray[indexPath.row]
            
            //hide plus and minus if not editable
            if self.editable == false{
                plusButton.isHidden = true
                minusButton.isHidden = true
                markField.isEnabled = false
            }else{
                plusButton.isHidden = false
                minusButton.isHidden = false
                markField.isEnabled = true
            }
            
            markField.delegate = self
            markField.addTarget(self, action: #selector(textFieldPressed), for: .touchUpInside)
            
            if indexPath.row == studentsArray.count - 1{
                bottomView?.isHidden = false
                bottomView?.dropShadow()
            }else{
                bottomView?.isHidden = true
            }

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
               
                    if(user.gender.lowercased() == "m"){
                        studentImageView.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_boy"))

                    }
                    else{
                        studentImageView.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "student_girl"))

                    }
                
            }else{
               
                    if(user.gender.lowercased() == "m"){
                        studentImageView.image = UIImage(named: "student_boy")
                    }
                    else{
                        studentImageView.image = UIImage(named: "student_girl")
                    }
                
                
            }
            
            studentNameLabel.text = student.fullName
            markField.minimumFontSize = 12
            markField.adjustsFontSizeToFitWidth = true
            checkMark(student.mark, markField: markField)
            plusButton.addTarget(self, action: #selector(plusButtonPressed), for: .touchUpInside)
            minusButton.addTarget(self, action: #selector(minusButtonPressed), for: .touchUpInside)
            cell?.selectionStyle = .none
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
            let saveButton = cell?.viewWithTag(20) as! UIButton
            saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
            if self.editable{
                saveButton.alpha = 1
                saveButton.isHidden = false
                saveButton.isUserInteractionEnabled = true
            }else{
                saveButton.alpha = 0.5
                saveButton.isHidden = true
                saveButton.isUserInteractionEnabled = false
            }
            cell?.selectionStyle = .none
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section{
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentHeaderReuse")
            let studentListLabel = cell?.viewWithTag(5) as! UILabel
            let studentNumberLabel = cell?.viewWithTag(6) as! UILabel
            let fullMarkLabel = cell?.viewWithTag(7) as! UILabel
            let _: UIView? = cell?.viewWithTag(8)
            
            studentListLabel.text = "Students List".localiz()
            studentNumberLabel.text = "\(studentsArray.count) \("students".localiz())"
            let fullMark = numberFormatter.string(from: maximumMark as NSNumber)
            fullMarkLabel.text = "\("over".localiz()) \(fullMark ?? "")"
            cell?.selectionStyle = .none
            return cell?.contentView
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section{
        case 1:
            return 69
        default:
            return 0.01
        }
    }
    
    @objc func backButtonPressed(sender: UIButton){
        self.backToGrades()
        SectionVC.canChangeClass = true
    }
    
    @objc func plusButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        guard let index = tableView.indexPath(for: cell) else{
            return
        }
        if self.studentsArray[index.row].mark+Float(1) < self.maximumMark+0.01{
            self.studentsArray[index.row].mark += 1
            reloadTableView(index: index)
        }
        
    }
    
    @objc func minusButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        guard let index = tableView.indexPath(for: cell) else{
            return
        }
        if self.studentsArray[index.row].mark-1 > 0.0-0.01{
            self.studentsArray[index.row].mark -= 1
            reloadTableView(index: index)
        }
    }
    
    @objc func saveButtonPressed(){
//        delegate?.saveMarks(markId: self.quizId)
        self.submitStudentMarks(user: self.user, sectionId: self.sectionId, type: self.type, id: self.quizId, students: self.studentsArray)
        SectionVC.canChangeClass = true
    }
    
    /// Description:
    /// - Update activeField variable.
    @objc func textFieldPressed(sender: UITextField){
        let cell = sender.superview?.superview as! UITableViewCell
        let index = tableView.indexPath(for: cell)
        self.activeField = index!.row
    }
    
    func reloadTableView(index: IndexPath){
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.reloadRows(at: [index], with: .none)
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: true)
    }
    
    /// Description:
    /// - Call backToGrades function in Grades page.
    func backToGrades(){
        delegate?.backToGrades()
    }
}

// MARK: - Handle Grades page delegate fucntions:
extension AddMarksViewController: AddGradesViewControllerDelegate{
    func QuizInfo(quizId: String, type: String, sectionId: Int, user: User, term: String, subTerm: String, subject: String, level: String, fullMark: Float, editable: Bool) {
        self.getStudentMark(user: user, sectionId: sectionId, type: type, id: quizId)
        self.averageTitle = "\(term) - \(subTerm)"
        self.subjectTitle = "\(subject) - \(level)"
        self.maximumMark = fullMark
        self.user = user
        self.sectionId = sectionId
        self.type = type
        self.quizId = quizId
        self.editable = editable
    }
    
 
    
    func updateStudentList(user: User, batchId: Int) {
        self.sectionId = batchId
        if self.type != "" && self.quizId != ""{
            self.getStudentMark(user: user, sectionId: sectionId, type: type, id: quizId)
        }
    }
}

// MARK: - UITextField Functions:
extension AddMarksViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let stringValue = "\(textField.text!)\(string)"
        if let value = Float(stringValue){
            self.studentsArray[self.activeField].mark = value
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let cell = textField.superview?.superview
        let markField = cell?.viewWithTag(14) as! UITextField
        self.addGradesDelegate?.showTopView()
        var value = NSString(string: textField.text!).floatValue
        if value > maximumMark || value < 0{
            value = 0
        }
        self.studentsArray[self.activeField].mark = value
        checkMark(value, markField: markField)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let cell = textField.superview?.superview as! UITableViewCell
        let index = tableView.indexPath(for: cell)
        self.activeField = index!.row
        self.addGradesDelegate?.hideTopView()
    }
    
}

// MARK: - API Calls:
extension AddMarksViewController{
    
    /// Description: Get Student Mark
    /// - Call "get_student_marks" API and update students list.
    func getStudentMark(user: User, sectionId: Int, type: String, id: String){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        self.tableView.isHidden = true
        Request.shared.getStudentMarks(user: user, sectionId: sectionId, type: type, id: id) { (message, data, status) in
            if status == 200{
                self.studentsArray = data!
                self.studentsArray = self.studentsArray.sorted(by: {$0.index < $1.index})
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Error", message: message ?? "", actions: [ok])
            }
            self.tableView.reloadData()
            self.tableView.isHidden = false
            UIApplication.shared.keyWindow?.viewWithTag(1500)?.removeFromSuperview()
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            self.loading.removeFromSuperview()
        }
    }
    
    /// Description: Submit Student Mark
    /// - Call "submit_student_marks" API.
    /// - Call backToGrades function to close the page.
    func submitStudentMarks(user: User, sectionId: Int, type: String, id: String, students: [Student]){
//        self.delegate?.addLoading()
        Request.shared.submitStudentMarks(user: user, sectionId: sectionId, type: type, id: id, students: students) { (message, data, status) in
            if status == 200{
                App.showMessageAlert(self, title: "", message: "Saved!".localiz(), dismissAfter: 1.5)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
//                    self.delegate?.removeLoading()
                    self.backToGrades()
                }
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Error", message: message ?? "", actions: [ok])
            }
        }
    }
}
