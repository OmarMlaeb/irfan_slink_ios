//
//  DiscussionMessagesViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 10/13/20.
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
import AVFoundation

class DiscussionMessagesViewController: UIViewController, UINavigationControllerDelegate, UIDocumentPickerDelegate, AVAudioRecorderDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var attachmentPicture: UIImageView!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var recipients: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var finalRecordingLabel: UILabel!
    @IBOutlet weak var recordTime: UILabel!
    @IBOutlet weak var deleteRecord: UIButton!
    @IBOutlet weak var recordingLayoutHeight: NSLayoutConstraint!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var rTimer: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var currentRecording: UIView!
    @IBOutlet weak var finalRecording: UIView!
    @IBOutlet weak var recordButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var recordButtonWidth: NSLayoutConstraint!
    
    var recordTimer = Timer()
    var count = 0
    var timerCounting:Bool = false
    var conversation: Inbox = Inbox(id: 0, date: "", subject: "", message: "", creator_name: "", creator_id: 0, attachment_link: "", attachment_content_type: "", attachment_file_name: "", attachment_file_size: "", canReply: false, unreadMessages: 0)
    var attachmentType: String = "text"
    var schoolInfo: SchoolActivation!
    var canEdit: Bool = true
    var messagesList = [DiscussionMessageModel]()
    var user: User!
    var answersColors: [String] = ["#ef4a7b","#337ba8","#33a567","#9ba439","#923e97","#a57732","#a64234","#a43463","#769e3f","#99573e","#3e998c"]
    var imagePicker = UIImagePickerController()
    var pdfURL : URL!
    var selectedImage : UIImage = UIImage()
    var isFileSelected = false
    var isSelectedImage = false
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")
    var isFirstEntered: Bool = false
    var openAttach: Bool = false
    var fName: String = "slink"
    var messageThreadId: String = "0"
    var page = 0
    var recipientNumber: String = ""
    var groupName: String = ""
    var timer: Timer?
    var counter: Int = 0
    var userList: [User] = []
    var colorList: [String] = ["#6ebee9","#cb57a0","#46bc8c","#f2cf61","#ec7078","#bed964","#fcb25b","#f16822","#7a60ab","#e2db57","#1195aa","#4a74ba"]

    var voiceRecorder: AVAudioRecorder!
    
    var selectedAssets = [PHAsset]()
    var selectedImages = [UIImage]()
    var photosPreview = [String]()
    
    @IBOutlet weak var tempLayout: UIView!
    @IBOutlet weak var cancelPhotoImage: UIButton!
    @IBOutlet weak var tempImagePreview: UIImageView!
    @IBOutlet weak var tempImageCollectionView: UICollectionView!
    @IBOutlet weak var tempSendView: UIView!
    @IBOutlet weak var tempSendTextview: UITextView!
    @IBOutlet weak var tempHeightSend: NSLayoutConstraint!
    @IBOutlet weak var tempSendButton: UIButton!
    var tempMessagesText: [String] = ["", "", "", "", "", "", ""]
    var imageIndex = 0
    var uploadedImages = 0
    var compressedDataToPass: NSData!
    //type
    var type: String = ""
    var creatorId: Int = 0

    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messagesTableView.dataSource = self
        self.messagesTableView.delegate = self
        
        self.messagesTableView.register(UINib(nibName: "AudioSentTableViewCell", bundle: nil), forCellReuseIdentifier: "audioSentReuse")
        self.messagesTableView.register(UINib(nibName: "AudioReceivedTableViewCell", bundle: nil), forCellReuseIdentifier: "audioReceivedReuse")

        if(self.conversation.canReply == true){
            self.sendView.isHidden = false
        }
        else{
            self.sendView.isHidden = true

            if(self.creatorId == self.user.userId){
                self.sendView.isHidden = false
       
            } else{
                self.sendView.isHidden = true
            }
        }
        
        self.schoolInfo = App.getSchoolActivation(schoolID: self.user.schoolId)

        
        titleLabel.text = groupName
        recipients.text = "\(recipientNumber) members"
        
       
        imagePicker.delegate = self
        self.messagesTableView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.937254902, blue: 0.9764705882, alpha: 1)
        messageTextView.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        messageTextView.inputAccessoryView = UIView()
        self.messagesTableView.transform = CGAffineTransform(rotationAngle: (-.pi))
        self.messagesTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.messagesTableView.bounds.size.width - 10)
            self.loadMessages(user: user, id: messageThreadId, page: page)
        self.messageRecipient(user: user, id: messageThreadId, colorList: self.colorList) { userIds, errorMessage in
                    if(self.user.userType == 1){
                        print("userIds ", userIds)
                        if let userIds = userIds {
                            if userIds.contains(self.user.userId) {
                                self.sendView.isHidden = false
                            } else{
                                self.sendView.isHidden = true
                            }
                        } else {
                            if let errorMessage = errorMessage {
                            
                            }
                        }
                    }
                }
     
        self.recordingLayoutHeight.constant = 0
        setUpRecorder()
        
        self.tempImageCollectionView.dataSource = self
        self.tempImageCollectionView.delegate = self
        
    }
