//
//  BlendedLearningViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 6/24/20.
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
import ActiveLabel

protocol BlendedLearningViewControllerDelegate {
    func blendedPressed()
    func goToBlended()
    func blendedToCalendar()
}



class BlendedLearningViewController: UIViewController{
    @IBOutlet weak var blendedLearningTableView: UITableView!
    
    var documentInteractionController: UIDocumentInteractionController!
    
    var refreshControl = UIRefreshControl()
       
    var blendedDelegate: BlendedLearningViewControllerDelegate?
    var subjectList = [Subject]()
    var child: Children!
    var user: User!
    var schoolInfo: SchoolActivation!
    var channelsCodes = [String]()
//    var channelsNames = ["Learning Channel1","Learning Channel2","Learning Channel3","Learning Channel4"]
//    var channelSections = [String:[SectionsModel]]()
//    var sectionDetails = [String: [SectionDetailsModel]]()
    var channelName: String = ""
    var sectionName: String = ""
    var colorList: [String] = ["#6ebee9","#cb57a0","#46bc8c","#f2cf61","#ec7078","#bed964","#fcb25b","#f16822","#7a60ab","#e2db57","#1195aa","#4a74ba"]
    var typeColorsMap: [String:String] = [:]
    var actualChannel: ChannelModel = ChannelModel(channelId: "", channelCode: "", channelName: "", channelColor: "", channelDate: "", channelPublished: false, sectionsList: [], userId: "")
    var actualSection: SectionModel = SectionModel(id: "", name: "", color: "", isTicked: false, expand: false, sectionDetailsList: [], date: "", sectionOrder: 0, url: "", urlTitle: "", code: "", userId: "")
    var allSections: [SectionModel] = []
    var selectedSubject = Subject.init(id: 0, name: "", code: "", sectionId: 0, sectionName: "", color: "", imperiumCode: "")
    var allClasses: [Class] = []
    var batchId: Int!
    var className: String!
    var channelsControlList: [ChannelModel] = []
    var channelCodes: [String] = []
    var channelList: [String: [SectionModel]] = [:]
    var subjectIndex = 0
    var itemType = ""
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")
    var expandList: [String:Bool] = [:]
    var channelNameIndex = 0
    var appTheme: AppTheme!

    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var onlineExamDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var pickerDateFormatter1: DateFormatter = {
                  let formatter = DateFormatter()
                  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                  formatter.locale = Locale(identifier: "en_US_POSIX")
          //        formatter.locale = Locale(identifier: "\(self.languageId)")
                  return formatter
              }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blendedLearningTableView.isHidden = true;
        
