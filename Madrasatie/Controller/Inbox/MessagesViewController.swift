//
//  MessagesViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/2/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import ActiveLabel

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var user: User!
    @IBOutlet weak var noMessagesLabel: UILabel!
    var messagesArray: [Inbox] = []
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    var refreshControl = UIRefreshControl()
    static var didLoadMessages = false
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")

    fileprivate lazy var dateTimeFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy hh:mm a"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter
    }()
    
    fileprivate lazy var dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localiz())
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh() {
        print("entered messages")
       // Code to refresh table view
        MessagesViewController.didLoadMessages = false
        self.getMessages()
    }
    
    func getMessages(){
//        if MessagesViewController.didLoadMessages == true{
//            return
//        }
        //add indicator view first time only
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.getMessages(user: self.user) { (message, messagesData, status) in
            if status == 200{
                self.messagesArray = messagesData!
                self.messagesArray.sort { (self.dateTimeFormatter.date(from: $0.date) ?? Date()) > (self.dateTimeFormatter.date(from: $1.date) ?? Date()) }

                if messagesData?.count != 0{
                    self.noMessagesLabel.isHidden = true
                }
                self.tableView.reloadData()
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
            self.refreshControl.endRefreshing()
            MessagesViewController.didLoadMessages = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barTintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        self.title = "Inbox".localiz()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        
        if(user.userType == 1 || user.userType == 2 || user.userType == 4){
            let leftButton: UIButton = UIButton(type: UIButton.ButtonType.custom)
            leftButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40) ;
            leftButton.setTitle("New Message", for: .normal)
            leftButton.addTarget(self, action: #selector(newMessageClick), for: UIControl.Event.touchUpInside)
            leftButton.isHidden = true
            let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: leftButton)
            
            self.navigationItem.setRightBarButton(leftBarButtonItem, animated: false);
        }
        

//        self.navigationController?.navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(self.user.blocked){
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "", message: "Your account has been blocked. Please contact your school".localiz(), actions: [ok])
            
        }
        else{
            print("entered messages1")
            self.getMessages()
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func convertUTCStringToLocalTime(utcString: String) -> Date? {
        guard let utcDate = dateTimeFormatter.date(from: utcString) else {
            return nil
        }

        let localTimeZone = TimeZone(identifier: "Asia/Beirut")
        let localDate = utcDate.addingTimeInterval(TimeInterval(localTimeZone?.secondsFromGMT(for: utcDate) ?? 0))

        return localDate
    }
}

// MARK: - UITableView Delegate and DataSource Functions:
extension MessagesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell")
        let view = cell?.viewWithTag(742) as! UIView
        let nameLabel = cell?.viewWithTag(2) as! UILabel
        let dateLabel = cell?.viewWithTag(3) as! UILabel
        let subjectLabel = cell?.viewWithTag(4) as! UILabel
        let messageLabel = cell?.viewWithTag(5) as! ActiveLabel
        let icon = cell?.viewWithTag(1034) as! UIImageView
        let unreadMessagesNumber = cell?.viewWithTag(1122) as! UILabel
        unreadMessagesNumber.layer.cornerRadius = unreadMessagesNumber.frame.width / 2
        unreadMessagesNumber.clipsToBounds = true
    
        // Adjust the number of lines and set the text alignment
        unreadMessagesNumber.numberOfLines = 1 // Set to 0 for multiline, adjust as needed
        unreadMessagesNumber.textAlignment = .center
        
        
        let broadcast_icon = cell?.viewWithTag(33) as! UIImageView
        
//        let downloadAttachment = cell?.viewWithTag(7) as! UIButton
        let inbox = messagesArray[indexPath.row]
        if(inbox.canReply == false){
            broadcast_icon.isHidden = false
        }
        else{
            broadcast_icon.isHidden = true
        }
        if(inbox.unreadMessages > 0){
            unreadMessagesNumber.isHidden = false
            unreadMessagesNumber.text = "\(inbox.unreadMessages)"
        }
        else{
            unreadMessagesNumber.isHidden = true

        }

        icon.sd_setImage(with: URL(string: inbox.attachment_link), placeholderImage: UIImage(named: "teacher_boy"))

        
        
        
//        downloadAttachment.addTarget(self, action: #selector(downloadButtonPressed), for: .touchUpInside)
//        if inbox.attachment_link != ""{
//            downloadAttachment.isHidden = false
//        }else{
//            downloadAttachment.isHidden = true
//        }
        nameLabel.text = inbox.creator_name
        //format date
        let date = self.convertUTCStringToLocalTime(utcString: inbox.date)
        let dateFormatted = self.dateTimeFormatter1.string(from: date ?? Date())
        dateLabel.text = dateFormatted
        subjectLabel.text = inbox.subject
        
        messageLabel.enabledTypes = [.mention, .hashtag, .url]
        messageLabel.text = inbox.message
        messageLabel.sizeToFit()
        messageLabel.numberOfLines = 0
        messageLabel.handleURLTap{ url in
//            let urlfixed = url.absoluteString.replacingOccurrences(of: " ", with: "%20")
            guard let safari = URL(string: url.absoluteString) else { return }
            UIApplication.shared.open(safari)
        }
        return cell!
    }
    
    @objc func newMessageClick(sender: UIButton){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "NewMessageViewController") as! NewMessageViewController
        studentVC.user = self.user
        studentVC.modalPresentationStyle = .fullScreen
        self.present(studentVC, animated: true, completion: nil)
    }
    @objc func downloadButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            var message: Inbox!
            message = messagesArray[indexPath.row]
            
            if(message.attachment_link != ""){
                var url = message.attachment_link
            
                
//                let urlfixed = url.replacingOccurrences(of: " ", with: "%20")
                guard let safari = URL(string: url) else { return }
                UIApplication.shared.open(safari)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row clicked")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentVC = storyboard.instantiateViewController(withIdentifier: "DiscussionMessagesViewController") as! DiscussionMessagesViewController
        studentVC.user = self.user
        studentVC.type = "message"
        studentVC.groupName = self.messagesArray[indexPath.row].subject
        studentVC.messageThreadId = String(self.messagesArray[indexPath.row].id)
        studentVC.conversation = self.messagesArray[indexPath.row]
        studentVC.creatorId = self.messagesArray[indexPath.row].creator_id
        
        studentVC.modalPresentationStyle = .fullScreen
        self.present(studentVC, animated: true, completion: nil)
        
    }
    
}

extension MessagesViewController: TabBarToMessagesDelegate{
    
    /// Description:
    /// - This function is called from TabBar page when user is changed to update user variable
    func changeMessagesSettings(user: User) {
        print("messages entered")
        self.user = user
    }
}

extension MessagesViewController: MessageViewControllerDelegate{
    func refreshMessages() {
        self.getMessages();
    }
    
    
}