//    override func viewWillAppear(_ animated: Bool) {
//        if(self.canEdit){
//                timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(syncMessageCall), userInfo: nil, repeats: true)
//
//
//
//        }
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        if timer != nil{
//            timer?.invalidate()
//        }
//    }
//    override func viewDidDisappear(_ animated: Bool) {
//        if timer != nil{
//            timer?.invalidate()
//        }
//    }
   
//    @objc func syncMessageCall()
//    {
//        self.loadCurrentMessages(user: user, id: messageThreadId, page: 0)
//    }
    

    
    @IBAction func deleteRecord(_ sender: UIButton) {
        self.count = 0
        self.recordTimer.invalidate()
        self.rTimer.text = self.makeTimeString(minutes: 0, seconds: 0)
        self.finalRecording.isHidden = true
        self.recordingLayoutHeight.constant = 0
        attachmentPicture.isHidden = false
        self.isFileSelected = false
        if(self.messageTextView.text.isEmpty){
            sendButton.isHidden = true
            recordButton.isHidden = false
        }else{
            sendButton.isHidden = false
            recordButton.isHidden = true
        }
       
        voiceRecorder.deleteRecording()
    }
    
    @IBAction func startRecording(_ sender: UIButton) {
        currentRecording.isHidden = false
        recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        self.count = 0
        self.rTimer.text = self.makeTimeString(minutes: 0, seconds: 0)
        finalRecording.isHidden = true
        self.recordingLayoutHeight.constant = 0
        messageTextView.isHidden = true
        attachmentPicture.isHidden = true
        sendButton.isHidden = true
        recordButton.isHidden = false
        voiceRecorder.record()
    }
    
    @IBAction func endRecording(_ sender: UIButton) {
        finalRecording.isHidden = false
        self.recordingLayoutHeight.constant = 30
        currentRecording.isHidden = true
        self.recordTimer.invalidate()
        messageTextView.isHidden = false
        attachmentPicture.isHidden = true
        sendButton.isHidden = false
        recordButton.isHidden = true
        voiceRecorder.stop()
        self.attachmentType = "audio"

        
    }
    
    // temp view
    @IBAction func cancelTempLayout(_ sender: UIButton) {
        print("cancel temp")
        tempLayout.isHidden = true
        self.attachmentType = "text"
    }
    
    @objc func deleteImage(sender: CustomTapGestureRecognizer){

        print("index: \(sender.passedValue ?? 0)")
        print("size: \(self.selectedImages.count)")
        
        
        if(self.selectedImages.count == 0 || self.selectedImages.count == 1){
            self.tempImagePreview.image = UIImage(named: "kjdjd")
         }
        else if(sender.passedValue == 0 && self.selectedImages.count >= 2) {
             let image = selectedImages[sender.passedValue! + 1 ]
            self.tempImagePreview.image = image
         }
        else{
            let image = selectedImages[sender.passedValue! - 1 ]
            self.tempImagePreview.image = image
        }
                   
        selectedImages.remove(at: sender.passedValue!)

        tempImageCollectionView.reloadData()
         
        
    }
    
    @objc func previewImage(sender: CustomTapGestureRecognizer){
        print("indexindex: \(sender.passedValue ?? 0)")
        print("sizesize: \(selectedImages.count)")
        let image = selectedImages[sender.passedValue!]
        self.tempImagePreview.image = image
        self.tempMessagesText[imageIndex] = self.tempSendTextview.text
        imageIndex = sender.passedValue!
        self.tempSendTextview.text = self.tempMessagesText[imageIndex]
        
        
        
        
        
    }
    
    @IBAction func tempSendMessages(_ sender: UIButton) {
        self.tempMessagesText[self.imageIndex] = self.tempSendTextview.text
        self.imageIndex = 0
        for msg in self.tempMessagesText{
            print("text messages: \(msg)")
        }
        self.tempLayout.isHidden = true
        var msgText = "attachment0"
        
        if(!self.tempMessagesText[0].isEmpty){
            msgText = self.tempMessagesText[0]
        }
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 115
        self.view.addSubview(indicatorView)
        
//        let lb = UILabel(frame: CGRect(x: 100, y: 200, width: 200, height: 200))
//        lb.text="anything"

        // show on screen
//        self.view.addSubview(lb)
//        lb.insertSubview(lb, belowSubview: indicatorView)
//        lb.center = self.view.center
//
//
//        self.view.addSubview(indicatorView)
        
        
        self.sendMessageWithAttachment2(user: user, messageThreadId: self.messageThreadId, images: self.selectedImages[0], message: msgText)
        
    }
    
    func secondsToMinuteSeconds(seconds: Int) -> (Int, Int){
        return (((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    
    @objc func timerCounter(){
        count = count + 1
        let time = secondsToMinuteSeconds(seconds: count)
        let timeString = makeTimeString(minutes: time.0, seconds: time.1)
        rTimer.text = timeString
        recordTime.text = timeString
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
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.isFileSelected = true
        self.pdfURL = recorder.url
        
        
    }
    
    func recordAudio(_ sender: Any){
        
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
   
    @IBAction func sendMessage(_ sender: UIButton) {
        self.canEdit = false
        if(self.messageTextView.text.isEmpty && !self.isSelectedImage && !self.isFileSelected){
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Alert", message: "You cannot submit an empty message", actions: [ok])
        }
        else{
                if(self.isSelectedImage || self.isFileSelected){
                    self.sendMessageWithAttachment(user: user, messageThreadId: messageThreadId, message: self.messageTextView.text, schoolInfo: self.schoolInfo)
                }
                else{
                    self.sendMessage(user: self.user, messageThreadId: messageThreadId, message: self.messageTextView.text, schoolInfo: self.schoolInfo)
                }
        }
      
        
        
    }
    
    
    @IBAction func moveToAboutDiscussion(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "AboutDiscussionUsersViewController") as! AboutDiscussionUsersViewController
        studentVC.threadId = self.messageThreadId
        studentVC.titleG = self.groupName
        studentVC.user = self.user
        studentVC.modalPresentationStyle = .fullScreen
        self.present(studentVC, animated: true, completion: nil)
    }
    
    @IBAction func openAttachment(_ sender: UIButton) {
        let alert = UIAlertController(title: "Upload picture".localiz(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take photo".localiz(), style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose an image".localiz(), style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction(title: "Choose a video".localiz(), style: .default, handler: { _ in
            self.openVideo()
        }))
        
        alert.addAction(UIAlertAction(title: "Attach a file".localiz(), style: .default, handler: { _ in
            self.attachDocument()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel".localiz(), style: .cancel, handler: nil))
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
   
    fileprivate lazy var dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        return formatter
    }()
    
    fileprivate lazy var messageDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    
    
    
    @objc func openLink(tapGesture: MyTapGestureDiscussion){
        
        
//        let urlfixed = self.messagesList[sender.index!.row].senderLink
//        let alert = UIAlertController(title: "Open Attachment".localiz(), message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "View", style: .default, handler: { _ in
        self.viewDocument(url: tapGesture.url, index: tapGesture.index!)
//        }))
        
//        alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { _ in
//            self.downloadDocument(url: urlfixed)
//        }))
        
       
//        switch UIDevice.current.userInterfaceIdiom {
//        case .pad:
//            alert.popoverPresentationController?.sourceView = sender
//            alert.popoverPresentationController?.sourceRect = (sender).bounds
////                alert.popoverPresentationController?.permittedArrowDirections = .up
//        default:
//            break
//        }
//        self.present(alert, animated: true, completion: nil)

    }
    @objc override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func downloadDocument(url: String){
        guard let safari = URL(string: url) else { return }
        UIApplication.shared.open(safari)
    }
    func viewDocument(url: String, index: IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "OpenAttachmentViewController") as! OpenAttachmentViewController
        studentVC.linkText = url
        studentVC.attachmentName = self.messagesList[index.row].senderFilename
        studentVC.attachmentType = self.messagesList[index.row].senderContentType
        studentVC.modalPresentationStyle = .fullScreen
        self.present(studentVC, animated: true, completion: nil)
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
            
            self.fName = self.pdfURL.lastPathComponent
                    
            
            let filetype = self.pdfURL.description.suffix(4).lowercased()
                if filetype == ".pdf"{
                    self.attachmentPicture.image = UIImage(named: "pdf_logo")
                }else if filetype == "docx"{
                   self.attachmentPicture.image = UIImage(named: "word_logo")
                }else if filetype == "xlsx"{
                    self.attachmentPicture.image = UIImage(named: "excel_logo")
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
                    self.attachmentPicture.image = UIImage(named: "doc_logo")
                }
    
            self.attachmentType = "file"

            self.messagesTableView.reloadData()
           }
           
           func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
               controller.dismiss(animated: true, completion: nil)
           }
}

extension DiscussionMessagesViewController: UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
          return 1
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messagesList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if(String(user.userId) == self.messagesList[indexPath.row].senderId){
            if(self.messagesList[indexPath.row].senderContentType != "" && (self.messagesList[indexPath.row].senderContentType == "image" || self.messagesList[indexPath.row].senderContentType == "file")){
                print("send send send1: \(self.messagesList[indexPath.row])")

                let cell = tableView.dequeueReusableCell(withIdentifier: "imageSentReuse")
                
                cell?.transform = CGAffineTransform(rotationAngle: (.pi))
                cell?.backgroundColor = UIColor(white: 1, alpha: 0.0)
                /*let view = cell?.viewWithTag(120) as! UIView*/
                
                
                let image = cell?.viewWithTag(198) as! UIImageView
                let attachmentList = self.messagesList[indexPath.row].senderLink
                
                image.isUserInteractionEnabled = true
                let tapGesture = MyTapGestureDiscussion(target: self, action: #selector(openLink(tapGesture:)))
                tapGesture.index = indexPath
                tapGesture.url = attachmentList

                image.addGestureRecognizer(tapGesture)


//                image.translatesAutoresizingMaskIntoConstraints = false

            
                if(self.messagesList[indexPath.row].senderContentType == "image"){
                    // Assuming imageView is your UIImageView and you want to set its maximum height to 200 points.

                    // Set the maximum height constraint
//                    let maxHeightConstraint = image.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
//                    maxHeightConstraint.isActive = true
                    
                    image.sd_setImage(with: URL(string: attachmentList), completed: { (img, error, cacheType, imageUrl) in
                        if let error = error {
                            // Handle the error, for example, log it or show a placeholder image
                            print("Error loading image: \(error.localizedDescription)")

                            // Optionally, you can also show a placeholder image or handle the error in some other way
                            let placeholderImage = UIImage(named: "corrupted")
                            image.image = placeholderImage
                        } else {
                            // Image loaded successfully
                            if let viewWithTag = self.view.viewWithTag(100) {
                                viewWithTag.removeFromSuperview()
                            }
                        }
                    })
                }
                else{
               
                    // Set the maximum height constraint
//                    let maxHeightConstraint = image.heightAnchor.constraint(lessThanOrEqualToConstant: 100)
//                    maxHeightConstraint.isActive = true
                    
                    // Assuming you have a container UIView and an UIImageView inside it:

                    
                    image.image = UIImage(named: "pdf_logo")
                }
                
                let dateLabel = cell?.viewWithTag(111) as! UILabel
                dateLabel.layer.masksToBounds = true
                let date = self.dateFormat.date(from: self.messagesList[indexPath.row].messageDate)
                let dateFormatted = self.messageDateFormat.string(from: date!)
                
                dateLabel.text = dateFormatted

                return cell!
            }
            else if(self.messagesList[indexPath.row].senderContentType != "" && self.messagesList[indexPath.row].senderContentType == "audio"){
                print("send send send3: \(self.messagesList[indexPath.row])")
                let cell = tableView.dequeueReusableCell(withIdentifier: "audioSentReuse", for: indexPath) as! AudioSentTableViewCell
                let audioURL = self.messagesList[indexPath.row].senderLink
                
                cell.transform = CGAffineTransform(rotationAngle: (.pi))
                cell.backgroundColor = UIColor(white: 1, alpha: 0.0)
                cell.playButton.setTitle("", for: .normal)
                cell.view.backgroundColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)
                cell.view.layer.cornerRadius = 10
                cell.view.clipsToBounds = true
                cell.configureCell(from: audioURL)

                cell.sentDate.layer.masksToBounds = true
                let date = self.dateFormat.date(from: self.messagesList[indexPath.row].messageDate)
                let dateFormatted = self.messageDateFormat.string(from: date!)
                
                cell.sentDate.text = dateFormatted
                
                return cell
                
            }
            else{
                print("send send send2: \(self.messagesList[indexPath.row])")

                let cell = tableView.dequeueReusableCell(withIdentifier: "sendReuse2")
                cell?.transform = CGAffineTransform(rotationAngle: (.pi))
                cell?.backgroundColor = UIColor(white: 1, alpha: 0.0)
                let sendTeviView = cell?.viewWithTag(954) as! UITextView
                sendTeviView.backgroundColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)
                sendTeviView.text = messagesList[indexPath.row].messageText
               
                let view = cell?.viewWithTag(120) as! UIView
                view.layer.masksToBounds = true
                view.cornerRadius = 10
                view.backgroundColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)

                let attachmentButton = cell?.viewWithTag(122) as! UIButton
                attachmentButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)
                
    //            let width = attachmentButton.constraints[0]
               
                
                let dateLabel = cell?.viewWithTag(111) as! UILabel
                dateLabel.layer.masksToBounds = true
                let date = self.dateFormat.date(from: self.messagesList[indexPath.row].messageDate)
                let dateFormatted = self.messageDateFormat.string(from: date!)
                
                dateLabel.text = dateFormatted
              

                if(self.messagesList[indexPath.row].senderLink.isEmpty){
                    attachmentButton.isHidden = true
    //                width.constant = 0
                }
                else{
                    attachmentButton.isHidden = false
    //                width.constant = 32
                }
                
                let insets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
                sendTeviView.textContainerInset = insets
                return cell!
            }
           
        }
        else{
          
            if(self.messagesList[indexPath.row].senderContentType != "" && (self.messagesList[indexPath.row].senderContentType == "image" || self.messagesList[indexPath.row].senderContentType == "file")){
                print("send send send1: \(self.messagesList[indexPath.row])")

                let cell = tableView.dequeueReusableCell(withIdentifier: "imageReceivedReuse")
                
                cell?.transform = CGAffineTransform(rotationAngle: (.pi))
                cell?.backgroundColor = UIColor(white: 1, alpha: 0.0)
                /*let view = cell?.viewWithTag(120) as! UIView*/
                
                
                let image = cell?.viewWithTag(433) as! UIImageView
                let attachmentList = self.messagesList[indexPath.row].senderLink
                
                image.isUserInteractionEnabled = true
                let tapGesture = MyTapGestureDiscussion(target: self, action: #selector(openLink(tapGesture:)))
                tapGesture.index = indexPath
                tapGesture.url = attachmentList

                image.addGestureRecognizer(tapGesture)


//                image.translatesAutoresizingMaskIntoConstraints = false

            
                if(self.messagesList[indexPath.row].senderContentType == "image"){
                    // Assuming imageView is your UIImageView and you want to set its maximum height to 200 points.

                    // Set the maximum height constraint
//                    let maxHeightConstraint = image.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
//                    maxHeightConstraint.isActive = true
                    
                    image.sd_setImage(with: URL(string: attachmentList), completed: { (img, error, cacheType, imageUrl) in
                        if let error = error {
                            // Handle the error, for example, log it or show a placeholder image
                            print("Error loading image: \(error.localizedDescription)")

                            // Optionally, you can also show a placeholder image or handle the error in some other way
                            let placeholderImage = UIImage(named: "corrupted")
                            image.image = placeholderImage
                        } else {
                            // Image loaded successfully
                            if let viewWithTag = self.view.viewWithTag(100) {
                                viewWithTag.removeFromSuperview()
                            }
                        }
                    })
                }
                else{
               
                    image.image = UIImage(named: "doc_logo")
                    let maxHeightConstraint = image.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
                    maxHeightConstraint.isActive = true
                }
                
                let profileImage = cell?.viewWithTag(110) as! UIImageView
                profileImage.layer.borderWidth = 1
                profileImage.layer.masksToBounds = false
                profileImage.layer.borderColor = UIColor.black.cgColor
                profileImage.layer.cornerRadius = profileImage.frame.height/2
                profileImage.clipsToBounds = true
                profileImage.backgroundColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)
    //            profileImage.image = UIImage(named: "teacher_boy")
                
                let dateLabel = cell?.viewWithTag(111) as! UILabel
                dateLabel.layer.masksToBounds = true
                let date = self.dateFormat.date(from: self.messagesList[indexPath.row].messageDate)
                let dateFormatted = self.messageDateFormat.string(from: date!)
                
                dateLabel.text = dateFormatted
                
                let senderName = cell?.viewWithTag(106) as! UILabel
                senderName.textColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)
                senderName.text = self.messagesList[indexPath.row].senderName
                senderName.font = UIFont(name: "OpenSans-Bold", size: 15)
              

                return cell!
            } else if(self.messagesList[indexPath.row].senderContentType != "" && self.messagesList[indexPath.row].senderContentType == "audio"){
                print("send send send3: \(self.messagesList[indexPath.row])")
                let cell = tableView.dequeueReusableCell(withIdentifier: "audioReceivedReuse", for: indexPath) as! AudioReceivedTableViewCell
                let audioURL = self.messagesList[indexPath.row].senderLink
                
                cell.transform = CGAffineTransform(rotationAngle: (.pi))
                cell.backgroundColor = UIColor(white: 1, alpha: 0.0)
                cell.playButton.setTitle("", for: .normal)
                cell.view.backgroundColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)
                cell.view.layer.cornerRadius = 10
                cell.view.clipsToBounds = true
                cell.configureCell(from: audioURL)
                
                
                cell.userImage.layer.borderWidth = 1
                cell.userImage.layer.masksToBounds = false
                cell.userImage.layer.borderColor = UIColor.black.cgColor
                cell.userImage.layer.cornerRadius = cell.userImage.frame.height/2
                cell.userImage.clipsToBounds = true
                cell.userImage.backgroundColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)
    //            profileImage.image = UIImage(named: "teacher_boy")
                
                cell.sentDate.layer.masksToBounds = true
                let date = self.dateFormat.date(from: self.messagesList[indexPath.row].messageDate)
                let dateFormatted = self.messageDateFormat.string(from: date!)
                
                cell.sentDate.text = dateFormatted
                
                cell.senderName.textColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)
                cell.senderName.text = self.messagesList[indexPath.row].senderName
                cell.senderName.font = UIFont(name: "OpenSans-Bold", size: 15)
                
                

                return cell
                
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiveReuse2")
                cell?.backgroundColor = UIColor(white: 1, alpha: 0.0)
            
                

                cell?.transform = CGAffineTransform(rotationAngle: (.pi))

                let sendTeviView = cell?.viewWithTag(4376) as! UITextView
                sendTeviView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                sendTeviView.text = messagesList[indexPath.row].messageText
                let insets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
                sendTeviView.textContainerInset = insets
                

                let view = cell?.viewWithTag(121) as! UIView
                view.layer.masksToBounds = true
                view.cornerRadius = 10
                view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

                let attachmentButton = cell?.viewWithTag(123) as! UIButton
                attachmentButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)

    //            let width = attachmentButton.constraints[0]
                if(self.messagesList[indexPath.row].senderLink.isEmpty){
                    attachmentButton.isHidden = true
    //                width.constant = 0
                }
                else{
                    attachmentButton.isHidden = false
    //                width.constant = 32
                }
                
                let profileImage = cell?.viewWithTag(110) as! UIImageView
                profileImage.layer.borderWidth = 1
                profileImage.layer.masksToBounds = false
                profileImage.layer.borderColor = UIColor.black.cgColor
                profileImage.layer.cornerRadius = profileImage.frame.height/2
                profileImage.clipsToBounds = true
                profileImage.backgroundColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)
    //            profileImage.image = UIImage(named: "teacher_boy")
                
                let dateLabel = cell?.viewWithTag(111) as! UILabel
                dateLabel.layer.masksToBounds = true
                let date = self.dateFormat.date(from: self.messagesList[indexPath.row].messageDate)
                let dateFormatted = self.messageDateFormat.string(from: date!)
                
                dateLabel.text = dateFormatted
                
                let senderName = cell?.viewWithTag(106) as! UILabel
                senderName.textColor = App.hexStringToUIColor(hex: self.messagesList[indexPath.row].color, alpha: 1.0)
                senderName.text = self.messagesList[indexPath.row].senderName
                senderName.font = UIFont(name: "OpenSans-Bold", size: 15)
                    return cell!
            }
            
        
    }

}
}
extension DiscussionMessagesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if self.messagesTableView.indexPathsForVisibleRows?.last?.row == self.messagesList.count - 1{
            if(self.canEdit == true){
                if(self.counter < 3){
                    self.canEdit = false
                    self.page += 1
                    self.loadMessages(user: user, id: self.messageThreadId, page: self.page)
                    
                }
            }
            
           }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(self.messagesList[indexPath.row].senderContentType == "image"){
            return 200
        }
        else if(self.messagesList[indexPath.row].senderContentType == "file"){
            return 100
        }
        return UITableView.automaticDimension
        
    }
    
}
// MARK: - UICollecionView functions:
extension DiscussionMessagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosReuse", for: indexPath)as!GalleryView
        cell.galleryImage.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        cell.galleryImage.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        cell.galleryImage.contentMode = .scaleAspectFill
        cell.galleryImage.layer.cornerRadius = 10
        cell.galleryImage.clipsToBounds = true
        
        cell.galleryImage.image = selectedImages[indexPath.item]
        print("image chosen: \(selectedImages[indexPath.item])")
        cell.deleteImageButton.image = UIImage(named: "x")
        let deleteGesture = CustomTapGestureRecognizer(target: self, action: #selector(deleteImage))
        deleteGesture.passedValue = indexPath.item
        cell.deleteImageButton.addGestureRecognizer(deleteGesture)
        cell.deleteImageButton.isUserInteractionEnabled = true
        
        
        let previewGesture = CustomTapGestureRecognizer(target: self, action: #selector(previewImage))
        previewGesture.passedValue = indexPath.item
        cell.galleryImage.addGestureRecognizer(previewGesture)
        cell.galleryImage.isUserInteractionEnabled = true
        
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return selectedImages.count
        
    }
}
extension DiscussionMessagesViewController: UITextViewDelegate{

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let sizeToFitIn = CGSize(width: textView.bounds.size.width, height: CGFloat(MAXFLOAT))
        let newSize = textView.sizeThatFits(sizeToFitIn)