        self.typeColorsMap["document"] = "#46BC8C"
        self.typeColorsMap["assignment"] = "#F1A420"
        self.typeColorsMap["url"] = "#CB57A0"
        self.typeColorsMap["online_exam"] = "#4A74BA"
        self.typeColorsMap["discussion"] = "#7A60AB"
        if user != nil{
            if(user.userType == 3 || user.userType == 4){
                batchId = self.user.classes.first?.batchId ?? 0
            }
            
            
            if(user.userType == 1 || user.userType == 2){
                //getSubjects(user: user, sectionId: batchId)
            }
            else{
                //getStudentSubjects(user: user, sectionId: self.user.classes.first?.batchId ?? 0)
            }
            
            
//            channelName = "1"
            channelList[channelName] = allSections
            
        }
        
    }
    
    @IBAction func webLinkButton(_ sender: UIButton) {
        
        self.getSchool()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
        
        if(blendedLearningTableView != nil){
            blendedLearningTableView.dataSource = self
            blendedLearningTableView.delegate = self
        }
        
        self.blendedDelegate?.blendedPressed()
           
       }
    func editLearningPath(section: Int, row: Int){
        
        if(row == 0){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let studentVC = storyboard.instantiateViewController(withIdentifier: "AddLearningPathViewController") as! AddLearningPathViewController
            studentVC.user = self.user
            studentVC.addType = "section"
            studentVC.pageTitle = "Edit section"
            studentVC.delegate = self
            studentVC.batchId = String(self.subjectList[subjectIndex].sectionId)
            studentVC.subjectName = self.subjectList[subjectIndex].name
            studentVC.subjectId = String(self.subjectList[subjectIndex].id)
            studentVC.channelId = self.channelName
            studentVC.edit = true
            studentVC.sectionId = self.channelList[self.channelName]![section - 3].id
            studentVC.sectionCode = self.channelList[self.channelName]![section - 3].code
            studentVC.sectionTitle = self.channelList[self.channelName]![section - 3].name
            studentVC.sectionDate = self.channelList[self.channelName]![section - 3].date
            studentVC.channelIndex = self.channelNameIndex
//            studentVC.subjectIndex = self.subjectIndex
            studentVC.modalPresentationStyle = .overFullScreen
            self.present(studentVC, animated: true, completion: nil)
                   
        }
       
        else{
            let type = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].type
            if type == "meeting_room" || type == "online_exam"{
                let alert = UIAlertController(title: "Alert".localiz(), message: "you cannot edit this item".localiz(), preferredStyle: UIAlertController.Style.alert)
                                                  
                alert.addAction(UIAlertAction(title: "OK".localiz(), style: UIAlertAction.Style.default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                 let studentVC = storyboard.instantiateViewController(withIdentifier: "AddLearningPathViewController") as! AddLearningPathViewController

                 studentVC.user = self.user
                 studentVC.addType = "item"
                 studentVC.delegate = self
                 studentVC.pageTitle = "Add new Activity"
                 studentVC.batchId = String(self.subjectList[subjectIndex].sectionId)
                 studentVC.subjectId = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].subjectId
                 studentVC.sectionId = self.channelList[self.channelName]![section - 3].id
                 studentVC.edit = true
                 studentVC.type = type
                 studentVC.itemId = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].id
                 studentVC.modalPresentationStyle = .overFullScreen
                studentVC.channelIndex = self.channelNameIndex
               


                print("item type: \(type)")
                print("item type: \(self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1])")

                 if(type.elementsEqual("document")){
                     studentVC.documentName = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].body
                     studentVC.attachment = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].attachmentLink
                     studentVC.attachmentType = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].attachmentContentType
                     print("attachment link: \(self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].attachmentLink)")
                     self.present(studentVC, animated: true, completion: nil)


                 }
               
                 else if(type.elementsEqual("url")){
                     studentVC.titleURL = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].title
                     studentVC.url = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].body
                     self.present(studentVC, animated: true, completion: nil)


                 }
                 else if(type.elementsEqual("discussion")){
                    print("discussion title: \(self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1])")
                    studentVC.discussionStudents = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].discussionStudent
                    studentVC.discussionTitle = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].body
                    self.present(studentVC, animated: true, completion: nil)

                    
                 }
                 else if(type.elementsEqual("assignment")){
                     print("homework student list: \(self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].assignmentStudentList)")
                     print("assignment date: \(self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].assignmentDate)")

                     let assignmentType = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].assignmentType
                     studentVC.asstType = assignmentType
                    studentVC.assignmentName = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].title
                    studentVC.assignmentBody = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].body
                    studentVC.studentList = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].assignmentStudentList
                    studentVC.assignmentDate = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].assignmentDate
                    studentVC.attachment = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].attachmentLink
                    studentVC.attachmentType = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].attachmentContentType

                    if(assignmentType.elementsEqual("exam")){
                        studentVC.subTerm = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].madrasatieSubTermId
                    }
                    else if(assignmentType.elementsEqual("quiz")){
                        studentVC.subTerm = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].madrasatieSubTermId
                        studentVC.subSubjectId = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].madrasatieSubSubjectId
                        studentVC.fullMark = self.channelList[self.channelName]![section - 3].sectionDetailsList[row - 1].fullMark

                    }
                    self.present(studentVC, animated: true, completion: nil)
                }
                       }
            }

            
        
    }
    
    @objc func deleteCh(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state != UIGestureRecognizer.State.ended {
            return
        }

        let collectionView = self.blendedLearningTableView.viewWithTag(12) as! UICollectionView
        let p = gesture.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: p)

        if let index = indexPath {
            var cell = collectionView.cellForItem(at: index)
            // do stuff with your cell, for example print the indexPath
            
            if(user.userType != 2 || Int(self.channelsControlList[index.row].userId) != user.userId){
                let alert = UIAlertController(title: "Alert".localiz(), message: "you cannot delete this learning path".localiz(),         preferredStyle: UIAlertController.Style.alert)
                                   
                alert.addAction(UIAlertAction(title: "OK".localiz(), style: UIAlertAction.Style.default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else if(self.channelsControlList[index.row].sectionsList.count > 1){
                let alert = UIAlertController(title: "Alert".localiz(), message: "You cannot delete non-empty learning path".localiz(),         preferredStyle: UIAlertController.Style.alert)
                                   
                alert.addAction(UIAlertAction(title: "OK".localiz(), style: UIAlertAction.Style.default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Are you sure?".localiz(), message: "Are you sure you want to delete this learning path?".localiz(),         preferredStyle: UIAlertController.Style.alert)
                                    
                alert.addAction(UIAlertAction(title: "Cancel".localiz(), style: UIAlertAction.Style.default, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "OK".localiz(),style: UIAlertAction.Style.default,handler: {(_: UIAlertAction!) in
                    
                    
                    if(!self.channelsControlList[index.row].channelId.isEmpty){
                        if(!String(self.batchId).isEmpty){
                            if(!String(self.subjectList[self.subjectIndex].id).isEmpty){
                                self.deleteChannel(user: self.user, channelId: self.channelsControlList[index.row].channelId,batch_id: String(self.batchId), subject_id: String(self.subjectList[self.subjectIndex].id), colorList: self.colorList)
                            }
//                            else{
//                                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                                App.showAlert(self, title: "ERROR".localiz(), message: "Subject not found", actions: [ok])
//                            }
                            
                        }
//                        else{
//                            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                            App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
//                        }
                        
                    }
//                    else{
//                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                        App.showAlert(self, title: "ERROR".localiz(), message: "Channel not found", actions: [ok])
//                    }
                   
                
                }))
                self.present(alert, animated: true, completion: nil)
                           
            }
           
            

             print(index.row)
        } else {
            print("Could not find index path")
        }
        
    }
    
    @objc func publish(sender: UIButton){
        var message = ""
        if(self.channelsControlList[self.channelNameIndex].channelPublished == true){
            message = "Are you sure you want to unpublish this learning path?"
        }
        else{
            message = "Are you sure you want to publish this learning path?"

        }
        let alert = UIAlertController(title: "Are you sure?".localiz(), message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel".localiz(), style: UIAlertAction.Style.default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "OK".localiz(),style: UIAlertAction.Style.default,handler: {(_: UIAlertAction!) in
            if(!self.channelName.isEmpty){
                if(!String(self.batchId).isEmpty){
                    if(!String(self.subjectList[self.subjectIndex].id).isEmpty){
                        self.publishChannel(user: self.user, channelId: self.channelName, batch_id: String(self.batchId), subject_id: String(self.subjectList[self.subjectIndex].id), colorList: self.colorList)
                    }
//                    else{
//                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                        App.showAlert(self, title: "ERROR".localiz(), message: "Subject not found", actions: [ok])
//                    }
                    
                }
//                else{
//                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                    App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
//                }
                
            }
//            else{
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR".localiz(), message: "Item not found", actions: [ok])
//            }
            
        }))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    @objc func openChannel(sender: UIButton){
           let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
        if(String(self.subjectList[subjectIndex].sectionId).isEmpty){
             App.showAlert(self, title: "Error".localiz(), message: "No section found".localiz(), actions: [ok])
        }
        else if(self.subjectList.count == 0){
            App.showAlert(self, title: "Error".localiz(), message: "No subject found".localiz(), actions: [ok])
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let studentVC = storyboard.instantiateViewController(withIdentifier: "AddLearningPathViewController") as! AddLearningPathViewController
            studentVC.user = self.user
            studentVC.addType = "channel"
            studentVC.pageTitle = "Add New Learning Path"
            studentVC.delegate = self
            studentVC.batchId = String(self.subjectList[subjectIndex].sectionId)
            studentVC.subjectId = String(self.subjectList[subjectIndex].id)

            
            studentVC.modalPresentationStyle = .overFullScreen
                   self.present(studentVC, animated: true, completion: nil)
        }
       
        
    }
    
    
    @objc func openSection(addItemGestureRecognizer: UITapGestureRecognizer){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "AddLearningPathViewController") as! AddLearningPathViewController
        studentVC.user = self.user
        studentVC.addType = "section"
        studentVC.pageTitle = "Add new section"
        studentVC.delegate = self
        studentVC.batchId = String(self.subjectList[subjectIndex].sectionId)
        studentVC.subjectId = String(self.subjectList[subjectIndex].id)
        studentVC.channelId = self.channelName
        studentVC.channelIndex = self.channelNameIndex
        studentVC.modalPresentationStyle = .overFullScreen
        self.present(studentVC, animated: true, completion: nil)
        
    }
    

    @objc func openSubmission(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        let index = self.blendedLearningTableView.indexPath(for: cell)
        
        if(self.user.userType == 2){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentRepliesViewController") as! StudentRepliesViewController
            studentVC.color = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].color
            studentVC.user = self.user
            studentVC.assignmentId = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].assignmentId
            studentVC.batchId = String(self.subjectList[subjectIndex].sectionId)
            studentVC.modalPresentationStyle = .overFullScreen
            self.present(studentVC, animated: true, completion: nil)
        
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let studentVC = storyboard.instantiateViewController(withIdentifier: "StudentRepliesViewController") as! StudentRepliesViewController
            studentVC.color = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].color
            studentVC.user = self.user
            studentVC.assignmentId = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].assignmentId
            studentVC.modalPresentationStyle = .overFullScreen
            self.present(studentVC, animated: true, completion: nil)
        }
    }
    @objc func  openDiscussion(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        let index = self.blendedLearningTableView.indexPath(for: cell)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "DiscussionMessagesViewController") as! DiscussionMessagesViewController
        
        print("discussion: \(self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1])")
        studentVC.user = self.user
        studentVC.type = "discussion"
        studentVC.recipientNumber = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].recipientNumber
        studentVC.groupName = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].body
        studentVC.messageThreadId = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].messageThreadId

