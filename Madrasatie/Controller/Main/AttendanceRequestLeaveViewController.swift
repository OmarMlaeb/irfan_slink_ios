//
//  AttendanceRequestLeaveViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/9/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

/// Description:
/// - Delegate from Attendance request leave page to Attendance page.
protocol AttendanceRequestLeaveViewControllerDelegate{
    func reasonDismiss(submitted: Bool)
}

class AttendanceRequestLeaveViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var absenceButton: UIButton!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var reasonTextField: TextFieldPadding!
    @IBOutlet weak var reasonDropDownButton: UIButton!
    @IBOutlet weak var reasonDropDownImageView: UIImageView!
    @IBOutlet weak var horizantalChart: HorizontalBarChartView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var horizantalChartTopConstraints: NSLayoutConstraint!
    @IBOutlet var absenceToLeaveButtonConstraint: NSLayoutConstraint!
    @IBOutlet var absenceLeadingConstarint: NSLayoutConstraint!
    @IBOutlet var backArrow: UIImageView!
    
    var reason = "leave"
    var user: User!
    var reasonsArray: [String] = []
    var delegate: AttendanceRequestLeaveViewControllerDelegate?
    var percentageArray: [Double] = [10,10,80]
    var valueArray = [5,10,15]
    var colorArray: [NSUIColor] = [App.hexStringToUIColorCst(hex: "#ff5955", alpha: 1.0), App.hexStringToUIColorCst(hex: "#ffcb39", alpha: 1.0), App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)]
    var selectedPeriod: [Period] = []
    var requestDate = ""
    var isRequestLeave = false
    var absenceId = 0
    var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    var startDate: String = ""
    var endDate: String = ""
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    override func viewDidLoad() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            super.viewDidLoad()
            
            
            self.reasonsArray.append("Sickness")
            self.reasonsArray.append("Weather Conditions")
            self.reasonsArray.append("Family Emergency")
            self.reasonsArray.append("Transportation Issues")
            self.reasonsArray.append("Vacation")
            self.reasonsArray.append("Personal Reasons")
            self.reasonsArray.append("Other")
            
            self.titleLabel.text = "Reason".localiz()
            self.leaveButton.backgroundColor = UIColor(red:0.34, green:0.56, blue:0.96, alpha:1.0)
            self.leaveButton.titleLabel?.textColor = .white
            self.leaveButton.tintColor = .white
            self.leaveButton.layer.borderWidth = 0
            self.absenceButton.backgroundColor = .white
            self.absenceButton.titleLabel?.textColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
            self.absenceButton.tintColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
            self.absenceButton.layer.borderWidth = 1
            self.absenceButton.layer.borderColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0).cgColor
            self.reasonLabel.text = "Write the reason".localiz()
            self.submitButton.backgroundColor = UIColor(red:0.34, green:0.56, blue:0.96, alpha:1.0)
            self.reasonTextView.layer.borderWidth = 1
            self.reasonTextView.layer.borderColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0).cgColor
            self.reasonTextView.layer.cornerRadius = 10
            self.reasonTextView.tintColor = App.hexStringToUIColorCst(hex: "#6D6E71", alpha: 1.0)
            self.reasonTextField.layer.cornerRadius = self.reasonTextField.frame.height/2
            self.reasonTextField.layer.borderWidth = 1
            self.reasonTextField.layer.borderColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0).cgColor
            self.reasonTextField.alpha = 0
            self.reasonDropDownButton.alpha = 0
            self.reasonDropDownImageView.alpha = 0
            self.horizantalChart.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.horizantalChartTopConstraints.constant = 0
            self.horizantalChart.isHidden = true

