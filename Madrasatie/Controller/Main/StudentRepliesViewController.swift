//
//  StudentRepliesViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 8/6/20.
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
import SwiftyJSON


class StudentRepliesViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate{
    @IBOutlet weak var studentsTitle: UILabel!
//    @IBOutlet weak var addAnswerTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitAnswer: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var currentRecording: UIView!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var rTimer: UILabel!
    
    @IBOutlet weak var finalRecording: UIView!
    @IBOutlet weak var finalRecordingLabel: UILabel!
    @IBOutlet weak var recordTime: UILabel!
    @IBOutlet weak var deleteRecord: UIButton!
    @IBOutlet weak var recordButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var recordButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var recordingLayoutHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var assignmentTitle: UITextField!
    @IBOutlet weak var assignmentDescription: UITextView!
    @IBOutlet weak var assignmentDueDate: UITextField!
    @IBOutlet weak var assignmentEstimatedTime: UITextField!
//    @IBOutlet weak var searchSubmissions: UISearchBar!
    @IBOutlet weak var submissionsTableView: UITableView!
    @IBOutlet weak var addSubmission: UIButton!
    
    @IBOutlet weak var submissionForm: UIView!
    
    @IBOutlet weak var xmark: UIImageView!
    @IBOutlet weak var actualTime: UITextField!
    @IBOutlet weak var addPicture: UIImageView!
    @IBOutlet weak var studentAnswer: UITextView!
    @IBOutlet weak var addText: UITextField!
    
//    var searchText = ""
    var compressedDataToPass: NSData!
    var croppingStyle = CropViewCroppingStyle.default
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    var recordTimer = Timer()
    var voiceRecorder: AVAudioRecorder!
    var count: Int = 0

    var asst: AgendaDetail?
    var studentsList: [StudentRepliesModel] = []
    var uniqueStudentsList: [StudentRepliesModel] = []
    var filteredList: [StudentRepliesModel] = []

    var color: String = ""
    var discussionMessages: [FeedbackModel] = []
    var user: User!
    var assignmentId: String = ""
    var batchId: String = ""
    var expandList: [Bool] = []
    var answersColors: [String] = ["#ef4a7b","#337ba8","#33a567","#9ba439","#923e97","#a57732","#a64234","#a43463","#769e3f","#99573e","#3e998c"]
    
    var discussionColors: [String] = ["#fcdee6","#dae7f0","#daeee3","#edefda","#eadcec","#eee6da","#f0ddda","#f0dae3","#e6eddb","#ede1db","#dcece9"]
    
    var imagePicker = UIImagePickerController()
    var pdfURL : URL!
    var selectedImage : UIImage = UIImage()
    var isFileSelected = false
    var isSelectedImage = false
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")
    var isFirstEntered: Bool = false
    var openAttach: Bool = false
    var filename: String = "SLink"
    var messageText: String = ""
    var fName: String = "SLink"
    //    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var check: Int = 0
    var isAccepted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submissionsTableView.delegate = self
        submissionsTableView.dataSource = self
      
        if(self.user.userType == 1 || self.user.userType == 2){
            addSubmission.isHidden = true
        }
        else{
            addSubmission.isHidden = false
        }
        
//        if(self.user.userType != 1 && self.user.userType != 2){
//            self.searchSubmissions.isHidden = true
//            self.searchSubmissions.heightAnchor.constraint(equalToConstant: CGFloat(0)).isActive = true

//        }
//        self.searchSubmissions.delegate = self
        
        self.addSubmission.layer.masksToBounds = true
        self.addSubmission.layer.cornerRadius = 30
        self.addSubmission.frame = CGRect(
            x: view.frame.size.width - 60 - 8,
            y: view.frame.size.height - 60 - 8 - view.safeAreaInsets.bottom,
            width: 60,
            height: 60
            
        )
       
        
//        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeForm))
//        xmark.addGestureRecognizer(gestureRecognizer)

//
//        //        addAnswerTableView.dataSource = self
//        //        addAnswerTableView.delegate = self
//        messageTextField.delegate = self
//        messageTextField.inputAccessoryView = UIView()
//
//        //
//
        imagePicker.delegate = self
//        submissionsTableView.backgroundColor = UIColor(patternImage: UIImage(named: "submission_background")!)
//
        print("agenda agenda: \(self.asst)")
        
        
        self.assignmentTitle.text = self.asst?.title
        self.assignmentDescription.text = self.asst?.description
            
        let attributedString1 = NSMutableAttributedString(string: "Estimated Time: \(self.asst!.estimatedTime) mins")
            // Define the range for the bold text
            let boldRange1 = NSRange(location: 0, length: 15)
            // Apply bold font to the selected range
            let boldFont1 = UIFont.boldSystemFont(ofSize: 14)
            attributedString1.addAttribute(.font, value: boldFont1, range: boldRange1)
            
            self.assignmentEstimatedTime.attributedText = attributedString1
            self.assignmentEstimatedTime.textAlignment = .left
            self.assignmentEstimatedTime.contentVerticalAlignment = .center
            
            self.assignmentTitle.borderStyle = .none
            self.assignmentDueDate.borderStyle = .none
            self.assignmentEstimatedTime.borderStyle = .none

            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
        let date = formatter.date(from: self.asst?.date ?? "") ?? Date()
            
            let dueDateFormatter = DateFormatter()
            dueDateFormatter.dateFormat = "dd-MMM"
            let finalDate = dueDateFormatter.string(from: date)
            
            let attributedString = NSMutableAttributedString(string: "Due Date: \(finalDate)")
            // Define the range for the bold text
            let boldRange = NSRange(location: 0, length: 9)
            // Apply bold font to the selected range
            let boldFont = UIFont.boldSystemFont(ofSize: 14)
            attributedString.addAttribute(.font, value: boldFont, range: boldRange)
            
