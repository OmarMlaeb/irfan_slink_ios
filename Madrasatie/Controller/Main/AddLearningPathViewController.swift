//
//  AddLearningPathViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 6/30/20.
//  Copyright © 2020 IQUAD. All rights reserved.
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

protocol LearningPathViewControllerDelegate{
    func refreshBlended()
}

class AddLearningPathViewController: UIViewController,UIDocumentPickerDelegate, UINavigationControllerDelegate, TableViewIndexDelegate{
    
    @IBOutlet weak var addFormTableView: UITableView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    var croppingStyle = CropViewCroppingStyle.default
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    
    var delegate: LearningPathViewControllerDelegate?
    var tableViewIndexController: TableViewIndexController!
    var user: User!
    var itemType = ""
    var assignmentType = ""
    var selectedGroup = ""
    var typeName = ""
    var assignmentTypeNb = 0
    var itemTypeArray = ["Digital Resources", "URL", "Assignment", "Discussion", "Online Exam"]
    var assignmentTypeArray = ["Homework","Classwork", "Assessment", "Exam"]
    var imagePicker = UIImagePickerController()
    var selectCalendarDate = ""
    var languageId = ""
    var startDate = ""
    var endDate = ""
    var eventEndDate: Date? = nil
    var eventStartDate: Date? = nil
    var eventStartTime: Date? = nil
    var eventEndTime: Date? = nil
    var addType: String = ""
    var batchId: String = ""
    var subjectId: String = ""
    var discussionStudents: String = ""
    var discussionTitle: String = ""
    var teacherStudentsArray: [CalendarEventItem] = [CalendarEventItem(id: "1", title: "Student1", active: false, studentId: ""), CalendarEventItem(id: "2", title: "Student2", active: false, studentId: ""),CalendarEventItem(id: "3", title: "Student3", active: false, studentId: ""),CalendarEventItem(id: "4", title: "Student4", active: false, studentId: "")]
    var pageTitle = ""
    var channelId = ""
    var sectionId = ""
    var expand: Bool = false
    var onlineExamsList: [OnlineExamGroupModel] = []
    
    var teacherSubjectArray: [Subject] = []
    var teacherTermsArray: [Subject] = []
    var assessmentsType: [AssessmentType] = []
    var selectedSubject = Subject.init(id: 0, name: "", code: "", sectionId: 0, sectionName: "", color: "", imperiumCode: "")
    var addEvent: AgendaExam!
    var pdfURL : URL!
    var compressedDataToPass: NSData!
    var selectedImage : UIImage = UIImage()
    var isFileSelected = false
    var isSelectedImage = false
    var allStudents = false
    var selectedStudentd: [String] = []
    var agendaType = AgendaDetail.agendaType.self
    var assessmentType: Int = 0
    var onlineExam: OnlineExamGroupModel!
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")
    var selectAttachment: Bool = false
    var documentCreate: Bool = false
    var documentChoose: Bool = false
    var documentsList: [DocumentsModel] = []
    var documentId: String = ""
    var subjectName: String = ""
    var studentCount: Int = 0;
    var itemsList: [ItemsModel] = [ItemsModel(color: "#46BC8C", name: "Digital Resources", image: "document_download", selected: false), ItemsModel(color: "#F1A420", name: "Assignment", image: "assignment_download", selected: false), ItemsModel(color: "#CB57A0", name: "URL", image: "url_download", selected: false), ItemsModel(color: "#4A74BA", name: "Online Exam", image: "online_exam_download", selected: false), ItemsModel(color: "#7A60AB", name: "Discussion", image: "discuss", selected: false)]
    
    var assignmentTypeList: [ItemsModel] = [ItemsModel(color: "#fa487a", name: "Homework", image: "homeWork-events", selected: false), ItemsModel(color: "#00a053", name: "Classwork", image: "classWork-events", selected: false), ItemsModel(color: "#faae21", name: "Assessment", image: "quiz-events", selected: false), ItemsModel(color: "#a171ff", name: "Exam", image: "exam-events", selected: false)]
    var sectionDate: String = ""
    var channelIndex: Int = 0

    //edit model
    var edit: Bool = false
    var type: String = ""
    
    //document edit
    var documentName: String = ""
    var attachment: String = ""
    
    //url edit
    var titleURL: String = ""
    var url: String = ""
    
    //assignment edit
    var asstType: String = ""
    var assignmentName: String = ""
    var assignmentBody: String = ""
    var studentList: String = ""
    var assignmentDate: String = ""
    var subTerm: String = ""
    var subSubjectId: String = ""
    var fullMark: String = ""
    var attachmentType: String = ""
    var sectionItemName: String = ""
    var itemId: String = ""
    var date: String = ""
    var time: String = ""
    var sectionCode: String = ""
    var sectionTitle: String = ""
    var allowReplies = false
    var filename: String = "Madrasatie"
    var newDocument: Bool = false
    var existingDocuments: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("subject id: \(subjectId)")
        print("subject name: \(subjectName)")
        
        print("channel index: \(channelIndex)")
        addFormTableView.dataSource = self
        addFormTableView.delegate = self
        
         tableViewIndexController = TableViewIndexController(scrollView: addFormTableView)
        tableViewIndexController.tableViewIndex.delegate = self
        tableViewIndexController.tableViewIndex.isUserInteractionEnabled = true
            pageTitleLabel.text = pageTitle
        
        imagePicker.delegate = self
        let currentDate = Date()
               
        date = self.dateFormatter2.string(from: currentDate)
        time = self.timeFormatter.string(from: currentDate)
        
        if(edit){
            if(type.elementsEqual("document")){
                self.documentCreate = true
                self.documentChoose = false
            }
        }
        
        if(self.edit){
            if(self.assignmentDate != ""){
                print("assignment date1: \(self.assignmentDate)")
                let currentDate = Date()
                let tempDate = self.pickerDateFormatter1.date(from: self.assignmentDate)
                self.endDate = self.dateFormatter2.string(from: tempDate ?? currentDate)
                self.selectCalendarDate = self.dateFormatter2.string(from: tempDate ?? currentDate)
            }
        }
        else{
            self.endDate = "\(date)"
            self.selectCalendarDate = "\(date)"
            
        }
        getDocuments(user: user)
        if(!self.batchId.isEmpty){
            self.getSectionStudent(user: user, sectionId: Int(self.batchId) ?? 0)
            self.getSubjects(user: user, sectionId: Int(self.batchId) ?? 0)

        }
        if(!self.subjectId.isEmpty){
            self.getUserOnlineExams(user: user, subjectId: subjectId)
        }
        
