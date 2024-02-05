////
////  ConversationViewController.swift
////  Madrasatie
////
////  Created by hisham noureddine on 5/13/19.
////  Copyright © 2019 Hisham Noureddine. All rights reserved.
////
//
//import UIKit
//
//class ConversationViewController: UIViewController {
//
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var menuTableView: UITableView!
//
//    var messagesArray: [Inbox] = [
//        Inbox(id: 1, name: "James Doe", date: Date(), subject: "Greetings", message: "Hi Janive, how are you hope everything is going Lorem ipsum dolor sit amet, consectetuer adipiscing ipsum dolor sit amet,\n\nRegards,", isReaded: false),
//        Inbox(id: 2, name: "James Doe", date: Date(), subject: "Exams", message: "Hi Janive, how are you hope everything is going Lorem ipsum dolor sit amet, consectetuer adipiscing ipsum dolor sit amet,\n\nRegards,", isReaded: true)
//    ]
//    var menuArray: [MenuItem] = [
//        MenuItem(id: 1, name: "Reply", value: 0, isSelected: false),
//        MenuItem(id: 2, name: "Forword", value: 0, isSelected: false)
//    ]
//
//    fileprivate lazy var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd MMMM yyyy"
//        return formatter
//    }()
//
//    fileprivate lazy var timeFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "hh:mm a"
//        return formatter
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.setMessageMenu()
//        self.initNavBar()
//        self.setMailNavigation(with: "You & James Doe")
//    }
//
//    override func optionButtonPressed(_ sender: UIButton) {
//        if menuTableView.isHidden{
//            menuTableView.isHidden = false
//            menuTableView.alpha = 0
//            UIView.animate(withDuration: 0.3) {
//                self.menuTableView.alpha = 1
//            }
//        }else{
//            UIView.animate(withDuration: 0.3, animations: {
//                self.menuTableView.alpha = 0
//            }) { (succes) in
//                self.menuTableView.isHidden = true
//            }
//        }
//    }
//
//}
//
//// MARK: - UITableView Delegate and DataSource:
//extension ConversationViewController: UITableViewDelegate, UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch tableView{
//        case self.tableView:
//            return messagesArray.count
//        default:
//            return menuArray.count
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch tableView{
//        case self.tableView:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell")
//            let iconImageView = cell?.viewWithTag(1) as! UIImageView
//            let nameLabel = cell?.viewWithTag(2) as! UILabel
//            let dateLabel = cell?.viewWithTag(3) as! UILabel
//            let subjectLabel = cell?.viewWithTag(4) as! UILabel
//            let messageLabel = cell?.viewWithTag(5) as! UILabel
//            let inbox = messagesArray[indexPath.row]
//
//            if inbox.isReaded{
//                iconImageView.isHidden = true
//                iconImageView.image = UIImage(named: "read-message")
//                nameLabel.textColor = .black
//            }else{
//                iconImageView.image = UIImage(named: "unread-message")
//                nameLabel.textColor = App.hexStringToUIColor(hex: "#568ef6", alpha: 1.0)
//                iconImageView.isHidden = false
//            }
//            nameLabel.text = inbox.name
//            dateLabel.text = "\(self.dateFormatter.string(from: inbox.date)) at \(self.timeFormatter.string(from: inbox.date))"
//            subjectLabel.text = inbox.subject
//            messageLabel.text = inbox.message
//            return cell!
//        default:
//            let cell = menuTableView.dequeueReusableCell(withIdentifier: "menuCell")
//            let titleLabel = cell?.viewWithTag(1) as! UILabel
//            let tickImageView = cell?.viewWithTag(2) as! UIImageView
//            tickImageView.isHidden = true
//
//            let item = menuArray[indexPath.row]
//            titleLabel.text = item.name
//            if item.isSelected{
//                titleLabel.textColor = App.hexStringToUIColor(hex: "#568ef6", alpha: 1.0)
//            }else{
//                titleLabel.textColor = App.hexStringToUIColor(hex: "#5D5D5D", alpha: 1.0)
//            }
//            return cell!
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch tableView{
//        case self.tableView:
//            return UITableView.automaticDimension
//        default:
//            return 32
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch tableView{
//        case self.menuTableView:
//            self.menuArray.forEach({$0.isSelected = false})
//            self.menuArray[indexPath.row].isSelected = true
//            self.menuTableView.reloadData()
//        default:
//            break
//        }
//    }
//
//}
