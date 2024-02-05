//
//  NewMessageViewController.swift
//  SLink
//
//  Created by Maher Jaber on 25/10/2021.
//  Copyright © 2021 IQUAD. All rights reserved.
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

protocol MessageViewControllerDelegate{
    func refreshMessages()
}

class NewMessageViewController: UIViewController,UIDocumentPickerDelegate, UINavigationControllerDelegate, TableViewIndexDelegate, UITextViewDelegate{
   
    @IBOutlet weak var newMessageViewController: UITableView!
    @IBOutlet weak var closeFormButton: UIButton!
    var delegate: MessageViewControllerDelegate?
    var user: User!
    var allSelectedUsers: [CalendarEventItem] = []

    var imagePicker = UIImagePickerController()
    var expandDep: Bool = false
    var expandClass: Bool = false
    var canReply = true
    var pdfURL : URL!
    var selectAttachment: Bool = false
    var isFileSelected: Bool = false
    var isSelectedImage: Bool = false
    var filename: String = ""
    var selectedImage : UIImage = UIImage()
    var addEvent: AgendaExam!
    var selectedUsers: [Student] = []
    var selectedParents: [Student] = []


    var attachmentType: String = "text"
    var departments: [CalendarEventItem] = []
    var classes: [CalendarEventItem] = []
    var submittedUsers: String = ""
    var compressedDataToPass: NSData!
    var croppingStyle = CropViewCroppingStyle.default
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    var selecteduserNames : [String] = []
    var selectedParentNames: [String] = []
    var selectedDeps: [String] = []
    var selectedClasses: [String] = []
    var selectedUsersCount: Int = 0
    var selectedParentsCount: Int = 0
    var selectedDepartmentsCount: Int = 0
    var selectedClassesCount: Int = 0
    var school: SchoolActivation!
    
    override func viewDidLoad(){
        self.school = App.getSchoolActivation(schoolID: self.user.schoolId)

        newMessageViewController.dataSource = self
        newMessageViewController.delegate = self
        newMessageViewController.separatorStyle = .none
        self.getSectionsDepartments(user: self.user)

        imagePicker.delegate = self

        closeFormButton.addTarget(self, action: #selector(closeForm), for: .touchUpInside)
        
        self.addEvent = AgendaExam(id: 0, title: "", type: "", students: [], subjectId: 0, startDate: "", startTime: "", endDate: "", endTime: "", description: "", assignmentId: 0, assessmentTypeId: 0, groupId: 0, mark: 0.0, enableSubmissions: true, enableLateSubmissions: true, enableDiscussions: true, enableGrading: true, estimatedTime: 0)
        
        
    
    }
    
    @objc func closeForm(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func viewDetailsDeps(sender: UIButton){
         let cell = sender.superview?.superview?.superview
            
            print("expandDep: \(self.expandDep)")
            if(self.expandDep == false){
                self.expandDep = true
            }
            else{
                self.expandDep = false
            }
        
        

        self.newMessageViewController.reloadData()
        
       
        
    }
    
    @objc func viewDetailsClasses(sender: UIButton){
         let cell = sender.superview?.superview?.superview

        print("expandClass: \(self.expandClass)")
            if(self.expandClass == false){
                self.expandClass = true
            }
            else{
                self.expandClass = false
            }
        
        

        self.newMessageViewController.reloadData()
        
       
        
    }
    
    @objc func allUsersSwitchPressed(sender: UIButton){
//        self.allUsers = !self.allUsers
//        self.newMessageViewController.reloadData()
    }
    
    @objc func canreplyPressed(sender: UIButton){
        print("called called")
        self.canReply = !self.canReply
    }
    @objc func departmentSwitchPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = self.newMessageViewController.indexPath(for: cell)
        if(self.departments[indexpath!.row - 1].active){
            self.departments[indexpath!.row - 1].active = false
            self.selectedDepartmentsCount = self.selectedDepartmentsCount - 1
            
            self.allSelectedUsers = self.allSelectedUsers.filter {$0.title != String(self.departments[indexpath!.row - 1].id)}

        }
        else{
            self.departments[indexpath!.row - 1].active = true
            self.selectedDepartmentsCount = self.selectedDepartmentsCount + 1
            self.getEmployeesByDepartment(user: self.user, departmentId: self.departments[indexpath!.row - 1].id)
        }
        print("final final: \(self.allSelectedUsers)")

        
//        self.newMessageViewController.reloadData()
    }
    
    @objc func classSwitchPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = self.newMessageViewController.indexPath(for: cell)
        if(self.classes[indexpath!.row - 1].active){

            self.classes[indexpath!.row - 1].active = false
            self.selectedClassesCount = self.selectedClassesCount - 1
            self.allSelectedUsers = self.allSelectedUsers.filter {$0.title != String(self.classes[indexpath!.row - 1].id)}

        }
        else{
            self.classes[indexpath!.row - 1].active = true
            self.selectedClassesCount = self.selectedClassesCount + 1
            self.getStudentsBySection(user: self.user, sectionId: self.classes[indexpath!.row - 1].id)
            self.getParentsBySection(user: self.user, sectionId: self.classes[indexpath!.row - 1].id)

        }
        
        print("final final: \(self.allSelectedUsers)")
    }
    
