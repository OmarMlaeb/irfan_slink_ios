//
//  NotificationsViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/2/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

protocol NotificationsViewControllerDelegate {
    func notificationPressed(moduleId: Int, date: String)
}

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var notificationArray: [Notifications] = []
    var user: User!
    var delegate: NotificationsViewControllerDelegate?
    var showSection = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {if(self.user.blocked){
        let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
        App.showAlert(self, title: "", message: "Your account has been blocked. Please contact your school".localiz(), actions: [ok])
    }
    else{
        getNotification(user: self.user, language: "")
        print("section", self.showSection)
    }
        
    }
    
    /// Description:
    /// - Initialize Navigation Bar title and color.
    func initNavigation(){
        self.navigationController?.navigationBar.barTintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationReuse")
        let icon = cell?.viewWithTag(1) as! UIImageView
        let titleLabel = cell?.viewWithTag(2) as! UILabel
        let descriptionLabel = cell?.viewWithTag(3) as! UILabel
        let dateLabel = cell?.viewWithTag(4) as! UILabel
        let markAsUnreadButton = cell?.viewWithTag(5) as! UIButton
        let bottomView: UIView? = cell?.viewWithTag(6)
        let bottomConstraint = descriptionLabel.constraints.filter({$0.identifier == "bottomConstraint"}).first
        let notification = notificationArray[indexPath.row]
        
        markAsUnreadButton.addTarget(self, action: #selector(markAsReadButtonPressed), for: .touchUpInside)
        titleLabel.text = notification.title
        descriptionLabel.text = notification.description
        dateLabel.text = notification.date
        if notification.read{
            icon.image = UIImage(named: "notification-off")
            markAsUnreadButton.isHidden = false
            titleLabel.textColor = App.hexStringToUIColorCst(hex: "#808285", alpha: 1.0)
            descriptionLabel.textColor = App.hexStringToUIColorCst(hex: "#808285", alpha: 1.0)
            bottomConstraint?.constant = 37
        }else{
            icon.image = UIImage(named: "notification-on")
            markAsUnreadButton.isHidden = true
            titleLabel.textColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
            descriptionLabel.textColor = App.hexStringToUIColorCst(hex: "#231f20", alpha: 1.0)
            bottomConstraint?.constant = 16
        }
        bottomView?.isHidden = false
        if indexPath.row == notificationArray.count - 1{
            bottomView?.isHidden = true
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    /// Description:
    /// - When select a notification, checkNotification function is called.
    /// - Call notificationPressed function in TabBar page in order to open a specific module.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.notificationArray[indexPath.row].read = true
        let date = self.notificationArray[indexPath.row].date
        let notificationId = self.notificationArray[indexPath.row].id
        checkNotification(user: self.user, id: notificationId)
        if(self.notificationArray[indexPath.row].section != 0){
            delegate?.notificationPressed(moduleId: self.notificationArray[indexPath.row].section, date: date)
        }
    }
    
    /// Description:
    /// - When mark as read button pressed, uncheckNotification function is called.
    @objc func markAsReadButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        self.notificationArray[indexPath!.row].read = false
        let notificationId = self.notificationArray[indexPath!.row].id
        uncheckNotification(user: self.user, id: notificationId)
    }

}

// API Calls:
extension NotificationsViewController{
    /// Description: Get Notifications
    ///
    /// - Parameters:
    ///   - user: Logged in selected user
    ///   - language: Current app language
    /// - This function is called to get the notifications data from "get_notifications" API for selected user and langage.
    func getNotification(user: User, language: String){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        /*
         static let NotiCalendar = 1
         static let NotiAttendance = 2
         static let NotiAgenda = 3
         static let NotiRemarks = 4
         static let NotiExamination = 5
         static let NotiInternalMessages = 6
         static let NotiFees = 7
         static let NotiBirthdays = 8
         */
        
        Request.shared.getNotifications(user: user, language: language) { (message, notificationData, status) in
            if status == 200{
                self.notificationArray = notificationData!
                var selectedId = 0
                switch self.showSection{
                    case "Calendar":
                        selectedId = 1
                        break
                    case "Attendance":
                        selectedId = 2
                        break
                    case "Agenda":
                        selectedId = 3
                        break
                    case "Remarks":
                        selectedId = 4
                        break
                    case "Grades":
                        selectedId = 5
                        break
                    case "Messages":
                        selectedId = 6
                        break
                    case "Blended":
                        selectedId = 15
                        break
                    default:
                        selectedId = 0
                        break;
                }
                if selectedId != 0{
                    self.notificationArray = self.notificationArray.filter{ $0.section == selectedId }
                }
                self.tableView.reloadData()
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    /// Description: Check Notifications
    /// - This function is called to send a request to "check_notification" API to mark a notification as read.
    func checkNotification(user: User, id: Int){
//        Request.shared.checkNotifications(user: user, notificationId: id) { (message, data, status) in
//            if status == 200{
//                self.tableView.reloadData()
//            }else{
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
//            }
//        }
    }
    
    
    /// Description: uncheck Notifications
    /// - This function is called to send a request to "uncheck_notification" API to mark a notification as unread.
    func uncheckNotification(user: User, id: Int){
        Request.shared.uncheckNotifications(user: user, notificationId: id) { (message, data, status) in
            if status == 200{
                self.tableView.reloadData()
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
}


// MARK: - TabBarToNotificationsDelegate:
extension NotificationsViewController: TabBarToNotificationsDelegate{
    
    func changeNotificationsModule(section: String){
        self.showSection = section
    }
    /// Description:
    /// - This function is called from TabBar page when user is changed to update user variable and notification array in this page.
    func changeNotificationsSettings(user: User) {
        self.user = user
        if self.tableView != nil{
            getNotification(user: self.user, language: "")
        }
    }
}