        if(self.edit){
             for item in self.itemTypeArray{
                 if(item.lowercased().elementsEqual(self.type)){
                    sectionItemName = item
                    self.itemType = item
                    self.assignmentType = ""
                    self.addFormTableView.reloadData()
                    
                 }
             }
            if(self.selectAttachment == false){
                
                if(self.attachmentType != ""){
                    print("attachment typee: \(self.attachmentType)")
                              let filetype = self.attachmentType.suffix(4)



                              
                              if filetype == "/jpg" || filetype == "jpeg" || filetype == "/png"{
                                  self.isSelectedImage = true
                                  self.isFileSelected = false
                                  
                                 if(baseURL?.prefix(8) == "https://"){
                                   if(self.attachment.prefix(8) != "https://"){
                                         self.attachment = "https://" + self.attachment
                                     }
                                 }
                                 else if(baseURL?.prefix(7) == "http://"){
                                     if (self.attachment.prefix(7) != "http://" ){
                                         self.attachment = "http://" + self.attachment
                                     }
                                 }
                                 
                              }
                              else{
                                  self.isFileSelected = true
                                  self.isSelectedImage = false
                                  self.pdfURL = URL(string: self.attachment)!
                                  
                              }
                }
          
            }
         }
    }
    
    @objc func createNewDocument(sender: UIButton){
        documentCreate = true
        documentChoose = false
        newDocument = true
        existingDocuments = false
        self.addFormTableView.reloadData()
    }
    @objc func chooseDocument(sender: UIButton){
        documentCreate = false
        documentChoose = true
        newDocument = false
        existingDocuments = true
        self.addFormTableView.reloadData()
    }

    @objc func dateButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
           let dateLabel = cell.viewWithTag(701) as! UILabel
           print("entered date")
           let datePicker = ActionSheetDatePicker(title: "Select a Date:".localiz(), datePickerMode: UIDatePicker.Mode.date, selectedDate: Date(), doneBlock: {
               picker, value, index in
               
               if let value = value{
                   let result = self.pickerDateFormatter.date(from: "\(value)") ?? Date()
                   let date = self.dateFormatter2.string(from: result)
                   dateLabel.text = date
                   
                self.endDate = self.dateFormatter2.string(from: result)
                self.selectCalendarDate = self.dateFormatter2.string(from: result)
                
               }
               return
           }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!.superview)
           datePicker?.minimumDate = Date()
           
           datePicker?.show()
       }
    
    @IBAction func closeFormPressed(_ sender: Any) {
         let blended = BlendedLearningViewController()
            print("return to blended: \(self.channelIndex)")
            blended.channelNameIndex = self.channelIndex
            
        self.dismiss(animated: true, completion: nil)
    }
    @objc func showHint(sender: UIButton){
        print("hint hint")
        
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Hint", message:"A Learning Path Title is displayed to students when they select their learning path icon. The title may be a Chapter name, a Lesson name or any other relevant title for the learning path that you are building. Number of characters should be no more than 20.", actions: [ok])
        
    }
    @objc func showHint1(sender: UIButton){
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Hint", message:"A Learning Path Code is an abbreviation of the title that is used to identify the learning path. Number of characters should be no more than 3", actions: [ok])
    }
    
    @objc func showHint2(sender: UIButton){
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Hint", message:"You can divide your Learning Path into sections for a better display for students", actions: [ok])
    }
    @objc func showHint3(sender: UIButton){
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Hint", message:"The Start Date is used by the Application to automatically open this section for students in a specific date. By default, it takes the date creation of the section, but you can change it to a future date.", actions: [ok])
    }
    @objc func createChannel(sender: UIButton){
        let cell = self.addFormTableView.viewWithTag(777) as! UITableViewCell
        let index = self.addFormTableView.indexPath(for: cell)
        let cellTitle = self.addFormTableView.viewWithTag(778) as! UITableViewCell
        let titleIndex = self.addFormTableView.indexPath(for: cellTitle)
        var channelCode = ""
        var channelTitle = ""
        if(index?.section == 1){
            let channelC = cell.viewWithTag(711) as! UITextField
            channelCode = channelC.text!
        }
        if(titleIndex?.section == 0){
            let channelT = cellTitle.viewWithTag(713) as! UITextField
            channelTitle = channelT.text!
        }
        
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)

        
        if(channelCode.elementsEqual("")){
            App.showAlert(self, title: "Error".localiz(), message: "Insert learning path code", actions: [ok])

        }
        else if(channelTitle.elementsEqual("")){
            App.showAlert(self, title: "Error".localiz(), message: "Insert learning path name", actions: [ok])

        }else{
            self.addChannel(user: user, batch_id: self.batchId, subject_id: self.subjectId, title: channelTitle, code: channelCode)

        }
        
        
    }
    
    @objc func studentSwitchPressed(sender: UIButton){
        print("entered switch")
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = self.addFormTableView.indexPath(for: cell)
        print("indexpath row: \(indexpath?.row)")
        if(self.teacherStudentsArray[indexpath!.row - 1].active){
//            let editedStudents = self.discussionStudents.replacingOccurrences(of: String(self.teacherStudentsArray[indexpath!.row - 1].id), with: "")
//            self.discussionStudents = editedStudents
            self.teacherStudentsArray[indexpath!.row - 1].active = false
        }
        else{
            self.teacherStudentsArray[indexpath!.row - 1].active = true
//            self.discussionStudents = self.discussionStudents + String(self.teacherStudentsArray[indexpath!.row - 1].id)

        }
        
        self.addFormTableView.reloadData()
    }
    
    @objc func createSection(sender: UIButton){
        
        let cellTitle = self.addFormTableView.viewWithTag(778) as! UITableViewCell
        let titleIndex = self.addFormTableView.indexPath(for: cellTitle)
        var sectionTitle = ""
        if(titleIndex?.section == 0){
            let sectionT = cellTitle.viewWithTag(713) as! UITextField
            sectionTitle = sectionT.text!
        }
        
        if(edit){
            self.editSection(user: user, batch_id: batchId, subject_id: subjectId, title: sectionTitle, code: "code", startDate: self.endDate, channelId: channelId, sectionOrder: "0", section_id: sectionId)
            
        }
        else{
             self.addSection(user: user, batch_id: batchId, subject_id: subjectId, title: sectionTitle, code: "code", startDate: self.endDate, channelId: channelId, sectionOrder: "0")
        }
       
        
        
      
        print("section code: \(sectionCode)")
        print("section title: \(sectionTitle)")
        print("index: \(titleIndex!.section)")
        
    }
    
    @objc func addDocument(sender: UIButton){
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
        if(self.documentCreate == true){
            let documentTitle = self.addFormTableView?.viewWithTag(730) as! UITextField

            let docTitle = documentTitle.text ?? ""
            if(docTitle == ""){
                App.showAlert(self, title: "Error".localiz(), message: "Insert document name", actions: [ok])
            }
            else if(self.isSelectedImage == false && self.isFileSelected == false){
                App.showAlert(self, title: "Error".localiz(), message: "Select an attachment", actions: [ok])
            }
            else{
                if(self.edit){
                    
                    self.editItemWithAttachment(user: user, type: "document", section_id: sectionId, title: docTitle, url: "", startDate: "", agenda: AgendaExam(id: 0, title: "", type: "", students: [], subjectId: 0, startDate: "", startTime: "", endDate: "", endTime: "", description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: true, enableLateSubmissions: true, enableDiscussions: true, enableGrading: true, estimatedTime: 0), subjectName: "", id: self.itemId)
                }
                else{
                    self.addItemWithAttachment(user: user, type: "document", section_id: sectionId, title: docTitle, url: "", startDate: "", agenda: AgendaExam(id: 0, title: "", type: "", students: [], subjectId: 0, startDate: "", startTime: "", endDate: "", endTime: "", description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: true, enableLateSubmissions: true, enableDiscussions: true, enableGrading: true, estimatedTime: 0), subjectName: "")
                }
                
            }
        }
        if(self.documentChoose == true){
            if(self.documentId == ""){
                App.showAlert(self, title: "Alert".localiz(), message: "Choose a document", actions: [ok])
            }
            else{
                self.addItem1(user: user, type: "document", section_id: sectionId, title: "", url: "", startDate: "", agenda: AgendaExam(id: 0, title: "", type: "", students: [], subjectId: 0, startDate: "", startTime: "", endDate: "", endTime: "", description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: true, enableLateSubmissions: true, enableDiscussions: true, enableGrading: true, estimatedTime: 0), id: "", subjectName: "", documentCreate: documentCreate, documentChoose: documentChoose, documentId: documentId)
            }
        }

        
    }
    @objc func addDiscussion(sender: UIButton){
        let title = self.addFormTableView.viewWithTag(730) as! UITextField
        let cell = self.addFormTableView.viewWithTag(932) as! UITableViewCell
        let body = cell.viewWithTag(720) as! UITextView
        
        if !allStudents{
            selectedStudentd = []
            for student in self.teacherStudentsArray{
                print("student active: \(student.active)")
                if student.active{
                    selectedStudentd.append(student.id)
                }
            }
        }
        else{
            selectedStudentd = []
            for student in self.teacherStudentsArray{
                    selectedStudentd.append(student.id)
            }
        }
        
        if(self.edit){
            if(!title.text!.isEmpty){
                    if(allStudents == true || !selectedStudentd.isEmpty){
                        self.addEvent.title = title.text ?? "Group Subject"
                        self.addEvent.description = body.text
                        self.addEvent.students = self.selectedStudentd
                        
                        
                        if(self.isFileSelected == false && self.isSelectedImage == false){
                            self.editItem(user: user, type: "discussion", section_id: sectionId, title: title.text!, url: "", startDate: "", agenda: self.addEvent, id: self.itemId, subjectName: "")
                        }
                        else{
                            self.editItemWithAttachment(user: user, type: "discussion", section_id: sectionId, title: title.text!, url: "", startDate: "", agenda: self.addEvent, subjectName: "", id: self.itemId)
                           
                        }
                    }
                    else{
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                        App.showAlert(self, title: "ERROR".localiz(), message: "No students selected", actions: [ok])
                    }
                
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: "Subject is Empty", actions: [ok])
            }
        }
        else{
            if(!title.text!.isEmpty){
                if(!body.text.isEmpty){
                    if(allStudents == true || !selectedStudentd.isEmpty){
                        self.addEvent.title = title.text ?? "Group Subject"
                        self.addEvent.description = body.text
                        self.addEvent.students = self.selectedStudentd
                        
                        
                        if(self.isFileSelected == false && self.isSelectedImage == false){
                            self.addItem(user: user, type: "discussion", section_id: sectionId, title: title.text!, url: "", startDate: "", agenda: self.addEvent, id: self.itemId, subjectName: "", documentCreate: false, documentChoose: false, documentId: "")
                        }
                        else{
                            self.addItemWithAttachment(user: user, type: "discussion", section_id: sectionId, title: title.text!, url: "", startDate: "", agenda: self.addEvent, subjectName: "")
                        }
                    }
                    else{
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                        App.showAlert(self, title: "ERROR".localiz(), message: "No students selected", actions: [ok])
                    }
                    
                }
                else{
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                       App.showAlert(self, title: "ERROR".localiz(), message: "Message is Empty", actions: [ok])
                    
                }
                
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: "Subject is Empty", actions: [ok])
            }
        }

        
    }
    @objc func addUrl(sender: UIButton){
        let cell1 = self.addFormTableView.viewWithTag(876) as! UITableViewCell
        let index1 = self.addFormTableView.indexPath(for: cell1)
        let cell2 = self.addFormTableView.viewWithTag(888) as! UITableViewCell
        let index2 = self.addFormTableView.indexPath(for: cell2)
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)

        
        var urlTitle = ""
        var url = ""
        if(index1!.section == 1){
            let urltitleTextView = cell1.viewWithTag(730) as! UITextField
            urlTitle = urltitleTextView.text ?? ""
        }
        if(index2!.section == 2){
            let urlTextView = cell2.viewWithTag(1111) as! UITextField

            url = urlTextView.text ?? ""
        }
        
    if(urlTitle == ""){
               App.showAlert(self, title: "Error".localiz(), message: "Insert url title".localiz(), actions: [ok])
           }
           else if(url == ""){
               App.showAlert(self, title: "Error".localiz(), message: "Insert url", actions: [ok])
           }
           else{
        if(self.edit){
            self.editItem(user: user, type: "url", section_id: sectionId, title: urlTitle, url: url, startDate: "", agenda: AgendaExam(id: 0, title: "", type: "", students: [], subjectId: 0, startDate: "", startTime: "", endDate: "", endTime: "", description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: true, enableLateSubmissions: true, enableDiscussions: true, enableGrading: true, estimatedTime: 0), id: self.itemId, subjectName: "")
        }
        else{
             self.addItem(user: user, type: "url", section_id: sectionId, title: urlTitle, url: url, startDate: "", agenda: AgendaExam(id: 0, title: "", type: "", students: [], subjectId: 0, startDate: "", startTime: "", endDate: "", endTime: "", description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: true, enableLateSubmissions: true, enableDiscussions: true, enableGrading: true, estimatedTime: 0), id: "", subjectName: "", documentCreate: documentCreate, documentChoose: documentChoose, documentId: documentId)
        }
                      
           }
       
    }
   
       
    @objc func allStudentsSwitchPressed(sender: UIButton){
        self.allStudents = !self.allStudents
        self.addFormTableView.reloadData()
    }
    
    @objc func allowRepliesPressed(sender: PWSwitch){
        self.allowReplies = !self.allowReplies
        self.addFormTableView.reloadData()
    }
    
    @objc func addAssignment(sender: UIButton){
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
        switch self.assignmentTypeNb{
        case self.agendaType.Exam.rawValue:
            let cell = self.addFormTableView.viewWithTag(932) as! UITableViewCell
            let aboutExam = cell.viewWithTag(720) as! UITextView
            let aboutExamText = aboutExam.text
            if(self.selectCalendarDate.isEmpty){
                App.showAlert(self, title: "Error".localiz(), message: "Select a date".localiz(), actions: [ok])
            }
            if addEvent.groupId == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Select a group".localiz(), actions: [ok])
            }else if self.selectedSubject.id == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Select a subject".localiz(), actions: [ok])
            }else if aboutExamText == ""{
                App.showAlert(self, title: "Error".localiz(), message: "Write a description".localiz(), actions: [ok])
            }else if selectCalendarDate.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Select a due date on the calendar".localiz(), actions: [ok])
            }else{
                self.addEvent.startDate = App.dateFormatter.string(from: self.dateFormatter2.date(from: selectCalendarDate) ?? Date())
                self.addEvent.subjectId = self.selectedSubject.id
                self.addEvent.assignmentId = self.assignmentTypeNb
                self.addEvent.description = aboutExamText ?? ""

                if(self.edit){
                    if self.isFileSelected || self.isSelectedImage{
                        self.editItemWithAttachment(user: user, type: "assignment", section_id: sectionId, title: self.assignmentType, url: "", startDate: selectCalendarDate, agenda: self.addEvent, subjectName: self.selectedSubject.name, id: self.itemId)

                    }else{
                        self.editItem(user: user, type: "assignment", section_id: sectionId, title: self.assignmentType, url: "", startDate: selectCalendarDate, agenda: self.addEvent, id: self.itemId, subjectName: self.selectedSubject.name)

                    }
                }
                else{
                    if self.isFileSelected || self.isSelectedImage{
                        self.addItemWithAttachment(user: user, type: "assignment", section_id: sectionId, title: self.assignmentType, url: "", startDate: selectCalendarDate, agenda: self.addEvent, subjectName: self.selectedSubject.name)

                    }else{
                        self.addItem(user: user, type: "assignment", section_id: sectionId, title: self.assignmentType, url: "", startDate: selectCalendarDate, agenda: self.addEvent, id: "", subjectName: self.selectedSubject.name, documentCreate: documentCreate, documentChoose: documentChoose, documentId: documentId)

                    }
                }
                
                
            }
        case self.agendaType.Homework.rawValue, self.agendaType.Classwork.rawValue:
            
            let cell = self.addFormTableView.viewWithTag(932) as! UITableViewCell
            
            let aboutHomework = cell.viewWithTag(720) as! UITextView
            let aboutHomeworkText = aboutHomework.text
            
            if !allStudents{
                selectedStudentd = []
                for student in self.teacherStudentsArray{
                    print("student active: \(student.active)")
                    if student.active{
                        selectedStudentd.append(student.id)
                    }
                }
            }
            else{
                selectedStudentd = []
                for student in self.teacherStudentsArray{
                        selectedStudentd.append(student.id)
                }
            }
            
             if(self.selectCalendarDate.isEmpty){
                 App.showAlert(self, title: "Error".localiz(), message: "Select a date".localiz(), actions: [ok])
             }
             else if(self.selectedSubject.id == 0){
                 App.showAlert(self, title: "Error".localiz(), message: "Select a subject".localiz(), actions: [ok])
             }
            else if(aboutHomeworkText == ""){
                 App.showAlert(self, title: "Error".localiz(), message: "Write a description".localiz(), actions: [ok])
             }
             else if(self.selectedStudentd.isEmpty){
                 App.showAlert(self, title: "Error".localiz(), message: "Select a student".localiz(), actions: [ok])
             }
             else{
                self.addEvent.description = aboutHomeworkText ?? ""
                self.addEvent.subjectId = self.selectedSubject.id
                self.addEvent.startDate = App.dateFormatter.string(from: self.dateFormatter2.date(from: selectCalendarDate) ?? Date())
                self.addEvent.students = self.selectedStudentd
                print("description: \(self.addEvent.description)")
                print("subject: \(self.addEvent.subjectId)")
                print("start date: \(self.addEvent.startDate)")
                print("students: \(self.teacherStudentsArray.count)")
                self.addEvent.assignmentId = self.assignmentTypeNb
                
                
                if(self.edit){
                   if self.isFileSelected || self.isSelectedImage{
                    self.editItemWithAttachment(user: user, type: "assignment", section_id: sectionId, title: self.assignmentType, url: "", startDate: selectCalendarDate, agenda: self.addEvent, subjectName: self.selectedSubject.name, id: self.itemId)

                    }else{
                    self.editItem(user: user, type: "assignment", section_id: sectionId, title: self.assignmentType, url: "", startDate: selectCalendarDate, agenda: self.addEvent, id: self.itemId, subjectName: self.selectedSubject.name)

                    }

                }
                else{
                  if self.isFileSelected || self.isSelectedImage{
                        self.addItemWithAttachment(user: user, type: "assignment", section_id: sectionId, title: self.assignmentType, url: "", startDate: selectCalendarDate, agenda: self.addEvent, subjectName: self.selectedSubject.name)

                    }else{
                        self.addItem(user: user, type: "assignment", section_id: sectionId, title: self.assignmentType, url: "", startDate: selectCalendarDate, agenda: self.addEvent, id: "", subjectName: self.selectedSubject.name, documentCreate: documentCreate, documentChoose: documentChoose, documentId: documentId)

                    }

                }
                
                
                
             }
            
        default:
            //Quiz/Assessment
            let marksCell = self.addFormTableView.viewWithTag(876) as! UITableViewCell
            let mark = marksCell.viewWithTag(730) as! UITextField
            let markText = Double(mark.text!) ?? 0.0
            let titleCell = self.addFormTableView.viewWithTag(877) as! UITableViewCell
            let title = titleCell.viewWithTag(730) as!UITextField
            let titleText = title.text
            let descriptionCell = self.addFormTableView.viewWithTag(932) as! UITableViewCell
            let description = descriptionCell.viewWithTag(720) as! UITextView
            let descriptionText = description.text

            print("assessment type: \(self.addEvent.assessmentTypeId)")
            if self.addEvent.groupId == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Select a group".localiz(), actions: [ok])
            }else if self.selectedSubject.id == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Select a subject".localiz(), actions: [ok])
            }else if self.addEvent.assessmentTypeId == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Select assessment type".localiz(), actions: [ok])
            }else if descriptionText!.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Write a description".localiz(), actions: [ok])
            }else if markText == 0{
                App.showAlert(self, title: "Error".localiz(), message: "Write a mark".localiz(), actions: [ok])
            }else if titleText!.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Write a title".localiz(), actions: [ok])
            }else if selectCalendarDate.isEmpty{
                App.showAlert(self, title: "Error".localiz(), message: "Select a due date on the calendar".localiz(), actions: [ok])
            }else{
                addEvent.subjectId = self.selectedSubject.id
                addEvent.description = descriptionText ?? ""
                addEvent.mark = markText
                addEvent.title = titleText ?? ""
                self.addEvent.assignmentId = self.assignmentTypeNb

                self.addEvent.startDate = App.dateFormatter.string(from: self.dateFormatter2.date(from: selectCalendarDate) ?? Date())
                
               
                    self.addItem(user: user, type: "assignment", section_id: sectionId, title: self.assignmentType, url: "", startDate: selectCalendarDate, agenda: self.addEvent, id: "", subjectName: self.selectedSubject.name, documentCreate: documentCreate, documentChoose: documentChoose, documentId: documentId)
                
            }
        }
    }
    
    @objc func addOnlineExam(sender: UIButton){
       
        if(self.onlineExam == nil){
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "ERROR".localiz(), message: "Please Choose an Exam", actions: [ok])
        }
        else{
            self.addItem(user: user, type: "online_exam", section_id: sectionId, title: "", url: "", startDate: "", agenda: AgendaExam(id: 0, title: "", type: "", students: [], subjectId: 0, startDate: "", startTime: "", endDate: "", endTime: "", description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: true, enableLateSubmissions: true, enableDiscussions: true, enableGrading: true, estimatedTime: 0), id: self.onlineExam.id, subjectName: "", documentCreate: documentCreate, documentChoose: documentChoose, documentId: documentId)
        }
               
        
    }
    
    @objc func timeButtonPressed(sender: UIButton){
        print("entered time")
           let cell = sender.superview?.superview as! UITableViewCell
           let timeLabel = cell.viewWithTag(703) as! UILabel
               let time = self.pickerTimeResultFormatter.date(from: (timeLabel.text) ?? "12:00 am")
               let timePicker = ActionSheetDatePicker(title: "Select a Time:".localiz(), datePickerMode: UIDatePicker.Mode.time, selectedDate: time, doneBlock: {
                   picker, value, index in
                   let index = self.addFormTableView.indexPath(for: cell)
                   
                   let result = self.pickerDateFormatter.date(from: "\(value ?? Date())")
                   if index?.row == 0{
                       self.eventStartDate = result
                   }else{
                       self.eventStartTime = result
                   }
                   
                   let time = self.pickerTimeResultFormatter.string(from: result ?? Date())
                   timeLabel.text = time
                   
                   let occasionTime = self.timeFormatter.string(from: result ?? Date())
                   let dateLabel = cell.viewWithTag(701) as! UILabel
                   let occasionDate = self.dateFormatter.string(from: self.pickerDateResultFormatter.date(from: dateLabel.text ?? "01-09-1900") ?? Date())
                   
                 
                    self.endDate = "\(occasionDate) \(occasionTime)"
                print("enddate: \(self.endDate)")
                   return
               }, cancel: {ActionStringCancelBlock in return}, origin: sender.superview!.superview)
               timePicker?.show()
           
       }
       
    @objc func viewDetails(sender: UIButton){
         let cell = sender.superview?.superview?.superview
        if let indexPath = self.addFormTableView.indexPath(for: cell as! UITableViewCell) {
            

            if(self.expand == false){
                self.expand = true
            }
            else{
                self.expand = false
            }
        }
        

        self.addFormTableView.reloadData()
        
       
        
    }
    
    @objc func asstTypeDropDownFieldPressed(sender: UIButton){
            let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.addFormTableView.indexPath(for: cell)
            let dropdownField = cell.viewWithTag(715) as! UITextField
            var array: [String] = []
            var title = ""
        print("assessment: \(self.assignmentTypeNb)")
        print("assessment: \(self.assessmentsType)")

        if self.assignmentTypeNb == self.agendaType.Assessment.rawValue{
                switch indexPath?.section{
                case 3:
                    for subject in teacherSubjectArray{
                        array.append(subject.name)
                    }
                    title = "subject".localiz()
                case 6:
                    for terms in teacherTermsArray{
                        array.append(terms.name)
                    }
                    title = "subterm".localiz()
                    
                case 7://7
                    for type in assessmentsType{
                        array.append(type.name)
                    }
                    title = "assessment type".localiz()
                default:
                    title = "title"
                    
                }
            }else{
                if indexPath?.section == 3{//in homework or classwork
                    for subject in teacherSubjectArray{
                        array.append(subject.name)
                    }
                    title = "subject".localiz()
                }else{//4 in Exam
                    for terms in teacherTermsArray{
                        array.append(terms.name)
                    }
                    title = "subterm".localiz()
                }
            }
            ActionSheetStringPicker.show(withTitle: "\("Choose".localiz()) \(title):", rows: array, initialSelection: 0, doneBlock: {
                picker, ind, values in
                if sender.accessibilityIdentifier == "subject"{
                }
                if array.isEmpty{
                    dropdownField.text = ""
                    return
                }
                dropdownField.text = array[ind]
                

//                print("section: \(assessment.first!.id)")
                switch indexPath?.section{
                case 6,4:
                    let groupArray = self.teacherTermsArray.filter({$0.name == array[ind]})
                    if !groupArray.isEmpty{
                        print("subject selected 1")
                        let group = groupArray.first!
                        self.addEvent.groupId = group.id
                        self.selectedGroup = group.name
                        if self.addEvent.groupId != 0 && self.addEvent.subjectId != 0{
                            self.getAssessment(user: self.user, subjectId: self.addEvent.subjectId, termId: group.id)
                        }
                    }
                case 7:
                    print("assessment type: \(self.assessmentType)")
                    let assessment = self.assessmentsType.filter({$0.name == array[ind]})
                    if !assessment.isEmpty{
                        self.addEvent.assessmentTypeId = assessment.first!.id
                        self.typeName = assessment.first!.name
                    }
                default://3
                    print("subject selected 2")
                    let subjectArray = self.teacherSubjectArray.filter({$0.name == array[ind]})
                    if !subjectArray.isEmpty{
                        let subjectId = subjectArray.first!.id
                        self.addEvent.subjectId = subjectId
                        self.selectedSubject = subjectArray.first!
                        if self.teacherTermsArray.first?.id != nil{
                            self.getAssessment(user: self.user, subjectId: subjectId, termId: self.teacherTermsArray.first!.id)
                        }
                    }
                }
//                self.addFormTableView.reloadData()

                return
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        }
        //MARK: drop down select
        /// Description:
        /// - Update needed textfield from picker array based on the current edit type and selected field index.
        @objc func dropDownFieldPressed(sender: UIButton){
            let cell = sender.superview?.superview as! UITableViewCell
            let indexPath = addFormTableView.indexPath(for: cell)
            let dropdownField = cell.viewWithTag(715) as! UITextField
           
  
            let title = "item"
            ActionSheetStringPicker.show(withTitle: "\("Choose".localiz()) \(title):", rows: itemTypeArray, initialSelection: 0, doneBlock: {
                picker, ind, values in
               
                if self.itemTypeArray.isEmpty{
                    dropdownField.text = ""
                }
                self.documentCreate = false
                self.documentChoose = false
                self.documentId = ""
                dropdownField.text = self.itemTypeArray[ind]
                self.itemType = self.itemTypeArray[ind]
                print("itemTypee: \(self.itemType)")
                self.assignmentType = ""
                self.addFormTableView.reloadData()

                
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        }
    
    //MARK: drop down select
           /// Description:
           /// - Update needed textfield from picker array based on the current edit type and selected field index.
           @objc func onlineExamDropDownPressed(sender: UIButton){
               let cell = sender.superview?.superview as! UITableViewCell
               let indexPath = addFormTableView.indexPath(for: cell)
               let dropdownField = cell.viewWithTag(715) as! UITextField
            let title = "online exam"
            var examsNames: [String] = []
            
            for exam in self.onlineExamsList{
                examsNames.append(exam.name)
            }
              
     
            ActionSheetStringPicker.show(withTitle: "\("Choose".localiz()) \(title):", rows: examsNames, initialSelection: 0, doneBlock: {
                   picker, ind, values in
                  
                if self.onlineExamsList.isEmpty{
                       dropdownField.text = ""
                       return
                   }
                dropdownField.text = self.onlineExamsList[ind].name
                self.onlineExam = self.onlineExamsList[ind]
                  
                   self.addFormTableView.reloadData()
                   return
               }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
           }
    
    
    //MARK: drop down select
           /// Description:
           /// - Update needed textfield from picker array based on the current edit type and selected field index.
           @objc func documentDropDownFieldPressed(sender: UIButton){
               let cell = sender.superview?.superview as! UITableViewCell
               let indexPath = addFormTableView.indexPath(for: cell)
               let dropdownField = cell.viewWithTag(715) as! UITextField
            let title = "document"
            var docsNames: [String] = []
            
            for doc in self.documentsList{
                docsNames.append(doc.name)
            }
            ActionSheetStringPicker.show(withTitle: "\("Choose".localiz()) \(title):", rows: docsNames, initialSelection: 0, doneBlock: {
                   picker, ind, values in
                  
                   if self.assignmentTypeArray.isEmpty{
                       dropdownField.text = ""
                       return
                   }
                dropdownField.text = self.documentsList[ind].name
                self.documentId = self.documentsList[ind].id
                   self.addFormTableView.reloadData()
                   return
               }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
           }
    
    
    //MARK: drop down select
           /// Description:
           /// - Update needed textfield from picker array based on the current edit type and selected field index.
           @objc func asstDropDownFieldPressed(sender: UIButton){
               let cell = sender.superview?.superview as! UITableViewCell
               let indexPath = addFormTableView.indexPath(for: cell)
               let dropdownField = cell.viewWithTag(715) as! UITextField
              
     
            let title = "type"
            ActionSheetStringPicker.show(withTitle: "\("Choose".localiz()) \(title):", rows: self.assignmentTypeArray, initialSelection: 0, doneBlock: {
                   picker, ind, values in
                  
                   if self.assignmentTypeArray.isEmpty{
                       dropdownField.text = ""
                       return
                   }
                   dropdownField.text = self.assignmentTypeArray[ind]
                self.assignmentType = self.assignmentTypeArray[ind]
                if(self.assignmentType.elementsEqual("Homework")){
                    self.assignmentTypeNb = 1
                }
                else if(self.assignmentType.elementsEqual("Classwork")){
                    self.assignmentTypeNb = 2
                }
                else if(self.assignmentType.elementsEqual("Assessment")){
                    self.assignmentTypeNb = 3
                }
                else if(self.assignmentType.elementsEqual("Exam")){
                    self.assignmentTypeNb = 4
                }
                                  
                   self.addFormTableView.reloadData()
                   return
               }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
           }
    
       fileprivate lazy var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
    //        formatter.locale = Locale(identifier: "\(self.languageId)")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
            }()
    
    fileprivate lazy var attachmentPickertime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
               let formatter = DateFormatter()
               formatter.dateFormat = "dd-MM-yyyy"
       //        formatter.locale = Locale(identifier: "\(self.languageId)")
               formatter.locale = Locale(identifier: "en_US_POSIX")
               return formatter
               }()
        
    fileprivate lazy var timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm a"
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
    fileprivate lazy var sectionDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm a"
    //        formatter.locale = Locale(identifier: "\(self.languageId)")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
        }()
     fileprivate lazy var pickerDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            formatter.locale = Locale(identifier: "en_US_POSIX")
    //        formatter.locale = Locale(identifier: "\(self.languageId)")
            return formatter
        }()
    
    fileprivate lazy var pickerDateFormatter1: DateFormatter = {
               let formatter = DateFormatter()
               formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
               formatter.locale = Locale(identifier: "en_US_POSIX")
       //        formatter.locale = Locale(identifier: "\(self.languageId)")
               return formatter
           }()
    fileprivate lazy var dateFormatter1: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd"
           formatter.locale = Locale(identifier: "en_US_POSIX")
           return formatter
       }()
    fileprivate lazy var pickerTimeResultFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
    //        formatter.locale = Locale(identifier: "\(self.languageId)")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
        }()
    
    //function to attach a file to the document
    @objc func addPicturePressed(sender: UIButton){
        let alert = UIAlertController(title: "Upload picture".localiz(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take photo".localiz(), style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from library".localiz(), style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Attach a file".localiz(), style: .default, handler: { _ in
            self.attachDocument()
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
    
   
        
    
    private func attachDocument() {
//        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet, kUTTypePNG, kUTTypeJPEG, kUTTypeGIF, "com.microsoft.word.doc" as CFString, "org.openxmlformats.wordprocessingml.document" as CFString, "org.openxmlformats.presentationml.presentation" as CFString, kUTTypeMovie, kUTTypeAudio, kUTTypeVideo, kUTTypeText, kUTTypeGIF]
       let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
           if #available(iOS 11.0, *) {
               importMenu.allowsMultipleSelection = false
           }
           
           importMenu.delegate = self
           importMenu.modalPresentationStyle = .formSheet
           
           present(importMenu, animated: true)
       }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
           self.pdfURL = urls[0]
        self.selectAttachment = true
           self.isFileSelected = true
           self.isSelectedImage = false
        self.filename = self.pdfURL.lastPathComponent
                           
        self.addFormTableView.reloadData()
       }
       
       func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
           controller.dismiss(animated: true, completion: nil)
       }
       
       
}

