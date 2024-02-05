//
//  SubmissionDetailsViewController.swift
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


class SubmissionDetailsViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate{
    
    @IBOutlet weak var studentProfile: UIImageView!
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var score: UITextField!
    @IBOutlet weak var answerDescription: UITextView!
    @IBOutlet weak var addMarkText: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var attachmentsCollectionView: UICollectionView!
    @IBOutlet weak var estimationTimeLabel: UILabel!
    @IBOutlet weak var actualTimeLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var fullMarkLabel: UILabel!
    
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var fullMarkLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var answerDescriptionConstraint: NSLayoutConstraint!
    var studentsList: [StudentRepliesModel] = []
    var index: Int = -1
    var user: User!
    var asst: AgendaDetail?
    var fullMark: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("students submission: \(studentsList)")
        print("index: \(index)")
        
        studentProfile.image = UIImage(named: "student_boy")
        
        attachmentsCollectionView.delegate = self
        attachmentsCollectionView.dataSource = self
        attachmentsCollectionView.reloadData()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // or .vertical, depending on your design
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // Adjust the left inset as needed
        attachmentsCollectionView.collectionViewLayout = layout
        
        if(self.asst?.enableGrading == false){
            self.addMarkText.isHidden = true
            self.score.isHidden = true
            self.updateButton.isHidden = true
        }
        else{
            self.addMarkText.isHidden = false
            self.score.isHidden = false
            self.updateButton.isHidden = false
            self.fullMarkLabel.text = "/ " + fullMark
        }
        