            self.assignmentDueDate.attributedText = attributedString
            self.assignmentDueDate.textAlignment = .left
            self.assignmentDueDate.contentVerticalAlignment = .center
        
        
        if(self.user.userType == 1 || self.user.userType == 2){
            self.teacherDiscussions(user: user, senderId: String(user.userId), sectionId: self.batchId, assignmentId: self.assignmentId, isFirstEntered: self.isFirstEntered, expandList: self.expandList)
        }
        else{
            self.getStudentAnswers(user: self.user, senderId: self.asst?.students ?? "0")
        }
 
//
//        self.sendView.isHidden = true
//
//
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//
//
//        self.recordingLayoutHeight.constant = 0
//        setUpRecorder()
        
        
    }
 
    
    
    @IBAction func closeForm(_ sender: UIButton) {
        print("pressed pressed")
        self.submissionForm.isHidden = true
    }
    
    @IBAction func atachButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Upload picture".localiz(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take photo".localiz(), style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from library".localiz(), style: .default, handler: { _ in
            self.openGallary()
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
    /// - Show alert with option to take picture or upload one from phone gallery.
   
    
    
    
    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @objc override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.isFileSelected = true
        self.pdfURL = recorder.url
        
        
    }
    func recordAudio(_ sender: Any){
        
    }
    
    func sortStudent(studentList: [StudentRepliesModel]) -> [StudentRepliesModel]{
        var black: [StudentRepliesModel] = [];
        var green: [StudentRepliesModel] = [];
        var red: [StudentRepliesModel] = [];
        var blue: [StudentRepliesModel] = [];
        
        print("list list1: \(studentList)")
        for student in studentList{
          
            if(student.orderColor == "blue"){
                blue.append(student);
            }
            else if(student.orderColor == "green"){
                green.append(student)
            }
            else if(student.orderColor == "red"){
                red.append(student)
            }
            else{
                black.append(student)

            }
        }
        let finalOrdering = black + blue + green + red;
        print("list list2: \(finalOrdering)")

        
        return finalOrdering
    }
    func setUpRecorder(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
        } catch let error as NSError {
            print(error.description)
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let current = formatter.string(from: date)
        self.fName = "recording\(current).m4a"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fName)
        print("audio url: \(audioFilename)")
        let recordSetting = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                              AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey: 320000,
                              AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100.2] as [String : Any]
        
        do{
            voiceRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting)
            voiceRecorder.delegate = self
            voiceRecorder.prepareToRecord()
            
        }
        catch{
            print(error)
        }
        
    }
    
    fileprivate lazy var attachmentPickertime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        //        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var submissionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "- dd MMM | HH:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy HH:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
  
    
    @IBAction func closeController(_ sender: UIButton) {
        self.dismiss(animated: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(user.userType == 1 || user.userType == 2){
            self.teacherDiscussions(user: user, senderId: String(user.userId), sectionId: self.batchId, assignmentId: self.assignmentId, isFirstEntered: self.isFirstEntered, expandList: expandList)
        } else {
            self.getStudentAnswers(user: self.user, senderId: self.asst?.students ?? "0")
        }
        
    }
    
    @IBAction func saveStudentAnswer(_ sender: UIButton) {
        
        let message = self.studentAnswer.text
        let actualTime = self.actualTime.text
        
        if(message!.isEmpty && self.isSelectedImage == false && self.isFileSelected == false){
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "ERROR".localiz(), message: "We can't submit empty reply", actions: [ok])
        }
        else if(actualTime!.isEmpty && self.isSelectedImage == false && self.isFileSelected == false){
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "ERROR".localiz(), message: "Please add actual Time", actions: [ok])
        }
        else if(self.isSelectedImage == false && self.isFileSelected == false){
            self.submitStudentAnswers(user: user, assignmentId: assignmentId, message: message!, actualTime: actualTime!)
        }
        else {
            self.submitStudentAnswersWithAttachment(user: user, assignmentId: assignmentId, message: message!, actualTime: actualTime!)
            
        }
        
    }
    
    @objc func acceptFeedback(sender: UIButton){
        if sender.tag == 70 {
            let cell = sender.superview?.superview?.superview?.superview as! UITableViewCell
            let index = self.submissionsTableView.indexPath(for: cell)
            let assignmentAnswerId = self.uniqueStudentsList[index!.section].id
            
            check = 1
            
            acceptOrDeclineAnswers(check: check, id: assignmentAnswerId, index: index!.section)
            
            UIView.animate(withDuration: 1.5) {
                print("acceptTapped, baseURL: \(self.baseURL), answerId: \(assignmentAnswerId), check is: \(self.check)")
                self.view.viewWithTag(70)!.alpha = 1
                self.view.viewWithTag(71)!.alpha = 0.2
            }
        }
    }
    
    @objc func onClickOpenDiscussions(sender: UIButton){
        var recipients: [Int] = []
        if(self.user.userType == 1 || self.user.userType == 2){
            
            let cell = sender.superview?.superview?.superview as! UITableViewCell
            let index = self.submissionsTableView.indexPath(for: cell)
            let userId = self.filteredList[index!.section].userId
            print("userIdddd: \(userId)")
            recipients.append(self.user.userId)
            recipients.append(userId)
        }
        else if(self.user.userType == 3){
            recipients.append(self.user.userId)
            recipients.append(Int(self.asst?.teacher ?? "0") ?? 0)
        }
        else if(self.user.userType == 4){
            recipients.append(Int(self.user.admissionNo) ?? 0)
            recipients.append(Int(self.asst?.teacher ?? "0") ?? 0)
        }
        self.createDiscussionAgenda(user: self.user, title: self.self.asst?.title ?? "", assignmentId: Int(self.assignmentId) ?? 0, recipients: recipients)
    }

    
    @objc func cancelFeedback(sender: UIButton){
        if sender.tag == 71 {
            let cell = sender.superview?.superview?.superview?.superview as! UITableViewCell
            let index = self.submissionsTableView.indexPath(for: cell)
            let assignmentAnswerId = self.uniqueStudentsList[index!.section].id
            
            check = 0
            
            acceptOrDeclineAnswers(check: check, id: assignmentAnswerId, index: index!.section)
            
            UIView.animate(withDuration: 1.5) {
                print("cancelTapped, baseURL: \(self.baseURL), answerId: \(assignmentAnswerId), check is: \(self.check)")
                self.view.viewWithTag(70)!.alpha = 0.2
                self.view.viewWithTag(71)!.alpha = 1
            }
        }
    }
    
    @objc func downloadAttachment(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        let index = self.submissionsTableView.indexPath(for: cell)
        var url = self.uniqueStudentsList[index!.section].attachmentLink
        
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
        
        print("url url1: \(url)")
//        let urlfixed = url.replacingOccurrences(of: " ", with: "%20")
        guard let safari = URL(string: url) else { return }
        UIApplication.shared.open(safari)
        
    }
    
    @IBAction func addAttachmentButton(_ sender: Any) {
        self.addAttachment(sender: sender as! UIButton)
    }
    
    
    @IBAction func addSubmissionButton(_ sender: UIButton) {
        print("pressed pressed")
        self.submissionForm.isHidden = false
    }
    

    @IBAction func closeViewController(_ sender: UIButton) {
        self.dismiss(animated: true)

    }
    @IBAction func submitStudentAnswerButton(_ sender: Any) {
        
//        let message = self.messageTextField.text
//
//
//        if(message!.isEmpty && self.isSelectedImage == false && self.isFileSelected == false){
//            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//            App.showAlert(self, title: "ERROR".localiz(), message: "We can't submit empty reply", actions: [ok])
//        }
//        else if(self.isSelectedImage == false && self.isFileSelected == false){
//            self.submitStudentAnswers(user: user, assignmentId: assignmentId, message: message!)
//        }
//        else {
//            self.submitStudentAnswersWithAttachment(user: user, assignmentId: assignmentId, message: message!, )
//
//        }
    }
    @objc func downloadDiscussionAttachment(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        let index = self.submissionsTableView.indexPath(for: cell)
        var url = self.uniqueStudentsList[index!.section].feedbackList[index!.row - 1].attachmentLink
        
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
        
        print("url url1: \(url)")
        print("section attachment: \(index!.section)")
        print("row attachment: \(index!.row)")
//        let urlfixed = url.replacingOccurrences(of: " ", with: "%20")
        guard let safari = URL(string: url) else { return }
        UIApplication.shared.open(safari)
        
    }
    @objc func addAttachment(sender: UIButton){
        //function to attach a file to the document
        self.openAttach = true
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
        //                alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
        
    }
    @objc func sendDiscussion(sender: UIButton){
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        let index = self.submissionsTableView.indexPath(for: cell)
        
        let message = cell.viewWithTag(101) as!UITextView
        
        self.expandList.removeAll()
        for exp in self.uniqueStudentsList{
            self.expandList.append(exp.expand)
        }
        for value in self.expandList{
            print("value value: \(value)")
        }
        if(message.text.isEmpty && self.isSelectedImage == false && self.isFileSelected == false){
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "ERROR".localiz(), message: "We can't submit empty reply", actions: [ok])
        }
        else if(self.isSelectedImage == false && self.isFileSelected == false){
            print("message typed: \(self.messageText)")
            if(self.user.userType == 1 || self.user.userType == 2){
                self.addDiscussion(user: user, assignmentAnswerId: self.uniqueStudentsList[index!.section].id, receiverId: self.uniqueStudentsList[index!.section].studentId, message: message.text, expandList: self.expandList, index: index!.section)
            }
            else{
                print("index section: \(index!.section)")
                self.addDiscussion(user: user, assignmentAnswerId: self.uniqueStudentsList[index!.section].id, receiverId: self.uniqueStudentsList[index!.section].teacherId, message: message.text, expandList: self.expandList,index: index!.section)
            }
            
        }
        else {
            if(self.user.userType == 1 || self.user.userType == 2){
                self.addDiscussionWithAttachment(user: user, assignmentAnswerId: self.uniqueStudentsList[index!.section].id, receiverId: self.uniqueStudentsList[index!.section].studentId, message: message.text, expandList: self.expandList)
            }
            else{
                print("index section: \(index!.section)")
                self.addDiscussionWithAttachment(user: user, assignmentAnswerId: self.uniqueStudentsList[index!.section].id, receiverId: self.uniqueStudentsList[index!.section].teacherId, message: message.text, expandList: self.expandList)
            }
            
        }
        
        
        
        
    }
    
    @objc func submitAssignmentAnswer(sender: UIButton){
//        let cell = sender.superview?.superview?.superview as! UITableViewCell
//        let index = self.submissionsTableView.indexPath(for: cell)
//        let messageTextView = self.submissionsTableView.viewWithTag(101) as! UITextView
//        let message = messageTextView.text
//
//        if(message!.isEmpty && self.isSelectedImage == false && self.isFileSelected == false){
//            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//            App.showAlert(self, title: "ERROR".localiz(), message: "We can't submit empty reply", actions: [ok])
//        }
//        else if(self.isSelectedImage == false && self.isFileSelected == false){
//            self.submitStudentAnswers(user: user, assignmentId: assignmentId, message: message!)
//        }
//        else {
//            self.submitStudentAnswersWithAttachment(user: user, assignmentId: assignmentId, message: message!)
//
//        }
    }
    
    @IBAction func startRecording1(_ sender: UIButton) {
        print("start recording")
        currentRecording.isHidden = false
        recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter1), userInfo: nil, repeats: true)
        self.count = 0
        self.rTimer.text = self.makeTimeString(minutes: 0, seconds: 0)
        finalRecording.isHidden = true
        self.recordingLayoutHeight.constant = 0
        messageTextField.isHidden = true
        addPicture.isHidden = true
        submitAnswer.isHidden = true
        recordButton.isHidden = false
        recordButtonWidth.constant = 24
        recordButtonHeight.constant = 32
        voiceRecorder.record()

    }
    
    @IBAction func endRecording1(_ sender: UIButton) {
        print("end recording")

        finalRecording.isHidden = false
        self.recordingLayoutHeight.constant = 30
        currentRecording.isHidden = true
        self.recordTimer.invalidate()
        messageTextField.isHidden = false
        addPicture.isHidden = true
        submitAnswer.isHidden = false
        recordButton.isHidden = true
        recordButtonWidth.constant = 0
        recordButtonHeight.constant = 0
        messageTextField.text = "Voice Note"
        messageTextField.isEditable = false
        voiceRecorder.stop()
    }
    
    @IBAction func deleteRecord1(_ sender: UIButton) {
        self.count = 0
        if(messageTextField.text.isEmpty){
            submitAnswer.isHidden = true
            recordButton.isHidden = false
            recordButtonWidth.constant = 24
            recordButtonHeight.constant = 32
        }
        self.recordTimer.invalidate()
        self.rTimer.text = self.makeTimeString(minutes: 0, seconds: 0)
        self.finalRecording.isHidden = true
        self.recordingLayoutHeight.constant = 0
        addPicture.isHidden = false
        self.isFileSelected = false
        messageTextField.text = ""
        messageTextField.isEditable = false


        voiceRecorder.deleteRecording()
    }
    
    @objc func endRecording(_ sender: UIButton) {
        
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        
        let finalRecording = cell.viewWithTag(430) as! UIView
        finalRecording.isHidden = false
        finalRecording.frame = CGRect(x: 0, y: 0, width: finalRecording.frame.width, height: finalRecording.frame.height + 30.0)

        
        let currentRecording = cell.viewWithTag(530) as! UIView
        finalRecording.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
        currentRecording.isHidden = true
        
        let sendB = cell.viewWithTag(103) as! UIButton
        let recordB = cell.viewWithTag(113) as! UIButton
        
        sendB.isHidden = false
        recordB.isHidden = true
        self.recordTimer.invalidate()
//        messageTextView.isHidden = false
        addPicture.isHidden = true
        voiceRecorder.stop()
        
        
    }
    @objc func startRecording(_ sender: UIButton) {
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        let currentRecording = cell.viewWithTag(530) as! UIView
        currentRecording.isHidden = false
        
        recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        self.count = 0
        
        let rTimer = cell.viewWithTag(533) as! UILabel
        rTimer.text = self.makeTimeString(minutes: 0, seconds: 0)
        
        let finalRecording = cell.viewWithTag(430) as! UIView
        finalRecording.isHidden = true
        finalRecording.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
        
//        messageTextView.isHidden = true
        addPicture.isHidden = true
//        sendButton.isHidden = true
        voiceRecorder.record()
    }
    
    @objc func timerCounter(){
        count = count + 1
        let time = secondsToMinuteSeconds(seconds: count)
        let timeString = makeTimeString(minutes: time.0, seconds: time.1)
        let rTime = self.submissionsTableView.viewWithTag(533) as! UILabel
        let recordT = self.submissionsTableView.viewWithTag(433) as! UILabel
        rTime.text = timeString
        recordT.text = timeString
//        return timeString
    }
    @objc func timerCounter1(){
        count = count + 1
        let time = secondsToMinuteSeconds(seconds: count)
        let timeString = makeTimeString(minutes: time.0, seconds: time.1)
        rTimer.text = timeString
        recordTime.text = timeString
    }
    
    func secondsToMinuteSeconds(seconds: Int) -> (Int, Int){
        return (((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    @objc func deleteRecording(_ sender: UIButton) {
//        self.count = 0
        self.recordTimer.invalidate()
        
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        let rTimer = cell.viewWithTag(533) as! UILabel
        rTimer.text = self.makeTimeString(minutes: 0, seconds: 0)
        
        let finalRecording = cell.viewWithTag(430) as! UIView
        finalRecording.isHidden = true
        
        let sendB = cell.viewWithTag(103) as! UIButton
        let recordB = cell.viewWithTag(113) as! UIButton
        
        sendB.isHidden = true
        recordB.isHidden = false
        
//        self.recordingLayoutHeight.constant = 0
        addPicture.isHidden = false
        self.isFileSelected = false
        voiceRecorder.deleteRecording()
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
    
    func makeTimeString(minutes: Int, seconds: Int) -> String{
        var time = ""
        if(seconds < 10){
            time += String(format: "0%2d", minutes)
            time += " : "
            time += String(format: "0%2d", seconds)
        }
        else{
            time += String(format: "0%2d", minutes)
            time += " : "
            time += String(format: "%2d", seconds)
        }
        
        return time
    }
    
    @objc func titlePressed(sender: UIButton){
        let cell = sender.superview?.superview?.superview?.superview as! UITableViewCell
        let indexPath = self.submissionsTableView.indexPath(for: cell)
        
        if(self.uniqueStudentsList[indexPath!.section].expand){
            self.uniqueStudentsList[indexPath!.section].expand = false
        }
        else{
            self.uniqueStudentsList[indexPath!.section].expand = true
        }
        self.submissionsTableView.reloadData()
    }
    
    private func attachDocument() {
        //        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet, kUTTypePNG, kUTTypeJPEG, kUTTypeGIF, "com.microsoft.word.doc" as CFString, "org.openxmlformats.wordprocessingml.document" as CFString, "org.openxmlformats.presentationml.presentation" as CFString, kUTTypeMovie, kUTTypeAudio, kUTTypeVideo, kUTTypeGIF, kUTTypeText]
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
        self.isFileSelected = true
        self.isSelectedImage = false
        
        filename = self.pdfURL.lastPathComponent
        
        print("filename: \(filename)")
        
        
        let filetype = self.pdfURL.description.suffix(4).lowercased()
        if filetype == ".pdf"{
            self.addPicture.image = UIImage(named: "pdf_logo")
        }else if filetype == "docx"{
            self.addPicture.image = UIImage(named: "word_logo")
        }else if filetype == "xlsx"{
            self.addPicture.image = UIImage(named: "excel_logo")
        }
        else if filetype == "pptx" || filetype == "ppsx" || filetype == "ppt"{
            addPicture.image = UIImage(named: "powerpoint")
        }
        else if filetype == ".m4a" || filetype == "flac" || filetype == ".mp3" || filetype == ".mp4" || filetype == ".wav"
                    || filetype == ".wma" || filetype == ".aac"{
            addPicture.image = UIImage(named: "audio")
        }
        
        else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
            addPicture.image = UIImage(named: "video")
            
        }
        else{
            self.addPicture.image = UIImage(named: "doc_logo")
        }
        
        self.submissionsTableView.reloadData()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
           
    }

// MARK: - Select Picture:
extension StudentRepliesViewController: UIImagePickerControllerDelegate, CropViewControllerDelegate{
    
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
        //            self.isFileSelected = false
        
        self.selectedImage = image
        self.isSelectedImage = true
        self.isFileSelected = false
        self.addPicture.image = image
        self.addPicture.image = image
        //        self.isSelectedImage = true
        //        let imageView = calendarTableView.viewWithTag(721) as! UIImageView
        //        imageView.image = selectedImage
            layoutImageView()
            
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            
            if cropViewController.croppingStyle != .circular {
                self.addPicture.isHidden = true
                
                cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                       toView: self.addPicture,
                                                       toFrame: CGRect.zero,
                                                       setup: { self.layoutImageView() },
                                                       completion: {
                                                        self.addPicture.isHidden = false })
            }
            else {
                addPicture.isHidden = false
                cropViewController.dismiss(animated: true, completion: nil)
                
            }
        }
    
    public func layoutImageView() {
//        let imageView = submissionsTableView.viewWithTag(721) as! UIImageView
        guard self.addPicture.image != nil else { return }
            
            let padding: CGFloat = 20.0
            
            var viewFrame = self.view.bounds
            viewFrame.size.width -= (padding * 2.0)
            viewFrame.size.height -= ((padding * 2.0))
            
            var imageFrame = CGRect.zero
            imageFrame.size = self.addPicture.image!.size;
            
            if self.addPicture.image!.size.width > viewFrame.size.width || self.addPicture.image!.size.height > viewFrame.size.height {
                let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
                imageFrame.size.width *= scale
                imageFrame.size.height *= scale
                imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
                imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
                self.addPicture.frame = imageFrame
            }
            else {
                self.addPicture.frame = imageFrame;
                self.addPicture.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            }
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true , completion: nil )
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        if(info[UIImagePickerController.InfoKey.mediaType] as! CFString == kUTTypeImage){
            guard let selectedImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
            
            let cropController = CropViewController(croppingStyle: croppingStyle, image: selectedImage)
            
            cropController.delegate = self
            
            if croppingStyle == .circular {
                if picker.sourceType == .camera {
                    picker.pushViewController(cropController, animated: true)

//                    picker.dismiss(animated: true, completion: {
//                        self.present(cropController, animated: true, completion: nil)
//                    })
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
            
           
//            print("entered here image picker")
//            self.selectedImage = selectedImage
//            self.isSelectedImage = true
//            self.isFileSelected = false
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
            
            self.submissionsTableView.reloadData()
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
                filename = self.pdfURL.lastPathComponent
//                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
//                let thumbnail = UIImage(cgImage: cgImage)
                self.selectedImage = UIImage(named: "video")!
                self.isFileSelected = true
                self.isSelectedImage = false
                self.submissionsTableView.reloadData()
            }
            catch let error {
                    print("*** Error generating thumbnail: \(error.localizedDescription)")
                }
            
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        picker.dismiss(animated: true)
        if(info[UIImagePickerController.InfoKey.mediaType] as! CFString == kUTTypeImage){
            
            guard let selectedImage = info[.originalImage] as? UIImage else {
                return
            }
            
            //                if let image = info[.editedImage] as? UIImage{
            //                    selectedImage = image
            //                }
            //                else if let image = info[.originalImage] as? UIImage{
            //                    selectedImage = image
            //                }
            print("entered here image picker")
            self.selectedImage = selectedImage
            self.isSelectedImage = true
            self.isFileSelected = false
            self.addPicture.image = self.selectedImage
            
            
            
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
            
            
            //                print("absolut÷e string: \(filename)")
            //        let imageView = self.addFormTableView.viewWithTag(721) as! UIImageView
            //        imageView.image = selectedImage
        }
        else{
            self.pdfURL = info[UIImagePickerController.InfoKey.mediaURL]as? NSURL as URL?
            do{
                let asset = AVURLAsset(url: self.pdfURL! as URL , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                filename = self.pdfURL.lastPathComponent
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                self.selectedImage = thumbnail
                self.addPicture.image = self.selectedImage
                self.isFileSelected = true
                self.isSelectedImage = false
                
            }
            catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
            }
            
        }
        self.submissionsTableView.reloadData()
        
    }
    

    
    func openGallery() {
        
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //imagePicker.allowsEditing = true
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func goToDestination(_ sender: UIGestureRecognizer){
        let touch = sender.location(in: self.submissionsTableView)
        if let indexPath = self.submissionsTableView.indexPathForRow(at: touch) {
            print("index: \(indexPath.section)")

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let studentVC = storyboard.instantiateViewController(withIdentifier: "SubmissionDetailsViewController") as! SubmissionDetailsViewController
            studentVC.studentsList = self.studentsList
            studentVC.fullMark = self.asst?.full_mark ?? ""
//            var count = 0
//            for number in 0...indexPath.section {
//                count = count + self.uniqueStudentsList[number].count
//                print("uniqueStudentsList[number] ", self.uniqueStudentsList[number])
//
//                print("Count ", count)
//            }
//            print("Count1 ", count)
//            count = count - self.uniqueStudentsList[indexPath.row].count
//            print("self.uniqueStudentsList[indexPath.row].count ", self.uniqueStudentsList[indexPath.row].count)
            var finalIndex = indexPath.row
            for number in 0..<indexPath.section {
                finalIndex += self.uniqueStudentsList[number].count
            }
            studentVC.index = finalIndex
            studentVC.user = self.user
            studentVC.asst = self.asst
    //        studentVC.batchId = String(batchId)
            studentVC.modalPresentationStyle = .fullScreen
            self.present(studentVC, animated: true, completion: nil)
        }
        
       
    }
    
//    @objc func goToDestination(_ sender: UIView) {
//        print("entered entered")
//
//        let cell = sender.superview?.superview?.superview as! UITableViewCell
//        print("sender2: \(self.submissionsTableView.indexPath(for: cell))")
////        let cell = sender.superview?.superview?.superview as! UITableViewCell
////        let index = self.agendaTableView.indexPath(for: cell)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let studentVC = storyboard.instantiateViewController(withIdentifier: "SubmissionDetailsViewController") as! SubmissionDetailsViewController
//        studentVC.uniqueStudentsList = self.uniqueStudentsList
////        studentVC.user = self.user
////        studentVC.assignmentId = String(event.id)
////        studentVC.batchId = String(batchId)
//        studentVC.modalPresentationStyle = .fullScreen
//        self.present(studentVC, animated: true, completion: nil)
//    }

    

}


extension StudentRepliesViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == self.submissionsTableView){
            return  self.filteredList.count
            
        }
        else{
            return 1
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
//        switch tableView{
//        case self.submissionsTableView:
//
//            if(self.uniqueStudentsList[section].expand){
//                if(user.userType == 4){
//                    return self.uniqueStudentsList[section].feedbackList.count
//                }
//                else{
//                    return 1 + self.uniqueStudentsList[section].feedbackList.count
//                }
//            }
//            else {
//                return 1
//            }
//
//
//        default:
//            return 1
//        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentsReuse")
            //                                cell?.backgroundColor = UIColor(patternImage: UIImage(named: "submission_background")!, alpha: 0.0)
            cell?.backgroundColor = UIColor(white: 1, alpha: 0.0)
            let uiView = cell?.viewWithTag(1119) as! UIView
            uiView.layer.borderWidth = 2.0 // or any other width you desire
            uiView.layer.cornerRadius = 20.0 // or any other radius you desire
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToDestination(_:)))
            uiView.addGestureRecognizer(tapGesture)
            
            let countSubmissions = cell?.viewWithTag(1121) as! UITextField
            let openDiscussionsButton = cell?.viewWithTag(434) as! UIButton
            openDiscussionsButton.addTarget(self, action: #selector(onClickOpenDiscussions), for: .touchUpInside)

            if(self.asst?.enableDiscussions == false){
                openDiscussionsButton.isHidden = true
            }
            else{
                openDiscussionsButton.isHidden = false
            }
            countSubmissions.backgroundColor =  #colorLiteral(red: 0.1254901961, green: 0.4901960784, blue: 0.8392156863, alpha: 1)
            countSubmissions.text = String(self.filteredList[indexPath.section].count)
            
            countSubmissions.layer.cornerRadius = countSubmissions.frame.size.width / 2
            countSubmissions.clipsToBounds = true
            
            // Center-align text within the text view
            countSubmissions.textAlignment = .center
            
            
            let studentImage = cell?.viewWithTag(1111) as! UIImageView
            studentImage.image = UIImage(named: "student_boy")

            let studentName = cell?.viewWithTag(1112) as! UITextField
            studentName.borderStyle = .none
            if(self.user.userType == 1 || self.user.userType == 2){
                studentName.text = self.filteredList[indexPath.section].studentName
            }
            else{
                studentName.text = "\(self.user.firstName) \(self.user.lastName)"
            }
            
            let studentAnswer = cell?.viewWithTag(1114) as! UITextView
            studentAnswer.text = self.filteredList[indexPath.section].text
            let submissionDate = cell?.viewWithTag(1116) as! UITextField
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let date = formatter.date(from: self.filteredList[indexPath.section].date) ?? Date()
            
            let finalDate = self.submissionDateFormatter.string(from: date)
            submissionDate.text = finalDate
            submissionDate.borderStyle = .none

            let status = cell?.viewWithTag(1115) as! UITextField
            status.borderStyle = .none
            status.textAlignment = .left
            status.contentVerticalAlignment = .center
            
    print("filtered::: \(self.filteredList[indexPath.section].status)")
            if(self.filteredList[indexPath.section].status.lowercased() == "not started"){
                status.text = "Not Started"
                status.textColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
                uiView.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)

            }
            else if(self.filteredList[indexPath.section].status.lowercased() == "not submitted"){
                status.text = "Not Submitted"
                status.textColor = #colorLiteral(red: 0.7176470588, green: 0.04705882353, blue: 0.04705882353, alpha: 1)
                uiView.layer.borderColor = #colorLiteral(red: 0.7176470588, green: 0.04705882353, blue: 0.04705882353, alpha: 1)

            }
            else if(self.filteredList[indexPath.section].status.lowercased() == "in progress"){
                status.text = "in Progress"
                status.textColor = #colorLiteral(red: 0.7176470588, green: 0.1254901961, blue: 0.6941176471, alpha: 1)
                uiView.layer.borderColor = #colorLiteral(red: 0.7176470588, green: 0.1254901961, blue: 0.6941176471, alpha: 1)


            }
            else if(self.filteredList[indexPath.section].status.lowercased() == "pending"){
                status.text = "Pending"
                status.textColor = #colorLiteral(red: 0.9019607843, green: 0.5921568627, blue: 0.003921568627, alpha: 1)
                uiView.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.5921568627, blue: 0.003921568627, alpha: 1)



            }
            else if(self.filteredList[indexPath.section].status.lowercased() == "Completed".lowercased()){
                status.text = "Completed"
                status.textColor = #colorLiteral(red: 0.4, green: 0.6901960784, blue: 0.2745098039, alpha: 1)
                uiView.layer.borderColor = #colorLiteral(red: 0.4, green: 0.6901960784, blue: 0.2745098039, alpha: 1)


            }
            else{
                status.text = "Not Started"
                status.textColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
                uiView.layer.borderColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)


            }


            return cell!
        }
        
        //                    }
        
        return UITableViewCell()
    }
    
    
}