//            self.horizantalChartTopConstraints.constant = 150
//            self.horizantalChart.removeFromSuperview()
//            self.horizantalChart.alpha = 0.0
//            self.setup(barLineChartView: self.horizantalChart)
            
            if self.languageId == "ar"{
                self.backArrow.image = UIImage(named: "calendar-right-arrow")
            }else{
                self.backArrow.image = UIImage(named: "calendar-left-arrow")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//            self.setup(barLineChartView: self.horizantalChart)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if isRequestLeave{
            delegate?.reasonDismiss(submitted: false)
        }else{
            delegate?.reasonDismiss(submitted: true)
        }
    }
    
    @IBAction func leaveButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func absenceButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func reasonDropDownButtonPressed(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Select Reason".localiz(), rows: self.reasonsArray, initialSelection: 0, doneBlock: {
            picker, ind, values in
            
            self.reasonTextField.text = self.reasonsArray[ind]
            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    /// Description:
    /// - Check if the parent request a leave or verify an absence to call the needed function.
    @IBAction func submitButtonPressed(_ sender: Any) {
        var subjectID: [String] = []
        var periodID:[Int] = []
        for period in self.selectedPeriod{
            subjectID.append(period.subjectId)
            periodID.append(period.periodId)
        }
        var fullDay = 1
        
        if reason == "leave"{
            fullDay = 0
        }else{
            fullDay = 1
        }
        let ok = UIAlertAction(title: "OK".localiz(), style: .default) { (action) in
            if self.isRequestLeave{
                self.submitReason(user: self.user, studentUsername: self.user.admissionNo, reason: self.reasonTextField.text!, period: self.selectedPeriod, fullDay: fullDay, requestDate: self.requestDate, startDate: self.startDate, endDate: self.endDate)
            }else{
                self.verifyAbsence(user: self.user, studentUsername: self.user.admissionNo, reason: self.reasonTextField.text ?? "", id: self.absenceId)
            }
        }
        let cancel = UIAlertAction(title: "Cancel".localiz(), style: .default, handler: nil)
        App.showAlert(self, title: "", message: "Are you sure you want to inform the school?".localiz(), actions: [ok,cancel])
    }
    
    
    /// Description:
    /// - Setup Horizontal Bar Chart View:
    func setup(barLineChartView chartView: HorizontalBarChartView) {

        chartView.isUserInteractionEnabled = false
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.setExtraOffsets(left: -8, top: 2, right: 16, bottom: 2)
        chartView.rightAxis.enabled = true
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.maxVisibleCount = 1000
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 10
        xAxis.axisMinimum = -2.5
        xAxis.axisMaximum = 25
        xAxis.valueFormatter = DayAxisValueFormatter(chart: chartView)
        
        let leftAxis = chartView.leftAxis
        leftAxis.enabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.granularityEnabled = false
        leftAxis.granularity = 10
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 90
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.drawAxisLineEnabled = true
        rightAxis.drawGridLinesEnabled = false
        rightAxis.granularity = 10
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 100
        
        chartView.legend.enabled = false
        chartView.legend.drawInside = true
        chartView.drawValueAboveBarEnabled = true
        
        //Init Data:
        
        let barWidth = 5.0
        
        var dataEntries = [ChartDataEntry]()
        
        for i in 0..<percentageArray.count {
            let entry = BarChartDataEntry(x: Double(i)*10, y: Double(percentageArray[i]), icon: #imageLiteral(resourceName: "empty"))
            dataEntries.append(entry)
        }
        
        let set1 = BarChartDataSet(values: dataEntries, label: "DataSet")
        set1.drawIconsEnabled = true
        set1.drawValuesEnabled = true
//        set1.colors = colorArray
        set1.setColors(colorArray, alpha: 1)
        set1.valueColors = colorArray
        
        let data = BarChartData(dataSet: set1)
        data.barWidth = barWidth
        data.setValueFont(UIFont(name: "OpenSans-Bold", size: 11)!)
        data.setDrawValues(true)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1.0
        formatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        chartView.data = data
        
        chartView.setNeedsDisplay()
        
    }
    
    
}


// MARK: - Handle delegate functions from attendance page:
extension AttendanceRequestLeaveViewController: RequestLeaveDelegate{
    
    /// Description:
    /// - Update the view to verify absence case.
    func verifyAbsence(percentageArray: [Double], colorArray: [NSUIColor], user: User, id: Int) {
        self.absenceLeadingConstarint.isActive = true
        self.absenceToLeaveButtonConstraint.isActive = false
        self.leaveButton.isHidden = true
        self.isRequestLeave = false
        self.user = user
        self.absenceId = id
        reloadView(fullDay: true)
//        getLeaveReasons(user: self.user, language: "en")
//        self.setup(barLineChartView: self.horizantalChart)
    }
    
    
    /// Description:
    /// - This function is called when user press on submot leave request in attendance page to reload page data.
    func requestLeave(percentageArray: [Double], colorArray: [NSUIColor], user: User, fullDay: Bool, selectedPeriods: [Period], date: String, startDate: String, endDate: String) {
        self.absenceLeadingConstarint.isActive = false
        self.absenceToLeaveButtonConstraint.isActive = true
        self.leaveButton.isHidden = false
        self.isRequestLeave = true
        self.percentageArray = percentageArray.reversed()
        self.colorArray = colorArray.reversed()
//        self.setup(barLineChartView: self.horizantalChart)
        self.user = user
        self.requestDate = date
        self.selectedPeriod = selectedPeriods
        self.startDate = startDate
        self.endDate = endDate
//        getLeaveReasons(user: self.user, language: "en")
        
        reloadView(fullDay: fullDay)
    }
    
    
    /// Description:
    /// - Update page view design.
    func reloadView(fullDay: Bool){
        if fullDay{
            absenceButton.backgroundColor = UIColor(red:0.34, green:0.56, blue:0.96, alpha:1.0)
            absenceButton.titleLabel?.textColor = .white
            absenceButton.tintColor = .white
            absenceButton.layer.borderWidth = 0
            leaveButton.backgroundColor = .white
            leaveButton.titleLabel?.textColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
            leaveButton.tintColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
            leaveButton.layer.borderWidth = 1
            leaveButton.layer.borderColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0).cgColor
            reasonLabel.text = "Choose an absence reason".localiz()
//            horizantalChartTopConstraints.constant = 80
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.reasonTextField.alpha = 1
                self.reasonDropDownButton.alpha = 1
                self.reasonDropDownImageView.alpha = 1
                self.reasonTextView.alpha = 0
            }
            reason = "absence"
        }else{
            leaveButton.backgroundColor = UIColor(red:0.34, green:0.56, blue:0.96, alpha:1.0)
            leaveButton.titleLabel?.textColor = .white
            leaveButton.tintColor = .white
            leaveButton.layer.borderWidth = 0
            absenceButton.backgroundColor = .white
            absenceButton.titleLabel?.textColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
            absenceButton.tintColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0)
            absenceButton.layer.borderWidth = 1
            absenceButton.layer.borderColor = UIColor(red:0.82, green:0.83, blue:0.83, alpha:1.0).cgColor
            reasonLabel.text = "Write the reason".localiz()
//            horizantalChartTopConstraints.constant = 150
//            UIView.animate(withDuration: 0.5) {
//                self.view.layoutIfNeeded()
//                self.reasonTextField.alpha = 0
//                self.reasonDropDownButton.alpha = 0
//                self.reasonDropDownImageView.alpha = 0
//                self.reasonTextView.alpha = 1
//            }
//            horizantalChartTopConstraints.constant = 80
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.reasonTextField.alpha = 1
                self.reasonDropDownButton.alpha = 1
                self.reasonDropDownImageView.alpha = 1
                self.reasonTextView.alpha = 0
            }
            reason = "leave"
        }
    }
}