//        studentVC.addType = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].
//        studentVC.delegate = self
//        studentVC.pageTitle = "Add new item"
//        studentVC.batchId = String(self.subjectList[subjectIndex].sectionId)
//        studentVC.subjectId = String(self.subjectList[subjectIndex].id)
//        studentVC.sectionId = self.actualSection.id
        studentVC.modalPresentationStyle = .overFullScreen
        self.present(studentVC, animated: true, completion: nil)
    }
    @objc func openUrl(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        let index = self.blendedLearningTableView.indexPath(for: cell)
        
        var url = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].body
        print("item type2: \(self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].type)")
        print("url url2: \(url)")
        
        if(!url.contains("https://") || !url.contains("http://")){
            if(baseURL?.prefix(8) == "https://"){
                if(url.prefix(8) != "https://"){
                    url = "https://" + url
                }
            }
            else if(baseURL?.prefix(7) == "http://"){
                if (url.prefix(7) != "http://" ){
                    url = "http://" + url
                }
            }
        }
        let urlfixed = url.replacingOccurrences(of: " ", with: "%20")
        
        
            let alert = UIAlertController(title: "Open Attachment".localiz(), message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "View", style: .default, handler: { _ in
                self.viewDocument(url: urlfixed, index: index!)
            }))
            
            alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { _ in
                self.downloadDocument(url: urlfixed)
            }))
            
        
           
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                alert.popoverPresentationController?.sourceView = sender
                alert.popoverPresentationController?.sourceRect = (sender).bounds
    //                alert.popoverPresentationController?.permittedArrowDirections = .up
            default:
                break
            }
            self.present(alert, animated: true, completion: nil)
        
        
        

    }
    func downloadDocument(url: String){
        guard let safari = URL(string: url) else { return }
        UIApplication.shared.open(safari)
    }
    func viewDocument(url: String, index: IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "OpenAttachmentViewController") as! OpenAttachmentViewController
        studentVC.linkText = url
        studentVC.attachmentName = self.channelList[self.channelName]![index.section - 3].sectionDetailsList[index.row - 1].attachmentFilename
        studentVC.attachmentType = self.channelList[self.channelName]![index.section - 3].sectionDetailsList[index.row - 1].attachmentContentType
        studentVC.modalPresentationStyle = .overFullScreen
        self.present(studentVC, animated: true, completion: nil)
    }
    @objc func openOnlineExam(sender: UIButton){
        let cell = sender.superview?.superview?.superview?.superview?.superview as! UITableViewCell
          let index = self.blendedLearningTableView.indexPath(for: cell)
          
        var url = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].link_to_join
        
        if(baseURL?.prefix(8) == "https://"){
                if(url.prefix(8) != "https://"){
                    url = "https://" + url
                }
            }
            else if(baseURL?.prefix(7) == "http://"){
                if (url.prefix(7) != "http://" ){
                    url = "http://" + url
                }
            }
            
        print("item type3: \(self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].type)")

          print("url url3: \(url)")
        let urlfixed = url.replacingOccurrences(of: " ", with: "%20")
        
        guard let safari = URL(string: urlfixed) else { return }
        UIApplication.shared.open(safari)
    
        
    
    }
    @objc func openDocument(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
          let index = self.blendedLearningTableView.indexPath(for: cell)
          
        var url = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].attachmentLink
        
        if(baseURL?.prefix(8) == "https://"){
                if(url.prefix(8) != "https://"){
                    url = "https://" + url
                }
            }
            else if(baseURL?.prefix(7) == "http://"){
                if (url.prefix(7) != "http://" ){
                    url = "http://" + url
                }
            }
            print("item type4: \(self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].type)")
          print("url url4: \(url)")
        let urlfixed = url.replacingOccurrences(of: " ", with: "%20")
        let alert = UIAlertController(title: "Open Attachment".localiz(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "View", style: .default, handler: { _ in
            self.viewDocument(url: urlfixed, index: index!)
        }))
        
        alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { _ in
            self.downloadDocument(url: urlfixed)
        }))
        
       
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = (sender).bounds
//                alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    
  

      }
    
    @objc func openAssignment(sender: UIButton){
        let cell = sender.superview?.superview?.superview?.superview?.superview as! UITableViewCell
        let index = self.blendedLearningTableView.indexPath(for: cell)
        
      var url = self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].attachmentLink
      
      if(baseURL?.prefix(8) == "https://"){
              if(url.prefix(8) != "https://"){
                  url = "https://" + url
              }
          }
          else if(baseURL?.prefix(7) == "http://"){
              if (url.prefix(7) != "http://" ){
                  url = "http://" + url
              }
          }
          
        print("item type1: \(self.channelList[self.channelName]![index!.section - 3].sectionDetailsList[index!.row - 1].type)")
        print("url url1: \(url)")
        let urlfixed = url.replacingOccurrences(of: " ", with: "%20")
        let alert = UIAlertController(title: "Open Attachment".localiz(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "View", style: .default, handler: { _ in
            self.viewDocument(url: urlfixed, index: index!)
        }))
        
        alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { _ in
            self.downloadDocument(url: urlfixed)
        }))
        
       
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = (sender).bounds
//                alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    

    }

    @objc func openItem(addItemGestureRecognizer: MyTapGesture){
        
        print("pathtitle: \(addItemGestureRecognizer.sectionId)")
        print("pathtitle: \(addItemGestureRecognizer.nameSection)")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "AddLearningPathViewController") as! AddLearningPathViewController
        studentVC.user = self.user
        studentVC.addType = "item"
        studentVC.delegate = self
        studentVC.pageTitle = "Add new Activity"
        studentVC.batchId = String(self.subjectList[subjectIndex].sectionId)
        studentVC.subjectId = String(self.subjectList[subjectIndex].id)
        studentVC.sectionId = addItemGestureRecognizer.sectionId
        studentVC.channelIndex = self.channelNameIndex
        studentVC.subjectName = self.subjectList[subjectIndex].sectionName
        
        studentVC.modalPresentationStyle = .overFullScreen

        self.present(studentVC, animated: true, completion: nil)
    }
    @objc func subjectSelected(subjectGestureRecognizer: UITapGestureRecognizer)
    {
        let subjectField = self.blendedLearningTableView.viewWithTag(701) as!UILabel
        let subjectImage = self.blendedLearningTableView.viewWithTag(500) as!UIImageView
        ActionSheetStringPicker.show(withTitle: "Select Subject", rows: self.subjectList.map({return $0.name}), initialSelection: 0, doneBlock: {
                   picker, ind, values in
                   
                   if self.subjectList.isEmpty{
                       subjectField.text = ""
                       return
                   }
            self.subjectIndex = ind
            subjectField.text = self.subjectList[ind].name
            
            print(self.subjectList[ind].name)
            subjectImage.image = UIImage(named: self.subjectList[ind].imperiumCode)
            print("getallchannels1: \(self.subjectList[ind].name)")
            //self.getAllChannels(user: self.user, batch_id: String(self.batchId), subject_id: String(self.subjectList[ind].id), colorList: self.colorList)
//            self.blendedLearningTableView.reloadData()
                   return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: self.view)

        //self.getSubjects(user: user, sectionId: self.batchId ?? 0)
    }
    
    @objc func tickButtonPressed(sender: UIButton){}
    @objc func viewDetails(sender: UIButton){
         let cell = sender.superview?.superview?.superview
        if let indexPath = self.blendedLearningTableView.indexPath(for: cell as! UITableViewCell) {
            
            self.actualSection = self.channelList[self.channelName]![indexPath.section - 3]
            

            if(self.channelList[self.channelName]![indexPath.section - 3].expand == false){
                self.channelList[self.channelName]![indexPath.section - 3].expand = true
                expandList[self.channelList[self.channelName]![indexPath.section - 3].id] = true
                let sections = IndexSet.init(integer: indexPath.section)
                self.blendedLearningTableView.reloadSections(sections, with: .automatic)
            }
            else{
                self.channelList[self.channelName]![indexPath.section - 3].expand = false
                expandList[self.channelList[self.channelName]![indexPath.section - 3].id] = false
                let sections = IndexSet.init(integer: indexPath.section)
                self.blendedLearningTableView.reloadSections(sections, with: .automatic)
            }
        }
        

       
        
       
        
    }
    
}

extension BlendedLearningViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        if(tableView == self.blendedLearningTableView){
//            return 3
//        }
//        else{
//            return 1
//        }
//        return self.channelSections[self.channelName]!.count + 2
       
