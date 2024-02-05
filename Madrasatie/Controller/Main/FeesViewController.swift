//
//  FeesViewController.swift
//  Madrasatie
//
//  Created by Maher Jaber on 3/30/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import Foundation
import UIKit
import PWSwitch
import ActionSheetPicker_3_0
import SDWebImage
import MonthYearPicker


protocol FeesViewControllerDelegate {
    func feesPressed(calendarType: CalendarStyle?)
}

class FeesViewController: UIViewController{
           
   
   
    
    @IBOutlet weak var dateLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var peopleFeesTableView: UITableView!
    private var datePicker: MonthYearPickerView?
    
    var input = [Payroll(amount:"Maher1", value:"Jaber1"), Payroll(amount:"Maher2", value:"Jaber2"), Payroll(amount:"Maher3", value:"Jaber3")]
    var deductions = [Payroll(amount:"HEY", value:"HEY"), Payroll(amount:"HEY", value:"HEY")]
    var total = [Payroll(amount:"Amount", value:"Value") ]
    var distributed = [DistributedPaymentsModel(count: 1, amount: "205000.0", paid: "200000.0", remianing: "50000.0", dueDate: "26 march 2018"),
    DistributedPaymentsModel(count: 2, amount: "205000.0", paid: "200000.0", remianing: "50000.0", dueDate: "26 march 2018"),
        DistributedPaymentsModel(count: 3, amount: "205000.0", paid: "200000.0", remianing: "50000.0", dueDate: "26 march 2018")
    ]
    var categories = [CategoriesModel(title: "Registration Fees",date: "01/01/2020", paid: "paid", remianing: "20000.00", total: "205000.00"),
    CategoriesModel(title: "Fourniture Fees",date: "01/01/2020", paid: "paid", remianing: "0.00", total: "205000.00"),
    CategoriesModel(title: "Tuition Fees",date: "01/01/2020", paid: "paid", remianing: "0.00", total: "205000.00")]
    
    
    //select date
    var currentDate = ""
    var selectedDate = ""
    
    //load data
    var parentCategories: [ParentFeesCategories] = []
    var parentCategoriesResult: [ParentFeesCategories] = []
    var parentDistPayments: [ParentFeesDistributedPayments] = []
    var parentDistributionResult: [ParentFeesDistributedPayments] = []
    var employeeEarnings: [EmployeePayroll] = []
    var employeeDeductions: [EmployeePayroll] = []
    var employeeTotalAmount: [EmployeePayroll] = []
    
    var calendarStyle: CalendarStyle? = .week
    var user: User!
    var feesDelegate: FeesViewControllerDelegate?
    var appTheme: AppTheme!
    
    var filterParentFees: String = ""

   
    
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
      
        peopleFeesTableView.dataSource = self
        peopleFeesTableView.delegate = self
        peopleFeesTableView.register(UINib(nibName: "TestCell", bundle: nil), forCellReuseIdentifier: "ReuseIdentifier")
        peopleFeesTableView.register(UINib(nibName: "DistributedPaymentsTableViewCell", bundle: nil), forCellReuseIdentifier: "DistributedIdentifier")
        peopleFeesTableView.register(UINib(nibName: "DistributedTotalPaymentsTableVC", bundle: nil), forCellReuseIdentifier: "TotalDistributedIdentifier")
        peopleFeesTableView.register(UINib(nibName: "CategoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoriesIdentifier")
        
        peopleFeesTableView.register(UINib(nibName: "TotalCategoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "TotalCategoriesIdentifier")

        datePicker = MonthYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: (view.bounds.height - 216) / 2), size: CGSize(width: view.bounds.width, height: 216)))


        //ToolBar
          let toolbar = UIToolbar();
          toolbar.sizeToFit()
          let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));

        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
         let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)


         dateLabel.inputAccessoryView = toolbar
         dateLabel.inputView = datePicker
        
        if(user.userType == 2){
            getTeachersPayroll(user: user, type: "payroll")
            dateLabel.isHidden = false
            dateLabelHeight.constant = 40
        }
        else if(user.userType == 4){
            dateLabel.isHidden = true
            dateLabelHeight.constant = 0
            
            if(filterParentFees.elementsEqual("fees") || filterParentFees.elementsEqual("")){
                getParentsFeesCategories(user: user, type: "fees", studentUsername: user.admissionNo)
            }
            else if(filterParentFees.elementsEqual("distributed_payments")){
                getParentsFeesDistributedPayments(user: user, type: "distributed_payments")
            }
        }
        

  }
  
    @objc func donedatePicker(){

        let formatter = DateFormatter()
        formatter.dateFormat = "MM-yyyy"
          dateLabel.text = formatter.string(from: datePicker!.date)
        self.view.endEditing(true)
      }

      @objc func cancelDatePicker(){
         self.view.endEditing(true)
       }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.calendarStyle = .week
        feesDelegate?.feesPressed(calendarType: self.calendarStyle)
        
    }
  
    
    
    
    
    fileprivate lazy var pickerDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-yyyy"
    //        formatter.locale = Locale(identifier: "\(self.languageId)")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
        }()
    
 /*override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch indexPath.section{
    case 0:
        let monthlyPayrollSelector = peopleFeesTableView.dequeueReusableCell(withIdentifier: "monthlyPayrollReuse")
        let startLabel = monthlyPayrollSelector?.viewWithTag(700) as! UILabel
        
        break
        
    default:
        
    }
    
    }*/}

