//
//  TeamsViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 6/9/20.
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

protocol TeamsViewControllerDelegate {
    func teamsPressed(calendarType: CalendarStyle?)
}

class TeamsViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var teamsMeetingsTableView: UITableView!
    var teamsDelegate: TeamsViewControllerDelegate?
    var user: User!
    var teamsMeetingsList = [TeamsMeetingModel(id:"1", meetingTitle: "study1", teacherName: "maher Kouzaei jaber", date: "06-06-2020 10:10:10 am", teacherPic: "pic"),
                             TeamsMeetingModel(id:"2", meetingTitle: "study1", teacherName: "maher Kouzaei jaber", date: "06-06-2020 10:10:10 am", teacherPic: "pic"),
                            TeamsMeetingModel(id:"3", meetingTitle: "study1", teacherName: "maher jaber", date: "06-06-2020 10:10:10 am", teacherPic: "pic"),
    TeamsMeetingModel(id:"4", meetingTitle: "study1", teacherName: "maher jaber", date: "06-06-2020 10:10:10 am", teacherPic: "pic")]
    var calendarStyle: CalendarStyle? = .week
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    var startDate = ""
    var endDate = ""
    var tempCalendarStyle: CalendarStyle?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidloadd")
        teamsMeetingsTableView.dataSource = self
        teamsMeetingsTableView.delegate = self
        calendarStyle = .week
         tempCalendarStyle = .week
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            if let calendarView = self.teamsMeetingsTableView.viewWithTag(4) as? FSCalendar{
                let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
                let monthLabel = self.teamsMeetingsTableView.viewWithTag(3) as! UILabel
                
                //set month label
                var currentCalendar = Calendar.current
                currentCalendar.locale = Locale(identifier: "\(self.languageId)")
                let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.currentPage)
                let stringMonth = currentCalendar.monthSymbols[values.month! - 1]
                
                if Locale.current.languageCode == "hy" {
                    monthLabel.text = "\(App.getArmenianMonth(month: values.month!)) \(values.year!)"
                }else{
                    monthLabel.text = "\(stringMonth) \(values.year!)"
                }
                        
                if self.calendarStyle == .week{
                    calendarView.setScope(.week, animated: false)
                    calendarHeight?.constant = 90
                }else{
                    calendarView.setScope(.month, animated: false)
                }
                self.teamsMeetingsTableView.reloadData()
                
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.calendarStyle = .week
        self.tempCalendarStyle = .week
        teamsDelegate?.teamsPressed(calendarType: self.calendarStyle)
        
    }
    /// Description
       /// - Show next month/week dates inside FSCalendar.
       @objc func calendarNextButtonPressed(sender: UIButton){
        guard let calendarView = self.teamsMeetingsTableView.viewWithTag(4) as? FSCalendar else{
               return
           }
           let calendar = Calendar.current
           var dateComponents = DateComponents()
           if calendarView.scope == .month{
               dateComponents.month = 1
           }else{
               dateComponents.weekOfMonth = 1
           }
           let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage)
           calendarView.setCurrentPage(currentCalendarPage!, animated: true)
       }
    @objc func calendarBackButtonPressed(sender: UIButton){
        guard let calendarView = self.teamsMeetingsTableView.viewWithTag(4) as? FSCalendar else{
            return
        }
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        if calendarView.scope == .month{
            dateComponents.month = -1 // For prev button
        }else{
            dateComponents.weekOfMonth = -1
        }
        let currentCalendarPage = calendar.date(byAdding: dateComponents, to: calendarView.currentPage)
        calendarView.setCurrentPage(currentCalendarPage!, animated: true)
    }
}
extension TeamsViewController: SectionVCToTeamsDelegate{
    func switchTeamsChildren(user: User, batchId: Int?, children: Children?) {
        self.user = user
        //self.getAlbums(user: self.user)
    }
    
    func teamsFilterSectionView(type: Int) {
        guard let calendarView = self.teamsMeetingsTableView.viewWithTag(4) as? FSCalendar else{
                  return
              }
               let calendarHeight = calendarView.constraints.filter({$0.identifier == "calendarHeight"}).first
        let monthLabel = self.teamsMeetingsTableView.viewWithTag(3) as! UILabel
               self.startDate = "01-09-1900"
               self.endDate = "30-09-2500"
               switch type{
               //Monthly View:
               case 0:
                   self.calendarStyle = .month
                   self.tempCalendarStyle = .month
                   calendarView.setScope(.month, animated: true)
                   calendarHeight?.constant = 250
               //Weekly View:
               case 1:
                   self.calendarStyle = .week
                   self.tempCalendarStyle = .week
                   calendarView.setScope(.week, animated: true)
                   calendarHeight?.constant = 90
                   monthLabel.text = "\n"
               //Yearly View:
               case 2:
                   calendarView.setScope(.month, animated: true)
                   self.calendarStyle = .month
                   let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: calendarView.today ?? Date())
                   let month = values.month
                   let year = values.year
                   if month! > 10{
                       self.startDate = "01-09-\(year!)"
                       self.endDate = "30-09-\(year!+1)"
                   }else{
                       self.startDate = "01-09-\(year!-1)"
                       self.endDate = "30-09-\(year!)"
                   }
                   calendarHeight?.constant = 250
               default:
                   break
               }
               SectionVC.didLoadAgenda = false
               //self.getAgendaData()
    }
}