            return  3 + self.channelList[self.channelName]!.count

        
       
       
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("sections blended: \(section)")
        if(section == 0 || section == 1 || section == 2){
            return 1
        }
        else{
            if(self.channelList[self.channelName]![section - 3].expand == true){
                return self.channelList[self.channelName]![section - 3].sectionDetailsList.count + 1
            }
            else{
                 return 1
            }
        }
//        }
//        else{
//            print("section name2: \(self.sectionName)")
//            print("section name2: \(self.sectionDetails[self.sectionName]!.count)")
//            return self.sectionDetails[self.sectionName]!.count
////            return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt\(tableView)")
        switch(tableView){
        case self.blendedLearningTableView:
            switch(indexPath.section){
            case 0:
            
                let subjectsCell = tableView.dequeueReusableCell(withIdentifier: "subjectsReuse")

                let subjectIcon = subjectsCell?.viewWithTag(500)as! UIImageView
                let subjectName = subjectsCell?.viewWithTag(701)as! UILabel
                let subjectDropDownList = subjectsCell?.viewWithTag(502)as! UIImageView

                if(self.subjectList.count > 0){
                    if(self.subjectIndex > self.subjectList.count - 1){
                        self.subjectIndex = 0
                    }
                    subjectIcon.image = UIImage(named: self.subjectList[self.subjectIndex].imperiumCode)
                    subjectName.text = self.subjectList[self.subjectIndex].name
                }
               
                let subjectGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(subjectSelected(subjectGestureRecognizer:)))
                subjectName.isUserInteractionEnabled = true
                subjectName.addGestureRecognizer(subjectGestureRecognizer)
                let subjectGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(subjectSelected(subjectGestureRecognizer:)))
                subjectDropDownList.isUserInteractionEnabled = true
                subjectDropDownList.addGestureRecognizer(subjectGestureRecognizer1)
                let subjectGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(subjectSelected(subjectGestureRecognizer:)))
                subjectIcon.isUserInteractionEnabled = true
                subjectIcon.addGestureRecognizer(subjectGestureRecognizer2)

                return subjectsCell!

            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "eventsReuse")
                let monthLabel = cell?.viewWithTag(11) as! UILabel
                let addImageView = cell?.viewWithTag(600) as! UIImageView
                let xImageView = cell?.viewWithTag(6001) as! UIImageView
                let addLabel = cell?.viewWithTag(601) as! UILabel
                let addButton = cell?.viewWithTag(602) as! UIButton
                monthLabel.isHidden = true

                addButton.addTarget(self, action: #selector(openChannel), for: .touchUpInside)

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

                    addLabel.text = "Add".localiz()
                    addImageView.image = UIImage(named: "add-school")
                    xImageView.isHidden = true


                let bottomShadowView: UIView? = cell?.viewWithTag(16)
                bottomShadowView?.dropShadow()
                let eventsCollectionView = cell?.viewWithTag(12) as! UICollectionView
                eventsCollectionView.delegate = self
                eventsCollectionView.dataSource = self
                eventsCollectionView.reloadData()
                cell?.selectionStyle = .none
                return cell!
                
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "channelNameReuse")
                let channelNameLabel = cell?.viewWithTag(456) as! UILabel
                let channelPublished = cell?.viewWithTag(457) as! UIButton
                if(self.channelsControlList.count > 0){
                    if(self.channelNameIndex > self.channelsControlList.count - 1){
                        self.channelNameIndex = 0
                    }
                    channelNameLabel.text = self.channelsControlList[self.channelNameIndex].channelName
                    if(user.userType == 2){
                        
                        channelPublished.isHidden = false
                        if(self.channelsControlList[self.channelNameIndex].channelPublished == true){
                             print("channel entered1")
                             channelPublished.setTitle("Unpublish", for: .normal)
                             channelPublished.setTitleColor(#colorLiteral(red: 0.7821028233, green: 0.1385409236, blue: 0.2157900929, alpha: 1), for: .normal)
                             

                         }
                         else {
                             print("channel entered2")
                             channelPublished.setTitle("Publish", for: .normal)
                             channelPublished.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)


                         }
                    }
                    else{
                        channelPublished.isHidden = true

                    }
                   
                
                }else{
                    print("channel entered3")
                    channelNameLabel.text = ""
                    channelPublished.setTitle("", for: .normal)

                }
                if(user.userType == 2){
                    channelPublished.addTarget(self, action: #selector(publish), for: .touchUpInside)
                }
                 
                
               
                return cell!

            default:
                if(indexPath.row == 0){
                    let cell = self.blendedLearningTableView.dequeueReusableCell(withIdentifier: "eventsDetailReuse")
                                    let dateLabel = cell?.viewWithTag(503)as!UILabel
                    dateLabel.text = self.channelList[self.channelName]![indexPath.section - 3].date

                                   
                    let titleView = cell?.viewWithTag(43) as! UIView
                    titleView.backgroundColor = App.hexStringToUIColor(hex: self.channelList[self.channelName]![indexPath.section - 3].color, alpha: 1.0)
                    print("item color: \(self.channelList[self.channelName]![indexPath.section - 3].color)")
                                    let titleLabel = cell?.viewWithTag(44) as! UILabel
                    
                                    let plusImage = cell?.viewWithTag(45) as! UIImageView
                                    let plusButton = cell?.viewWithTag(46) as! UIButton
                    titleLabel.text = self.channelList[self.channelName]![indexPath.section - 3].name
                    
                    
                    
                                    plusButton.addTarget(self, action: #selector(viewDetails), for: .touchUpInside)

                                    let topView = cell?.viewWithTag(47) as! UIView

                                    let tickView = cell?.viewWithTag(48) as! UIView
                                    let tickImage = cell?.viewWithTag(49) as! UIImageView
                                    let tickButton = cell?.viewWithTag(501) as! UIButton

                                    let bottomLineView = cell?.viewWithTag(50) as! UIView
                                

//                                    if(user.userType == 2){
                                        tickView.isHidden = true
                                        tickImage.isHidden = true
                                        tickButton.isHidden = true
                                        bottomLineView.isHidden = true
                                        topView.isHidden = true
//                                    }
//                                    else{
//                                        tickView.isHidden = false
//                                        tickImage.isHidden = false
//                                        tickButton.isHidden = false
//                                        bottomLineView.isHidden = false
//                                        topView.isHidden = false
//                                    }

                    let addButton = cell?.viewWithTag(32) as! UIImageView
                    if(user.userType == 2){
                        if(indexPath.section - 3 == self.channelList[self.channelName]!.count - 1){
                             addButton.isHidden = false
                             plusImage.isHidden = true
                             plusButton.isHidden = true
                             titleLabel.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                            let addItemGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openSection(addItemGestureRecognizer:)))
                            titleView.isUserInteractionEnabled = true
                            titleView.addGestureRecognizer(addItemGestureRecognizer)
                                               
                         }
                         else{
                             addButton.isHidden = true
                             plusImage.isHidden = false
                             plusButton.isHidden = false
                             titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                         }
                    }else{
                        titleView.isUserInteractionEnabled = false
                        plusImage.isHidden = false
                        plusButton.isHidden = false
                        addButton.isHidden = true
//                        titleLabel.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                        titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                        }
                    
                   
                    
                   
                
                    
                

                    if(self.channelList[self.channelName]![indexPath.section - 3].expand == true){
                        plusImage.image = UIImage(named: "-")
                        
                    }else{

                        plusImage.image = UIImage(named: "+")

                    }
                                   


                                    return cell!
                }
                else{
                    let cell = self.blendedLearningTableView.dequeueReusableCell(withIdentifier: "sectionDetailReuse")
                    let dateLabel = cell?.viewWithTag(40)as!UILabel
                    dateLabel.isHidden = true

                    let titleView2 = cell?.viewWithTag(908) as! UIView
//                    let titleColor = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].color
                    let titleColor = self.typeColorsMap[self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].type] ?? "#FFFFFF"
                    print("type type: \(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].type)")
                    print("title view: \(titleColor)")
                    titleView2.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 0.15)
                    let titleLabel = cell?.viewWithTag(44) as! UILabel
                    titleLabel.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                    let plusImage = cell?.viewWithTag(45) as! UIImageView
                    let plusButton = cell?.viewWithTag(46) as! UIButton
                    let startDate = cell?.viewWithTag(321) as!UILabel
                    startDate.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                    let endDate = cell?.viewWithTag(322) as!UILabel
                    endDate.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                    let duration = cell?.viewWithTag(323) as!UILabel
                    duration.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                    let bodyBackground = cell?.viewWithTag(70) as!UIStackView
                    let startButton = cell?.viewWithTag(333) as! UIButton
                    

                    
                    
                    
                    titleLabel.text = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].title
//                                    plusButton.addTarget(self, action: #selector(viewDetails), for: .touchUpInside)
                    plusButton.isHidden = true
                    plusImage.isHidden = true
                    let backgroundView = cell?.viewWithTag(41) as! UIView

                    let downloadButton = cell?.viewWithTag(71) as! UIButton
                    let sectionBody = cell?.viewWithTag(42) as! ActiveLabel
                    sectionBody.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                    sectionBody.text = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].body
                    
                    sectionBody.isUserInteractionEnabled = true
                    sectionBody.enabledTypes = [.mention, .hashtag, .url]
                    sectionBody.handleURLTap{ url in
                        var urlfixed = url.absoluteString.replacingOccurrences(of: " ", with: "%20")
                        
                        if(urlfixed.contains("https://") || urlfixed.contains("http://")){
                            guard let safari = URL(string: urlfixed) else { return }
                            UIApplication.shared.open(safari, completionHandler: { success in
                                   if success {
                                       print("opened")
                                   } else {
                                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                    App.showAlert(self, title: "ERROR".localiz(), message: "The link is invalid", actions: [ok])
                                   }
                               })
                            
                        }
                        else{
                            if(self.baseURL?.prefix(8) == "https://"){
                                if(urlfixed.prefix(8) != "https://"){
                                    urlfixed = "https://" + urlfixed
                                }
                            }
                            else if(self.baseURL?.prefix(7) == "http://"){
                                if (urlfixed.prefix(7) != "http://" ){
                                    urlfixed = "http://" + urlfixed
                                }
                            }
                            guard let safari = URL(string: urlfixed) else { return }
                            UIApplication.shared.open(safari, completionHandler: { success in
                                   if success {
                                       print("opened")
                                   } else {
                                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                                    App.showAlert(self, title: "ERROR".localiz(), message: "The link is invalid", actions: [ok])
                                   }
                               })
                        }
                        
                        
                        
                    
                    }