// API Calls:
extension FeesViewController{
    /// Description: Get Employee Payroll
    ///
    /// - Parameters:
    ///   - user: Logged in selected user
    ///   - language: Current app language
    ///   - type: fees type
    /// - This function is called to get the employee fees from  "getTeachersPayroll" API for selected user and langage.
    func getTeachersPayroll(user: User, type: String){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.getTeachersPayroll(user: user, type: type) { (message, payrollMap, status) in
            if status == 200{
                self.employeeEarnings = payrollMap!["earning"]!
                for item in self.employeeEarnings{
                    print("payroll: \(item.amount)")
                    print("payroll: \(item.amountValue)")

                }
                    
                self.employeeDeductions = payrollMap!["deduction"]!
                self.employeeTotalAmount = payrollMap!["total_amount"]!
                
                self.peopleFeesTableView.reloadData()

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
    
    /// Description: Get Employee Payroll
    ///
    /// - Parameters:
    ///   - user: Logged in selected user
    ///   - language: Current app language
    ///   - type: fees type
    /// - This function is called to get the employee fees from  "getTeachersPayroll" API for selected user and langage.
    func getParentsFeesCategories(user: User, type: String, studentUsername: String){
        let indicatorView = App.loading()
        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.getParentsFeesCategories(user: user, type: type, studentUsername: studentUsername) { (message, parentsCategoryFees, status) in
            if status == 200{
                print("entered")
                self.parentCategories = parentsCategoryFees!
                self.parentCategoriesResult.append(self.parentCategories[self.parentCategories.count-1])
                self.parentCategories.removeLast()
                
                self.peopleFeesTableView.reloadData()
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
    
  /// Description: Get Employee Payroll
  ///
  /// - Parameters:
  ///   - user: Logged in selected user
  ///   - language: Current app language
  ///   - type: fees type
  /// - This function is called to get the employee fees from  "getTeachersPayroll" API for selected user and langage.
  func getParentsFeesDistributedPayments(user: User, type: String){
      let indicatorView = App.loading()
      indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
      indicatorView.tag = 100
      self.view.addSubview(indicatorView)
      
      Request.shared.getParentsFeesDistributedPayments(user: user, type: type) { (message, parentFeesDistrubutedPayments, status) in
          if status == 200{
            self.parentDistPayments = parentFeesDistrubutedPayments!
            self.parentDistributionResult.append(self.parentDistPayments[self.parentDistPayments.count-1])
            self.parentDistPayments.removeLast()
            self.peopleFeesTableView.reloadData()

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
  
}
extension FeesViewController: FeesViewControllerDelegate{
    func feesPressed(calendarType: CalendarStyle?) {
        print("hello")
    }
    
    func feesPressed(type:String) {
        print("hello")
    }
    
    
    
}

extension FeesViewController: SectionVCToFeesDelegate{
    func switchFeesChildren(user: User, batchId: Int?, children: Children?) {
        self.user = user
        if(user.userType == 2){
                  getTeachersPayroll(user: user, type: "payroll")
                  dateLabel.isHidden = false
                  dateLabelHeight.constant = 40
              }
              else if(user.userType == 4){
                if(dateLabel != nil){
                    dateLabel.isHidden = true
                    dateLabelHeight.constant = 0
                }
                 
                  
                  if(filterParentFees.elementsEqual("fees") || filterParentFees.elementsEqual("")){
                      getParentsFeesCategories(user: user, type: "fees", studentUsername: user.admissionNo)
                  }
                  else if(filterParentFees.elementsEqual("distributed_payments")){
                      getParentsFeesDistributedPayments(user: user, type: "distributed_payments")
                  }
              }
    }
    
    func feesFilterSectionView(type: Int) {
        switch self.user.userType{
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            switch type{
            // Absent Students:
            case 0:
               filterParentFees = "distributed_payments"
               getParentsFeesDistributedPayments(user: user, type: filterParentFees)
            // Present Students:
            case 1:
                filterParentFees = "fees"
                getParentsFeesCategories(user: user, type: filterParentFees, studentUsername: user.admissionNo)
                

            // Late Students:
            default:
                filterParentFees = ""
        }
        default:
            filterParentFees = ""
            
        }
    
    
    
}
}


extension FeesViewController: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
            return IndicatorInfo(title: "Fees".localiz(), counter: "", image: UIImage(named: "fees"), backgroundViewColor: App.hexStringToUIColorCst(hex: "#06c6b3", alpha: 1.0), id: App.feesId)
       
    }
    
}


extension FeesViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // #warning Incomplete implementation, return the number of sections
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(user.userType == 2){
            if(section == 0){
                return employeeEarnings.count
            }
            else if(section == 1){
                return employeeDeductions.count
            }
            else if(section == 2){
                return employeeTotalAmount.count
            }
        }
        else if(user.userType == 4){
            if(filterParentFees.elementsEqual("distributed_payments")){
                if(section == 3){
                    return distributed.count
                    }
                else if(section == 4){
                    return 1
                }
            }
            if(filterParentFees.elementsEqual("fees") || filterParentFees.elementsEqual("")){
                print("number of sections: \(section)")
                if(section == 5){
                    return parentCategories.count
                }
                else if(section == 6){
                    return 5
                }
            }
            
            
        }
        
       
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)
            as!TestCell
            
            cell.amount?.text = employeeEarnings[indexPath.row].amount
            cell.value?.text = employeeEarnings[indexPath.row].amountValue
            if(indexPath.row == 0){
                cell.background.layer.backgroundColor = #colorLiteral(red: 0.3441109061, green: 0.5559097528, blue: 0.5366322398, alpha: 1)
            }
            else if(indexPath.row == employeeEarnings.count-1){
                cell.background.layer.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)

            }
            else{
                cell.background.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
            return cell
            
            
        case 1:
            if(user.userType == 2){
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)
                           as!TestCell
                           
                           cell.amount?.text = employeeDeductions[indexPath.row].amount
                           cell.value?.text = employeeDeductions[indexPath.row].amountValue

                           if(indexPath.row == 0){
                               cell.background.layer.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)

                               
                           }
                           else if(indexPath.row == employeeDeductions.count-1){
                               cell.background.layer.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)

                           }
                           else{
                               cell.background.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                           }
                           return cell
            }
           

        case 2:

            if(user.userType == 2){
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifier", for: indexPath)
                as!TestCell

                cell.amount?.text = employeeTotalAmount[indexPath.row].amount
                cell.value?.text = employeeTotalAmount[indexPath.row].amountValue
                cell.background.layer.backgroundColor = #colorLiteral(red: 0.202219367, green: 0.2679272592, blue: 1, alpha: 1)
                return cell
            }
            

        case 3:


            if( user.userType == 4){
                if(filterParentFees.elementsEqual("distributed_payments")){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DistributedIdentifier", for: indexPath)
                                               as!DistributedPaymentsTableViewCell

                    if(parentDistPayments.count>0){
                        cell.paymentCountValue?.text = String(parentDistPayments[indexPath.row].count)
                        cell.amountValue?.text = parentDistPayments[indexPath.row].amountValue
                        cell.paidAmountValue?.text = parentDistPayments[indexPath.row].paidAmountValue
                        cell.remainingValue?.text = parentDistPayments[indexPath.row].remainingAmountValue
                        cell.dueDateValue?.text = parentDistPayments[indexPath.row].dueDate
                        print("sectionss: \(cell.frame.height)")
                        return cell
                    }

                }

            }
           
            
        case 4:
            if(user.userType == 4){
                if(filterParentFees.elementsEqual("distributed_payments")){
                let cell = tableView.dequeueReusableCell(withIdentifier: "TotalDistributedIdentifier", for: indexPath)
                as!DistributedTotalPaymentsTableVC
                    if(parentDistPayments.count>0){
                        cell.amount?.text = "total"
                        cell.paid?.text = "paid"
                        cell.remaining?.text = "remaining"
                    }

                }

            }
            
            
        
        case 5:
            if(user.userType == 4){
                if(filterParentFees.elementsEqual("fees") || filterParentFees.elementsEqual("")){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesIdentifier", for: indexPath)
                                               as!CategoriesTableViewCell

                    if(parentCategories.count > 0){
                        cell.title?.text = parentCategories[indexPath.row].title
                                           cell.date?.text = parentCategories[indexPath.row].date
                                           cell.remaining?.text = parentCategories[indexPath.row].remainingAmount
                                           cell.total?.text = parentCategories[indexPath.row].totalAmount

                                           if(Double(parentCategories[indexPath.row].remainingAmount) != 0.00){
                                               cell.paid?.text = "Unpaid"
                                               cell.paid.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                                           }
                                           else{
                                               cell.paid?.text = "Paid"
                                               cell.paid.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                                           }
                                                                      return cell
                    }

                }
            }

            
        case 6:
//            if(user.userType == 4){
//                if(filterParentFees.elementsEqual("fees") || filterParentFees.elementsEqual("")){
//                    print("parentDistPayments: \(parentDistPayments.count)")
//                    if(parentCategoriesResult.count>0){
//                        let cell = tableView.dequeueReusableCell(withIdentifier: "TotalDistributedIdentifier", for: indexPath)
//                                               as!DistributedTotalPaymentsTableVC
//                        print("parentCategoriesResult: \(self.parentCategoriesResult.count)")
//
//                        cell.amount?.text = parentCategoriesResult[0].totalAmount
//                        cell.paid?.text = parentCategoriesResult[0].condition
//                        cell.remaining?.text = parentCategoriesResult[0].remainingAmount
//
//                                               return cell
//                    }
//
//
//                }
//
//
//            }
            if(user.userType == 4){
                if(filterParentFees.elementsEqual(("fees")) || filterParentFees.elementsEqual((""))){
                    if(parentCategoriesResult.count > 0){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "totalInfo", for: indexPath)
                        let key = cell.viewWithTag(1001) as! UILabel
                        let value = cell.viewWithTag(1002) as! UILabel;
                        cell.borderWidth = 1
                        cell.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                        key.font = UIFont.boldSystemFont(ofSize: 17)
                        
                        print("user: \(user.userName)")
                        if(indexPath.row == 0){
                            key.text = "Code";
                            value.text = user.userName;
                            cell.backgroundColor = #colorLiteral(red: 0.008992123418, green: 0.5049488544, blue: 1, alpha: 1)
                            key.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                            value.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                        }
                        
                        if(indexPath.row == 1){
                            key.text = "Total Amount";
                            value.text = parentCategoriesResult[0].totalAmount;
                            key.textColor = #colorLiteral(red: 0.008992123418, green: 0.5049488544, blue: 1, alpha: 1)
                        }
                        if(indexPath.row == 2){
                            key.text = "Paid Amount";
                            value.text = parentCategoriesResult[0].condition;
                            key.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)

                        }
                        if(indexPath.row == 3){
                            key.text = "Discount Amount";
                            value.text = parentCategoriesResult[0].totalAmount;
                            key.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)

                        }
                        if(indexPath.row == 4){
                            key.text = "Remaining Amount";
                            value.text = parentCategoriesResult[0].remainingAmount
                            key.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)

                        }
                        
                       
                                               
                    }
                }
            }
            
