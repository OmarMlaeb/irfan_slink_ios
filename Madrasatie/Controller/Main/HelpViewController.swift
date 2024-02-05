//
//  HelpViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/2/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageController: PageControl!
    
    var helpOverlayArray: [String] = []
    var teacherHome = ["teacher-home-guide"]
    var teacherCalendar = ["Teacher-Calendar-Guide-1", "Teacher-Calendar-Guide-2", "Teacher-Calendar-Guide-3"]
    var teacherAttendance = ["Teacher-Attendance-Guide"]
    var teacherAgenda = ["Teacher-Agenda-Guide-1", "Teacher-Agenda-Guide-2", "Teacher-Agenda-Guide-3"]
    var teacherRemarks = ["Teacher-Remarks-Guide-1", "Teacher-Remarks-Guide-2"]
    
    var studentHome = ["Student-Home-guide"]
    var studentCalendar = ["Student-Calendar-guide-1", "Student-Calendar-guide-2"]
    var studentAttendance = ["Student-Attendance-guide-1", "Student-Attendance-guide-2", "Student-Attendance-guide-3", "Student-Attendance-guide-4"]
    var studentAgenda = ["Student-Agenda-guide-1", "Student-Agenda-guide-2"]
    var studentRemarks = ["Student-Remarks-guide-1"]
    var studentGrades = ["Student-Grades-guide-1", "Student-Grades-guide-2"]
    var studentTimeTable = ["Student-TimeTable-guide-1", "Student-TimeTable-guide-2"]
    
    var parentHome = ["Parent-Home-Guide"]
    var parentCalendar = ["Parent-Calendar-Guide-1", "Parent-Calendar-Guide-2"]
    var parentAttendance = ["Parent-Attendance-Guide-1", "Parent-Attendance-Guide-2", "Parent-Attendance-Guide-3", "Parent-Attendance-Guide-4"]
    var parentAgenda = ["Parent-Agenda-Guide-1", "Parent-Agenda-Guide-2"]
    var parentRemarks = ["Parent-Remarks-Guide-1"]
    var parentGrades = ["Parent-Grades-Guide-1", "Parent-Grades-Guide-2"]
    var parentTimeTable = ["Parent-TimeTable-Guide-1", "Parent-TimeTable-Guide-2"]
    
    var userType = 0
    var moduleID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        helpOverlayArray = []
        switch userType{
        case 2:
            switch moduleID{
            case 0:
                helpOverlayArray = teacherHome
            case 1:
                helpOverlayArray = teacherCalendar
            case 2:
                helpOverlayArray = teacherAttendance
            case 3:
                helpOverlayArray = teacherAgenda
            case 4:
                helpOverlayArray = teacherRemarks
//            case 5:
                //Grades
//            case 6:
                //TimeTable
            default:
                break
            }
        case 3:
            switch moduleID{
            case 0:
                helpOverlayArray = studentHome
            case 1:
                helpOverlayArray = studentCalendar
            case 2:
                helpOverlayArray = studentAttendance
            case 3:
                helpOverlayArray = studentAgenda
            case 4:
                helpOverlayArray = studentRemarks
            case 5:
                helpOverlayArray = studentGrades
            case 6:
                helpOverlayArray = studentTimeTable
            default:
                break
            }
        case 4:
            switch moduleID{
            case 0:
                helpOverlayArray = parentHome
            case 1:
                helpOverlayArray = parentCalendar
            case 2:
                helpOverlayArray = parentAttendance
            case 3:
                helpOverlayArray = parentAgenda
            case 4:
                helpOverlayArray = parentRemarks
            case 5:
                helpOverlayArray = parentGrades
            case 6:
                helpOverlayArray = parentTimeTable
            default:
                break
            }
        default:
            break
        }
        pageController.numberOfPages = helpOverlayArray.count
        collectionView.setContentOffset(.zero, animated: false)
        self.collectionView.reloadData()
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource:
extension HelpViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return helpOverlayArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
//        let scrollView = cell.viewWithTag(1) as! UIScrollView
        let imageView = cell.viewWithTag(2) as! UIImageView
        let imageViewHeight = imageView.constraints.filter({$0.identifier == "imageViewHeight"}).first
        if let image = UIImage(named: helpOverlayArray[indexPath.row]){
            imageView.image = image
            /// Calculate UIImage Ratio to prevent UIImage from streching inside imageView:
            let ratio = image.size.height / image.size.width
            imageViewHeight?.constant = imageView.bounds.width * ratio
            cell.layoutIfNeeded()
        }else{
            imageView.image = nil
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout:
extension HelpViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

// MARK: - UIScrollViewDelegate:
extension HelpViewController: UIScrollViewDelegate{
    
    /// Description:
    /// - This function is used to update pageController selected index when swipe to the next or previous collection item.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView {
            let total = scrollView.contentSize.width - scrollView.bounds.width
            let offset = scrollView.contentOffset.x
            let percent = Double(offset / total)
            
            let progress = percent * Double(self.helpOverlayArray.count - 1)
            
            pageController.progress = progress
        }
    }
}

// MARK: - TabBarToHelpDelegate:
extension HelpViewController: TabBarToHelpDelegate{
    
    /// Description:
    ///
    /// - Parameters:
    ///   - moduleID: Active Module ID
    ///   - userType: Current user Type
    /// - This function is called from TabBar when changing user or open a new module or close module page.
    /// - It will update the needed variable in this page in order to show the correct help overlay.
    func updateActiveModule(moduleID: Int, userType: Int) {
        self.moduleID = moduleID
        self.userType = userType
    }
}