// MARK: - Select Picture:
extension AddLearningPathViewController: UIImagePickerControllerDelegate, CropViewControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true , completion: nil )
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if(info[UIImagePickerController.InfoKey.mediaType] as! CFString == kUTTypeImage){
            guard let selectedImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
            
            let cropController = CropViewController(croppingStyle: croppingStyle, image: selectedImage)
            
            cropController.delegate = self
            
//            print("entered here image picker")
//            self.selectAttachment = true
//            self.selectedImage = selectedImage
//            self.isSelectedImage = true
//            self.isFileSelected = false
            
            //If profile picture, push onto the same navigation stack
                    if croppingStyle == .circular {
                        if picker.sourceType == .camera {
                            picker.pushViewController(cropController, animated: true)
//                            picker.dismiss(animated: true, completion: {
//                                self.present(cropController, animated: true, completion: nil)
//                            })
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
            
    //        let imageView = self.addFormTableView.viewWithTag(721) as! UIImageView
    //        imageView.image = selectedImage
            
            if #available(iOS 11.0, *) {
                if let asset = info[.phAsset] as? PHAsset, let fileName = asset.value(forKey: "filename") as? String {
                    filename = fileName
                } else if let url = info[.imageURL] as? URL {
                    filename = url.lastPathComponent
                }
            } else {
                filename = "Madrasatie"
            }
            
            print("filename: \(filename)")
            
            self.addFormTableView.reloadData()
        }
        else{
            self.pdfURL = info[UIImagePickerController.InfoKey.mediaURL]as? NSURL as URL?
            let filetype = self.pdfURL.description.suffix(4).lowercased()
            
            if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                
                let data = try! Data(contentsOf: pdfURL! as URL)
                
                print("File size before compression: \(data)")

                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                
                compressVideo(inputURL: pdfURL as! URL, outputURL: compressedURL) { (exportSession) in
                                guard let session = exportSession else {
                                    return
                                }

                                switch session.status {
                                case .unknown:
                                    break
                                case .waiting:
                                    break
                                case .exporting:
                                    break
                                case .completed:
                                    guard let compressedData = NSData(contentsOf: compressedURL) else {
                                        return
                                    }
                                    self.compressedDataToPass = compressedData
                                    print("File size after compression: \(self.compressedDataToPass.length)")
                                case .failed:
                                    break
                                case .cancelled:
                                    break
                                }
                            }
            }
            
            
     
            do{
                let asset = AVURLAsset(url: self.pdfURL! as URL , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                filename = self.pdfURL.lastPathComponent
                self.selectedImage = thumbnail
                self.selectAttachment = true
                self.isFileSelected = true
                self.isSelectedImage = false
                self.addFormTableView.reloadData()

            }
            catch let error {
                    print("*** Error generating thumbnail: \(error.localizedDescription)")
                }
            
        }
        

    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
            let urlAsset = AVURLAsset(url: inputURL, options: nil)
            guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
                handler(nil)

                return
            }

            exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously { () -> Void in
                handler(exportSession)
            }
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
        let imageView = addFormTableView.viewWithTag(721) as! UIImageView
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
        let imageView = addFormTableView.viewWithTag(721) as! UIImageView
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
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openGallery() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        //imagePicker.allowsEditing = true
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension AddLearningPathViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("length: \(textField.text)")
        print("length: \(self.addType)")
        
        var maxLength : Int = 0
        
        let titleTextField = self.view.viewWithTag(713)
        let codeTextField = self.view.viewWithTag(711)
        
        if(self.addType == "channel"){
            if textField == codeTextField {
             maxLength = 3
            }
            else if textField == titleTextField {
                maxLength = 20
            }
              let currentString: NSString = textField.text! as NSString
              let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
              return newString.length <= maxLength
        }
        if(self.addType == "section"){
            let maxLength = 20
              let currentString: NSString = textField.text! as NSString
              let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
              return newString.length <= maxLength
        }
        
        if(self.itemType == "Digital Resources"){
            if(self.documentCreate){
                let maxLength = 20
                  let currentString: NSString = textField.text! as NSString
                  let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                  return newString.length <= maxLength
            }
        }
        if(self.itemType == "URL"){
            if(textField.tag == 730){
                let maxLength = 20
                  let currentString: NSString = textField.text! as NSString
                  let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                  return newString.length <= maxLength
            }
        }
        
        if(self.itemType == "Assignment"){
            if(textField.tag == 730){
                
                self.assignmentName = textField.text!
                let maxLength = 20
                  let currentString: NSString = textField.text! as NSString
                  let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                  return newString.length <= maxLength
            }
            
            
        }
        if(self.itemType.elementsEqual("Discussion")){
            print("entered textview")
            let maxLength = 20
              let currentString: NSString = textField.text! as NSString
              let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
              return newString.length <= maxLength
        }
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField){
        let cell = textField.superview?.superview as! UITableViewCell
        let indexPath = self.addFormTableView.indexPath(for: cell)
        
        if(self.itemType == "Assignment"){
            if(indexPath?.section == 4){
                print("textView: \(textField.text)")
                if(textField.tag == 730){
                    self.fullMark = textField.text ?? ""

                }
            }
            else{
                
            }
           
            
            
        }
    }

}

extension AddLearningPathViewController: UITextViewDelegate{