extension TeamsViewController: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Microsoft Teams", counter: "", image: UIImage(named: "teamsIcon"),
                             backgroundViewColor: App.hexStringToUIColorCst(hex: "#acb3db", alpha: 1.0), id: App.teamsId)
    }
    
}
extension TeamsViewController:  UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
           
           // #warning Incomplete implementation, return the number of sections
           return 2
       }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return 1
        case 1:
            return teamsMeetingsList.count
        default:
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView,
            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section){
        case 0:
            let calendarCell = tableView.dequeueReusableCell(withIdentifier: "calendarReuse")
                        let calendarBackButton = calendarCell?.viewWithTag(1) as! UIButton
                        let calendarNextButton = calendarCell?.viewWithTag(6) as! UIButton
            //            let monthLabel = calendarCell?.viewWithTag(3) as! UILabel
                        guard let calendarView: FSCalendar = calendarCell?.viewWithTag(4) as? FSCalendar else{
                            return UITableViewCell()
                        }
                        let bottomShadowView: UIView? = calendarCell?.viewWithTag(7)
                        let calendarNextImageView = calendarCell?.viewWithTag(61) as! UIImageView
                        let calendarBackImageView = calendarCell?.viewWithTag(99) as! UIImageView
                        
                        calendarBackButton.dropCircleShadow()
                        calendarBackButton.addTarget(self, action: #selector(calendarBackButtonPressed), for: .touchUpInside)
                        calendarNextButton.dropCircleShadow()
                        calendarNextButton.addTarget(self, action: #selector(calendarNextButtonPressed), for: .touchUpInside)
                        if self.languageId.description == "ar"{
                            calendarNextImageView.image = UIImage(named: "calendar-left-arrow")
                            calendarBackImageView.image = UIImage(named: "calendar-right-arrow")
                        }else{
                            calendarNextImageView.image = UIImage(named: "calendar-right-arrow")
                            calendarBackImageView.image = UIImage(named: "calendar-left-arrow")
                        }
            //            calendarView.bottomBorder.isHidden = true
                        calendarView.calendarWeekdayView.addBorders(edges: .bottom)
                        calendarView.delegate = self
                        calendarView.dataSource = self
                        calendarView.locale = Locale(identifier: "\(self.languageId)")
                        calendarView.calendarHeaderView.calendar.locale = Locale(identifier: "\(self.languageId)")
                        calendarView.register(DIYCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
                        calendarView.reloadData()
                        
                        bottomShadowView?.dropTopShadow()
                        calendarCell?.selectionStyle = .none
                        return calendarCell!
        case 1:
            print("microsoft teams entered")
            let cell = tableView.dequeueReusableCell(withIdentifier:
                "teamsMeetingsReuse")as!TeamsMeetingsCell
            cell.meetingTitle.text = self.teamsMeetingsList[indexPath.item].meetingTitle
            cell.teacherName.text = self.teamsMeetingsList[indexPath.item].teacherName
            cell.date.text = self.teamsMeetingsList[indexPath.item].date
            print("height: \(cell.teacherImage.frame.height)")
            print("width: \(cell.teacherImage.frame.width)")

            cell.teacherImage.layer.cornerRadius = cell.teacherImage.frame.size.width/2
            cell.teacherImage.clipsToBounds = true
            
            cell.outerView.layer.cornerRadius = 10
            cell.outerView.clipsToBounds = true
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
}

extension TeamsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.section){
            case 0:
                return UITableView.automaticDimension
            case 1:
                return 110
            default:
                return UITableView.automaticDimension
            }
        
    }

    
    //MARK: Custom Tableview Headers
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 1){
            return "Hello"

        }
        return ""
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){

        view.tintColor = UIColor.black
        let header = view as! UITableViewHeaderFooterView
        if section == 0 {
            header.textLabel?.textColor = UIColor.black
            view.tintColor = UIColor.white
        }
        else {
            view.tintColor = UIColor.groupTableViewBackground
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           
           if(section == 1){
              return 50
          }
          else{
             return 0
          }
       }
    
}