// MARK: - API Calls:
extension AttendanceRequestLeaveViewController{
    /// Description: Get Reasons
    /// - Call "get_reasons" API
    func getLeaveReasons(user: User, language: String){
        Request.shared.getReasons(user: user, language: language) { (message, reasonData, status) in
            if status == 200{
                self.reasonsArray = []
                for reason in reasonData!{
                    self.reasonsArray.append(reason)
                }
                self.reasonTextField.text = self.reasonsArray.first
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Error".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    /// Description: Submit Reason
    /// - Call "request_absence" API.
    /// - Call reasonDismiss function to go back to attendance page.
    func submitReason(user: User, studentUsername: String, reason: String, period: [Period], fullDay: Int, requestDate: String, startDate: String, endDate: String){
        Request.shared.submitReasons(user: user, studentUsername: studentUsername, reason: reason, periodArray: period, fullDay: fullDay, date: requestDate, startDate: startDate, endDate: endDate) { (message, data, status) in
            if status == 200{
                App.showMessageAlert(self, title: "", message: "Submitted".localiz(), dismissAfter: 1.0)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.delegate?.reasonDismiss(submitted: true)
                })
                self.reasonTextView.text = ""
                self.reasonTextField.text = ""
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Error".localiz(), message: message ?? "", actions: [ok])
            }
        }
    }
    
    /// Description: Verify Absence
    /// - Call "verify_absence" API.
    /// - Call reasonDismiss function to go back to attendance page.
    func verifyAbsence(user: User, studentUsername: String, reason: String, id: Int){
        self.view.superview?.superview?.insertSubview(self.loading, at: 1)
        Request.shared.verifyAbsence(user: user, studentUsername: studentUsername, reason: reason, id: id) { (message, data, status) in
            if status == App.STATUS_SUCCESS{
                App.showMessageAlert(self, title: "", message: "Verified".localiz(), dismissAfter: 1.0)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.delegate?.reasonDismiss(submitted: true)
                })
                self.reasonTextView.text = ""
                self.reasonTextField.text = ""
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "Error".localiz(), message: message ?? "", actions: [ok])
            }
            UIApplication.shared.keyWindow?.viewWithTag(1500)?.removeFromSuperview()
            self.view.superview?.superview?.viewWithTag(1500)?.removeFromSuperview()
            self.loading.removeFromSuperview()
        }
    }
}