//extension StudentRepliesViewController: UISearchBarDelegate {
//    private func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        // Assuming your data source is an array named "dataArray"
//        self.filteredList = self.uniqueStudentsList.filter { item in
//            return item.studentName.lowercased().contains(searchText.lowercased())
//        }
//        self.submissionsTableView.reloadData()
//    }
//
////    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
////        filterContentForSearchText(searchText)
////        self.submissionsTableView.reloadData()
////    }
////
////    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
////        searchBar.text = nil
////        self.filteredList.removeAll()
////        self.submissionsTableView.reloadData()
////    }
////
////    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
////        searchBar.resignFirstResponder()
////    }
////
////    func filterContentForSearchText(_ searchText: String) {
////        self.filteredList = self.uniqueStudentsList.filter { $0.studentName.lowercased().contains(searchText.lowercased()) }
////    }
//}




extension StudentRepliesViewController: UITableViewDelegate{
    
}

extension StudentRepliesViewController: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let sizeToFitIn = CGSize(width: textView.bounds.size.width, height: CGFloat(MAXFLOAT))
        let newSize = textView.sizeThatFits(sizeToFitIn)
        print("textViewDidChange: \(newSize.height)")
        print("textViewDidChange: \(uniqueStudentsList.count)")

        
      
       
        
        if(textView == self.messageTextField){
            if(textView.text.isEmpty){
                self.submitAnswer.isHidden = true
                self.recordButton.isHidden = false
                self.recordButtonHeight.constant = 32
                self.recordButtonWidth.constant = 24

            }
            else{
                self.submitAnswer.isHidden = false
                self.recordButton.isHidden = true
                self.recordButtonHeight.constant = 0
                self.recordButtonWidth.constant = 0
            }
            self.recordButton.layoutIfNeeded()
            
            self.messageHeight.constant = newSize.height
        }
        else if(textView.tag == 101){
            let sendB = self.submissionsTableView.viewWithTag(103) as! UIButton
            let recordB = self.submissionsTableView.viewWithTag(113) as! UIButton
            if(textView.text.isEmpty){
                sendB.isHidden = true
                recordB.isHidden = false
            }
            else{
                sendB.isHidden = false
                recordB.isHidden = true
            }
        }
        else{
            print("text submitted: \(textView.text)")
            self.messageText = textView.text
            textView.frame.size.height = newSize.height
            textView.isScrollEnabled = false
            textView.translatesAutoresizingMaskIntoConstraints = true
            textView.superview?.frame.size.height = newSize.height + 12.0
            textView.superview?.superview?.frame.size.height = newSize.height
            
            self.submissionsTableView.beginUpdates()
            self.submissionsTableView.endUpdates()
            self.view.layoutIfNeeded()
        }
        
        
        
        
        
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //       var messageTextView = self.submissionsTableView.viewWithTag(101) as? UITextView
        //        messageTextView = nil
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("entered")
        
        
        //        messageTextField = textView
        
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    
    
    //    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
    //         self.textSubject = textView.text ?? ""
    //           addEvent.description = textView.text ?? ""
    //       }
}