    func textViewDidChange(_ textView: UITextView){
        print(textView.text)
        if(self.itemType.elementsEqual("Assignment")){
            if(textView.tag == 720){
                self.assignmentBody = textView.text ?? ""
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView){
        print(textView.text)
        self.discussionTitle = textView.text ?? ""
        
        if(self.itemType.elementsEqual("Assignment")){
            if(textView.tag == 720){
                self.assignmentBody = textView.text ?? ""
            }
        }
    }
    
//    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
//         self.textSubject = textView.text ?? ""
//           addEvent.description = textView.text ?? ""
//       }
}

extension AddLearningPathViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(addType.elementsEqual("channel")){
            return 3
        }
        else if(addType.elementsEqual("section")){
            return 3
        }
        else{
            if(self.itemType.elementsEqual("Digital Resources")){
                if(documentChoose == true){
                    return 5
                }
                else if(documentCreate == true){
                    return 6
                }
                else{
                    return 3
                }
                   }
                
            else if(self.itemType.elementsEqual("Discussion")){
                return 7
            }
                
            else if(self.itemType.elementsEqual("URL")){
                return 4
            }
                   else if(self.itemType.elementsEqual("Assignment")){
                       if(self.assignmentType.elementsEqual("Classwork")){
                           return 9
                       }
                       else if(self.assignmentType.elementsEqual("Homework")){
                           return 9
                       }
                       else if(self.assignmentType.elementsEqual("Exam")){
                           return 8
                       }
                       else if(self.assignmentType.elementsEqual("Assessment")){
                           return 11
                       }
                       else{
                           return 2
                       }
                   }
                  
                   else if(self.itemType.elementsEqual("Online Exam")){ return 4}
                   else if(self.itemType.elementsEqual("Meeting room")){return 4}
        }
       
        
        return 1
       
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.itemType.elementsEqual("Assignment")){
            if(self.assignmentType.elementsEqual("Homework") || self.assignmentType.elementsEqual("Classwork")){
                if(section == 6){
                    if(self.expand == true){
                        print("expand: \(self.teacherStudentsArray.count)")
                        return self.teacherStudentsArray.count + 1
                    }
                }
                else{
                    return 1
                }
            }
        }
        else if(self.itemType.elementsEqual("Discussion")){
            if(section == 4){
                if(self.expand == true){
                    print("expand: \(self.teacherStudentsArray.count)")
                    return self.teacherStudentsArray.count + 1
                }
            }
            else{
                return 1
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("iitemtype: \(self.itemType)")
        
        if(self.addType.elementsEqual("channel")){
            switch(indexPath.section){
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "channelTitleReuse")
                let channelCodeLabel = cell?.viewWithTag(712) as! UILabel
                let channelCodeText = cell?.viewWithTag(713) as! UITextField
                let hintButton = cell?.viewWithTag(439) as! UIButton
                hintButton.isEnabled = true
                hintButton.isUserInteractionEnabled = true

                channelCodeText.delegate = self
                hintButton.addTarget(self, action: #selector(showHint), for: .touchUpInside)
                channelCodeText.layer.borderWidth = 1
                channelCodeText.borderColor = #colorLiteral(red: 0.2470588235, green: 0.5058823529, blue: 0.7647058824, alpha: 1)
                channelCodeText.layer.cornerRadius = 20
                channelCodeText.clipsToBounds = false
                channelCodeText.layer.backgroundColor = UIColor.white.cgColor
                channelCodeText.rightPadding = 8
                channelCodeText.leftPadding = 8
                channelCodeText.placeholder = "Add Learning Path Title"
                
                channelCodeLabel.text = "Title"
                return cell!
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "teacherHeaderReuse")
                let channelCodeLabel = cell?.viewWithTag(710) as! UILabel
                let channelCodeText = cell?.viewWithTag(711) as! UITextField
                let hintButton = cell?.viewWithTag(439) as! UIButton
                hintButton.isEnabled = true
                hintButton.isUserInteractionEnabled = true
                channelCodeText.delegate = self

                hintButton.addTarget(self, action: #selector(showHint1), for: .touchUpInside)
                channelCodeText.layer.borderWidth = 1
                channelCodeText.borderColor = #colorLiteral(red: 0.2470588235, green: 0.5058823529, blue: 0.7647058824, alpha: 1)
                channelCodeText.layer.cornerRadius = 20
                channelCodeText.clipsToBounds = false
                channelCodeText.layer.backgroundColor = UIColor.white.cgColor
                channelCodeText.rightPadding = 8
                channelCodeText.leftPadding = 8
                channelCodeText.placeholder = "Add Learning Path Code"

                channelCodeLabel.text = "Code"
                return cell!
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                let saveButton = cell?.viewWithTag(725) as! UIButton
                
                saveButton.addTarget(self, action: #selector(createChannel), for: .touchUpInside)
                return cell!
                
            default:
                return UITableViewCell()
            }
        }
        else if(self.addType.elementsEqual("section")){
            switch(indexPath.section){
                
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "channelTitleReuse")
                let channelCodeLabel = cell?.viewWithTag(712) as! UILabel
                let channelCodeText = cell?.viewWithTag(713) as! UITextField
                
                let hintButton = cell?.viewWithTag(439) as! UIButton
                hintButton.isEnabled = true
                hintButton.isUserInteractionEnabled = true
                hintButton.addTarget(self, action: #selector(showHint2), for: .touchUpInside)
                
                if edit{
                    channelCodeText.text = self.sectionTitle
                }
                channelCodeText.delegate = self
                channelCodeText.layer.borderWidth = 1
                channelCodeText.borderColor = #colorLiteral(red: 0.2470588235, green: 0.5058823529, blue: 0.7647058824, alpha: 1)
                channelCodeText.layer.cornerRadius = 20
                channelCodeText.clipsToBounds = false
                channelCodeText.layer.backgroundColor = UIColor.white.cgColor
                channelCodeText.rightPadding = 8
                channelCodeText.leftPadding = 8
                channelCodeText.placeholder = "Add Section Title"

                channelCodeLabel.text = "Title"
                return cell!
                
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startSectionReuse")
                let dateLabel = cell?.viewWithTag(700) as! UILabel
                
                let dateValueLabel = cell?.viewWithTag(701) as! UILabel
                let dateValueButton = cell?.viewWithTag(702) as! UIButton
                
                let hintButton = cell?.viewWithTag(439) as! UIButton
                hintButton.isEnabled = true
                hintButton.isUserInteractionEnabled = true
                hintButton.addTarget(self, action: #selector(showHint3), for: .touchUpInside)
                
                
                dateValueButton.addTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
                dateValueButton.isEnabled = true

                if(edit){
                    self.endDate = self.dateFormatter.string(from: self.dateFormatter1.date(from: selectCalendarDate) ?? Date())
                    dateValueLabel.text = self.endDate
                }
                else{
                    dateValueLabel.text =  self.endDate
                }
                
                let view = cell?.viewWithTag(90) as! UIView
                view.layer.borderWidth = 1
                view.borderColor = #colorLiteral(red: 0.2470588235, green: 0.5058823529, blue: 0.7647058824, alpha: 1)
                view.layer.cornerRadius = 20
                view.clipsToBounds = false
            
                



                dateLabel.text = "Starts"

                return cell!

            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                let saveButton = cell?.viewWithTag(725) as! UIButton
                
                saveButton.addTarget(self, action: #selector(createSection), for: .touchUpInside)
                return cell!
                
            default:
                return UITableViewCell()
            }
        }
        else{
            if(indexPath.section == 0){
                let eventsCell = tableView.dequeueReusableCell(withIdentifier: "eventsReuse")
            
                let eventsCollectionView = eventsCell?.viewWithTag(12) as! UICollectionView
                eventsCollectionView.delegate = self
                eventsCollectionView.dataSource = self
                eventsCollectionView.reloadData()
                
                return eventsCell!
                
                

            }
               
               
                if(self.itemType.elementsEqual("Digital Resources")){
                    print("section2: \(indexPath.section)")
                    if(documentCreate == true){
                        switch(indexPath.section){
                        case 1:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "documentButtonReuse1")
                            
                            let buttonCreate = cell?.viewWithTag(222) as! UIButton
                            buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 1.0)
                            buttonCreate.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                            buttonCreate.setTitle("Create new document", for: .normal)
                            buttonCreate.addTarget(self, action: #selector(createNewDocument), for: .touchUpInside)
                            buttonCreate.layer.cornerRadius = 20
                            buttonCreate.clipsToBounds = false
                            buttonCreate.titleLabel?.font = UIFont(name: "effra-regular", size: 17)
                            if(newDocument){
                                buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                            }
                            else{
                                buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 0.43)
                            }

                            return cell!
                        case 2:

                            let cell = tableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                            let textField = cell?.viewWithTag(730) as! UITextField
                            let documentTitle = cell?.viewWithTag(44) as! UILabel
                            documentTitle.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                            documentTitle.text = "Document name"
                            documentTitle.backgroundColor = App.hexStringToUIColor(hex: "#FFFFFF", alpha: 1.0)
                            textField.placeholder = "Enter document name here"
                            if(edit){
                                if(type.elementsEqual("document")){
                                    textField.text = documentName
                                }
                            }
                            
                            textField.delegate = self

                            return cell!
                            
                        case 3:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "pictureReuse")
                           let attachmentLabel = cell?.viewWithTag(720) as! UILabel
                           attachmentLabel.text = "Attach a file"
                            attachmentLabel.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                           
                           let attachmentPicture = cell?.viewWithTag(721) as! UIImageView
                          
                           if(self.edit){
                               if self.attachmentType == ""{
                                   attachmentPicture.image = UIImage(named: "attach")
                               }
                                else{
                                   let filetype = self.attachmentType.suffix(4)
                                   
                                   if(baseURL?.prefix(8) == "https://"){
                                     if(self.attachment.prefix(8) != "https://"){
                                           self.attachment = "https://" + self.attachment
                                       }
                                   }
                                   else if(baseURL?.prefix(7) == "http://"){
                                       if (self.attachment.prefix(7) != "http://" ){
                                           self.attachment = "http://" + self.attachment
                                       }
                                   }

                                  
                                       print("attachment type: \(filetype)")

                                       if filetype == "/pdf"{
                                           attachmentPicture.image = UIImage(named: "pdf_logo")
                                       }else if filetype == "docx"{
                                           attachmentPicture.image = UIImage(named: "word_logo")
                                       }else if filetype == "xlsx"{
                                           attachmentPicture.image = UIImage(named: "excel_logo")
                                       }
                                       else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                        attachmentPicture.image = UIImage(named: "powerpoint")
                                       }
                                       
                                       else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                           || filetype == ".wma" || filetype == ".aac"{
                                           attachmentPicture.image = UIImage(named: "audio")
                                       }
                                        
                                       else if filetype == "/png" || filetype == "/jpg" || filetype == "jpeg"{
                                           print("attachment attachment: \(self.attachment)")
                                             attachmentPicture.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                           attachmentPicture.sd_setImage(with: URL(string: self.attachment),
                                            completed: { (image, error, cacheType, imageUrl) in
                                             
                                              })
                                           
                                       }else{
                                           attachmentPicture.image = UIImage(named: "doc_logo")
                                       }
                          
                                   if self.selectAttachment == true{
                                       if self.isFileSelected == true{
                                            print("url ",self.pdfURL)
                                        let filetype = self.pdfURL.description.suffix(4).lowercased().lowercased()
                                            if filetype == ".pdf"{
                                                attachmentPicture.image = UIImage(named: "pdf_logo")
                                            }else if filetype == "docx"{
                                                attachmentPicture.image = UIImage(named: "word_logo")
                                            }else if filetype == "xlsx"{
                                                attachmentPicture.image = UIImage(named: "excel_logo")
                                            }
                                            
                                            else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                             attachmentPicture.image = UIImage(named: "powerpoint")
                                            }
                                            else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                                || filetype == ".wma" || filetype == ".aac"{
                                                attachmentPicture.image = UIImage(named: "audio")
                                            }
                                            else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                                attachmentPicture.image = UIImage(named: "video")

                                            }
                                            else{
                                                attachmentPicture.image = UIImage(named: "doc_logo")
                                            }
                                        }else if self.isSelectedImage{
                                            print("selectedimage: \(self.selectedImage)")
                                            attachmentPicture.image = selectedImage
                                        }else{
                                            attachmentPicture.image = UIImage(named: "attach")
                                        }
                                   }
                                   
                               }
                           }
                           else{
                               if self.isFileSelected == true{
                                   print("url ",self.pdfURL)
                                let filetype = self.pdfURL.description.suffix(4).lowercased()
                                   if filetype == ".pdf"{
                                       attachmentPicture.image = UIImage(named: "pdf_logo")
                                   }else if filetype == "docx"{
                                       attachmentPicture.image = UIImage(named: "word_logo")
                                   }else if filetype == "xlsx"{
                                       attachmentPicture.image = UIImage(named: "excel_logo")
                                   }
                                   
                                   else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                    attachmentPicture.image = UIImage(named: "powerpoint")
                                   }
                                   else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                       attachmentPicture.image = UIImage(named: "video")

                                   }
                                   else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                       || filetype == ".wma" || filetype == ".aac"{
                                       attachmentPicture.image = UIImage(named: "audio")
                                   }
                                   else{
                                       attachmentPicture.image = UIImage(named: "doc_logo")
                                   }
                               }else if self.isSelectedImage{
                                   print("selectedimage: \(self.selectedImage)")
                                   attachmentPicture.image = selectedImage
                               }else{
                                   attachmentPicture.image = UIImage(named: "attach")
                               }
                           }
                          
                           let attachmentButton = cell?.viewWithTag(722) as! UIButton
                        //                         attachmentButton.removeTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                               attachmentButton.addTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                               return cell!
                               
                           case 4:
                               let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                               let saveButton = cell?.viewWithTag(725) as! UIButton
                               saveButton.removeTarget(self, action: #selector(addDocument), for: .touchUpInside)
                               saveButton.addTarget(self, action: #selector(addDocument), for: .touchUpInside)
                               
                               return cell!
                       
                        case 5:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "documentButtonReuse2")
                            
                            let buttonCreate = cell?.viewWithTag(223) as! UIButton
                            buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 1.0)
                            buttonCreate.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                            buttonCreate.setTitle("Choose from existing documents", for: .normal)
                            buttonCreate.addTarget(self, action: #selector(chooseDocument), for: .touchUpInside)
                            buttonCreate.layer.cornerRadius = 20
                            buttonCreate.clipsToBounds = false
                            buttonCreate.titleLabel?.font = UIFont(name: "effra-regular", size: 17)
                            
                            if(existingDocuments){
                                buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                            }
                            else{
                                buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 0.34)
                            }
                            
                            return cell!
                           default:
                               return UITableViewCell()
                        }
                    }
                    else if(documentChoose == true){
                        switch indexPath.section{
                        case 1:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "documentButtonReuse1")
                            
                            let buttonCreate = cell?.viewWithTag(222) as! UIButton
                            buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 1.0)
                            buttonCreate.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                            buttonCreate.setTitle("Create new document", for: .normal)
                            buttonCreate.addTarget(self, action: #selector(createNewDocument), for: .touchUpInside)
                            buttonCreate.layer.cornerRadius = 20
                            buttonCreate.clipsToBounds = false
                            buttonCreate.titleLabel?.font = UIFont(name: "effra-regular", size: 17)
                            
                            if(newDocument){
                                buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                            }
                            else{
                                buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 0.34)
                            }
                            
                            return cell!
                            
                        case 2:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "documentButtonReuse2")
                            
                            let buttonCreate = cell?.viewWithTag(223) as! UIButton
                            buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 1.0)
                            buttonCreate.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                            buttonCreate.setTitle("Choose from existing documents", for: .normal)
                            buttonCreate.addTarget(self, action: #selector(chooseDocument), for: .touchUpInside)
                            buttonCreate.layer.cornerRadius = 20
                            buttonCreate.clipsToBounds = false
                            buttonCreate.titleLabel?.font = UIFont(name: "effra-regular", size: 17)
                            if(existingDocuments){
                                buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                            }
                            else{
                                buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 0.34)
                            }
                            return cell!
                            
                        case 3:
//                            print("entered asst")
//                            let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
//                            let itemTypeSelector = cell?.viewWithTag(715) as! UITextField
//                            let dropDownArrow = cell?.viewWithTag(716) as! UIImageView
//                            let itemTypeButton = cell?.viewWithTag(717) as! UIButton
//                            itemTypeButton.isEnabled = true
//
//                            itemTypeButton.removeTarget(self, action: #selector(documentDropDownFieldPressed), for: .touchUpInside)
//                            itemTypeButton.addTarget(self, action: #selector(documentDropDownFieldPressed), for: .touchUpInside)
//
//
//                            cell?.selectionStyle = .none
//                                        return cell!
                            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewReuse2")
                             let collectionView = cell?.viewWithTag(15) as! UICollectionView
                             collectionView.delegate = self
                             collectionView.dataSource = self
                            collectionView.isScrollEnabled = false
                            collectionView.reloadData()
                             return cell!
                            
                        case 4:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                            let saveButton = cell?.viewWithTag(725) as! UIButton
                            saveButton.removeTarget(self, action: #selector(addDocument), for: .touchUpInside)
                            saveButton.addTarget(self, action: #selector(addDocument), for: .touchUpInside)
                            
                            return cell!
                            
                        default:
                            return UITableViewCell()
                        }
                    }
                    else {
                        switch indexPath.section {
                        case 1:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "documentButtonReuse1")
                            
                            let buttonCreate = cell?.viewWithTag(222) as! UIButton
                            buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 1.0)
                            buttonCreate.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                            buttonCreate.setTitle("Create new document", for: .normal)
                            buttonCreate.addTarget(self, action: #selector(createNewDocument), for: .touchUpInside)
                            buttonCreate.layer.cornerRadius = 20
                            buttonCreate.clipsToBounds = false
                            buttonCreate.titleLabel?.font = UIFont(name: "effra-regular", size: 17)

                            return cell!
                            
                        case 2:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "documentButtonReuse2")
                            
                            let buttonCreate = cell?.viewWithTag(223) as! UIButton
                            buttonCreate.backgroundColor = App.hexStringToUIColor(hex: "#6EBEE9", alpha: 1.0)
                            buttonCreate.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                            buttonCreate.setTitle("Choose from existing documents", for: .normal)
                            buttonCreate.addTarget(self, action: #selector(chooseDocument), for: .touchUpInside)
                            buttonCreate.layer.cornerRadius = 20
                            buttonCreate.clipsToBounds = false
                            buttonCreate.titleLabel?.font = UIFont(name: "effra-regular", size: 17)
                            return cell!
                        default:
                            return UITableViewCell()
                        }
                    }
                    
                }
                else if(self.itemType.elementsEqual("Discussion")){
                    print("entered discussion")
                    switch indexPath.section {
                    case 1:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                        let textField = cell?.viewWithTag(730) as! UITextField
                        textField.placeholder = "Enter Discussion Title here"
                        textField.delegate = self
                        if(self.edit){
                            textField.text = self.discussionTitle
                        }
                        
                        let documentTitle = cell?.viewWithTag(44) as! UILabel
                        documentTitle.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                        documentTitle.text = "Discussion Title"
                        documentTitle.backgroundColor = App.hexStringToUIColor(hex: "#FFFFFF", alpha: 1.0)
                        
                        
                        

                        return cell!

                    case 2:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "writeReuse")
                         let textView = cell?.viewWithTag(720) as! UITextView
                         textView.delegate = self
                         if(edit){
                             
                            textView.isEditable = false
                         }


                         return cell!

                    case 3:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "allStudentReuse")

                        let nameLabel = cell?.viewWithTag(7300) as! UILabel
                        let uiswitch = cell?.viewWithTag(732) as! PWSwitch
                        let button = cell?.viewWithTag(178) as! UIButton
                        button.isEnabled = true
                        
                        button.addTarget(self, action: #selector(allStudentsSwitchPressed), for: .touchUpInside)
                        
//                        if(self.edit){
//                            let studentNb = self.discussionStudents.split(separator: ",")
//                            if(studentNb.count == self.teacherStudentsArray.count){
//                                self.allStudents = true
//                            }
//                            else{
//                                self.allStudents = false
//                            }
//                        }
                        
                        if(self.allStudents){
                            uiswitch.setOn(true, animated: false)
                        }
                        else{
                            uiswitch.setOn(false, animated: false)
                        }
                        
                        
                        cell?.selectionStyle = .none
                        nameLabel.text = "All Students"
                        return cell!

//                    case 4:
//                        let cell = tableView.dequeueReusableCell(withIdentifier: "allStudentReuse")
//
//                        let nameLabel = cell?.viewWithTag(7300) as! UILabel
//                        let uiswitch = cell?.viewWithTag(732) as! PWSwitch
//
//                        uiswitch.isHidden = true
//
//                        cell?.selectionStyle = .none
//                        nameLabel.text =
//                        return cell!

                    case 4:

                        if(indexPath.row == 0){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse")


                        let dateLabel = cell?.viewWithTag(503)as!UILabel
                            dateLabel.text = "Select Students for group discussion"


                        let titleView = cell?.viewWithTag(43) as! UIView
                        titleView.backgroundColor = .blue
                        let titleLabel = cell?.viewWithTag(44) as! UILabel
                        let plusImage = cell?.viewWithTag(45) as! UIImageView
                        let plusButton = cell?.viewWithTag(46) as! UIButton
                        titleLabel.text = "Students List"
                             plusButton.addTarget(self, action: #selector(viewDetails), for: .touchUpInside)

                             let topView = cell?.viewWithTag(47) as! UIView

                             let tickView = cell?.viewWithTag(48) as! UIView
                             let tickImage = cell?.viewWithTag(49) as! UIImageView
                             let tickButton = cell?.viewWithTag(501) as! UIButton

                             let bottomLineView = cell?.viewWithTag(50) as! UIView


                             plusImage.image = UIImage(named: "+")


                                 tickView.isHidden = true
                                 tickImage.isHidden = true
                                 tickButton.isHidden = true
                                 bottomLineView.isHidden = true
                                 topView.isHidden = true

                             if(expand == true){
//                                 let sections = IndexSet.init(integer: indexPath.section - 4)
//                                 tableView.reloadSections(sections, with: .none)
                                 plusImage.image = UIImage(named: "-")

                             }else{
//                                 let sections = IndexSet.init(integer: indexPath.section - 4)
//                                 tableView.reloadSections(sections, with: .none)
                                 plusImage.image = UIImage(named: "+")

                             }


                             return cell!
                         }
                         else{
                             let cell = tableView.dequeueReusableCell(withIdentifier: "studentReuse")

                                 let nameLabel = cell?.viewWithTag(740) as! UILabel
                                 let uiswitch = cell?.viewWithTag(741) as! PWSwitch
                            let uiButton = cell?.viewWithTag(187) as! UIButton
                            uiButton.isEnabled = true
                            
                             nameLabel.text = self.teacherStudentsArray[indexPath.row - 1].title
                                 print("student reuse: \(self.teacherStudentsArray[indexPath.row - 1].title)")
                        //                                 uiswitch.removeTarget(self, action: #selector(studentSwitchPressed), for: .touchUpInside)
                            uiButton.addTarget(self, action: #selector(studentSwitchPressed), for: .touchUpInside)
                            if(self.edit){
                                print("discussion student 1: \(self.teacherStudentsArray[indexPath.row - 1].id)")
                                print("discussion student 2: \(self.discussionStudents)")
                                if(self.teacherStudentsArray[indexPath.row - 1].active ){
                                    self.teacherStudentsArray[indexPath.row - 1].active = true
                                }
                                else{
                                    self.teacherStudentsArray[indexPath.row - 1].active = false
                                }
                            }
                           
                            if(self.allStudents){
                                uiswitch.setOn(true, animated: false)
                                uiswitch.isEnabled = false
                                uiButton.isEnabled = false
                            }
                            else{
                                uiswitch.isEnabled = true
                                uiButton.isEnabled = true
                                if(self.teacherStudentsArray[indexPath.row - 1].active){
                                    print("entered switch1")
                                    uiswitch.setOn(true, animated: false)
                                }
                                else{
                                    print("entered switch2")
                                    uiswitch.setOn(false, animated: false)
                                }
                            }
                                
                            


                            if allStudents{
                                    uiButton.isEnabled = false
                                }else{
                                    uiButton.isEnabled = true
                                }
                                    return cell!
                            }

//
                    case 5:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "pictureReuse")
                         let attachmentLabel = cell?.viewWithTag(720) as! UILabel
                        
                         attachmentLabel.text = "Attach a file"
                        attachmentLabel.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                        let attachmentButton = cell?.viewWithTag(722) as! UIButton
                       //attachmentButton.removeTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                       attachmentButton.addTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                         let attachmentPicture = cell?.viewWithTag(721) as! UIImageView
                         if(self.edit){
                            attachmentButton.isEnabled = false
                                   }
                               else{
                                   if self.isFileSelected == true{
                                       print("url ",self.pdfURL)
                                    let filetype = self.pdfURL.description.suffix(4).lowercased()
                                       if filetype == ".pdf"{
                                           attachmentPicture.image = UIImage(named: "pdf_logo")
                                       }else if filetype == "docx"{
                                           attachmentPicture.image = UIImage(named: "word_logo")
                                       }else if filetype == "xlsx"{
                                           attachmentPicture.image = UIImage(named: "excel_logo")
                                       }
                                       else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                        attachmentPicture.image = UIImage(named: "powerpoint")
                                       }
                                       else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                           || filetype == ".wma" || filetype == ".aac"{
                                           attachmentPicture.image = UIImage(named: "audio")
                                       }
                                       else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                           attachmentPicture.image = UIImage(named: "video")

                                       }
                                       else{
                                           attachmentPicture.image = UIImage(named: "doc_logo")
                                       }
                                   }else if self.isSelectedImage{
                                       print("selectedimage: \(self.selectedImage)")
                                       attachmentPicture.image = selectedImage
                                   }else{
                                       attachmentPicture.image = UIImage(named: "attach")
                                   }
                               }

                        
                        return cell!