    @objc func showClasses(sender: UIButton){
        print("hellomaher")
        
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = self.newMessageViewController.indexPath(for: cell)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentsViewController") as! StudentsViewController
        studentVC.delegate = self
        studentVC.user = self.user
        studentVC.type = "inbox"
        studentVC.departmentId = ""
        studentVC.sectionId = classes[indexpath!.row - 1].id ?? ""
 
        studentVC.modalPresentationStyle = .fullScreen
        self.present(studentVC, animated: true, completion: nil)
    }
    
    @objc func showDepartments(sender: UIButton){
        print("hellomaher")
      
        let cell = sender.superview?.superview as! UITableViewCell
        let indexpath = self.newMessageViewController.indexPath(for: cell)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentsViewController") as! StudentsViewController
        studentVC.delegate = self
        studentVC.user = self.user
        print("deps: \(indexpath!.row )")
        print("deps: \(departments.count)")

//        studentVC.students = []
        studentVC.departmentId = departments[indexpath!.row - 1].id ?? ""
        studentVC.sectionId = ""
        studentVC.modalPresentationStyle = .fullScreen
        self.present(studentVC, animated: true, completion: nil)
       }
    
    
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
        self.attachmentType = "file"
//        self.newMessageViewController.reloadData()
       }
       
       func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
           controller.dismiss(animated: true, completion: nil)
       }
    
    @objc func addMessage(){
        self.addNewMessage();
    }
       
    
}

