//
//  NewMsssageViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 5/14/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit

class NewMsssageViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subjectTextField: TextField!
    @IBOutlet weak var messageTextView: TextView!
    @IBOutlet weak var attachView: UIView!
    @IBOutlet weak var attachTitleLabel: UILabel!
    @IBOutlet weak var attachSizeLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    var selectedUsers: [Student] = []
    var attachmentURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.dropCircleShadow()
        self.initNavBar()
        self.title = "New E-mail"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadAttachment()
    }
    
    func reloadAttachment(){
        guard let url = self.attachmentURL else{
            attachView.isHidden = true
            return
        }
        attachView.isHidden = false
        self.attachTitleLabel.text = url.lastPathComponent
        self.attachSizeLabel.text = App.fileSize(fromPath: url.path)
    }
    
    @IBAction func addUserButtonPressed(_ sender: Any){
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseUsersViewController") as! ChooseUsersViewController
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonPressed(_ sender: Any){
//        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.text"], in: UIDocumentPickerMode.import)
        let documentPicker = UIDocumentPickerViewController(documentTypes: [], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func removeAttachButtonPressed(_ sender: Any){
        self.attachmentURL = nil
        self.reloadAttachment()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any){
        
    }

}

// MARK: - UICollectionView Delegate and DataSource Functions:
extension NewMsssageViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        let xButton = cell.viewWithTag(2) as! UIButton
        let contact = self.selectedUsers[indexPath.row]
        imageView.image = UIImage(named: contact.photo)
        xButton.dropCircleShadow()
        xButton.addTarget(self, action: #selector(xButtonPressed), for: .touchUpInside)
        return cell
    }
    
    @objc func xButtonPressed(_ sender: UIButton){
        let cell = sender.superview?.superview as! UICollectionViewCell
        if let index = self.collectionView.indexPath(for: cell){
            self.selectedUsers.remove(at: index.row)
            self.collectionView.deleteItems(at: [index])
        }
    }
}

// MARK: - UICollectionView Delegate FlowLayout:
extension NewMsssageViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 46, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

// MARK: - UIDocumentPickerDelegate:
extension NewMsssageViewController: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == .import{
            print(url.lastPathComponent)
            self.attachmentURL = url
            self.reloadAttachment()
        }
    }
}

// MARK: - Handle Choose user delegate function:
extension NewMsssageViewController: ChooseUsersViewControllerDelegate{
    func selectedUsers(users: [Student]) {
        self.selectedUsers = users
        self.collectionView.reloadData()
    }
}