//                    case 6:
//                        let cell = tableView.dequeueReusableCell(withIdentifier: "allStudentReuse")
//
//                        let nameLabel = cell?.viewWithTag(7300) as! UILabel
//                        let uiswitch = cell?.viewWithTag(732) as! PWSwitch
//
//                        uiswitch.addTarget(self, action: #selector(allowRepliesPressed), for: .touchUpInside)
//
//                        cell?.selectionStyle = .none
//                        nameLabel.text = "Replies"
//                        return cell!

                    case 6:

                        let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                        let saveButton = cell?.viewWithTag(725) as! UIButton
                        saveButton.setTitle("Save", for: .normal)

                        saveButton.removeTarget(self, action: #selector(addDiscussion), for: .touchUpInside)
                        saveButton.addTarget(self, action: #selector(addDiscussion), for: .touchUpInside)
                        return cell!
//
                    default:
                        return UITableViewCell()
                    }
                }
                else if(self.itemType.elementsEqual("URL")){
                    switch(indexPath.section){
                    case 1:

                        let cell = tableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                        let textField = cell?.viewWithTag(730) as! UITextField
                        textField.placeholder = "Enter URL title here"
                        textField.delegate = self
                        
                        let documentTitle = cell?.viewWithTag(44) as! UILabel
                        documentTitle.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                        documentTitle.text = "URL Title"
                        documentTitle.backgroundColor = App.hexStringToUIColor(hex: "#FFFFFF", alpha: 1.0)
                        
                        if(edit){
                            if(type.elementsEqual("url")){
                                textField.text = titleURL
                            }
                        }
                        
                        return cell!
                        
                    case 2:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "titleTextReuse3")
                        let textField = cell?.viewWithTag(1111) as! UITextField
                        textField.placeholder = "Enter URL here"
                        
                        let documentTitle = cell?.viewWithTag(44) as! UILabel
                        documentTitle.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                        documentTitle.text = "URL"
                        documentTitle.backgroundColor = App.hexStringToUIColor(hex: "#FFFFFF", alpha: 1.0)
                        
                        if(edit){
                            if(type.elementsEqual("url")){
                                textField.text = url
                            }
                        }
                       
                        
                        return cell!

                    case 3:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                        let saveButton = cell?.viewWithTag(725) as! UIButton
                        
                        saveButton.removeTarget(self, action: #selector(addUrl), for: .touchUpInside)
                        saveButton.addTarget(self, action: #selector(addUrl), for: .touchUpInside)
                        return cell!
                    default:
                        return UITableViewCell()
                    }
                }
                else if(self.itemType.elementsEqual("Assignment")){
                    if(indexPath.section == 1){
                            let eventsCell = tableView.dequeueReusableCell(withIdentifier: "eventsReuse2")
                        
                            let eventsCollectionView = eventsCell?.viewWithTag(13) as! UICollectionView
                            eventsCollectionView.delegate = self
                            eventsCollectionView.dataSource = self
                            eventsCollectionView.reloadData()
                            eventsCell?.selectionStyle = .none
                        
                        if(edit){
                            if(type.elementsEqual("assignment")){
                                if(self.asstType.elementsEqual("homework")){
                                    self.assignmentTypeNb = 1
                                    self.assignmentType = "Homework"

                                }
                                else if(self.asstType.elementsEqual("classwork")){
                                    self.assignmentTypeNb = 2
                                    self.assignmentType = "Classwork"
                                }
                                else if(self.asstType.elementsEqual("quiz")){
                                    self.assignmentTypeNb = 3
                                    self.assignmentType = "Assessment"
                                }
                                else if(self.asstType.elementsEqual("exam")){
                                    self.assignmentTypeNb = 4
                                    self.assignmentType = "Exam"
                                }
                            }
                            
                        }
                        
                            return eventsCell!
                    }
                   
                    switch(self.assignmentType){
                    case "Classwork", "Homework":
                        switch (indexPath.section) {
                        case 2:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "startEndReuse")
                            let dateLabel = cell?.viewWithTag(700) as! UILabel
                            let dateValueLabel = cell?.viewWithTag(701) as! UILabel
                            let dateValueButton = cell?.viewWithTag(702) as! UIButton
                            let timeLabel = cell?.viewWithTag(703) as! UILabel
                            let timeButton = cell?.viewWithTag(704) as! UIButton
//                             dateValueButton.removeTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
                            dateValueButton.addTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
                            
                          
                                dateValueLabel.text = self.endDate
                            
//                            timeLabel.text = self.time

                            let view = cell?.viewWithTag(90) as! UIView
                            view.layer.borderWidth = 1
                            view.borderColor = #colorLiteral(red: 0.2470588235, green: 0.5058823529, blue: 0.7647058824, alpha: 1)
                            view.layer.cornerRadius = 20
                            view.clipsToBounds = false
                            
                            dateLabel.text = "Starts"
//                             timeButton.removeTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
//                            timeButton.addTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
                            timeButton.isHidden = true
                            timeLabel.isHidden = true
                            
                            
                            return cell!

                        case 3:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
                                let itemTypeSelector = cell?.viewWithTag(715) as! UITextField
                                let dropDownArrow = cell?.viewWithTag(716) as! UIImageView
                                let itemTypeButton = cell?.viewWithTag(717) as! UIButton
                            itemTypeSelector.placeholder = "Subjects"
                            
                            if(edit){
                               if !self.teacherSubjectArray.isEmpty{
                                self.addEvent.subjectId = Int(self.subjectId)!
                                for sub in self.teacherSubjectArray{
                                    if(sub.id == self.addEvent.subjectId){
                                        self.selectedSubject = sub
                                        itemTypeSelector.text = sub.name
                                    }
                                }
                                }
                            }
                            
                            
                               itemTypeButton.removeTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                                itemTypeButton.addTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                            
                            
                                cell?.selectionStyle = .none
                            return cell!
                        case 4:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "writeReuse")
                            let textView = cell?.viewWithTag(720) as! UITextView
                            textView.delegate = self
                            if(edit){
                                textView.text = self.assignmentBody
                            }
                           

                            return cell!
                        case 5:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "allStudentReuse")

                            let nameLabel = cell?.viewWithTag(7300) as! UILabel
                            let uiswitch = cell?.viewWithTag(732) as! PWSwitch
                            let button = cell?.viewWithTag(178) as! UIButton
                            button.isEnabled = true
//                            uiswitch.removeTarget(self, action: #selector(allStudentsSwitchPressed), for: .touchUpInside)
                            button.addTarget(self, action: #selector(allStudentsSwitchPressed), for: .touchUpInside)
                            if(self.allStudents){
                                uiswitch.setOn(true, animated: false)
                            }
                            else{
                                uiswitch.setOn(false, animated: false)
                            }
                            cell?.selectionStyle = .none
                            nameLabel.text = "All Students"
                            return cell!

                        case 6:
                            if(indexPath.row == 0){
                                let cell = tableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse")
                                
                                
                                let dateLabel = cell?.viewWithTag(503)as!UILabel
                                dateLabel.isHidden = true

                                                                 
                                let titleView = cell?.viewWithTag(43) as! UIView
                                titleView.backgroundColor = .blue
                                let titleLabel = cell?.viewWithTag(44) as! UILabel
                                let plusImage = cell?.viewWithTag(45) as! UIImageView
                                let plusButton = cell?.viewWithTag(46) as! UIButton
                                titleLabel.text = "Students List"
                                plusButton.addTarget(self, action: #selector(viewDetails), for: .touchUpInside)

                                let topView = cell?.viewWithTag(47) as! UIView

                                let tickView = cell?.viewWithTag(48) as! UIView
                                let tickImage = cell?.viewWithTag(49) as! UIImageView
                                let tickButton = cell?.viewWithTag(501) as! UIButton

                                let bottomLineView = cell?.viewWithTag(50) as! UIView

                                                               
                                plusImage.image = UIImage(named: "+")
                                                              

                                    tickView.isHidden = true
                                    tickImage.isHidden = true
                                    tickButton.isHidden = true
                                    bottomLineView.isHidden = true
                                    topView.isHidden = true
                                    
                                if(expand == true){
//                                    let sections = IndexSet.init(integer: indexPath.section - 6)
//                                    tableView.reloadSections(sections, with: .none)
                                    plusImage.image = UIImage(named: "-")
                                    
                                }else{
//                                    let sections = IndexSet.init(integer: indexPath.section - 6)
//                                    tableView.reloadSections(sections, with: .none)
                                    plusImage.image = UIImage(named: "+")

                                }
                                
                                                                 
                                return cell!
                            }
                            else{
                                let cell = tableView.dequeueReusableCell(withIdentifier: "studentReuse")

                                    let nameLabel = cell?.viewWithTag(740) as! UILabel
                                    let uiswitch = cell?.viewWithTag(741) as! PWSwitch
                                
                                let uiButton = cell?.viewWithTag(187) as! UIButton
                                uiButton.isEnabled = true
                                
                                nameLabel.text = self.teacherStudentsArray[indexPath.row - 1].title
                                    print("student reuse: \(self.teacherStudentsArray[indexPath.row - 1].title)")
//                                 uiswitch.removeTarget(self, action: #selector(studentSwitchPressed), for: .touchUpInside)
                                uiButton.addTarget(self, action: #selector(studentSwitchPressed), for: .touchUpInside)
                                if(self.allStudents){
                                    uiswitch.setOn(true, animated: false)
                                    uiswitch.isEnabled = false
                                    uiButton.isEnabled = false
                                }
                                else{
                                    uiswitch.isEnabled = true
                                    uiButton.isEnabled = true
                                    if(self.teacherStudentsArray[indexPath.row - 1].active){
                                        print("entered switch1")
                                        uiswitch.setOn(true, animated: false)
                                    }
                                    else{
                                        print("entered switch2")
                                       uiswitch.setOn(false, animated: false)
                                    }
                                }
                                    
                                
                                
                                if allStudents{
                                    uiButton.isEnabled = false
                                }else{
                                    uiButton.isEnabled = true
                                }
                                    return cell!
                            }
                            
                            
                        case 7:
                           let cell = tableView.dequeueReusableCell(withIdentifier: "pictureReuse")
                            let attachmentLabel = cell?.viewWithTag(720) as! UILabel
                            attachmentLabel.text = "Attach a file"
                            attachmentLabel.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                            
                            let attachmentPicture = cell?.viewWithTag(721) as! UIImageView
                            if(self.edit){
                               if self.attachmentType == ""{
                                   attachmentPicture.image = UIImage(named: "attach")
                               }
                                else{
                                   let filetype = self.attachmentType.suffix(4)
                                    
                                    if(baseURL?.prefix(8) == "https://"){
                                    if(self.attachment.prefix(8) != "https://"){
                                            self.attachment = "https://" + self.attachment
                                        }
                                    }
                                    else if(baseURL?.prefix(7) == "http://"){
                                        if (self.attachment.prefix(7) != "http://" ){
                                            self.attachment = "http://" + self.attachment
                                        }
                                    }

                                  
                                   if filetype == "/pdf"{
                                       attachmentPicture.image = UIImage(named: "pdf_logo")
                                   }else if filetype == "docx"{
                                       attachmentPicture.image = UIImage(named: "word_logo")
                                   }else if filetype == "xlsx"{
                                       attachmentPicture.image = UIImage(named: "excel_logo")
                                   }
                                   else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                    attachmentPicture.image = UIImage(named: "powerpoint")
                                   }
                                   else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                       || filetype == ".wma" || filetype == ".aac"{
                                       attachmentPicture.image = UIImage(named: "audio")
                                   }
                                    
                                   else if filetype == "/png" || filetype == "/jpg" || filetype == "jpeg"{
                                       if(baseURL?.prefix(8) == "https://"){
                                           if(self.attachment.prefix(8) != "https://"){
                                                 self.attachment = "https://" + self.attachment
                                             }
                                         }
                                         else if(baseURL?.prefix(7) == "http://"){
                                             if (self.attachment.prefix(7) != "http://" ){
                                                 self.attachment = "http://" + self.attachment
                                             }
                                         }
                                         attachmentPicture.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                       attachmentPicture.sd_setImage(with: URL(string: self.attachment),
                                        completed: { (image, error, cacheType, imageUrl) in
                                         
                                          })
                                       
                                   }else{
                                   attachmentPicture.image = UIImage(named: "doc_logo")
                                              }
                                          }
                                      }
                                  else{
                                      if self.isFileSelected == true{
                                          print("url ",self.pdfURL)
                                        let filetype = self.pdfURL.description.suffix(4).lowercased()
                                          if filetype == ".pdf"{
                                              attachmentPicture.image = UIImage(named: "pdf_logo")
                                          }else if filetype == "docx"{
                                              attachmentPicture.image = UIImage(named: "word_logo")
                                          }else if filetype == "xlsx"{
                                              attachmentPicture.image = UIImage(named: "excel_logo")
                                          }
                                          else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                           attachmentPicture.image = UIImage(named: "powerpoint")
                                          }
                                          else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                              || filetype == ".wma" || filetype == ".aac"{
                                              attachmentPicture.image = UIImage(named: "audio")
                                          }
                                          else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                              attachmentPicture.image = UIImage(named: "video")

                                          }
                                          else{
                                              attachmentPicture.image = UIImage(named: "doc_logo")
                                          }
                                      }else if self.isSelectedImage{
                                          print("selectedimage: \(self.selectedImage)")
                                          attachmentPicture.image = selectedImage
                                      }else{
                                          attachmentPicture.image = UIImage(named: "attach")
                                      }
                                  }
                                     
                            let attachmentButton = cell?.viewWithTag(722) as! UIButton
//                            attachmentButton.removeTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                            attachmentButton.addTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                            return cell!
                        case 8:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                            let saveButton = cell?.viewWithTag(725) as! UIButton
                            saveButton.removeTarget(self, action: #selector(addAssignment), for: .touchUpInside)

                            saveButton.addTarget(self, action: #selector(addAssignment), for: .touchUpInside)
                            return cell!
                        default:
                            return UITableViewCell()
                        }
                    case "Exam":
                        switch(indexPath.section){
                            case 2:
                             let cell = tableView.dequeueReusableCell(withIdentifier: "startEndReuse")
                             let dateLabel = cell?.viewWithTag(700) as! UILabel
                             dateLabel.text = "Due Date"
                             let dateValueLabel = cell?.viewWithTag(701) as! UILabel
                             let dateValueButton = cell?.viewWithTag(702) as! UIButton
                             let timeLabel = cell?.viewWithTag(703) as! UILabel
                             let timeButton = cell?.viewWithTag(704) as! UIButton
                             timeLabel.isHidden = true
                             timeButton.isHidden = true
                             dateLabel.text = "Starts"
                                let view = cell?.viewWithTag(90) as! UIView
                                view.layer.borderWidth = 1
                                view.borderColor = #colorLiteral(red: 0.2470588235, green: 0.5058823529, blue: 0.7647058824, alpha: 1)
                                view.layer.cornerRadius = 20
                                view.clipsToBounds = false
                            
                                 dateValueLabel.text = self.endDate
                             
                             
                             timeLabel.text = self.time
//                              dateValueButton.removeTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
                              dateValueButton.addTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
//                             timeButton.removeTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
                             timeButton.addTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
                             timeButton.isHidden = true
                             timeLabel.isHidden = true
                             return cell!

                            case 3:
                                let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
                                    let itemTypeSelector = cell?.viewWithTag(715) as! UITextField
                                    let dropDownArrow = cell?.viewWithTag(716) as! UIImageView
                                    let itemTypeButton = cell?.viewWithTag(717) as! UIButton
                                itemTypeSelector.placeholder = "Subjects"
                                
                                if(edit){
                                   if !self.teacherSubjectArray.isEmpty{
                                    self.addEvent.subjectId = Int(self.subjectId)!
                                    for sub in self.teacherSubjectArray{
                                        if(sub.id == self.addEvent.subjectId){
                                            self.selectedSubject = sub
                                            itemTypeSelector.text = sub.name
                                        }
                                    }
                                    }
                                }
                                
                                   itemTypeButton.removeTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                                    itemTypeButton.addTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                                    cell?.selectionStyle = .none
                                return cell!
                            case 4:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
                                let itemTypeSelector = cell?.viewWithTag(715) as! UITextField
                                let dropDownArrow = cell?.viewWithTag(716) as! UIImageView
                                let itemTypeButton = cell?.viewWithTag(717) as! UIButton
                            
                            if(edit){
                                if !self.teacherTermsArray.isEmpty{
                                   print("subject selected 101")
                                    for i in 0...self.teacherTermsArray.count - 1{
                                        
                                        if(self.teacherTermsArray[i].id == Int(self.subTerm)){
                                            self.addEvent.groupId = self.teacherTermsArray[i].id
                                            self.selectedGroup = self.teacherTermsArray[i].name
                                            itemTypeSelector.text = self.teacherTermsArray[i].name
                                        }
                                    }
                                }
                            }
                            
                                                        
                            
                            
                            
                            itemTypeSelector.placeholder = "Choose exam group here"
                             itemTypeButton.removeTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                                itemTypeButton.addTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                                cell?.selectionStyle = .none
                            return cell!
                            
                            case 5:
                                let cell = tableView.dequeueReusableCell(withIdentifier: "writeReuse")
                                let textView = cell?.viewWithTag(720) as! UITextView
                                textView.delegate = self;
                                if(edit){
                                    textView.text = assignmentBody
                                }

                                return cell!

                        case 6:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "pictureReuse")
                           let attachmentLabel = cell?.viewWithTag(720) as! UILabel
                           attachmentLabel.text = "Attach a file"
                            attachmentLabel.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                           
                           let attachmentPicture = cell?.viewWithTag(721) as! UIImageView
                          
                           if(self.edit){
                               if self.attachmentType == ""{
                                   attachmentPicture.image = UIImage(named: "attach")
                               }
                                else{
                                   let filetype = self.attachmentType.suffix(4)
                                   
                                   if(baseURL?.prefix(8) == "https://"){
                                     if(self.attachment.prefix(8) != "https://"){
                                           self.attachment = "https://" + self.attachment
                                       }
                                   }
                                   else if(baseURL?.prefix(7) == "http://"){
                                       if (self.attachment.prefix(7) != "http://" ){
                                           self.attachment = "http://" + self.attachment
                                       }
                                   }

                                  
                                       print("attachment type: \(filetype)")

                                       if filetype == "/pdf"{
                                           attachmentPicture.image = UIImage(named: "pdf_logo")
                                       }else if filetype == "docx"{
                                           attachmentPicture.image = UIImage(named: "word_logo")
                                       }else if filetype == "xlsx"{
                                           attachmentPicture.image = UIImage(named: "excel_logo")
                                       }
                                       else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                        attachmentPicture.image = UIImage(named: "powerpoint")
                                       }
                                       
                                       else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                           || filetype == ".wma" || filetype == ".aac"{
                                           attachmentPicture.image = UIImage(named: "audio")
                                       }
                                        
                                       else if filetype == "/png" || filetype == "/jpg" || filetype == "jpeg"{
                                           print("attachment attachment: \(self.attachment)")
                                             attachmentPicture.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                           attachmentPicture.sd_setImage(with: URL(string: self.attachment),
                                            completed: { (image, error, cacheType, imageUrl) in
                                             
                                              })
                                           
                                       }else{
                                           attachmentPicture.image = UIImage(named: "doc_logo")
                                       }
                          
                                   if self.selectAttachment == true{
                                       if self.isFileSelected == true{
                                            print("url ",self.pdfURL)
                                        let filetype = self.pdfURL.description.suffix(4).lowercased().lowercased()
                                            if filetype == ".pdf"{
                                                attachmentPicture.image = UIImage(named: "pdf_logo")
                                            }else if filetype == "docx"{
                                                attachmentPicture.image = UIImage(named: "word_logo")
                                            }else if filetype == "xlsx"{
                                                attachmentPicture.image = UIImage(named: "excel_logo")
                                            }
                                            
                                            else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                             attachmentPicture.image = UIImage(named: "powerpoint")
                                            }
                                            else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                                || filetype == ".wma" || filetype == ".aac"{
                                                attachmentPicture.image = UIImage(named: "audio")
                                            }
                                            else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                                attachmentPicture.image = UIImage(named: "video")

                                            }
                                            else{
                                                attachmentPicture.image = UIImage(named: "doc_logo")
                                            }
                                        }else if self.isSelectedImage{
                                            print("selectedimage: \(self.selectedImage)")
                                            attachmentPicture.image = selectedImage
                                        }else{
                                            attachmentPicture.image = UIImage(named: "attach")
                                        }
                                   }
                                   
                               }
                           }
                           else{
                               if self.isFileSelected == true{
                                   print("url ",self.pdfURL)
                                let filetype = self.pdfURL.description.suffix(4).lowercased()
                                   if filetype == ".pdf"{
                                       attachmentPicture.image = UIImage(named: "pdf_logo")
                                   }else if filetype == "docx"{
                                       attachmentPicture.image = UIImage(named: "word_logo")
                                   }else if filetype == "xlsx"{
                                       attachmentPicture.image = UIImage(named: "excel_logo")
                                   }
                                   
                                   else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                    attachmentPicture.image = UIImage(named: "powerpoint")
                                   }
                                   else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                       attachmentPicture.image = UIImage(named: "video")

                                   }
                                   else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                       || filetype == ".wma" || filetype == ".aac"{
                                       attachmentPicture.image = UIImage(named: "audio")
                                   }
                                   else{
                                       attachmentPicture.image = UIImage(named: "doc_logo")
                                   }
                               }else if self.isSelectedImage{
                                   print("selectedimage: \(self.selectedImage)")
                                   attachmentPicture.image = selectedImage
                               }else{
                                   attachmentPicture.image = UIImage(named: "attach")
                               }
                           }
                          
                           let attachmentButton = cell?.viewWithTag(722) as! UIButton
                        //                         attachmentButton.removeTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                               attachmentButton.addTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                               return cell!
                        case 7:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                            let saveButton = cell?.viewWithTag(725) as! UIButton
                            saveButton.removeTarget(self, action: #selector(addAssignment), for: .touchUpInside)
                            saveButton.addTarget(self, action: #selector(addAssignment), for: .touchUpInside)

                            return cell!

                        default:
                            return UITableViewCell()
                        }

                    case "Assessment":
                        switch (indexPath.section) {
                        case 2:
                           let cell = tableView.dequeueReusableCell(withIdentifier: "startEndReuse")
                            let dateLabel = cell?.viewWithTag(700) as! UILabel
                            dateLabel.text = "Due Date"
                            let dateValueLabel = cell?.viewWithTag(701) as! UILabel
                            let dateValueButton = cell?.viewWithTag(702) as! UIButton
                            let timeLabel = cell?.viewWithTag(703) as! UILabel
                            let timeButton = cell?.viewWithTag(704) as! UIButton
                            timeLabel.isHidden = true
                            timeButton.isHidden = true
                            dateLabel.text = "Starts"
                            let view = cell?.viewWithTag(90) as! UIView
                            view.layer.borderWidth = 1
                            view.borderColor = #colorLiteral(red: 0.2470588235, green: 0.5058823529, blue: 0.7647058824, alpha: 1)
                            view.layer.cornerRadius = 20
                            view.clipsToBounds = false
                            
//                            dateValueButton.removeTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
                             dateValueButton.addTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
//                           timeButton.removeTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
                            timeButton.addTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
                           timeButton.isHidden = true
                           timeLabel.isHidden = true
                           dateValueLabel.text = self.endDate
                           
                           timeLabel.text = self.time
                           return cell!

                        case 3:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
                                let itemTypeSelector = cell?.viewWithTag(715) as! UITextField
                            
                                let dropDownArrow = cell?.viewWithTag(716) as! UIImageView
                                let itemTypeButton = cell?.viewWithTag(717) as! UIButton
                                itemTypeSelector.placeholder = "Subjects"
                            
                            if(edit){
                               if !self.teacherSubjectArray.isEmpty{
                                self.addEvent.subjectId = Int(self.subjectId)!
                                for sub in self.teacherSubjectArray{
                                    if(sub.id == self.addEvent.subjectId){
                                        self.selectedSubject = sub
                                        itemTypeSelector.text = sub.name
                                    }
                                }
                                }
                            }
                            
                               itemTypeButton.removeTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                                itemTypeButton.addTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                                cell?.selectionStyle = .none
                            return cell!
                        case 4:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "titleTextReuse4")
                            let textField = cell?.viewWithTag(730) as! UITextField
                            textField.placeholder = "0.0"
                            textField.keyboardType = .numberPad
                            
                            textField.delegate = self
                            
                            if(edit){
                                textField.text = self.fullMark
                            }
                            return cell!
                        case 5:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "titleTextReuse5")
                            let textField = cell?.viewWithTag(730) as! UITextField
                            textField.placeholder = "Max. 20 Characters"
                           
                            if(edit){
                                textField.text = self.assignmentName
                            }
                            textField.delegate = self
                            return cell!


                        case 6:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
                            let itemTypeSelector = cell?.viewWithTag(715) as! UITextField
                            let dropDownArrow = cell?.viewWithTag(716) as! UIImageView
                            let itemTypeButton = cell?.viewWithTag(717) as! UIButton
                            itemTypeSelector.placeholder = "Choose exam group here"
                            
                            if(edit){
                                if !self.teacherTermsArray.isEmpty{
                                   print("subject selected 102")
                                    for i in 0...self.teacherTermsArray.count - 1{
                                        if(self.teacherTermsArray[i].id == Int(self.subTerm)){
                                            self.addEvent.groupId = self.teacherTermsArray[i].id
                                            self.selectedGroup = self.teacherTermsArray[i].name
                                            itemTypeSelector.text = self.teacherTermsArray[i].name
                                        }
                                        }
                                    }
                                }
                            
                            itemTypeButton.removeTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                            itemTypeButton.addTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                            cell?.selectionStyle = .none
                            return cell!
                        case 7:
                             let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
                            let itemTypeSelector = cell?.viewWithTag(715) as! UITextField
                            let dropDownArrow = cell?.viewWithTag(716) as! UIImageView
                            let itemTypeButton = cell?.viewWithTag(717) as! UIButton
                             
                             if(edit){
                                    if !self.assessmentsType.isEmpty{
                                        for i in 0...self.assessmentsType.count - 1{
                                            if(self.assessmentsType[i].id == Int(self.subSubjectId)){
                                                self.addEvent.assessmentTypeId = self.assessmentsType[i].id
                                                self.typeName = self.assessmentsType[i].name
                                                itemTypeSelector.text = self.assessmentsType[i].name
                                            }
                                        }
                                    }
                             }
                            itemTypeButton.removeTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                            itemTypeButton.addTarget(self, action: #selector(asstTypeDropDownFieldPressed), for: .touchUpInside)
                            cell?.selectionStyle = .none
                            return cell!

                        case 8:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "writeReuse")
                            let textView = cell?.viewWithTag(720) as! UITextView
                            textView.delegate = self
                            if(edit){
                                textView.text = self.assignmentBody
                            }

                            return cell!
                        case 9:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "pictureReuse")
                           let attachmentLabel = cell?.viewWithTag(720) as! UILabel
                           attachmentLabel.text = "Attach a file"
                            attachmentLabel.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
                           
                           let attachmentPicture = cell?.viewWithTag(721) as! UIImageView
                          
                           if(self.edit){
                               if self.attachmentType == ""{
                                   attachmentPicture.image = UIImage(named: "attach")
                               }
                                else{
                                   let filetype = self.attachmentType.suffix(4)
                                   
                                   if(baseURL?.prefix(8) == "https://"){
                                     if(self.attachment.prefix(8) != "https://"){
                                           self.attachment = "https://" + self.attachment
                                       }
                                   }
                                   else if(baseURL?.prefix(7) == "http://"){
                                       if (self.attachment.prefix(7) != "http://" ){
                                           self.attachment = "http://" + self.attachment
                                       }
                                   }

                                  
                                       print("attachment type: \(filetype)")

                                       if filetype == "/pdf"{
                                           attachmentPicture.image = UIImage(named: "pdf_logo")
                                       }else if filetype == "docx"{
                                           attachmentPicture.image = UIImage(named: "word_logo")
                                       }else if filetype == "xlsx"{
                                           attachmentPicture.image = UIImage(named: "excel_logo")
                                       }
                                       else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                        attachmentPicture.image = UIImage(named: "powerpoint")
                                       }
                                       
                                       else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                           || filetype == ".wma" || filetype == ".aac"{
                                           attachmentPicture.image = UIImage(named: "audio")
                                       }
                                        
                                       else if filetype == "/png" || filetype == "/jpg" || filetype == "jpeg"{
                                           print("attachment attachment: \(self.attachment)")
                                             attachmentPicture.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                           attachmentPicture.sd_setImage(with: URL(string: self.attachment),
                                            completed: { (image, error, cacheType, imageUrl) in
                                             
                                              })
                                           
                                       }else{
                                           attachmentPicture.image = UIImage(named: "doc_logo")
                                       }
                          
                                   if self.selectAttachment == true{
                                       if self.isFileSelected == true{
                                            print("url ",self.pdfURL)
                                        let filetype = self.pdfURL.description.suffix(4).lowercased().lowercased()
                                            if filetype == ".pdf"{
                                                attachmentPicture.image = UIImage(named: "pdf_logo")
                                            }else if filetype == "docx"{
                                                attachmentPicture.image = UIImage(named: "word_logo")
                                            }else if filetype == "xlsx"{
                                                attachmentPicture.image = UIImage(named: "excel_logo")
                                            }
                                            
                                            else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                             attachmentPicture.image = UIImage(named: "powerpoint")
                                            }
                                            else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                                || filetype == ".wma" || filetype == ".aac"{
                                                attachmentPicture.image = UIImage(named: "audio")
                                            }
                                            else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                                attachmentPicture.image = UIImage(named: "video")

                                            }
                                            else{
                                                attachmentPicture.image = UIImage(named: "doc_logo")
                                            }
                                        }else if self.isSelectedImage{
                                            print("selectedimage: \(self.selectedImage)")
                                            attachmentPicture.image = selectedImage
                                        }else{
                                            attachmentPicture.image = UIImage(named: "attach")
                                        }
                                   }
                                   
                               }
                           }
                           else{
                               if self.isFileSelected == true{
                                   print("url ",self.pdfURL)
                                let filetype = self.pdfURL.description.suffix(4).lowercased()
                                   if filetype == ".pdf"{
                                       attachmentPicture.image = UIImage(named: "pdf_logo")
                                   }else if filetype == "docx"{
                                       attachmentPicture.image = UIImage(named: "word_logo")
                                   }else if filetype == "xlsx"{
                                       attachmentPicture.image = UIImage(named: "excel_logo")
                                   }
                                   
                                   else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
                                    attachmentPicture.image = UIImage(named: "powerpoint")
                                   }
                                   else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                                       attachmentPicture.image = UIImage(named: "video")

                                   }
                                   else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                                       || filetype == ".wma" || filetype == ".aac"{
                                       attachmentPicture.image = UIImage(named: "audio")
                                   }
                                   else{
                                       attachmentPicture.image = UIImage(named: "doc_logo")
                                   }
                               }else if self.isSelectedImage{
                                   print("selectedimage: \(self.selectedImage)")
                                   attachmentPicture.image = selectedImage
                               }else{
                                   attachmentPicture.image = UIImage(named: "attach")
                               }
                           }
                          
                           let attachmentButton = cell?.viewWithTag(722) as! UIButton
                        //                         attachmentButton.removeTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                               attachmentButton.addTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
                               return cell!
                        case 10:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                            let saveButton = cell?.viewWithTag(725) as! UIButton
                           saveButton.removeTarget(self, action: #selector(addAssignment), for: .touchUpInside)
                            saveButton.addTarget(self, action: #selector(addAssignment), for: .touchUpInside)
                            return cell!
                            
                            
                        default:
                            return UITableViewCell()
                        }

                    default:
                        return UITableViewCell()

                    }
                }

                else if(self.itemType == "Online Exam"){
                    switch(indexPath.section){
                        case 1:
//                           let cell = tableView.dequeueReusableCell(withIdentifier: "dropdownReuse")
//                            let itemTypeSelector = cell?.viewWithTag(715) as! UITextField
//                            let dropDownArrow = cell?.viewWithTag(716) as! UIImageView
//                            let itemTypeButton = cell?.viewWithTag(717) as! UIButton
//                           itemTypeButton.removeTarget(self, action: #selector(onlineExamDropDownPressed), for: .touchUpInside)
//                            itemTypeButton.addTarget(self, action: #selector(onlineExamDropDownPressed), for: .touchUpInside)
//                            cell?.selectionStyle = .none
                            
                            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewReuse")
                             let collectionView = cell?.viewWithTag(14) as! UICollectionView

                             collectionView.delegate = self
                             collectionView.dataSource = self
                            collectionView.isScrollEnabled = false
                            collectionView.reloadData()
                             
                            return cell!
                        
                        case 2:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                            let saveButton = cell?.viewWithTag(725) as! UIButton
                            saveButton.removeTarget(self, action: #selector(addOnlineExam), for: .touchUpInside)
                            saveButton.addTarget(self, action: #selector(addOnlineExam), for: .touchUpInside)
                            return cell!
                        default:
                            return UITableViewCell()
                        }
                }
                else if(self.itemType.elementsEqual("Meeting room")){
                    switch(indexPath.section){
                        case 1:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
                            let textField = cell?.viewWithTag(730) as! UITextField
                            textField.delegate = self
                            textField.placeholder = "Meeting title goes here"
                        return cell!
                        case 2:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "startEndReuse")
                            let dateLabel = cell?.viewWithTag(700) as! UILabel
                            let dateValueLabel = cell?.viewWithTag(701) as! UILabel
                            let dateValueButton = cell?.viewWithTag(702) as! UIButton
                            let timeLabel = cell?.viewWithTag(703) as! UILabel
                            let timeButton = cell?.viewWithTag(704) as! UIButton
//                             dateValueButton.removeTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
                            dateValueButton.addTarget(self, action: #selector(dateButtonPressed), for: .touchUpInside)
//                            timeButton.removeTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
                            timeButton.addTarget(self, action: #selector(timeButtonPressed), for: .touchUpInside)
                            
                           
                            dateValueLabel.text = self.endDate
                            
                            timeLabel.text = self.time
                            return cell!
                            case 3:
                            let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
                            let saveButton = cell?.viewWithTag(725) as! UIButton
                        return cell!
                        default:
                            return UITableViewCell()
                        }
            }
        }

        


       return UITableViewCell()
}
}

    
    
    