        if(index != -1){
            self.studentName.text = studentsList[index].studentName
            self.answerDescription.text = studentsList[index].text
            if(self.user.userType == 1 || self.user.userType == 2){
                self.estimationTimeLabel.text = "Estimation Time: \(self.studentsList[index].assignmentEstimatedTime)"
                self.actualTimeLabel.text = "Actual Time: \(self.studentsList[index].actualTime)"
            } else {
                self.estimationTimeLabel.isHidden = true
                self.actualTimeLabel.isHidden = true
                self.lineView.isHidden = true
                self.answerDescriptionConstraint.constant = 8
            }
//            if(self.studentsList[index].mark != nil){
//                self.score.text = self.studentsList[index].mark
//
//            }
            
            if(self.user.userType != 1 && self.user.userType != 2){
                addMarkText.text = "Mark: "
                score.isUserInteractionEnabled = false
                self.score.isHidden = true
                updateButton.isHidden = true
                print("mark mark: \(self.studentsList[index].mark)")

                if(self.studentsList[index].mark != nil && self.studentsList[index].mark != ""){
                    print("entered mark1")
                    print(self.studentsList[index].mark)
                    self.markLabel.text = self.studentsList[index].mark
                    self.fullMarkLeftConstraint.constant = 50
                }
                else{
                    print("entered mark2")
//                    self.score.placeholder = "Not Graded"
//                    self.score.text = ""
                    self.markLabel.text = "Not Graded"
                    self.fullMarkLabel.isHidden = true
                }
                self.studentName.text = "\(self.user.firstName) \(self.user.lastName)"

            }
            else{
                if(self.studentsList[index].mark != nil && self.studentsList[index].mark != ""){
                    print("entered mark1")
                    print(self.studentsList[index].mark)
                    self.score.isHidden = true
                    self.markLabel.text = self.studentsList[index].mark
                    self.updateButton.isHidden = true
                    self.fullMarkLeftConstraint.constant = 50
                    self.view.layoutIfNeeded()
                    
                } else{
                    self.markLabel.isHidden = true
                }
               
            }
            
        }
     
        
    }
    @objc func openImage(_ sender: UITapGestureRecognizer){
        print("sender: \(sender.view)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController

        var att: [String] = []
        
        for attachment in self.studentsList[index].attachments{
            att.append(attachment.url)
        }
        
        vc.imgArray = att
//        vc.passedContentOffset = indexPath
        vc.modalPresentationStyle = .fullScreen


 
           self.show(vc, sender: self)
    }

    
    
    @IBAction func onPreviousSubmission(_ sender: UIButton) {
        if(self.index > 0){
            self.index = self.index - 1
            if(self.user.userType == 1 || self.user.userType == 2){
                self.studentName.text = studentsList[index].studentName
                self.estimationTimeLabel.text = "Estimation Time: \(self.studentsList[index].assignmentEstimatedTime)"
                self.actualTimeLabel.text = "Actual Time: \(self.studentsList[index].actualTime)"
            }
            self.answerDescription.text = studentsList[index].text
            if(self.studentsList[index].mark != nil && self.studentsList[index].mark != ""){
                self.score.isHidden = true
                self.markLabel.isHidden = false
                self.markLabel.text = self.studentsList[index].mark
                self.updateButton.isHidden = true
                self.fullMarkLeftConstraint.constant = 50

            } else{
                if(self.user.userType == 1 || self.user.userType == 2){
                    self.markLabel.isHidden = true
                    self.score.isHidden = false
                    self.updateButton.isHidden = false
                    self.fullMarkLeftConstraint.constant = 115
                }else{
                    self.markLabel.isHidden = false
                    self.markLabel.text = "Not Graded"
                    self.fullMarkLabel.isHidden = true
                }
            }
            self.attachmentsCollectionView.reloadData()
        }
    }
    
    @IBAction func onNextSubmission(_ sender: Any) {
        if(self.index < self.studentsList.count - 1){
            self.index = self.index + 1
            if(self.user.userType == 1 || self.user.userType == 2){
                self.studentName.text = studentsList[index].studentName
                self.estimationTimeLabel.text = "Estimation Time: \(self.studentsList[index].assignmentEstimatedTime)"
                self.actualTimeLabel.text = "Actual Time: \(self.studentsList[index].actualTime)"
            }
            self.answerDescription.text = studentsList[index].text
            if(self.studentsList[index].mark != nil && self.studentsList[index].mark != ""){
                self.score.isHidden = true
                self.markLabel.isHidden = false
                self.markLabel.text = self.studentsList[index].mark
                self.updateButton.isHidden = true
                self.fullMarkLeftConstraint.constant = 50

            } else{
                if(self.user.userType == 1 || self.user.userType == 2){
                    self.markLabel.isHidden = true
                    self.score.isHidden = false
                    self.updateButton.isHidden = false
                    self.fullMarkLeftConstraint.constant = 115
                } else{
                    self.markLabel.isHidden = false
                    self.markLabel.text = "Not Graded"
                    self.fullMarkLabel.isHidden = true
                }
            }
            self.attachmentsCollectionView.reloadData()

        }
    }
    
    @IBAction func updateMark(_ sender: UIButton) {
        
        if(self.fullMark >= self.score.text ?? ""){
            self.gradeAssignment(user: self.user, mark: self.score.text ?? "0", assignedStudentId: self.studentsList[index].assignedStudentId)
        } else{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Alert".localiz(), message: "Mark can't be greater than Full Mark.", actions: [ok])
        }
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true)

    }
    
    @objc override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func viewDocument(url: String, index: IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "OpenAttachmentViewController") as! OpenAttachmentViewController
        studentVC.linkText = url
        studentVC.attachmentName = self.studentsList[index.row].attachments[index.item].filename
        studentVC.attachmentType = self.studentsList[index.row].attachments[index.item].type
        studentVC.modalPresentationStyle = .fullScreen
        self.present(studentVC, animated: true, completion: nil)
    }
    
}