        if(textView == self.messageTextView){
            if(textView.text.isEmpty){
                self.sendButton.isHidden = true
                self.recordButton.isHidden = false
                self.recordButtonHeight.constant = 32
                self.recordButtonWidth.constant = 24

            }
            else{
                self.sendButton.isHidden = false
                self.recordButton.isHidden = true
                self.recordButtonHeight.constant = 0
                self.recordButtonWidth.constant = 0
            }
            self.recordButton.layoutIfNeeded()
            
            
            self.messageHeight.constant = newSize.height
        }
        else{
            textView.frame.size.height = newSize.height
            textView.isScrollEnabled = false
            textView.translatesAutoresizingMaskIntoConstraints = true
            textView.superview?.frame.size.height = newSize.height + 12.0
            textView.superview?.superview?.frame.size.height = newSize.height

            self.messagesTableView.beginUpdates()
            self.messagesTableView.endUpdates()
            self.view.layoutIfNeeded()
        }

    }


    func textViewDidEndEditing(_ textView: UITextView) {

    }
    func textViewDidBeginEditing(_ textView: UITextView) {

    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }

}
extension DiscussionMessagesViewController: UIImagePickerControllerDelegate{

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true , completion: nil )
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
            self.pdfURL = info[UIImagePickerController.InfoKey.mediaURL]as? NSURL as URL?
            let filetype = self.pdfURL.description.suffix(4).lowercased()
            
            if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                
                attachmentPicture.image = UIImage(named: "video")

                let data = try! Data(contentsOf: pdfURL! as URL)
                
                print("File size before compression: \(data)")

                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                
                compressVideo(inputURL: self.pdfURL as! URL, outputURL: compressedURL) { (exportSession) in
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
                                    self.attachmentType = "image"

                                case .failed:
                                    break
                                case .cancelled:
                                    break
                                }
                            }
            }
            else{
                self.attachmentPicture.image = UIImage(named: "doc_logo")

            }
            
            
            
            do{
                let asset = AVURLAsset(url: self.pdfURL! as URL , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                fName = self.pdfURL.lastPathComponent
//                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
//                let thumbnail = UIImage(cgImage: cgImage)
                self.selectedImage = UIImage(named: "video")!
                self.isFileSelected = true
                self.isSelectedImage = false
                self.messagesTableView.reloadData()
                self.attachmentType = "image"


            }
            catch let error {
                    print("*** Error generating thumbnail: \(error.localizedDescription)")
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
    func openCamera() {
        var minimumSize: CGSize = CGSize(width: 60, height: 60)

        var croppingParameters: CroppingParameters {
            return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: minimumSize)
        }

        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            // Do something with your image here.
            if image != nil{
                self?.selectedImage = image!
                self?.isSelectedImage = true
                self?.isFileSelected = false
//                    let imageView = self?.studentsTableView.viewWithTag(333) as! UIImageView
//                    imageView.image = image

                self?.attachmentPicture.image = image
                self?.messagesTableView.reloadData()
                self?.attachmentType = "image"

            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }

    func openVideo() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //imagePicker.allowsEditing = true
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        self.present(imagePicker, animated: true, completion: nil)

    }
    
    func openGallery() {
        self.selectedImages.removeAll()
         
        let imgPicker = ImagePickerController()
        imgPicker.settings.selection.max = 7
        imgPicker.settings.theme.selectionStyle = .numbered
        imgPicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imgPicker.settings.selection.unselectOnReachingMax = true
        let start = Date()
        self.presentImagePicker(imgPicker, select: { (asset) in
            print("Selected: \(asset)")
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
            
            
            
            for asset in assets{
                
                let retinaScale = UIScreen.main.scale
                let retinaSquare = CGSize(width: 100 * retinaScale, height: 100 * retinaScale)
                //let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
               
                
                let manager = PHImageManager.default()
                let options = PHImageRequestOptions()
                var thumbnail = UIImage()
                options.isSynchronous = true
                options.deliveryMode = .highQualityFormat
                options.resizeMode = .exact
                
                manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                })
                
                self.selectedImages.append(thumbnail)
                self.tempLayout.isHidden = false
            }
            self.isSelectedImage = true
            self.isFileSelected = false
            
            print("temp temp: \( self.selectedImages.count)")
            if(self.selectedImages.count > 0){
                self.tempImagePreview.image = self.selectedImages[0]
            }
            self.attachmentType = "image"
            self.tempImageCollectionView.reloadData()
//            let collection = self.addAlbumTableView.viewWithTag(723) as! UICollectionView
//            collection.reloadData()
            
        }, completion: {
            let finish = Date()
            print(finish.timeIntervalSince(start))
        })
        
    }
}
// MARK: - API Calls:
extension DiscussionMessagesViewController{