extension AddLearningPathViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(itemType == "Digital Resources"){
            if(self.documentChoose){
                if(indexPath.section == 3){
                    if(self.documentsList.count < 5){
                        return 150
                    }
                    else{
                        return CGFloat(self.documentsList.count*100/5)
                    }
                }
            }
        }
        else if(itemType == "Online Exam"){
            if(indexPath.section == 1){
                if(self.onlineExamsList.count < 5){
                    return 150
                }
                else{
                    return CGFloat(self.onlineExamsList.count*150/5)
                }
            }
        }
            return UITableView.automaticDimension
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.addFormTableView.dequeueReusableCell(withIdentifier: "headerReuse")
        let headerTitle = header?.viewWithTag(30) as! UILabel
        if(self.itemType.elementsEqual("Digital Resources")){
//             if(section == 1){
//                if(documentCreate == true){
//                    headerTitle.text = "Document name"
//                }
//                else{
//                    headerTitle.text = ""
//                }
//             }
         }
         else if(self.itemType.elementsEqual("Assignment")){
             if(self.assignmentType.elementsEqual("Classwork")){
                 if(section == 3){
                     headerTitle.text = "Classwork Subject"
                 }
                 else if(section == 4){
                     headerTitle.text = "Write about the classwork"
                 }
                 else {return UIView()}
             }
             else if(self.assignmentType.elementsEqual("Homework")){
                            if(section == 3){
                                headerTitle.text = "Homework Subject"
                            }
                            else if(section == 4){
                                headerTitle.text = "Write about the homework"
                            }
                            else {return UIView()}
                        }
             else if(self.assignmentType.elementsEqual("Exam")){
                        if(section == 3){
                            headerTitle.text = "Exam Subject"
                        }
                        else if(section == 4){
                            headerTitle.text = "Sub-Term"
                        }
                        else if(section == 5){
                            headerTitle.text = "Write about the exam"
                        }
                         
                        else {
                            return UIView()
                        }
                    }
             else if(self.assignmentType.elementsEqual("Assessment")){
                 if(section == 3){
                     headerTitle.text = "Assessment Subject"
                 }
                 else if(section == 4){
                     headerTitle.text = "Full Mark"
                 }
                 else if(section == 5){
                     headerTitle.text = "Assessment Title"
                 }
                 else if(section == 6){
                      headerTitle.text = "Sub-Term"
                  }
                  else if(section == 7){
                      headerTitle.text = "Assessment Type"
                  }
                  else if(section == 8){
                      headerTitle.text = "Write about the assessment "
                  }
                 else {
                     return UIView()
                 }
             }
         }
         else if(self.itemType.elementsEqual("Online Exam")){
            if(section == 1){
                headerTitle.text = "Choose an Exam"
                headerTitle.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)

            }
         }
         else if(self.itemType.elementsEqual("Discussion")){
             
            if(section == 2){
                headerTitle.text = "Message"
             }
            
             else{
                 return UIView()
             }
         }
        
        return header?.contentView
    }
   