//                    let backgroundColor =  self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].color
                    let backgroundColor = self.typeColorsMap[self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].type] ?? "#FFFFFF"
                    backgroundView.backgroundColor = App.hexStringToUIColor(hex: backgroundColor, alpha: 0.3)
                    
                    let addButton = cell?.viewWithTag(33) as! UIImageView
                    if(self.user.userType == 2){
                        if(indexPath.row - 1 == self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList.count - 1){
                            addButton.isHidden = false
                            titleLabel.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                            downloadButton.isHidden = true
                            startButton.isHidden = true
                            let addItemGestureRecognizer = MyTapGesture(target: self, action: #selector(openItem(addItemGestureRecognizer:)))
                            addItemGestureRecognizer.sectionId = self.channelList[self.channelName]![indexPath.section - 3].id
                            addItemGestureRecognizer.nameSection = self.channelList[self.channelName]![indexPath.section - 3].name
                            titleView2.isUserInteractionEnabled = true
                            titleView2.addGestureRecognizer(addItemGestureRecognizer)
                                               
                        }
                        else{
                            addButton.isHidden = true
                            titleLabel.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                        }
                    }
                    else{
                        addButton.isHidden = true
                        titleLabel.textColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
//                        titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    }
                    
                    
                   
                    if(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].type.elementsEqual("url")){
                        startDate.isHidden = true
                        endDate.isHidden = true
                        duration.isHidden = true
                        sectionBody.isHidden = false
                        downloadButton.isHidden = true
                        startButton.isHidden = true
                        plusImage.isHidden = true
                        plusButton.isHidden = true
                        
                        
                        //backgroundView.isHidden = false
//                        let back = backgroundView.heightAnchor.constraint(equalToConstant: 20)
//                        back.isActive = true

                        plusImage.image = UIImage(named: "url_download")
                        plusImage.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                        plusImage.layer.borderWidth = 0
                        plusImage.layer.masksToBounds = false
                        plusImage.layer.cornerRadius = plusImage.frame.height/2
                        plusImage.clipsToBounds = true
                        plusImage.isHidden = true
                        plusButton.isHidden = true
                         plusButton.removeTarget(nil, action: nil, for: .allEvents)
                        plusButton.addTarget(self, action: #selector(openUrl), for: .touchUpInside)
                        titleLabel.text = "URL - " + self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].title

                    }
                     if(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].type.elementsEqual("document")){
                        startDate.isHidden = true
                        endDate.isHidden = true
                        duration.isHidden = true
//                        sectionBody.isHidden = true
                        downloadButton.isHidden = true
                        startButton.isHidden = true
                        
                        //backgroundView.isHidden = false
                        //  let back = backgroundView.heightAnchor.constraint(equalToConstant: 20)
                        //  back.isActive = true

                        plusImage.image = UIImage(named: "document_download")
                        plusImage.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                        plusImage.layer.borderWidth = 0
                        plusImage.layer.masksToBounds = false
                        plusImage.layer.cornerRadius = plusImage.frame.height/2
                        plusImage.clipsToBounds = true
                        plusImage.isHidden = false
                        plusButton.isHidden = false
                        plusButton.removeTarget(nil, action: nil, for: .allEvents)
                        plusButton.addTarget(self, action: #selector(openDocument), for: .touchUpInside)
                        titleLabel.text = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].title

                    }
                    
                     if(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].type.elementsEqual("online_exam")){
                        startDate.isHidden = false
                        endDate.isHidden = false
                        duration.isHidden = false
                        startButton.isHidden = false
                        
                        
                        let startDate1 = self.onlineExamDateFormatter.string(from: self.pickerDateFormatter1.date(from: self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].startDate) ?? Date())
                         let endDate1 = self.onlineExamDateFormatter.string(from: self.pickerDateFormatter1.date(from: self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].endDate) ?? Date())
                        
                        startDate.text = "-Starts: " + startDate1
                        endDate.text = "-Ends: " + endDate1
                        duration.text = "-Duration: " + self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].duration