    func loadMessages(user: User, id: String, page: Int){
        Request.shared.loadMessages(user: user, id: id, page: page, colorList: self.answersColors, messagesList: self.messagesList){ (message, data, status) in
                if status == 200{
                    let discussionList = data
                    let countBefore = self.messagesList.count
                    for dis in discussionList{
                        if(!self.messagesList.contains(dis)){
                            self.messagesList.append(dis)
                        }
                    }
                    let countAfter = self.messagesList.count
                    
                    if(countBefore == countAfter){
                        self.counter += 1
                    }
                    if(discussionList.count < 5){
                        self.page = self.page - 1
                    }
                    self.canEdit = true
                    
                    self.messagesTableView.reloadData()
                }
//                else{
//                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                    App.showAlert(self, title: "ERROR1".localiz(), message: message ?? "", actions: [ok])
//                }
             
            }
        
//
        
    }
    
    func messageRecipient(user: User, id: String, colorList: [String], completion: @escaping ([Int]?, String?) -> Void){
            
            let indicatorView = App.loading()
            indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            indicatorView.tag = 110
            self.view.addSubview(indicatorView)
            
            Request.shared.messageRecipient(user: user, id: id, colorList: colorList){ (message, data, status) in
                    if status == 200{
                        self.userList = data
                        self.recipientNumber = "\(self.userList.count)"
                        print("recipientNumber: \(self.recipientNumber)")
                        self.recipients.text = "\(self.recipientNumber) members"
                        
                        let userIds = self.userList.map { $0.userId }
                        
                        completion(userIds, nil)
     
                    }
                    else{
                                            
                        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                        App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                        
                        completion(nil, message)
     
                    }
                 
                }
            if let viewWithTag = self.view.viewWithTag(110){
                               print("entered3")
                               viewWithTag.removeFromSuperview()
                       }
        }