//    //MARK: Custom Tableview Headers
//     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if(self.itemType.elementsEqual("Document")){
//            if(section == 1){
//                return "Document name"
//            }
//        }
//        else if(self.itemType.elementsEqual("Assignment")){
//            if(self.assignmentType.elementsEqual("Classwork")){
//                if(section == 3){
//                    return "Classwork Subject"
//                }
//                else if(section == 4){
//                    return "Write about the classwork"
//                }
//                else {return ""}
//            }
//            else if(self.assignmentType.elementsEqual("Homework")){
//                           if(section == 3){
//                               return "Homework Subject"
//                           }
//                           else if(section == 4){
//                               return "Write about the homework"
//                           }
//                           else {return ""}
//                       }
//            else if(self.assignmentType.elementsEqual("Exam")){
//                       if(section == 3){
//                           return "Exam Subject"
//                       }
//                       else if(section == 4){
//                           return "Sub-Term"
//                       }
//                       else if(section == 5){
//                           return "Write about the exam"
//                       }
//
//                       else {
//                           return ""
//                       }
//                   }
//            else if(self.assignmentType.elementsEqual("Assessment")){
//                if(section == 3){
//                    return "Assessment Subject"
//                }
//                else if(section == 4){
//                    return "Full Mark"
//                }
//                else if(section == 5){
//                    return "Assessment Title"
//                }
//                else if(section == 6){
//                     return "Sub-Term"
//                 }
//                 else if(section == 7){
//                     return "Assessment Type"
//                 }
//                 else if(section == 8){
//                     return "Write about the assessment "
//                 }
//                else {
//                    return ""
//                }
//            }
//        }
//        else if(self.itemType.elementsEqual("Discussion")){
//            if(section == 1){
//                return "Discussion name"
//            }
//            else{
//                return ""
//            }
//        }
//
//        return ""
//    }

//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
//
//        view.tintColor = UIColor.white
//        let header = view as! UITableViewHeaderFooterView
//        if section == 0 {
//            header.textLabel?.textColor = UIColor.blue
//            view.tintColor = UIColor.white
//        }
//        else {
//            view.tintColor = UIColor.white
//        }
//    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          if(self.itemType.elementsEqual("Digital Resources")){
            return 0
            
            }
            else if(self.itemType.elementsEqual("Assignment")){
                if(self.assignmentType.elementsEqual("Homework") || self.assignmentType.elementsEqual("Classwork")){
                    if(section == 3 || section == 4){
                        return 50
                    }
                    else {return 0}
                }
            else if(self.assignmentType.elementsEqual("Exam")){
                    if(section == 3 || section == 4 || section == 5){
                        return 50

                    }
                    else{
                        return 0
                    }
                }
            else if(self.assignmentType.elementsEqual("Assessment")){
                if(section == 3 || section == 4 || section == 5 || section == 6 || section == 7 || section == 8){
                    return 50

                }
                else{
                    return 0
                }
            }
            
            }
            else if(self.itemType.elementsEqual("Online Exam")){
                if(section == 1){
                    return 50
                }
                else {
                    return 0
                }
                
            }
                else if(self.itemType.elementsEqual("Discussion")){
                    if(section == 2){
                        return 50
                    }
                    
                    else{
                        return 0
                    }
                }
       
                return 0
       }
}

