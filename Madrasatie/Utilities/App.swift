//
//  App.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/3/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SDWebImage

class App{
    
    static var languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    static var dbVersion = 7
    
    static var birthdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static var pickerTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "\(languageId)")//exception LEAVE IT
        return formatter
    }()
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static var STATUS_SUCCESS: Int {
        return 200
    }
    
    static var STATUS_VIOLATION: Int {
        return 700
    }
    
    static var studentAttendancePrivilege: String{
        return "student_attendance_register_privilege"
    }
    
    static var eventManagmentPrivilege: String{
        return "event_management_privilege"
    }
    
    static var studentsControlPrivilege: String{
        return "students_control_privilege"
    }
    
    static var studentAttendanceViewPrivilege: String{
        return "student_attendance_view_privilege"
    }
    
    static var subjectMasterPrivilege: String{
        return "subject_master_privilege"
    }
    
    static var examinationControlPrivilege: String{
        return "examination_control_privilege"
    }
    
    static var viewResultPrivilege: String{
        return "view_results_privilege"
    }
    
    static var enterResultPrivilege: String{
        return "enter_results_privilege"
    }
    
//    static var timeTableViewPrivilege: String{
//        return "timetable_view_privilege"
//    }
//
//    static var employeeAttendancePrivilege: String{
//        return "employee_attendance_privilege"
//    }
//
//    static var studentViewPrivilege: String{
//        return "student_view_privilege"
//    }
    
    
//    "reports_view_privilege",
//    "examination_control_privilege",
//    "enter_results_privilege",
//    "view_results_privilege",
//    "admission_privilege",
//    "manage_news_privilege",
//    "manage_timetable_privilege",
//    "hr_settings_privilege",
//    "manage_course_batch_privilege",
//    "general_settings_privilege",
//    "payroll_and_payslip_privilege",
//    "employee_search_privilege",
//    "sms_management_privilege",
//    "custom_report_control_privilege",
//    "custom_report_view_privilege",
//    "data_management_privilege",
//    "data_management_viewer_privilege",
//    "group_create_privilege",
//    "gallery_privilege",
//    "hostel_admin_privilege",
//    "librarian_privilege",
//    "placement_activities_privilege",
//    "task_management_privilege",
//    "transport_admin_privilege",
//    "applicant_registration_privilege",
//    "blog_admin_privilege",
//    "inventory_manager_privilege",
//    "inventory_privilege",
//    "poll_control_privilege",
//    "custom_import_privilege",
//    "discipline_privilege",
//    "send_email_privilege",
//    "email_alert_settings_privilege",
//    "document_manager_privilege",
//    "inventory_basics_privilege",
//    "app_frame_admin_privilege",
//    "tokens_privilege",
//    "oauth2_manage_privilege",
//    "manage_users_privilege",
//    "classroom_allocation_privilege",
//    "manage_building_privilege",
//    "online_exam_control_privilege",
//    "form_builder_privilege",
//    "inventory_sales_privilege",
//    "miscellaneous_privilege",
//    "finance_reports_privilege",
//    "approve_reject_payslip_privilege",
//    "fee_submission_privilege",
//    "manage_fee_privilege",
//    "revert_transaction_privilege",
//    "manage_refunds_privilege",
//    "manage_audit_privilege",
//    "manage_roll_number_privilege",
//    "manage_alumni_privilege",
//    "reminder_manager_privilege",
//    "manage_student_record_privilege",
//    "manage_employee_privilege",
//    "employee_reports_privilege",
//    "manage_transfer_certificate_privilege",
//    "health_admin_privilege"
    
    static var STATUS_TIMEOUT = 402
    static var STATUS_INVALID_RESPONSE = 401
    static var CONNECTION_TIMEOUT = "Connection timeout"