    func loadCurrentMessages(user: User, id: String, page: Int){
        self.canEdit = false
      
        Request.shared.loadMessages(user: user, id: id, page: page, colorList: self.answersColors , messagesList: self.messagesList){ (message, data, status) in
            if status == 200{
                self.canEdit = true
                let discussionList = data
                for dis in discussionList{
                    if(!self.messagesList.contains(dis)){
                        self.messagesList.insert(dis, at: 0)
                    }
                }
                
                if(discussionList.count < 5){
                    self.page = self.page - 1
                }
                
                self.messagesTableView.reloadData()
            }
            else{
                self.canEdit = false
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            
        }
    }
    
    func sendMessage(user: User, messageThreadId: String, message: String, schoolInfo: SchoolActivation){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 108
        self.view.addSubview(indicatorView)

        Request.shared.sendMessage(user: user, message_thread_id: messageThreadId, message: message, schoolInfo: schoolInfo){ (message, data, status) in
            if status == 200{
                self.sendButton.isHidden = true
                self.recordButton.isHidden = false
                self.recordButtonHeight.constant = 32
                self.recordButtonWidth.constant = 24
                self.view.setNeedsUpdateConstraints()
                
                self.messageTextView.text = ""
                self.attachmentPicture.image = UIImage(named: "add-school")
                self.isFileSelected = false
                self.isSelectedImage = false
                self.counter = 0
                self.loadCurrentMessages(user: user, id: messageThreadId, page: 0)
                
                self.count = 0
                self.recordTimer.invalidate()
                self.rTimer.text = self.makeTimeString(minutes: 0, seconds: 0)
                self.finalRecording.isHidden = true
                self.recordingLayoutHeight.constant = 0
                self.attachmentPicture.isHidden = false
                
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
          if let viewWithTag = self.view.viewWithTag(108){
                             viewWithTag.removeFromSuperview()
                     }
            
        }
    }
    
    func sendMessageWithAttachment(user: User, messageThreadId: String, message: String, schoolInfo: SchoolActivation){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 109
        self.view.addSubview(indicatorView)

        Request.shared.sendMessageWithAttachment(user: user, id: messageThreadId, body: message, file: self.pdfURL, compressedFile: self.compressedDataToPass, image: selectedImage, isSelectedImage: isSelectedImage, filename: fName, schoolInfo: schoolInfo, type: self.attachmentType){ (message, data, status)  in
            if status == 200{
                self.sendButton.isHidden = true
                self.recordButton.isHidden = false
                self.recordButtonHeight.constant = 32
                self.recordButtonWidth.constant = 24
                
                self.view.setNeedsUpdateConstraints()
                self.counter = 0
                self.messageTextView.text = ""
                self.attachmentPicture.image = UIImage(named: "add-school")
                self.isFileSelected = false
                self.isSelectedImage = false
                self.loadCurrentMessages(user: user, id: messageThreadId, page: 0)
                self.count = 0
                self.recordTimer.invalidate()
                self.rTimer.text = self.makeTimeString(minutes: 0, seconds: 0)
                self.finalRecording.isHidden = true
                self.recordingLayoutHeight.constant = 0
                self.attachmentPicture.isHidden = false
                
                    
               
                
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
          if let viewWithTag = self.view.viewWithTag(109){
                             viewWithTag.removeFromSuperview()
                     }
            
        }
    }
    
    func sendMessageWithAttachment2(user: User, messageThreadId: String, images: UIImage, message: String){
        
        
        
            var msgText = "attachment\(self.imageIndex)"
            if(!message.isEmpty){
                msgText = message
            }
        Request.shared.sendMessageWithAttachment(user: user, id: messageThreadId, body: msgText, file: self.pdfURL, compressedFile: self.compressedDataToPass, image: images, isSelectedImage: isSelectedImage, filename: fName, schoolInfo: self.schoolInfo, type: self.attachmentType){ (message, data, status) in
                if status == 200{
                    self.imageIndex += 1
                    
                    if(self.imageIndex == self.selectedImages.count){
                        
                        if let viewWithTag = self.view.viewWithTag(115){
                                           viewWithTag.removeFromSuperview()
                                   }
                        
                        self.loadCurrentMessages(user: user, id: messageThreadId, page: 0)
                    }
                    else{
                        msgText = "attachment\(self.imageIndex)"

                        if(!self.tempMessagesText[self.imageIndex].isEmpty){
                            msgText = self.tempMessagesText[self.imageIndex]
                        }
                        self.sendMessageWithAttachment2(user: user, messageThreadId: self.messageThreadId, images: self.selectedImages[self.imageIndex], message: msgText)
                    }
                }
                else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                    
                    if let viewWithTag = self.view.viewWithTag(115){
                                       viewWithTag.removeFromSuperview()
                               }
                    
                }
        }

        
         
            
        
    }
    
}


class MyTapGestureDiscussion: UITapGestureRecognizer {
    var url = ""
    var index: IndexPath?
}