//        case 7:
//            print("entered case 7")
//            if(user.userType == 4){
//                if(filterParentFees.elementsEqual(("fees")) || filterParentFees.elementsEqual((""))){
//                    if(parentCategoriesResult.count > 0){
//                        let cell = tableView.dequeueReusableCell(withIdentifier: "totalInfo", for: indexPath)
//                        let key = cell.viewWithTag(1001) as! UILabel
//                        let value = cell.viewWithTag(1002) as! UILabel;
//
//                        key.text = "Total Amount";
//                        value.text = parentCategoriesResult[0].totalAmount;
//
//                    }
//                }
//            }
            
            
        default:
            print("no items attached")
        }
        return UITableViewCell()
}

}

extension FeesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat{
        if(user.userType == 2){
            if(indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2){
                return 38
            }
            else{
                return 0
            }
        }
        if(user.userType == 4){
            if(filterParentFees.elementsEqual("distributed_payments")){
                if(indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5){
                    return 0
                }
//                if(indexPath.section == 3 ){
//                    return 185
//                }
//                else if(indexPath.section == 4){
//                    return 130
//                }
//                else{
//                    return 0
//                }
            }
            
            if(filterParentFees.elementsEqual("categories") || filterParentFees.elementsEqual("")){
                if(indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5){
                    return 0
                }
                else if(indexPath.section == 6){
                    return 50
                }
                else{
                    return 0
                }
               
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    

}