//    static var INVALID_RESPONSE = "Invalid API response"
    static var INVALID_RESPONSE = "Sorry, an error has occurred"
    
    static let NotiCalendar = 1
    static let NotiAttendance = 2
    static let NotiAgenda = 3
    static let NotiRemarks = 4
    static let NotiExamination = 5
    static let NotiInternalMessages = 6
    static let NotiFees = 7
    static let NotiBirthdays = 8
    static let NotiBlended = 15
    
    static var calendarID = 2
    static var attendanceID = 8
    static var agendaID = 3
    static var remarksID = 9
    static var gradesID = 5
    static var timeTableID = 10
    static var messagesID = 11
    static var gclassID = 99
    static var feesId = 12
    static var galleryId = 11
    static var teamsId = 13
    static var virtualClassroomId = 14
    static var blendedLearningId = 15
    static var assessmentId = 20
    
    /// Description:
    /// - sd_setShowActivityIndicatorView depricated from SDWebImage.
    class func addImageLoader(imageView: UIImageView?, button: UIButton?){
        if imageView != nil {
//            imageView?.sd_setShowActivityIndicatorView(true)
//            imageView?.sd_setIndicatorStyle(.gray)
        }
        if button != nil{
//            button?.sd_setShowActivityIndicatorView(true)
//            button?.sd_setIndicatorStyle(.gray)
        }
    }
    
    /// Description:
    /// - sd_setShowActivityIndicatorView depricated from SDWebImage.
    class func removeImageLoader(imageView: UIImageView?, button: UIButton?){
        if imageView != nil {
//            imageView?.sd_setShowActivityIndicatorView(false)
        }
        if button != nil{
//            button?.sd_setShowActivityIndicatorView(false)
        }
    }
    
    class func showAlert(_ presenting: UIViewController, title: String, message: String, actions: [UIAlertAction], controller: UIViewController? = nil, isCancellable: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        if let controller = controller {
            alert.setValue(controller, forKey: "contentViewController")
        }
        
        if presenting.presentedViewController is UIAlertController {
            return
        }
//        alert.view.tintColor = self.blueColor
        (presenting.presentedViewController ?? presenting).present(alert, animated: true, completion: {
//            alert.view.tintColor = self.blueColor
            if isCancellable {
                alert.view.superview?.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(App.dismiss(_:)))
                tap.accessibilityElements = [presenting.presentedViewController ?? presenting]
                alert.view.superview?.addGestureRecognizer(tap)
            }
        })
    }
    
    class func showMessageAlert(_ presenting: UIViewController, title: String, message: String, dismissAfter: Double) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if presenting.presentedViewController is UIAlertController {
            return
        }
        let okAction = UIAlertAction(title: "OK".localiz(), style: UIAlertAction.Style.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        alert.addAction(okAction)
        presenting.present(alert, animated: true, completion: nil)
    }
    
    class func showMainScreen(with transition: UIView.AnimationOptions = .transitionCrossDissolve) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()
        controller?.modalPresentationStyle = .fullScreen
        UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.5, options: transition, animations: {() -> Void in
            UIApplication.shared.keyWindow!.rootViewController! = controller!
        }, completion: { _ in })
    }
    
    class func showSplashScreen(with transition: UIView.AnimationOptions = .transitionCrossDissolve, pushController: PushController? = nil) {
        let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        controller.modalPresentationStyle = .fullScreen
        controller.pushController = pushController

        UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.5, options: transition, animations: {() -> Void in
            UIApplication.shared.keyWindow!.rootViewController! = controller
        }, completion: { _ in })
    }
    
    @objc fileprivate class func dismiss(_ sender: UITapGestureRecognizer) {
        let controller = sender.accessibilityElements?.first as? UIViewController
        controller?.dismiss(animated: true, completion: nil)
    }
    
    class func getLoggedInUsers() -> [User]?{
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
        do {
            let userData = try managedContext.fetch(userFetchRequest) as! [NSManagedObject]
            var userArray: [User] = []
            for user in userData{
                var classes = [Class]()
                if let classesData = user.value(forKey: "classes") as? NSOrderedSet {
                    for case let classData as NSManagedObject in classesData {
                        let classObject = Class(classId: classData.integer(forKey: "classId"),batchId: classData.integer(forKey: "batchId"), className: classData.string(forKey: "classname"), imperiumCode: classData.string(forKey: "imperiumCode"))
                        classes.append(classObject)
                    }
                }
//                user.setValue(NSSet(array: userData), forKey: "classes")
                let userObject = User(token: user.string(forKey: "token"), userName: user.string(forKey: "username"), schoolId: user.string(forKey: "schoolId"), firstName: user.string(forKey: "firstName"), lastName: user.string(forKey: "lastName"), userId: user.integer(forKey: "userId"), email: user.string(forKey: "email"), googleToken: "", gender: user.string(forKey: "gender"), cycle: user.string(forKey: "cycle"), photo: user.string(forKey: "photo"), userType: user.integer(forKey: "userType"), batchId: user.integer(forKey: "batchId"), imperiumCode: user.string(forKey: "imperiumCode"), className: user.string(forKey: "classname"), childrens: [], classes: classes, privileges: user.strings(forKey: "privileges"), firstLogin: false, admissionNo: user.string(forKey: "studentUsername"), bdDate: user.dates(forKey: "dob"), isBdChecked: user.bool(forKey: "isBdChecked"), blocked: user.bool(forKey: "blocked"), password: user.string(forKey: "password"))
                userArray.append(userObject)
            }
            return userArray
        }
        catch {
            return nil
        }
        
    }
    
    class func getSchoolActivation(schoolID: String) -> SchoolActivation?{
        var schoolObject: SchoolActivation?
        print("schoolObject: \(schoolObject)")
//        let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOLDATA")
        let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let school = try? managedContext.fetch(schoolFetchRequest) as! [SCHOOL]
        if school != nil{
            for object in school! {
                print("schoolObject1: \(object)")
                print("params: \(object.schoolId)")
                print("params: \(object.id)")
                print("params: \(schoolID)")
                print("params: \(object.schoolId == schoolID)")

                if object.schoolId == schoolID{
                    schoolObject = SchoolActivation(id: Int(object.id), logo: object.logo!, schoolURL: object.url!, schoolId: object.schoolId!, name: object.name!, website: object.website!, location: object.location!, lat: object.lat, long: object.long, facebook: object.facebook!, twitter: object.twitter!, linkedIn: object.linkedIn!, google: object.google!, instagram: object.instagram!, phone: object.phone!, code: object.code!)
                    print("school url: \(schoolObject!.schoolURL)")
                    UserDefaults.standard.set(schoolObject!.schoolURL, forKey: "BASEURL")
                }
            }
        }
        print("schoolObject2: \(schoolObject)")

        return schoolObject
    }
    
    class func getArmenianMonth (month: Int) -> String{
        switch month {
        case 1:
            return "Յունուար"
        case 2:
            return "Փետրուար"
        case 3:
            return "Մարտ"
        case 4:
            return "Ապրիլ"
        case 5:
            return "Մայիս"
        case 6:
            return "Յունիս"
        case 7:
            return "Յուլիս"
        case 8:
            return "Օգոստոս"
        case 9:
            return "Սեպտեմբեր"
        case 10:
            return "Հոկտեմբեր"
        case 11:
            return "Նոյեմբեր"
        case 12:
            return "Դեկտեմբեր"
        default:
            return "Յունուար"
        }
    }
    class func hexStringToUIColor (hex:String, alpha: CGFloat) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    class func hexStringToUIColorCst (hex:String, alpha: CGFloat) -> UIColor {
            var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }
            
            if ((cString.count) != 6) {
                return UIColor.gray
            }
            
            var rgbValue:UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha
            )
        }
    
    class func fileSize(fromPath path: String) -> String? {
        guard let size = try? FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.size],
            let fileSize = size as? UInt64 else {
                return nil
        }
        
        // bytes
        if fileSize < 1023 {
            return String(format: "%lu bytes", CUnsignedLong(fileSize))
        }
        // KB
        var floatSize = Float(fileSize / 1024)
        if floatSize < 1023 {
            return String(format: "%.1f KB", floatSize)
        }
        // MB
        floatSize = floatSize / 1024
        if floatSize < 1023 {
            return String(format: "%.1f MB", floatSize)
        }
        // GB
        floatSize = floatSize / 1024
        return String(format: "%.1f GB", floatSize)
    }
    
    class func loading() -> UIView {
        let loading = VisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        loading.colorTint = .white
        loading.colorTintAlpha = 0.6
        loading.blurRadius = 1
        loading.tag = 1500
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .whiteLarge
        loadingIndicator.color = UIColor.black
        loadingIndicator.startAnimating()
        loadingIndicator.center = loading.center
        
        loading.contentView.addSubview(loadingIndicator)
        return loading
    }
    
    class func loadingWithText() -> UIView {
        let loading = VisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        loading.colorTint = .white
        loading.colorTintAlpha = 0.6
        loading.blurRadius = 1
        loading.tag = 1500

        let messageLabel = UILabel()
        messageLabel.text = "Setting up Conversation.\nPlease wait..."  // Set your desired message here, with a line break
        messageLabel.textColor = UIColor.black
        messageLabel.font = UIFont.systemFont(ofSize: 15) // Set the desired font size
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 2 // Set the number of lines to 2
        messageLabel.lineBreakMode = .byWordWrapping // Choose the line break mode
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add the message label to the contentView
        loading.contentView.addSubview(messageLabel)

        // Center the message label horizontally
        messageLabel.centerXAnchor.constraint(equalTo: loading.contentView.centerXAnchor).isActive = true

        // Center the message label vertically
        messageLabel.centerYAnchor.constraint(equalTo: loading.contentView.centerYAnchor).isActive = true



        // Add the VisualEffectView to the view hierarchy
        return loading


    }
    
    class func loadingBlendedLearing() -> UIView {
        let loading = VisualEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            loading.colorTint = .white
            loading.colorTintAlpha = 0.6
            loading.blurRadius = 1
            loading.tag = 1500

            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .whiteLarge
            loadingIndicator.color = UIColor.black
            loadingIndicator.startAnimating()
            loadingIndicator.center = CGPoint(x: loading.center.x, y: loading.center.y - 20) // Lift the loading indicator

            loading.contentView.addSubview(loadingIndicator)

            let messageLabel = UILabel()
            messageLabel.text = "Setting up your\nBlended Learning..."  // Set your desired message here, with a line break
            messageLabel.textColor = UIColor.black
            messageLabel.font = UIFont.systemFont(ofSize: 15) // Set the desired font size
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 2 // Set the number of lines to 2
            messageLabel.lineBreakMode = .byWordWrapping // Choose the line break mode
            messageLabel.translatesAutoresizingMaskIntoConstraints = false

            // Add the message label to the contentView
            loading.contentView.addSubview(messageLabel)

            // Center the message label horizontally
            messageLabel.centerXAnchor.constraint(equalTo: loading.contentView.centerXAnchor).isActive = true

            // Center the message label vertically below the loading indicator
            messageLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 10).isActive = true

            return loading
    }
    
    class func isValidPhone(_ phone: String) -> Bool {
        
        let PHONE_REGEX = "^[0-9]+$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phone)
        return result
    }
    
    class func base64Convert(base64String: String?) -> UIImage {
        let fallback = #imageLiteral(resourceName: "avatar")
        let temp = base64String?.components(separatedBy: ",") ?? []
        if temp.count < 2 {
            return fallback
        }
        if let dataDecoded = Data(base64Encoded: temp[1], options: .ignoreUnknownCharacters) {
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage ?? fallback
        }
        
        return fallback
    }
    
    class func eventBase64Convert(base64String: String?) -> UIImage{
        let fallback = #imageLiteral(resourceName: "whiteEvent")
        let temp = base64String?.components(separatedBy: ",") ?? []
        if temp.count < 2 {
            return fallback
        }
        if let dataDecoded = Data(base64Encoded: temp[1], options: .ignoreUnknownCharacters) {
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage ?? fallback
        }
        
        return fallback
    }
    
    class func holidayBase64Convert(base64String: String?) -> UIImage{
        let fallback  = #imageLiteral(resourceName: "holiday-default")
        let temp = base64String?.components(separatedBy: ",") ?? []
        if temp.count < 2 {
            return fallback
        }
        if let dataDecoded = Data(base64Encoded: temp[1], options: .ignoreUnknownCharacters) {
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage ?? fallback
        }
        
        return fallback
    }
    
    class func logout() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
        
        do {
            let users = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for user in users {
                managedContext.delete(user)
            }
            do {
                try managedContext.save()
                return true
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
                return false
            }
        } catch let error as NSError {
            print("logging out error : \(error) \(error.userInfo)")
            return false
        }
    }
    
    class func showLoginPage(){
        print("login1")
        let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
        let login = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let navController = UINavigationController(rootViewController: login)
        navController.modalPresentationStyle = .fullScreen
        UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.5, options: .transitionCrossDissolve, animations: {() -> Void in
            UIApplication.shared.keyWindow!.rootViewController! = navController
        }, completion: { _ in })
    }
    
    
    /// Description:
    /// - Remove school related to the activation code from core data.
    /// - Remove users related to this school.
    class func removeSchoolUsers(activationCode: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
//        let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOLDATA")
        print("removeSchoolUsers")
        let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
        
        do {
            let users = try managedContext.fetch(userFetchRequest) as! [USER]
            let schools = try managedContext.fetch(schoolFetchRequest) as! [SCHOOL]
            for user in users {
                if user.schoolId == activationCode{
                    managedContext.delete(user)
                }
            }
            for school in schools{
                if school.schoolId == activationCode{
                    managedContext.delete(school)
                }
            }
            do {
                try managedContext.save()
                return true
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
                return false
            }
        } catch let error as NSError {
            print("logging out error : \(error) \(error.userInfo)")
            return false
        }
    }
    
    class func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat{
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
    class func radians(_ degrees: Double) -> Double {
        return Double.pi * degrees / 180.0
    }
    
    class func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
}

extension String {
    var unescaped: String {
        let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\"]
        var current = self
        for entity in entities {
            let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
            let description = String(descriptionCharacters)
            current = current.replacingOccurrences(of: description, with: entity)
        }
        return current
    }
}

extension UIView{
    func image() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        UIColor.white.setFill()
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension Date{
    var lastHour: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
}

extension CGFloat {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random,
                       green: .random,
                       blue:  .random,
                       alpha: 1.0)
    }
}

