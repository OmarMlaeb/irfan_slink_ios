//
//  AboutDiscussionUsersViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 10/14/20.
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
import MXParallaxHeader

class AboutDiscussionUsersViewController: UIViewController, UINavigationControllerDelegate{
    @IBOutlet weak var studentsTableView: UITableView!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupTitle: UILabel!
//    @IBOutlet weak var scrollView: UIScrollView!
    var headerView: UIView!
    let headerHeight: CGFloat = 250
    var userList: [User] = []
    var threadId: String = ""
    var titleG: String = ""
    var colorList: [String] = ["#6ebee9","#cb57a0","#46bc8c","#f2cf61","#ec7078","#bed964","#fcb25b","#f16822","#7a60ab","#e2db57","#1195aa","#4a74ba"]
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupTitle.text = titleG
        
        self.studentsTableView.dataSource = self
        self.studentsTableView.delegate = self
        headerView = self.studentsTableView.tableHeaderView
        self.studentsTableView.tableHeaderView = nil
        self.studentsTableView.addSubview(headerView)
        self.studentsTableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        self.studentsTableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
        
        self.groupImage.clipsToBounds = true
        self.groupImage.contentMode = .scaleToFill
        
        messageRecipient(user: user, id: threadId, colorList: colorList)
//        updateHeader()
        
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    //    func updateHeader(){
//        print(self.studentsTableView.contentOffset.y)
//        if(self.studentsTableView.contentOffset.y < self.headerHeight){
//            self.headerView.frame.origin.y = self.studentsTableView.contentOffset.y
//            self.headerView.frame.size.height = -self.studentsTableView.contentOffset.y
//
//        }
//    }
    
    
}

extension AboutDiscussionUsersViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentReuse")! as UITableViewCell
        
        let imageView = cell.viewWithTag(120) as! UIImageView
        let studentName = cell.viewWithTag(121) as! UILabel
        imageView.backgroundColor = App.hexStringToUIColor(hex: self.userList[indexPath.row].googleToken , alpha: 1.0)
        
        studentName.text = "\(self.userList[indexPath.row].firstName) \(self.userList[indexPath.row].lastName)"
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
          return 1
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    
}
extension AboutDiscussionUsersViewController: UITableViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.studentsTableView.contentOffset.y < self.headerHeight){
            self.headerView.frame.origin.y = self.studentsTableView.contentOffset.y
            self.headerView.frame.size.height = -self.studentsTableView.contentOffset.y
            
        }
       }
}

extension AboutDiscussionUsersViewController{
    
    func messageRecipient(user: User, id: String, colorList: [String]){
        
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 110
        self.view.addSubview(indicatorView)
        
        Request.shared.messageRecipient(user: user, id: id, colorList: colorList){ (message, data, status) in
                if status == 200{
                    self.userList = data
                    self.studentsTableView.reloadData()
                    
                }
                else{
                    let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                    App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                }
             
            }
        if let viewWithTag = self.view.viewWithTag(110){
                           print("entered3")
                           viewWithTag.removeFromSuperview()
                   }
    }
}