extension NewMessageViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 4){
            if(self.expandDep == true){
                return self.departments.count + 1
            }
        }
        else if(section == 5){
            if(self.expandClass){
                return self.classes.count + 1
            }
        }
        else{
            return 1
        }
        return 1
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleTextReuse")
            let textField = cell?.viewWithTag(730) as! UITextField
            textField.placeholder = "Enter Message Title here"
            textField.delegate = self
            
            let documentTitle = cell?.viewWithTag(44) as! UILabel
            documentTitle.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
            documentTitle.text = "Message Title"
            documentTitle.backgroundColor = App.hexStringToUIColor(hex: "#FFFFFF", alpha: 1.0)
            
            
            

            return cell!

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "writeReuse")
             let textView = cell?.viewWithTag(5554) as! UITextView
             textView.delegate = self
            


             return cell!


        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentReuse")
            let studentsLabel = cell?.viewWithTag(74011) as! UILabel
            let uiswitch = cell?.viewWithTag(74111) as! PWSwitch
            
            studentsLabel.text = "Can Reply"
            uiswitch.removeTarget(self, action: #selector(canreplyPressed), for: .touchUpInside)
            uiswitch.addTarget(self, action: #selector(canreplyPressed), for: .touchUpInside)
            
            uiswitch.isEnabled = true

            uiswitch.setOn(self.canReply, animated: true)
           
            cell?.selectionStyle = .none
            return cell!
            
        case 4:

            
            if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse")
                cell?.selectionStyle = .none

            let dateLabel = cell?.viewWithTag(503)as!UILabel
                dateLabel.text = "\(self.selectedUsersCount) users/ \(self.selectedParentsCount) parents/ \(self.selectedDepartmentsCount) departments/ \(self.selectedClassesCount) classes"
                dateLabel.isHidden = true


            let titleView = cell?.viewWithTag(43) as! UIView
            titleView.backgroundColor = .blue
            let titleLabel = cell?.viewWithTag(44) as! UILabel
            let plusImage = cell?.viewWithTag(45) as! UIImageView
            let plusButton = cell?.viewWithTag(46) as! UIButton
            titleLabel.text = "departments"
                 plusButton.addTarget(self, action: #selector(viewDetailsDeps), for: .touchUpInside)

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

                 if(expandDep == true){
                     plusImage.image = UIImage(named: "-")

                 }else{
                     plusImage.image = UIImage(named: "+")

                 }


                 return cell!
             }
             else{
                 let cell = tableView.dequeueReusableCell(withIdentifier: "depListReuse")

                cell?.selectionStyle = .none
                     let nameLabel = cell?.viewWithTag(740) as! UILabel
                     let uiswitch = cell?.viewWithTag(741) as! PWSwitch
                let uiButton = cell?.viewWithTag(742) as! UIButton
                uiButton.isEnabled = true
                
                uiButton.addTarget(self, action: #selector(showDepartments), for: .touchUpInside)

                 nameLabel.text = self.departments[indexPath.row - 1].title
                uiswitch.removeTarget(self, action: #selector(departmentSwitchPressed), for: .touchUpInside)
                uiswitch.addTarget(self, action: #selector(departmentSwitchPressed), for: .touchUpInside)
         
                    uiswitch.isEnabled = true
                    uiButton.isEnabled = true
                 
                    if(self.departments[indexPath.row - 1].active == true){
                        uiswitch.setOn(true, animated: true)
                    }
                    else{
                        uiswitch.setOn(false, animated: true)
                    }
                        return cell!
                }

        case 5:

            if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse2")
                cell?.selectionStyle = .none

            let dateLabel = cell?.viewWithTag(503)as!UILabel
                dateLabel.text = "Select users for group message"
                dateLabel.isHidden = true


            let titleView = cell?.viewWithTag(43) as! UIView
            titleView.backgroundColor = .blue
            let titleLabel = cell?.viewWithTag(44) as! UILabel
            let plusImage = cell?.viewWithTag(45) as! UIImageView
            let plusButton = cell?.viewWithTag(46) as! UIButton
            titleLabel.text = "Classes List"
                 plusButton.addTarget(self, action: #selector(viewDetailsClasses), for: .touchUpInside)

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

                 if(expandClass == true){
                     plusImage.image = UIImage(named: "-")

                 }else{
                     plusImage.image = UIImage(named: "+")

                 }


                 return cell!
             }
             else{
                 let cell = tableView.dequeueReusableCell(withIdentifier: "classesListReuse")
                cell?.selectionStyle = .none
                     let nameLabel = cell?.viewWithTag(7401) as! UILabel
                     let uiswitch = cell?.viewWithTag(7411) as! PWSwitch
                let uiButton = cell?.viewWithTag(7421) as! UIButton
                uiButton.isEnabled = true
                uiButton.addTarget(self, action: #selector(showClasses), for: .touchUpInside)
                
                 nameLabel.text = self.classes[indexPath.row - 1].title
            //                                 uiswitch.removeTarget(self, action: #selector(studentSwitchPressed), for: .touchUpInside)
                uiswitch.addTarget(self, action: #selector(classSwitchPressed), for: .touchUpInside)
         
               
        
                    uiswitch.isEnabled = true
                    uiButton.isEnabled = true
                    if(self.classes[indexPath.row - 1].active){
                        print("entered switch1")
                        uiswitch.setOn(true, animated: true)
                    }
                    else{
                        print("entered switch2")
                        uiswitch.setOn(false, animated: true)
                    }
                
                        return cell!
                }

//
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pictureReuse")
             let attachmentLabel = cell?.viewWithTag(720) as! UILabel
            
             attachmentLabel.text = "Attach a file"
            attachmentLabel.textColor = App.hexStringToUIColor(hex: "#3F81C3", alpha: 1.0)
            let attachmentButton = cell?.viewWithTag(722) as! UIButton
           //attachmentButton.removeTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
           attachmentButton.addTarget(self, action: #selector(addPicturePressed), for: .touchUpInside)
             let attachmentPicture = cell?.viewWithTag(721) as! UIImageView
            
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
                   

            
            return cell!



        case 7:

            let cell = tableView.dequeueReusableCell(withIdentifier: "saveReuse")
            let saveButton = cell?.viewWithTag(725) as! UIButton
            saveButton.setTitle("Save", for: .normal)

            saveButton.addTarget(self, action: #selector(addMessage), for: .touchUpInside)
            return cell!
//
        default:
            return UITableViewCell()
        }
    }
    
    func addNewMessage(){
        
        let title = self.newMessageViewController.viewWithTag(730) as! UITextField
        let body = self.newMessageViewController.viewWithTag(5554) as! UITextView
        
        selecteduserNames = []
        selectedParentNames = []
        selectedDeps = []
        selectedClasses = []
            for user in self.selectedUsers{
                self.selecteduserNames.append(user.id)
            }
        for parent in self.selectedParents{
            self.selectedParentNames.append(parent.id)
        }
        
        for dep in departments{
            if(dep.active){
                print("departments: \(dep.title)")
                selectedDeps.append(dep.id)
            }
        }
        for cls in classes{
            if(cls.active){
                selectedClasses.append(cls.id)
            }
        }
        
        print("selected students: \(self.selecteduserNames)")
        print("selected parents: \(self.selectedParentNames)")

        
        

            if(!title.text!.isEmpty){
                if(!body.text.isEmpty){
                    if(selecteduserNames.count != 0 || selectedParentNames.count != 0 || selectedDeps.count != 0 || selectedClasses.count != 0){
                        self.addEvent.title = title.text ?? "Group Subject"
                        self.addEvent.description = body.text
//                        self.addEvent.students = self.selectedStudentd
                        
                        print("students: \(selecteduserNames)")
                        print("parents: \(selectedParentNames)")
                        print("deps: \(selectedDeps)")
                        print("classes: \(selectedClasses)")

                        var allUsers: [String] = []
                        for us in self.allSelectedUsers{
                            allUsers.append(us.id)
                        }
                        if(self.isFileSelected == false && self.isSelectedImage == false){
                            self.createInboxMessage(user: user, title: title.text!, agenda: self.addEvent, allSelectedUsers: allUsers, canReply: self.canReply)
                        }
                        else{
                            self.createInboxMessageWithAttachment(user: user, title: title.text!, agenda: self.addEvent, allSelectedUsers: allUsers, canReply: canReply)
                        }

                    }
                    else{
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                       App.showAlert(self, title: "ERROR".localiz(), message: "Please Select at least one user", actions: [ok])
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
extension NewMessageViewController: UITableViewDelegate{
    
}

extension NewMessageViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 20
          let currentString: NSString = textField.text! as NSString
          let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
          return newString.length <= maxLength
        
        
    }
}

extension NewMessageViewController{
    func newMessage(){
        //API call
    }
    
    /// Description:
    /// - This function call "get_sections_and_departments" API to get sections and departments data.
    func getSectionsDepartments(user: User){
        Request.shared.getDepartments(user: user) { (message, departmentData, status) in
            if status == 200{
                self.departments = departmentData!
            }
            else{
                print("error", "getSectionsDepartments")
            }
        }
        
        Request.shared.getSections(user: user) { (message, sectionData, status) in
            if status == 200{
                self.classes = sectionData!
                
            }
            else{
                print("error", "getSectionsDepartments")
            }
        }
    }
    
    func getEmployeesByDepartment(user: User, departmentId: String){
        Request.shared.getEmployeesByDepartment(user: user, departmentId: departmentId) { (message, departmentData, status) in
            if status == 200{

                self.allSelectedUsers = self.allSelectedUsers + departmentData!
                print("test test test1: \(self.allSelectedUsers)")

            }
            else{
                print("error", "getSectionsDepartments")
            }
        }


    }

    func getStudentsBySection(user: User, sectionId: String){
        Request.shared.getStudentsBySection(user: user, sectionId: sectionId) { (message, sectionsData, status) in
            if status == 200{
                self.allSelectedUsers = self.allSelectedUsers + sectionsData!

                print("test test test2: \(self.allSelectedUsers)")

            }
            else{
                print("error", "getSectionsDepartments")
            }
        }


    }
    
    func getParentsBySection(user: User, sectionId: String){
        Request.shared.getParentsBySection(user: user, sectionId: sectionId) { (message, sectionsData, status) in
            if status == 200{
                self.allSelectedUsers = self.allSelectedUsers + sectionsData!

                print("test test test2: \(self.allSelectedUsers)")

            }
            else{
                print("error", "getSectionsDepartments")
            }
        }


    }

//    func getAllowedRecipients(user: User){
//
//        //add indicator view first time only
//        let indicatorView = App.loading()
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
//
//        Request.shared.getAllowedRecipients(user: user) { (message, departmentsList, studentsData, status) in
//            if status == 200{
//                print("data received: \(departmentsList)")
//                print("data received: \(studentsData)")
//
//                self.departments = departmentsList!
//                self.classes = studentsData!
//
//
//            }else{
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
//            }
//            if let viewWithTag = self.view.viewWithTag(100){
//                viewWithTag.removeFromSuperview()
//            }
//        }
//    }
    
    func createInboxMessage(user: User, title: String, agenda: AgendaExam, allSelectedUsers: [String], canReply: Bool){
        
        
                        let indicatorView = App.loading()
                         indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                         indicatorView.tag = 100
                         self.view.addSubview(indicatorView)
                        SectionVC.canChange = true

        Request.shared.createInboxMessage(user: user, title: title, agenda: agenda, allSelectedUsers: allSelectedUsers, canReply: canReply, schoolInfo: self.school){
                            (message, result, status) in
                            if(status == 200){
                                if let viewWithTag = self.view.viewWithTag(100){
                                viewWithTag.removeFromSuperview()
                                    self.dismiss(animated: true) {
                                        self.delegate?.refreshMessages()
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
    
    func createInboxMessageWithAttachment(user: User, title: String, agenda: AgendaExam, allSelectedUsers: [String], canReply: Bool){
        
        
                        let indicatorView = App.loading()
                         indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                         indicatorView.tag = 100
                         self.view.addSubview(indicatorView)
                        SectionVC.canChange = true

        Request.shared.createInboxMessageWithAttachment(user: user, title: title, agenda: agenda, file: self.pdfURL, fileCompressed: compressedDataToPass, image: self.selectedImage, isSelectedImage: self.isSelectedImage, filename: self.filename, allSelectedUsers: allSelectedUsers, canReply: canReply, type: self.attachmentType, schoolInfo: self.school){
                            (message, result, status) in
                            if(status == 200){
                                if let viewWithTag = self.view.viewWithTag(100){
                                viewWithTag.removeFromSuperview()
                                    self.dismiss(animated: true) {
                                        self.delegate?.refreshMessages()
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
    
}

extension NewMessageViewController: StudentsViewControllerDelegate{
    func selectedStudents(students: [Student], std: String, parents: [Student]) {
        print("returned students: \(students)")
            
        for student in students{
            self.selectedUsers.append(student)
        }
        
        for parent in parents{
            self.selectedParents.append(parent)
        }
        self.selectedUsersCount = self.selectedUsers.count
        self.selectedParentsCount = self.selectedParents.count
       
    }
    
    
}

extension NewMessageViewController: UIImagePickerControllerDelegate, CropViewControllerDelegate{
    
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
                filename = "SLink"
            }
            
            print("filename: \(filename)")
            
            self.newMessageViewController.reloadData()
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
                self.attachmentType = "image"

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
                self.newMessageViewController.reloadData()
                self.attachmentType = "file"


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
        self.attachmentType = "image"

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
        let imageView = newMessageViewController.viewWithTag(721) as! UIImageView
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
        self.attachmentType = "image"

        }
    
    public func layoutImageView() {
        let imageView = newMessageViewController.viewWithTag(721) as! UIImageView
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
        
        self.attachmentType = "image"
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