//                        sectionBody.isHidden = true
                        downloadButton.isHidden = true
                        plusButton.isHidden = true
                        plusImage.isHidden = true
                        
                        //backgroundView.isHidden = false
                        //  let back = backgroundView.heightAnchor.constraint(equalToConstant: 20)
                        //  back.isActive = true

                        startButton.setImage(UIImage(named: "online_exam_download"), for: .normal)
                        startButton.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                        startButton.layer.borderWidth = 0
                        startButton.layer.masksToBounds = false
                        startButton.layer.borderColor = UIColor.black.cgColor
                        startButton.layer.cornerRadius = startButton.frame.height/2
                        startButton.clipsToBounds = true
                      startButton.removeTarget(nil, action: nil, for: .allEvents)
                        startButton.addTarget(self, action: #selector(openOnlineExam), for: .touchUpInside)
                        titleLabel.text = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].title

                    }
                    if(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].type.elementsEqual("discussion")){
                        startDate.isHidden = true
                        endDate.isHidden = true
                        duration.isHidden = true
                        sectionBody.isHidden = false
                        downloadButton.isHidden = true
                        startButton.isHidden = true
                        plusImage.isHidden = false
                        plusButton.isHidden = true
//                        sectionBody.isHidden = true
                        
                         
                        
                        
                        //backgroundView.isHidden = false
//                        let back = backgroundView.heightAnchor.constraint(equalToConstant: 20)
//                        back.isActive = true

                        plusImage.image = UIImage(named: "arrow-right")
                        plusImage.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                        plusImage.layer.borderWidth = 0
                        plusImage.layer.masksToBounds = false
                        plusImage.layer.cornerRadius = plusImage.frame.height/2
                        plusImage.clipsToBounds = true
                        plusImage.isHidden = false
                        plusButton.isHidden = false
                         plusButton.removeTarget(nil, action: nil, for: .allEvents)
                        plusButton.addTarget(self, action: #selector(openDiscussion), for: .touchUpInside)
                        titleLabel.text = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].title
                    }
                     if(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].type.elementsEqual("assignment")){
                        startDate.isHidden = true
                        endDate.isHidden = true
                        duration.isHidden = true
                        startButton.isHidden = true
                        sectionBody.isHidden = false
                        plusButton.isHidden = false
                        plusImage.isHidden = false
                        
                        plusImage.image = UIImage(named: "reply_icon")
                        plusImage.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                        plusImage.layer.borderWidth = 0
                        plusImage.layer.masksToBounds = false
                        plusImage.layer.borderColor = UIColor.black.cgColor
                        plusImage.layer.cornerRadius = startButton.frame.height/2
                        plusImage.clipsToBounds = true
                        
                        plusButton.removeTarget(nil, action: nil, for: .allEvents)
                       plusButton.addTarget(self, action: #selector(openSubmission), for: .touchUpInside)
                        
                        
                        
                        if(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].attachmentLink.isEmpty){
                             downloadButton.isHidden = true
                         }
                         else{
                             downloadButton.isHidden = false
                         }
                        downloadButton.removeTarget(nil, action: nil, for: .allEvents)
                        downloadButton.addTarget(self, action: #selector(openAssignment), for: .touchUpInside)
                        
                        
                        //backgroundView.isHidden = false
                        //  let back = backgroundView.heightAnchor.constraint(equalToConstant: 20)
                        //  back.isActive = true

                        downloadButton.setImage(UIImage(named: "assignment_download"), for: .normal)
                        downloadButton.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                        downloadButton.layer.borderWidth = 0
                        downloadButton.layer.masksToBounds = false
                        downloadButton.layer.borderColor = UIColor.black.cgColor
                        downloadButton.layer.cornerRadius = startButton.frame.height/2
                        downloadButton.clipsToBounds = true
                      
                        titleLabel.text = "Assignment - " + self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].title

                    }
                    if(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].type.elementsEqual("meeting_room")){
                        startDate.isHidden = true
                        endDate.isHidden = false
                        duration.isHidden = true
                        startButton.isHidden = false
                        
                        print("startdate1: \(startDate.isHidden)")
                        print("startdate2: \(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].startDate)")

                        endDate.text = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].body
                       
                        sectionBody.isHidden = true
                        downloadButton.isHidden = true
                        plusButton.isHidden = true
                        plusImage.isHidden = true
                        
                        //backgroundView.isHidden = false
                        //  let back = backgroundView.heightAnchor.constraint(equalToConstant: 20)
                        //  back.isActive = true

                        startButton.setImage(UIImage(named: "virtual_classroom_download"), for: .normal)
                        startButton.backgroundColor = App.hexStringToUIColor(hex: titleColor, alpha: 1.0)
                        startButton.layer.borderWidth = 0
                        startButton.layer.masksToBounds = false
                        startButton.layer.borderColor = UIColor.black.cgColor
                        startButton.layer.cornerRadius = startButton.frame.height/2
                        startButton.clipsToBounds = true
                      startButton.removeTarget(nil, action: nil, for: .allEvents)
                        startButton.addTarget(self, action: #selector(openOnlineExam), for: .touchUpInside)
                        titleLabel.text = self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].title

                    }
                    
                    
                                         
                   
                                  
                                   let tickView = cell?.viewWithTag(48) as! UIView
                                    let tickImage = cell?.viewWithTag(49) as! UIImageView
                                    let tickButton = cell?.viewWithTag(501) as! UIButton


                    let topView = cell?.viewWithTag(47) as! UIView

                    let bottomLineView = cell?.viewWithTag(50) as! UIView
                 
                                     tickView.isHidden = true
                                     tickImage.isHidden = true
                                     tickButton.isHidden = true
                                     bottomLineView.isHidden = true
                                     topView.isHidden = true
                                   

                                   


                                    return cell!
                    //                return UITableViewCell()
                }
                
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(user.userType == 2){
            if(indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2){
                    return false
                }
                else{
                
                    if indexPath.row == 0{
                        if Int(self.channelList[self.channelName]![indexPath.section - 3].userId) == user.userId{
                            if self.channelList[self.channelName]![indexPath.section - 3].id != "-1"{
                                return true
                            }
                        }
                    }
                    else{
                        if(!self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].creator.elementsEqual(String(user.userId))){
                            print("swipe swipe1")

                                return false
                            }
                           
                            else{
                                print("swipe swipe2")

                                return true
                                
                        }
                    }
//                }else{
//                    return false
//                }
           
                    
                    
                    }
        }
        else{
            return false
        }
        return false
    }
        
        
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "") { (_,_, index)  in
            
            var title = ""
            if(indexPath.row == 0){
                title = "section"
            }
            else{
                title = "activity"
            }
            
            

            
          
          let alert = UIAlertController(title: "Are you sure?".localiz(), message: "Are you sure you want to delete this \(title) ?".localiz(),         preferredStyle: UIAlertController.Style.alert)
          
          alert.addAction(UIAlertAction(title: "Cancel".localiz(), style: UIAlertAction.Style.default, handler: { _ in
              alert.dismiss(animated: true, completion: nil)
          }))
          alert.addAction(UIAlertAction(title: "OK".localiz(),style: UIAlertAction.Style.default,handler: {(_: UIAlertAction!) in
            if indexPath.row == 0{
                
                print("count count: \(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList.count)")
                print("count count: \(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList)")

                if(!self.channelList[self.channelName]![indexPath.section - 3].id.isEmpty){
                    if(!String(self.batchId).isEmpty){
                        if(!String(self.subjectList[self.subjectIndex].id).isEmpty){
                            
                            if(self.user.userType != 2 || Int(self.channelList[self.channelName]![indexPath.section - 3].userId) != self.user.userId){
                                let alert = UIAlertController(title: "Alert".localiz(), message: "you cannot delete this learning path".localiz(),         preferredStyle: UIAlertController.Style.alert)
                                                   
                                alert.addAction(UIAlertAction(title: "OK".localiz(), style: UIAlertAction.Style.default, handler: { _ in
                                    alert.dismiss(animated: true, completion: nil)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            else if(self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList.count > 1){
                                let alert = UIAlertController(title: "Alert".localiz(), message: "You cannot delete non-empty section".localiz(),         preferredStyle: UIAlertController.Style.alert)
                                                   
                                alert.addAction(UIAlertAction(title: "OK".localiz(), style: UIAlertAction.Style.default, handler: { _ in
                                    alert.dismiss(animated: true, completion: nil)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                            else{
                                self.deleteSection(user: self.user, sectionId: self.channelList[self.channelName]![indexPath.section - 3].id, batch_id: String(self.batchId), subject_id: String(self.subjectList[self.subjectIndex].id), colorList: self.colorList)
                            }
                            
                         
                        }
//                        else{
//                            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                            App.showAlert(self, title: "ERROR".localiz(), message: "Subject not found", actions: [ok])
//                        }
                        
                    }
//                    else{
//                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                        App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
//                    }
                    
                }
//                else{
//                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                    App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
//                }

               
            }
            else{
                if(!self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].id.isEmpty){
                    if(!String(self.batchId).isEmpty){
                        if(!String(self.subjectList[self.subjectIndex].id).isEmpty){
                            self.deleteItem(user: self.user, itemId: self.channelList[self.channelName]![indexPath.section - 3].sectionDetailsList[indexPath.row - 1].id, batch_id: String(self.batchId), subject_id: String(self.subjectList[self.subjectIndex].id), colorList: self.colorList)
                        }
//                        else{
//                            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                            App.showAlert(self, title: "ERROR".localiz(), message: "Subject not found", actions: [ok])
//                        }
                        
                    }
//                    else{
//                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                        App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
//                    }
                    
                }
//                else{
//                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                    App.showAlert(self, title: "ERROR".localiz(), message: "Item not found", actions: [ok])
//                }
                
            }
            
          }))
          self.present(alert, animated: true, completion: nil)
      
      }

      // here set your image and background color
      deleteAction.image = UIImage(named: "delete-x")!.scaleImage(scaledToSize: CGSize(width: 44, height: 44))
      deleteAction.backgroundColor = .white

        let editAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in
            self.editLearningPath(section: indexPath.section, row: indexPath.row)
        complete(true)
      }
        
        editAction.image = UIImage(named: "editbutton")!.scaleImage(scaledToSize: CGSize(width: 44, height: 44))
        editAction.backgroundColor = .white

      return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
        
    
}
extension BlendedLearningViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("tableview height: \(UITableView.automaticDimension)")
            return UITableView.automaticDimension
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

   
    //MARK: Custom Tableview Headers
//     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if(section == 1){
//            return "Hello"
//
//        }
//        return ""
//    }
//
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
//
//        view.tintColor = UIColor.black
//        let header = view as! UITableViewHeaderFooterView
//        if section == 0 {
//            header.textLabel?.textColor = UIColor.black
//            view.tintColor = UIColor.white
//        }
//        else {
//            view.tintColor = UIColor.groupTableViewBackground
//        }
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//
//           if(section == 1){
//              return 50
//          }
//          else{
//             return 0
//          }
//       }
}
extension BlendedLearningViewController: IndicatorInfoProvider, LearningPathViewControllerDelegate{
    func refreshBlended() {
        
        print("blended section selected:")
        //self.getAllChannels(user: self.user, batch_id: String(self.batchId), subject_id: String(self.subjectList[self.subjectIndex].id), colorList: self.colorList)
    }
    
  
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Blended Learning", counter: "", image: UIImage(named: "blendedIcon"),
                             backgroundViewColor: App.hexStringToUIColorCst(hex: "#ba9ecb", alpha: 1.0), id: App.blendedLearningId)
    }
    
}
extension BlendedLearningViewController: SectionVCToBlendedLearningDelegate{
    func updateBlendedTheme(theme: AppTheme?) {
        self.appTheme = theme
            if self.appTheme!.activeModule.contains(where: {$0.id == App.blendedLearningId && $0.status == 0}){
                App.showMessageAlert(self, title: "", message: "You do not have the required privilegs to view or interact with this module. for more details please contact your school management".localiz(), dismissAfter: 3.0)
                    self.blendedDelegate?.blendedToCalendar()
            }
        
    }
    
    func switchBlendedLearning(user: User, batchId: Int?, children: Children?) {
        print("called12")
            self.user = user
        self.selectedSubject = Subject.init(id: 0, name: "", code: "", sectionId: 0, sectionName: "", color: "", imperiumCode: "")
        print("channelNameIndex1")
        self.channelNameIndex = 0
        self.subjectIndex = 0
        
        if self.blendedLearningTableView != nil{
            switch self.user.userType{
            case 2:
                print("userusername: \(user.userName)")
                self.batchId = batchId
                getSubjects(user: user, sectionId: batchId ?? 0)
                break
                
            case 3:
                self.batchId = self.user.classes.first?.batchId ?? 0
                getStudentSubjects(user: user, sectionId: self.batchId)
                break
                
            case 4:
                
                self.child = children
                if let batch = children?.batchId{
                    self.batchId = children?.batchId
                    getStudentSubjects(user: user, sectionId: batch)
                }
                else{
                    self.batchId = self.user.classes.first?.batchId ?? 0
                    getStudentSubjects(user: user, sectionId: self.batchId)
                }
                break
                
            default:
                break
            }
        }
        
           
            SectionVC.didLoadBlended = false
    }
    
    func blendedBatchId(user: User, allClasses: [Class], batchId: Int, className: String) {
        print("called13")
        self.user = user
        self.selectedSubject = Subject.init(id: 0, name: "", code: "", sectionId: 0, sectionName: "", color: "", imperiumCode: "")
        print("channelNameIndex2")
//        self.channelNameIndex = 0
//        self.subjectIndex = 0
                
        if self.blendedLearningTableView != nil{
            switch self.user.userType{
            case 1:
                print("userusername: \(user.userName)")
                self.allClasses = allClasses
                self.batchId = batchId
                self.className = className
                self.getSubjects(user: user, sectionId: self.batchId)
                break
                
            case 2:
                print("userusername: \(user.userName)")
                self.allClasses = allClasses
                self.batchId = batchId
                self.className = className
                self.getSubjects(user: user, sectionId: self.batchId)
                break
                
            case 3:
                self.batchId = self.user.classes.first?.batchId ?? 0
                self.className = self.user.classes.first?.className ?? ""
                self.getStudentSubjects(user: user, sectionId: self.batchId)
                break
                
            case 4:
                    self.batchId = self.user.classes.first?.batchId ?? 0
                    self.className = self.user.classes.first?.className ?? ""
                    self.getStudentSubjects(user: user, sectionId: self.batchId)
                break
                
            default:
                break
            }

    }
        SectionVC.didLoadBlended = false

    }
    
    func blendedFilterSectionView(type: Int) {
        print("called14")

    }
    
    
    
    
}

// MARK: - UICollecionView functions:
extension BlendedLearningViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIDocumentInteractionControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.channelsControlList.count
    }
    
    //MARK: Collection View For Events
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventsCell", for: indexPath)
        let eventIcon = cell.viewWithTag(21) as! UIImageView
//        let counterLabel = cell.viewWithTag(22) as! UILabel
        let titleLabel = cell.viewWithTag(23) as! UILabel
        let eventColorView: UIView? = cell.viewWithTag(24)
        let tickView: UIView? = cell.viewWithTag(25)
//        let tickImageView = cell.viewWithTag(26) as! UIImageView
        eventColorView!.layer.sublayers?.forEach({if $0.accessibilityValue == "gradient" {$0.removeFromSuperlayer()}})
        eventColorView?.layer.masksToBounds = false
        titleLabel.font = UIFont(name: "OpenSans-Light", size: 11)
        cell.isUserInteractionEnabled = true
        cell.contentView.alpha = 1
        titleLabel.text = self.channelsControlList[indexPath.row].channelCode
        eventColorView?.backgroundColor = App.hexStringToUIColor(hex: self.channelsControlList[indexPath.row].channelColor, alpha: 1.0)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteCh))  //Long function will call when user long press on button.
        eventColorView?.addGestureRecognizer(longGesture)
        eventColorView?.isUserInteractionEnabled = true
      

        eventColorView?.cornerRadius = (eventColorView?.frame.width)! / 2
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.actualChannel = self.channelsControlList[indexPath.row]
        self.channelName = self.channelsControlList[indexPath.row].channelId
        self.channelNameIndex = indexPath.row
        self.blendedLearningTableView.reloadData()
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension BlendedLearningViewController{
    func getSubjects(user: User, sectionId: Int){
        if(sectionId != 0){
            let indicatorView = App.loading()
            indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            indicatorView.tag = 103
            self.view.addSubview(indicatorView)
            
            Request.shared.getTeacherSubject(user: user, sectionId: sectionId) { (message, subjectData, status) in
                if status == 200{
                    self.subjectList = subjectData!
                    print("getsubjects: \(subjectData!.count)")
                    if !self.subjectList.isEmpty{
                        self.selectedSubject = self.subjectList.first!
                            //self.getAllChannels(user: self.user, batch_id: String(self.batchId), subject_id: String(self.subjectList[self.subjectIndex].id), colorList: self.colorList)
                    }
                    else{
                        
                        self.subjectList.removeAll()
                        self.subjectList.append(Subject(id: -1, name: "", code: "", sectionId: -1, sectionName: "", color: "", imperiumCode: ""))
                        self.channelList.removeAll()
                        self.channelList[self.channelName] = []
                        self.channelsControlList.removeAll()
                        self.blendedLearningTableView.reloadData()
                    }
                    
                }
                else{
                    print("getTeacherSubject error")
    //                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
    //                App.showAlert(self, title: "ERROR2".localiz(), message: message ?? "", actions: [ok])
                }
                if let viewWithTag = self.view.viewWithTag(103){
                    print("entered3")
                    viewWithTag.removeFromSuperview()
                }
            }
        }

    }
    
    func getStudentSubjects(user: User, sectionId: Int){
        if(sectionId != 0){
            let indicatorView = App.loading()
            indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            indicatorView.tag = 102
            self.view.addSubview(indicatorView)
            
            Request.shared.getStudentSubject(user: user, sectionId: sectionId) { (message, subjectData, status) in
                if status == 200{
                    self.subjectList = subjectData!
                    print("getsubjects: \(subjectData!.count)")
                    if !self.subjectList.isEmpty{
                        self.subjectIndex = 0
                        self.selectedSubject = self.subjectList.first!
                     print("getallchannels4")
                     if(self.batchId != nil){
                         if self.subjectList.count > self.subjectIndex{
                             //self.getAllChannels(user: self.user, batch_id: String(self.batchId), subject_id: String(self.subjectList[self.subjectIndex].id), colorList: self.colorList)
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
                    
                }
                else{
                    print("getStudentSubject error")
                }
                if let viewWithTag = self.view.viewWithTag(102){
                    print("entered3")
                    viewWithTag.removeFromSuperview()
                }
            }
        }
        else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
        }
    
       }
    /// Description: Remove item
    /// - Call "delete_item" to remove a section item.
    func deleteItem(user: User, itemId: String, batch_id: String, subject_id: String, colorList: [String]){
//        let indicatorView = App.loading()
//        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
        
        Request.shared.deleteItem(user: user, itemId: itemId){ (message, studentData, status) in
            if status == 200{
                SectionVC.didLoadBlended = false
                
                //self.getAllChannels(user: user, batch_id: batch_id, subject_id: subject_id, colorList: colorList)
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
//            if let viewWithTag = self.view.viewWithTag(100){
//                print("entered3")
//                viewWithTag.removeFromSuperview()
//            }
            
        }
    }
    
    /// Description: Remove section
    /// - Call "delete_item" to remove a section .
    func deleteSection(user: User, sectionId: String, batch_id: String, subject_id: String, colorList: [String]){
//        let indicatorView = App.loading()
//        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
        Request.shared.deleteSection(user: user, sectionId: sectionId){ (message, studentData, status) in
            if status == 200{
                SectionVC.didLoadBlended = false
                //self.getAllChannels(user: user, batch_id: batch_id, subject_id: subject_id, colorList: colorList)
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
//            if let viewWithTag = self.view.viewWithTag(100){
//                print("entered3")
//                viewWithTag.removeFromSuperview()
//            }
        }
    }
    
    /// Description: Remove channel
      /// - Call "delete_item" to remove a channel.
      func deleteChannel(user: User, channelId: String, batch_id: String, subject_id: String, colorList: [String]){
//        let indicatorView = App.loading()
//        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
        Request.shared.deleteChannel(user: user, channelId: channelId){ (message, studentData, status) in
              if status == 200{
                  SectionVC.didLoadBlended = false
                  //self.getAllChannels(user: user, batch_id: batch_id, subject_id: subject_id, colorList: colorList)
              }
              else{
                  let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                  App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
              }
//            if let viewWithTag = self.view.viewWithTag(100){
//                print("entered3")
//                viewWithTag.removeFromSuperview()
//            }
          }
      }
    
    /// Description: publish item
    /// - Call "publish_item" to publish/unpublish learning channel.
    func publishChannel(user: User, channelId: String, batch_id: String, subject_id: String, colorList: [String]){
//        let indicatorView = App.loading()
//        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
        Request.shared.publishChannel(user: user, channelId: channelId){ (message, studentData, status) in
            if status == 200{
               
                    //self.getAllChannels(user: user, batch_id: batch_id, subject_id: subject_id, colorList: colorList)
                
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
//            if let viewWithTag = self.view.viewWithTag(100){
//                print("entered3")
//                viewWithTag.removeFromSuperview()
//            }
        }
    }
    
    func getAllChannels(user: User, batch_id: String, subject_id: String, colorList: [String]){
        if(!batch_id.isEmpty){
            if(!subject_id.isEmpty){
                    let indicatorView = App.loading()
                    indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                    indicatorView.tag = 101
                    self.view.addSubview(indicatorView)
                
                
                Request.shared.getAllChannels(user: user, batch_id: batch_id, subject_id: subject_id, colorList: colorList, expandList: self.expandList){
                    (message, result,additionalResult, status) in
                    if status == 200{
                        self.channelList = result!
                        print("count: \(self.channelList.count)")
                        print("count: \(additionalResult.count)")
                        self.channelsControlList = additionalResult
                        if(self.channelsControlList.count == 0){
                            self.channelName = ""
                        }
                        else{
//                            self.channelNameIndex = 0
                           
                            
                            if(self.channelsControlList.count > self.channelNameIndex){
                                self.channelName = self.channelsControlList[self.channelNameIndex].channelId
                            }
                            else{
                                self.channelName = self.channelsControlList[0].channelId

                            }

                        }
                        
                        print("channelid: \(self.channelName)")
                        
                        self.channelsCodes.removeAll()
                        for channel in self.channelsControlList{
                            self.channelsCodes.append(channel.channelCode)
                        }
                        if(self.blendedLearningTableView.viewWithTag(12) != nil){
                            let eventsCollectionView = self.blendedLearningTableView.viewWithTag(12) as! UICollectionView
                            eventsCollectionView.reloadData()
                        }
                        
                       
                        self.blendedLearningTableView.reloadData()
                    }
                    else{
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                        App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                        }
                    if let viewWithTag = self.view.viewWithTag(101){
                        print("entered3")
                        viewWithTag.removeFromSuperview()
                    }
                    }
                
                
            }
//            else{
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR".localiz(), message: "Subject not found", actions: [ok])
//            }
            
        }
//        else{
//            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//            App.showAlert(self, title: "ERROR".localiz(), message: "Section not found", actions: [ok])
//        }
        
    }
    
    //augmental
    
    func getSchool(){
        
        if !self.refreshControl.isRefreshing {
            self.view.superview?.superview?.insertSubview(self.loadingBlending, at: 1)
        }

        Request.shared.getSchool(user: self.user) { (message, userData, status) in
            if status == 200{
            
                if(message == "Successfully found school") {
                    let accountCode = userData?["accountCode"].stringValue
                    let schoolLink = userData?["schoolLink"].stringValue
                    
                    self.isUserFound(accountCode: accountCode!, schoolLink: schoolLink!)
                }
                
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    func isUserFound(accountCode: String, schoolLink: String){

        Request.shared.isUserFound(user: self.user) { (message, userData, status) in
            if status == 200{
                                                
                if(message == "No user found"){
                    
                    self.augmentalSignUp(accountCode: accountCode, schoolLink: schoolLink)
                    
                } else if (message == "Successfully found user") {
                    
                    let accountCode = userData?["accountCode"].stringValue
                    let userCode = userData?["userCode"].stringValue
                    
                    self.enrollUser(accountCode: accountCode!, userCode: userCode!)
                }
                
                
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    func augmentalSignUp(accountCode: String, schoolLink: String){

        Request.shared.augmentalSignUp(user: self.user, accountCode: accountCode, schoolLink: schoolLink) { (message, userData, status) in
            if status == 200{
                
                if ((userData?["message"].stringValue.contains("Email already exists")) != nil) {
                    self.getSchool()
                } else {
                    let userCode = userData?["code"].stringValue
                    self.registerUser(accountCode: accountCode, userCode: userCode!, schoolLink: schoolLink)
                }
                
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    func registerUser(accountCode: String, userCode: String, schoolLink: String){

        Request.shared.registerUser(user: self.user, accountCode: accountCode, userCode: userCode, schoolLink: schoolLink) { (message, userData, status) in
            if status == 200{
                
                if(message == "Successfully create user") {
                    let accountCode = userData?["accountCode"].stringValue
                    let userCode = userData?["userCode"].stringValue
                    
                    self.enrollUser(accountCode: accountCode!, userCode: userCode!)
                }
                
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    func enrollUser(accountCode: String, userCode: String){
        
        var firstPart: String?
        var secondPart: String?
        
        
        if user.userType == 1 || user.userType == 2 {
            let dispatchGroup = DispatchGroup()
            var counter = 0
            var returned_userCode = ""

            for classItem in self.allClasses {
                let className = classItem.className.components(separatedBy: "-")
                if className.count == 2 {
                    let firstPart = className[0].replacingOccurrences(of: " ", with: "")
                    let secondPart = className[1].replacingOccurrences(of: " ", with: "")

                    dispatchGroup.enter() // Enter the group before starting each request

                    Request.shared.enrollUser(user: self.user, accountCode: accountCode, userCode: userCode, className: classItem.imperiumCode, classCode: secondPart) { (message, userData, userCode, status) in
                        if status == 200 {
                            if message == "Enrolled" {
                                counter += 1
                                returned_userCode = userCode!
                            }
                        } else {
                            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                            App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                        }

                        dispatchGroup.leave() // Leave the group when the request is complete
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {

                if counter == self.allClasses.count {
                    self.loginUser(userCode: returned_userCode)
                } else {
                    if !self.refreshControl.isRefreshing {
                        self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
                    }
                    self.refreshControl.endRefreshing()
                }
            }
        } else if(user.userType == 3){
            let className = self.user.classes.first?.className.components(separatedBy: "-")
            if className?.count == 2 {
                firstPart = className?[0]
                secondPart = className?[1]
            }
            
            Request.shared.enrollUser(user: self.user, accountCode: accountCode, userCode: userCode, className: firstPart ?? "", classCode: secondPart ?? "") { (message, userData, userCode, status) in
                if status == 200{
                    
                    if(message == "Enrolled"){
                        self.loginUser(userCode: userCode!)
                    } else{
                        if !self.refreshControl.isRefreshing {
                            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
                        }
                        self.refreshControl.endRefreshing()
                    }
                    
                }else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                }
            }
        }
    }
    
    func loginUser(userCode: String){

        Request.shared.loginUser(userCode: userCode) { (message, htmlString, status) in
            if status == 200{
                
                let tempHtmlFileURL = self.saveHTMLContentToTempFile(htmlContent: htmlString!)
                        
                        if let url = tempHtmlFileURL {
                            self.documentInteractionController = UIDocumentInteractionController(url: url)
                            self.documentInteractionController.delegate = self
                            self.documentInteractionController.presentPreview(animated: true)
                        }
                
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if !self.refreshControl.isRefreshing {
                self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            }
            self.refreshControl.endRefreshing()
        }
        
    }
    
    func saveHTMLContentToTempFile(htmlContent: String) -> URL? {
        do {
            let tempDir = FileManager.default.temporaryDirectory
            let tempHtmlFileURL = tempDir.appendingPathComponent("BlendedLearning.html")
            
            try htmlContent.write(to: tempHtmlFileURL, atomically: true, encoding: .utf8)
            
            return tempHtmlFileURL
        } catch {
            print("Error writing HTML content to file: \(error.localizedDescription)")
            return nil
        }
    }
        
    // UIDocumentInteractionControllerDelegate method to handle the preview view controller dismissal
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
}

class MyTapGesture: UITapGestureRecognizer {
    var sectionId = ""
    var nameSection = ""
}