// MARK: - API Calls:
extension StudentRepliesViewController{
    /// Description: AddDiscussion
    /// - Call "add_discussion" to add a discussion
    func addDiscussion(user: User, assignmentAnswerId: String, receiverId: String, message: String, expandList: [Bool], index: Int){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        //
        Request.shared.addDiscussion(user: user, senderId: String(user.userId), assignmentAnswerId: assignmentAnswerId, message: message, receiverId: receiverId){ (message, data, status) in
            if status == 200{
                
                if(self.uniqueStudentsList[index].status == "0"){
                    self.uniqueStudentsList[index].orderColor = "blue"
                }
                
                let recordB = self.submissionsTableView.viewWithTag(113) as! UIButton
                
                recordB.isHidden = false

                self.messageText = ""
                SectionVC.didLoadAgenda = false
                self.isFirstEntered = true
                
                self.expandList.removeAll()
                for exp in self.uniqueStudentsList{
                    self.expandList.append(exp.expand)
                }
                let messageTextView = self.submissionsTableView.viewWithTag(101) as! UITextView
                messageTextView.text = ""
                
                self.teacherDiscussions(user: user, senderId: String(user.userId), sectionId: self.batchId, assignmentId: self.assignmentId, isFirstEntered: self.isFirstEntered, expandList: expandList)
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                print("entered3")
                viewWithTag.removeFromSuperview()
            }
            
        }
    }
    
    
    func createDiscussionAgenda(user: User, title: String, assignmentId: Int, recipients: [Int]){
        
        let indicatorView = App.loadingWithText()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        
        self.view.addSubview(indicatorView)
        //
        Request.shared.createAgendaDiscussion(user: user, title: title, assignmentId: assignmentId, recipients: recipients){ (message, data, status) in
            if status == 200{
                
                print("createAgendaDiscussion: \(data)")
                
                var conversation: Inbox = Inbox(id: data?["id"].intValue ?? 0, date: "", subject: "", message: "", creator_name: "", creator_id: 0, attachment_link: "", attachment_content_type: "", attachment_file_name: "", attachment_file_size: "", canReply: true, unreadMessages: 0)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let studentVC = storyboard.instantiateViewController(withIdentifier: "DiscussionMessagesViewController") as! DiscussionMessagesViewController
                studentVC.user = self.user
                studentVC.type = "message"
                studentVC.groupName = data?["title"].stringValue ?? ""
                studentVC.messageThreadId = data?["id"].stringValue ?? "0"
                studentVC.conversation = conversation
                
                studentVC.modalPresentationStyle = .fullScreen
                self.present(studentVC, animated: true, completion: nil)
                
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                print("entered3")
                viewWithTag.removeFromSuperview()
            }
            
        }
    }
    
    
    