// MARK: - UICollecionView functions:
extension AddLearningPathViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 12){
            return self.itemsList.count
        }
        else if(collectionView.tag == 13){
            return self.assignmentTypeList.count
        }
        else if(collectionView.tag == 14){
            return self.onlineExamsList.count
        }
        else if(collectionView.tag == 15){
            return self.documentsList.count
        }
        return 0
    }
    
    //MARK: Collection View For Events
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if(collectionView.tag == 12 || collectionView.tag == 13){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventsCell", for: indexPath)
            let eventIcon = cell.viewWithTag(21) as! UIImageView
            let titleLabel = cell.viewWithTag(23) as! UILabel
            let eventColorView: UIView? = cell.viewWithTag(24)
            let tickView: UIView? = cell.viewWithTag(25)
            titleLabel.lineBreakMode = .byClipping
//            let separatorCollectionViewFlowLayout: SeparatorCollectionViewFlowLayout

           
            let tickImageView = cell.viewWithTag(26) as! UIImageView
            let todayString = self.dateFormatter1.string(from: Date())
            eventColorView!.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
            eventColorView?.layer.masksToBounds = false
            titleLabel.font = UIFont(name: "OpenSans-Light", size: 9)
            cell.isUserInteractionEnabled = true
            cell.contentView.alpha = 1
            eventColorView?.isHidden = false
            eventColorView?.layer.cornerRadius = eventColorView!.frame.height / 2
            eventColorView?.dropCircleShadow()
            if(collectionView.tag == 12){
                titleLabel.text = self.itemsList[indexPath.row].name
                eventColorView?.backgroundColor = App.hexStringToUIColor(hex: self.itemsList[indexPath.row].color, alpha: 1.0)
                eventIcon.image = UIImage(named: self.itemsList[indexPath.row].image)
                if(self.edit){
                    collectionView.isUserInteractionEnabled = false
                    print("item typee: \(self.type)")
                    if(self.type == "document"){
                        self.itemType = "Digital Resources"
                        self.itemsList[0].selected = true
                    }
                    else if(self.type == "assignment"){
                        self.itemsList[1].selected = true

                    }
                    else if(self.type == "url"){
                        self.itemsList[2].selected = true

                    }
                    else if(self.type == "online_exam"){
                        self.itemsList[3].selected = true

                    }
                    else if(self.type == "discussion"){
                        self.itemsList[4].selected = true

                    }
                }
                else{
                    collectionView.isUserInteractionEnabled = true
                }
                
                if(self.itemsList[indexPath.row].selected){
                    tickView?.isHidden = false
                    tickImageView.isHidden = false
                    tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#568ef6", alpha: 1.0)
                    tickView?.layer.borderWidth = 0
                }
                else{
                    tickView?.isHidden = false
                    tickImageView.isHidden = false
                    tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#8F9190", alpha: 1.0)
                    tickView?.layer.borderWidth = 0
                }
            }
            else if(collectionView.tag == 13){
                titleLabel.text = self.assignmentTypeList[indexPath.row].name
                eventColorView?.backgroundColor = App.hexStringToUIColor(hex: self.assignmentTypeList[indexPath.row].color, alpha: 1.0)
                eventIcon.image = UIImage(named: self.assignmentTypeList[indexPath.row].image)
                
                if(self.edit){
                    collectionView.isUserInteractionEnabled = false
                    if(self.asstType == "homework"){
                        self.assignmentTypeList[0].selected = true
                    }
                    else if(self.asstType == "classwork"){
                        self.assignmentTypeList[1].selected = true

                    }
                    else if(self.asstType == "quiz"){
                        self.assignmentTypeList[2].selected = true

                    }
                    else if(self.asstType == "exam"){
                        self.assignmentTypeList[3].selected = true

                    }
                    
                }
                else{
                    collectionView.isUserInteractionEnabled = true
                }
                
                
                if(self.assignmentTypeList[indexPath.row].selected){
                    tickView?.isHidden = false
                    tickImageView.isHidden = false
                    tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#568ef6", alpha: 1.0)
                    tickView?.layer.borderWidth = 0
                }
                else{
                    tickView?.isHidden = false
                    tickImageView.isHidden = false
                    tickView?.backgroundColor = App.hexStringToUIColorCst(hex: "#8F9190", alpha: 1.0)
                    tickView?.layer.borderWidth = 0
                }
            }
            return cell
        }
        else{
            print("collection view height: \(collectionView.contentSize.height)")
            print("collection view height 2: \(collectionView.collectionViewLayout.collectionViewContentSize.height)")
            print("collectionview height 3: \(self.documentsList.count*100/5)")
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridReuse", for: indexPath)

            let title = cell.viewWithTag(77) as! UILabel
            if(collectionView.tag == 14){
                title.text = self.onlineExamsList[indexPath.row].name
                if(self.onlineExam != nil){
                    if(self.onlineExamsList[indexPath.row].id == self.onlineExam.id){
                        cell.backgroundColor = App.hexStringToUIColor(hex: "#C7DDF9", alpha: 1.0)
                        title.numberOfLines = 0
                    }
                    else{
                        cell.backgroundColor = App.hexStringToUIColor(hex: "#FFFFFF", alpha: 1.0)
                        title.numberOfLines = 1
                    }
                }
                
                
            }
            else{
                title.text = self.documentsList[indexPath.row].name
                if(self.documentsList[indexPath.row].id == self.documentId){
                    cell.backgroundColor = App.hexStringToUIColor(hex: "#C7DDF9", alpha: 1.0)
                    title.numberOfLines = 0
                    
                }
                else{
                    cell.backgroundColor = App.hexStringToUIColor(hex: "#FFFFFF", alpha: 1.0)
                    title.numberOfLines = 1
                }
            }
            
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("collectionview selected: \(self.documentsList.count)")
        print("collectionview selected: \(collectionView)")

        if(collectionView.tag == 12){
            self.documentCreate = false
            self.documentChoose = false
            self.newDocument = true
            self.existingDocuments = true
            self.documentId = ""
            self.itemType = self.itemsList[indexPath.row].name
            print("itemTypee: \(self.itemType)")
            self.assignmentType = ""
            self.addFormTableView.reloadData()
            for i in 0...itemsList.count - 1{
                itemsList[i].selected = false
            }
            self.itemsList[indexPath.row].selected = true
        }
        else if(collectionView.tag == 13){
            self.documentCreate = false
            self.documentChoose = false
            self.newDocument = true
            self.existingDocuments = true
            self.documentId = ""
            self.assignmentType = self.assignmentTypeList[indexPath.row].name
            self.addFormTableView.reloadData()
            for i in 0...self.assignmentTypeList.count - 1{
                self.assignmentTypeList[i].selected = false
            }
            self.assignmentTypeList[indexPath.row].selected = true
            
            self.assignmentType = self.assignmentTypeArray[indexPath.row]
            if(self.assignmentType.elementsEqual("Homework")){
                self.assignmentTypeNb = 1
            }
            else if(self.assignmentType.elementsEqual("Classwork")){
                self.assignmentTypeNb = 2
            }
            else if(self.assignmentType.elementsEqual("Assessment")){
                self.assignmentTypeNb = 3
            }
            else if(self.assignmentType.elementsEqual("Exam")){
                self.assignmentTypeNb = 4
            }
            
        }
        else if(collectionView.tag == 14){
            self.onlineExam = self.onlineExamsList[indexPath.row]
        }
        else if(collectionView.tag == 15){
            self.documentId = self.documentsList[indexPath.row].id
        }
       
        collectionView.reloadData()
        
        //calendarStyle = temp
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 50  , height:  50)
//        if(collectionView.tag == 14 || collectionView.tag == 15){
//            let bounds = collectionView.bounds
//            let heightVal = self.view.frame.height
//            let widthVal = self.view.frame.width
//            let cellsize = (heightVal < widthVal) ?  bounds.height/3 : bounds.width/3
//
//            return CGSize(width: cellsize - 10   , height:  cellsize - 10)
//        }
//        else{
//            let heightVal = self.view.frame.height
//            let widthVal = self.view.frame.width
//            return CGSize(width: widthVal  , height:  heightVal)
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        if(collectionView.tag == 12 || collectionView.tag == 13){
            return 0
//        }
//        else{
//            return 10
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
// APIS Calls
extension AddLearningPathViewController{
    
    func addChannel(user: User, batch_id: String, subject_id: String, title: String, code: String){
        if(!batch_id.isEmpty){
            if(!subject_id.isEmpty){
                if(!title.isEmpty){
                    if(!code.isEmpty){
                        let indicatorView = App.loading()
                         indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                         indicatorView.tag = 100
                         self.view.addSubview(indicatorView)
                        SectionVC.canChange = true
                        
                        Request.shared.addChannel(user: user, batch_id: batch_id, subject_id: subject_id, title: title, code: code){
                            (message, result, status) in
                            if(status == 200){
                                if let viewWithTag = self.view.viewWithTag(100){
                                    viewWithTag.removeFromSuperview()
                                        self.dismiss(animated: true) {
                                            self.delegate?.refreshBlended()
                                        }
                                    }
                  
                            }
                            else {
                                if let viewWithTag = self.view.viewWithTag(100){
                                    viewWithTag.removeFromSuperview()
                                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                                   App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                                }
                               
                            }
                        }
                    }
                    else{
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                        App.showAlert(self, title: "ERROR".localiz(), message: "Channel code not found", actions: [ok])
                    }
                }
                else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "ERROR".localiz(), message: "Channel title not found", actions: [ok])
                }
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: "Subjct not found", actions: [ok])
            }
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
        }
        
    }
    
    func addSection(user: User, batch_id: String, subject_id: String, title: String, code: String, startDate: String, channelId: String, sectionOrder: String){
        if(!batch_id.isEmpty){
            if(!subject_id.isEmpty){
                if(!title.isEmpty){
                    if(!code.isEmpty){
                        let indicatorView = App.loading()
                         indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                         indicatorView.tag = 100
                         self.view.addSubview(indicatorView)
                        SectionVC.canChange = true
                        
                        Request.shared.addSection(user: user, batch_id: batch_id, subject_id: subject_id, title: title, code: code, startDate: startDate, channelId: channelId, sectionOrder: sectionOrder){
                            (message, result, status) in
                            print("add section")
                            if(status == 200){
                                
                                if let viewWithTag = self.view.viewWithTag(100){
                                viewWithTag.removeFromSuperview()
                                    self.dismiss(animated: true) {
                                        self.delegate?.refreshBlended()
                                    }
                                }
                            }
                            else {
                                if let viewWithTag = self.view.viewWithTag(100){
                                    viewWithTag.removeFromSuperview()
                                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                                   App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                                }
                               
                            }
                        }
                    }
                    else{
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                        App.showAlert(self, title: "ERROR".localiz(), message: "Channel code not found", actions: [ok])
                    }
                }
                else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "ERROR".localiz(), message: "Channel title not found", actions: [ok])
                }
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: "Subjct not found", actions: [ok])
            }
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
        }
        
    
        
        
    }
    
    func editSection(user: User, batch_id: String, subject_id: String, title: String, code: String, startDate: String, channelId: String, sectionOrder: String, section_id: String){
        if(!batch_id.isEmpty){
            if(!subject_id.isEmpty){
                if(!channelId.isEmpty){
                    if(!section_id.isEmpty){
                        let indicatorView = App.loading()
                            indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                            indicatorView.tag = 100
                            self.view.addSubview(indicatorView)
                           SectionVC.canChange = true
                           
                           Request.shared.editSection(user: user, batch_id: batch_id, subject_id: subject_id, title: title, code: code, startDate: startDate, channelId: channelId, sectionOrder: sectionOrder, sectionId: sectionId){
                               (message, result, status) in
                               print("edit section")
                               if(status == 200){
                                   
                                   if let viewWithTag = self.view.viewWithTag(100){
                                   viewWithTag.removeFromSuperview()
                                       self.dismiss(animated: true) {
                                           self.delegate?.refreshBlended()
                                       }
                                   }
                               }
                               else {
                                   if let viewWithTag = self.view.viewWithTag(100){
                                       viewWithTag.removeFromSuperview()
                                       let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                                      App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                                   }
                                  
                               }
                           }
                        
                    }else{
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                       App.showAlert(self, title: "ERROR".localiz(), message: "Channel section not found", actions: [ok])
                    }
                    
                }
                else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                   App.showAlert(self, title: "ERROR".localiz(), message: "Channel not found", actions: [ok])
                }
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                               App.showAlert(self, title: "ERROR".localiz(), message: "Subject not found", actions: [ok])
            }
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                           App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
        }
       
       }
       
    func addItem(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam, id: String, subjectName: String, documentCreate: Bool, documentChoose: Bool, documentId: String){
        
        
                if(!type.isEmpty){
                    if(!section_id.isEmpty){
                        let indicatorView = App.loading()
                         indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                         indicatorView.tag = 100
                         self.view.addSubview(indicatorView)
                        SectionVC.canChange = true

                        Request.shared.addItem(user: user, type: type, section_id: section_id, title: title, url: url, startDate: startDate, agenda: agenda, id: id, subjectName: subjectName, documentCreate: documentCreate, documentChoose: documentChoose, documentId: documentId, replies: self.allowReplies){
                            (message, result, status) in
                            if(status == 200){
                                if let viewWithTag = self.view.viewWithTag(100){
                                viewWithTag.removeFromSuperview()
                                    self.dismiss(animated: true) {
                                        print("create homework: \(result)")
                                        self.delegate?.refreshBlended()
                                    }
                                }
                            }
                            else {
                                if let viewWithTag = self.view.viewWithTag(100){
                                viewWithTag.removeFromSuperview()
                                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                    App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                                }
                                
                            }
                        }
                         
                    }else{
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                       App.showAlert(self, title: "ERROR".localiz(), message: "Channel section not found", actions: [ok])
                    }
                    
                }
                else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                   App.showAlert(self, title: "ERROR".localiz(), message: "Channel not found", actions: [ok])
                }
 
        }
    
    func addItem1(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam, id: String, subjectName: String, documentCreate: Bool, documentChoose: Bool, documentId: String){
        
        if(!documentId.isEmpty){
        if(!type.isEmpty){
            if(!section_id.isEmpty){
                let indicatorView = App.loading()
                 indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                 indicatorView.tag = 100
                 self.view.addSubview(indicatorView)
                SectionVC.canChange = true

                Request.shared.addItem1(user: user, type: type, section_id: section_id, title: title, url: url, startDate: startDate, agenda: agenda, id: id, subjectName: subjectName, documentCreate: documentCreate, documentChoose: documentChoose, documentId: documentId){
                    (message, result, status) in
                    if(status == 200){
                        if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                            self.dismiss(animated: true) {
                                self.delegate?.refreshBlended()
                            }
                        }
                    }
                    else {
                        if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                            App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                        }
                        
                    }
                }
                 
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                               App.showAlert(self, title: "ERROR".localiz(), message: "Channel section not found", actions: [ok])
            }
            
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                           App.showAlert(self, title: "ERROR".localiz(), message: "Channel not found", actions: [ok])
        }
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                           App.showAlert(self, title: "ERROR".localiz(), message: "Document not found", actions: [ok])
        }
       
         
        }
    
    
    func addItemWithAttachment(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam, subjectName: String){
        
        if(!type.isEmpty){
            if(!section_id.isEmpty){
                
                let indicatorView = App.loading()
                 indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                 indicatorView.tag = 100
                 self.view.addSubview(indicatorView)
                SectionVC.canChange = true
                
                Request.shared.addItemWithAttachment(user: user, type: type, section_id: section_id, title: title, url: url, startDate: startDate, agenda: agenda, file: self.pdfURL, fileCompressed: compressedDataToPass, image: self.selectedImage, isSelectedImage: self.isSelectedImage, subjectName: subjectName, replies: self.allowReplies, filename: self.filename){
                    (message, result, status) in
                    if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                        self.dismiss(animated: true) {
                            self.delegate?.refreshBlended()
                        }
                    }
                     
                    }
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                               App.showAlert(self, title: "ERROR".localiz(), message: "Channel section not found", actions: [ok])
            }
            
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                           App.showAlert(self, title: "ERROR".localiz(), message: "Channel not found", actions: [ok])
        }

        
       
        }
        
    func editItem(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam, id: String, subjectName: String){
        if(!type.isEmpty){
            if(!section_id.isEmpty){
                
                let indicatorView = App.loading()
                 indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                 indicatorView.tag = 100
                 self.view.addSubview(indicatorView)
                SectionVC.canChange = true

                Request.shared.editItem(user: user, type: type, section_id: section_id, title: title, url: url, startDate: startDate, agenda: agenda, id: id, subjectName: subjectName){
                    (message, result, status) in
                    if(status == 200){
                        if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                            self.dismiss(animated: true) {
                                self.delegate?.refreshBlended()
                            }
                        }
                    }
                    else {
                        if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                            App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                        }
                        
                    }
                }
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                               App.showAlert(self, title: "ERROR".localiz(), message: "Channel section not found", actions: [ok])
            }
            
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                           App.showAlert(self, title: "ERROR".localiz(), message: "Channel not found", actions: [ok])
        }

        
       
         
        }
    
    
    
    func editItemWithAttachment(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam, subjectName: String, id: String){
        if(!type.isEmpty){
            if(!section_id.isEmpty){
                let indicatorView = App.loading()
                 indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                 indicatorView.tag = 100
                 self.view.addSubview(indicatorView)
                SectionVC.canChange = true
                
                Request.shared.editItemWithAttachment(user: user, type: type, section_id: section_id, title: title, url: url, startDate: startDate, agenda: agenda, file: self.pdfURL, image: self.selectedImage, isSelectedImage: self.isSelectedImage, subjectName: subjectName, id: id, selectAttachment: self.selectAttachment, attachmentLink: self.attachment, attachmentType: self.attachmentType, edit: self.edit, filename: self.filename){
                    (message, result, status) in
                    if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                        self.dismiss(animated: true) {
                            self.delegate?.refreshBlended()
                        }
                    }
                     
                    }
               
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                               App.showAlert(self, title: "ERROR".localiz(), message: "Channel section not found", actions: [ok])
            }
            
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                           App.showAlert(self, title: "ERROR".localiz(), message: "Channel not found", actions: [ok])
        }
        }
        
    
    
    func getUserOnlineExams(user: User, subjectId: String){
        if(!subjectId.isEmpty){
            
            Request.shared.getUserOnlineExams(user: user, subjectId: subjectId){
                (message, result, status) in
                if(status == 200){
                    self.onlineExamsList = result!
                    self.addFormTableView.reloadData()
                }
                else {
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                }
            }
        }
        
       
    }
    
    func getDocuments(user: User){
        Request.shared.getDocuments(user: user){
            (message, result, status) in
            if(status == 200){
                self.documentsList = result!
                self.addFormTableView.reloadData()
            }
            
        }
    }
    
    /// Description: Get Teacher Subject
       /// - Call "get_teacher_subjects" to mark an assessment as unchecked.
       /// - Select the first subject by default.
 func getSubjects(user: User, sectionId: Int){
    if(sectionId != 0){
        Request.shared.getTeacherSubject(user: user, sectionId: sectionId) { (message, subjectData, status) in
            if status == 200{
                self.teacherSubjectArray = subjectData!
                if !self.teacherSubjectArray.isEmpty{
                    self.selectedSubject = self.teacherSubjectArray.first!
                    let date = self.dateFormatter2.string(from: Date())
                    let time = App.pickerTimeFormatter.string(from: Date())
                    self.addEvent = AgendaExam(id: 0, title: "", type: "Classwork", students: [], subjectId: self.selectedSubject.id, startDate: date, startTime: time, endDate: date, endTime: time, description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: true, enableLateSubmissions: true, enableDiscussions: true, enableGrading: true, estimatedTime: 0)
                }
                
               self.getTerms(user: user, sectionId: Int(self.batchId) ?? 0)
             }
             
         }
    }
   
    
    
  }
  
  // Get Teacher Terms:
  /// Description: Get Teacher Terms
  /// - Call "get_sub_terms" API to get terms data and select the first term by default.
  func getTerms(user: User, sectionId: Int){
    if(sectionId != 0){
          Request.shared.getTeacherTerms(user: user, sectionId: sectionId) { (message, termsData, status) in
              if status == 200{
                  self.teacherTermsArray = termsData!
                  if !self.teacherTermsArray.isEmpty && !self.teacherSubjectArray.isEmpty{
                     self.getAssessment(user: self.user, subjectId: self.teacherSubjectArray.first!.id, termId: self.teacherTermsArray.first!.id)
                  }
              }
              else{
                  let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                  App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
              }
          }
    }
    
    
    
   
  }
  
  // Get Assessment Type:
  
  /// Description: Get Assessment Type
  /// - Call "get_assessment_types" API and get assessment type data.
  func getAssessment(user: User, subjectId: Int, termId: Int){
    
    if(termId != 0){
        if(subjectId != 0){
            Request.shared.getAssessmentType(user: user, subjectId: subjectId, termId: termId) { (message, assessmentData, status) in
                if status == 200{
                    self.assessmentsType = assessmentData!
                    print("assessment type111: \(self.assessmentsType)")
                  self.addFormTableView.reloadData()
                }
                else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                }
            }
        }
       
    }
    
    
     
  }
    
    /// Description: Get Section Student
       /// - Call "get_section_students" API and get section students.
       func getSectionStudent(user: User, sectionId: Int){
        
        if(sectionId != 0){
            Request.shared.getSectionStudent(user: user, sectionId: sectionId) { (message, studentData, status) in
                if status == 200{
                    self.teacherStudentsArray = studentData!
 //                   self.teacherStudentsArray = studentData!
                 var checkStudents: Bool = true
                    
                    print("students: \(self.teacherStudentsArray)")
//                    for student in self.teacherStudentsArray{
//
//                    }
                    
                    
                    var tempStudentList = self.teacherStudentsArray
                    
                    if(self.itemType == "Discussion"){
                        var tempDisStudents = 0
                        for i in 0...self.teacherStudentsArray.count - 1{
                            if(self.discussionStudents.contains(self.teacherStudentsArray[i].studentId)){
                                tempStudentList[i].active = true
                                tempDisStudents = tempDisStudents + 1;
                            }
                            else{
                                tempStudentList[i].active = false
                            }
                        }
                        
                        if(tempDisStudents == self.teacherStudentsArray.count){
                            self.allStudents = true;
                        }
                        
                    }
                    else{
                        for i in 0...self.teacherStudentsArray.count - 1{
                            print("student id: \(self.teacherStudentsArray[i].studentId)")
                            print("student list: \(self.studentList)")
                            print("comparison: \(self.studentList.contains(self.teacherStudentsArray[i].studentId))")
                            print("---------------------------------")
                            if(self.studentList.contains(self.teacherStudentsArray[i].studentId)){
                                tempStudentList[i].active = true
                                self.studentCount = self.studentCount + 1;
                            }
                            else{
                                tempStudentList[i].active = false
                            }
                        }
                        
                        if(self.studentCount == self.teacherStudentsArray.count){
                            self.allStudents = true;
                            self.studentCount = 0;
                        }
                       
                    }
                    
                    self.teacherStudentsArray = tempStudentList;
                    print("new student list: \(self.teacherStudentsArray)")

                   
                  
                 
//                 if(studentstemp.count>=1){
//                     for i in 0...studentstemp.count - 1{
//                                   if(self.studentList.contains(studentstemp[i].studentId)){
//                                       print("entered student")
//                                       studentstemp[i].active = true
//                                   }
//                                   else{
//                                       studentstemp[i].active = false
//                                      checkStudents = false
//                                   }
//                               }
//                               if(checkStudents){
//                                   self.allStudents = true
//                               }else{
//                                   self.allStudents = false
//                               }
//
//                          self.teacherStudentsArray = studentstemp
//                          for std in self.teacherStudentsArray{
//                              print("active students = \(std.active)")
//                          }
//                 }
           
                     self.addFormTableView.reloadData()

                }
                else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                }
            }
        }
          
       }
  
    
}
    