extension SubmissionDetailsViewController{
    /// Description: AddDiscussion
    /// - Call "add_discussion" to add a discussion
    func gradeAssignment(user: User, mark: String, assignedStudentId: String){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        //
        Request.shared.gradeAssignment(user: user, mark: mark, assignedStudentId: assignedStudentId){ (message, data, status) in
            if status == 200{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Success".localiz(), message: "Mark Updated!", actions: [ok])
                
                self.studentsList[self.index].mark = mark
                
                if self.index != -1 {
                    // Update marks for students with the same name after the current index
                    var new_index1 = self.index
                    while new_index1 <= self.studentsList.count - 1{
                        if(self.studentsList.count - 1 == new_index1){
                            self.studentsList[new_index1].mark = mark
                            break
                        } else{
                            if self.studentsList[new_index1].studentName != self.studentsList[new_index1 + 1].studentName {
                                break
                            }
                        }
                        
                        self.studentsList[new_index1].mark = mark
                        new_index1 += 1
                    }
                    
                    

                    // Update marks for students with the same name including the current index
                    var new_index2 = self.index
                    while new_index2 >= 0 {
                        if(new_index2 > 0){
                            if self.studentsList[new_index2].studentName != self.studentsList[new_index2 - 1].studentName {
                                if(new_index2 >= 0){
                                    self.studentsList[new_index2].mark = mark
                                }
                                break
                            }
                        }
                        
                        self.studentsList[new_index2].mark = mark
                        new_index2 -= 1
                    }
                }
                                
                self.score.isHidden = true
                self.markLabel.isHidden = false
                self.markLabel.text = mark
                self.updateButton.isHidden = true
                self.fullMarkLeftConstraint.constant = 50
                self.view.layoutIfNeeded()
              
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
}

extension SubmissionDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func getMimeTypeSync(for url: URL) -> String? {
        let request = URLRequest(url: url)
        var mimeType: String?

        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            defer {
                semaphore.signal()
            }

            if let httpResponse = response as? HTTPURLResponse {
                mimeType = httpResponse.mimeType
            }
        }
        
        task.resume()
        semaphore.wait()

        return mimeType
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageReuse", for: indexPath)
        let image = cell.viewWithTag(13) as! UIImageView
        print("url url: \(self.studentsList[self.index].attachments[indexPath.row])")
        
      
        
        image.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
      
        let img =  self.studentsList[self.index].attachments[indexPath.row].url
        
        if(img.count > 0 && img.contains(".")){
            let split = img.split(separator: ".")
            let type = split[split.count - 1]
            if(type == "pdf"){
                image.image = UIImage(named: "pdf_logo")
            }
            else if(type == "docx" || type == "doc"){
                image.image = UIImage(named: "word_logo")
            }
            else if(type == "xlsx"){
                image.image = UIImage(named: "excel_logo")
            }
            else if(type == "pptx" || type == "ppsx" || type == "ppt"){
                image.image = UIImage(named: "powerpoint")
            }
            else if(type == "m4a" || type == "flac" || type == "mp3" || type == "mp4" || type == "wav"
                    || type == "wma" || type == "aac"){
                image.image = UIImage(named: "audio")
            }
            else if(type == "png" || type == "jpg" || type == "jpeg"){
                
                image.sd_setImage(with: URL(string: img), completed: { (img, error, cacheType, imageUrl) in
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
            }
        }
        
        image.layer.cornerRadius = 20 // Adjust the value as needed
        image.clipsToBounds = true
        
  
        
//        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openImage(_:)))
//        image.isUserInteractionEnabled = true
//
//        image.addGestureRecognizer(gestureRecognizer)
        
        
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItemIndex = indexPath.item
        print("Selected item index: \(selectedItemIndex)")
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController

        var att: [String] = []
        
        for attachment in self.studentsList[index].attachments{
            att.append(attachment.url)
        }
        
        vc.imgArray = att
        vc.passedContentOffset = indexPath
        vc.modalPresentationStyle = .fullScreen
        
        self.viewDocument(url: self.studentsList[index].attachments[selectedItemIndex].url, index: indexPath)
        


 
           self.show(vc, sender: self)
        
        // You can use the selected item index for further actions or to access your data source.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 100   , height:  100  )
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.studentsList[self.index].attachments.count
    }
    
    
    
    
}