    func addDiscussionWithAttachment(user: User, assignmentAnswerId: String, receiverId: String, message: String, expandList: [Bool]){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.addDiscussionWithAttachment(user: user, senderId: String(user.userId), assignmentAnswerId: assignmentAnswerId, message: message, receiverId: receiverId, file: pdfURL, image: selectedImage, isSelectedImage: isSelectedImage, filename: self.filename,  fileCompressed: compressedDataToPass){ (message, data, status) in
            if status == 200{
                
                let deleteRec = self.submissionsTableView.viewWithTag(434) as! UIButton
                deleteRec.sendActions(for: .touchUpInside)
                
                self.messageText = ""
                SectionVC.didLoadAgenda = false
                self.isFirstEntered = true
                
                self.expandList.removeAll()
                for exp in self.uniqueStudentsList{
                    self.expandList.append(exp.expand)
                }
                let messageTextView = self.submissionsTableView.viewWithTag(101) as! UITextView
                messageTextView.text = ""
                
                self.teacherDiscussions(user: user, senderId: String(user.userId), sectionId: self.batchId, assignmentId: self.assignmentId, isFirstEntered: self.isFirstEntered, expandList: expandList)
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    
    /// Description: submitStudentReplies
    /// - Call "submit_student_replies" to add a assignment answer
    func submitStudentAnswers(user: User, assignmentId: String, message: String, actualTime: String){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.studentAnswer(user: user, senderId: String(self.asst?.students ?? ""), assignmentId: assignmentId, message: message, actualTime: actualTime) { (message, data, status) in
            
            print("resp resp resp: \(message)")
            print("resp resp resp: \(data)")
            print("resp resp resp: \(status)")

            if status == 200{
                
                SectionVC.didLoadAgenda = false
                self.expandList.append(false)
                self.isFirstEntered = false
                
                self.submissionForm.isHidden = true
                
//                self.messageTextField.text = ""
                
                self.getStudentAnswers(user: self.user, senderId: self.asst?.students ?? "0")
                
//                self.teacherDiscussions(user: user, senderId: String(user.userId), sectionId: self.batchId, assignmentId: assignmentId, isFirstEntered: self.isFirstEntered, expandList: self.expandList)
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            
            if let viewWithTag = self.view.viewWithTag(100){
                print("entered3")
                viewWithTag.removeFromSuperview()
            }
            
        }
    }
    
    /// Description: submitStudentRepliesWithAttachment
    /// - Call "submit_student_replies" to add a assignment answer
    func submitStudentAnswersWithAttachment(user: User, assignmentId: String, message: String, actualTime: String){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.studentAnswerWithAttachment(user: user, senderId: String(self.asst?.students ?? ""), assignmentId: assignmentId, message: message, file: pdfURL, image: selectedImage, isSelectedImage: isSelectedImage, filename: self.filename,  fileCompressed: compressedDataToPass, actualTime: actualTime) { (message, data, status) in
            if status == 200{
                SectionVC.didLoadAgenda = false
                self.expandList.append(false)
                self.isFirstEntered = false
//                self.messageTextField.text = ""
                self.submissionForm.isHidden = true
                
                self.getStudentAnswers(user: self.user, senderId: self.asst?.students ?? "0")
//                self.teacherDiscussions(user: user, senderId: String(user.userId), sectionId: self.batchId, assignmentId: assignmentId, isFirstEntered: self.isFirstEntered, expandList: self.expandList)
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                print("entered3")
                viewWithTag.removeFromSuperview()
            }
        }
    }
    func teacherDiscussions(user: User, senderId: String, sectionId: String, assignmentId: String, isFirstEntered: Bool, expandList: [Bool]){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.teacherDiscussions(user: user, senderId: senderId, sectionId: sectionId, assignmentId: assignmentId, color: self.color, expandList: expandList, isFirstEntered: self.isFirstEntered, answersColors: self.answersColors, discussionColors: self.discussionColors) { (message, subjectData, status) in
            self.dismissKeyboard()
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
            
            if status == 200{
                
                self.studentsList = subjectData!
                self.filteredList = subjectData!
                print("student list: \(self.uniqueStudentsList)")
                self.openAttach = false
                self.isSelectedImage = false
                self.isFileSelected = false
                self.uniqueStudentsList = []
               
                
                for std in self.studentsList{
                    
                    
                    print("unique assigned student: \(self.uniqueStudentsList.firstIndex(where: { $0.assignedStudentId == std.assignedStudentId }))")
                    if let foundIndex = self.uniqueStudentsList.firstIndex(where: { $0.assignedStudentId == std.assignedStudentId }) {
                        self.uniqueStudentsList[foundIndex].count = self.uniqueStudentsList[foundIndex].count + 1
                    } else {
                        print("assignedStudentId: \(std.assignedStudentId)")

                        self.uniqueStudentsList.append(std)
                    }
                    
                }
                
                print("unique students list: \(self.uniqueStudentsList)")
                print("unique students list: \(self.uniqueStudentsList.count)")
                
                self.filteredList = self.uniqueStudentsList

                

                self.uniqueStudentsList = self.sortStudent(studentList: self.uniqueStudentsList)
                self.filteredList = self.sortStudent(studentList: self.filteredList)

                self.submissionsTableView.reloadData();
                                
            }
            else if status == 400{
                if message == "answer not found"{
                    self.uniqueStudentsList = subjectData!
                    if(self.uniqueStudentsList.count == 0){
                        if(user.userType == 3){
                            self.sendView.isHidden = false
                        }
                        else{
                            self.sendView.isHidden = true
                        }
                    }
                    
                    self.uniqueStudentsList = self.sortStudent(studentList: self.uniqueStudentsList)
                    self.submissionsTableView.reloadData();
                    
                    
                }
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            
        }
    }
    
    func getStudentAnswers(user: User, senderId: String){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.getStudentAnswers(user: user, senderId: senderId) { (message, subjectData, status) in
            self.dismissKeyboard()
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
            
            if status == 200{
                
                self.studentsList = subjectData!
                print("student list: \(self.uniqueStudentsList)")
                self.uniqueStudentsList = []
                self.openAttach = false
                self.isSelectedImage = false
                self.isFileSelected = false

                for std in self.studentsList{
                    
                    if let foundIndex = self.uniqueStudentsList.firstIndex(where: { $0.assignedStudentId == std.assignedStudentId }) {
                        self.uniqueStudentsList[foundIndex].count = self.uniqueStudentsList[foundIndex].count + 1
                    } else {
                        self.uniqueStudentsList.append(std)
                    }
                    
                }
                
                print("unique unique: \(self.uniqueStudentsList)")
                self.uniqueStudentsList = self.sortStudent(studentList: self.uniqueStudentsList)
                self.filteredList = self.uniqueStudentsList

                self.submissionsTableView.reloadData();
                

                
            }
            else if status == 400{
                if message == "answer not found"{
                    self.uniqueStudentsList = subjectData!
                    if(self.uniqueStudentsList.count == 0){
                        if(user.userType == 3){
                            self.sendView.isHidden = false
                        }
                        else{
                            self.sendView.isHidden = true
                        }
                    }
                    
                    self.uniqueStudentsList = self.sortStudent(studentList: self.uniqueStudentsList)
                    self.submissionsTableView.reloadData();
                    
                    
                }
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            
        }
    }
    
    
    /// Description: Accept or decline student assignment submission
    /// - Call "acceptOrDeclineStudentAssignmentSubmission" to accept or decline a student assignment submission
    func acceptOrDeclineAnswers(check: Int, id: String, index: Int){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.acceptOrDeclineStudentAssignmentSubmission(check: check, id: id) { (message, data, status) in
            if status == 200{
                print(data)
                print(message)
                print(index)
                if(check == 1){
                    self.uniqueStudentsList[index].orderColor = "green"
                }
                else{
                    self.uniqueStudentsList[index].orderColor = "red"
                }
                
                self.uniqueStudentsList = self.sortStudent(studentList: self.uniqueStudentsList)
                self.submissionsTableView.reloadData();
                
                
                
            }
            else{
                print("cancelTapped failed")
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
        }
    }
    
}

// ViewController.swift
//class ScrollViewController: UIViewController {
//
//  @IBOutlet weak var scrollView: UIScrollView!
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//
//      // Do any additional setup after loading the view.
//    NotificationCenter.default.addObserver(self, selector: #selector(StudentRepliesViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//    NotificationCenter.default.addObserver(self, selector: #selector(StudentRepliesViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//  }
//
//  @objc func keyboardWillShow(notification: NSNotification) {
//    guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//    else {
//      // if keyboard size is not available for some reason, dont do anything
//      return
//    }
//
//    let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
//    scrollView.contentInset = contentInsets
//    scrollView.scrollIndicatorInsets = contentInsets
//  }
//
//  @objc func keyboardWillHide(notification: NSNotification) {
//    let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
//
//
//    // reset back the content inset to zero after keyboard is gone
//    scrollView.contentInset = contentInsets
//    scrollView.scrollIndicatorInsets = contentInsets
//  }
//}
