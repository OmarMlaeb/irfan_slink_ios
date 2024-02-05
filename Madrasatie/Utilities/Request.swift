//
//  Request.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/23/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase
import MobileCoreServices
import AVFoundation
import AVKit
import JWTDecode

class Request{
    
    var manager: SessionManager
    var baseURL = UserDefaults.standard.string(forKey: "BASEURL")
    
    ////////////////////////////////////////////////devo/////////////////////////////////////////////////////
//    var GET_SCHOOL_URL = "https://ne8yyqm707.execute-api.eu-west-1.amazonaws.com/devo";
//    var LOGIN_URL = "https://r6jo3sr176.execute-api.eu-west-1.amazonaws.com/devo";
//    var CALENDAR_EVENTS_URL = "https://syerwvipif.execute-api.eu-west-1.amazonaws.com/devo";
//    var AGENDA_ASSIGNMENTS_URL = "https://gronreec79.execute-api.eu-west-1.amazonaws.com/devo";
//    var GET_TEACHERS_URL = "https://0iaz49bv34.execute-api.eu-west-1.amazonaws.com/devo";
//    var GET_STUDENTS_URL = "https://sxxy236x1m.execute-api.eu-west-1.amazonaws.com/devo";
//    var MESSAGES_URL = "https://tpaoryne61.execute-api.eu-west-1.amazonaws.com/devo";
//    var ATTENDANCE_URL = "https://6cgm6wy98e.execute-api.eu-west-1.amazonaws.com/devo";
//    var TIMETABLE_URL = "https://v3mhoevn18.execute-api.eu-west-1.amazonaws.com/devo";
//    var NOTIFICATIONS_URL = "https://yyflvtgz0j.execute-api.eu-west-1.amazonaws.com/devo";
//    var GRADEBOOK_URL = "https://a2wqr2yg0f.execute-api.eu-west-1.amazonaws.com/devo";
//    var BLENDED_LEARNING_URL = "https://6xwgshy2b4.execute-api.eu-west-1.amazonaws.com/devo";
    
    // Augmental
    var AUGMENTAL_URL = "https://prod-gateway.augmental.xyz/api/Institutions";
    var AUGMENTAL_LOGIN_URL = "https://skills4success.augmentalapp.com";

    ////////////////////////////////////////////////prod/////////////////////////////////////////////////////
    var GET_SCHOOL_URL = "https://96u1tdypxl.execute-api.eu-west-1.amazonaws.com/prod";
    var LOGIN_URL = "https://hauwtt40ig.execute-api.eu-west-1.amazonaws.com/prod";
    var CALENDAR_EVENTS_URL = "https://q4xj7zvvn6.execute-api.eu-west-1.amazonaws.com/prod";
    var AGENDA_ASSIGNMENTS_URL = "https://rpyi5m1opi.execute-api.eu-west-1.amazonaws.com/prod";
    var GET_TEACHERS_URL = "https://5a8kr7n1m0.execute-api.eu-west-1.amazonaws.com/prod";
    var GET_STUDENTS_URL = "https://ury8mtwvb8.execute-api.eu-west-1.amazonaws.com/prod";
    var MESSAGES_URL = "https://nn8a3b0wyg.execute-api.eu-west-1.amazonaws.com/prod";
    var ATTENDANCE_URL = "https://gyiw3rutv2.execute-api.eu-west-1.amazonaws.com/prod";
    var TIMETABLE_URL = "https://ha0vxkks61.execute-api.eu-west-1.amazonaws.com/prod";
    var NOTIFICATIONS_URL = "https://nwdepwfj8g.execute-api.eu-west-1.amazonaws.com/prod";
    var GRADEBOOK_URL = "https://2q8oej5jx1.execute-api.eu-west-1.amazonaws.com/prod";
    var BLENDED_LEARNING_URL = "";

    let fedenaURL = "http://apis.fedena.com/fedena/"
//    let imperiumURL = "https://madrasati.imperiumcms.net/apis/"
//    let imperiumURL = "http://ec2-52-213-45-201.eu-west-1.compute.amazonaws.com/apis/"
    let imperiumURL = "http://admin.madrasatie.online/apis/"
    let languageId = UserDefaults.standard.string(forKey: "languageId") ?? "en"
    let DEBUG = false
    let agendaType = AgendaDetail.agendaType.self
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateFormatterNew: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var tFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
//        formatter.locale = Locale(identifier: "\(self.languageId)")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    fileprivate lazy var dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy HH:mm:ss"
//        formatter.locale = Locale(identifier: "\(App.languageId ?? "en")")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    
    static var shared: Request{
        return Request()
    }
    
    init() {
        self.manager = Alamofire.SessionManager.default
        self.manager.session.configuration.timeoutIntervalForRequest = 30
        self.manager.session.configuration.timeoutIntervalForResource = 30
    }
    
    func reportError(message: String){
        let userInfo = ["message" : message]
        let errorFirebase = NSError(domain: "AppErrorDomain", code: 1, userInfo: userInfo)
        Crashlytics.crashlytics().record(error: errorFirebase)
//        Crashlytics.sharedInstance().recordError(errorFirebase)
    }
    
   
    //SignIn API:
    func SignIn(userName: String, password: String, schoolUrl: String, grantType: String, completion: @escaping(_ message: String?, _ result: User?, _ status: Int?)->Void){
        
        
        let signInURL = "\(LOGIN_URL)/login_user"
            let params = [
                "username": "\(userName)",
                "password": "\(password)",
                ]
        
        print(signInURL)
        print(params)
        print(schoolUrl)
        var headers: HTTPHeaders = [
            "origin": schoolUrl // You can add more headers as needed
        ]
        

        print(headers)
        
        
        self.manager.request(signInURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    print("==>req signin", response)
                    var message = json["message"].stringValue
                    let response = json["response"]
                    print("----------------------------------")
                    print(response)
                           
                    var status = 0;
                    if(message.contains("Successfully Login")){
                        status = 200
                    }
                    else{
                        let arr = message.split(separator: ",")
                        if(arr.count > 0){
                            message = String(arr[0])
                        }
                    }
                    if(status == 200){
                        do{
                            let jwt = try decode(jwt: response.stringValue)
                            print(jwt)
                            print(jwt.body)
                            print(jwt.body["id"])

                            var id = 0
                            var username = ""
                            var email = ""
                            var role = ""
                            var schoolId = ""
                            
                            if let id1 = jwt.body["id"] as? Int{
                                id = id1
                            }
                            if let username1 = jwt.body["username"] as? String{
                                username = username1
                            }
                            if let role1 = jwt.body["role"] as? String{
                                role = role1
                            }
                            if let email1 = jwt.body["email"] as? String{
                                email = email1
                            }
                            if let schoolId1 = jwt.body["schoolId"] as? String{
                                schoolId = schoolId1
                            }
                           
                            
                            var userType = 1

                            if(role == "admin"){
                                userType = 1
                            }
                            else if(role == "teacher"){
                                userType = 2
                            }
                            else if(role == "student"){
                                userType = 3
                            }
                            else{
                                userType = 4
                            }

                            print("id: \(id)")
                            
   
                            var classesArray: [Class] = []
  
                            
                            
                            var userData = User(token: response.stringValue, userName: username ?? "", schoolId: schoolId ?? "", firstName: "", lastName: "", userId: id ?? 0, email: email, googleToken: "", gender: "", cycle: "", photo: "", userType:userType, batchId: 1, imperiumCode: "", className: "", childrens: [], classes: classesArray, privileges: [], firstLogin: true, admissionNo: "", bdDate: Date(), isBdChecked: false, blocked: false, password: password)
                            
                            print("SAVINGGGG EMAIL1 ", userData.email)
                            
                            if(role.lowercased() == "student"){
                                self.getUserType(id: id ?? 0, type: role.lowercased() ?? "student", token: response.stringValue, schoolUrl: schoolUrl){ section in
                                    print("User type received:", section)
                                    
                                    let sectionArray = section.components(separatedBy: "???")
                                    let sectionId = sectionArray[0].components(separatedBy: "=")[1]
                                    let sectionName = sectionArray[1].components(separatedBy: "=")[1]
                                    let className = sectionArray[2].components(separatedBy: "=")[1]
                                    let studentId = sectionArray[3].components(separatedBy: "=")[1]

                                    print(sectionArray)
                                    print(sectionId)
                                    print(sectionName)
                                    print(className)
                                    print(studentId)

                                    let cls = Class(batchId: Int(sectionId) ?? 0, className: "\(className)-\(sectionName)", imperiumCode: "")
                                    classesArray.append(cls)
                                    userData = User(token: response.stringValue, userName: username , schoolId: schoolId , firstName: "", lastName: "", userId: id, email: email, googleToken: "", gender: "", cycle: "", photo: "", userType: userType, batchId: Int(sectionId) ?? 0, imperiumCode: "", className: "\(className)-\(sectionName)", childrens: [], classes: classesArray, privileges: [], firstLogin: true, admissionNo: studentId, bdDate: Date(), isBdChecked: false, blocked: false, password: password)
                                    
                                    print("SAVINGGGG EMAIL2 ", userData.email)
                                    
                                    print("user user final: \(userData)")
                                    completion(message,userData,200)


                                }

                            }
                            else if(role.lowercased() == "admin" || role.lowercased() == "teacher"){
                                self.getParentDetails(id: id ?? 0, type: role.lowercased() ?? "teacher", token: response.stringValue, schoolUrl: schoolUrl){ data in
                                    print("User type received11:", data)
                                    
                                    let employee_id = data["id"].stringValue
                                    print("User type received11:", employee_id)

                                    userData = User(token: response.stringValue, userName: username ?? "", schoolId: schoolId ?? "", firstName: "", lastName: "", userId: id, email: email, googleToken: "", gender: "", cycle: "", photo: "", userType:userType, batchId: 1, imperiumCode: employee_id, className: "", childrens: [], classes: classesArray, privileges: [], firstLogin: true, admissionNo: "", bdDate: Date(), isBdChecked: false, blocked: false, password: password)
                                    
                                    print("SAVINGGGG EMAIL3 ", userData.email)
                                    
                                    print("user user final: \(userData)")
                                    completion(message,userData,200)


                                }
                            }
                            else if(role.lowercased() == "parent"){

                                var childrenArray: [Children] = []
                                self.getParentDetails(id: id ?? 0, type: role.lowercased() ?? "parent", token: response.stringValue, schoolUrl: schoolUrl){ data in
                                    print("User type received:", data)
                                    
                                    let children = data["family"]["students"]
                                    for child in children{
                                        let childGender = child.1["user"]["gender"].stringValue.lowercased()
                                        let childCycle = child.1["cycle"].stringValue
                                        let childPhoto = child.1["user"]["profilePictureUrl"].stringValue
                                        let childFirstName = child.1["user"]["firstName"].stringValue
                                        let childLastName = child.1["user"]["lastName"].stringValue
                                        let childAdmissionNo = child.1["id"].stringValue
                                        let childClassInfo = child.1["section"]
                                        let isChildBdChecked = true
                                        let childDob = child.1["user"]["dateOfBirth"].stringValue
                                        let childBithday = App.dateFormatter.date(from: childDob)
                                    
                                        let childClass = childClassInfo["classOfAcademicYear"]
                                        let childBatchId = childClassInfo["id"].intValue
                                        let childClassName = "\(childClass["code"].stringValue)-\(childClassInfo["code"].stringValue)"
                                        let childImperiumCode = "\(childClass["code"].stringValue)-\(childClassInfo["code"].stringValue)"
                                    
                                    
                                        let children = Children(gender: childGender, cycle: childCycle, photo: childPhoto, firstName: childFirstName, lastName: childLastName, batchId: childBatchId, imperiumCode: childImperiumCode, className: childClassName, admissionNo: childAdmissionNo, bdDate: childBithday ?? Date(), isBdChecked: isChildBdChecked)
                                        childrenArray.append(children)
                                    }
                                    
    //                                let cls = Class(batchId: Int(sectionId) ?? 0, className: "\(className)-\(sectionName)", imperiumCode: "")
    //                                classesArray.append(cls)
                                    
                                  
                                    
                                    var userData = User(token: response.stringValue, userName: username ?? "", schoolId: schoolId ?? "", firstName: "", lastName: "", userId: id, email: email, googleToken: "", gender: "", cycle: "", photo: "", userType:userType, batchId: 1, imperiumCode: "", className: "", childrens: childrenArray, classes: classesArray, privileges: [], firstLogin: true, admissionNo: "", bdDate: Date(), isBdChecked: false, blocked: false, password: password)
                                    
                                    print("SAVINGGGG EMAIL4 ", userData.email)
                                    
                                    print("user user final: \(userData)")
                                    completion(message,userData,200)


                                }
                            }
//                            else{
//                                completion(message,userData,200)
//
//                            }
                            
                        }
                        catch{
                            print("Error parsing JSON")
                            
                            // Failed server response
                            let description = response["message"].stringValue
                            self.reportError(message: description)
                            completion(description,nil,400)
                        }
                    }
                    else{
                        self.reportError(message: message)
                        completion(message,nil,400)
                    }
               
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
    }
    
    
    //User Details API:
    func getUserType(id: Int, type: String, token: String, schoolUrl: String, completion: @escaping (String) -> Void) {
        let userDetailURL = "\(LOGIN_URL)/user_type?userId=\(id)&userRole=\(type)"
        
        var headers: HTTPHeaders = [
            "origin": schoolUrl, // You can add more headers as needed
            "Authorization": token
        ]
        print("getUserType1: ", userDetailURL)

        self.manager.request(userDetailURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("getUserType: ", json)
                        #endif
                        let status = 200
                        let message = json["message"].stringValue
                        let data = json["response"]
                        
                        if status == 200 {
                            
                            let section = "sectionId=\(data["section"]["id"].stringValue)???sectionCode=\(data["section"]["code"].stringValue)???className=\(data["section"]["classOfAcademicYear"]["code"].stringValue)???studentId=\(data["id"])"
                            
                            completion(section)
                        }
                        else {
                            // Failed server response
                            completion("")

                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion("")

                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion("")

                        }
                        else {
                            completion("")

                        }
                    }
                }
        
    }
    
    
    
    func getParentDetails(id: Int, type: String, token: String, schoolUrl: String, completion: @escaping (JSON) -> Void) {
        let userDetailURL = "\(LOGIN_URL)/user_type?userId=\(id)&userRole=\(type)"
        
        var headers: HTTPHeaders = [
            "origin": schoolUrl, // You can add more headers as needed
            "Authorization": token
        ]
        print("getUserType1: ", userDetailURL)

        self.manager.request(userDetailURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("getUserType: ", json)
                        #endif
                        let status = 200
                        let message = json["message"].stringValue
                        let data = json["response"]
                        
                        if status == 200 {
                            completion(data)
                        }
                        else {
                            // Failed server response
                            completion("")

                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion("")

                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion("")

                        }
                        else {
                            completion("")

                        }
                    }
                }
        
    }
    
    
    //User Details API:
    func getUserDetails(id: Int, token: String, schoolUrl: String, password: String, completion: @escaping(_ message: String?, _ result: User?, _ status: Int?)->Void){
        let userDetailURL = "\(LOGIN_URL)/user?id=\(id)"
        
        var headers: HTTPHeaders = [
            "origin": schoolUrl, // You can add more headers as needed
            "Authorization": token
        ]
        
        self.manager.request(userDetailURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("getUserDetails ", json)
                        #endif
                        let status = 200
                        let message = json["message"].stringValue
                        let data = json["response"]
                        
                        if status == 200 {
                            var childrenArray: [Children] = []
                            var classesArray: [Class] = []
                            var privilegeArray: [String] = []
                            
                            let id = data["id"].intValue
                            let gender = "f"
//                            let cycle = data["cycle"].stringValue
//                            let photo = data["profilePictureUrl"].stringValue
                            let photo = "dl4a9z4gqzf0z.cloudfront.net/uploads/3636/employees/photos/80946/original/20200124090138/age-group-woman-circle._CB278609004_.png?Expires=1690878000&Signature=TKnA-ouHEWAt1r8Ksftz~RcHYZ8KTRNjQHEoZCB0k8Nq8PMOGCaxjNhpoUbXBle6nfovNy4BDFmy~F8a-K3nxVvxP~Fio3l62Kh5T~Xeij9U68ikYOMEvHd12n-y5ldNEeJoe2boQp8GoVi3-0JBqsl39zAg6dQURzyo1~qtiNYfH5QRNpo3X9vYs9TOrW-c1o2tTNW2xR8NysVPyb-EE78nPRnIgOqNaBWZpe3Gh2-URm0suA7989VdaOv7PB017Q1e9Q-zD1CXqpjBw6pRef2h7ZSZ1AZwox1g7yg4dBXCetjUU244qB8NhBlQEOzrYyhSfhHsHXdnR7rpwyESOg__&Key-Pair-Id=APKAIBA66IBPTTRR7HRQ"
//                            let isBdChecked = data["checked_bday"].boolValue
                            let dob = data["dateOfBirth"].stringValue
                            let bithday = App.dateFormatter.date(from: dob)
                            
//                            let userInfo = userDetail["user"]
                            let type = data["userRole"]["roleName"].stringValue
                            var userType = 1
                            
                            if(type == "admin"){
                                userType = 1
                            }
                            else if(type == "teacher"){
                                userType = 2
                            }
                            else if(type == "student"){
                                userType = 3
                            }
                            else{
                                userType = 4
                            }
                            let username = data["username"].stringValue
                            let firstName = data["firstName"].stringValue
                            let email = data["email"].stringValue
                            let schoolId = data["userRole"]["schoolId"].stringValue

//                            let blocked = userInfo["blocked"].boolValue
                            let lastName = data["lastName"].stringValue
//                            let firstTime = userInfo["first_login"].boolValue
                            let firstTime = false
                            

                            
//                            let privileges = userInfo["privileges"]
                            
//                            let classInfo = userDetail["class"]
//                            let batchId = classInfo["batch_id"].intValue
//                            let className = classInfo["class_name"].stringValue
//                            let imperiumCode = classInfo["imperium_code"].stringValue
                            
//                            if userType == 4{
//                                let childrens = userDetail["children"]
//                                for child in childrens{
//                                    let childGender = child.1["gender"].stringValue.lowercased()
//                                    let childCycle = child.1["cycle"].stringValue
//                                    let childPhoto = child.1["photo_link"].stringValue
//                                    let childFirstName = child.1["first_name"].stringValue
//                                    let childAdmissionNo = child.1["admission_no"].stringValue
//                                    let childClassInfo = child.1["class"]
//                                    let isChildBdChecked = child.1["checked_bday"].boolValue
//                                    let childDob = child.1["dob"].stringValue
//                                    let childBithday = App.dateFormatter.date(from: childDob)
//
//                                    let childBatchId = childClassInfo["batch_id"].intValue
//                                    let childClassName = childClassInfo["class_name"].stringValue
//                                    let childImperiumCode = childClassInfo["imperium_code"].stringValue
//
//                                    let children = Children(gender: childGender, cycle: childCycle, photo: childPhoto, firstName: childFirstName, lastName: lastName, batchId: childBatchId, imperiumCode: childImperiumCode, className: childClassName, admissionNo: childAdmissionNo, bdDate: childBithday ?? Date(), isBdChecked: isChildBdChecked)
//                                    childrenArray.append(children)
//                                }
//                            }
                            
//                            if userType == 2{
//                                for privilege in privileges{
//                                    privilegeArray.append(privilege.1.stringValue)
//                                }
//                                let classesObject = userDetail["classes"]
//                                let classArray = classesObject["class"]
//                                for object in classArray{
//                                    let id = object.1["batch_id"].intValue
//                                    let name = object.1["class_name"].stringValue
//                                    let imperiumCode = object.1["imperium_code"].stringValue
//
//                                    let clas = Class(batchId: id, className: name, imperiumCode: imperiumCode)
//                                    classesArray.append(clas)
//                                }
//                            }
                            
//                            let staticJSON = """
//                                {
//                                    "class": [
//                                        {
//                                            "imperium_code": "GR5",
//                                            "batch_id": 91200,
//                                            "class_name": "Gr5 - A"
//                                        },
//                                        {
//                                            "imperium_code": null,
//                                            "batch_id": 91923,
//                                            "class_name": "G 1A - 2021"
//                                        },
//                                        {
//                                            "imperium_code": null,
//                                            "batch_id": 92790,
//                                            "class_name": "Gr1 - A - 1718"
//                                        },
//                                        {
//                                            "imperium_code": null,
//                                            "batch_id": 92768,
//                                            "class_name": "Gr123 - A – 2021"
//                                        },
//                                        {
//                                            "imperium_code": "GR6",
//                                            "batch_id": 91202,
//                                            "class_name": "Gr6 - A 2021"
//                                        },
//                                        {
//                                            "imperium_code": null,
//                                            "batch_id": 91812,
//                                            "class_name": "Gr8 - IS"
//                                        },
//                                        {
//                                            "imperium_code": null,
//                                            "batch_id": 92901,
//                                            "class_name": "Gr8 - rt"
//                                        }
//                                    ]
//                                }
//                            """
//
//                            let jsonData = Data(staticJSON.utf8)
//
//                            do {
//                                // Convert JSON data to Swift objects (e.g., an array of `Class` objects)
//                                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
//
//                                if let jsonDictionary = jsonObject as? [String: Any],
//                                   let classes = jsonDictionary["class"] as? [[String: Any]] {
//                                    // Now, you can parse the individual classes and create your Swift objects
//
//                                    for classDict in classes {
//                                        if let imperiumCode = classDict["imperium_code"] as? String,
//                                           let batchID = classDict["batch_id"] as? Int,
//                                           let className = classDict["class_name"] as? String {
//                                            let classObj = Class(batchId: batchID, className: className, imperiumCode: imperiumCode)
//                                            classesArray.append(classObj)
//                                        }
//                                    }
//
//                                    // Now you have the `classesArray`, which contains the parsed `Class` objects.
//                                    // You can do further processing or use the data as needed.
//                                }
//                            } catch {
//                                // Handle error
//                                print("Error: \(error)")
//                            }
//
//
                            let prev = """
                                {
                                     "privileges": [
                                                        "manage_news_privilege",
                                                        "manage_course_batch_privilege",
                                                        "subject_master_privilege",
                                                        "event_management_privilege",
                                                        "general_settings_privilege",
                                                        "sms_management_privilege",
                                                        "custom_report_control_privilege",
                                                        "custom_report_view_privilege",
                                                        "data_management_privilege",
                                                        "data_management_viewer_privilege",
                                                        "hostel_admin_privilege",
                                                        "librarian_privilege",
                                                        "placement_activities_privilege",
                                                        "task_management_privilege",
                                                        "transport_admin_privilege",
                                                        "inventory_manager_privilege",
                                                        "inventory_privilege",
                                                        "custom_import_privilege",
                                                        "discipline_privilege",
                                                        "send_email_privilege",
                                                        "email_alert_settings_privilege",
                                                        "document_manager_privilege",
                                                        "inventory_basics_privilege",
                                                        "app_frame_admin_privilege",
                                                        "tokens_privilege",
                                                        "oauth2_manage_privilege",
                                                        "manage_users_privilege",
                                                        "form_builder_privilege",
                                                        "inventory_sales_privilege",
                                                        "manage_audit_privilege",
                                                        "manage_roll_number_privilege",
                                                        "manage_alumni_privilege",
                                                        "reminder_manager_privilege",
                                                        "manage_groups_privilege",
                                                        "examination_control_privilege",
                                                        "enter_results_privilege",
                                                        "view_results_privilege",
                                                        "admission_privilege",
                                                        "students_control_privilege",
                                                        "manage_timetable_privilege",
                                                        "student_attendance_view_privilege",
                                                        "hr_settings_privilege",
                                                        "timetable_view_privilege",
                                                        "student_attendance_register_privilege",
                                                        "employee_attendance_privilege",
                                                        "payroll_and_payslip_privilege",
                                                        "employee_search_privilege",
                                                        "group_create_privilege",
                                                        "gallery_privilege",
                                                        "applicant_registration_privilege",
                                                        "student_view_privilege",
                                                        "blog_admin_privilege",
                                                        "poll_control_privilege",
                                                        "reports_view_privilege",
                                                        "classroom_allocation_privilege",
                                                        "manage_building_privilege",
                                                        "online_exam_control_privilege",
                                                        "miscellaneous_privilege",
                                                        "finance_reports_privilege",
                                                        "approve_reject_payslip_privilege",
                                                        "fee_submission_privilege",
                                                        "manage_fee_privilege",
                                                        "revert_transaction_privilege",
                                                        "manage_refunds_privilege",
                                                        "manage_student_record_privilege",
                                                        "manage_employee_privilege",
                                                        "employee_reports_privilege",
                                                        "manage_transfer_certificate_privilege",
                                                        "health_admin_privilege",
                                                        "competencies_admin_privilege",
                                                        "manage_message_privilege",
                                                        "fees_submission_without_discount",
                                                        "blended_learning_control_privilege"
                                                    ],
                                }
                            """

                            let prevData = Data(prev.utf8)

                            do {
                                // Convert JSON data to Swift objects
                                let prevObject = try JSONSerialization.jsonObject(with: prevData, options: [])
                                
                                if let jsonDictionary = prevObject as? [String: Any],
                                    let prevs = jsonDictionary["privileges"] as? [String] {
                                    // Now, you have the array of privilege strings directly

                                    privilegeArray = prevs

                                    // You can access the individual privileges in `privilegeArray` and perform further processing or use the data as needed.
                                    for privilege in privilegeArray {
                                        print("Privilege: \(privilege)")
                                    }
                                }
                            } catch {
                                // Handle error
                                print("Error: \(error)")
                            }
                            
                            var userData = User(token: token, userName: username, schoolId: schoolId, firstName: firstName, lastName: lastName, userId: id, email: email, googleToken: "", gender: gender, cycle: "", photo: photo, userType: userType, batchId: 0, imperiumCode: "", className: "", childrens: childrenArray, classes: classesArray, privileges: privilegeArray, firstLogin: firstTime, admissionNo: "", bdDate: bithday ?? Date(), isBdChecked: true, blocked: false, password: password)
                            
                            print("SAVINGGGG EMAIL5 ", userData.email)
                            
                            if(type.lowercased() == "student"){
                                self.getUserType(id: id ?? 0, type: type.lowercased() ?? "student", token: token, schoolUrl: schoolUrl){ section in
                                    print("User type received:", section)
                                    
                                    
                                    let sectionArray = section.components(separatedBy: "???")
                                    let sectionId = sectionArray[0].components(separatedBy: "=")[1]
                                    let sectionName = sectionArray[1].components(separatedBy: "=")[1]
                                    let className = sectionArray[2].components(separatedBy: "=")[1]
                                    let studentId = sectionArray[3].components(separatedBy: "=")[1]

                                    print(sectionArray)
                                    print(sectionId)
                                    print(sectionName)
                                    print(className)
                                    print(studentId)
                                    
                                    let cls = Class(batchId: Int(sectionId) ?? 0, className: "\(className)-\(sectionName)", imperiumCode: "")
                                    classesArray.append(cls)
                                    
                                    userData = User(token: token, userName: username, schoolId: schoolId, firstName: firstName, lastName: lastName, userId: id, email: email, googleToken: "", gender: gender, cycle: "", photo: photo, userType: userType, batchId: Int(sectionId) ?? 0, imperiumCode: "", className: "\(className)-\(sectionName)", childrens: childrenArray, classes: classesArray, privileges: privilegeArray, firstLogin: firstTime, admissionNo: studentId, bdDate: bithday ?? Date(), isBdChecked: true, blocked: false, password: password)
                                    
                                    print("SAVINGGGG EMAIL6 ", userData.email)
                                    
                                    print("get user details: \(userData)")

                                    completion(message,userData,status)

                                    
                                }
                            }
                            else if(type.lowercased() == "admin" || type.lowercased() == "teacher"){
                                self.getParentDetails(id: id ?? 0, type: type.lowercased() ?? "teacher", token: token, schoolUrl: schoolUrl){ data in
                                    print("User type received111:", data)
                                    
                                    
                                    let employee_id = data["id"].stringValue
                                    print("User type received11:", employee_id)

                                    var userData = User(token: token, userName: username, schoolId: schoolId, firstName: firstName, lastName: lastName, userId: id, email: email, googleToken: "", gender: gender, cycle: "", photo: photo, userType: userType, batchId: 0, imperiumCode: employee_id, className: "", childrens: childrenArray, classes: classesArray, privileges: privilegeArray, firstLogin: firstTime, admissionNo: "", bdDate: bithday ?? Date(), isBdChecked: true, blocked: false, password: password)
                                    
                                    print("SAVINGGGG EMAIL7 ", userData.email)
                                    
                                    print("user user final111: \(userData)")
                                    completion(message,userData,status)


                                }
                            }
                            else if(type.lowercased() == "parent"){


                                self.getParentDetails(id: id ?? 0, type: type.lowercased() ?? "parent", token: token, schoolUrl: schoolUrl){ data in
                                    print("User type received:", data)
                                    
                                    let children = data["family"]["students"]
                                    for child in children{
                                        let childGender = child.1["user"]["gender"].stringValue.lowercased()
                                        let childCycle = child.1["cycle"].stringValue
                                        let childPhoto = child.1["user"]["profilePictureUrl"].stringValue
                                        let childFirstName = child.1["user"]["firstName"].stringValue
                                        let childLastName = child.1["user"]["lastName"].stringValue
                                        let childAdmissionNo = child.1["id"].stringValue
                                        let childClassInfo = child.1["section"]
                                        let isChildBdChecked = true
                                        let childDob = child.1["user"]["dateOfBirth"].stringValue
                                        let childBithday = App.dateFormatter.date(from: childDob)
                                    
                                        let childClass = childClassInfo["classOfAcademicYear"]
                                        let childBatchId = childClassInfo["id"].intValue
                                        let childClassName = "\(childClass["code"].stringValue)-\(childClassInfo["code"].stringValue)"
                                        let childImperiumCode = "\(childClass["code"].stringValue)-\(childClassInfo["code"].stringValue)"
                                    
                                        let children = Children(gender: childGender, cycle: childCycle, photo: childPhoto, firstName: childFirstName, lastName: childLastName, batchId: childBatchId, imperiumCode: childImperiumCode, className: childClassName, admissionNo: childAdmissionNo, bdDate: childBithday ?? Date(), isBdChecked: isChildBdChecked)
                                        childrenArray.append(children)
                                    }
                                    
                                    
                                    
                                    var userData = User(token: token, userName: username, schoolId: schoolId, firstName: firstName, lastName: lastName, userId: id, email: email, googleToken: "", gender: gender, cycle: "", photo: photo, userType: userType, batchId: 0, imperiumCode: "", className: "", childrens: childrenArray, classes: classesArray, privileges: privilegeArray, firstLogin: firstTime, admissionNo: "", bdDate: bithday ?? Date(), isBdChecked: true, blocked: false, password: password)
                                    
                                    print("SAVINGGGG EMAIL8 ", userData.email)
                                    
                                    print("get user details: \(userData)")

                                    completion(message,userData,status)
                                    
                                   


                                }
                            }

                            else{
                                completion(message,userData,status)

                            }
                         
                            

                            
                        }
                        else {
                            // Failed server response
                            let description = data["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,nil,status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
        
    }
    
    //Get Phone Number And Email API:
    func GetPhoneEmail(username: String, user: User, completion: @escaping(_ message: String?, _ email: String?, _ phone: String?, _ status: Int?)->Void){
        let phoneEmailURL = "\(baseURL!)/api/user/get_phone_or_email"
        let params = [
            "username": "\(username)",
            "token": "\(user.token)"
            ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: phoneEmailURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                            let json = JSON(j)
                            let status = json["statusCode"].intValue
                            let message = json["statusMessage"].stringValue
                            let data = json["data"]
                            if status == 200{
                                let userDetail = data["user_details"]
                                let email = userDetail["email"].stringValue
                                let phone = userDetail["phone"].stringValue
                                completion(message,email,phone,status)
                            }else{
                                self.reportError(message: message)
                                completion(message,"","",status)
                            }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"","",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"","",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"","",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"","",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"","",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"","",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    // Send OTP API:
    func SendOTP(type: String, user: User, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let otpURL = "\(baseURL!)/api/user/forgot_password"
        let params = [
            "username": "\(user.userName)",
            "type": "\(type)",
            "token": "\(user.token)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: otpURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        let status = json["statusCode"].intValue
                        let message = json["statusMessage"].stringValue
                        let data = json["data"]
                        if status == 200 {
                            completion(message,data,status)
                        }else{
                            // Failed server response
                            let error = data["error_msgs"].stringValue
                            self.reportError(message: error)
                            completion(error,data,status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    // Get Leave Reasons:
    func getReasons(user: User, language: String, completion: @escaping(_ message: String?, _ result: [String]?, _ status: Int?)->Void){
        let reasonsURL = "\(baseURL!)/api/attendance/get_reasons"
        let params = [
            "token": "\(user.token)",
            "language": "\(language)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: reasonsURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        let status = json["statusCode"].intValue
                        let message = json["statusMessage"].stringValue
                        let data = json["data"]
                        
                        if status == 200 {
                            
                            let reasonsData = data["reasons"]
                            var reasons: [String] = []
                           

                            for reason in reasonsData{
                                reasons.append(reason.1.stringValue)
                            }
                            
                            completion(message,reasons,status)
                        }
                        else {
                            // Failed server response
                            let description = data["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,[],status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    // Submit Leave Reasons:
    func submitReasons(user: User, studentUsername: String, reason: String, periodArray: [Period], fullDay: Int, date: String, startDate: String, endDate: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let submitReasonURL = "\(ATTENDANCE_URL)/request_absence"

        var subjects = ""
        var periods = ""
        var dates = ""
        var dateArray = periodArray.map({return $0.date})
        dateArray = App.uniq(source: dateArray)
        
        for (index, period) in periodArray.enumerated(){
            if periodArray.count > 1{
                if index == 0{
                    subjects = "\(period.subjectId)"
                    periods = "\(period.periodId)"
                }else{
                    subjects = "\(subjects),\(period.subjectId)"
                    periods = "\(periods),\(period.periodId)"
                }
            }else{
                subjects = period.subjectId
                periods = period.periodId.description
            }
        }
        
        for (index, date) in dateArray.enumerated(){
            if dateArray.count > 1{
                if index == 0{
                    dates = "\(date)"
                }else{
                    dates = "\(dates),\(date)"
                }
            }else{
                dates = date
            }
        }
        
        let start = "\(date) \(startDate)"
        let end = "\(date) \(endDate)"

        let params = [
        
        [
            "key": "school_id",
            "value": "\(user.schoolId)",
            "type": "text"
          ],
          [
            "key": "student_id",
            "value": "\(user.admissionNo)",
            "type": "text"
          ],
          [
            "key": "section_id",
            "value": "\(user.batchId)",
            "type": "text"
          ],
          [
            "key": "absence_date",
            "value": "\(date)",
            "type": "text"
          ],
          [
            "key": "is_full_day",
            "value": "\(fullDay)",
            "type": "text"
          ],
        [
          "key": "start_time",
          "value": "\(start)",
          "type": "text"
        ],
        [
          "key": "end_time",
          "value": "\(end)",
          "type": "text"
        ],
        [
          "key": "absence_reason",
          "value": "\(reason)",
          "type": "text"
        ],
        [
          "key": "studentName",
          "value": "\(user.firstName) \(user.lastName)",
          "type": "text"
        ],
        [
          "key": "schoolName",
          "value": "slink",
          "type": "text"
        ],
        [
          "key": "createdBy",
          "value": "\(user.userId)",
          "type": "text"
        ],
        [
          "key": "verification_attachments",
          "value": "",
          "type": "file"
        ],
       
        ]
        
        print("params", params)
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for param in params {
                if let key = param["key"], let value = param["value"] {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }

        }, to: submitReasonURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let json):
                        
                        let data = JSON(json)
                        let message = data["message"].stringValue
                        var status = 0
                        
                        if(message.contains("Absence Request created")){
                            status = 200
                        }
                        let dataArray = data["data"]
                        print("response: \(data)")
                        
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            // Failed server response
                            let description = dataArray["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,dataArray,status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    //Get Calendar Data:
    func getCalendar(user: User, admissionNo: String, startDate: String, endDate: String, batchId: Int, calendarTheme: CalendarTheme, completion: @escaping(_ message: String?, _ result: [Event]?, _ status: Int?)->Void){
       
        
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.token)",
            "Content-Type": "application/json"
        ]
    
        print("\(CALENDAR_EVENTS_URL)/get_events?user_id=\(user.userId)&start_date=\(startDate)&end_date=\(endDate)")
        self.manager.request("\(CALENDAR_EVENTS_URL)/get_events?user_id=\(user.userId)&start_date=\(startDate)&end_date=\(endDate)&school_id=\(user.schoolId)", method: .get, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                    .responseJSON { response in
                        switch response.result{
                        case .success(let j):
                            let json = JSON(j)
                            print("get calendar events new: \(json)")
                            let data = json["response"]
                            let status = 200
                            let message = json["message"].stringValue
                            print(data)
                            let events = data["events"]
                            
                            var eventData: [Event] = []
                            var duesArray: [EventDetail] = []
                            var eventsArray: [EventDetail] = []
                            var holidaysArray: [EventDetail] = []
                            
                            
                            for event in events{
                                let type = event.1["event_type"].stringValue
                                
                                let name = event.1["title"].stringValue
                                let startdateData = event.1["start"].stringValue
                                let enddateData = event.1["end"].stringValue
                                let description = event.1["description"].stringValue
                                let id = event.1["id"].intValue
                                let image = event.1["thumbnail_attachment"].stringValue
                                
                                var allow_update = false
                                if(user.userType == 1){
                                    allow_update = true
                                }
                                
                                print("start start: \(startdateData)")
                                let date = self.dateTimeFormatter.string(from: self.dateFormatterNew.date(from: startdateData) ?? Date())
                                let enddate = self.dateTimeFormatter.string(from: self.dateFormatterNew.date(from: enddateData) ?? Date())
                                
                                var event_type = 0
                                switch type{
                                case "event":
                                    event_type = 1
                                case "meeting":
                                    event_type = 3
                                case "holiday":
                                    event_type = 2
                                default:
                                    event_type = 1
                                }
                           
                                switch event_type{
                                case 1:
                                    let detail = EventDetail(id: id, title: name, type: event_type, date: date, enddate: enddate, image: image, batches: "[]", departments: "[]", description: description, backgroudColor: calendarTheme.eventBg, topColor: calendarTheme.eventBg, allow_update: allow_update)
                                    eventsArray.append(detail)
                                    
                                case 3:
                                    let detail = EventDetail(id: id, title: name, type: event_type, date: date, enddate: enddate, image: image, batches: "[]", departments: "[]", description: description, backgroudColor: calendarTheme.dueBg, topColor: calendarTheme.dueBg, allow_update: allow_update)
                                    duesArray.append(detail)
                                    
                                case 2:
                                    let detail = EventDetail(id: id, title: name, type: event_type, date: date, enddate: enddate, image: image, batches:  "[]", departments: "[]", description: description, backgroudColor: calendarTheme.holidayBg, topColor: calendarTheme.holidayBg, allow_update: allow_update)
                                    holidaysArray.append(detail)
                                default:
                                    print("default")
                                }
                                
                             
                            }
        
                            var event = Event(id: 1, icon: calendarTheme.eventIcon, color: calendarTheme.eventBg, counter: eventsArray.count, type: self.agendaType.Events.rawValue, date: "", percentage: 0, detail: eventsArray, agendaDetail: [])
                            eventData.append(event)
                 
                            event = Event(id: 2, icon: calendarTheme.holidayIcon, color: calendarTheme.holidayBg, counter: holidaysArray.count, type: self.agendaType.Holidays.rawValue, date: "", percentage: 0, detail: holidaysArray, agendaDetail: [])
                            eventData.append(event)
                 
                            event = Event(id: 3, icon: calendarTheme.dueIcon, color: calendarTheme.dueBg, counter: duesArray.count, type: self.agendaType.Dues.rawValue, date: "", percentage: 0, detail: duesArray, agendaDetail: [])
                            eventData.append(event)
                            completion(message,eventData,status)
        
                        case .failure(let error):
        
                            let schoolData = SchoolActivation(id: 0, logo: "", schoolURL: "", schoolId: "", name: "", website: "", location: "", lat: 0.0, long: 0.0, facebook: "", twitter: "", linkedIn: "", google: "", instagram: "", phone: "", code: "")
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                }
        

        
    }
    
    //Get allowed recipients:
    func getAllowedRecipients(user: User, completion: @escaping(_ message: String?, _ result1: [MessageDepartment]?, _ result2: [CalendarEventItem]?, _ status: Int?)->Void){
        let usersURL = "\(baseURL!)/api/messages/get_allowed_recipients"
        
        let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: usersURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    
                    switch response.result {
                    case .success(let json):
                        #if DEBUG
                            print("==>getusers ", json)
                        #endif
                        let data = JSON(json)
                        let statusMessage = data["statusMessage"].stringValue
                        let status = data["statusCode"].intValue
                        let dataArray = data["data"]
                        let usersArray = dataArray["recipients"]
                        var departmentsList: [MessageDepartment] = []
                        
                        if status == 200 {
                            var employeesData: [Student] = []
                            var studentsData: [CalendarEventItem] = []
                            
//                            if(user.userType == 2){
                                let departments = usersArray["departments"]
                                
                                for dep in departments{
                                    let employees = dep.1["employees"]
                                    print("employees: \(employees)")
                                    
                                    let depId = dep.1["id"].stringValue
                                    let depName = dep.1["name"].stringValue
                                    for employee in employees{
                                        let id = employee.1["admission_no"].stringValue
                                        
                                        let name = employee.1["name"].stringValue
                                        let photo = employee.1["photo"].stringValue
                                        
                                        let user = Student(index: "0", id: id, fullName: name, photo: photo, mark: 0.0, selected: false, gender: "m", parent: false)
                                        employeesData.append(user);
                                    }
                                    
                                    let tempDep = MessageDepartment(id: depId, name: depName, employees: employeesData, active: false)
                                    departmentsList.append(tempDep)
                                    
                                    
                                }
                                
                                let students = usersArray["students"]
                                
                                for std in students{
                                    let id = std.1["id"].stringValue
                                    let name = std.1["name"].stringValue
                                    
                                    let user = CalendarEventItem(id: id, title: name, active: false, studentId: "")
                                    studentsData.append(user);
                                    
                                    
                                }
                                
//                                let parents = usersArray["parents"]
//
//                                for parent in parents{
//                                    let id = parent.1["id"].stringValue
//
//                                    let index = studentsData.firstIndex{$0.id == id}
//                                    if(index != nil){
//                                        studentsData[index!].active = true;
//                                    }
//                                }
                                
                              
                                
                                
//                            }
//                            else{
//
//                            }
                            
                            
                            
                           
                            completion(statusMessage,departmentsList, studentsData,status)
                        }else {
                            // Failed server response
                            let description = dataArray["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,[],[],status)
                            
                        }
                    case .failure(let error):
                        //TODO: add this to all errors
                        let error = error as NSError
                        if error.domain == NSURLErrorDomain {
                            completion("No internet connection available",[],[],App.STATUS_INVALID_RESPONSE)
                        } else {
                            completion(App.INVALID_RESPONSE,[],[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
  
    func createInboxMessage(user: User, title: String, agenda: AgendaExam, allSelectedUsers: [String], canReply: Bool, schoolInfo: SchoolActivation, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createSectionURL = "\(MESSAGES_URL)/onlineDiscussion/conversation/create"
            
        let scl = "{\"id\" : \"\(schoolInfo.id)\" , \"englishName\" : \"\(schoolInfo.name)\"}"

        let users = allSelectedUsers.map { Int($0) ?? 0 }
        
        let params = [
            [
                "key": "schoolObj",
                "value": "\(scl)",
                "type": "text"
              ],
        [
            "key": "title",
            "value": "\(title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
        [
            "key": "canSendAdmin",
            "value": "false",
            "type": "text"
          ],
       
        [
            "key": "canReply",
            "value": "\(canReply)",
            "type": "text"
          ],
        [
            "key": "type",
            "value": "text",
            "type": "text"
          ],
        [
            "key": "message",
            "value": "\(agenda.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
        [
            "key": "recipients",
            "value": "\(users)",
            "type": "text"
          ],
        ]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for param in params {
                if let key = param["key"], let value = param["value"] {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }


//            if profile?.size != CGSize(width: 0.0, height: 0.0){
//                if let profile = profile {
//                    multipartFormData.append(profile.jpeg(.lowest)!, withName: "file", fileName: filename, mimeType: "image/jpeg")
//                }
//            }

        }, to: createSectionURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                                  print("create convo response: \(j)")
                                      let json = JSON(j)
                                      let message = json["message"].stringValue
                                      let status = 200
                                      if status == 200 {
                                          let data = json["response"]
                                          completion(message,data,status)
                                                                              
                                      }
                                      else {
                                      // Failed server response
                                         let error = JSON(j)
                                         let statusCode = error["statusCode"].intValue
                                         let data = error["data"]
                                         let errorMessage = data["error_msgs"].stringValue
                                        print("status code: \(statusCode)")
                                        print("data: \(data)")
                                        print("errorMessage: \(errorMessage)")
                                         self.reportError(message: errorMessage)
                                         completion(errorMessage,error,statusCode)
                                  }
                              case .failure(let error):
                              
                                  if error._code == NSURLErrorTimedOut {
                                      completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                                  }
                                  else if error._code == NSFileNoSuchFileError {
                                    
                                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                  }
                                  else {
                                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                  }
                              }
                          }
                      case .failure(let error):
                              
                          if error._code == NSURLErrorTimedOut {
                              completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                          }
                          else if error._code == NSFileNoSuchFileError {
                              completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                          }
                          else {
                              completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                          }
                      }
                  })
              }
    
    func createInboxMessageWithAttachment(user: User, title: String, agenda: AgendaExam, file: URL?, fileCompressed: NSData? , image: UIImage?, isSelectedImage: Bool, filename: String, allSelectedUsers: [String], canReply: Bool, type: String, schoolInfo: SchoolActivation, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createSectionURL = "\(MESSAGES_URL)/onlineDiscussion/conversation/create"
        let scl = "{\"id\" : \"\(schoolInfo.id)\" , \"englishName\" : \"\(schoolInfo.name)\"}"

       
        let params = [
            [
                "key": "schoolObj",
                "value": "\(scl)",
                "type": "text"
              ],
        [
            "key": "title",
            "value": "\(title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
        [
            "key": "canSendAdmin",
            "value": "false",
            "type": "text"
          ],
       
        [
            "key": "canReply",
            "value": "\(canReply)",
            "type": "text"
          ],
        [
            "key": "type",
            "value": "\(type)",
            "type": "text"
          ],
       
        [
            "key": "recipients",
            "value": "\(allSelectedUsers)",
            "type": "text"
          ],
        ]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for param in params {
                if let key = param["key"], let value = param["value"] {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }

                if isSelectedImage{
                    multipartFormData.append(image!.jpeg(.lowest)!, withName: "message", fileName: filename, mimeType: "image/jpeg") //image!.jpegData(compressionQuality: 0.5)!
                }else{
                    let pdfData = try! Data(contentsOf: file!)
                    let filetype = file!.description.suffix(4)
                    print("file description: \(file!.description.suffix(4))")

                    var mimeType = ""
                    if filetype.lowercased() == ".pdf"{
                        mimeType = "application/pdf"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                    }else if filetype.lowercased() == "docx"{
                        mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                    }else if filetype.lowercased() == "xlsx"{
                        mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                    }else if filetype.lowercased() == "pptx" || filetype.lowercased() == "ppsx" || filetype.lowercased() == "ppt"{
                        mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                    }
                     else if filetype.lowercased() == ".m4a"{
                         mimeType = "audio/mpeg"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                     }
                     else if filetype.lowercased() == ".mp3" || filetype == ".mid" || filetype == ".midi" || filetype == ".kar" || filetype == ".ogg" || filetype == ".aac"{
                         mimeType = "audio/mpeg"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                     }
                    else if(filetype.lowercased() == ".gif"){
                        mimeType = "audio/gif"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                    }
                    else if(filetype.lowercased() == ".wma"){
                        mimeType = "audio/wma"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                    }
                    else if(filetype.lowercased() == ".rtf"){
                        mimeType = "application/rtf"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                    }
                    else if(filetype.lowercased() == ".txt"){
                        mimeType = "text/plain"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                    }
                    else if(filetype.lowercased() == ".csv"){
                        mimeType = "text/csv"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                    }
                    else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                         mimeType = "video/mp4"
                        multipartFormData.append(fileCompressed! as Data, withName: "message", fileName: filename, mimeType: mimeType)
                     }
                     else if filetype.lowercased() == ".wmv"{
                         mimeType = "video/x-ms-wmv"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                     }
                     else{
                         mimeType = "application/octet-stream"
                        multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)
                     }
                    

                    
                }
                         
        }, to: createSectionURL, method: .post, headers: headers, encodingCompletion: {
                  (result) in
                  switch result {
                  case .success(let upload, _, _):
                      upload.responseJSON {
                          response in
                          switch response.result {
                          case .success(let j):
                              
                                  let json = JSON(j)
                                  let message = json["message"].stringValue
                                  let status = 200
                                  if status == 200 {
                                      let data = json["response"]
                                      completion(message,data,status)
                                                                          
                                  }
                                  else {
                                  // Failed server response
                                     let error = JSON(j)
                                     let statusCode = error["statusCode"].intValue
                                     let data = error["data"]
                                     let errorMessage = data["error_msgs"].stringValue
                                     self.reportError(message: errorMessage)
                                     completion(errorMessage,error,statusCode)
                              }
                          case .failure(let error):
                          
                              if error._code == NSURLErrorTimedOut {
                                  completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                              }
                              else if error._code == NSFileNoSuchFileError {
                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                              }
                              else {
                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                              }
                          }
                      }
                  case .failure(let error):
                          
                      if error._code == NSURLErrorTimedOut {
                          completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                      }
                      else if error._code == NSFileNoSuchFileError {
                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                      }
                      else {
                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                      }
                  }
              })
          }
        
            
    
    func createAgendaDiscussion(user: User, title: String, assignmentId: Int, recipients: [Int], completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createSectionURL = "\(MESSAGES_URL)/onlineDiscussion/conversation/create_agenda"
            

        
        let params = [
            "title": title,
            "recipients": recipients,
            "canReply": "\(true)",
            "schoolId": "\(user.schoolId)",
            "assignmentId": "\(assignmentId)"
        ] as [String : Any]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.request(createSectionURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                                  print("create convo response: \(j)")
                                      let json = JSON(j)
                                      let message = json["message"].stringValue
                                      let status = 200
                                      if status == 200 {
                                          let data = json["response"]
                                          completion(message,data,status)
                                                                              
                                      }
                                      else {
                                      // Failed server response
                                         let error = JSON(j)
                                         let statusCode = error["statusCode"].intValue
                                         let data = error["data"]
                                         let errorMessage = data["error_msgs"].stringValue
                                        print("status code: \(statusCode)")
                                        print("data: \(data)")
                                        print("errorMessage: \(errorMessage)")
                                         self.reportError(message: errorMessage)
                                         completion(errorMessage,error,statusCode)
                                  }
                              case .failure(let error):
                              
                                  if error._code == NSURLErrorTimedOut {
                                      completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                                  }
                                  else if error._code == NSFileNoSuchFileError {
                                    
                                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                  }
                                  else {
                                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                  }
                              }
                          }
              }
    
    //Get messages Data:
    func getMessages(user: User, completion: @escaping(_ message: String?, _ result: [Inbox]?, _ status: Int?)->Void){
            let messagesURL = "\(MESSAGES_URL)/onlineDiscussion/conversations?schoolId=\(user.schoolId)"
           
            
            let headers: HTTPHeaders = [
                "origin": baseURL!, // You can add more headers as needed
                "Authorization": "Bearer \(user.token)"
            ]
            
            print("header header111: \(headers)")
            print(messagesURL)
            self.manager.request(messagesURL, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate { request, response, data in
                    return .success
                }
                .responseJSON { response in
                    switch response.result{
                    case .success(let json):
                            #if DEBUG
                                print("==>getmessages ", json)
                            #endif
                            let data = JSON(json)
                            let statusMessage = data["message"].stringValue
                            let status = 200
                            let dataArray = data["response"]
                            
                            if status == 200 {
                                var messagesData: [Inbox] = []
                                
                                
                                for object in dataArray{
                                    let id = object.1["id"].intValue
                                    let subject = object.1["title"].stringValue
                                    let date = object.1["createdAt"].stringValue
                                    let message = object.1["body"].stringValue
                                    let creator_name = "\(object.1["user"]["firstName"].stringValue) \(object.1["user"]["lastName"].stringValue)"
                                    let creator_id = object.1["user"]["id"].intValue
                                    let attachment_link = object.1["avatar"].stringValue
                                    let attachment_content_type = object.1["attachment_content_type"].stringValue
                                    let attachment_file_name = object.1["attachment_file_name"].stringValue
                                    let attachment_file_size = object.1["attachment_file_size"].stringValue
                                    let canReply = object.1["canReply"].boolValue
                                    let unreadMessages = object.1["onlineDiscussionMessages"].count
     
                                    let inbox = Inbox(id: id, date: date, subject: subject, message: message, creator_name: creator_name, creator_id: creator_id, attachment_link: attachment_link, attachment_content_type: attachment_content_type, attachment_file_name: attachment_file_name, attachment_file_size: attachment_file_size, canReply: canReply, unreadMessages: unreadMessages)
                                    
                                    messagesData.append(inbox)
                                }
                                completion(statusMessage,messagesData,status)
                            }else {
                                // Failed server response
                                let description = dataArray["error_msgs"].stringValue
                                self.reportError(message: description)
                                completion(description,[],status)
                            }
                        case .failure(let error):
                            //TODO: add this to all errors
                            let error = error as NSError
                            if error.domain == NSURLErrorDomain {
                                completion("No internet connection available",[],App.STATUS_INVALID_RESPONSE)
                            } else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                    }
            
        }
    
    //Get messages Data:
    func getUnreadMessages(user: User, completion: @escaping(_ message: String?, _ result: Int?, _ status: Int?)->Void){
        let messagesURL = "\(MESSAGES_URL)/onlineDiscussion/unread?schoolId=\(user.schoolId)"
       
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header111: \(headers)")
        print(messagesURL)
        self.manager.request(messagesURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let json):
                        #if DEBUG
                            print("==>getmessages111 ", json)
                        #endif
                        let data = JSON(json)
                        let statusMessage = data["message"].stringValue
                        let status = 200
                        
                        if status == 200 {
                            
                            let count = data["response"].intValue
                            
                            
                            completion(statusMessage,count,status)
                        }else {
                            // Failed server response
                            self.reportError(message: statusMessage)
                            completion(statusMessage,0,status)
                        }
                    case .failure(let error):
                        //TODO: add this to all errors
                        let error = error as NSError
                        if error.domain == NSURLErrorDomain {
                            completion("No internet connection available", 0 ,App.STATUS_INVALID_RESPONSE)
                        } else {
                            completion(App.INVALID_RESPONSE,0,App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
        
    }
    // Discussion messages APIs
        func messageRecipient(user: User, id: String,  colorList: [String], completion: @escaping(_ message: String?, _ result: [User], _ status: Int?)->Void){
            let messageURL = "\(MESSAGES_URL)/onlineDiscussion/members?conversationId=\(id)"
             
            let headers: HTTPHeaders = [
                "origin": baseURL!, // You can add more headers as needed
                "Authorization": "Bearer \(user.token)"
            ]
            
            print("header header111: \(headers)")
            print(messageURL)
            self.manager.request(messageURL, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate { request, response, data in
                    return .success
                }
                .responseJSON { response in
                    switch response.result{
                    case .success(let json):
                      #if DEBUG
                          print("==>getMessages111 ", json)
                      #endif
                      let response = JSON(json)
                      let statusMessage = response["message"].stringValue
                      let status = 200
                      let data = response["response"]
                       var userList: [User] = []
                      
                      if status == 200 {
                      
                       var index = 0
                       for message in data{
                           let firstName = message.1["firstName"].stringValue
                           let lastName = message.1["lastName"].stringValue
                           let studentFilename = message.1["student_file_name"].stringValue
                           let studentFilesize = message.1["student_file_size"].stringValue
                           let studentLink = message.1["profilePictureUrl"].stringValue
                           let section = message.1["section"].stringValue
                           let body = message.1["body"].stringValue
                           let fullName = "\(message.1["firstName"].stringValue) \(message.1["lastName"].stringValue)"
                           let senderId = message.1["userId"].stringValue
                           let gender = message.1["gender"].stringValue
                              var color = colorList[index % 11]
                              index += 1
                              
                           let user = User(token: "", userName: "", schoolId: "", firstName: firstName, lastName: lastName, userId: Int(senderId) ?? 0, email: "", googleToken: color, gender: "", cycle: section, photo: "", userType: 3, batchId: 0, imperiumCode: "", className: section, childrens: [], classes: [], privileges: [], firstLogin: false, admissionNo: "", bdDate: Date(), isBdChecked: false, blocked: false, password: "")
                              userList.append(user)
                           
                    
                              
                          }
                          
                          
                          
                             
                          completion(statusMessage,userList,status)
                         }else {
                             // Failed server response
                             let description = data["error_msgs"].stringValue
                             self.reportError(message: description)
                          completion(description,[],status)
                         }
                       case .failure(let error):
                           //TODO: add this to all errors
                           let error = error as NSError
                           if error.domain == NSURLErrorDomain {
                            completion("No internet connection available",[],App.STATUS_INVALID_RESPONSE)
                           } else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                           }
                       }
                    }
    }
    // Discussion messages APIs
    func loadMessages(user: User, id: String, page: Int, colorList: [String], messagesList: [DiscussionMessageModel], completion: @escaping(_ message: String?, _ result: [DiscussionMessageModel], _ status: Int?)->Void){
        let messageURL = "\(MESSAGES_URL)/onlineDiscussion/conversation?conversationId=\(id)&startFrom=\(page)"
        
              
        print("discussion params: \(id)")
        print("discussion params: \(page)")
        
               
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header111: \(headers)")
        print(messageURL)
        self.manager.request(messageURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let json):
                  #if DEBUG
                      print("==>getMessages ", json)
                  #endif
                  let response = JSON(json)
                  let statusMessage = response["message"].stringValue
                  let status = 200
                  let data = response["response"]
                 
                   var messagesList1: [DiscussionMessageModel] = []
                 
                 
                  if status == 200 {
                   var i = 1
                   var index = 1
                   
                   var colorIndex = 0
                   var usersDiscussionMap = ["":""]
                   var usersDiscussionArray = [""]
                   var messageIds = [""]
                   for msg in messagesList{
                       messageIds.append(msg.messageId)
                       usersDiscussionArray.append(msg.senderId)
                       usersDiscussionMap[msg.senderId] = msg.color
                   }
                   for message in data{
                       let id = message.1["id"].stringValue
                       let messageId = message.1["id"].stringValue
                       let type = message.1["type"].stringValue
                       
                       var studentFilename = ""
                       var studentFilesize = ""
                       var studentContentType = type
                       var studentLink = ""
                       var body = ""
                       
                       if(type != "text"){
                           studentFilename = message.1["attachment_file_name"].stringValue
                           studentFilesize = message.1["attachment_file_size"].stringValue
                           studentContentType = type
                           studentLink = message.1["message"].stringValue
                           body = type
                       }
                       else{
                           body = message.1["message"].stringValue

                       }
                       
                       let date = message.1["createdAt"].stringValue
                       let fullName = "\(message.1["user"]["firstName"].stringValue) \(message.1["user"]["lastName"].stringValue)"
                       let senderId = message.1["user"]["id"].stringValue
                       let gender = message.1["gender"].stringValue
                       var color = ""
                       
                       if(usersDiscussionArray.contains(senderId)){
                           if(senderId.elementsEqual(String(user.userId))){
                               color = "#608FEE"
                           }
                           else{
                               color = usersDiscussionMap[senderId]!
                           }
                       }
                       else{
                           if(senderId.elementsEqual(String(user.userId))){
                               color = "#608FEE"
                               usersDiscussionMap[senderId] = "#608FEE"
                           }
                           else{
                               if(colorIndex == i){
                                   colorIndex += 1
                                   usersDiscussionMap[senderId] = colorList[i%11]
                                   usersDiscussionArray.append(senderId)
                                   color = colorList[i%11]
                                   colorIndex += 1
                               }
                               else{
                                   usersDiscussionMap[senderId] = colorList[i%11]
                                   usersDiscussionArray.append(senderId)
                                   color = colorList[i%11]
                                   
                                   colorIndex += 1
                               }
                               
                           }
                       }
                       
                       if(!messageIds.contains(messageId)){
                           print("message ids: \(messageId)")
                           let msgDiscussion = DiscussionMessageModel(id: id, senderId: senderId, senderName: fullName, senderLink: studentLink, senderFilename: studentFilename, senderContentType: studentContentType, senderFilesize: studentFilesize, messageId: messageId, messageText: body, nbOfRecipients: "", messageDate: date, color: color, gender: "")
                           messagesList1.append(msgDiscussion)
                           messageIds.append(messageId)
                           i = i + 1
                       }
                       
                   }
                 
                   
                   
                      
                   completion(statusMessage,messagesList1,status)
                  }else {
                      // Failed server response
                      let description = data["error_msgs"].stringValue
                      self.reportError(message: description)
                   completion(description,[],status)
                  }
                           case .failure(let error):
                               //TODO: add this to all errors
                               let error = error as NSError
                               if error.domain == NSURLErrorDomain {
                                completion("No internet connection available",[],App.STATUS_INVALID_RESPONSE)
                               } else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                               }
                           }
                       }
    }
    
    // Discussion messages APIs
    func loadCurrentMessages(user: User, id: String, page: Int, colorList: [String], messagesList: [DiscussionMessageModel], completion: @escaping(_ message: String?, _ result: [DiscussionMessageModel], _ status: Int?)->Void){
        let messageURL = "\(baseURL!)/api/messages/get_group_messages"
         let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)",
            "id": "\(id)",
            "page":"\(0)",
             ]
              
               
               self.manager.upload(multipartFormData: {
                   multipartFormData in
                   for (key, value) in params{
                       multipartFormData.append(value.data(using: .utf8)!, withName: key)
                   }
               }, to: messageURL, encodingCompletion: {
                   (result) in
                   switch result {
                   case .success(let upload, _, _):
                       upload.responseJSON {
                           response in
                           
                           switch response.result {
                           case .success(let json):
                               #if DEBUG
                                   print("==>getMessages ", json)
                               #endif
                               let response = JSON(json)
                               let statusMessage = response["statusMessage"].stringValue
                               let status = response["statusCode"].intValue
                               let data = response["data"]
                                var messagesList1: [DiscussionMessageModel] = []
                            
                               if status == 200 {
                                let inbox = data["inbox"]
                                var i = 1
                                var index = 1
                                
                                var colorIndex = 0
                                var usersDiscussionMap = ["":""]
                                var usersDiscussionArray = [""]
                                var messageIds = [""]
                                for msg in messagesList{
                                    messageIds.append(msg.messageId)
                                    usersDiscussionArray.append(msg.senderId)
                                    usersDiscussionMap[msg.senderId] = msg.color
                                }
                                for message in inbox{
                                    let id = message.1["id"].stringValue
                                    let messageId = message.1["message_id"].stringValue
                                    let studentFilename = message.1["attachment_file_name"].stringValue
                                    let studentFilesize = message.1["attachment_file_size"].stringValue
                                    let studentContentType = message.1["attachment_content_type"].stringValue
                                    let studentLink = message.1["attachment_link"].stringValue
                                    let date = message.1["date"].stringValue
                                    let body = message.1["body"].stringValue
                                    let fullName = message.1["full_name"].stringValue
                                    let senderId = message.1["sender_id"].stringValue
                                    let gender = message.1["gender"].stringValue
                                    var color = ""
                                    
                                    if(usersDiscussionArray.contains(senderId)){
                                        if(senderId.elementsEqual(String(user.userId))){
                                            color = "#608FEE"
                                        }
                                        else{
                                            color = usersDiscussionMap[senderId]!
                                        }
                                    }
                                    else{
                                        if(senderId.elementsEqual(String(user.userId))){
                                            color = "#608FEE"
                                            usersDiscussionMap[senderId] = "#608FEE"
                                        }
                                        else{
                                            if(colorIndex == i){
                                                colorIndex += 1
                                                usersDiscussionMap[senderId] = colorList[i%11]
                                                usersDiscussionArray.append(senderId)
                                                color = colorList[i%11]
                                                colorIndex += 1
                                            }
                                            else{
                                                usersDiscussionMap[senderId] = colorList[i%11]
                                                usersDiscussionArray.append(senderId)
                                                color = colorList[i%11]
                                                
                                                colorIndex += 1
                                            }
                                            
                                        }
                                    }
                                    
                                    if(!messageIds.contains(messageId)){
                                        let msgDiscussion = DiscussionMessageModel(id: id, senderId: senderId, senderName: fullName, senderLink: studentLink, senderFilename: studentFilename, senderContentType: studentContentType, senderFilesize: studentFilesize, messageId: messageId, messageText: body, nbOfRecipients: "", messageDate: date, color: color, gender: "")
                                        messagesList1.insert(msgDiscussion, at: 0)
                                        messageIds.append(messageId)
                                        i = i + 1
                                    }
                                    
                                }
                            
                                
                                
                                   
                                completion(statusMessage,messagesList1,status)
                               }else {
                                   // Failed server response
                                   let description = data["error_msgs"].stringValue
                                   self.reportError(message: description)
                                completion(description,[],status)
                               }
                           case .failure(let error):
                               //TODO: add this to all errors
                               let error = error as NSError
                               if error.domain == NSURLErrorDomain {
                                completion("No internet connection available",[],App.STATUS_INVALID_RESPONSE)
                               } else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                               }
                           }
                       }
                   case .failure(let error):
                           
                       if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                       }
                       else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                       }
                       else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                       }
                   }
               })
    }
   
    
    func sendMessage(user: User, message_thread_id: String, message: String, schoolInfo: SchoolActivation, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
           let createSectionURL = "\(MESSAGES_URL)/onlineDiscussion/message/send"
          
//        let scl = "{\"id\" : \"\(schoolInfo.schoolId)\", \"englishName\" : \"\(schoolInfo.name)\"}"
        let scl = "{\"id\" : \"\(schoolInfo.schoolId)\"}"

        let params = [
        
        [
            "key": "conversationId",
            "value": "\(message_thread_id)",
            "type": "text"
          ],
          [
            "key": "message",
            "value": "\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
          [
            "key": "type",
            "value": "text",
            "type": "text"
          ],
         
          [
            "key": "schoolObj",
            "value": "\(scl)",
            "type": "text"
          ],
       
        ]
        
        
        print("send message params: \(params)")
        let headers: HTTPHeaders = [
//            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for param in params {
                if let key = param["key"], let value = param["value"] {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }

        }, to: createSectionURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                           
                               let json = JSON(j)
                        print("success success: \(json)")
                               let message = json["message"].stringValue
                               let status = 200
                               if status == 200 {
                                   let data = json["response"]
                                   completion(message,data,status)
                                                                       
                               }
                               else {
                               // Failed server response
                                  let error = JSON(j)
                                  let statusCode = error["statusCode"].intValue
                                  let data = error["data"]
                                  let errorMessage = data["error_msgs"].stringValue
                                  self.reportError(message: errorMessage)
                                  completion(errorMessage,error,statusCode)
                           }
                       case .failure(let error):
                       
                           if error._code == NSURLErrorTimedOut {
                               completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                           }
                           else if error._code == NSFileNoSuchFileError {
                               completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                           }
                           else {
                               completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                           }
                       }
                   }
               case .failure(let error):
                       
                   if error._code == NSURLErrorTimedOut {
                       completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                   }
                   else if error._code == NSFileNoSuchFileError {
                       completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                   }
                   else {
                       completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                   }
               }
           })
       }
     
    // send message with attachment
    
    func sendMessageWithAttachment(user: User, id: String, body: String, file: URL?, compressedFile: NSData?, image: UIImage?, isSelectedImage: Bool, filename: String, schoolInfo: SchoolActivation, type: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createSectionURL = "\(MESSAGES_URL)/onlineDiscussion/message/send"
       
        let scl = "{\"id\" : \"\(schoolInfo.schoolId)\"}"

        
     let params = [
     
     [
         "key": "conversationId",
         "value": "\(id)",
         "type": "text"
       ],
      
       [
         "key": "type",
         "value": "\(type)",
         "type": "text"
       ],
      
       [
         "key": "schoolObj",
         "value": "\(scl)",
         "type": "text"
       ],
    
     ]
     
     
     print("send message params: \(params)")
     let headers: HTTPHeaders = [
         "origin": baseURL!, // You can add more headers as needed
         "Authorization": "Bearer \(user.token)"
     ]
     
    
     #if DEBUG
         print("createOccasion params",params)
     #endif
     

     self.manager.upload(multipartFormData: {
         multipartFormData in
         for param in params {
             if let key = param["key"], let value = param["value"] {
                 if let data = value.data(using: .utf8) {
                     multipartFormData.append(data, withName: key)
                 }
             }
         }
         if isSelectedImage{
             multipartFormData.append(image!.jpeg(.lowest)!, withName: "message", fileName: filename, mimeType: "image/jpeg")
         }else{
         let pdfData = try! Data(contentsOf: file!)
         let filetype = file!.description.suffix(4)
             print("file type: \(filetype)")
         var mimeType = ""
             if filetype.lowercased() == ".pdf"{
                 mimeType = "application/pdf"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

             }else if filetype.lowercased() == "docx"{
                 mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

             }else if filetype.lowercased() == "xlsx"{
                 mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

             }else if filetype.lowercased() == "pptx" || filetype.lowercased() == "ppsx" || filetype.lowercased() == "ppt"{
                  mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

              }
              else if filetype.lowercased() == ".m4a"{
                  mimeType = "audio/mpeg"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

              }
              else if filetype.lowercased() == ".mp3" || filetype == ".mid" || filetype == ".midi" || filetype == ".kar" || filetype == ".ogg" || filetype == ".aac"{
                  mimeType = "audio/mpeg"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

              }
             else if(filetype.lowercased() == ".gif"){
                 mimeType = "audio/gif"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

             }
             else if(filetype.lowercased() == ".wma"){
                 mimeType = "audio/wma"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

             }
             else if(filetype.lowercased() == ".rtf"){
                 mimeType = "application/rtf"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

             }
             else if(filetype.lowercased() == ".txt"){
                 mimeType = "text/plain"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

             }
             else if(filetype.lowercased() == ".csv"){
                 mimeType = "text/csv"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

             }
             else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                  mimeType = "video/mp4"
                 multipartFormData.append(compressedFile! as Data, withName: "message", fileName: filename, mimeType: mimeType)

              }
              else if filetype.lowercased() == ".wmv"{
                  mimeType = "video/x-ms-wmv"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

              }
              else{
                  mimeType = "application/octet-stream"
                 multipartFormData.append(pdfData, withName: "message", fileName: filename, mimeType: mimeType)

              }
             
             
         }
                  
              }, to: createSectionURL, method: .post, headers: headers, encodingCompletion: {
         (result) in
         switch result {
         case .success(let upload, _, _):
             upload.responseJSON {
                 response in
                 switch response.result {
                 case .success(let j):
                        
                            let json = JSON(j)
                     print("success success: \(json)")
                            let message = json["message"].stringValue
                            let status = 200
                            if status == 200 {
                                let data = json["response"]
                                completion(message,data,status)
                                                                    
                            }
                            else {
                            // Failed server response
                               let error = JSON(j)
                               let statusCode = 400
                               let data = error["response"]
                               let errorMessage = data["message"].stringValue
                               self.reportError(message: errorMessage)
                               completion(errorMessage,error,statusCode)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
          }
        
    func getTeachersPayroll(user:User, type:String, completion: @escaping(_ message: String?, _ result: [String : [EmployeePayroll]]?, _ status: Int?)->Void){
        let feesURL = "\(baseURL!)/api/financials/get_details"
         let params = [
                                     "token": "\(user.token)",
                                     "username": "\(user.userName)",
                                      "type": "\(type)",
                      
                                 ]
              
               
               self.manager.upload(multipartFormData: {
                   multipartFormData in
                   for (key, value) in params{
                       multipartFormData.append(value.data(using: .utf8)!, withName: key)
                   }
               }, to: feesURL, encodingCompletion: {
                   (result) in
                   switch result {
                   case .success(let upload, _, _):
                       upload.responseJSON {
                           response in
                           
                           switch response.result {
                           case .success(let json):
                               #if DEBUG
                                   print("==>getfees ", json)
                               #endif
                               let response = JSON(json)
                               let statusMessage = response["statusMessage"].stringValue
                               let status = response["statusCode"].intValue
                               let data = response["data"]
                               
                               if status == 200 {
                                var payrollMap = ["total_amount": []]
                                var employeeEarningData: [EmployeePayroll] = []
                                var employeeTotalAmount: [EmployeePayroll] = []

                                let result = data["result"]
                                //earnings part
                                let earnings = result["earnings"]
                                let earningCurrency = earnings["currency"].stringValue
                                let earningTotalAmount = earnings["total_amount"].stringValue
                                let earningsCategories = earnings["categories"]
                                let header = EmployeePayroll(amount: "Earnings", amountValue: "Amount("+earningCurrency+")")
                                employeeEarningData.append(header)
                                for object in earningsCategories{
                                    let amountValue = object.1["amount"].stringValue
                                    let amount = object.1["name"].stringValue

                                    let payroll = EmployeePayroll(amount:amount, amountValue:amountValue)
                                     
                                    employeeEarningData.append(payroll)
                                 }
                                let earningsResult = EmployeePayroll(amount: "Total Earnings", amountValue: earningTotalAmount)
                                employeeEarningData.append(earningsResult)
                                
                                 payrollMap["earning"] = employeeEarningData

                                 var employeeDeductionData: [EmployeePayroll] = []
                                 let deductions = result["deductions"]
                                 let deductionCurrency = deductions["currency"].stringValue
                                 let deductionTotalAmount = deductions["total_amount"].stringValue
                                 let deductionsCategories = deductions["categories"]
                                 
                                let deductionsHeader = EmployeePayroll(amount: "Deductions", amountValue: "Amount("+deductionCurrency+")")
                                employeeDeductionData.append(deductionsHeader)
                                 for object in deductionsCategories{
                                     let amountValue = object.1["amount"].stringValue
                                     let amount = object.1["name"].stringValue
                                  let payroll = EmployeePayroll(amount:amount, amountValue:amountValue)
                                     
                                     employeeDeductionData.append(payroll)
                                 }
                                let deductionResult = EmployeePayroll(amount: "Total Deductions", amountValue: deductionTotalAmount)
                                employeeDeductionData.append(deductionResult)
                                
                                 payrollMap["deduction"] = employeeDeductionData
                                
                                let totalEar = Double(earningTotalAmount)
                                let totalDed = Double(deductionTotalAmount)
                                if(totalEar != nil && totalDed != nil){
                                    let totalPayroll = totalEar!  + totalDed!
                                    employeeTotalAmount.append(EmployeePayroll(amount: "Net Pay", amountValue: String(totalPayroll)))
                                    payrollMap["total_amount"] = employeeTotalAmount
                                }
                               
                            
                                
                                
                                   
                                completion(statusMessage,payrollMap as? [String : [EmployeePayroll]],status)
                               }else {
                                   // Failed server response
                                   let description = data["error_msgs"].stringValue
                                   self.reportError(message: description)
                                completion(description,[:],status)
                               }
                           case .failure(let error):
                               //TODO: add this to all errors
                               let error = error as NSError
                               if error.domain == NSURLErrorDomain {
                                completion("No internet connection available",[:],App.STATUS_INVALID_RESPONSE)
                               } else {
                                completion(App.INVALID_RESPONSE,[:],App.STATUS_INVALID_RESPONSE)
                               }
                           }
                       }
                   case .failure(let error):
                           
                       if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[:],App.STATUS_TIMEOUT)
                       }
                       else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[:],App.STATUS_INVALID_RESPONSE)
                       }
                       else {
                        completion(App.INVALID_RESPONSE,[:],App.STATUS_INVALID_RESPONSE)
                       }
                   }
               })
    }
    
    func getParentsFeesCategories(user:User, type:String, studentUsername:String, completion: @escaping(_ message: String?, _ result: [ParentFeesCategories]?, _ status: Int?)->Void){
        let feesURL = "\(baseURL!)/api/financials/get_details"
         let params = [
                                     "token": "\(user.token)",
                                     "username": "\(user.userName)",
                                     "type": "\(type)",
                                    "student_username": "\(studentUsername)",
                                 ]
        
    
              
               
               self.manager.upload(multipartFormData: {
                   multipartFormData in
                   for (key, value) in params{
                       multipartFormData.append(value.data(using: .utf8)!, withName: key)
                   }
               }, to: feesURL, encodingCompletion: {
                   (result) in
                   switch result {
                   case .success(let upload, _, _):
                       upload.responseJSON {
                           response in
                           
                           switch response.result {
                           case .success(let json):
                               #if DEBUG
                                   print("==>getfees ", json)
                               #endif
                               let response = JSON(json)
                               let statusMessage = response["statusMessage"].stringValue
                               let status = response["statusCode"].intValue
                               let data = response["data"]
                               
                               if status == 200 {
                                var parentsCategoryFees: [ParentFeesCategories] = []
                                
                                let result = data["result"]
                                let fees = result["fees"]
                                
                                for object in fees{
                                    let title = object.1["name"].stringValue
                                    let date = object.1["due_date"].stringValue
                                    let remainingAmount = object.1["remaining_amount"].stringValue
                                    let totalAmount = object.1["paid_amount"].stringValue
                                    var condition = ""
                                    
                                    let remaining = Double(remainingAmount)
                                    if(remaining == 0.0){
                                        condition = "Paid"
                                    }
                                    else{
                                        condition = "Unpaid"
                                    }

                                   let categories = ParentFeesCategories(title:title, date:date,
                                                                      condition: condition,
                                                                      remainingAmount:remainingAmount,
                                                                      totalAmount:totalAmount, totalDiscount: "")

                                    
                                   parentsCategoryFees.append(categories)
                                }
                                
                                let total_remaining = result["total_remaining"].stringValue
                                let total_amount = result["total_amount"].stringValue
                                let total_paid = result["total_paid"].stringValue
                                let total_discount = result["total_discount"].stringValue
                                
                                parentsCategoryFees.append(ParentFeesCategories(title: "", date: "", condition: total_paid, remainingAmount: total_remaining, totalAmount: total_amount, totalDiscount: total_discount))
                                   
                                completion(statusMessage,parentsCategoryFees,status)
                               }else {
                                   // Failed server response
                                   let description = data["error_msgs"].stringValue
                                   self.reportError(message: description)
                                completion(description,[],status)
                               }
                           case .failure(let error):
                               //TODO: add this to all errors
                               let error = error as NSError
                               if error.domain == NSURLErrorDomain {
                                completion("No internet connection available",[],App.STATUS_INVALID_RESPONSE)
                               } else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                               }
                           }
                       }
                   case .failure(let error):
                           
                       if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                       }
                       else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                       }
                       else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                       }
                   }
               })
    }
    
    
    func getParentsFeesDistributedPayments(user:User, type:String, completion: @escaping(_ message: String?, _ result: [ParentFeesDistributedPayments]?, _ status: Int?)->Void){
        let feesURL = "\(baseURL!)/api/financials/get_details"
         let params = [
                                     "token": "\(user.token)",
                                     "username": "\(user.userName)",
                                      "type": "\(type)",
                                 ]
        
              
               
               self.manager.upload(multipartFormData: {
                   multipartFormData in
                   for (key, value) in params{
                       multipartFormData.append(value.data(using: .utf8)!, withName: key)
                   }
               }, to: feesURL, encodingCompletion: {
                   (result) in
                   switch result {
                   case .success(let upload, _, _):
                       upload.responseJSON {
                           response in
                           
                           switch response.result {
                           case .success(let json):
                               #if DEBUG
                                   print("==>getfees ", json)
                               #endif
                               let response = JSON(json)
                               let statusMessage = response["statusMessage"].stringValue
                               let status = response["statusCode"].intValue
                               let data = response["data"]
                               
                               if status == 200 {
                                var parentFeesDistrubutedPayments: [ParentFeesDistributedPayments] = []
                                
                                let result = data["result"]
                                let payments = result["payments"]
                                
                                let i = 1
                                for object in payments{
                                    let count = i
                                    let amountValue = object.1["amount"].stringValue
                                    let paidAmountValue = object.1["paid_amount"].stringValue
                                    let remainingAmountValue = object.1["remaining_amount"].stringValue
                                    let dueDate = object.1["due_date"].stringValue
                                    

                                   let distributed = ParentFeesDistributedPayments(count:count, amountValue:amountValue, paidAmountValue: paidAmountValue, remainingAmountValue:remainingAmountValue, dueDate:dueDate)
                                    
                                   parentFeesDistrubutedPayments.append(distributed)
                                }
                                
                                let totalAmount = result["total_amount"].stringValue
                                let totalRemaining = result["total_remaining"].stringValue
                                let totalPaid = result["paid_amount"].stringValue
                                
                                let total_distributed = ParentFeesDistributedPayments(count: -1, amountValue: totalAmount, paidAmountValue: totalPaid, remainingAmountValue: totalRemaining, dueDate: "")
                                parentFeesDistrubutedPayments.append(total_distributed)
                                
                                   
                                completion(statusMessage,parentFeesDistrubutedPayments,status)
                               }else {
                                   // Failed server response
                                   let description = data["error_msgs"].stringValue
                                   self.reportError(message: description)
                                completion(description,[],status)
                               }
                           case .failure(let error):
                               //TODO: add this to all errors
                               let error = error as NSError
                               if error.domain == NSURLErrorDomain {
                                completion("No internet connection available",[],App.STATUS_INVALID_RESPONSE)
                               } else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                               }
                           }
                       }
                   case .failure(let error):
                           
                       if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                       }
                       else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                       }
                       else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                       }
                   }
               })
    }
    
    
    //Create Album
    
    func createAlbum(user: User, title: String, allSchool: String, departments: [String], classes: [String], std: [String], emp: [String],  completion: @escaping(_ message: String?, _ result: String?, _ status: Int?)->Void){
            let createOccasionURL = "\(baseURL!)/api/gallery/create_album"
            
            var students = ""
            var employees = ""
            var dept = ""
            var cls = ""
            
        for (index, dep) in emp.enumerated(){
                if employees.count > 1{
                    if index == 0{
                        employees = "\(dep)"
                    }else{
                        employees = "\(employees),\(dep)"
                    }
                }else{
                    employees = dep
                }
            }
        
        for (index, dep) in departments.enumerated(){
            if dept.count > 1{
                if index == 0{
                    dept = "\(dep)"
                }else{
                    dept = "\(dept),\(dep)"
                }
            }else{
                dept = dep
            }
        }

        for (index, sec) in std.enumerated(){
                if students.count > 1{
                    if index == 0{
                        students = "\(sec)"
                    }else{
                        students = "\(students),\(sec)"
                    }
                }else{
                    students = sec
                }
            }
        
        for (index, sec) in classes.enumerated(){
            if cls.count > 1{
                if index == 0{
                    cls = "\(sec)"
                }else{
                    cls = "\(students),\(sec)"
                }
            }else{
                cls = sec
            }
        }
            
            let params = [
                "token": "\(user.token)",
                "username": "\(user.userName)",
                "name": "\(title)",
                "is_common": "\(allSchool)",
                "departments": "\(dept)",
                "classes": "\(cls)",
                "extra_students": "\(students)",
                "extra_employees": "\(employees)",
                "type":"0",
            ]
            
            #if DEBUG
                print("createOccasion params",params)
            #endif
            self.manager.upload(multipartFormData: {
                multipartFormData in
                for (key, value) in params{
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                
    //            do {
    //                let sectionData = try JSONSerialization.data(withJSONObject: occasion.departments, options: .prettyPrinted)
    //                var sections = String(data: sectionData, encoding: .utf8)
    //                sections = sections?.replacingOccurrences(of: "\n", with: "")
    //                multipartFormData.append((sections ?? "").data(using: .utf8)!, withName: "sections")
    //
    //                let departmentData = try JSONSerialization.data(withJSONObject: occasion.sections, options: .prettyPrinted)
    //                var departments = String(data: departmentData, encoding: .utf8)
    //                departments = departments?.replacingOccurrences(of: "\n", with: "")
    //                multipartFormData.append((departments ?? "").data(using: .utf8)!, withName: "departments")
    //            }
    //            catch {
    //
    //            }
                
                
            }, to: createOccasionURL, encodingCompletion: {
                (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        switch response.result {
                        case .success(let j):
                            
                                let json = JSON(j)
                                let message = json["statusMessage"].stringValue
                                let status = json["statusCode"].intValue
                                if status == 200 {
                                    let data = json["data"]
                                    let albums = data["albums"]
                                    let album_id = albums["id"].stringValue
                                    completion(message,album_id,status)
                                                                        
                                }
                                else {
                                // Failed server response
                                    let error = JSON(j)
                                    let statusCode = error["statusCode"].intValue
                                    let data = error["data"]
                                    let errorMessage = data["error_msgs"].stringValue
                                    self.reportError(message: errorMessage)
                                    completion(errorMessage,errorMessage,statusCode)
                            }
                        case .failure(let error):
                        
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                            }
                        }
                    }
                case .failure(let error):
                        
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                    }
                }
            })
        }

    
   //Create Album
   
   func addAlbumPhotos(user: User, photo: UIImage?, album_id: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
           let createOccasionURL = "\(baseURL!)/api/gallery/add_image_file"
           
          
           
           let params = [
               "token": "\(user.token)",
               "username": "\(user.userName)",
               "album_id": "\(album_id)",
           ]
           
           #if DEBUG
               print("createOccasion params",params)
           #endif
           self.manager.upload(multipartFormData: {
               multipartFormData in
               for (key, value) in params{
                   multipartFormData.append(value.data(using: .utf8)!, withName: key)
               }
               
            if photo?.size != CGSize(width: 0.0, height: 0.0){
                if let profile = photo {
                    multipartFormData.append(profile.jpeg(.lowest)!, withName: "photo", fileName: "event.jpg", mimeType: "image/jpeg")
                }
            }
               
           }, to: createOccasionURL, encodingCompletion: {
               (result) in
               switch result {
               case .success(let upload, _, _):
                   upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        if status == 200 {
                            let data = json["data"]
                            completion(message,data,status)
                               }
                               else {
                               // Failed server response
                                   let error = JSON(j)
                                   let statusCode = error["statusCode"].intValue
                                   let data = error["data"]
                                   let errorMessage = data["error_msgs"].stringValue
                                   self.reportError(message: errorMessage)
                                   completion(errorMessage,error,statusCode)
                           }
                       case .failure(let error):
                       
                           if error._code == NSURLErrorTimedOut {
                               completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                           }
                           else if error._code == NSFileNoSuchFileError {
                               completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                           }
                           else {
                               completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                           }
                       }
                   }
               case .failure(let error):
                       
                   if error._code == NSURLErrorTimedOut {
                       completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                   }
                   else if error._code == NSFileNoSuchFileError {
                       completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                   }
                   else {
                       completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                   }
               }
           })
       }

    // get albums API
        func getAlbums(user: User, completion: @escaping(_ message: String?, _ result: [AlbumModel]?, _ status: Int?)->Void){
            let getSectionAbsenceURL = "\(baseURL!)/api/gallery/get_albums"
    //        var params = ["":""]
    //        if user.privileges.contains(App.studentAttendanceViewPrivilege){
    //            params = [
    //                "username": "\(user.userName)",
    //                "token": "\(user.token)",
    //                "date": "\(date)",
    //            ]
    //        }else{
              let  params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                ]
    //        }
        
            self.manager.upload(multipartFormData: {
                multipartFormData in
                for (key, value) in params{
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                
            }, to: getSectionAbsenceURL, encodingCompletion: {
                (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        switch response.result {
                        case .success(let j):
                            
                            var albums: [AlbumModel] = []
                            
                            let data = JSON(j)
                            let message = data["statusMessage"].stringValue
                            let status = data["statusCode"].intValue
                            let dataArray = data["data"]
                            let alb = dataArray["albums"]
                            let getAlbums = alb["albums"]
                            
                            for albs in getAlbums{
                                let description = albs.1["description"].stringValue
                                let id = albs.1["id"].stringValue
                                let createdAt = albs.1["created_at"].stringValue
                                let lastModifiedAt = albs.1["last_modified_at"].stringValue
                                let publishedAt = albs.1["published_at"].stringValue
                                let name = albs.1["name"].stringValue
                                let photo = albs.1["photo"].stringValue
                                let photoCount = albs.1["photo_count"].intValue
                                let galleryAlbum = AlbumModel(id: id, albumName: name, image: photo, dateCreated: createdAt, dateModified: lastModifiedAt, description: description, datePublished: publishedAt, albumCount: photoCount)
                                albums.append(galleryAlbum)
                            }
                           
                            
                            completion(message,albums,status)
                        case .failure(let error):
                        
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                    }
                case .failure(let error):
                        
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            })
        }
        
    // get albums API
    func getAlbumPhotos(user: User, albumId: String, completion: @escaping(_ message: String?, _ result: [PhotoAlbumModel]?, _ status: Int?)->Void){
            let getSectionAbsenceURL = "\(baseURL!)/api/gallery/view_album"
    //        var params = ["":""]
    //        if user.privileges.contains(App.studentAttendanceViewPrivilege){
    //            params = [
    //                "username": "\(user.userName)",
    //                "token": "\(user.token)",
    //                "date": "\(date)",
    //            ]
    //        }else{
              let  params = [
                "username": "\(user.userName)",
                "token": "\(user.token)",
                "id": "\(albumId)",
                ]
    //        }
        
            self.manager.upload(multipartFormData: {
                multipartFormData in
                for (key, value) in params{
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                
            }, to: getSectionAbsenceURL, encodingCompletion: {
                (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        switch response.result {
                        case .success(let j):
                            
                            var albums: [PhotoAlbumModel] = []
                            let data = JSON(j)

                            print("album photos: \(data)")
                            let message = data["statusMessage"].stringValue
                            let status = data["statusCode"].intValue
                            let dataArray = data["data"]
                            let photos = dataArray["photos"]
                            let images = photos["images"]
                            
                            for img in images{
                                let id = img.1["id"].stringValue
                                let imageContentType = img.1["image_content_type"].stringValue
                                let imageFileSize = img.1["image_file_size"].stringValue
                                let createdAt = img.1["created_at"].stringValue
                                let imageLink = img.1["image_link"].stringValue
                                let description = img.1["description"].stringValue
                                let imageName = img.1["image_file_name"].stringValue
                                let albumPhotos = PhotoAlbumModel(id: id, imageLink: imageLink, imageContentType: imageContentType, imageSize: imageFileSize, createdAt: createdAt, description: description, imageName: imageName)
                                albums.append(albumPhotos)
                            }
                           
                            
                            completion(message,albums,status)
                        case .failure(let error):
                        
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                    }
                case .failure(let error):
                        
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            })
        }
    
    //delete album
    func deleteAlbum(user: User, albumId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let getStudentURL = "\(baseURL!)/api/gallery/delete_album"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "album_id": "\(albumId)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: getStudentURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,"",status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //delete album
    func deletePhoto(user: User, photoId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let getStudentURL = "\(baseURL!)/api/gallery/delete_photo"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "photo": "\(photoId)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: getStudentURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,"",status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
// get user channels
    func getAllChannels(user: User, batch_id: String, subject_id: String, colorList: [String], expandList: [String:Bool], completion: @escaping(_ message: String?, _ result: [String:[SectionModel]]?, _ additionalResult: [ChannelModel], _ status: Int?)->Void){
        let channelsURL = "\(baseURL!)/api/blended_learning/get_user_channels"
       
        

        
            let params = [
                "token": "\(user.token)",
                "username": "\(user.userName)",
                "batch_id": "\(batch_id)",
                "subject_id": "\(subject_id)",
            ]
      

        #if DEBUG
            print("==>getChannelparams ", params)
        #endif
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: channelsURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    
                    switch response.result {
                    case .success(let json):
                        #if DEBUG
                            print("==>getChannel ", json)
                        #endif
                        let data = JSON(json)
                        let message = data["statusMessage"].stringValue
                        let status = data["statusCode"].intValue
                        let dataArray = data["data"]
                        var i = 0
                        
                        if status == 200 {
                            var channelsControlList: [ChannelModel] = []
                            var channelCodes: [String] = []
                            var channelList: [String: [SectionModel]] = [:]
                            
                            let channels = dataArray["channels"]
                            for object in channels{
                                let channelId = object.1["id"].stringValue
                                let channelName = object.1["title"].stringValue
                                var channelCode = object.1["code"].stringValue
                                let isPublished = object.1["is_published"].boolValue
                                let channelUserId = object.1["user_id"].stringValue
                                
                                let sectionList = object.1["sections"]
                                var channelSections: [SectionModel] = []
                                for section in sectionList{
                                    let sectionTitle = section.1["title"].stringValue
                                    let sectionId = section.1["id"].stringValue
                                    let sectionDate = section.1["start_date"].stringValue
                                    let sectionOrder = 0
                                    let sectionCode = section.1["code"].stringValue
                                    let sectionUserId = section.1["user_id"].stringValue
                                    
                                    
                                    let itemList = section.1["items"]
                                    var itemsArray: [SectionDetailsModel] = []
                                    for item in itemList{
                                        let itemType = item.1["type"].stringValue
                                        let itemId = item.1["item_id"].stringValue
                                        var itemTitle = "Attachment"
                                        if(itemType == "document"){
                                            itemTitle = "Document"
                                        }
                                        else if(itemType == "assignment"){
                                            itemTitle = "Assignment"
                                        }
                                        else if(itemType == "url"){
                                            itemTitle = "URL"
                                        }
                                        else if(itemType == "online_exam"){
                                            itemTitle = "OnlineExam"
                                        }
                                        else if(itemType == "discussion"){
                                            itemTitle = "Discussion"
                                        }
                                        

                                        if(itemType.lowercased().elementsEqual("document")){
                                            let itemBody = item.1["document_name"].stringValue
                                            let itemAttachmentLink = item.1["attachment_link"].stringValue
                                            let itemAttachmentContentType = item.1["attachment_content_type"].stringValue
                                            let itemAttachmentContentSize = item.1["attachment_content_size"].stringValue
                                            let itemAttachmentFilename = item.1["attachment_file_name"].stringValue
                                            let creator = item.1["creator"].stringValue
                                            
                                            let items = SectionDetailsModel(id: itemId, title: itemTitle, downloadImage: "", body: itemBody, color: colorList[i%colorList.count], attachmentLink: itemAttachmentLink, attachmentContentType: itemAttachmentContentType, attachmentContentSize: itemAttachmentContentSize, attachmentFilename: itemAttachmentFilename, type: itemType, startDate: "", endDate: "", duration: "", link_type: "", link_to_join: "", assignmentType: "", assignmentStudentList: "", assignmentDate: "", subjectId: "", madrasatieSubTermId: "", madrasatieSubSubjectId: "", fullMark: "", creator: creator, messageThreadId: "", assignmentId: "", recipientNumber: "", discussionStudent: "")
                                            itemsArray.append(items)
                                            
                                        }
                                        else if(itemType.lowercased().elementsEqual("assignment")){
                                            let itemTitle = item.1["assignment_name"].stringValue
                                            let itemBody = item.1["assignment_body"].stringValue
                                            let itemAttachmentLink = item.1["attachment_link"].stringValue
                                            let itemAttachmentContentType = item.1["attachment_content_type"].stringValue
                                            let itemAttachmentContentSize = item.1["attachment_content_size"].stringValue
                                            let itemAttachmentFilename = item.1["attachment_file_name"].stringValue
                                            let itemType = item.1["type"].stringValue
                                            
                                            let assignmentType = item.1["assignment_type"].stringValue
                                            if(assignmentType.elementsEqual("homework") || assignmentType.elementsEqual("classwork")){
                                                let studentList = item.1["student_list"].stringValue
                                                let subjectId = item.1["subject_id"].stringValue
                                                let assignmentDate = item.1["assignment_date"].stringValue
                                                let creator = item.1["creator"].stringValue
                                                let assignmentId = item.1["assignment_id"].stringValue
                                                
                                                let items = SectionDetailsModel(id: itemId, title: itemTitle, downloadImage: "", body: itemBody, color: colorList[i%colorList.count], attachmentLink: itemAttachmentLink, attachmentContentType: itemAttachmentContentType, attachmentContentSize: itemAttachmentContentSize, attachmentFilename: itemAttachmentFilename, type: itemType, startDate: "", endDate: "", duration: "", link_type: "", link_to_join: "", assignmentType: assignmentType, assignmentStudentList: studentList, assignmentDate: assignmentDate, subjectId: subjectId, madrasatieSubTermId: "", madrasatieSubSubjectId: "", fullMark: "", creator: creator, messageThreadId: "", assignmentId: assignmentId, recipientNumber: "", discussionStudent: "")
                                                itemsArray.append(items)
                                            }
                                            else if(assignmentType.elementsEqual("exam")){
                                                let subjectId = item.1["subject_id"].stringValue
                                                let assignmentDate = item.1["assignment_date"].stringValue
                                                let subTermId = item.1["madrasatie_sub_term_id"].stringValue
                                                let creator = item.1["creator"].stringValue
                                                let assignmentId = item.1["assignment_id"].stringValue
                                                
                                                let items = SectionDetailsModel(id: itemId, title: itemTitle, downloadImage: "", body: itemBody, color: colorList[i%colorList.count], attachmentLink: itemAttachmentLink, attachmentContentType: itemAttachmentContentType, attachmentContentSize: itemAttachmentContentSize, attachmentFilename: itemAttachmentFilename, type: itemType, startDate: "", endDate: "", duration: "", link_type: "", link_to_join: "", assignmentType: assignmentType, assignmentStudentList: "", assignmentDate: assignmentDate, subjectId: subjectId, madrasatieSubTermId: subTermId, madrasatieSubSubjectId: "", fullMark: "", creator: creator, messageThreadId: "", assignmentId: assignmentId, recipientNumber: "", discussionStudent: "")
                                                itemsArray.append(items)
                                            }
                                            else if(assignmentType.elementsEqual("quiz")){
                                                let subjectId = item.1["subject_id"].stringValue
                                                let assignmentDate = item.1["assignment_date"].stringValue
                                                let subTermId = item.1["madrasatie_sub_term_id"].stringValue
                                                let subSubjectId = item.1["madrasatie_sub_subject_id"].stringValue
                                                let fullMark = item.1["full_mark"].stringValue
                                                let creator = item.1["creator"].stringValue
                                                let assignmentId = item.1["assignment_id"].stringValue
                                                
                                                let items = SectionDetailsModel(id: itemId, title: itemTitle, downloadImage: "", body: itemBody, color: colorList[i%colorList.count], attachmentLink: itemAttachmentLink, attachmentContentType: itemAttachmentContentType, attachmentContentSize: itemAttachmentContentSize, attachmentFilename: itemAttachmentFilename, type: itemType, startDate: "", endDate: "", duration: "", link_type: "", link_to_join: "", assignmentType: assignmentType, assignmentStudentList: "", assignmentDate: assignmentDate, subjectId: subjectId, madrasatieSubTermId: subTermId, madrasatieSubSubjectId: subSubjectId, fullMark: fullMark, creator: creator, messageThreadId: "", assignmentId: assignmentId, recipientNumber: "", discussionStudent: "")
                                                itemsArray.append(items)
                                            }
                                            
                                            
                                            
                                        }
                                        else if(itemType.lowercased().elementsEqual("url")){
                                            let itemTitle = item.1["title"].stringValue
                                            let itemBody = item.1["url"].stringValue
                                            let creator = item.1["creator"].stringValue
                                            
                                            let items = SectionDetailsModel(id: itemId, title: itemTitle, downloadImage: "", body: itemBody, color: colorList[i%colorList.count], attachmentLink: "", attachmentContentType: "", attachmentContentSize: "", attachmentFilename: "", type: itemType, startDate: "", endDate: "", duration: "", link_type: "", link_to_join: "", assignmentType: "", assignmentStudentList: "", assignmentDate: "", subjectId: "", madrasatieSubTermId: "", madrasatieSubSubjectId: "", fullMark: "", creator: creator, messageThreadId: "", assignmentId: "", recipientNumber: "", discussionStudent: "")
                                            itemsArray.append(items)
                                        }
                                        else if(itemType.lowercased().elementsEqual("discussion")){
                                            let itemB = item.1["title"].stringValue
                                            let itemBody = item.1["can_reply"].stringValue
                                            let creator = item.1["creator"].stringValue
                                            let startDate = item.1["created_at"].stringValue
                                            let messageThreadId = item.1["message_thread_id"].stringValue
                                            let recipientNumber = item.1["recipient_number"].stringValue
                                            let discussionStudent = item.1["discussion_student"].stringValue
                                            
                                            print("message thread id: \(messageThreadId)")
                                            
                                            
                                            let items = SectionDetailsModel(id: itemId, title: itemTitle, downloadImage: "", body: itemB, color: colorList[i%colorList.count], attachmentLink: "", attachmentContentType: "", attachmentContentSize: "", attachmentFilename: "", type: itemType, startDate: startDate, endDate: "", duration: "", link_type: "", link_to_join: "", assignmentType: "", assignmentStudentList: "", assignmentDate: "", subjectId: "", madrasatieSubTermId: "", madrasatieSubSubjectId: "", fullMark: "", creator: creator, messageThreadId: messageThreadId, assignmentId: "", recipientNumber: recipientNumber, discussionStudent: discussionStudent)
                                            itemsArray.append(items)
                                        }
                                        else if(itemType.lowercased().elementsEqual("online_exam")){
                                            let itemTitle = "Online Exam - " + item.1["name"].stringValue
                                            let itemStartDate = item.1["start_date"].stringValue
                                            let itemEndDate = item.1["end_date"].stringValue
                                            let itemduraton = item.1["duration"].stringValue
                                            let itemExamType = item.1["exam_type"].stringValue
                                            let itemLinkToJoin = item.1["link_to_join"].stringValue
                                            let creator = item.1["creator"].stringValue
                                            
                                            
                                            let items = SectionDetailsModel(id: itemId, title: itemTitle, downloadImage: "", body: "", color: colorList[i%colorList.count], attachmentLink: "", attachmentContentType: "", attachmentContentSize: "", attachmentFilename: "", type: itemType, startDate: itemStartDate, endDate: itemEndDate, duration: itemduraton, link_type: itemExamType, link_to_join: itemLinkToJoin, assignmentType: "", assignmentStudentList: "", assignmentDate: "", subjectId: "", madrasatieSubTermId: "", madrasatieSubSubjectId: "", fullMark: "", creator: creator, messageThreadId: "", assignmentId: "", recipientNumber: "", discussionStudent: "")
                                            itemsArray.append(items)
                                        }
                                        else if(itemType.lowercased().elementsEqual("meeting_room")){
                                            let itemTitle = item.1["name"].stringValue
                                            let itemMeetingType = item.1["meeting_type"].stringValue
                                            let itemLinkToJoin = item.1["link_to_join"].stringValue
                                            let creator = item.1["creator"].stringValue
                                            
                                            if(itemMeetingType.lowercased().elementsEqual("join")){
                                                let items = SectionDetailsModel(id: itemId, title: "Online Meeting", downloadImage: "", body: "Join meeting", color: colorList[i%colorList.count], attachmentLink: "", attachmentContentType: "", attachmentContentSize: "", attachmentFilename: "", type: itemType, startDate: "", endDate: "", duration: "", link_type: "", link_to_join: itemLinkToJoin, assignmentType: "", assignmentStudentList: "", assignmentDate: "", subjectId: "", madrasatieSubTermId: "", madrasatieSubSubjectId: "", fullMark: "", creator: creator, messageThreadId: "", assignmentId: "", recipientNumber: "", discussionStudent: "")
                                                itemsArray.append(items)

                                            }
                                            else{
                                                let items = SectionDetailsModel(id: itemId, title: "Online Meeting", downloadImage: "", body: "Download recording", color: colorList[i%colorList.count], attachmentLink: "", attachmentContentType: "", attachmentContentSize: "", attachmentFilename: "", type: itemType, startDate: "", endDate: "", duration: "", link_type: "", link_to_join: itemLinkToJoin, assignmentType: "", assignmentStudentList: "", assignmentDate: "", subjectId: "", madrasatieSubTermId: "", madrasatieSubSubjectId: "", fullMark: "", creator: creator, messageThreadId: "", assignmentId: "", recipientNumber: "", discussionStudent: "")
                                                itemsArray.append(items)

                                            }
                                            
                                        }
                                        
                                    }
                                    if(user.userType == 2){
                                        let addNewItem = SectionDetailsModel(id: "", title: "Add new activity", downloadImage: "", body: "", color: "#FFFFFF", attachmentLink: "", attachmentContentType: "", attachmentContentSize: "", attachmentFilename: "", type: "", startDate: "", endDate: "", duration: "", link_type: "", link_to_join: "", assignmentType: "", assignmentStudentList: "", assignmentDate: "", subjectId: "", madrasatieSubTermId: "", madrasatieSubSubjectId: "", fullMark: "", creator: "", messageThreadId: "", assignmentId: "", recipientNumber: "", discussionStudent: "")
                                            itemsArray.append(addNewItem)
                                    }
                                  
                                    var sec = SectionModel(id: "", name: "", color: "", isTicked: false, expand: false, sectionDetailsList: [], date: "", sectionOrder: 0, url: "", urlTitle: "", code: "", userId: "")
                                    if let val = expandList[sectionId]{
                                        sec = SectionModel(id: sectionId, name: sectionTitle, color: colorList[i%colorList.count], isTicked: false, expand: val, sectionDetailsList: itemsArray, date: sectionDate, sectionOrder: sectionOrder, url: "", urlTitle: "", code: sectionCode, userId: sectionUserId)
                                    }
                                    else{
                                        sec = SectionModel(id: sectionId, name: sectionTitle, color: colorList[i%colorList.count], isTicked: false, expand: false, sectionDetailsList: itemsArray, date: sectionDate, sectionOrder: sectionOrder, url: "", urlTitle: "", code: sectionCode, userId: sectionUserId)
                                    }
                                    
                                    channelSections.append(sec)
                                }
                                if(user.userType == 2){
                                    let addSection = SectionModel(id: "-1", name: "Add new section", color: "#FFFFFF", isTicked: false, expand: false, sectionDetailsList: [], date: "", sectionOrder: 0, url: "", urlTitle: "", code: "", userId: "")
                                        channelSections.append(addSection)
                                }
                               
                                
                                let ch = ChannelModel(channelId: channelId, channelCode: channelCode, channelName: channelName, channelColor: colorList[i%colorList.count], channelDate: "", channelPublished: isPublished, sectionsList: channelSections, userId: channelUserId)
                                channelList[ch.channelId] = channelSections
                                channelCode.append(ch.channelCode)
                                channelsControlList.insert(ch, at: 0)
                                
                                i = i + 1
                            }
                            channelList[""] = []
                          
                            completion(message,channelList,channelsControlList, status)
                        }
                        else {
                            // Failed server response
                            let description = dataArray["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,[:],[], status)
                        }
                    case .failure(let error):
                        //TODO: add this to all errors
                        let error = error as NSError
                        if error.domain == NSURLErrorDomain {
                            completion("No internet connection available",[:],[],App.STATUS_INVALID_RESPONSE)
                        } else {
                            completion(App.INVALID_RESPONSE,[:],[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[:],[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[:],[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[:],[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    //Get Teacher Subject API:
        func getUserOnlineExams(user: User, subjectId: String, completion: @escaping(_ message: String?, _ result: [OnlineExamGroupModel]?, _ status: Int?)->Void){
            let getExamURL = "\(baseURL!)/api/blended_learning/get_online_exams"
            
            let params = [
                "username": "\(user.userName)",
                "token": "\(user.token)",
                "subject_id": "\(subjectId)",
            ]
            
            self.manager.upload(multipartFormData: {
                multipartFormData in
                for (key, value) in params{
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                
            }, to: getExamURL, encodingCompletion: {
                (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        switch response.result {
                        case .success(let j):
                            var examsArray: [OnlineExamGroupModel] = []
                            let json = JSON(j)
                            
                            #if DEBUG
    //                            print(params)
                                print("==>getOnlineExam", json)
                            #endif
                            
                            let message = json["statusMessage"].stringValue
                            let status = json["statusCode"].intValue
                            let data = json["data"]
                            if status == 200{
                                let examsData = data["online_exams"]
                                for exam in examsData{
                                    let id = exam.1["id"].stringValue
                                    let name = exam.1["name"].stringValue
                                    let startDate = exam.1["start_date"].stringValue
                                    let endDate = exam.1["endDate"].stringValue
                                    let duration = exam.1["duration"].stringValue
                                    let linktoJoin = exam.1["link_to_join"].stringValue
                                    let batchId = exam.1["batch_id"].stringValue
                                    let examFormat = exam.1["exam_format"].stringValue
                                    let examType = exam.1["exam_type"].stringValue
                                    let optionCount = exam.1["option_count"].stringValue
                                    let passPercentage = exam.1["pass_percentage"].stringValue
                                    
                                    let ex = OnlineExamGroupModel(id: id, name: name, startDate: startDate, endDate: endDate, passPercentage: passPercentage, maximumTime: duration, batchId: batchId, examType: examType, examFormat: examFormat, optionCount: optionCount, linkToJoin: linktoJoin)
                                    
                                    examsArray.append(ex)
                                }
                                
                                completion(message,examsArray,status)
                            }else{
                                let errorMessage = data["error_msgs"].stringValue
                                self.reportError(message: errorMessage)
                                completion(errorMessage,[],status)
                            }
                            
                        case .failure(let error):
                        
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                    }
                case .failure(let error):
                        
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            })
        }
        
    
    
    //Create channel
     func addChannel(user: User, batch_id: String, subject_id: String, title: String, code: String,  completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
             let createChannelURL = "\(baseURL!)/api/blended_learning/create_channel"
            
    
             
             let params = [
                 "token": "\(user.token)",
                 "name": "\(title)",
                 "batch_id": "\(batch_id)",
                 "subject_id": "\(subject_id)",
                 "title": "\(title)",
                 "code": "\(code)",
                "user_id": "\(user.userId)"
             ]
             
             #if DEBUG
                 print("createChannel params",params)
             #endif
             self.manager.upload(multipartFormData: {
                 multipartFormData in
                 for (key, value) in params{
                     multipartFormData.append(value.data(using: .utf8)!, withName: key)
                 }
            
                 
                 
             }, to: createChannelURL, encodingCompletion: {
                 (result) in
                 switch result {
                 case .success(let upload, _, _):
                     upload.responseJSON {
                         response in
                         switch response.result {
                         case .success(let j):
                             
                                 let json = JSON(j)
                                 let message = json["statusMessage"].stringValue
                                 let status = json["statusCode"].intValue
                                 if status == 200 {
                                     let data = json["data"]
                                     completion(message,data,status)
                                                                         
                                 }
                                 else {
                                 // Failed server response
                                    let error = JSON(j)
                                    let statusCode = error["statusCode"].intValue
                                    let data = error["data"]
                                    let errorMessage = data["error_msgs"].stringValue
                                    self.reportError(message: errorMessage)
                                    completion(errorMessage,error,statusCode)
                             }
                         case .failure(let error):
                         
                             if error._code == NSURLErrorTimedOut {
                                 completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                             }
                             else if error._code == NSFileNoSuchFileError {
                                 completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                             }
                             else {
                                 completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                             }
                         }
                     }
                 case .failure(let error):
                         
                     if error._code == NSURLErrorTimedOut {
                         completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                     }
                     else if error._code == NSFileNoSuchFileError {
                         completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                     }
                     else {
                         completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                     }
                 }
             })
         }

     
  //Create setion
   
    func addSection(user: User, batch_id: String, subject_id: String, title: String, code: String, startDate: String, channelId: String, sectionOrder: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
           let createSectionURL = "\(baseURL!)/api/blended_learning/create_section"
          
  
           
           let params = [
            "token": "\(user.token)",
            "name": "\(title)",
            "batch_id": "\(batch_id)",
            "subject_id": "\(subject_id)",
            "title": "\(title)",
            "code": "\(code)",
            "start_date": "\(startDate)",
            "channel_id": "\(channelId)",
            "section_order": "\(sectionOrder)",
            "user_id": "\(user.userId)"
           ]
           
           #if DEBUG
               print("createChannel params",params)
           #endif
           self.manager.upload(multipartFormData: {
               multipartFormData in
               for (key, value) in params{
                   multipartFormData.append(value.data(using: .utf8)!, withName: key)
               }
          
               
               
           }, to: createSectionURL, encodingCompletion: {
               (result) in
               switch result {
               case .success(let upload, _, _):
                   upload.responseJSON {
                       response in
                       switch response.result {
                       case .success(let j):
                           
                               let json = JSON(j)
                        print("get sections response ==> \(json)")
                               let message = json["statusMessage"].stringValue
                               let status = json["statusCode"].intValue
                               if status == 200 {
                                   let data = json["data"]
                                   completion(message,data,status)
                                                                       
                               }
                               else {
                               // Failed server response
                                  let error = JSON(j)
                                  let statusCode = error["statusCode"].intValue
                                  let data = error["data"]
                                  let errorMessage = data["error_msgs"].stringValue
                                  self.reportError(message: errorMessage)
                                  completion(errorMessage,error,statusCode)
                           }
                       case .failure(let error):
                       
                           if error._code == NSURLErrorTimedOut {
                               completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                           }
                           else if error._code == NSFileNoSuchFileError {
                               completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                           }
                           else {
                               completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                           }
                       }
                   }
               case .failure(let error):
                       
                   if error._code == NSURLErrorTimedOut {
                       completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                   }
                   else if error._code == NSFileNoSuchFileError {
                       completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                   }
                   else {
                       completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                   }
               }
           })
       }
     
    //edit setion
     
    func editSection(user: User, batch_id: String, subject_id: String, title: String, code: String, startDate: String, channelId: String, sectionOrder: String, sectionId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
             let createSectionURL = "\(baseURL!)/api/blended_learning/edit_section"
            
    
             
             let params = [
              "token": "\(user.token)",
              "name": "\(title)",
              "batch_id": "\(batch_id)",
              "subject_id": "\(subject_id)",
              "title": "\(title)",
              "code": "\(code)",
              "start_date": "\(startDate)",
              "channel_id": "\(channelId)",
              "section_order": "\(sectionOrder)",
                "id":"\(sectionId)"
             ]
             
             #if DEBUG
                 print("createChannel params",params)
             #endif
             self.manager.upload(multipartFormData: {
                 multipartFormData in
                 for (key, value) in params{
                     multipartFormData.append(value.data(using: .utf8)!, withName: key)
                 }
            
                 
                 
             }, to: createSectionURL, encodingCompletion: {
                 (result) in
                 switch result {
                 case .success(let upload, _, _):
                     upload.responseJSON {
                         response in
                         switch response.result {
                         case .success(let j):
                             
                                 let json = JSON(j)
                                 let message = json["statusMessage"].stringValue
                                 let status = json["statusCode"].intValue
                                 if status == 200 {
                                     let data = json["data"]
                                     completion(message,data,status)
                                                                         
                                 }
                                 else {
                                 // Failed server response
                                    let error = JSON(j)
                                    let statusCode = error["statusCode"].intValue
                                    let data = error["data"]
                                    let errorMessage = data["error_msgs"].stringValue
                                    self.reportError(message: errorMessage)
                                    completion(errorMessage,error,statusCode)
                             }
                         case .failure(let error):
                         
                             if error._code == NSURLErrorTimedOut {
                                 completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                             }
                             else if error._code == NSFileNoSuchFileError {
                                 completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                             }
                             else {
                                 completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                             }
                         }
                     }
                 case .failure(let error):
                         
                     if error._code == NSURLErrorTimedOut {
                         completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                     }
                     else if error._code == NSFileNoSuchFileError {
                         completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                     }
                     else {
                         completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                     }
                 }
             })
         }
       
    //Create item
      
    func addItemWithAttachment(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam,file: URL?, fileCompressed: NSData? , image: UIImage?, isSelectedImage: Bool, subjectName: String, replies: Bool, filename: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
              let createSectionURL = "\(baseURL!)/api/blended_learning/create_item"
        
        var params = ["":""]
        
         if(type.lowercased().elementsEqual("document")){
                       params = [
                           "username": "\(user.userName)",
                           "token": "\(user.token)",
                           "section_id": "\(section_id)",
                           "type": "\(type)",
                           "title": "\(title)",
                       ]
                   }

         else if(type.lowercased().elementsEqual("discussion")){
            print("discussion params: \(user.userName)")
            print("discussion params: \(user.token)")
            print("discussion params: \(section_id)")
            print("discussion params: \(type)")
            print("discussion params: \(title)")
            print("discussion params: \(agenda.description)")
            print("discussion params: \(agenda.students)")
            
             params = [
                 "username": "\(user.userName)",
                 "token": "\(user.token)",
                 "section_id": "\(section_id)",
                 "type": "\(type)",
                 "title": "\(title)",
                 "can_reply": "1",
                 "body": "\(agenda.description)",
                 "students": "\(agenda.students)",
             ]
         }
         
         
                   else if(type.lowercased().elementsEqual("assignment")){
                       
                       var students = ""
                       for (index, std) in agenda.students.enumerated(){
                           if students.count > 1{
                               if index == 0{
                                   students = "\(std)"
                               }else{
                                   students = "\(students),\(std)"
                               }
                           }else{
                               students = std
                           }
                       }
                                   
                       //no student list in assessment
                       if agenda.assignmentId == agendaType.Assessment.rawValue{

                           params = [
                               "username": "\(user.userName)",
                               "token": "\(user.token)",
                               "assignment_type":"\(agenda.assignmentId)",
                               "title": "\(type)",
                               "sub_term": "\(agenda.groupId)",
                               "subject": "\(agenda.subjectId)",
                               "due_date": "\(agenda.startDate)",
                               "description": "\(agenda.description)",
                               "assessment_type": "\(agenda.assessmentTypeId)",
                               "full_mark": "\(agenda.mark)",
                               "section_id":"\(section_id)",
                               "type": "\(type)",
                               "name":"\(subjectName)" ]
                       }
                       else if(agenda.assignmentId == agendaType.Exam.rawValue){
                           params = [
                               "username": "\(user.userName)",
                               "token": "\(user.token)",
                               "assignment_type":"\(agenda.assignmentId)",
                               "title": "\(type)",
                               "sub_term": "\(agenda.groupId)",
                               "subject": "\(agenda.subjectId)",
                               "due_date": "\(agenda.startDate)",
                               "description": "\(agenda.description)",
                               "section_id":"\(section_id)",
                               "type": "\(type)",
                               "name":"\(subjectName)" ]
                       }
                       else{
                        print("homework1: \(user.userName)")
                        print("homework2: \(user.token)")
                        print("homework3: \(agenda.assignmentId)")
                        print("homework4: \(students)")
                        print("homework5: \(agenda.subjectId)")
                        print("homework6: \(agenda.startDate)")
                        print("homework7: \(agenda.description)")
                        print("homework8: \(section_id)")
                        print("homework9: \(type)")
                           params = [
                               "username": "\(user.userName)",
                               "token": "\(user.token)",
                               "assignment_type":"\(agenda.assignmentId)",
                               "sub_term": "",
                               "students": "\(students)",
                               "subject": "\(agenda.subjectId)",
                               "due_date": "\(agenda.startDate)",
                               "description": "\(agenda.description)",
                               "section_id":"\(section_id)",
                               "type": "\(type)",
                               "name":"\(subjectName)"
                           ]
                       }
                   }
                   else if(type.lowercased().elementsEqual("url")){
                       params = [
                           "username": "\(user.userName)",
                           "token": "\(user.token)",
                           "section_id": "\(section_id)",
                           "type": "\(type)",
                           "title": "\(title)",
                           "url": "\(url)"
                       ]
                   }
                   else if(type.lowercased().elementsEqual("online_exam")){
                       params = [
                           "username": "\(user.userName)",
                           "token": "\(user.token)",
                           "section_id": "\(section_id)",
                           "type": "\(type)",
                       ]
               }
                        
              
              #if DEBUG
                  print("createChannel params",params)
              #endif
              self.manager.upload(multipartFormData: {
                multipartFormData in
                for (key, value) in params{
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                if isSelectedImage{
                    multipartFormData.append(image!.jpeg(.lowest)!, withName: "attachment", fileName: filename, mimeType: "image/jpeg") //image!.jpegData(compressionQuality: 0.5)!
                }else{
                    let pdfData = try! Data(contentsOf: file!)
                    let filetype = file!.description.suffix(4)
                    print("file description: \(file!.description.suffix(4))")

                    var mimeType = ""
                    if filetype.lowercased() == ".pdf"{
                        mimeType = "application/pdf"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    }else if filetype.lowercased() == "docx"{
                        mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    }else if filetype.lowercased() == "xlsx"{
                        mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    }else if filetype.lowercased() == "pptx" || filetype.lowercased() == "ppsx" || filetype.lowercased() == "ppt"{
                        mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    }
                     else if filetype.lowercased() == ".m4a"{
                         mimeType = "audio/mpeg"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                     }
                     else if filetype.lowercased() == ".mp3" || filetype == ".mid" || filetype == ".midi" || filetype == ".kar" || filetype == ".ogg" || filetype == ".aac"{
                         mimeType = "audio/mpeg"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                     }
                    else if(filetype.lowercased() == ".gif"){
                        mimeType = "audio/gif"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    }
                    else if(filetype.lowercased() == ".wma"){
                        mimeType = "audio/wma"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    }
                    else if(filetype.lowercased() == ".rtf"){
                        mimeType = "application/rtf"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    }
                    else if(filetype.lowercased() == ".txt"){
                        mimeType = "text/plain"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    }
                    else if(filetype.lowercased() == ".csv"){
                        mimeType = "text/csv"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    }
                    else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                         mimeType = "video/mp4"
                        multipartFormData.append(fileCompressed! as Data, withName: "attachment", fileName: filename, mimeType: mimeType)
                     }
                     else if filetype.lowercased() == ".wmv"{
                         mimeType = "video/x-ms-wmv"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                     }
                     else{
                         mimeType = "application/octet-stream"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                     }
                    

                    
                }
                         
                     }, to: createSectionURL, encodingCompletion: {
                  (result) in
                  switch result {
                  case .success(let upload, _, _):
                      upload.responseJSON {
                          response in
                          switch response.result {
                          case .success(let j):
                              
                                  let json = JSON(j)
                                  let message = json["statusMessage"].stringValue
                                  let status = json["statusCode"].intValue
                                  if status == 200 {
                                      let data = json["data"]
                                      completion(message,data,status)
                                                                          
                                  }
                                  else {
                                  // Failed server response
                                     let error = JSON(j)
                                     let statusCode = error["statusCode"].intValue
                                     let data = error["data"]
                                     let errorMessage = data["error_msgs"].stringValue
                                     self.reportError(message: errorMessage)
                                     completion(errorMessage,error,statusCode)
                              }
                          case .failure(let error):
                          
                              if error._code == NSURLErrorTimedOut {
                                  completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                              }
                              else if error._code == NSFileNoSuchFileError {
                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                              }
                              else {
                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                              }
                          }
                      }
                  case .failure(let error):
                          
                      if error._code == NSURLErrorTimedOut {
                          completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                      }
                      else if error._code == NSFileNoSuchFileError {
                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                      }
                      else {
                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                      }
                  }
              })
          }
        
    func addItem1(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam, id: String, subjectName: String, documentCreate: Bool, documentChoose: Bool, documentId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createSectionURL = "\(baseURL!)/api/blended_learning/create_item1"
        
        var params = ["":""]
        if(type.lowercased().elementsEqual("document")){
            if(documentCreate == true){
                params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                    "section_id": "\(section_id)",
                    "type": "\(type)",
                    "title": "\(title)",
                ]
            }
            if(documentChoose == true){
                params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                    "section_id": "\(section_id)",
                    "type": "\(type)",
                    "document_id": "\(documentId)",
                ]
            }
        }
        
        #if DEBUG
                             print("createChannel params",params)
                         #endif
                         self.manager.upload(multipartFormData: {
                           multipartFormData in
                           for (key, value) in params{
                               multipartFormData.append(value.data(using: .utf8)!, withName: key)
                           }
                                }, to: createSectionURL, encodingCompletion: {
                             (result) in
                             switch result {
                             case .success(let upload, _, _):
                                 upload.responseJSON {
                                     response in
                                     switch response.result {
                                     case .success(let j):
                                         
                                             let json = JSON(j)
                                             let message = json["statusMessage"].stringValue
                                             let status = json["statusCode"].intValue
                                             if status == 200 {
                                                 let data = json["data"]
                                                 completion(message,data,status)
                                                                                     
                                             }
                                             else {
                                             // Failed server response
                                                let error = JSON(j)
                                                let statusCode = error["statusCode"].intValue
                                                let data = error["data"]
                                                let errorMessage = data["error_msgs"].stringValue
                                                self.reportError(message: errorMessage)
                                                completion(errorMessage,error,statusCode)
                                         }
                                     case .failure(let error):
                                     
                                         if error._code == NSURLErrorTimedOut {
                                             completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                                         }
                                         else if error._code == NSFileNoSuchFileError {
                                             completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                         }
                                         else {
                                             completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                         }
                                     }
                                 }
                             case .failure(let error):
                                     
                                 if error._code == NSURLErrorTimedOut {
                                     completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                                 }
                                 else if error._code == NSFileNoSuchFileError {
                                     completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                 }
                                 else {
                                     completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                 }
                             }
                         })
    }
    func addItem(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam, id: String, subjectName: String, documentCreate: Bool, documentChoose: Bool, documentId: String, replies: Bool, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
                  let createSectionURL = "\(baseURL!)/api/blended_learning/create_item"
            
            var params = ["":""]
        print("type type: \(type.lowercased())")
            if(type.lowercased().elementsEqual("document")){
                if(documentCreate == true){
                    params = [
                        "username": "\(user.userName)",
                        "token": "\(user.token)",
                        "section_id": "\(section_id)",
                        "type": "\(type)",
                        "title": "\(title)",
                        "document_type": "\(true)",
                    ]
                }
                if(documentChoose == true){
                    params = [
                        "username": "\(user.userName)",
                        "token": "\(user.token)",
                        "section_id": "\(section_id)",
                        "type": "\(type)",
                        "document_id": "\(documentId)",
                        "document_type": "\(false)",

                    ]
                }
                
            }
           
            else if(type.lowercased().elementsEqual("discussion")){
                

                params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                    "section_id": "\(section_id)",
                    "type": "\(type)",
                    "title": "\(title)",
                    "can_reply": "1",
                    "body": "\(agenda.description)",
                    "students": "\(agenda.students)",
                ]
            
            }
            else if(type.lowercased().elementsEqual("assignment")){
                
                var students = ""
                for (index, std) in agenda.students.enumerated(){
                    if students.count > 1{
                        if index == 0{
                            students = "\(std)"
                        }else{
                            students = "\(students),\(std)"
                        }
                    }else{
                        students = std
                    }
                }
                            
                //no student list in assessment
                if agenda.assignmentId == agendaType.Assessment.rawValue{

                    print("Assessment1: \(user.userName)")
                    print("Assessment2: \(user.token)")
                    print("Assessment3: \(user.userName)")
                    print("Assessment4: \(agenda.assignmentId)")
                    print("Assessment4: \(type)")
                    print("Assessment5: \(agenda.subjectId)")
                    print("Assessment6: \(agenda.startDate)")
                    print("Assessment7: \(agenda.description)")
                    print("Assessment8: \(agenda.assessmentTypeId)")
                    print("Assessment9: \(agenda.groupId)")
                    print("Assessment10: \(agenda.mark)")
                    print("Assessment11: \(agenda.title)")
                    
                    
                    params = [
                        "username": "\(user.userName)",
                        "token": "\(user.token)",
                        "student_username": "\(user.userName)",
                        "assignment_type":"\(agenda.assignmentId)",
                        "title": "\(type)",
                        "sub_term": "\(agenda.groupId)",
                        "subject": "\(agenda.subjectId)",
                        "due_date": "\(agenda.startDate)",
                        "description": "\(agenda.description)",
                        "assessment_type": "\(agenda.assessmentTypeId)",
                        "full_mark": "\(agenda.mark)",
                        "section_id":"\(section_id)",
                        "type": "\(type)",
                        "assignment_title": "\(agenda.title)",
                        "name":"\(subjectName)" ]
                }
                else if(agenda.assignmentId == agendaType.Exam.rawValue){
                    params = [
                        "username": "\(user.userName)",
                        "token": "\(user.token)",
                        "assignment_type":"\(agenda.assignmentId)",
                        "title": "\(type)",
                        "sub_term": "\(agenda.groupId)",
                        "subject": "\(agenda.subjectId)",
                        "due_date": "\(agenda.startDate)",
                        "description": "\(agenda.description)",
                        "section_id":"\(section_id)",
                        "type": "\(type)",
                        "name":"\(subjectName)" ]
                }
                else{
                    
                    print("homework1: \(user.userName)")
                    print("homework2: \(user.token)")
                    print("homework3: \(agenda.assignmentId)")
                    print("homework4: \(students)")
                    print("homework5: \(agenda.subjectId)")
                    print("homework6: \(agenda.startDate)")
                    print("homework7: \(agenda.description)")
                    print("homework8: \(section_id)")
                    print("homework9: \(type)")
                    
                    params = [
                        "username": "\(user.userName)",
                        "token": "\(user.token)",
                        "assignment_type":"\(agenda.assignmentId)",
                        "sub_term": "",
                        "students": "\(students)",
                        "subject": "\(agenda.subjectId)",
                        "due_date": "\(agenda.startDate)",
                        "description": "\(agenda.description)",
                        "section_id":"\(section_id)",
                        "type": "\(type)",
                        "name":"\(subjectName)"
                    ]
                }
            }
            else if(type.lowercased().elementsEqual("url")){
                params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                    "section_id": "\(section_id)",
                    "type": "\(type)",
                    "title": "\(title)",
                    "url": "\(url)"
                ]
            }
            else if(type.lowercased().elementsEqual("online_exam")){
                params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                    "section_id": "\(section_id)",
                    "type": "\(type)",
                    "id": "\(id)"
                ]
        }
                 
            

                  
                  #if DEBUG
                      print("createChannel params",params)
                  #endif
                  self.manager.upload(multipartFormData: {
                    multipartFormData in
                    for (key, value) in params{
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }
                         }, to: createSectionURL, encodingCompletion: {
                      (result) in
                      switch result {
                      case .success(let upload, _, _):
                          upload.responseJSON {
                              response in
                              switch response.result {
                              case .success(let j):
                                  
                                      let json = JSON(j)
                                      let message = json["statusMessage"].stringValue
                                      let status = json["statusCode"].intValue
                                      if status == 200 {
                                          let data = json["data"]
                                          completion(message,data,status)
                                                                              
                                      }
                                      else {
                                      // Failed server response
                                         let error = JSON(j)
                                         let statusCode = error["statusCode"].intValue
                                         let data = error["data"]
                                         let errorMessage = data["error_msgs"].stringValue
                                        print("status code: \(statusCode)")
                                        print("data: \(data)")
                                        print("errorMessage: \(errorMessage)")
                                         self.reportError(message: errorMessage)
                                         completion(errorMessage,error,statusCode)
                                  }
                              case .failure(let error):
                              
                                  if error._code == NSURLErrorTimedOut {
                                      completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                                  }
                                  else if error._code == NSFileNoSuchFileError {
                                    
                                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                  }
                                  else {
                                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                  }
                              }
                          }
                      case .failure(let error):
                              
                          if error._code == NSURLErrorTimedOut {
                              completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                          }
                          else if error._code == NSFileNoSuchFileError {
                              completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                          }
                          else {
                              completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                          }
                      }
                  })
              }
            
    func editItem(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam, id: String, subjectName: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
              let createSectionURL = "\(baseURL!)/api/blended_learning/edit_item"
        
        var params = ["":""]
        if(type.lowercased().elementsEqual("document")){
            params = [
                "username": "\(user.userName)",
                "token": "\(user.token)",
                "section_id": "\(section_id)",
                "type": "\(type)",
                "title": "\(title)",
                "id": "\(id)",
            ]
        }
        else if(type.lowercased().elementsEqual("discussion")){
            

            params = [
                "username": "\(user.userName)",
                "token": "\(user.token)",
                "section_id": "\(section_id)",
                "type": "\(type)",
                "title": "\(title)",
                "can_reply": "1",
                "students": "\(agenda.students)",
                "id": "\(id)",
            ]
        
        }
        else if(type.lowercased().elementsEqual("assignment")){
            
            var students = ""
            for (index, std) in agenda.students.enumerated(){
                if students.count > 1{
                    if index == 0{
                        students = "\(std)"
                    }else{
                        students = "\(students),\(std)"
                    }
                }else{
                    students = std
                }
            }
                        
            //no student list in assessment
            if agenda.assignmentId == agendaType.Assessment.rawValue{

               
                
                
                params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                    "student_username": "\(user.userName)",
                    "assignment_type":"\(agenda.assignmentId)",
                    "title": "\(type)",
                    "sub_term": "\(agenda.groupId)",
                    "subject": "\(agenda.subjectId)",
                    "due_date": "\(agenda.startDate)",
                    "description": "\(agenda.description)",
                    "assessment_type": "\(agenda.assessmentTypeId)",
                    "full_mark": "\(agenda.mark)",
                    "section_id":"\(section_id)",
                    "type": "\(type)",
                    "assignment_title": "\(agenda.title)",
                    "id": "\(id)",
                    "name":"\(subjectName)" ]
            }
            else if(agenda.assignmentId == agendaType.Exam.rawValue){
                params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                    "assignment_type":"\(agenda.assignmentId)",
                    "title": "\(type)",
                    "sub_term": "\(agenda.groupId)",
                    "subject": "\(agenda.subjectId)",
                    "due_date": "\(agenda.startDate)",
                    "description": "\(agenda.description)",
                    "section_id":"\(section_id)",
                    "type": "\(type)",
                    "id": "\(id)",
                    "name":"\(subjectName)" ]
            }
            else{
                
                print("homework1: \(user.userName)")
                print("homework2: \(user.token)")
                print("homework3: \(agenda.assignmentId)")
                print("homework4: ")
                print("homework4: \(students)")
                print("homework5: \(agenda.subjectId)")
                print("homework6: \(agenda.startDate)")
                print("homework7: \(agenda.description)")
                print("homework8: \(section_id)")
                print("homework9: \(type)")
                print("homework10: \(id)")
                print("homework11: \(subjectName)")
                
                params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                    "assignment_type":"\(agenda.assignmentId)",
                    "sub_term": "",
                    "students": "\(students)",
                    "subject": "\(agenda.subjectId)",
                    "due_date": "\(agenda.startDate)",
                    "description": "\(agenda.description)",
                    "section_id":"\(section_id)",
                    "type": "\(type)",
                    "id": "\(id)",
                    "name":"\(subjectName)"
                ]
            }
        }
        else if(type.lowercased().elementsEqual("url")){
            params = [
                "username": "\(user.userName)",
                "token": "\(user.token)",
                "section_id": "\(section_id)",
                "type": "\(type)",
                "title": "\(title)",
                "id": "\(id)",
                "url": "\(url)"
            ]
        }
       
             
        

              
              #if DEBUG
                  print("editSectionItem params",params)
              #endif
              self.manager.upload(multipartFormData: {
                multipartFormData in
                for (key, value) in params{
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                     }, to: createSectionURL, encodingCompletion: {
                  (result) in
                  switch result {
                  case .success(let upload, _, _):
                      upload.responseJSON {
                          response in
                          switch response.result {
                          case .success(let j):
                              
                                  let json = JSON(j)
                            print("==> json \(json)")
                                  let message = json["statusMessage"].stringValue
                                  let status = json["statusCode"].intValue
                                  if status == 200 {
                                      let data = json["data"]
                                      completion(message,data,status)
                                                                          
                                  }
                                  else {
                                  // Failed server response
                                     let error = JSON(j)
                                     let statusCode = error["statusCode"].intValue
                                     let data = error["data"]
                                     let errorMessage = data["error_msgs"].stringValue
                                     self.reportError(message: errorMessage)
                                     completion(errorMessage,error,statusCode)
                              }
                          case .failure(let error):
                            print("error error1: \(error)")
                              if error._code == NSURLErrorTimedOut {
                                  completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                              }
                              else if error._code == NSFileNoSuchFileError {
                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                              }
                              else {
                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                              }
                          }
                      }
                  case .failure(let error):
                          print("error error1: \(error)")
                      if error._code == NSURLErrorTimedOut {
                          completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                      }
                      else if error._code == NSFileNoSuchFileError {
                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                      }
                      else {
                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                      }
                  }
              })
          }
        
    func editItemWithAttachment(user: User, type: String, section_id: String, title: String, url: String, startDate: String, agenda: AgendaExam,file: URL?, image: UIImage?, isSelectedImage: Bool, subjectName: String, id: String, selectAttachment: Bool, attachmentLink: String, attachmentType: String, edit: Bool, filename: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
          let createSectionURL = "\(baseURL!)/api/blended_learning/edit_item"
    
    var params = ["":""]
     if(type.lowercased().elementsEqual("document")){
                   params = [
                       "username": "\(user.userName)",
                       "token": "\(user.token)",
                       "section_id": "\(section_id)",
                       "type": "\(type)",
                        "id": "\(id)",
                       "title": "\(title)",
                   ]
               }
     
     else if(type.lowercased().elementsEqual("discussion")){
         

         params = [
             "username": "\(user.userName)",
             "token": "\(user.token)",
             "section_id": "\(section_id)",
             "type": "\(type)",
             "title": "\(title)",
             "can_reply": "1",
             "students": "\(agenda.students)",
             "id": "\(id)",
         ]
     
     }
               else if(type.lowercased().elementsEqual("assignment")){
                   
                   var students = ""
                   for (index, std) in agenda.students.enumerated(){
                       if students.count > 1{
                           if index == 0{
                               students = "\(std)"
                           }else{
                               students = "\(students),\(std)"
                           }
                       }else{
                           students = std
                       }
                   }
        
        print("students selected :\(students)")
                               
                   //no student list in assessment
                   if agenda.assignmentId == agendaType.Assessment.rawValue{

                       params = [
                           "username": "\(user.userName)",
                           "token": "\(user.token)",
                           "assignment_type":"\(agenda.assignmentId)",
                           "title": "\(type)",
                           "sub_term": "\(agenda.groupId)",
                           "subject": "\(agenda.subjectId)",
                           "due_date": "\(agenda.startDate)",
                           "description": "\(agenda.description)",
                           "assessment_type": "\(agenda.assessmentTypeId)",
                           "full_mark": "\(agenda.mark)",
                           "section_id":"\(section_id)",
                           "type": "\(type)",
                            "id": "\(id)",
                           "name":"\(subjectName)" ]
                   }
                   else if(agenda.assignmentId == agendaType.Exam.rawValue){
                       params = [
                           "username": "\(user.userName)",
                           "token": "\(user.token)",
                           "assignment_type":"\(agenda.assignmentId)",
                           "title": "\(type)",
                           "sub_term": "\(agenda.groupId)",
                           "subject": "\(agenda.subjectId)",
                           "due_date": "\(agenda.startDate)",
                           "description": "\(agenda.description)",
                           "section_id":"\(section_id)",
                           "type": "\(type)",
                            "id": "\(id)",
                           "name":"\(subjectName)" ]
                   }
                   else{
                    
                       params = [
                           "username": "\(user.userName)",
                           "token": "\(user.token)",
                           "assignment_type":"\(agenda.assignmentId)",
                           "sub_term": "",
                           "students": "\(students)",
                           "subject": "\(agenda.subjectId)",
                           "due_date": "\(agenda.startDate)",
                           "description": "\(agenda.description)",
                           "section_id":"\(section_id)",
                           "type": "\(type)",
                            "id": "\(id)",
                           "name":"\(subjectName)"
                       ]
                   }
               }
               else if(type.lowercased().elementsEqual("url")){
                   params = [
                       "username": "\(user.userName)",
                       "token": "\(user.token)",
                       "section_id": "\(section_id)",
                       "type": "\(type)",
                       "title": "\(title)",
                     "id": "\(id)",
                       "url": "\(url)"
                   ]
               }
              
          
          #if DEBUG
              print("createChannel params",params)
          #endif
          self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            let filetype = attachmentType.suffix(4)
            var check: Bool = filetype == "/jpg" || filetype == "jpeg" || filetype == "/png"
            
            if(edit && selectAttachment == false && check){
                    
                        print("async pressed")
                        let imageUrl = URL(string: attachmentLink)!

                        let imageData = try! Data(contentsOf: imageUrl)

                        let imagee = UIImage(data: imageData)
                    
                multipartFormData.append(imagee!.jpeg(.lowest)!, withName: "attachment", fileName: filename, mimeType: "image/jpeg")
               
            }
            else{
                if isSelectedImage{
                    multipartFormData.append(image!.jpeg(.lowest)!, withName: "attachment", fileName: filename, mimeType: "image/jpeg")
                }else{
                let pdfData = try! Data(contentsOf: file!)
                let filetype = file!.description.suffix(4)
                var mimeType = ""
                    if filetype.lowercased() == ".pdf"{
                        mimeType = "application/pdf"
                    }else if filetype.lowercased() == "docx"{
                        mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                    }else if filetype.lowercased() == "xlsx"{
                        mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    }else if filetype.lowercased() == "pptx" || filetype.lowercased() == "ppsx" || filetype.lowercased() == "ppt"{
                        mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                    }
                     else if filetype.lowercased() == ".m4a"{
                         mimeType = "audio/mpeg"
                     }
                     else if filetype.lowercased() == ".mp3" || filetype == ".mid" || filetype == ".midi" || filetype == ".kar" || filetype == ".ogg" || filetype == ".aac"{
                         mimeType = "audio/mpeg"
                     }
                    else if(filetype.lowercased() == ".gif"){
                        mimeType = "audio/gif"
                    }
                    else if(filetype.lowercased() == ".wma"){
                        mimeType = "audio/wma"
                    }
                    else if(filetype.lowercased() == ".rtf"){
                        mimeType = "application/rtf"
                    }
                    else if(filetype.lowercased() == ".txt"){
                        mimeType = "text/plain"
                    }
                    else if(filetype.lowercased() == ".csv"){
                        mimeType = "text/csv"
                    }
                    else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                         mimeType = "video/mp4"
                     }
                     else if filetype.lowercased() == ".wmv"{
                         mimeType = "video/x-ms-wmv"
                     }
                     else{
                         mimeType = "application/octet-stream"
                     }
                    
                    multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
                    
                }
            }
            
                     
                 }, to: createSectionURL, encodingCompletion: {
              (result) in
              switch result {
              case .success(let upload, _, _):
                  upload.responseJSON {
                      response in
                      switch response.result {
                      case .success(let j):
                          
                              let json = JSON(j)
                              let message = json["statusMessage"].stringValue
                              let status = json["statusCode"].intValue
                              if status == 200 {
                                  let data = json["data"]
                                  completion(message,data,status)
                                                                      
                              }
                              else {
                              // Failed server response
                                 let error = JSON(j)
                                 let statusCode = error["statusCode"].intValue
                                 let data = error["data"]
                                 let errorMessage = data["error_msgs"].stringValue
                                 self.reportError(message: errorMessage)
                                 completion(errorMessage,error,statusCode)
                          }
                      case .failure(let error):
                      
                          if error._code == NSURLErrorTimedOut {
                              completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                          }
                          else if error._code == NSFileNoSuchFileError {
                              completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                          }
                          else {
                              completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                          }
                      }
                  }
              case .failure(let error):
                      
                  if error._code == NSURLErrorTimedOut {
                      completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                  }
                  else if error._code == NSFileNoSuchFileError {
                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                  }
                  else {
                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                  }
              }
          })
      }
    
    //Remove section item API:
    func deleteItem(user: User, itemId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let removeItemURL = "\(baseURL!)/api/blended_learning/delete_item"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "id": "\(itemId)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: removeItemURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Remove section item API:
    func deleteSection(user: User, sectionId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let removeItemURL = "\(baseURL!)/api/blended_learning/delete_section"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "id": "\(sectionId)"
        ]
        print("section id: \(sectionId)")
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: removeItemURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Remove section item API:
    func deleteChannel(user: User, channelId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let removeItemURL = "\(baseURL!)/api/blended_learning/delete_channel"
        
        print("params1: \(user.userName)")
        print("params2: \(user.token)")
        print("params3: \(channelId)")
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "id": "\(channelId)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: removeItemURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        print(data)
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Remove section item API:
    func publishChannel(user: User, channelId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let removeItemURL = "\(baseURL!)/api/blended_learning/publish_item"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "id": "\(channelId)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: removeItemURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    func convertArrayToJSON(array: [Any]) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: [])
            return jsonData
        } catch {
            print("Error converting to JSON: \(error)")
            return nil
        }
    }
    
    func isDate(_ dateToCheck: Date, between startDate: Date, and endDate: Date) -> Bool {
        return dateToCheck >= startDate && dateToCheck <= endDate
    }
    
    //Get Attendance Data:
    func getAttendance(user: User, studentUsername: String, startDate: String, endDate: String, completion: @escaping(_ message: String?, _ result: [Attendance]?, _ status: Int?)->Void){
        
        print("user details: \(user )")
        let calendar = Calendar.current
        let dFormat =  DateFormatter()
        dFormat.dateFormat = "yyyy-MM-dd"
        let date = dFormat.date(from: startDate) ?? Date()
        let currentMonth = calendar.component(.month, from: date)
        print("current month: \(startDate)")
        print("current month: \(currentMonth)")
        let attendanceURL = "\(ATTENDANCE_URL)/getStudentAbsencesList?studentId=\(user.admissionNo)&month=\(currentMonth)"
       
        
        let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)",
            "student_username": "\(studentUsername)",
            "start_date": "\(startDate)",
            "end_date": "\(endDate)",
        ]

        #if DEBUG
            print("==>getAttendance params ", params)
        #endif
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        
        self.manager.request(attendanceURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                        let data = JSON(j)
                        let message = data["message"].stringValue
                        var status = 0
                    
                    if(message.contains("details found")){
                        status = 200
                    }
                        let dataArray = data["response"]

                        #if DEBUG
                            print("==>getAttendance ", data)
                        #endif
                        
                        if status == 200 {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            let start = formatter.date(from: startDate)
                            let end = formatter.date(from: endDate)
                            
                         
                            
                            
                            var absence = 0
                            var presence = 0
                            var late = 0
                            var attendanceData: [Attendance] = []
                            var latencyDates: [String] = []
                            var absentDates: [String] = []
                            var detailArray: [attendanceDetail] = []


                            for att in dataArray {
                                let absenceDate = att.1["absenceDate"].stringValue
                                let absenceD = formatter.date(from: absenceDate)
                                
                                if self.isDate(absenceD ?? Date(), between: start ?? Date(), and: end ?? Date()){
                                    
                                    let fullDay = att.1["isFullDay"].boolValue
                                    if(fullDay){
                                        absence += 1
                                        let d = att.1["absenceDate"].stringValue
                                        absentDates.append(d)

                                        let id = att.1["id"].intValue
                                        let verified = att.1["isVerified"].boolValue
                                        let reason = att.1["absenceReason"].stringValue
                                        let detail = attendanceDetail(id: id, date: d, verified: verified, reason: reason)
                                        detailArray.append(detail)
                                    }
                                    else{
                                        late += 1
                                        let d = att.1["absenceDate"].stringValue
                                        latencyDates.append(d)
                                        
                                        let id = att.1["id"].intValue
                                        let verified = att.1["isVerified"].boolValue
                                        let reason = att.1["absenceReason"].stringValue
                                        let detail = attendanceDetail(id: id, date: d, verified: verified, reason: reason)
                                        detailArray.append(detail)
                                        

                                    }
                                    
                                    
                                }
                                
                            }
                            
                            let calendar = Calendar.current
                            let currentDate = Date()

                            // Get the range of dates for the current month
                            var days = 1
                            if let currentMonthRange = calendar.range(of: .day, in: .month, for: currentDate) {
                                days = currentMonthRange.count
                                print("Number of days in the current month: \(days)")
                            } else {
                                print("Failed to get the range of days for the current month")
                            }
                            print(days)
                            
                            let latePerc = Double(late * 100) / Double(days)
                            
                            let latencyAttendance = Attendance(type: "latency", color: "#ffcb39", percentage: Double(String(format: "%.2f", latePerc)) ?? 0.0, dates: latencyDates, details: detailArray)
                            attendanceData.append(latencyAttendance)
                          
                            
                            let absentPerc = Double(absence * 100) / Double(days)
                            
                            let absentAttendance = Attendance(type: "absent", color: "#ff5955", percentage: Double(String(format: "%.2f", absentPerc)) ?? 0.0, dates: absentDates, details: detailArray)
                            attendanceData.append(absentAttendance)
                            
                            let leftDays = days - late - absence
                            let presPerc = 100 - absentPerc - latePerc
                            let presentAttendance = Attendance(type: "present", color: "#014e80", percentage: Double(String(format: "%.2f", presPerc)) ?? 0.0, dates: [], details: [])
                            attendanceData.append(presentAttendance)
                
                            
                            completion(message,attendanceData,status)
                        }
                        else {
                            // Failed server response
                            let description = data["message"].stringValue
                            self.reportError(message: description)
                            completion(description,[],status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
        
    }
    
    ////////////////////////// agenda discussion apis/////////////////////////////////////////
    
//    func studentAnswerWithAttachment(user: User, senderId: String, assignmentId: String, message: String, file: URL?, image: UIImage?, isSelectedImage: Bool, filename: String, fileCompressed: NSData?, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
//              let createSectionURL = "\(baseURL!)/api/agenda/submit_student_answer"
//
//        let params = [
//            "sender_id": "\(user.userId)",
//            "token": "\(user.token)",
//            "assignment_id": "\(assignmentId)",
//            "message": "\(message)",
//            "title": "agenda answer",
//        ]
//
//
//              #if DEBUG
//                  print("submit student answer params",params)
//              #endif
//              self.manager.upload(multipartFormData: {
//                multipartFormData in
//                for (key, value) in params{
//                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
//                }
//                if isSelectedImage{
//                    multipartFormData.append(image!.jpeg(.lowest)!, withName: "attachment", fileName: filename, mimeType: "image/jpeg")
//                }else{
//                let pdfData = try! Data(contentsOf: file!)
//                let filetype = file!.description.suffix(4)
//                var mimeType = ""
//                    if filetype.lowercased() == ".pdf"{
//                        mimeType = "application/pdf"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                    }else if filetype.lowercased() == "docx"{
//                        mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                    }else if filetype.lowercased() == "xlsx"{
//                        mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                    }else if filetype.lowercased() == "pptx" || filetype.lowercased() == "ppsx" || filetype.lowercased() == "ppt"{
//                        mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                    }
//                     else if filetype.lowercased() == ".m4a"{
//                         mimeType = "audio/mpeg"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                     }
//                     else if filetype.lowercased() == ".mp3" || filetype == ".mid" || filetype == ".midi" || filetype == ".kar" || filetype == ".ogg" || filetype == ".aac"{
//                         mimeType = "audio/mpeg"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                     }
//                    else if(filetype.lowercased() == ".gif"){
//                        mimeType = "audio/gif"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                    }
//                    else if(filetype.lowercased() == ".wma"){
//                        mimeType = "audio/wma"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                    }
//                    else if(filetype.lowercased() == ".rtf"){
//                        mimeType = "application/rtf"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                    }
//                    else if(filetype.lowercased() == ".txt"){
//                        mimeType = "text/plain"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                    }
//                    else if(filetype.lowercased() == ".csv"){
//                        mimeType = "text/csv"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                    }
//                    else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
//                         mimeType = "video/mp4"
//                        multipartFormData.append(fileCompressed! as Data, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                     }
//                     else if filetype.lowercased() == ".wmv"{
//                         mimeType = "video/x-ms-wmv"
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                     }
//                     else{
//                         mimeType = "application/octet-stream"
//
//                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)
//
//                     }
//
//
//                }
//
//                     }, to: createSectionURL, encodingCompletion: {
//                  (result) in
//                  switch result {
//                  case .success(let upload, _, _):
//                      upload.responseJSON {
//                          response in
//                          switch response.result {
//                          case .success(let j):
//
//                                  let json = JSON(j)
//                                  let message = json["statusMessage"].stringValue
//                                  let status = json["statusCode"].intValue
//                                  if status == 200 {
//                                      let data = json["data"]
//                                      completion(message,data,status)
//
//                                  }
//                                  else {
//                                  // Failed server response
//                                     let error = JSON(j)
//                                     let statusCode = error["statusCode"].intValue
//                                     let data = error["data"]
//                                     let errorMessage = data["error_msgs"].stringValue
//                                     self.reportError(message: errorMessage)
//                                     completion(errorMessage,error,statusCode)
//                              }
//                          case .failure(let error):
//
//                              if error._code == NSURLErrorTimedOut {
//                                  completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
//                              }
//                              else if error._code == NSFileNoSuchFileError {
//                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                              }
//                              else {
//                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                              }
//                          }
//                      }
//                  case .failure(let error):
//
//                      if error._code == NSURLErrorTimedOut {
//                          completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
//                      }
//                      else if error._code == NSFileNoSuchFileError {
//                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                      }
//                      else {
//                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                      }
//                  }
//              })
//          }
//
    
    func studentAnswerWithAttachment(user: User, senderId: String, assignmentId: String, message: String, file: URL?, image: UIImage?, isSelectedImage: Bool, filename: String, fileCompressed: NSData?, actualTime: String,completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createAssignmentURL = "\(AGENDA_ASSIGNMENTS_URL)/addstudentanswer?actual_time=\(actualTime)&assignedStudentId=\(senderId)"
        print("occasion occasion: \(createAssignmentURL)")
//        print("occasion occasion1: \(filename)")

       

        
        let params = [
        
        [
            "key": "school_id",
            "value": "\(user.schoolId)",
            "type": "text"
          ],
          [
            "key": "answer",
            "value": "\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ]
          
          ]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for param in params {
                if let key = param["key"], let value = param["value"] {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }


            if isSelectedImage{
                multipartFormData.append(image!.jpeg(.lowest)!, withName: "file", fileName: filename, mimeType: "image/jpeg")
            }else{
                let pdfData = try! Data(contentsOf: file!)
                let filetype = file!.description.suffix(4)
                var mimeType = ""
                if filetype.lowercased() == ".pdf"{
                    mimeType = "application/pdf"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                }else if filetype.lowercased() == "docx"{
                    mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                }else if filetype.lowercased() == "xlsx"{
                    mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                }else if filetype.lowercased() == "pptx" || filetype.lowercased() == "ppsx" || filetype.lowercased() == "ppt"{
                    mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                }
                 else if filetype.lowercased() == ".m4a"{
                     mimeType = "audio/mpeg"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                 }
                 else if filetype.lowercased() == ".mp3" || filetype == ".mid" || filetype == ".midi" || filetype == ".kar" || filetype == ".ogg" || filetype == ".aac"{
                     mimeType = "audio/mpeg"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                 }
                else if(filetype.lowercased() == ".gif"){
                    mimeType = "audio/gif"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".wma"){
                    mimeType = "audio/wma"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".rtf"){
                    mimeType = "application/rtf"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".txt"){
                    mimeType = "text/plain"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".csv"){
                    mimeType = "text/csv"
                    multipartFormData.append(pdfData, withName: "file", fileName: filename, mimeType: mimeType)
                }
                else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                     mimeType = "video/mp4"
                    multipartFormData.append(fileCompressed! as Data, withName: "file", fileName: filename, mimeType: mimeType)
                    
                 }
                 else if filetype.lowercased() == ".wmv"{
                     mimeType = "video/x-ms-wmv"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                 else{
                     mimeType = "application/octet-stream"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                
                
            }

        }, to: createAssignmentURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        var status = 0
                        if message == "success" {
                            let data = json["data"]
                            status = 200
                            completion(message,data,status)
                        }
                        else {
                        // Failed server response
                            let error = JSON(j)
                            let statusCode = error["statusCode"].intValue
                            let data = error["data"]
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,error,statusCode)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):

                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    
    func studentAnswer(user: User, senderId: String, assignmentId: String, message: String, actualTime: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createAssignmentURL = "\(AGENDA_ASSIGNMENTS_URL)/addstudentanswer?assignedStudentId=\(senderId)&actual_time=\(actualTime)"
        print("occasion occasion: \(createAssignmentURL)")
//        print("occasion occasion1: \(filename)")

       

        
//        let params = [
//
//        [
//            "key": "school_id",
//            "value": "\(user.schoolId)",
//            "type": "text"
//          ],
//          [
//            "key": "answer",
//            "value": "\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
//            "type": "text"
//          ],
//        [
//          "key": "file",
//          "value": "",
//          "type": "text"
//        ]
//          ]
        
        
        let params = [
            "school_id": "\(user.schoolId)",
            "answer": "\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        ]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params11",params)
        #endif
        
//        self.manager.upload(multipartFormData: {
//            multipartFormData in
//            for (key, value) in params{
//                multipartFormData.append(value.data(using: .utf8)!, withName: key)
//            }
//        }
//
//        self.manager.upload(multipartFormData: {
//            multipartFormData in
//            for param in params {
//                if let key = param["key"], let value = param["value"] {
//                    if let data = value.data(using: .utf8) {
//                        multipartFormData.append(data, withName: key)
//                    }
//                }
//            }
//
//
//        }
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: createAssignmentURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        print("message message: \(message)")

                        var status = 0
                        if message == "success" {
                            let data = json["response"]
                            status = 200
                            completion(message,data,status)
                        }
                        else {
                        // Failed server response
                            let error = JSON(j)
                            let statusCode = error["statusCode"].intValue
                            let data = error["data"]
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,error,statusCode)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):

                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    func addDiscussionWithAttachment(user: User, senderId: String, assignmentAnswerId: String, message: String, receiverId: String, file: URL?, image: UIImage?, isSelectedImage: Bool, filename: String, fileCompressed: NSData?,completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
              let createSectionURL = "\(baseURL!)/api/agenda/add_discussion"
        
        let params = [
            "sender_id": "\(user.userId)",
            "token": "\(user.token)",
            "assignment_answer_id": "\(assignmentAnswerId)",
            "message": "\(message)",
            "receiver_id": "\(receiverId)"
        ]
        
              
              #if DEBUG
                  print("add discussion params",params)
              #endif
              self.manager.upload(multipartFormData: {
                multipartFormData in
                for (key, value) in params{
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                if isSelectedImage{
                    multipartFormData.append(image!.jpeg(.lowest)!, withName: "attachment", fileName: filename, mimeType: "image/jpeg")
                }else{
                   let pdfData = try! Data(contentsOf: file!)
                    let filetype = file!.description.suffix(4)
                    var mimeType = ""
                    if filetype.lowercased() == ".pdf"{
                        mimeType = "application/pdf"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                    }else if filetype.lowercased() == "docx"{
                        mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                    }else if filetype.lowercased() == "xlsx"{
                        mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                    }else if filetype.lowercased() == "pptx" || filetype.lowercased() == "ppsx" || filetype.lowercased() == "ppt"{
                        mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                    }
                     else if filetype.lowercased() == ".m4a"{
                         mimeType = "audio/mpeg"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                     }
                     else if filetype.lowercased() == ".mp3" || filetype == ".mid" || filetype == ".midi" || filetype == ".kar" || filetype == ".ogg" || filetype == ".aac"{
                         mimeType = "audio/mpeg"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                     }
                    else if(filetype.lowercased() == ".gif"){
                        mimeType = "audio/gif"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                    }
                    else if(filetype.lowercased() == ".wma"){
                        mimeType = "audio/wma"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                    }
                    else if(filetype.lowercased() == ".rtf"){
                        mimeType = "application/rtf"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                    }
                    else if(filetype.lowercased() == ".txt"){
                        mimeType = "text/plain"
                    }
                    else if(filetype.lowercased() == ".csv"){
                        mimeType = "text/csv"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                    }
                    else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                         mimeType = "video/mp4"
                        multipartFormData.append(fileCompressed! as Data, withName: "attachment", fileName: filename, mimeType: mimeType)

                     }
                     else if filetype.lowercased() == ".wmv"{
                         mimeType = "video/x-ms-wmv"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                     }
                     else{
                         mimeType = "application/octet-stream"
                        multipartFormData.append(pdfData, withName: "attachment", fileName: filename, mimeType: mimeType)

                     }
                    
                    
                }
                         
                     }, to: createSectionURL, encodingCompletion: {
                  (result) in
                  switch result {
                  case .success(let upload, _, _):
                      upload.responseJSON {
                          response in
                          switch response.result {
                          case .success(let j):
                              
                                  let json = JSON(j)
                                  let message = json["statusMessage"].stringValue
                                  let status = json["statusCode"].intValue
                                  if status == 200 {
                                      let data = json["data"]
                                      completion(message,data,status)
                                                                          
                                  }
                                  else {
                                  // Failed server response
                                     let error = JSON(j)
                                     let statusCode = error["statusCode"].intValue
                                     let data = error["data"]
                                     let errorMessage = data["error_msgs"].stringValue
                                     self.reportError(message: errorMessage)
                                     completion(errorMessage,error,statusCode)
                              }
                          case .failure(let error):
                          
                              if error._code == NSURLErrorTimedOut {
                                  completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                              }
                              else if error._code == NSFileNoSuchFileError {
                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                              }
                              else {
                                  completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                              }
                          }
                      }
                  case .failure(let error):
                          
                      if error._code == NSURLErrorTimedOut {
                          completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                      }
                      else if error._code == NSFileNoSuchFileError {
                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                      }
                      else {
                          completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                      }
                  }
              })
          }
        
    func addDiscussion(user: User, senderId: String, assignmentAnswerId: String, message: String, receiverId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
                  let createSectionURL = "\(baseURL!)/api/agenda/add_discussion"
            
        print("message in request: \(message)")
           let params = [
               "sender_id": "\(user.userId)",
               "token": "\(user.token)",
               "assignment_answer_id": "\(assignmentAnswerId)",
               "message": "\(message)",
               "receiver_id": "\(receiverId)"
           ]
                  #if DEBUG
                      print("add discussion params",params)
                  #endif
                  self.manager.upload(multipartFormData: {
                    multipartFormData in
                    for (key, value) in params{
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }
                         }, to: createSectionURL, encodingCompletion: {
                      (result) in
                      switch result {
                      case .success(let upload, _, _):
                          upload.responseJSON {
                              response in
                              switch response.result {
                              case .success(let j):
                                  
                                      let json = JSON(j)
                                      let message = json["statusMessage"].stringValue
                                      let status = json["statusCode"].intValue
                                      if status == 200 {
                                          let data = json["data"]
                                          completion(message,data,status)
                                                                              
                                      }
                                      else {
                                      // Failed server response
                                         let error = JSON(j)
                                         let statusCode = error["statusCode"].intValue
                                         let data = error["data"]
                                         let errorMessage = data["error_msgs"].stringValue
                                         self.reportError(message: errorMessage)
                                         completion(errorMessage,error,statusCode)
                                  }
                              case .failure(let error):
                              
                                  if error._code == NSURLErrorTimedOut {
                                      completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                                  }
                                  else if error._code == NSFileNoSuchFileError {
                                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                  }
                                  else {
                                      completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                                  }
                              }
                          }
                      case .failure(let error):
                              
                          if error._code == NSURLErrorTimedOut {
                              completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                          }
                          else if error._code == NSFileNoSuchFileError {
                              completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                          }
                          else {
                              completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                          }
                      }
                  })
              }
    
    //Get student/teacher discussions:
    func teacherDiscussions(user: User, senderId: String, sectionId: String, assignmentId: String, color: String, expandList: [Bool], isFirstEntered: Bool, answersColors: [String], discussionColors: [String], completion: @escaping(_ message: String?, _ result: [StudentRepliesModel]?, _ status: Int?)->Void){
        var agendaURL = ""
        var params = ["":""]
        if(user.userType == 1 || user.userType == 2){
            agendaURL = "\(AGENDA_ASSIGNMENTS_URL)/getteachersubmissions/\(assignmentId)"
            
            params = [
                "token": "\(user.token)",
                "sender_id": "\(user.userId)",
                "section_id": "\(sectionId)",
                "assignment_id": "\(assignmentId)",
            ]
        }
        else if(user.userType == 3){
            agendaURL = "\(baseURL!)/api/agenda/student_discussions"
            params = [
                "token": "\(user.token)",
                "sender_id": "\(user.userId)",
                "assignment_id": "\(assignmentId)",
            ]
        }
        else{
            print("params1: \(user.token)")
            print("params2: \(user.admissionNo)")
            print("params4: \(assignmentId)")
            
            agendaURL = "\(baseURL!)/api/agenda/student_discussions"
            params = [
                "token": "\(user.token)",
                "username": "\(user.admissionNo)",
                "assignment_id": "\(assignmentId)",
                "school_id": "\(user.schoolId)"
            ]
        }
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        self.manager.request(agendaURL, method: .get, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let json):
                    #if DEBUG
                        print("getTeacherDiscussion ==> ", json)
                    #endif
                    
                    let data = JSON(json)
                    let message = data["message"].stringValue
                    var status = 0
                    if(message.contains("Successfully")){
                        status = 200
                    }
                    
                    if status == 200 {
                        var studentsList: [StudentRepliesModel] = []
                        
                        let answers = data["response"]
                        var answerCreator: String = ""
                        var i = 0
                        var index = 0
                        for answer in answers{
                            let id = answer.1["id"].stringValue
                            let assignedStudentId = answer.1["assigned_student_id"].stringValue

                            let assignmentId = answer.1["assignedStudent"]["assignmentId"].stringValue
                            let actualTime = answer.1["actual_time"].stringValue
                            let message = answer.1["answer"].stringValue
                            let employeeId = answer.1["employee_id"].stringValue
                            let studentId = answer.1["assignedStudent"]["studentId"].stringValue
                            answerCreator = studentId
                            let attachmentLink = answer.1["attachment_link"].stringValue
                            let attachmentFileName = answer.1["attachment_file_name"].stringValue
                            let attachmentContentType = answer.1["attachment_content_type"].stringValue
                            let attachmentFileSize = answer.1["attachment_file_size"].stringValue
                            let studentLink = answer.1["student_link"].stringValue
                            let studentFileName = answer.1["student_file_name"].stringValue
                            let studentContentType = answer.1["student_content_type"].stringValue
                            let studentFileSize = answer.1["student_file_size"].stringValue
                            let studentName = "\(answer.1["assignedStudent"]["student"]["user"]["firstName"].stringValue) \(answer.1["assignedStudent"]["student"]["user"]["lastName"].stringValue)"
                            let userId = answer.1["assignedStudent"]["student"]["user"]["id"].intValue
                            let date = answer.1["created_at"].stringValue
                            let status = answer.1["assignedStudent"]["status"].stringValue
                            let gender = "M"
                            let assignmentTitle = answer.1["assignedStudent"]["assignment"]["title"].stringValue
                            let assignmentDescription = answer.1["assignedStudent"]["assignment"]["content"].stringValue
                            let assignmentDueDate = answer.1["assignedStudent"]["assignment"]["dueDate"].stringValue
                            let assignmentEstimatedTime = answer.1["assignedStudent"]["assignment"]["estimatedTime"].stringValue
                            let fullMark = answer.1["assignedStudent"]["assignment"]["fullMark"].stringValue
                            let mark = answer.1["assignedStudent"]["mark"].stringValue
                            let feedbacks = answer.1["discussions"]
                            print("feedbacks: \(feedbacks)")
                            var colorIndex = 0
                            var usersDiscussionMap = ["":""]
                            var usersDiscussionArray = [""]
                            var usersTextMap = ["":""]
                            
                            var orderColor = "black"

                            if(status == "REJECTED"){
                                orderColor = "red"
                            }
                            else if(status == "ACCEPTED"){
                                orderColor = "green"
                            }
                            else if(feedbacks.count > 0 && status == "0"){
                                orderColor = "blue"
                            }
                            
                            let attachments = answer.1["attachments"]
                            var attachmentsList: [AttachmentModel] = []
                            for attachment in attachments {
                                let attachmentId = attachment.1["id"].stringValue
                                let attachmentUrl = attachment.1["url"].stringValue
                                let attachmentFilename = attachment.1["filename"].stringValue
                                let attachmentWidth = attachment.1["width"].stringValue
                                let attachmentHeight = attachment.1["height"].stringValue
                                let attachmentType = attachment.1["contentType"].stringValue
                                let attachmentSize = attachment.1["size"].stringValue
                                let small = attachment.1["small"].stringValue
                                let medium = attachment.1["medium"].stringValue
                                let large = attachment.1["large"].stringValue
                                let filepath = attachment.1["filepath"].stringValue
                                let att = AttachmentModel(id: attachmentId, url: attachmentUrl, filename: attachmentFilename, width: attachmentWidth, height: attachmentHeight, type: attachmentType, size: attachmentSize, small: small, medium: medium, large: large, filepath: filepath)
                                
                                attachmentsList.append(att)
                            }
                            var feedbackList: [FeedbackModel] = []
                            for feedback in feedbacks{
                                print("entered feedback")
                                let id1 = feedback.1["id"].stringValue
                                let receiverName1 = feedback.1["receiver_name"].stringValue
                                let message1 = feedback.1["message"].stringValue
                                let attachmentLink1 = feedback.1["attachment_link"].stringValue
                                let attachmentFileName1 = feedback.1["attachment_file_name"].stringValue
                                let attachmentContentType1 = feedback.1["attachment_content_type"].stringValue
                                let attachmentFileSize1 = feedback.1["attachment_file_size"].stringValue
                                let senderId1 = feedback.1["sender_id"].stringValue
                                var feedbackTextColor = ""
                                var feedbackColor = ""
                                if(senderId1.elementsEqual(answerCreator)){
                                    feedbackColor = discussionColors[index % 11]
                                    feedbackTextColor = answersColors[index % 11]
                                    
                                }
                                else{
                                    if(usersDiscussionArray.contains(senderId1)){
                                        feedbackColor = usersDiscussionMap[senderId1]!
                                        feedbackTextColor = usersTextMap[senderId1]!
                                    }
                                    else{
                                        if(colorIndex == index){
                                            colorIndex = colorIndex + 1
                                            usersDiscussionMap[senderId1] = discussionColors[colorIndex % 11]
                                            usersTextMap[senderId1] = answersColors[colorIndex % 11]
                                            usersDiscussionArray.append(senderId1)
                                            feedbackColor = discussionColors[colorIndex % 11]
                                            feedbackTextColor = answersColors[colorIndex % 11]
                                            colorIndex = colorIndex + 1
                                        }
                                        else{
                                            usersDiscussionMap[senderId1] = discussionColors[colorIndex % 11]
                                            usersTextMap[senderId1] = answersColors[colorIndex % 11]
                                            usersDiscussionArray.append(senderId1)
                                            feedbackColor = discussionColors[colorIndex % 11]
                                            feedbackTextColor = answersColors[colorIndex % 11]
                                            colorIndex = colorIndex + 1
                                        }
                                    }
                                }
                                let receiverId1 = feedback.1["receiver_id"].stringValue
                                let date1 = feedback.1["date"].stringValue
                                let senderName1 = feedback.1["sender_name"].stringValue
                                
                                
                                let feed = FeedbackModel(id: id1, text: message1, textColor: feedbackTextColor, color: feedbackColor, senderId: senderId1, senderName: senderName1, receiverId: receiverId1, receiverName: receiverName1, attachmentLink: attachmentLink1, attachmentContentType: attachmentContentType1, attachmentContentSize: attachmentFileSize1, attachmentFileName: attachmentFileName1, date: date1)
                                
                                feedbackList.append(feed)

                            }
                            
                            let feed1 = FeedbackModel(id: "-1", text: "", textColor: "", color: "", senderId: "", senderName: "", receiverId: "", receiverName: "", attachmentLink: "", attachmentContentType: "", attachmentContentSize: "", attachmentFileName: "", date: "")
                            
                            feedbackList.append(feed1)

                            if(isFirstEntered){
                                let studentReplies = StudentRepliesModel(id: id, text: message, color: answersColors[index % 11], studentId: studentId, studentName: studentName, teacherId: employeeId, attachmentLink: attachmentLink, attachmentContentType: attachmentContentType, attachmentContentSize: attachmentFileSize, attachmentFileName: attachmentFileName, studentLink: studentLink, studentContentType: studentContentType, studentContentSize: studentFileSize, studentFileName: studentFileName, feedbackList: feedbackList, expand: expandList[i], date: date, assignmentId: assignmentId, status: status, gender: gender, orderColor: orderColor, assignmentTitle: assignmentTitle, assignmentDescription: assignmentDescription, assignmentDueDate: assignmentDueDate, assignmentEstimatedTime: assignmentEstimatedTime, actualTime: actualTime, mark: mark, fullMark: fullMark, assignedStudentId: assignedStudentId, attachments: attachmentsList, userId: userId)
                                
                                studentsList.append(studentReplies)
                                i = i + 1
                                }
                            else{
                                let studentReplies = StudentRepliesModel(id: id, text: message, color: answersColors[index % 11], studentId: studentId, studentName: studentName, teacherId: employeeId, attachmentLink: attachmentLink, attachmentContentType: attachmentContentType, attachmentContentSize: attachmentFileSize, attachmentFileName: attachmentFileName, studentLink: studentLink, studentContentType: studentContentType, studentContentSize: studentFileSize, studentFileName: studentFileName, feedbackList: feedbackList, expand: false, date: date, assignmentId: assignmentId, status: status, gender: gender, orderColor: orderColor, assignmentTitle: assignmentTitle, assignmentDescription: assignmentDescription, assignmentDueDate: assignmentDueDate, assignmentEstimatedTime: assignmentEstimatedTime, actualTime: actualTime, mark: mark, fullMark: fullMark, assignedStudentId: assignedStudentId, attachments: attachmentsList, userId: userId)
                                                                                                         
                                studentsList.append(studentReplies)
                            }
                            index = index + 1
                        }
                    
                        
                        completion(message,studentsList,status)
                    }
                    else {
                        // Failed server response
                        let description = message
                        self.reportError(message: description)
                        completion(description,[],status)
                    }
                case .failure(let error):
                
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            }
        }
        
    
    //Get student/teacher discussions:
    func getStudentAnswers(user: User, senderId: String, completion: @escaping(_ message: String?, _ result: [StudentRepliesModel]?, _ status: Int?)->Void){
        var agendaURL = "\(AGENDA_ASSIGNMENTS_URL)/getstudentanswers/\(senderId)"
        var params = ["":""]
       
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("agendaURL: \(agendaURL)")
        self.manager.request(agendaURL, method: .get, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let json):
                    #if DEBUG
                        print("getStudentsAnswers ==> ", json)
                    #endif
                    
                    let data = JSON(json)
                    let message = data["message"].stringValue
                    var status = 0
                    if(message.contains("Successfully")){
                        status = 200
                    }
                    
                    if status == 200 {
                        var studentsList: [StudentRepliesModel] = []
                        
                        let answers = data["response"]
                        var answerCreator: String = ""
                        var i = 0
                        var index = 0
                        for answer in answers{
                            let id = answer.1["id"].stringValue
                            let assignedStudentId = answer.1["assigned_student_id"].stringValue

                            let assignmentId = answer.1["assignedStudent"]["assignmentId"].stringValue
                            let actualTime = answer.1["actual_time"].stringValue
                            let message = answer.1["answer"].stringValue
                            let employeeId = answer.1["employee_id"].stringValue
                            let studentId = answer.1["assignedStudent"]["studentId"].stringValue
                            answerCreator = studentId
                            let attachmentLink = answer.1["attachment_link"].stringValue
                            let attachmentFileName = answer.1["attachment_file_name"].stringValue
                            let attachmentContentType = answer.1["attachment_content_type"].stringValue
                            let attachmentFileSize = answer.1["attachment_file_size"].stringValue
                            let studentLink = answer.1["student_link"].stringValue
                            let studentFileName = answer.1["student_file_name"].stringValue
                            let studentContentType = answer.1["student_content_type"].stringValue
                            let studentFileSize = answer.1["student_file_size"].stringValue
                            let studentName = "\(answer.1["assignedStudent"]["student"]["user"]["firstName"].stringValue) \(answer.1["assignedStudent"]["student"]["user"]["lastName"].stringValue)"
                            let userId = answer.1["assignedStudent"]["student"]["user"]["id"].intValue
                            let date = answer.1["created_at"].stringValue
                            let status = answer.1["assignedStudent"]["status"].stringValue
                            let gender = "M"
                            let assignmentTitle = answer.1["assignedStudent"]["assignment"]["title"].stringValue
                            let assignmentDescription = answer.1["assignedStudent"]["assignment"]["content"].stringValue
                            let assignmentDueDate = answer.1["assignedStudent"]["assignment"]["dueDate"].stringValue
                            let assignmentEstimatedTime = answer.1["assignedStudent"]["assignment"]["estimatedTime"].stringValue
                            let mark = answer.1["assignedStudent"]["mark"].stringValue
                            let feedbacks = answer.1["discussions"]
                            print("feedbacks: \(feedbacks)")
                            var colorIndex = 0
                            var usersDiscussionMap = ["":""]
                            var usersDiscussionArray = [""]
                            var usersTextMap = ["":""]
                            
                            var orderColor = "black"

                            if(status == "REJECTED"){
                                orderColor = "red"
                            }
                            else if(status == "ACCEPTED"){
                                orderColor = "green"
                            }
                            else if(feedbacks.count > 0 && status == "0"){
                                orderColor = "blue"
                            }
                            
                            let attachments = answer.1["attachments"]
                            var attachmentsList: [AttachmentModel] = []
                            for attachment in attachments {
                                let attachmentId = attachment.1["id"].stringValue
                                let attachmentUrl = attachment.1["url"].stringValue
                                let attachmentFilename = attachment.1["filename"].stringValue
                                let attachmentWidth = attachment.1["width"].stringValue
                                let attachmentHeight = attachment.1["height"].stringValue
                                let attachmentType = attachment.1["type"].stringValue
                                let attachmentSize = attachment.1["size"].stringValue
                                let small = attachment.1["small"].stringValue
                                let medium = attachment.1["medium"].stringValue
                                let large = attachment.1["large"].stringValue
                                let filepath = attachment.1["filepath"].stringValue
                                let att = AttachmentModel(id: attachmentId, url: attachmentUrl, filename: attachmentFilename, width: attachmentWidth, height: attachmentHeight, type: attachmentType, size: attachmentSize, small: small, medium: medium, large: large, filepath: filepath)
                                
                                attachmentsList.append(att)
                            }
                            var feedbackList: [FeedbackModel] = []
                            
                          
                                let studentReplies = StudentRepliesModel(id: id, text: message, color: "", studentId: studentId, studentName: studentName, teacherId: employeeId, attachmentLink: attachmentLink, attachmentContentType: attachmentContentType, attachmentContentSize: attachmentFileSize, attachmentFileName: attachmentFileName, studentLink: studentLink, studentContentType: studentContentType, studentContentSize: studentFileSize, studentFileName: studentFileName, feedbackList: feedbackList, expand: false, date: date, assignmentId: assignmentId, status: status, gender: gender, orderColor: orderColor, assignmentTitle: assignmentTitle, assignmentDescription: assignmentDescription, assignmentDueDate: assignmentDueDate, assignmentEstimatedTime: assignmentEstimatedTime, actualTime: "", mark: mark, fullMark: "", assignedStudentId: assignedStudentId, attachments: attachmentsList, userId: userId)
                                
                                studentsList.append(studentReplies)
                                i = i + 1
                                
                            
                            index = index + 1
                        }
                    
                        
                        completion(message,studentsList,status)
                    }
                    else {
                        // Failed server response
                        let description = message
                        self.reportError(message: description)
                        completion(description,[],status)
                    }
                case .failure(let error):
                
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            }
        }
        
    
    func convertDateFormat(dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MM-dd-yyyy"
            let formattedDate = outputFormatter.string(from: date)
            return formattedDate
        } else {
            return nil  // Unable to parse the input date string
        }
    }
    
    //Get Agenda Data:
    func getAgenda(user: User, studentUsername: String, startDate: String, endDate: String, agendaTheme: AgendaTheme, completion: @escaping(_ message: String?, _ result: [Event]?, _ status: Int?)->Void){
        
        var start_date = ""
        var end_date = ""

        if let outputStartDate = convertDateFormat(dateString: startDate) {
            start_date = outputStartDate
        } else {
            print("Invalid date format")
        }
        
        if let outputEndDate = convertDateFormat(dateString: endDate) {
            end_date = outputEndDate
        } else {
            print("Invalid date format")
        }
        
        let agendaURL = "\(AGENDA_ASSIGNMENTS_URL)/getassignmentsbysubject/\(user.admissionNo)?start_date=\(start_date)&end_date=\(end_date)"
        print("user user agendaURL: \(agendaURL)")
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header111: \(headers)")
        print(agendaURL)
        self.manager.request(agendaURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    print("==>viewSectionAssignmentStudent", json)
                    var agendaArray: [Event] = []
                    var quizDetails: [AgendaDetail] = []
                    var examDetails: [AgendaDetail] = []
                    var homeWorkDetails: [AgendaDetail] = []
                    var classWorkDetails: [AgendaDetail] = []
                    var homeworkPercentage = 0.0
                    var classworkPercantage = 0.0
                    var quizPercentage = 0.0
                    var examPercentage = 0.0
                    
                    let message = json["message"].stringValue
                    var status = 0
                    if(message.contains("assignments grouped by subject for student") || message.contains("assignments found")){
                        status = 200
                    }
                    let data = json["data"]
                    if status == 200{
                        let agendaData = json["response"]
                        
                        for agenda in agendaData{
                            let assignments = agenda.1["assignments"]
                            for object in assignments{
        
                            let subject_name = agenda.1["name"].stringValue
                            let title = object.1["title"].stringValue
                            let teacher = object.1["createdBy"].stringValue
                            let allow_update = false
                                let sss = object.1["assignedStudents"]
                                
                                var studentId = ""
                                var ticked = false
                                for std in sss{
                                    studentId = std.1["id"].stringValue
                                    let isTicked = std.1["status"].stringValue
                                    if(isTicked.lowercased() != "not started"){
                                        ticked = true
                                    }
                                    
                                }
                            let students = studentId
                            let workLoad = object.1["work_load"].doubleValue
                            let id = object.1["id"].intValue
                            let dateData = object.1["dueDate"].stringValue
                            var asst_type = object.1["assignmentType"].stringValue
                            let description = object.1["content"].stringValue

                            let enable_submissions = object.1["enableOnlineSubmission"].boolValue
                            let enable_late_submissions = object.1["enableLateSubmission"].boolValue
                            let enable_grading = object.1["enableGrading"].boolValue
                            let enable_discussions = object.1["enableDiscussion"].boolValue
                            let estimatedTime = object.1["estimatedTime"].intValue
                                
                            let attachments = object.1["attachments"]
                            var attachment_link = ""
                            if(attachments.count > 0){
                                for att in attachments{
                                    attachment_link = att.1["url"].stringValue

                                }
                            }
                            
                            let tempData = self.tFormatter.date(from: dateData)
                            print("tempData: \(tempData)")
                            let date = self.dateFormatter1.string(from: tempData ?? Date())
                            print("date: \(date)")


                            
                            var type = 1
                            if(asst_type == "homework"){
                                type = 1
                            }
                            else if(asst_type == "classwork"){
                                type = 2
                            }
                            else if(asst_type == "exam"){
                                type = 4
                            }
                            else if(asst_type == "assessment"){
                                type = 3
                            }
                            else{
                                type = 1
                            }
                            switch type{
                                //Assessment:
                            case 3:
                                let full_mark = object.1["fullMark"].stringValue
                                let sub_term = object.1["sub_term"].stringValue
                                let assessment_type = object.1["assessment_type"].stringValue
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.quizColor, topColor: agendaTheme.quizColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: "", endDate: "", duration: "", link_to_join: "", enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                quizDetails.append(detail)
                                quizPercentage = quizPercentage + workLoad
                                //Exam:
                            case 4:
                                let full_mark = object.1["fullMark"].stringValue
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.examColor, topColor: agendaTheme.examColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: "", endDate: "", duration: "", link_to_join: "", enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                examDetails.append(detail)
                                examPercentage = examPercentage + workLoad
                                
                                //online_exam:
                            case 5:
                                let full_mark = object.1["fullMark"].stringValue
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let startDate = object.1["start_date"].stringValue
                                let endDate = object.1["end_date"].stringValue
                                let duration = object.1["duration"].stringValue
                                let link_to_join = object.1["link_to_join"].stringValue
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.examColor, topColor: agendaTheme.examColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: startDate, endDate: endDate, duration: duration, link_to_join: link_to_join, enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                examDetails.append(detail)
                                examPercentage = examPercentage + workLoad
                                
                                //meetings
                            case 6:
                                let full_mark = object.1["fullMark"].stringValue
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let startDate = object.1["start_date"].stringValue
                                let endDate = object.1["end_date"].stringValue
                                let duration = object.1["duration"].stringValue
                                let link_to_join = object.1["link_to_join"].stringValue
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.examColor, topColor: agendaTheme.examColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: startDate, endDate: endDate, duration: duration, link_to_join: link_to_join, enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                examDetails.append(detail)
                                examPercentage = examPercentage + workLoad
                                
                                //HomeWork:
                            case 1:
                                let full_mark = object.1["fullMark"].stringValue
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.homeworkColor, topColor: agendaTheme.homeworkColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: "", endDate: "", duration: "", link_to_join: "", enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                homeWorkDetails.append(detail)
                                homeworkPercentage = homeworkPercentage + workLoad
                                //ClassWork:
                            case 2:
                                let full_mark = object.1["fullMark"].stringValue
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.classworkColor, topColor: agendaTheme.classworkColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: "", endDate: "", duration: "", link_to_join: "", enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                classWorkDetails.append(detail)
                                classworkPercantage = classworkPercantage + workLoad
                            default:
                                break
                            }
                        }
                    }
                        let quizEvent = Event(id: 1, icon: agendaTheme.quizIcon, color: agendaTheme.quizColor, counter: quizDetails.count, type: self.agendaType.Assessment.rawValue, date: "", percentage: quizPercentage, detail: [], agendaDetail: quizDetails)
                        let examEvent = Event(id: 2, icon: agendaTheme.examIcon, color: agendaTheme.examColor, counter: examDetails.count, type: self.agendaType.Exam.rawValue, date: "", percentage: examPercentage, detail: [], agendaDetail: examDetails)
                        let homeWorkEvent = Event(id: 3, icon: agendaTheme.homeworkIcon, color: agendaTheme.homeworkColor, counter: homeWorkDetails.count, type: self.agendaType.Homework.rawValue, date: "", percentage: homeworkPercentage, detail: [], agendaDetail: homeWorkDetails)
                        let classWorkEvent = Event(id: 4, icon: agendaTheme.classworkIcon, color: agendaTheme.classworkColor, counter: classWorkDetails.count, type: self.agendaType.Classwork.rawValue, date: "", percentage: classworkPercantage, detail: [], agendaDetail: classWorkDetails)
                        
                        agendaArray.append(quizEvent)
                        agendaArray.append(examEvent)
                        agendaArray.append(homeWorkEvent)
                        agendaArray.append(classWorkEvent)
                      
                        
                        completion(message,agendaArray,status)
                            
                    }else{
                        let errorMessage = data["error_msgs"].stringValue
                        self.reportError(message: errorMessage)
                        completion(errorMessage,[],status)
                    }
                    
                case .failure(let error):
                    
                    let agendaWorkload = AgendaWorkload.init(homeworkLoad: 0, classworkLoad: 0, quizLoad: 0, examLoad: 0)
                    
                    let schoolData = SchoolActivation(id: 0, logo: "", schoolURL: "", schoolId: "", name: "", website: "", location: "", lat: 0.0, long: 0.0, facebook: "", twitter: "", linkedIn: "", google: "", instagram: "", phone: "", code: "")
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
    }
    
    //Get Student Remarks Data:
    func getRemarks(user: User, studentUsername: String, startDate: String, endDate: String, remarkTheme: RemarkTheme, completion: @escaping(_ message: String?, _ result: [Remark]?, _ status: Int?)->Void){
        let remarksURL = "\(baseURL!)/api/remarks/get_student_remarks"
        
        let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)",
            "student_username": "\(studentUsername)",
            "start_date": "\(startDate)",
            "end_date": "\(endDate)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: remarksURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("==>getRemarks", json)
                        #endif
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                    
                        if status == 200 {
                            var remarksData: [Remark] = []
                            var goodDetail: [RemarkDetail] = []
                            var badDetail: [RemarkDetail] = []
                            
                            
                            let remarkArray = data["remarks"]
                            
                            for remark in remarkArray{
                                let dateData = remark.1["date"].stringValue
                                let date = self.dateFormatter1.string(from: self.formatter.date(from: dateData)!)
                                let subject = remark.1["remark_subject"].stringValue
                                let body = remark.1["remark_body"].stringValue
                                let category = remark.1["remark_category"].stringValue
                                let id = remark.1["id"].intValue
                                let positive = remark.1["is_positive"].boolValue
                                let tutor = remark.1["remarked_by"].stringValue
                                let ticked = remark.1["is_ticked"].boolValue
                                
                                if positive{
                                    let detail = RemarkDetail(id: id, title: category, date: date, image: "good-face", description: body, tutorName: tutor, studentName: "", subject: subject, ticked: ticked, backgroundColor: remarkTheme.happyColor, iconColor: remarkTheme.happyColor)
                                    goodDetail.append(detail)
                                }else{
                                    let detail = RemarkDetail(id: id, title: category, date: date, image: "bad-face", description: body, tutorName: tutor, studentName: "", subject: subject, ticked: ticked, backgroundColor: remarkTheme.sadColor, iconColor: remarkTheme.sadColor)
                                    badDetail.append(detail)
                                }
                            }
                            
                            let goodRemarks = Remark(id: 1, icon: "good-face", color: remarkTheme.happyColor, counter: "\(goodDetail.count)", Title: "good", remarkDetail: goodDetail)
                            let badRemarks = Remark(id: 2, icon: "bad-face", color: remarkTheme.sadColor, counter: "\(badDetail.count)", Title: "bad", remarkDetail: badDetail)
                            remarksData.append(goodRemarks)
                            remarksData.append(badRemarks)
                            
                            completion(message,remarksData,status)
                        }
                        else {
                            // Failed server response
                            let description = data["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,[],status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    //Get Teacher Remarks Data:
    func viewSectionRemark(user: User, startDate: String, endDate: String, className: String, batchId: Int, completion: @escaping(_ message: String?, _ result: [Remark]?, _ status: Int?)->Void){
        let url = App.getSchoolActivation(schoolID: user.schoolId)?.schoolURL
        let remarksURL = "\(url ?? baseURL!)/api/remarks/view_section_remarks"

        let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)",
            "section_id": "\(batchId)",
            "start_date": "\(startDate)",
            "end_date": "\(endDate)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: remarksURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        
                        print("==>view section remarks: \(data)")

                        if status == 200 {
                            var remarksData: [Remark] = []
                            var goodDetail: [RemarkDetail] = []
                            var badDetail: [RemarkDetail] = []


                            let remarkArray = data["remarks"]

                            for remark in remarkArray{
                                let student = remark.1["student"].stringValue
                                let subject = remark.1["subject"].stringValue
                                let body = remark.1["text"].stringValue
                                let id = remark.1["id"].intValue
                                let tutor = remark.1["remarked_by"].stringValue
                                let dateData = remark.1["remark_date"].stringValue
                                let date = self.dateFormatter1.string(from: self.formatter.date(from: dateData)!)
                                let positive = remark.1["positive"].boolValue

                                if positive{
                                    let detail = RemarkDetail(id: id, title: subject, date: date, image: "good-face", description: body, tutorName: tutor, studentName: student, subject: className, ticked: false, backgroundColor: "#c6aeff", iconColor: "#a171ff")
                                    goodDetail.append(detail)
                                }else{
                                    let detail = RemarkDetail(id: id, title: subject, date: date, image: "bad-face", description: body, tutorName: tutor, studentName: student, subject: className, ticked: false, backgroundColor: "#ff908d", iconColor: "#ee4037")
                                    badDetail.append(detail)
                                }
                            }

                            let goodRemarks = Remark(id: 1, icon: "good-face", color: "#a171ff", counter: "\(goodDetail.count)", Title: "good", remarkDetail: goodDetail)
                            let badRemarks = Remark(id: 2, icon: "bad-face", color: "#ee4037", counter: "\(badDetail.count)", Title: "bad", remarkDetail: badDetail)
                            remarksData.append(goodRemarks)
                            remarksData.append(badRemarks)

                            completion(message,remarksData,status)
                        }
                        else {
                            // Failed server response
                            let description = data["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,[],status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })

    }
    
    //Accept or student assignment submission
    func acceptOrDeclineStudentAssignmentSubmission(check: Int, id: String, completion: @escaping(_ message: String?, _ result: String?, _ status: Int?)->Void){
        let acceptOrDeclineStudentAssignmentSubmissionURL = "\(baseURL!)/api/agenda/accept_reject_answer"
        
        let params = [
            "id": id,
            "check": "\(check)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: acceptOrDeclineStudentAssignmentSubmissionURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        let dataMessage = data["message"].stringValue
                        if status == 200 {
                            
                            completion(message,dataMessage,status)
                        }
                        else {
                            // Failed server response
                            let error = JSON(j)
                            let statusCode = response.response?.statusCode
                            let description = error["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,"",statusCode)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    
    
    
    //Check Agenda Data:
    func checkAgenda(user: User, assignedStudentId: String, actualTime: String, completion: @escaping(_ message: String?, _ result: String?, _ status: Int?)->Void){
        let checkAgendaURL = "\(AGENDA_ASSIGNMENTS_URL)/addstudentassignmenttime?assignedStudentId=\(assignedStudentId)&actual_time=\(actualTime)"
        
        let params = ["" : ""]
 
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: checkAgendaURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        let message = json["message"].stringValue
                        let status = 200
                        let data = json["response"].stringValue
                        if status == 200 {
                            
                            completion(message,data,status)
                        }
                        else {
                            // Failed server response
                            let error = JSON(j)
                            let statusCode = response.response?.statusCode
                            let description = error["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,"",statusCode)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    //UnCheck Agenda Data:
    func unCheckAgenda(user: User, studentUsername: String, type: String, id: Int, completion: @escaping(_ message: String?, _ result: String?, _ status: Int?)->Void){
        let checkAgendaURL = "\(baseURL!)/api/agenda/uncheck_assignment"
        
        var eventType = 0
        switch type {
        case "Quiz":
            eventType = 3
        case "Exams":
            eventType = 4
        case "Homework":
            eventType = 1
        default:
            eventType = 2
        }
        
        let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)",
            "student_username": "\(studentUsername)",
            "type": "\(eventType)",
            "id": "\(id)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: checkAgendaURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                            let json = JSON(j)
                            let message = json["statusMessage"].stringValue
                            let status = json["statusCode"].intValue
                            let data = json["data"]
                            let dataMessage = data["message"].stringValue
                            if status == 200 {
                            completion(message,dataMessage,status)
                            } else {
                            // Failed server response
                            let error = JSON(j)
                            let statusCode = response.response?.statusCode
                            let description = error["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,"",statusCode)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    
    //Check Remark Data:
    func checkRemark(user: User, studentUsername: String, id: Int, completion: @escaping(_ message: String?, _ result: String?, _ status: Int?)->Void){
        let checkRemarkURL = "\(baseURL!)/api/remarks/check_remark"
        
        let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)",
            "student_username": "\(studentUsername)",
            "id": "\(id)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: checkRemarkURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        let dataMessage = data["message"].stringValue
                        if status == 200 {
                            completion(message,dataMessage,status)
                        } else {
                            // Failed server response
                            let error = JSON(j)
                            let statusCode = response.response?.statusCode
                            let description = error["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,"",statusCode)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    
    //UnCheck Remark Data:
    func UnCheckRemark(user: User, studentUsername: String, id: Int, completion: @escaping(_ message: String?, _ result: String?, _ status: Int?)->Void){
        let checkRemarkURL = "\(baseURL!)/api/remarks/uncheck_remark"
        
        let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)",
            "student_username": "\(studentUsername)",
            "id": "\(id)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: checkRemarkURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        let dataMessage = data["message"].stringValue
                        
                        if status == 200 {
                            completion(message,dataMessage,status)
                        }else {
                            // Failed server response
                            let error = JSON(j)
                            let statusCode = response.response?.statusCode
                            let description = error["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,"",statusCode)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    
    //Sections and Departments Data:
    func getSectionDepartment(user: User, completion: @escaping(_ message: String?, _ sectionResult: [CalendarEventItem]?, _ departmentResult: [CalendarEventItem]?, _ status: Int?)->Void){
        let getSectionsURL = "\(baseURL!)/api/calendar/get_sections_and_departments"
        
        let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: getSectionsURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                            var sectionsArray: [CalendarEventItem] = []
                            var departmentArray: [CalendarEventItem] = []
                            
                            let json = JSON(j)
                            let message = json["statusMessage"].stringValue
                            let status = json["statusCode"].intValue
                            let data = json["data"]
                            if status == 200 {
                                let sections = data["sections"]
                                for object in sections{
                                    let id = object.1["id"].stringValue
                                    let name = object.1["name"].stringValue
                                    let section = CalendarEventItem(id: id, title: name, active: false, studentId: "")
                                    sectionsArray.append(section)
                                }
                                
                                let departments = data["departments"]
                                for object in departments{
                                    let id = object.1["id"].stringValue
                                    let name = object.1["name"].stringValue
                                    let department = CalendarEventItem(id: id, title: name, active: false, studentId: "")
                                    departmentArray.append(department)
                                }
                                
                                completion(message,sectionsArray,departmentArray,status)
                            }
                        else {
                            // Failed server response
                            let error = JSON(j)
                            let statusCode = response.response?.statusCode
                            let description = error["error_msgs"].stringValue
                            self.reportError(message: description)
                            completion(description,[],[],statusCode)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    func replaceEmptyStringsWithNull(in dictionary: [String: Any]) -> [String: Any] {
        var updatedDictionary = dictionary

        for (key, value) in dictionary {
            print("key: \(key)")
            print("value: \(value)")

            if let stringValue = value as? String, stringValue.isEmpty {
                updatedDictionary[key] = NSNull()
            } else if let nestedDictionary = value as? [String: Any] {
                updatedDictionary[key] = replaceEmptyStringsWithNull(in: nestedDictionary)
            }
        }

        return updatedDictionary
    }
    //Create Occasion:
    func createOccasion(user: User, profile: UIImage?, occasion: Occasion, filename: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createOccasionURL = "\(CALENDAR_EVENTS_URL)/create_event"
        print("occasion occasion: \(occasion)")
        print("occasion occasion1: \(filename)")

        let departments = occasion.departments.map { Int($0) ?? 0 }
        let sections = occasion.batches.map { Int($0) ?? 0 }
        let users = departments + sections
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let date = dateFormatter.date(from: occasion.startDate)
        let eDate = dateFormatter.date(from: occasion.endDate)

        print("date date: \(date)")
        print("date date1: \(eDate)")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = formatter.string(from: date ?? Date())
        
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "HH:mm"
        let start_date = startDateFormatter.string(from: date ?? Date())
        
        let end_date = startDateFormatter.string(from: eDate ?? Date())
        
        var event = "event"
        
        if(occasion.holiday){
            event = "holiday"
        }
        if(occasion.meeting){
            event = "meeting"
        }
        

        
        let params = [
            "payload": """
               {
                   "start_time": "\(start_date)",
                   "thumbnail_attachment": "",
                   "tagged_users": \(users),
                   "event_date": "\(formattedDate)",
                   "tagAllUsers": \(occasion.common),
                   "school_id": \(user.schoolId),
                   "description": "\(occasion.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
                   "current_user_id": \(user.userId),
                   "title": "\(occasion.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
                   "end_time": "\(end_date)",
                   "event_type": "\(event)"
               }
               """
        ]
        
        let updatedParams = replaceEmptyStringsWithNull(in: params)
        print("updated params: \(updatedParams)")
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }


            if profile?.size != CGSize(width: 0.0, height: 0.0){
                if let profile = profile {
                    multipartFormData.append(profile.jpeg(.lowest)!, withName: "file", fileName: filename, mimeType: "image/jpeg")
                }
            }

        }, to: createOccasionURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        var status = 0
                        if message == "success" {
                            let data = json["data"]
                            status = 200
                            completion(message,data,status)
                        }
                        else {
                        // Failed server response
                            let error = JSON(j)

                            self.reportError(message: message)
                            completion(message,error,status)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):

                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Update Occasion:
    
    func updateOccasion(user: User, profile: UIImage?, occasion: Occasion, filename: String,  completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createOccasionURL = "\(CALENDAR_EVENTS_URL)/update_event"

        print("occasion occasion11: \(occasion)")
        let departments = occasion.departments.map { Int($0) ?? 0 }
        let sections = occasion.batches.map { Int($0) ?? 0 }
        let users = departments + sections
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: occasion.startDate)
        let eDate = dateFormatter.date(from: occasion.endDate)

        print("date date: \(date)")
        print("date date1: \(eDate)")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = formatter.string(from: date ?? Date())
        
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "HH:mm"
        let start_date = startDateFormatter.string(from: date ?? Date())
        
        let end_date = startDateFormatter.string(from: eDate ?? Date())
        
        var event = "event"
        
        if(occasion.holiday){
            event = "holiday"
        }
        if(occasion.meeting){
            event = "meeting"
        }

        
        let params = [
            "payload": """
               {
                   "start_time": "\(start_date)",
                   "tagAllStudents": "",
                   "tagAllParents": "",
                   "thumbnail_attachment": "",
                   "tagAllEmployees": "",
                   "tagged_users": \(users),
                   "event_id": "\(occasion.id ?? 0)",
                   "event_date": "\(formattedDate)",
                   "editTaggedUsers": "\(true)",
                   "tagAllUsers": \(occasion.common),
                   "school_id": \(user.schoolId),
                   "description": "\(occasion.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
                   "current_user_id": \(user.userId),
                   "title": "\(occasion.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
                   "end_time": "\(end_date)",
                   "event_type": "\(event)"
               }
               """
        ]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }


            if profile?.size != CGSize(width: 0.0, height: 0.0){
                if let profile = profile {
                    multipartFormData.append(profile.jpeg(.lowest)!, withName: "file", fileName: filename, mimeType: "image/jpeg")
                }
            }

        }, to: createOccasionURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        var status = 0
                        if message.contains("updated")  {
                            let data = json["data"]
                            status = 200
                            completion(message,data,status)
                        }
                        else {
                        // Failed server response
                            let error = JSON(j)
                         
                            self.reportError(message: message)
                            completion(message,error,status)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):

                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
//    func updateOccasion(user: User, profile: UIImage?, occasion: Occasion, filename: String,  completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
//        let createOccasionURL = "\(baseURL!)/api/calendar/update_occasion"
//
//        var sections = ""
//        var departments = ""
//        let id = occasion.id
//
//        for (index, dep) in occasion.departments.enumerated(){
//            if departments.count > 1{
//                if index == 0{
//                    departments = "\(dep)"
//                }else{
//                    departments = "\(departments),\(dep)"
//                }
//            }else{
//                departments = dep
//            }
//        }
//
//        for (index, sec) in occasion.batches.enumerated(){
//            if sections.count > 1{
//                if index == 0{
//                    sections = "\(sec)"
//                }else{
//                    sections = "\(sections),\(sec)"
//                }
//            }else{
//                sections = sec
//            }
//        }
//
//        let params = [
//            "token": "\(user.token)",
//            "username": "\(user.userName)",
//            "occasion": "\(id!)",
//            "title": "\(occasion.title)",
//            "description": "\(occasion.description)",
//            "start_date": "\(occasion.startDate)",
//            "end_date": "\(occasion.endDate)",
//            "is_holiday": "\(occasion.holiday)",
//            "is_common": "\(occasion.common)",
//            "sections": "\(sections)",
//            "departments": "\(departments)"
//        ]
//
//
//        #if DEBUG
//            print("updateOccasion params",params)
//        #endif
//
//        self.manager.upload(multipartFormData: {
//            multipartFormData in
//            for (key, value) in params{
//                multipartFormData.append(value.data(using: .utf8)!, withName: key)
//            }
//
//            if profile?.size != CGSize(width: 0.0, height: 0.0){
//                if let profile = profile {
//                    multipartFormData.append(profile.jpeg(.lowest)!, withName: "photo", fileName: filename, mimeType: "image/jpeg")
//                }
//            }
//
//        }, to: createOccasionURL, encodingCompletion: {
//            (result) in
//            switch result {
//            case .success(let upload, _, _):
//                upload.responseJSON {
//                    response in
//                    switch response.result {
//                    case .success(let j):
//
//                        let json = JSON(j)
//                        let message = json["statusMessage"].stringValue
//                        let status = json["statusCode"].intValue
//                        if status == 200 {
//                            let data = json["data"]
//                            completion(message,data,status)
//                        }
//                        else {
//                            // Failed server response
//                            let error = JSON(j)
//                            let statusCode = error["statusCode"].intValue
//                            let data = error["data"]
//                            let errorMessage = data["error_msgs"].stringValue
//                            self.reportError(message: errorMessage)
//                            completion(errorMessage,error,statusCode)
//                        }
//                    case .failure(let error):
//
//                        if error._code == NSURLErrorTimedOut {
//                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
//                        }
//                        else if error._code == NSFileNoSuchFileError {
//                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                        }
//                        else {
//                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                        }
//                    }
//                }
//            case .failure(let error):
//
//                if error._code == NSURLErrorTimedOut {
//                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
//                }
//                else if error._code == NSFileNoSuchFileError {
//                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                }
//                else {
//                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                }
//            }
//        })
//    }
    
    
    //Get Class Icons:
    func GetClassIcons(user: User, schoolID: String, classID: Int, code: String, gender: String, completion: @escaping(_ message: String?, _ data: AppTheme?, _ status: Int)->Void){

                    
                    
                        let homeIcon = "home_icon.png"
                        let messageIcon = "message_icon.png"
                        let notificationIcon = "notification_icon.png"
                        let settingIcon = "settings_icon.png"
                        let helpIcon = "question_icon.png"
                    
                    
        let mainPageTheme = MainPageTheme(schoolId: Int(schoolID) ?? 0, classID: classID, home: "", message: "", notification: "", settings: "", help: "")
                    
                    let calendarIcon = "calendar"
                    let calendarBg = "#7cedab"
                    
                    let attendanceIcon = "attendance"
                    let attendanceBg = "#fbb870"
                    
                    let agendaIcon = "agenda-home"
                    let agendaBg = "#e39cf4"
                    
                    let gradeIcon = "grades"
                    let gradeBg = "#f69c9c"
                    
                    let remarkIcon = "remarks-home"
                    let remarkBg = "#a171ff"
                    
                    let gclassIcon = "gclassIcon"
                    let gclassBg = "#7775b2"
                    
                    let timeTableIcon = "timeTableDefault"
                    let timeTableBg = "#79cbf7"
                    
                    let galleryIcon = "galleryIcon"
                    let galleryBg = "#ADABAB"
                    
                    let feesIcon = "feesIcon"
                    let feesBg = "#f9ad20"
                    
                    let teamsIcon = "teamsIcon"
                    let teamsBg = "#acb3db"
                    
                    let virtualIcon = "virtualIcon"
                    let virtualBg = "#dd6b67"
                    
                    let blendedIcon = "blended_learning"
                    let blendedBg = "#ba9ecb"
                    
                    let assessmentIcon = "assessment_photo"
                    let assessmentBg = "#FF5B55"
                    
                    let homePage = HomePage(calendarIcon: calendarIcon, calendarBg: calendarBg, attendanceIcon: attendanceIcon, attendanceBg: attendanceBg, agendaIcon: agendaIcon, agendaBg: agendaBg, gradeIcon: gradeIcon, gradeBg: gradeBg, remarkIcon: remarkIcon, remarkBg: remarkBg, gclassIcon: gclassIcon, gclassBg: gclassBg, timeTableIcon: timeTableIcon, timeTableBg: timeTableBg, galleryIcon: galleryIcon, galleryBg: galleryBg, feesIcon: feesIcon, feesBg: feesBg, teamsIcon: teamsIcon, teamsBg: teamsBg, virtualIcon: virtualIcon, virtualBg: virtualBg, blendedIcon: blendedIcon, blendedBg: blendedBg, assessmentIcon: assessmentIcon, assessmentBg: assessmentBg)
                    
                                        
                 
                    let eventBackground = "#00a79d"
                  
                    let holidayBackground = "#48c2f4"
                    
                    let dueBackground = "#fa487a"
                    
                    let  eventIcon = "calendar-events"
                   
                    let holidayIcon = "calendar-holiday"
                   
                    let dueIcon = "calendar-due"
                    
                    let defaultEventImage = "event-default"

                    let defaultHolidayIcon = "holiday-default"

                    
                    

                    let calendarPageTheme = CalendarTheme(eventBg: eventBackground, holidayBg: holidayBackground, dueBg: dueBackground, eventIcon: "\(eventIcon)", holidayIcon: "\(holidayIcon)", dueIcon: "\(dueIcon)", defaultEventIcon: "\(defaultEventImage)", defaultHolidayIcon: defaultHolidayIcon, notificationCount: 0)
                    
                    //calendar
                    let calendarModuleObject = Module(id: 2, name: "Calendar", status: 1, link: "")
                    let agendaModuleObject = Module(id: 3, name: "Agenda", status: 1, link: "")
                    let attendanceModuleObject = Module(id: 8, name: "Attendance", status: 1, link: "")
                    let timeTableModuleObject = Module(id: 10, name: "TimeTable", status: 1, link: "")
                    
                   
                    
//                    if(user.userType == 1 || user.userType == 2){
//                        gradesModuleObject.status = 0
//                    }
       

                    var modulesArray: [Module] = []

                    modulesArray.append(calendarModuleObject)
                    modulesArray.append(agendaModuleObject)
                    modulesArray.append(attendanceModuleObject)
                    modulesArray.append(timeTableModuleObject)
        
                    if(user.userType == 3 || user.userType == 4){
                        var gradesModuleObject = Module(id: 5, name: "Grades", status: 1, link: "")
                        modulesArray.append(gradesModuleObject)

                    }

                
//                    if(user.userType == 1 || user.userType == 2 || user.userType == 3){
//                        var blendedLearningModuleObject = Module(id: 15, name: "Blended Learning", status: 1, link: "")
//                        modulesArray.append(blendedLearningModuleObject)
//                    }
                    
                  
                        let presenceColor = "#014e80"

                   
                        let lateColor = "#ffcb39"
                   
                        let absenceColor = "#ff5955"
                    
                    let attendanceTheme = AttendanceTheme(presenceColor: presenceColor, absenceColor: absenceColor, lateColor: lateColor, notificationCount: 0)
                    
                
                        let examColor = "#a171ff"
                    
                    let examIcon = "exam-events"
//                    if examIcon.isEmpty{
//                        examIcon = "exam-events"
//                    }else{
//                        examIcon = "\(imageURL)\(examIcon)"
//                    }
                  
                    let homeworkColor = "#fa487a"
                    let homeworkIcon = "homeWork-events"
//                    if homeworkIcon.isEmpty{
//                        homeworkIcon = "homeWork-events"
//                    }else{
//                        homeworkIcon = "\(imageURL)\(homeworkIcon)"
//                    }
                
                    let classWorkColor = "#00a053"

                    let classWorkIcon = "classWork-events"
//                    if classWorkIcon.isEmpty{
//                        classWorkIcon = "classWork-events"
//                    }else{
//                        classWorkIcon = "\(imageURL)\(classWorkIcon)"
//                    }
                  
                    let quizColor = "#faae21"
                    let quizIcon = "quiz-events"
//                    if quizIcon.isEmpty{
//                        quizIcon = "quiz-events"
//                    }else{
//                        quizIcon = "\(imageURL)\(quizIcon)"
//                    }
                    
                    let agendaTheme = AgendaTheme(examColor: examColor, examIcon: examIcon, homeworkColor: homeworkColor, homeworkIcon: homeworkIcon, classworkColor: classWorkColor, classworkIcon: classWorkIcon, quizColor: quizColor, quizIcon: quizIcon, notificationCount: 0)
                    
                    var subjectTheme: [SubjectTheme] = []
                    
                    let chemistryBg = "#fa487a"
                    let chemistryIcon = "chemistry"
                    let chemestryObject = SubjectTheme(code: "chemistry", bg: chemistryBg, icon: chemistryIcon)
                    subjectTheme.append(chemestryObject)
                    
                    let artBg = "#fa487a"
                    let artIcon = "art"
                    let artObject = SubjectTheme(code: "arts", bg: artBg, icon: artIcon)
                    subjectTheme.append(artObject)
                    
                    let computerBg = "#fa487a"
                    let computerIcon = "computer"
                    let computerObject = SubjectTheme(code: "computer", bg: computerBg, icon: computerIcon)
                    subjectTheme.append(computerObject)
                    
                    let englishBg = "#fa487a"
                    let englishIcon = "english"
                    let englishObject = SubjectTheme(code: "english", bg: englishBg, icon: englishIcon)
                    subjectTheme.append(englishObject)
                    
                    let arabicBg = "#fa487a"
                    let arabicIcon = "arabic"
                    let arabicObject = SubjectTheme(code: "arabic", bg: arabicBg, icon: arabicIcon)
                    subjectTheme.append(arabicObject)
                    
                    let physicsBg = "#fa487a"
                    let physicsIcon = "physics"
                    let physicsObject = SubjectTheme(code: "physics", bg: physicsBg, icon: physicsIcon)
                    subjectTheme.append(physicsObject)
                    
                    let mathBg = "#fa487a"
                    let mathIcon = "maths"
                    let mathObject = SubjectTheme(code: "maths", bg: mathBg, icon: mathIcon)
                    subjectTheme.append(mathObject)
                    
                    let frenchBg = "#fa487a"
                    let frenchIcon = "french"
                    let frenchObject = SubjectTheme(code: "french", bg: frenchBg, icon: frenchIcon)
                    subjectTheme.append(frenchObject)
                    
                    let activitiesBg = "#fa487a"
                    let activitiesIcon = "activities"
                    let activitiesObject = SubjectTheme(code: "activities", bg: activitiesBg, icon: activitiesIcon)
                    subjectTheme.append(activitiesObject)
                    
                    let biologyBg = "#fa487a"
                    let biologyIcon = "biology"
                    let biologyObject = SubjectTheme(code: "biology", bg: biologyBg, icon: biologyIcon)
                    subjectTheme.append(biologyObject)
                    
                    let cineBg = "#fa487a"
                    let cineIcon = "cine"
                    let cineObject = SubjectTheme(code: "cine", bg: cineBg, icon: cineIcon)
                    subjectTheme.append(cineObject)
                    
                    let civicsBg = "#fa487a"
                    let civicsIcon = "civics"
                    let civicsObject = SubjectTheme(code: "civics", bg: civicsBg, icon: civicsIcon)
                    subjectTheme.append(civicsObject)
                    
                    let danceBg = "#fa487a"
                    let danceIcon = "dance"
                    let danceObject = SubjectTheme(code: "dance", bg: danceBg, icon: danceIcon)
                    subjectTheme.append(danceObject)
                    
                    let economicBg = "#fa487a"
                    let economicIcon = "economics"
                    let economicsObject = SubjectTheme(code: "economics", bg: economicBg, icon: economicIcon)
                    subjectTheme.append(economicsObject)
                    
                    let religieusBg = "#fa487a"
                    let religieusIcon = "religieuse"
                    let religieusObject = SubjectTheme(code: "religieus", bg: religieusBg, icon: religieusIcon)
                    subjectTheme.append(religieusObject)
                    
                    let sportiveBg = "#fa487a"
                    let sportiveIcon = "sport"
                    let sportiveObject = SubjectTheme(code: "sportive", bg: sportiveBg, icon: sportiveIcon)
                    subjectTheme.append(sportiveObject)
                    
                    let geographieBg = "#fa487a"
                    let geographieIcon = "geographie"
                    let geographieObject = SubjectTheme(code: "geographie", bg: geographieBg, icon: geographieIcon)
                    subjectTheme.append(geographieObject)
                    
                    let historyBg = "#fa487a"
                    let historyIcon = "history"
                    let historyObject = SubjectTheme(code: "history", bg: historyBg, icon: historyIcon)
                    subjectTheme.append(historyObject)
                    
                    let musicBg = "#fa487a"
                    let musicIcon = "music"
                    let musicObject = SubjectTheme(code: "music", bg: musicBg, icon: musicIcon)
                    subjectTheme.append(musicObject)
                    
                    let philosophyBg = "#fa487a"
                    let philosophyIcon = "philosophy"
                    let philosophyObject = SubjectTheme(code: "philosophy", bg: philosophyBg, icon: philosophyIcon)
                    subjectTheme.append(philosophyObject)
                    
                    let sociologyBg = "#fa487a"
                    let sociologyIcon = "sociology"
                    let sociologyObject = SubjectTheme(code: "sociology", bg: sociologyBg, icon: sociologyIcon)
                    subjectTheme.append(sociologyObject)
                    
                    let scienceBg = "#fa487a"
                    let scienceIcon = "science"
                    let scienceObject = SubjectTheme(code: "science", bg: scienceBg, icon: scienceIcon)
                    subjectTheme.append(scienceObject)
                    
                    let socialbg = "#fa487a"
                    let socialIcon = "science"
                    let socialObject = SubjectTheme(code: "science", bg: socialbg, icon: socialIcon)
                    subjectTheme.append(socialObject)
                    
                    let languageBg = "#fa487a"
                    let languageIcon = "language"
                    let languageObject = SubjectTheme(code: "language", bg: languageBg, icon: languageIcon)
                    subjectTheme.append(languageObject)
 
                    let happyColor = "#a171ff"
                    let sadColor = "#ee4037"
                    
                    let remarkTheme = RemarkTheme.init(happyColor: happyColor, sadColor: sadColor, notificationCount: 0)
                    
                    var genderIcon = "avatar"
                    if(user.userType == 2){
                        if(user.gender.lowercased() == "m"){
                            genderIcon = "teacher_boy"

                        }
                        else{
                            genderIcon = "teacher_girl"


                        }
                    }
                    else{
                        if(user.gender.lowercased() == "m"){
                            genderIcon = "student_boy"

                        }
                        else{
                            genderIcon = "student_girl"


                        }
                    }
                    
                  
                        let e1 = "#00a79d"
                        let e2 = "#48c2f4"
                        let e3 = "#fa487a"
                        let e4 = "#66ff5a"
                        let e5 = "#f6bad4"
                    let e6 = "#faae21"
                    let all = "#faae21"
                    let veryGood = ""
                    let good = ""
                    let bad = ""
                    let veryBad = ""
                    
                    let gradeTheme = GradeTheme.init(subTerm_1: e1, subTerm_2: e2, subTerm_3: e3, subTerm_4: e4, subTerm_5: e5, subTerm_6: e6, allSubterms: all, veryGood: veryGood, good: good, bad: bad, veryBad: veryBad, notificationCount: 0)
                    
                    
                    let theme = AppTheme(mainPageTheme: mainPageTheme, calendarTheme: calendarPageTheme, homePage: homePage, activeModule: modulesArray, attendanceTheme: attendanceTheme, agendaTheme: agendaTheme, subjectTheme: subjectTheme, gradesTheme: gradeTheme, remarkTheme: remarkTheme, genderIcon: genderIcon, timeTableNotificationCount: 0)
                    
        print("app theme: \(theme)")
                    completion("",theme,200)
                    
    }
    
    
    
    //Get School URL:
    func GetSchoolURL(activationCode: String, completion: @escaping(_ message: String?, _ school: SchoolActivation, _ status: Int)->Void){
        let params: Parameters = [
            "schoolCode": activationCode
        ]

        print("schoolCode: \(activationCode)")
        
        self.manager.request("\(GET_SCHOOL_URL)/school_by_code?code=" + activationCode, method: .get, encoding: JSONEncoding.default)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    print("\(self.GET_SCHOOL_URL)/school_by_code?code=\(activationCode)")
                    print("school activation: \(json)")
                    let data = json["response"]
                    let status = 200
                    let message = json["message"].stringValue
                    print(data)
                    
                    let id = data["id"].intValue
                    let logo = data["logo"].stringValue
                    let url = data["schoolUrl"].stringValue
                    let schoolId = data["id"].stringValue
                    let name = data["englishName"].stringValue
                    let website = data["website"].stringValue
                    let location = data["address"].stringValue
                    let long = data["lng"].doubleValue
                    let lat = data["lat"].doubleValue
                    let facebook = data["facebook"].stringValue
                    let twitter = data["twitter"].stringValue
                    let linkedIn = data["linkedin"].stringValue
                    let google = data["mobile"].stringValue
                    let instagram = data["phone2"].stringValue
                    let phone = data["phone1"].stringValue
                    let code = data["code"].stringValue
                    
                    let schoolData = SchoolActivation(id: id, logo: logo, schoolURL: url, schoolId: schoolId, name: name, website: website, location: location, lat: lat, long: long, facebook: facebook, twitter: twitter, linkedIn: linkedIn, google: google, instagram: instagram, phone: phone, code: code)
                    completion(message,schoolData,status)
                    
                case .failure(let error):
                    
                    let schoolData = SchoolActivation(id: 0, logo: "", schoolURL: "", schoolId: "", name: "", website: "", location: "", lat: 0.0, long: 0.0, facebook: "", twitter: "", linkedIn: "", google: "", instagram: "", phone: "", code:"")
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,schoolData,App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,schoolData,App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,schoolData,App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
    }
    
    //Get Section Absence API:
    func getSectionAbsence(user: User, sectionId: Int, date: String, completion: @escaping(_ message: String?, _ result: [Attendance]?, _ status: Int?)->Void){
        let getSectionAbsenceURL = "\(baseURL!)/api/attendance/get_section_absences"
//        var params = ["":""]
        //        if user.privileges._tudentAttendanceViewPrivilege){
//            params = [
//                "username": "\(user.userName)",
//                "token": "\(user.token)",
//                "date": "\(date)",
//            ]
//        }else{
          let  params = [
                "username": "\(user.userName)",
                "token": "\(user.token)",
                "section_id": "\(sectionId)",
                "date": "\(date)",
            ]
//        }
    
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: getSectionAbsenceURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        var attendanceData: [Attendance] = []
                        
                        let data = JSON(j)
                        let message = data["statusMessage"].stringValue
                        let status = data["statusCode"].intValue
                        let dataArray = data["data"]
                        let attendanceArray = dataArray["attendance"]
                        
                        //Latency:
                        let latencyArray = attendanceArray["latency"]
                        let latPercentage = latencyArray["percentage"].doubleValue
                        let latencyPercentage = Double(round(100*latPercentage)/100)
                        let latencyAttendance = Attendance(type: "latency", color: "#ffcb39", percentage: latencyPercentage, dates: [], details: [])
                        attendanceData.append(latencyAttendance)
                        
                        //Absent:
                        let absentArray = attendanceArray["absent"]
                        let absPercentage = absentArray["percentage"].doubleValue
                        let absentPercentage = Double(round(100*absPercentage)/100)
                        let absentAttendance = Attendance(type: "absent", color: "#ff5955", percentage: absentPercentage, dates: [], details: [])
                        attendanceData.append(absentAttendance)
                        
                        //Present:
                        let presentArray = attendanceArray["present"]
                        let prePercentage = presentArray["percentage"].doubleValue
                        let presentPercentage = Double(round(100*prePercentage)/100)
                        let presentAttendance = Attendance(type: "present", color: "#014e80", percentage: presentPercentage, dates: [], details: [])
                        attendanceData.append(presentAttendance)
                        
                        completion(message,attendanceData,status)
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Add Absence API:
    func addAbsence(user: User, studentUsername: String, date: String, sectionId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let addAbsenceURL = "\(ATTENDANCE_URL)/markStudentAbsent"
        print("occasion occasion1: \(addAbsenceURL)")
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        let params = [
            "student_id": "\(studentUsername)",
            "section_id": "\(sectionId)",
            "school_id": "\(user.schoolId)",
            "absence_date": "\(date)",
            "is_full_day": "true",
            "start_time": "2023-09-08 08:00:00.000",
            "end_time": "2023-09-08 15:00:00.000",
            "duration": "7",
            "createdBy": "\(user.userId)"
        ]
        
        print("occasion occasion2: \(params)")

                
        self.manager.request(addAbsenceURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                .responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let data = JSON(j)
                        print("response: \(data)")
                        let message = data["message"].stringValue
                        let status = 200
                        let dataArray = data["response"]
                        if status == 200{
                            completion(message,dataArray,status)
                        }else{
                            
                            self.reportError(message: message)
                            completion(message,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
    }
    
    //Remove Absence API:
    func removeAbsence(user: User, studentUsername: String, date: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        
        let removeAbsenceURL = "\(ATTENDANCE_URL)/unMarkStudentAbsent"
        print("occasion occasion1: \(removeAbsenceURL)")
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        let params = [
                "student_id": "\(studentUsername)",
                "absence_date": "\(date)",
                "createdBy": "\(user.userId)"
        ]
        
                
        self.manager.request(removeAbsenceURL, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                .responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let data = JSON(j)
                        print("response: \(data)")

                        let message = data["message"].stringValue
                        let status = 200
                        let dataArray = data["response"]
                        if status == 200{
                            completion(message,dataArray,status)
                        }else{
                            let errorMessage = dataArray["error_msgs"].stringValue
                            self.reportError(message: message)
                            completion(message,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
    }
    
    
    //Get Section Attendance API:
    func getAttendanceList(user: User, sectionId: Int, date: String, completion: @escaping(_ message: String?, _ result: [TeacherAttendance]?, _ perc: [Attendance]?, _ status: Int?)->Void){
        let attendanceURL = "\(ATTENDANCE_URL)/getAllStudentAttendance?sectionId=\(sectionId)&schoolId=\(user.schoolId)"

        #if DEBUG
            print("==>getAttendance params11 ", attendanceURL)
        #endif
        print("date date: \(date)")
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        
        self.manager.request(attendanceURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                        var studentsArray: [TeacherAttendance] = []
                        let json = JSON(j)
                        #if DEBUG
                        print("getAttendanceList", json)
                        #endif
                        let message = json["message"].stringValue
                        let status = 200
                        let studentsData = json["response"]
                    
                        
                        if status == 200{
                            var latency = 0
                            for student in studentsData{
                                let name = "\(student.1["user"]["firstName"].stringValue) \(student.1["user"]["lastName"].stringValue)"
                                let photo = student.1["user"]["profilePictureUrl"].stringValue
                                let admissionNo = student.1["user"]["id"].stringValue
//                                let attendanceStatus = 1
//                                let latency = student.1["latence_mins"].stringValue
                                let gender = student.1["user"]["gender"].stringValue
                                let sectionId = student.1["section_id"].stringValue
                                
                                
                                var attendanceStatus = 1
                                let student_absences = student.1["student_absences"]
                                for absence in student_absences{
                                    let absenceDate = absence.1["absenceDate"].stringValue
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    
                                   
                                    
                                    if(absenceDate == date){
                                        let fullDay = absence.1["isFullDay"].boolValue
                                        if(fullDay == true){
                                            attendanceStatus = 2
                                        }
                                        else{
                                            attendanceStatus = 3
                                            let start_time = absence.1["startTime"].stringValue
                                            let end_time = absence.1["endTime"].stringValue
                                            
                                            let start = self.tFormatter.date(from: start_time)
                                            let end = self.tFormatter.date(from: end_time)
                                            let calendar = Calendar.current

                                            // Calculate the difference between the two dates
                                            let components = calendar.dateComponents([.minute], from: start ?? Date(), to: end ?? Date())
                                            
                                            print("start: \(start_time)")
                                            print("end: \(end_time)")
                                            
                                            print("start: \(start)")
                                            print("end: \(end)")

                                            if let minutesDifference = components.minute {
                                                print("The difference between the two dates is \(minutesDifference) minutes.")
                                                latency = latency + minutesDifference

                                            } else {
                                                print("Error calculating the difference between the two dates.")
                                            }
                                            
                                            
                                            
                                        }
                                    }
                                }
                                
                                
                                
                                
                                let studentObject = TeacherAttendance(admissionNo: admissionNo, name: name, image: photo, status: attendanceStatus, latencyTime: "\(latency)", gender: gender, sectionId: sectionId)
                                
                                print("studentObject: \(studentObject)")
                                studentsArray.append(studentObject)
                            }
                            
                            var presenceStudents = 0
                            var lateStudents = 0
                            var absentStudents = 0
                            
                            
                            
                            for student in studentsArray{
                                if(student.status == 1){
                                    presenceStudents += 1
                                }
                                else if(student.status == 2){
                                    absentStudents += 1
                                }
                                else{
                                    lateStudents += 1
                                }
                            }
                            
                            var attendanceData: [Attendance] = []

                            if(studentsArray.count > 0){
                                let presencePerc = Double(presenceStudents * 100) / Double(studentsArray.count)
                                let finalPresence = (presencePerc * 100).rounded() / 100
                                let presentAttendance = Attendance(type: "present", color: "#014e80", percentage: Double(finalPresence), dates: [], details: [])
                                
                                attendanceData.append(presentAttendance)
                                let absencePerc = Double(absentStudents * 100) / Double(studentsArray.count)
                                let finalAbsence = (absencePerc * 100).rounded() / 100
                                
                                let absentAttendance = Attendance(type: "absent", color: "#ff5955", percentage: Double(finalAbsence), dates: [], details: [])
                                attendanceData.append(absentAttendance)

                                
                                let latePerc = Double(lateStudents * 100) / Double(studentsArray.count)
                                let finalLate = (latePerc * 100).rounded() / 100
                                let latencyAttendance = Attendance(type: "latency", color: "#ffcb39", percentage: Double(finalLate), dates: [], details: [])
                                
                                attendanceData.append(latencyAttendance)

                                
                                
                                
                            }
                            
                            print(presenceStudents)
                            print(lateStudents)
                            print(absentStudents)
                            
                            completion(message,studentsArray,attendanceData, status)
                        }else{
                            
                            self.reportError(message: message)
                            completion(message,[],[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }

    }
    
    
    
    
    //Get Teacher Subject API:
    func getTeacherSubject(user: User, sectionId: Int, completion: @escaping(_ message: String?, _ result: [Subject]?, _ status: Int?)->Void){
        let getSubjectURL = "\(GET_TEACHERS_URL)/get_teacher_subjects/\(sectionId)/\(user.schoolId)"
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        print("get_teacher_subjects_users: \(user)")

        print("get_teacher_subjects: \(getSubjectURL)")
        
        self.manager.request(getSubjectURL, method: .get, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    var subjectArray: [Subject] = []
                    let json = JSON(j)
                    
                    #if DEBUG
                        print("teacher subjects params:")
                        print("==>getTeacherSubject", json)
                    #endif
                    
                    let message = json["message"].stringValue
                    var status = 0
                    if(message.contains("Successfully found")){
                        status = 200
                    }
                    if status == 200{
                        let subjectData = json["response"]
                        for subject in subjectData{
                            let name = subject.1["name"].stringValue
                            let sectionId = subject.1["section_id"].intValue
                            let code = subject.1["code"].stringValue
                            let id = subject.1["id"].intValue
                            let sectionName = subject.1["section_id"].stringValue
                            let imperiumCode = subject.1["imperium_code"].stringValue
                            
                            let employee_id = subject.1["employeeSubject"]["employeeId"].stringValue
                            
                            let foundSubject = subjectArray.first(where: { $0.id == id })

                            if((foundSubject) == nil){
                                if(user.userType == 1){
                                    let subjectObject = Subject(id: id, name: name, code: code, sectionId: sectionId, sectionName: sectionName, color: "#a171ff", imperiumCode: imperiumCode)
                                    subjectArray.append(subjectObject)
                                }
                                else{
                                    if(user.userType == 2){
                                        if(employee_id == user.imperiumCode){
                                            let subjectObject = Subject(id: id, name: name, code: code, sectionId: sectionId, sectionName: sectionName, color: "#a171ff", imperiumCode: imperiumCode)
                                            subjectArray.append(subjectObject)
                                        }
                                    }
                                }
                            }
                           
                           
                            
                        }
                        
                        completion(message,subjectArray,status)
                    }else{
                        self.reportError(message: message)
                        completion(message,[],status)
                    }
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            }
    }
    //Get Teacher Subject API:
        func getStudentSubject(user: User, sectionId: Int, completion: @escaping(_ message: String?, _ result: [Subject]?, _ status: Int?)->Void){
            let getSubjectURL = "\(baseURL!)/api/user/get_student_subjects"
            
            var params = ["":""]
            
            print("paramss1: \(user.userName)")
            print("paramss2: \(user.token)")
            print("paramss3: \(sectionId)")

            if(user.userType == 3){
                params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                    "section_id": "\(sectionId)",
                           ]
            }
            else if(user.userType == 4){
                params = [
                    "username": "\(user.admissionNo)",
                    "token": "\(user.token)",
                    "section_id": "\(sectionId)",
                ]
            }
            
            
            self.manager.upload(multipartFormData: {
                multipartFormData in
                for (key, value) in params{
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                
            }, to: getSubjectURL, encodingCompletion: {
                (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        switch response.result {
                        case .success(let j):
                            var subjectArray: [Subject] = []
                            let json = JSON(j)
                            
                            #if DEBUG
    //                            print(params)
                                print("==>getStudentSubject", json)
                            #endif
                            
                            let message = json["statusMessage"].stringValue
                            let status = json["statusCode"].intValue
                            let data = json["data"]
                            if status == 200{
                                let subjectData = data["subjects"]
                                for subject in subjectData{
                                    let name = subject.1["name"].stringValue
                                    let sectionId = subject.1["section_id"].intValue
                                    let code = subject.1["code"].stringValue
                                    let id = subject.1["id"].intValue
                                    let sectionName = subject.1["section_name"].stringValue
                                    let imperiumCode = subject.1["imperium_code"].stringValue
                                    
                                    let subjectObject = Subject(id: id, name: name, code: code, sectionId: sectionId, sectionName: sectionName, color: "#a171ff", imperiumCode: imperiumCode)
                                    subjectArray.append(subjectObject)
                                }
                                
                                completion(message,subjectArray,status)
                            }else{
                                let errorMessage = data["error_msgs"].stringValue
                                self.reportError(message: errorMessage)
                                completion(errorMessage,[],status)
                            }
                            
                        case .failure(let error):
                        
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                    }
                case .failure(let error):
                        
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            })
        }
    
    //Get user documents API:
        func getDocuments(user: User, completion: @escaping(_ message: String?, _ result: [DocumentsModel]?, _ status: Int?)->Void){
            let getSubjectURL = "\(baseURL!)/api/blended_learning/get_user_documents"
            
            
                let params = [
                    "username": "\(user.userName)",
                    "token": "\(user.token)",
                           ]
            
            
            self.manager.upload(multipartFormData: {
                multipartFormData in
                for (key, value) in params{
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                
            }, to: getSubjectURL, encodingCompletion: {
                (result) in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        switch response.result {
                        case .success(let j):
                            var documentsArray: [DocumentsModel] = []
                            let json = JSON(j)
                            
                            #if DEBUG
    //                            print(params)
                                print("==>getUserDocuments", json)
                            #endif
                            
                            let message = json["statusMessage"].stringValue
                            let status = json["statusCode"].intValue
                            let data = json["data"]
                            if status == 200{
                                let documentData = data["documents"]
                                for document in documentData{
                                    let id = document.1["id"].stringValue
                                    let name = document.1["name"].stringValue
                                    
                                    let itemAttachmentLink = document.1["attachment_link"].stringValue
                                    let itemAttachmentContentType = document.1["attachment_content_type"].stringValue
                                    let itemAttachmentContentSize = document.1["attachment_content_size"].stringValue
                                    let itemAttachmentFilename = document.1["attachment_file_name"].stringValue
                                    
                                    let documentModel = DocumentsModel(id: id, name: name, attachmentLink: itemAttachmentLink, attachmentContentType: itemAttachmentContentType, attachmentContentSize: itemAttachmentContentSize, attachmentFileName: itemAttachmentFilename)
                                    documentsArray.append(documentModel)
                                }
                                
                                completion(message,documentsArray,status)
                            }else{
                                let errorMessage = data["error_msgs"].stringValue
                                self.reportError(message: errorMessage)
                                completion(errorMessage,[],status)
                            }
                            
                        case .failure(let error):
                        
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                    }
                case .failure(let error):
                        
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            })
        }
    
    //Get Teacher Terms API:
    func getTeacherTerms(user: User, sectionId: Int, completion: @escaping(_ message: String?, _ result: [Subject]?, _ status: Int?)->Void){
        let getTermsURL = "\(baseURL!)/api/grades/get_sub_terms"
        
        var section = "\(sectionId)"
        if section == "0"{
            section = ""
        }
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "section_id": "\(section)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: getTermsURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        var termsArray: [Subject] = []
                        let json = JSON(j)
                        
                        #if DEBUG
//                            print("==> ", params)
//                            print("==>getTeacherTerms", json)
                        #endif
                        
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            let termsData = data["sub_terms"]
                            for terms in termsData{
                                let name = terms.1["name"].stringValue
                                let code = terms.1["code"].stringValue
                                let id = terms.1["id"].intValue
                                let imperiumCode = terms.1["imperium_code"].stringValue
                                
                                let termsObject = Subject(id: id, name: name, code: code, sectionId: 0, sectionName: "", color: "", imperiumCode: imperiumCode)
                                termsArray.append(termsObject)
                            }
                            
                            completion(message,termsArray,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Get Assessment Type API:
    func getAssessmentType(user: User, subjectId: Int, termId: Int, completion: @escaping(_ message: String?, _ result: [AssessmentType]?, _ status: Int?)->Void){
        let getAssessmentURL = "\(baseURL!)/api/agenda/get_assessment_types"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "subject": "\(subjectId)",
            "sub_term": "\(termId)",
        ]
        
        #if DEBUG
            print("getAssessmentTypeparams", params)
        #endif
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: getAssessmentURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        var assessmentArray: [AssessmentType] = []
                        
                        let json = JSON(j)

                        #if DEBUG
                            print("getAssessmentType", json)
                        #endif
                        
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            let assessmentData = data["assessment_types"]
                            for type in assessmentData{
                                let name = type.1["name"].stringValue
                                let id = type.1["id"].intValue
                                
                                let assessmentObject = AssessmentType(id: id, name: name)
                                assessmentArray.append(assessmentObject)
                            }
                            
                            completion(message,assessmentArray,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                        
                        #if DEBUG
                            print("getAssessmentTyperesres", response)
                        #endif
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    func generateDates(startDate: Date, endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    //View Section Assignments API:
    func viewSectionAssignment(user: User, sectionId: Int, startDate: String, endDate: String, agendaTheme: AgendaTheme, completion: @escaping(_ message: String?, _ result: [Event]?, _ workload: AgendaWorkload?, _ status: Int?)->Void){
        
        print("start date11: \(startDate)")
        print("end date11: \(endDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        var start_date = ""
        var end_date = ""
 
        if let outputStartDate = convertDateFormat(dateString: startDate) {
            start_date = outputStartDate
        } else {
            print("Invalid date format")
        }
        
        if let outputEndDate = convertDateFormat(dateString: endDate) {
            end_date = outputEndDate
        } else {
            print("Invalid date format")
        }
            
        let viewAssignmentURL = "\(AGENDA_ASSIGNMENTS_URL)/getsectionassignments?sectionId=\(sectionId)&start_date=\(start_date)&end_date=\(end_date)"

        print("viewAssignmentURL: \(viewAssignmentURL)")
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("\(viewAssignmentURL)")
        
        
        
        self.manager.request(viewAssignmentURL, method: .get, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    print("==>viewSectionAssignmentss", json)
                    var agendaArray: [Event] = []
                    var quizDetails: [AgendaDetail] = []
                    var examDetails: [AgendaDetail] = []
                    var homeWorkDetails: [AgendaDetail] = []
                    var classWorkDetails: [AgendaDetail] = []
                    var homeworkPercentage = 0.0
                    var classworkPercantage = 0.0
                    var quizPercentage = 0.0
                    var examPercentage = 0.0
                    
                    let message = json["message"].stringValue
                    var status = 0
                    if(message.contains("Successfully found assignments") || message.contains("assignments for section")){
                        status = 200
                    }
                    let data = json["data"]
                    if status == 200{
                        let agendaData = json["response"]
                        
                        for object in agendaData{
                            let subject_name = object.1["subject"]["name"].stringValue
                            let title = object.1["title"].stringValue
                            let teacher = object.1["createdBy"].stringValue
                            let allow_update = true
                            let students = object.1["assignedStudents"].array?.description
                            let workLoad = object.1["work_load"].doubleValue
                            let id = object.1["id"].intValue
                            let dateData = object.1["dueDate"].stringValue
                            var asst_type = object.1["assignmentType"].stringValue
                            let description = object.1["content"].stringValue
                            let ticked = object.1["is_ticked"].boolValue
                            let enable_submissions = object.1["enableOnlineSubmission"].boolValue
                            let enable_late_submissions = object.1["enableLateSubmission"].boolValue
                            let enable_grading = object.1["enableGrading"].boolValue
                            let enable_discussions = object.1["enableDiscussion"].boolValue
                            let estimatedTime = object.1["estimatedTime"].intValue
                            let attachments = object.1["attachments"]
                            let full_mark = object.1["fullMark"].stringValue

                            var attachment_link = ""
                            if(attachments.count > 0){
                                for att in attachments{
                                    attachment_link = att.1["url"].stringValue

                                }
                            }
                            
                            let date = self.dateFormatter1.string(from: self.dateFormatter.date(from: dateData) ?? self.tFormatter.date(from: dateData) ?? self.formatter.date(from: dateData) ?? Date())
                            
                            var type = 1
                            if(asst_type == "homework"){
                                type = 1
                            }
                            else if(asst_type == "classwork"){
                                type = 2
                            }
                            else if(asst_type == "exam"){
                                type = 4
                            }
                            else if(asst_type == "assessment"){
                                type = 3
                            }
                            else{
                                type = 1
                            }
                            switch type{
                                //Assessment:
                            case 3:
                                let sub_term = object.1["sub_term"].stringValue
                                let assessment_type = object.1["assessment_type"].stringValue
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students!, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.quizColor, topColor: agendaTheme.quizColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: "", endDate: "", duration: "", link_to_join: "", enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                quizDetails.append(detail)
                                quizPercentage = quizPercentage + workLoad
                                //Exam:
                            case 4:
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students!, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.examColor, topColor: agendaTheme.examColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: "", endDate: "", duration: "", link_to_join: "", enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                examDetails.append(detail)
                                examPercentage = examPercentage + workLoad
                                
                                //online_exam:
                            case 5:
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let startDate = object.1["start_date"].stringValue
                                let endDate = object.1["end_date"].stringValue
                                let duration = object.1["duration"].stringValue
                                let link_to_join = object.1["link_to_join"].stringValue
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students!, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.examColor, topColor: agendaTheme.examColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: startDate, endDate: endDate, duration: duration, link_to_join: link_to_join, enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                examDetails.append(detail)
                                examPercentage = examPercentage + workLoad
                                
                                //meetings
                            case 6:
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let startDate = object.1["start_date"].stringValue
                                let endDate = object.1["end_date"].stringValue
                                let duration = object.1["duration"].stringValue
                                let link_to_join = object.1["link_to_join"].stringValue
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students!, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.examColor, topColor: agendaTheme.examColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: startDate, endDate: endDate, duration: duration, link_to_join: link_to_join, enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                examDetails.append(detail)
                                examPercentage = examPercentage + workLoad
                                
                                //HomeWork:
                            case 1:
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students!, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.homeworkColor, topColor: agendaTheme.homeworkColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: "", endDate: "", duration: "", link_to_join: "", enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                homeWorkDetails.append(detail)
                                homeworkPercentage = homeworkPercentage + workLoad
                                //ClassWork:
                            case 2:
                                let sub_term = ""
                                let assessment_type = ""
                                
                                let detail = AgendaDetail(id: id, date: date, teacher: teacher, allow_update: allow_update, students: students!, type: type, title: title, subject_name: subject_name, full_mark: full_mark, sub_term: sub_term, assessment_type: assessment_type, description: description, backgroudColor: agendaTheme.classworkColor, topColor: agendaTheme.classworkColor, ticked: ticked, expand: false, percentage: workLoad, attachment_link: attachment_link, startDate: "", endDate: "", duration: "", link_to_join: "", enableSubmissions: enable_submissions, enableLateSubmissions: enable_late_submissions, enableDiscussions: enable_discussions, enableGrading: enable_grading, estimatedTime: estimatedTime)
                                classWorkDetails.append(detail)
                                classworkPercantage = classworkPercantage + workLoad
                            default:
                                break
                            }
                        }
                        let quizEvent = Event(id: 1, icon: agendaTheme.quizIcon, color: agendaTheme.quizColor, counter: quizDetails.count, type: self.agendaType.Assessment.rawValue, date: "", percentage: quizPercentage, detail: [], agendaDetail: quizDetails)
                        let examEvent = Event(id: 2, icon: agendaTheme.examIcon, color: agendaTheme.examColor, counter: examDetails.count, type: self.agendaType.Exam.rawValue, date: "", percentage: examPercentage, detail: [], agendaDetail: examDetails)
                        let homeWorkEvent = Event(id: 3, icon: agendaTheme.homeworkIcon, color: agendaTheme.homeworkColor, counter: homeWorkDetails.count, type: self.agendaType.Homework.rawValue, date: "", percentage: homeworkPercentage, detail: [], agendaDetail: homeWorkDetails)
                        let classWorkEvent = Event(id: 4, icon: agendaTheme.classworkIcon, color: agendaTheme.classworkColor, counter: classWorkDetails.count, type: self.agendaType.Classwork.rawValue, date: "", percentage: classworkPercantage, detail: [], agendaDetail: classWorkDetails)
                        
                        agendaArray.append(quizEvent)
                        agendaArray.append(examEvent)
                        agendaArray.append(homeWorkEvent)
                        agendaArray.append(classWorkEvent)
                        
                        let workload = data["work_loads"]
                        let homework = workload["1"].doubleValue
                        let classwork = workload["2"].doubleValue
                        let quiz = workload["3"].doubleValue
                        let exam = workload["4"].doubleValue
                        
                        let agendaWorkload = AgendaWorkload.init(homeworkLoad: homework, classworkLoad: classwork, quizLoad: quiz, examLoad: exam)
                        
                        completion(message,agendaArray,agendaWorkload,status)
                    }else{
                        let errorMessage = data["error_msgs"].stringValue
                        self.reportError(message: errorMessage)
                        completion(errorMessage,[],nil,status)
                    }
                    
                case .failure(let error):
                    
                    let agendaWorkload = AgendaWorkload.init(homeworkLoad: 0, classworkLoad: 0, quizLoad: 0, examLoad: 0)
                    
                    let schoolData = SchoolActivation(id: 0, logo: "", schoolURL: "", schoolId: "", name: "", website: "", location: "", lat: 0.0, long: 0.0, facebook: "", twitter: "", linkedIn: "", google: "", instagram: "", phone: "", code: "")
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],agendaWorkload,App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],agendaWorkload,App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],agendaWorkload,App.STATUS_INVALID_RESPONSE)
                    }
                }
            }
        }

    
    //Create Occasion:
    func createAssignment(user: User, agenda: AgendaExam, sectionId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createAssignmentURL = "\(AGENDA_ASSIGNMENTS_URL)/assignment"
        print("occasion occasion: \(agenda)")
//        print("occasion occasion1: \(filename)")

        let due = "\(agenda.startDate) \(agenda.endTime)"
        
        print(due)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: due)

        print("date date: \(date)")
        let students = agenda.students.joined(separator: ",")

        
        let due_date = formatter.string(from: date ?? Date())
        
       

        
        let params = [
        
        [
            "key": "school_id",
            "value": "\(user.schoolId)",
            "type": "text"
          ],
          [
            "key": "assignment_type",
            "value": "\(agenda.type.lowercased())",
            "type": "text"
          ],
          [
            "key": "estimated_time",
            "value": "\(agenda.estimatedTime)",
            "type": "text"
          ],
          [
            "key": "enable_discussion",
            "value": "\(agenda.enableDiscussions)",
            "type": "text"
          ],
          [
            "key": "enable_grading",
            "value": "\(agenda.enableGrading)",
            "type": "text"
          ],
          [
            "key": "enable_late_submission",
            "value": "\(agenda.enableLateSubmissions)",
            "type": "text"
          ],
          [
            "key": "full_mark",
            "value": "\(Int(agenda.mark))",
            "type": "text"
          ],
          [
            "key": "title",
            "value": "\(agenda.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
          [
            "key": "due_date",
            "value": "\(due_date)",
            "type": "text"
          ],
          [
            "key": "enable_online_submission",
            "value": "\(agenda.enableSubmissions)",
            "type": "text"
          ],
          [
            "key": "created_by",
            "value": "\(user.userId)",
            "type": "text"
          ],
          [
            "key": "content",
            "value": "\(agenda.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
          [
            "key": "subject_id",
            "value": "\(agenda.subjectId)",
            "type": "text"
          ],
          [
            "key": "hasAllstudent",
            "value": "false",
            "type": "text"
          ],
          [
            "key": "sectionIds",
            "value": "\(sectionId)",
            "type": "text"
          ],
          [
            "key": "studentIds",
            "value": "\(students)",
            "type": "text"
          ],
       
        ]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for param in params {
                if let key = param["key"], let value = param["value"] {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }


//            if profile?.size != CGSize(width: 0.0, height: 0.0){
//                if let profile = profile {
//                    multipartFormData.append(profile.jpeg(.lowest)!, withName: "file", fileName: filename, mimeType: "image/jpeg")
//                }
//            }

        }, to: createAssignmentURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        var status = 0
                        if message.contains("created successfully") {
                            let data = json["data"]
                            status = 200
                            completion(message,"",status)
                        }
                        else {
                        // Failed server response
                            
                            self.reportError(message: message)
                            completion(message,json,status)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):

                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    
    //Create Occasion:
    func gradeAssignment(user: User, mark: String, assignedStudentId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let markAssignmentURL = "\(AGENDA_ASSIGNMENTS_URL)/addmark?mark=\(mark)&assignedStudentId=\(assignedStudentId)"
        print("occasion occasion1: \(markAssignmentURL)")
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        


//        self.manager.request(markAssignmentURL, method: .put, headers: headers, encodingCompletion: {
//            (result) in
//            switch result {
//            case .success(let upload, _, _):
                
        self.manager.request(markAssignmentURL, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                .responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        var status = 0
                        if message.contains("successfully") {
                            let data = json["data"]
                            status = 200
                            completion(message,"",status)
                        }
                        else {
                        // Failed server response
                            let error = JSON(j)
                            let statusCode = error["statusCode"].intValue
                            let data = error["data"]
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,error,statusCode)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
         
            }

    
    
    
    
    //Create Assignment API:
    func createAssignment1(user: User, agenda: AgendaExam, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createAssignmentURL = "\(baseURL!)/api/agenda/create_assignment"
        var type = 0
        
        switch agenda.type{
        case "Homework":
            type = 1
        case "Classwork":
            type = 2
        case "Quiz":
            type = 3
        default:
            type = 4
        }
        
        var students = ""
        for (index, std) in agenda.students.enumerated(){
            if students.count > 1{
                if index == 0{
                    students = "\(std)"
                }else{
                    students = "\(students),\(std)"
                }
            }else{
                students = std
            }
        }
        
        var params = ["":""]
        
        //no student list in assessment
        if type == agendaType.Assessment.rawValue{
            params = [
                "username": "\(user.userName)",
                "token": "\(user.token)",
                "student_username": "\(user.userName)",
                "type": "\(type)",
                "subject": "\(agenda.subjectId)",
                "due_date": "\(agenda.startDate)",
                "description": "\(agenda.description)",
                "assessment_type": "\(agenda.assessmentTypeId)",
                "sub_term": "\(agenda.groupId)",
                "full_mark": "\(agenda.mark)",
                "title": "\(agenda.title)"
            ]
        }else{
            params = [
                "username": "\(user.userName)",
                "token": "\(user.token)",
                "student_username": "\(user.userName)",
                "type": "\(type)",
                "subject": "\(agenda.subjectId)",
                "due_date": "\(agenda.startDate)",
                "description": "\(agenda.description)",
                "assessment_type": "\(agenda.assessmentTypeId)",
                "sub_term": "\(agenda.groupId)",
                "full_mark": "\(agenda.mark)",
                "title": "\(agenda.title)",
                "students": "\(students)"
            ]
        }
        
        #if DEBUG
            print("paramsagenda",params)
        #endif
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: createAssignmentURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,"",status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Edit Assignment API:
    func editAssignment(user: User, agenda: AgendaExam, sectionId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createAssignmentURL = "\(AGENDA_ASSIGNMENTS_URL)/assignment/\(agenda.id)"
        print("occasion occasion: \(agenda)")
//        print("occasion occasion1: \(filename)")

        let due = "\(agenda.startDate) \(agenda.endTime)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: due)

        print("date date: \(date)")
        let students = agenda.students.joined(separator: ",")

        
        let due_date = formatter.string(from: date ?? Date())
        
       

        
        let params = [
        
        [
            "key": "school_id",
            "value": "\(user.schoolId)",
            "type": "text"
          ],
          [
            "key": "assignment_type",
            "value": "\(agenda.type.lowercased())",
            "type": "text"
          ],
          [
            "key": "estimated_time",
            "value": "\(agenda.estimatedTime)",
            "type": "text"
          ],
          [
            "key": "enable_discussion",
            "value": "\(agenda.enableDiscussions)",
            "type": "text"
          ],
          [
            "key": "enable_grading",
            "value": "\(agenda.enableGrading)",
            "type": "text"
          ],
          [
            "key": "enable_late_submission",
            "value": "\(agenda.enableLateSubmissions)",
            "type": "text"
          ],
          [
            "key": "full_mark",
            "value": "\(Int(agenda.mark))",
            "type": "text"
          ],
          [
            "key": "title",
            "value": "\(agenda.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
          [
            "key": "due_date",
            "value": "\(due_date)",
            "type": "text"
          ],
          [
            "key": "enable_online_submission",
            "value": "\(agenda.enableSubmissions)",
            "type": "text"
          ],
          [
            "key": "created_by",
            "value": "\(user.userId)",
            "type": "text"
          ],
          [
            "key": "content",
            "value": "\(agenda.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
          [
            "key": "subject_id",
            "value": "\(agenda.subjectId)",
            "type": "text"
          ],
          [
            "key": "hasAllstudent",
            "value": "false",
            "type": "text"
          ],
          [
            "key": "section_id",
            "value": "\(sectionId)",
            "type": "text"
          ],
          [
            "key": "studentIds",
            "value": "\(students)",
            "type": "text"
          ]]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for param in params {
                if let key = param["key"], let value = param["value"] {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
            
//            if profile?.size != CGSize(width: 0.0, height: 0.0){
//                if let profile = profile {
//                    multipartFormData.append(profile.jpeg(.lowest)!, withName: "file", fileName: filename, mimeType: "image/jpeg")
//                }
//            }

        }, to: createAssignmentURL, method: .put, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        var status = 0
                        if message.contains("updated successfully"){
                            let data = json["data"]
                            status = 200
                            completion(message,"",status)
                        }
                        else {
                        // Failed server response
                            let error = JSON(j)
                            let statusCode = error["statusCode"].intValue
                            let data = error["data"]
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,error,statusCode)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):

                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    func createAssignmentWithFile(user: User, file: URL?, fileCompressed: NSData?, image: UIImage?, isSelectedImage: Bool, agenda: AgendaExam, filename: String, sectionId: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createAssignmentURL = "\(AGENDA_ASSIGNMENTS_URL)/assignment"
        print("occasion occasion: \(agenda)")
//        print("occasion occasion1: \(filename)")

        let due = "\(agenda.startDate) \(agenda.endTime)"
        
        print(due)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: due)

        print("date date: \(date)")
        let students = agenda.students.joined(separator: ",")

        
        let due_date = formatter.string(from: date ?? Date())
        
       

        
        let params = [
        
        [
            "key": "school_id",
            "value": "\(user.schoolId)",
            "type": "text"
          ],
          [
            "key": "assignment_type",
            "value": "\(agenda.type.lowercased())",
            "type": "text"
          ],
          [
            "key": "estimated_time",
            "value": "\(agenda.estimatedTime)",
            "type": "text"
          ],
          [
            "key": "enable_discussion",
            "value": "\(agenda.enableDiscussions)",
            "type": "text"
          ],
          [
            "key": "enable_grading",
            "value": "\(agenda.enableGrading)",
            "type": "text"
          ],
          [
            "key": "enable_late_submission",
            "value": "\(agenda.enableLateSubmissions)",
            "type": "text"
          ],
          [
            "key": "full_mark",
            "value": "\(Int(agenda.mark))",
            "type": "text"
          ],
          [
            "key": "title",
            "value": "\(agenda.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
          [
            "key": "due_date",
            "value": "\(due_date)",
            "type": "text"
          ],
          [
            "key": "enable_online_submission",
            "value": "\(agenda.enableSubmissions)",
            "type": "text"
          ],
          [
            "key": "created_by",
            "value": "\(user.userId)",
            "type": "text"
          ],
          [
            "key": "content",
            "value": "\(agenda.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")",
            "type": "text"
          ],
          [
            "key": "subject_id",
            "value": "\(agenda.subjectId)",
            "type": "text"
          ],
          [
            "key": "hasAllstudent",
            "value": "false",
            "type": "text"
          ],
          [
            "key": "sectionIds",
            "value": "\(sectionId)",
            "type": "text"
          ],
          [
            "key": "studentIds",
            "value": "\(students)",
            "type": "text"
          ],
       
        ]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        
     
                
                self.manager.upload(multipartFormData: {
                    multipartFormData in
                    for param in params {
                        if let key = param["key"], let value = param["value"] {
                            if let data = value.data(using: .utf8) {
                                if(!key.contains("file-")){
                                    multipartFormData.append(data, withName: key)
                                }
                            }
                        }
                    }

            if isSelectedImage{
                multipartFormData.append(image!.jpeg(.lowest)!, withName: "file-1", fileName: filename, mimeType: "image/jpeg")
            }else{
                let pdfData = try! Data(contentsOf: file!)
                let filetype = file!.description.suffix(4)
                var mimeType = ""
                if filetype.lowercased() == ".pdf"{
                    mimeType = "application/pdf"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }else if filetype.lowercased() == "docx"{
                    mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }else if filetype.lowercased() == "xlsx"{
                    mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }else if filetype.lowercased() == "pptx" || filetype.lowercased() == "ppsx" || filetype.lowercased() == "ppt"{
                    mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                 else if filetype.lowercased() == ".m4a"{
                     mimeType = "audio/mpeg"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                 else if filetype.lowercased() == ".mp3" || filetype == ".mid" || filetype == ".midi" || filetype == ".kar" || filetype == ".ogg" || filetype == ".aac"{
                     mimeType = "audio/mpeg"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                else if(filetype.lowercased() == ".gif"){
                    mimeType = "audio/gif"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".wma"){
                    mimeType = "audio/wma"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".rtf"){
                    mimeType = "application/rtf"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".txt"){
                    mimeType = "text/plain"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".csv"){
                    mimeType = "text/csv"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                     mimeType = "video/mp4"
                    multipartFormData.append(fileCompressed! as Data, withName: "file-1", fileName: filename, mimeType: mimeType)
                    
                 }
                 else if filetype.lowercased() == ".wmv"{
                     mimeType = "video/x-ms-wmv"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                 else{
                     mimeType = "application/octet-stream"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                
                
            }
            
        }, to: createAssignmentURL, method: .post, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        var status = 0
                        if message.contains("created successfully") {
                            let data = json["data"]
                            status = 200
                            completion(message,"",status)
                        }
                        else {
                        // Failed server response
                         
                            self.reportError(message: message)
                            completion(message,json,status)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
            let urlAsset = AVURLAsset(url: inputURL, options: nil)
            guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
                handler(nil)

                return
            }

            exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously { () -> Void in
                handler(exportSession)
            }
        }
    
    func editAssignmentWithFile(user: User, file: URL?, image: UIImage?, isSelectedImage: Bool, agenda: AgendaExam, filename: String, sectionId: String, fileCompressed: NSData?, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let createAssignmentURL = "\(AGENDA_ASSIGNMENTS_URL)/assignment/\(agenda.id)"
        print("occasion occasion: \(agenda)")
//        print("occasion occasion1: \(filename)")

        let due = "\(agenda.startDate) \(agenda.endTime)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: due)

        print("date date: \(date)")
        let students = agenda.students.joined(separator: ",")

        
        let due_date = formatter.string(from: date ?? Date())
        
       

        
        let params = [
        
        [
            "key": "school_id",
            "value": "\(user.schoolId)",
            "type": "text"
          ],
          [
            "key": "assignment_type",
            "value": "\(agenda.type.lowercased())",
            "type": "text"
          ],
          [
            "key": "estimated_time",
            "value": "\(agenda.estimatedTime)",
            "type": "text"
          ],
          [
            "key": "enable_discussion",
            "value": "\(agenda.enableDiscussions)",
            "type": "text"
          ],
          [
            "key": "enable_grading",
            "value": "\(agenda.enableGrading)",
            "type": "text"
          ],
          [
            "key": "enable_late_submission",
            "value": "\(agenda.enableLateSubmissions)",
            "type": "text"
          ],
          [
            "key": "full_mark",
            "value": "\(Int(agenda.mark))",
            "type": "text"
          ],
          [
            "key": "title",
            "value": "\(agenda.title)",
            "type": "text"
          ],
          [
            "key": "due_date",
            "value": "\(due_date)",
            "type": "text"
          ],
          [
            "key": "enable_online_submission",
            "value": "\(agenda.enableSubmissions)",
            "type": "text"
          ],
          [
            "key": "created_by",
            "value": "\(user.userId)",
            "type": "text"
          ],
          [
            "key": "content",
            "value": "\(agenda.description)",
            "type": "text"
          ],
          [
            "key": "subject_id",
            "value": "\(agenda.subjectId)",
            "type": "text"
          ],
          [
            "key": "hasAllstudent",
            "value": "false",
            "type": "text"
          ],
          [
            "key": "section_id",
            "value": "\(sectionId)",
            "type": "text"
          ],
          [
            "key": "studentIds",
            "value": "\(students)",
            "type": "text"
          ]]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for param in params {
                if let key = param["key"], let value = param["value"] {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }

            if isSelectedImage{
                multipartFormData.append(image!.jpeg(.lowest)!, withName: "file-1", fileName: filename, mimeType: "image/jpeg")
            }else{
                let pdfData = try! Data(contentsOf: file!)
                let filetype = file!.description.suffix(4)
                var mimeType = ""
                if filetype.lowercased() == ".pdf"{
                    mimeType = "application/pdf"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }else if filetype.lowercased() == "docx"{
                    mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }else if filetype.lowercased() == "xlsx"{
                    mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }else if filetype.lowercased() == "pptx" || filetype.lowercased() == "ppsx" || filetype.lowercased() == "ppt"{
                    mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                 else if filetype.lowercased() == ".m4a"{
                     mimeType = "audio/mpeg"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                 else if filetype.lowercased() == ".mp3" || filetype == ".mid" || filetype == ".midi" || filetype == ".kar" || filetype == ".ogg" || filetype == ".aac"{
                     mimeType = "audio/mpeg"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                else if(filetype.lowercased() == ".gif"){
                    mimeType = "audio/gif"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".wma"){
                    mimeType = "audio/wma"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".rtf"){
                    mimeType = "application/rtf"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".txt"){
                    mimeType = "text/plain"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if(filetype.lowercased() == ".csv"){
                    mimeType = "text/csv"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                }
                else if filetype.lowercased() == ".mp4" || filetype.lowercased() == "m3u8" || filetype.lowercased() == ".mov" || filetype.lowercased() == "mpeg" || filetype.lowercased() == ".mpg" || filetype.lowercased() == "webm" || filetype.lowercased() == ".flv" || filetype.lowercased() == ".wav" || filetype.lowercased() == ".3gp" || filetype.lowercased() == ".avi"{
                     mimeType = "video/mp4"
                    multipartFormData.append(fileCompressed! as Data, withName: "file-1", fileName: filename, mimeType: mimeType)
                    
                 }
                 else if filetype.lowercased() == ".wmv"{
                     mimeType = "video/x-ms-wmv"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                 else{
                     mimeType = "application/octet-stream"
                    multipartFormData.append(pdfData, withName: "file-1", fileName: filename, mimeType: mimeType)
                 }
                
                
            }
        }, to: createAssignmentURL, method: .put, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        var status = 0
                        if message.contains("updated successfully"){
                            let data = json["data"]
                            status = 200
                            completion(message,"",status)
                        }
                        else {
                        // Failed server response
                            let error = JSON(j)
                            let statusCode = error["statusCode"].intValue
                            let data = error["data"]
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,error,statusCode)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):

                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Get Section Students API:
    func getSectionStudent(user: User, sectionId: Int, completion: @escaping(_ message: String?, _ result: [CalendarEventItem]?, _ status: Int?)->Void){
        print("getSectionStudent111")
        let getStudentURL = "\(GET_STUDENTS_URL)/student_view_by_section?sectionId=\(sectionId)"
        
        print("username: \(user.userName)")
        print("token: \(user.token)")
        print("section_id: \(sectionId)")

        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "section_id": "\(sectionId)",
        ]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        
        self.manager.request(getStudentURL, method: .get, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    var studentsArray: [CalendarEventItem] = []
                    let json = JSON(j)
                    
                    #if DEBUG
                        print("==>getSectionStudent", json)
                    #endif
                    let message = json["message"].stringValue
                    var status = 0
                    if(message.contains("Students details found")){
                        status = 200
                    }
                    if status == 200{
                        let studentsData = json["response"]
                        for student in studentsData{
                            let name = "\(student.1["user"]["firstName"].stringValue) \(student.1["user"]["lastName"].stringValue)"
                            let admissionNo = student.1["id"].stringValue
                            let studentId = student.1["id"].stringValue
                            print("student id: \(studentId)")
                            
                            let studentObject = CalendarEventItem(id: admissionNo, title: name, active: false, studentId: studentId)
                            studentsArray.append(studentObject)
                        }
                        
                        completion(message,studentsArray,status)
                    }else{
                        
                        self.reportError(message: message)
                        completion(message,[],status)
                    }
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            }
        
        
        
       
    }
    
    //Set Device Token API:
    func setDeviceToken(user: User, deviceId: String, deviceToken: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let setTokenURL = "\(NOTIFICATIONS_URL)/subscribe-app-user-irfan"
        
        print("token1: \(user.userName)")
        print("token2: \(user.token)")
        print("token3: \(deviceId)")
        print("token4: \("iOS")")
        print("token5: \(deviceToken)")
        let params = [
            "userId": "\(user.userId)",
            "appType": "Apple",
            "deviceToken": "\(deviceToken)",
        ]
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]

        print("params params final: \(params)")
        self.manager.request(setTokenURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                        
                        let json = JSON(j)
                        
                        print("setDeviceToken", json)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            
                            completion(message,"",status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            //don't report because the simulator doesn't have gcm token
//                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
    }
    
    //Set Device Token API:
    func removeDeviceToken(user: User, deviceId: String, deviceToken: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let setTokenURL = "\(NOTIFICATIONS_URL)/remove_token_irfan"
        
        print("token1: \(user.userName)")
        print("token2: \(user.token)")
        print("token3: \(deviceId)")
        print("token4: \("iOS")")
        print("token5: \(deviceToken)")
        let params = [
            "userId": "\(user.userId)",
            "appType": "Apple",
            "deviceToken": "\(deviceToken)",
        ]
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]

        print("params params final remove token: \(params)")
        self.manager.request(setTokenURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                        
                        let json = JSON(j)
                        
                        print("removeDeviceToken", json)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            
                            completion(message,"",status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            //don't report because the simulator doesn't have gcm token
//                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
    }
    
    
    //Get Notifications API:
    func getNotifications(user: User, language: String, completion: @escaping(_ message: String?, _ result: [Notifications]?, _ status: Int?)->Void){
        let getNotificationsURL = "\(NOTIFICATIONS_URL)/notifications?schoolId=\(user.schoolId)&userId=\(user.userId)"
        
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header: \(headers)")
        
        self.manager.request(getNotificationsURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    var notificationsArray: [Notifications] = []
                    
                    let json = JSON(j)
                    #if DEBUG
                        print("getNotifications", json)
                    #endif
                    let message = json["message"].stringValue
                    let status = 200
                    let data = json["response"]
                    if status == 200{
                    
                        for notification in data{
                            let date = notification.1["createdAt"].stringValue
                            let title = notification.1["title"].stringValue
                            let originId = notification.1["user_id"].intValue
                            let id = notification.1["id"].intValue
                            let read = notification.1["isRead"].boolValue
                            let description = notification.1["messageText"].stringValue
                            
                            let referenceType = notification.1["referenceType"].stringValue
                            var section = 0
                            if(referenceType.contains("Event")){
                                section = 1
                            }
                            else if(referenceType.contains("Assignment")){
                                section = 3
                            }
                            else if(referenceType.contains("Message")){
                                section = 6
                            }
                            else if(referenceType.contains("absence") || referenceType.contains("Absence")){
                                section = 2
                            }
                            
                                                        
                            let object = Notifications(id: id, referenceId: originId, title: title, date: date, read: read, description: description, section: section)
                            
                            notificationsArray.append(object)
                        }
                            completion(message,notificationsArray,status)
                    }else{
                        let errorMessage = data["error_msgs"].stringValue
                        completion(errorMessage,[],status)
                    }
                    
                case .failure(let error):
                
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
    }
    
    
    //Check Notifications API:
    func checkNotifications(user: User, notificationId: Int, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let checkNotificationsURL = "\(baseURL!)/api/notifications/check_notification"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "id": "\(notificationId)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: checkNotificationsURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Uncheck Notifications API:
    func uncheckNotifications(user: User, notificationId: Int, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let uncheckNotificationsURL = "\(baseURL!)/api/notifications/uncheck_notification"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "id": "\(notificationId)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: uncheckNotificationsURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Get Pages URL:
    func getPages(completion: @escaping(_ message: String?, _ school: Page?, _ status: Int)->Void){
        let params: Parameters = [:]
        
       
                    
                    let privacyTitle = "Privacy Policy"
                    let privacyText = "Privacy Notice Effective Date: November 1, 2023, This privacy notice discloses the privacy practices for SLINK Education. This privacy notice applies solely to information collected by the Web app and Mobile App, except where stated otherwise. It will notify you of the following: What information we collect; With whom it is shared; How it can be corrected; How it is secured; How policy changes will be communicated; and How to address concerns over misuse of personal data. Information Collection, Use, and Sharing We only have access to\\collect information that the School gives us. We will not sell or rent this information to anyone. We will use your information to respond to you, regarding the reason you contacted us and how you are using the Web or Mobile Application. We will not share your information with any third party outside of our organization, other than as necessary to fulfill your request. Unless you ask us not to, we may contact you via email in the future to tell you about specials, new products or services, or changes to this privacy policy. Your Access to and Control Over Information. You can do the following at any time by contacting the School from which you have got your login details: See what data they have about if any. Change correct any data they have about you. Have us delete any data they have about you. Express any concern you have about our use of your data Registration In order to use the Web App, a user must get login details from the School. Cookies We use \\\"cookies\\\" on this APP. A cookie is a piece of data stored on a site visitors hard drive to help us improve your access to the App and identify repeat visitor. For instance, when we use a cookie to identify you, you would not have to log in a password more than once, thereby saving time while on our app. Cookies can also enable us to track and target the interests of our users to enhance their experience. Usage of a cookie is in no way linked to any personally identifiable information. The app may contain links to other sites / web resources. Please be aware that we are not responsible for the content or privacy practices of such other sites. We encourage our users to be aware when they leave our app and to read the privacy statements of any other site /s that collects personally identifiable information. Surveys & Contests. From time-to-time, our site requests information via surveys or contests. Participation in these surveys or contests is completely voluntary and you may choose whether or not to participate and therefore disclose this information. Information requested may include contact information (such as name and shipping address), and demographic information (such as zip code, age level). Contact information will be used to notify the winners and award prizes. Survey information will be used for purposes of monitoring or improving the use and satisfaction of this site. "
                    
                    let termsTitle = "Terms & Conditions"
                    let termsText = "TERMS & CONDITIONS: \n Slink Education Last updated [November 01, 2023] PLEASE READ THESE TERMS AND CONDITIONS CAREFULLY. \n AGREEMENT TO TERMS: These Terms and Conditions constitute a legally binding agreement made between you, whether personally or on behalf of an entity (you) and Slink Education, doing business as Slink Education, we, us or our, concerning your access to and use of the Slink Web and Mobile app as well as any other media form, media channel, mobile website or mobile application related, linked, or otherwise connected thereto (collectively, the Site). You agree that by accessing the Site, you have read, understood, and agree to be bound by all of these Terms and Conditions Use. IF YOU DO NOT AGREE WITH ALL OF THESE TERMS and CONDITIONS, THEN YOU ARE EXPRESSLY PROHIBITED FROM USING THE SITE AND YOU MUST DISCONTINUE USE IMMEDIATELY. Supplemental terms and conditions or documents that may be posted on the Site from time to time are hereby expressly incorporated herein by reference. We reserve the right, in our sole discretion, to make changes or modifications to these Terms and Conditions at any time and for any reason. We will alert you about any changes by updating the Last updated date of these Terms and Conditions and you waive any right to receive specific notice of each such change. It is your responsibility to periodically review these Terms and Conditions to stay informed of updates. You will be subject to and will be deemed to have been made aware of and to have accepted, the changes in any revised Terms and Conditions by your continued use of the Site after the date such revised Terms are posted. The information provided on the Site is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would subject us to any registration requirement within such jurisdiction or country. Accordingly, those persons who choose to access the Site from other locations do so on their own initiative and are solely responsible for compliance with local laws, if and to the extent local laws are applicable. The Site is intended for users who are at least 13 years of age. All users who are minors in the jurisdiction in which they reside must have the permission of, and be directly supervised by, their parent or guardian to use the Site. If you are a minor, you must have your parent or guardian read and agree to these Terms & Conditions prior to you using the Site. INTELLECTUAL PROPERTY RIGHTS: Unless otherwise indicated, the Site is Slink Education proprietary property and all source code, databases, functionality, software, website designs, audio, video, text, photographs, and graphics on the Site (collectively, the Content) and the trademarks, service marks, and logos contained therein (the Marks) are owned or controlled by us or licensed to us, and are protected by copyright and trademark laws and various other intellectual property rights. The Content and the Marks are provided on the Site AS IS for your information and personal use only. Except as expressly provided in these Terms and conditions, no part of the Site and no Content or Marks may be copied, reproduced, aggregated, republished, uploaded, posted, publicly displayed, encoded, translated, transmitted, distributed, sold, licensed, or otherwise exploited for any commercial purpose whatsoever, without our express prior written permission. Provided that you are eligible to use the Site, you are granted a limited Subscription to access and use the Site and to download or print a copy of any portion of the Content to which you have properly gained access solely for your personal, non-commercial use. We reserve all rights not expressly granted to you in and to the Site, Content and the Marks. \n USER REPRESENTATIONS: By using the Site, you represent and warrant that: [(1) all information you submit will be true, accurate, current, and complete; (2) you will maintain the accuracy of such information and promptly update such information as necessary;] (3) you have the legal capacity and you agree to comply with these Terms and conditions; (4) you are not under the age of 13; (5) not a minor in the jurisdiction in which you reside, or if a minor, you have received parental permission to use the Site; (6) you will not access the Site through automated or non-human means, whether through a bot, script or otherwise; (7) you will not use the Site for any illegal or unauthorized purpose; and (8) your use of the Site will not violate any applicable law or regulation. If you provide any information that is untrue, inaccurate, not current, or incomplete, we have the right to suspend or terminate your account and refuse any and all current or future use of the Site (or any portion thereof). \n USER REGISTRATION: You will be provided with your registration details by the School and You are required to log in to the Site. You agree to keep your password confidential and will be responsible for all use of your account and password. We reserve the right to remove, reclaim, or change a username you select if we determine, in our sole discretion, that such username is inappropriate, obscene, or otherwise objectionable. \n PROHIBITED ACTIVITIES: You may not access or use the Site for any purpose other than that for which we make the Site available. The Site may not be used in connection with any commercial endeavors except those that are specifically endorsed or approved by us. As a user of the Site, you agree not to: Systematically retrieve data or other content from the Site to create or compile, directly or indirectly, a collection, compilation, database, or directory without written permission from us. Make any unauthorized use of the Site, including collecting usernames and/or email addresses of users by electronic or other means for the purpose of sending unsolicited email, or creating user accounts by automated means or under false pretenses. Use the Site to advertise or offer to sell goods and services. Circumvent, disable, or otherwise interfere with security-related features of the Site, including features that prevent or restrict the use or copying of any Content or enforce limitations on the use of the Site and/or the Content contained therein. Engage in unauthorized framing of or linking to the Site. Tricking, defrauding, or misleading us and other users, especially in an attempt to learn sensitive account information such as user passwords; Make improper use of our support services or submit false reports of abuse or misconduct. Engage in any automated use of the system, such as using scripts to send comments or messages, or using any data mining, robots, or similar data gathering and extraction tools. Interfere with, disrupt, or create an undue burden on the Site or the networks or services connected to the Site. Attempt to impersonate another user or person or use the username of another user. Sell or otherwise transfer your profile. Use any information obtained from the Site in order to harass, abuse, or harm another person. Use the Site as part of an effort to compete with us or otherwise use the Site and/or the Content for any revenue-generating endeavor or commercial enterprise. Decipher, decompile, disassemble, or reverse engineer any of the software comprising or in any way making up a part of the Site. Attempt to bypass any measures of the Site designed to prevent or restrict access to the Site, or any portion of the Site. Harass, annoy, intimidate, or threaten any of our employees or agents engaged in providing any portion of the Site to you. Delete the copyright or other proprietary rights notice from any Content. Copy or adapt the Site software, including but not limited to Flash, PHP, HTML, JavaScript, or other code. Upload or transmit (or attempt to upload or to transmit) viruses, Trojan horses, or other material, including excessive use of capital letters and spamming (continuous posting of repetitive text), that interferes with any party uninterrupted use and enjoyment of the Site or modifies, impairs, disrupts, alters, or interferes with the use, features, functions, operation, or maintenance of the Site. Upload or transmit (or attempt to upload or to transmit) any material that acts as a passive or active information collection or transmission mechanism, including without limitation, clear graphics interchange formats (gifs), 71 pixels, web bugs, cookies, or other similar devices (sometimes referred to as spyware or passive collection mechanisms or PCM).Except as may be the result of a standard search engine or Internet browser usage, use, launch, develop, or distribute any automated system, including without limitation, any spider, robot, cheat utility, scraper, or offline reader that accesses the Site, or using or launching any unauthorized script or other software. Disparage, tarnish, or otherwise harm, in our opinion, us and/or the Site.use the Site in a manner inconsistent with any applicable laws or regulations. \n MOBILE APPLICATION LICENSE: Use License If you access the Site via a mobile application, then we grant you a revocable, non-exclusive, non-transferable, limited right to install and use the mobile application on wireless electronic devices owned or controlled by you, and to access and use the mobile application on such devices strictly in accordance with the terms and conditions of this mobile application license contained in these Terms & Conditions. You shall not: (1) decompile, reverse engineer, disassemble, attempt to derive the source code of, or decrypt the application; (2) make any modification, adaptation, improvement, enhancement, translation, or derivative work from the application; (3) violate any applicable laws, rules, or regulations in connection with your access or use of the application; (4) remove, alter, or obscure any proprietary notice (including any notice of copyright or trademark) posted by us or the licensors of the application; (5) use the application for any revenue generating endeavor, commercial enterprise, or other purpose for which it is not designed or intended; (6) make the application available over a network or other environment permitting access or use by multiple devices or users at the same time; (7) use the application for creating a product, service, or software that is, directly or indirectly, competitive with or in any way a substitute for the application; (8) use the application to send automated queries to any website or to send any unsolicited commercial e-mail; or (9) use any proprietary information or any of our interfaces or our other intellectual property in the design, development, manufacture, licensing, or distribution of any applications, accessories, or devices for use with the application. \n Apple and Android Devices: The following terms apply when you use a mobile application obtained from either the Apple Store or Google Play (each an App Distributor) to access the Site: (1) the license granted to you for our mobile application is limited to a non-transferable license to use the application on a device that utilizes the Apple iOS or Android operating systems, as applicable, and in accordance with the usage rules set forth in the applicable App Distributor terms of service; (2) we are responsible for providing any maintenance and support services with respect to the mobile application as specified in the terms and conditions of this mobile application license contained in these Terms & Conditions or as otherwise required under applicable law, and you acknowledge that each App Distributor has no obligation whatsoever to furnish any maintenance and support services with respect to the mobile application; (3) in the event of any failure of the mobile application to conform to any applicable warranty, you may notify the applicable App Distributor, and the App Distributor, in accordance with its terms and policies, may refund the purchase price, if any, paid for the mobile application, and to the maximum extent permitted by applicable law, the App Distributor will have no other warranty obligation whatsoever with respect to the mobile application; (4) you represent and warrant that (i) you are not located in a country that is subject to a U.S. government embargo, or that has been designated by the U.S. government as a terrorist supporting country and (ii) you are not listed on any U.S. government list of prohibited or restricted parties; (5) you must comply with applicable third-party terms of agreement when using the mobile application, e.g., if you have a VoIP application, then you must not be in violation of their wireless data service agreement when using the mobile application; and (6) you acknowledge and agree that the App Distributors are third-party beneficiaries of the terms and conditions in this mobile application license contained in these Terms & Conditions, and that each App Distributor will have the right (and will be deemed to have accepted the right) to enforce the terms and conditions in this mobile application license contained in these Terms & Conditions against you as a third-party beneficiary thereof. \n SUBMISSIONS: You acknowledge and agree that any questions, comments, suggestions, ideas, feedback, or other information regarding the Site Submissions provided by you to us are non-confidential and shall become our sole property. We shall own exclusive rights, including all intellectual property rights, and shall be entitled to the unrestricted use and dissemination of these Submissions for any lawful purpose, commercial or otherwise, without acknowledgment or compensation to you. You hereby waive all moral rights to any such Submissions, and you hereby warrant that any such Submissions are original with you or that you have the right to submit such Submissions. You agree there shall be no recourse against us for any alleged or actual infringement or misappropriation of any proprietary right in your Submissions. \n THIRD-PARTY WEBSITES AND CONTENT: The Site may contain (or you may be sent via the Site) links to other websites Third-Party Websites as well as articles, photographs, text, graphics, pictures, designs, music, sound, video, information, applications, software, and other content or items belonging to or originating from third parties Third-Party Content. Such Third-Party Websites and Third-Party Content are not investigated, monitored, or checked for accuracy, appropriateness, or completeness by us, and we are not responsible for any Third-Party Websites accessed through the Site or any Third-Party Content posted on, available through, or installed from the Site, including the content, accuracy, offensiveness, opinions, reliability, privacy practices, or other policies of or contained in the Third-Party Websites or the Third-Party Content. The inclusion of, linking to, or permitting the use or installation of any Third-Party Websites or any Third-Party Content does not imply approval or endorsement thereof by us. If you decide to leave the Site and access the Third-Party Websites or to use or install any Third-Party Content, you do so at your own risk, and you should be aware these Terms & Conditions no longer govern. You should review the applicable terms and policies, including privacy and data gathering practices, of any website to which you navigate from the Site or relating to any applications you use or install from the Site. Any purchases you make through Third-Party Websites will be through other websites and from other companies, and we take no responsibility whatsoever in relation to such purchases which are exclusively between you and the applicable third party. You agree and acknowledge that we do not endorse the products or services offered on Third-Party Websites and you shall hold us harmless from any harm caused by your purchase of such products or services. Additionally, you shall hold us harmless from any losses sustained by you or harm caused to you relating to or resulting in any way from any Third-Party Content or any contact with Third-Party Websites. \nADVERTISERS: We allow advertisers to display their advertisements and other information in certain areas of the Site, such as sidebar advertisements or banner advertisements. If you are an advertiser, you shall take full responsibility for any advertisements you place on the Site and any services provided on the Site or products sold through those advertisements. Further, as an advertiser, you warrant and represent that you possess all rights and authority to place advertisements on the Site, including, but not limited to, intellectual property rights, publicity rights, and contractual rights. As an advertiser, you agree that such advertisements are subject to our Digital Millennium Copyright Act (DMCA) Notice and Policy provisions as described below, and you understand and agree there will be no refund or other compensation for DMCA takedown-related issues. We simply provide the space to place such advertisements, and we have no other relationship with advertisers. \n SITE MANAGEMENT: We reserve the right, but not the obligation, to:(1) monitor the Site for violations of these Terms and Conditions; (2) take appropriate legal action against anyone who, in our sole discretion, violates the law or these Terms & Conditions, including without limitation, reporting such user to law enforcement authorities; (3) in our sole discretion and without limitation, refuse, restrict access to, limit the availability of, or disable (to the extent technologically feasible) any of your Contributions or any portion thereof; (4) in our sole discretion and without limitation, notice, or liability, to remove from the Site or otherwise disable all files and content that are excessive in size or are in any way burdensome to our systems; and (5) otherwise manage the Site in a manner designed to protect our rights and property and to facilitate the proper functioning of the Site.\n PRIVACY POLICY: We care about data privacy and security. Please review our Privacy Policy. By using the Site, you agree to be bound by our Privacy Policy, which is incorporated into these Terms & Conditions. Please be advised the Site is hosted in the United States. If you access the Site from the European Union, Asia, or any other region of the world with laws or other requirements governing personal data collection, use, or disclosure that differ from applicable laws in the United States, then through your continued use of the Site or Services, you are transferring your data to the United States, and you expressly consent to have your data transferred to and processed in the United States. Further, we do not knowingly accept, request, or solicit information from children or knowingly market to children. Therefore, in accordance with the U.S. Children Online Privacy Protection Act, if we receive actual knowledge that anyone under the age of 13 has provided personal information to us without the requisite and verifiable parental consent, we will delete that information from the Site as quickly as is reasonably practical.\n TERM AND TERMINATION: These Terms & Conditions shall remain in full force and effect while you use the Site. WITHOUT LIMITING ANY OTHER PROVISION OF THESE TERMS & CONDITIONS, WE RESERVE THE RIGHT TO, IN OUR SOLE DISCRETION AND WITHOUT NOTICE OR LIABILITY, DENY ACCESS TO AND USE OF THE SITE (INCLUDING BLOCKING CERTAIN IP ADDRESSES), TO ANY PERSON FOR ANY REASON OR FOR NO REASON, INCLUDING WITHOUT LIMITATION FOR BREACH OF ANY REPRESENTATION, WARRANTY, OR COVENANT CONTAINED IN THESE TERMS & CONDITIONS OR OF ANY APPLICABLE LAW OR REGULATION. WE MAY TERMINATE YOUR USE OR PARTICIPATION IN THE SITE OR DELETE [YOUR ACCOUNT AND] ANY CONTENT OR INFORMATION THAT YOU POSTED AT ANY TIME, WITHOUT WARNING, IN OUR SOLE DISCRETION. If we terminate or suspend your account for any reason, you are prohibited from registering and creating a new account under your name, a fake or borrowed name, or the name of any third party, even if you may be acting on behalf of the third party. In addition to terminating or suspending your account, we reserve the right to take appropriate legal action, including without limitation pursuing civil, criminal, and injunctive redress. \n MODIFICATIONS AND INTERRUPTIONS: We reserve the right to change, modify, or remove the contents of the Site at any time or for any reason at our sole discretion without notice. However, we have no obligation to update any information on our Site. We also reserve the right to modify or discontinue all or part of the Site without notice at any time. We will not be liable to you or any third party for any modification, price change, suspension, or discontinuance of the Site. We cannot guarantee the Site will be available at all times. We may experience hardware, software, or other problems or need to perform maintenance related to the Site, resulting in interruptions, delays, or errors. We reserve the right to change, revise, update, suspend, discontinue, or otherwise modify the Site at any time or for any reason without notice to you. You agree that we have no liability whatsoever for any loss, damage, or inconvenience caused by your inability to access or use the Site during any downtime or discontinuance of the Site. Nothing in these Terms & Conditions will be construed to obligate us to maintain and support the Site or to supply any corrections, updates, or releases in connection therewith. \n GOVERNING LAW: These Terms & Conditions and your use of the Site are governed by and construed in accordance with the laws of the State of Lebanon applicable to agreements made and to be entirely performed within the State of Lebanon without regard to its conflict of law principles. \n DISPUTE RESOLUTION: Option 1: Any legal action of whatever nature brought by either you or us (collectively, the Parties and individually, a Party) shall be commenced or prosecuted in the County, Lebanon. Option 2: Informal Negotiations To expedite resolution and control the cost of any dispute, controversy, or claim related to these Terms & Conditions (each a Dispute and collectively, the Disputes) brought by either you or us (individually, a Party and collectively, the Parties), the Parties agree to first attempt to negotiate any Dispute (except those Disputes expressly provided below) informally for at least 60 days before initiating arbitration. Such informal negotiations commence upon written notice from one Party to the other Party. Restrictions The Parties agree that any arbitration shall be limited to the Dispute between the Parties individually. To the full extent permitted by law, (a) no arbitration shall be joined with any other proceeding; (b) there is no right or authority for any Dispute to be arbitrated on a class-action basis or to utilize class action procedures; and (c) there is no right or authority for any Dispute to be brought in a purported representative capacity on behalf of the general public or any other persons. CORRECTIONS There may be information on the Site that contains typographical errors, inaccuracies, or omissions that may relate to the Site, including descriptions, pricing, availability, and various other information. We reserve the right to correct any errors, inaccuracies, or omissions and to change or update the information on the Site at any time, without prior notice. DISCLAIMER THE SITE IS PROVIDED ON AN AS-IS AND AS-AVAILABLE BASIS. YOU AGREE THAT YOUR USE OF THE SITE SERVICES WILL BE AT YOUR SOLE RISK. TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH THE SITE AND YOUR USE THEREOF, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. WE MAKE NO WARRANTIES OR REPRESENTATIONS ABOUT THE ACCURACY OR COMPLETENESS OF THE SITE CONTENT OR THE CONTENT OF ANY WEBSITES LINKED TO THIS SITE AND WE WILL ASSUME NO LIABILITY OR RESPONSIBILITY FOR ANY (1) ERRORS, MISTAKES, OR INACCURACIES OF CONTENT AND MATERIALS, (2) PERSONAL INJURY OR PROPERTY DAMAGE, OF ANY NATURE WHATSOEVER, RESULTING FROM YOUR ACCESS TO AND USE OF THE SITE, (3) ANY UNAUTHORIZED ACCESS TO OR USE OF OUR SECURE SERVERS AND/OR ANY AND ALL PERSONAL INFORMATION AND/OR FINANCIAL INFORMATION STORED THEREIN, (4) ANY INTERRUPTION OR CESSATION OF TRANSMISSION TO OR FROM THE SITE, (5) ANY BUGS, VIRUSES, TROJAN HORSES, OR THE LIKE WHICH MAY BE TRANSMITTED TO OR THROUGH THE SITE BY ANY THIRD PARTY, AND/OR (6) ANY ERRORS OR OMISSIONS IN ANY CONTENT AND MATERIALS OR FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF THE USE OF ANY CONTENT POSTED, TRANSMITTED, OR OTHERWISE MADE AVAILABLE VIA THE SITE. WE DO NOT WARRANT, ENDORSE, GUARANTEE, OR ASSUME RESPONSIBILITY FOR ANY PRODUCT OR SERVICE ADVERTISED OR OFFERED BY A THIRD PARTY THROUGH THE SITE, ANY HYPERLINKED WEBSITE, OR ANY WEBSITE OR MOBILE APPLICATION FEATURED IN ANY BANNER OR OTHER ADVERTISING, AND WE WILL NOT BE A PARTY TO OR IN ANY WAY BE RESPONSIBLE FOR MONITORING ANY TRANSACTION BETWEEN YOU AND ANY THIRD-PARTY PROVIDERS OF PRODUCTS OR SERVICES. AS WITH THE PURCHASE OF A PRODUCT OR SERVICE THROUGH ANY MEDIUM OR IN ANY ENVIRONMENT, YOU SHOULD USE YOUR BEST JUDGMENT AND EXERCISE CAUTION WHERE APPROPRIATE.LIMITATIONS OF LIABILITY IN NO EVENT WILL WE OR OUR DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL, SPECIAL, OR PUNITIVE DAMAGES, INCLUDING LOST PROFIT, LOST REVENUE, LOSS OF DATA, OR OTHER DAMAGES ARISING FROM YOUR USE OF THE SITE, EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. INDEMNIFICATION:  You agree to defend, indemnify, and hold us harmless, including our subsidiaries, affiliates, and all of our respective officers, agents, partners, and employees, from and against any loss, damage, liability, claim, or demand, including reasonable at fees and expenses, made by any third party due to or arising out of: (1) your Contributions; (2) use of the Site; (3) breach of these Terms & Conditions; (4) any breach of your representations and warranties set forth in these Terms & Conditions; (5) your violation of the rights of a third party, including but not limited to intellectual property rights; or (6) any overt harmful act toward any other user of the Site with whom you connected via the Site. Notwithstanding the foregoing, we reserve the right, at your expense, to assume the exclusive defense and control of any matter for which you are required to indemnify us, and you agree to cooperate, at your expense, with our defense of such claims. We will use reasonable efforts to notify you of any such claim, action, or proceeding which is subject to this indemnification upon becoming aware of it. \n USER DATA: We will maintain certain data that you transmit to the Site for the purpose of managing the Site, as well as data relating to your use of the Site. Although we perform regular routine backups of data, you are solely responsible for all data that you transmit or that relates to any activity you have undertaken using the Site. You agree that we shall have no liability to you for any loss or corruption of any such data, and you hereby waive any right of action against us arising from any such loss or corruption of such data. ELECTRONIC COMMUNICATIONS, TRANSACTIONS, AND SIGNATURES Visiting the Site, sending us emails, and completing online forms constitute electronic communications. You consent to receive electronic communications, and you agree that all agreements, notices, disclosures, and other communications we provide to you electronically, via email and on the Site, satisfy any legal requirement that such communication is in writing. YOU HEREBY AGREE TO THE USE OF ELECTRONIC SIGNATURES, CONTRACTS, ORDERS, AND OTHER RECORDS, AND TO ELECTRONIC DELIVERY OF NOTICES, POLICIES, AND RECORDS OF TRANSACTIONS INITIATED OR COMPLETED BY US OR VIA THE SITE. You hereby waive any rights or requirements under any statutes, regulations, rules, ordinances, or other laws in any jurisdiction which require an original signature or delivery or retention of non-electronic records, or to payments or the granting of credits by any means other than electronic means. \n MISCELLANEOUS: These Terms & Conditions and any policies or operating rules posted by us on the Site constitute the entire agreement and understanding between you and us. Our failure to exercise or enforce any right or provision of these Terms & Conditions shall not operate as a waiver of such right or provision. These Terms & Conditions operate to the fullest extent permissible by law. We may assign any or all of our rights and obligations to others at any time. We shall not be responsible or liable for any loss, damage, delay, or failure to act caused by any cause beyond our reasonable control. If any provision or part of a provision of these Terms & Conditions is determined to be unlawful, void, or unenforceable, that provision or part of the provision is deemed severable from these Terms & Conditions and does not affect the validity and enforceability of any remaining provisions. There is no joint venture, partnership, employment or agency relationship created between you and us as a result of these Terms & Conditions or use of the Site. You agree that these Terms & Conditions will not be construed against us by virtue of having drafted them. You hereby waive any and all defenses you may have based on the electronic form of these Terms & Conditions and the lack of signing by the parties hereto to execute these Terms & Conditions."
                    let faqArray: [FAQ] = []
//                    let faqData = data["faq"]
//                    for faq in faqData{
//                        let faqQuestion = faq.1["question"].stringValue
//                        let faqAnswer = faq.1["answer"].stringValue
//                        let faqObject = FAQ(title: faqQuestion, body: faqAnswer)
//                        faqArray.append(faqObject)
//                    }
 
                    let helpQuestionArray: [FAQ] = []
                    
                    let page = Page(privacy: FAQ(title: privacyTitle, body: privacyText), terms: FAQ(title: termsTitle, body: termsText), faq: faqArray, helpTitle: "", helpText: "", helpQuestion: helpQuestionArray)
                    
                    completion("",page,200)
                    
         
    }
    
    
    //Get About page:
    func getSchoolInfo(completion: @escaping(_ message: String?, _ data: AboutInfo?, _ status: Int)->Void){
        let params: Parameters = [:]
        
        self.manager.request("https://lts.madrasatie.com/activation/get_school_url", method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    let schoolData = json["data"]
                    let data = schoolData["data"]

                    let status = json["statusCode"].intValue
                    let message = json["statusMessage"].stringValue
                    
                    let website = data["website"].stringValue
                    let location = data["location"].stringValue
                    let lat = data["lat"].doubleValue
                    let long = data["lng"].doubleValue
                    let phone = data["phone"].stringValue
                    let socialArray = [
                    Social(id: 1, name: "Facebook", icon: "about-fb", link: data["facebook"].stringValue),
                    Social(id: 2, name: "Twitter", icon: "about-twitter", link: data["twitter"].stringValue),
                    Social(id: 3, name: "LinkedIn", icon: "about-linkedin", link: data["linkedin"].stringValue),
                    Social(id: 4, name: "Google Plus", icon: "about-google", link: data["google"].stringValue),
                    Social(id: 5, name: "Instagram", icon: "about-insta", link: data["instagram"].stringValue)
                    ]
                    
                    let info = AboutInfo(website: website, direction: location, lat: lat, long: long, phoneNumber: phone, social: socialArray)
                    completion(message,info,status)
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
    }
    
    //Attendance TimeTable API:
    func getAttendanceTimeTable(user: User, theme: [SubjectTheme], date: Date, completion: @escaping(_ message: String?, _ result: [Period]?, _ status: Int?)->Void){
        var timeTableURL = ""
        if user.userType == 2{
            timeTableURL = "\(TIMETABLE_URL)/get_teacher_timetable?teacher_id=77"
        }else{
            timeTableURL = "\(TIMETABLE_URL)/get_student_timetable?section_id=1"
        }
        
        var params = ["":""]
        
        print("called called timetable")
        
//        if user.userType == 4{
//            params = [
//                "username": "\(user.admissionNo)",
//                "token": "\(user.token)",
//            ]
//        }else{
//            params = [
//                "username": "\(user.userName)",
//                "token": "\(user.token)",
//            ]
//        }
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        self.manager.request(timeTableURL, method: .get, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                    .responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("getAttendanceTimeTable", json)
                        #endif
                        let message = json["message"].stringValue
                        let status = 200
                        let data = json["response"]
                        
                        if status == 200{
                            var selectedDayId: Int = 0
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "EEEE"
                            let weekDay = dateFormatter.string(from: date)
                            
                            switch weekDay{
                            case "Monday":
                                selectedDayId = 1
                            case "Tuesday":
                                selectedDayId = 2
                            case "Wednesday":
                                selectedDayId = 3
                            case "Thursday":
                                selectedDayId = 4
                            case "Friday":
                                selectedDayId = 5
                            case "Saturday":
                                selectedDayId = 6
                            default:
                                selectedDayId = 7
                            }
                            
                            var periodArray: [Period] = []
                            
                            for weekday in data{
                                let periodData = weekday.1["schedule"]
                                for period in periodData{
                                    let time = period.1["scheduled_time"].stringValue
                                    let subjectId = period.1["subject_id"].stringValue
                                    let periodId = period.1["id"].intValue
                                    let subjectCode = period.1["subject_name"].stringValue
                                    let subjectName = period.1["subject_name"].stringValue
                                    let classCode = weekday.1["class_name"].stringValue
                                    let endTime = weekday.1["end_time"].stringValue
                                    let dayName = period.1["week_day"].stringValue
                                    
                                    var dayId = 0

                                    switch dayName{
                                    case "Monday":
                                        dayId = 1
                                    case "Tuesday":
                                        dayId = 2
                                    case "Wednesday":
                                        dayId = 3
                                    case "Thursday":
                                        dayId = 4
                                    case "Friday":
                                        dayId = 5
                                    case "Saturday":
                                        dayId = 6
                                    default:
                                        dayId = 7
                                    }
                                    
                                    let subjectIcon = weekday.1["imperium_code"].stringValue
                                    
                                   
                                    
                                    var dateString = ""
                                    if dayId < selectedDayId{
                                        let difference = selectedDayId - dayId
                                        let periodDate = Calendar.current.date(byAdding: .day, value: 7 - difference, to: date)
                                        dateString = self.formatter.string(from: periodDate!)
                                    }else{
                                        let difference = dayId - selectedDayId
                                        let periodDate = Calendar.current.date(byAdding: .day, value: difference, to: date)
                                        dateString = self.formatter.string(from: periodDate!)
                                    }
                                    
                                    let periodObject = Period(dayId: dayId, date: dateString, subjectId: subjectId, periodId: periodId, subjectName: subjectName, subjectIcon: subjectIcon, subjectCode: subjectCode, time: time, classCode: classCode, selected: false, endTime: endTime, dayName: dayName)
                                        periodArray.append(periodObject)
                                }
                            }
                            
                            completion(message,periodArray,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
       
    }
    
    //Add Remark API:
    func addRemark(user: User, remark: CreateRemark, date: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let addRemarkURL = "\(baseURL!)/api/remarks/add_remark"
        
        var students = ""
        let studentsArray = remark.students.map({return $0.id})
        for (index, student) in studentsArray.enumerated(){
            if studentsArray.count > 1{
                if index == 0{
                    students = "\(student)"
                }else{
                    students = "\(students),\(student)"
                }
            }else{
                students = student
            }
        }

        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "subject": "\(remark.subject)",
            "text": "\(remark.remarkText)",
            "reference_id": "\(remark.id)",
            "date": "\(date)",
            "students": "\(students)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
//            var students: [String] = []
//            for student in remark.students{
//                students.append(student.id)
//            }
//
//            do {
//                let studentData = try JSONSerialization.data(withJSONObject: students, options: .prettyPrinted)
//                var students = String(data: studentData, encoding: .utf8)
//                students = students?.replacingOccurrences(of: "\n", with: "")
//                multipartFormData.append((students ?? "").data(using: .utf8)!, withName: "students")
//            }
//            catch {
//
//            }
            
//            for student in students.map({return "\($0)"}) {
//                multipartFormData.append(student.data(using: .utf8)!, withName: "students")
//            }

        }, to: addRemarkURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,data,status)
                        }

                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Get Remark List API:
    func getRemarkList(user: User, completion: @escaping(_ message: String?, _ result: [RemarkCategory]?, _ status: Int?)->Void){
        let url = App.getSchoolActivation(schoolID: user.schoolId)
        let addRemarkURL = "\(url?.schoolURL ?? baseURL!)/api/remarks/get_remarks_list"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: addRemarkURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        var remarkCategory: [RemarkCategory] = []
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            let remarksData = data["remarks"]
                            for category in remarksData{
                                let categoryId = category.1["category_id"].intValue
                                let categoryName = category.1["category"].stringValue
                                let remarks = category.1["remarks"]
                                var remarkList: [RemarkList] = []
                                for remark in remarks{
                                    let text = remark.1["text"].stringValue
                                    let positive = remark.1["positive"].boolValue
                                    let referenceId = remark.1["reference_id"].intValue
                                    
                                    let remarkObject = RemarkList.init(id: referenceId, text: text, positive: positive)
                                    remarkList.append(remarkObject)
                                }
                                let categoryObject = RemarkCategory.init(id: categoryId, name: categoryName, remarks: remarkList, color: "#c842f4")
                                remarkCategory.append(categoryObject)
                            }
                            
                            completion(message,remarkCategory,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Get Remark Students API:
    func getRemarkStudent(user: User, sectionId: Int, completion: @escaping(_ message: String?, _ result: [Student]?, _ status: Int?)->Void){
        let getStudentURL = "\(baseURL!)/api/user/get_section_students"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "section_id": "\(sectionId)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: getStudentURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        var studentsArray: [Student] = []
                        
                        let json = JSON(j)
                        print("getRemarkStudent", json)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            let studentsData = data["student_details"]
                            for student in studentsData{
                                var name = student.1["name"].stringValue
                                let admissionNo = student.1["admission_no"].stringValue
                                let photo = student.1["photo_link"].stringValue
                                var gender = student.1["gender"].stringValue
                                if gender.isEmpty{
                                    gender = "m"
                                }
                                name = name.capitalized
                                if name.isEmpty{
                                    name = " "
                                }
                                let studentObject = Student(index: "\(name.first!)", id: admissionNo, fullName: name, photo: photo, mark: 0, selected: false, gender: gender, parent: false)
                                studentsArray.append(studentObject)
                            }
                            
                            completion(message,studentsArray,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    // get department employees API:
    //Get Remark Students API:
       func getDepartmentEmployees(user: User, departmentId: Int, completion: @escaping(_ message: String?, _ result: [Student]?, _ status: Int?)->Void){
           let getStudentURL = "\(baseURL!)/api/user/get_department_employees"
           
           let params = [
               "username": "\(user.userName)",
               "token": "\(user.token)",
               "department_id": "\(departmentId)",
           ]
           
           self.manager.upload(multipartFormData: {
               multipartFormData in
               for (key, value) in params{
                   multipartFormData.append(value.data(using: .utf8)!, withName: key)
               }
               
           }, to: getStudentURL, encodingCompletion: {
               (result) in
               switch result {
               case .success(let upload, _, _):
                   upload.responseJSON {
                       response in
                       switch response.result {
                       case .success(let j):
                           var studentsArray: [Student] = []
                           
                           let json = JSON(j)
                           print("getDepartmentEmployees", json)
                           let message = json["statusMessage"].stringValue
                           let status = json["statusCode"].intValue
                           let data = json["data"]
                           if status == 200{
                               let studentsData = data["student_details"]
                               for student in studentsData{
                                   var name = student.1["name"].stringValue
                                   let admissionNo = student.1["employee_number"].stringValue
                                   let photo = student.1["photo_link"].stringValue
                                   var gender = student.1["gender"].stringValue
                                   if gender.isEmpty{
                                       gender = "m"
                                   }
                                   name = name.capitalized
                                   if name.isEmpty{
                                       name = " "
                                   }
                                let studentObject = Student(index: "\(name.first!)", id: admissionNo, fullName: name, photo: photo, mark: 0, selected: false, gender: gender, parent: false)
                                   studentsArray.append(studentObject)
                               }
                               
                               completion(message,studentsArray,status)
                           }else{
                               let errorMessage = data["error_msgs"].stringValue
                               self.reportError(message: errorMessage)
                               completion(errorMessage,[],status)
                           }
                           
                       case .failure(let error):
                       
                           if error._code == NSURLErrorTimedOut {
                               completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                           }
                           else if error._code == NSFileNoSuchFileError {
                               completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                           }
                           else {
                               completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                           }
                       }
                   }
               case .failure(let error):
                       
                   if error._code == NSURLErrorTimedOut {
                       completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                   }
                   else if error._code == NSFileNoSuchFileError {
                       completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                   }
                   else {
                       completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                   }
               }
           })
       }
       
    
    
    //Delete Occasion API:
    func deleteOccasion(user: User, occasionId: Int, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.token)",
            "Content-Type": "application/json"
        ]
    
        self.manager.request("\(CALENDAR_EVENTS_URL)/delete_event?user_id=\(user.userId)&event_id=\(occasionId)", method: .get, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                    .responseJSON { response in
                        switch response.result{
                        case .success(let j):
                            let json = JSON(j)
                            print("delete calendar events new: \(json)")
                            let data = json["response"]
                            let status = 200
                            let message = json["message"].stringValue
                            print(data)
                            
           
                            
                            completion(message,json,status)
        
                        case .failure(let error):
        
                            let schoolData = SchoolActivation(id: 0, logo: "", schoolURL: "", schoolId: "", name: "", website: "", location: "", lat: 0.0, long: 0.0, facebook: "", twitter: "", linkedIn: "", google: "", instagram: "", phone: "", code: "")
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                }
        
    }
    
    //Sections Data:
    func getSections(user: User, completion: @escaping(_ message: String?, _ sectionData: [Class]?, _ status: Int?)->Void){
        let getSectionsURL = "\(baseURL!)/api/calendar/get_sections_and_departments"
                
        let params = [
            "token": "\(user.token)",
            "username": "\(user.userName)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
        }, to: getSectionsURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        var sectionsArray: [Class] = []
                        
                        let json = JSON(j)
                        #if DEBUG
                            print("getsections ", json)
                        #endif
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200 {
                            let sections = data["sections"]
                            for object in sections{
                                let id = object.1["id"].intValue
                                let name = object.1["name"].stringValue
                                let code = object.1["imperium_code"].stringValue
                                let section = Class.init(batchId: id, className: name, imperiumCode: code)
                                sectionsArray.append(section)
                            }
                            
                            completion(message,sectionsArray,status)
                            } else {
                                // Failed server response
                                let error = JSON(j)
                                let statusCode = response.response?.statusCode
                                let description = error["error_msgs"].stringValue
                                self.reportError(message: description)
                                completion(description,[],statusCode)
                            }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
        
    }
    
    //Sections Data:
//        func getSectionsPerModule(user: User, completion: @escaping(_ message: String?, _ sectionData: [ClassPerModule]?, _ status: Int?)->Void){
//            let getSectionsURL = "https://lts.madrasatie.com/api/calendar/get_sections_per_module"
//
//            let params = [
//                "token": "5a45b3a54f727a7b13f23c36ff6e66149c0d9de2d32ebd6253988cf07d4e744e",
//                "username": "E125",
//            ]
//
//            #if DEBUG
//                print("getsectionspermoduleparams ", params)
//            #endif
//
//            self.manager.upload(multipartFormData: {
//                multipartFormData in
//                for (key, value) in params{
//                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
//                }
//            }, to: getSectionsURL, encodingCompletion: {
//                (result) in
//                switch result {
//                case .success(let upload, _, _):
//                    upload.responseJSON {
//                        response in
//                        switch response.result {
//                        case .success(let j):
//                            var sectionsArray: [ClassPerModule] = []
//                            let json = JSON(j)
//                            #if DEBUG
//                                print("getsectionspermodule ", json)
//                            #endif
//                            let message = json["statusMessage"].stringValue
//                            let status = json["statusCode"].intValue
//                            let data = json["data"]["sections"]
//                            if status == 200 {
//                                //calendar
//                                for object in data["1"]{
//                                    let id = object.1["id"].intValue
//                                    let name = object.1["name"].stringValue
//                                    let code = object.1["imperium_code"].stringValue
//                                    let section = ClassPerModule.init(batchId: id, className: name, imperiumCode: code, module: 1, cayId: 0, cayCode: "", cayName: "", secId: 0, secCode: "", subjectId: 0, subjectCode: "", displayName: "")
//                                    sectionsArray.append(section)
//                                }
//
//                                //agenda
//                                for object in data["2"]{
//                                    let id = object.1["id"].intValue
//                                    let name = object.1["name"].stringValue
//                                    let code = object.1["imperium_code"].stringValue
//                                    let section = ClassPerModule.init(batchId: id, className: name, imperiumCode: code, module: 3, cayId: 0, cayCode: "", cayName: "", secId: 0, secCode: "", subjectId: 0, subjectCode: "", displayName: "")
//                                    sectionsArray.append(section)
//                                }
//
//                                //grades
//                                for object in data["3"]{
//                                    let id = object.1["id"].intValue
//                                    let name = object.1["name"].stringValue
//                                    let code = object.1["imperium_code"].stringValue
//                                    let section = ClassPerModule.init(batchId: id, className: name, imperiumCode: code, module: 5, cayId: 0, cayCode: "", cayName: "", secId: 0, secCode: "", subjectId: 0, subjectCode: "", displayName: "")
//                                    sectionsArray.append(section)
//                                }
//
//                                //attendance
//                                for object in data["4"]{
//                                    let id = object.1["id"].intValue
//                                    let name = object.1["name"].stringValue
//                                    let code = object.1["imperium_code"].stringValue
//                                    let section = ClassPerModule.init(batchId: id, className: name, imperiumCode: code, module: 2, cayId: 0, cayCode: "", cayName: "", secId: 0, secCode: "", subjectId: 0, subjectCode: "", displayName: "")
//                                    sectionsArray.append(section)
//                                }
//
//                                //remarks
//                                for object in data["5"]{
//                                    let id = object.1["id"].intValue
//                                    let name = object.1["name"].stringValue
//                                    let code = object.1["imperium_code"].stringValue
//                                    let section = ClassPerModule.init(batchId: id, className: name, imperiumCode: code, module: 4, cayId: 0, cayCode: "", cayName: "", secId: 0, secCode: "", subjectId: 0, subjectCode: "", displayName: "")
//                                    sectionsArray.append(section)
//                                }
//
//                                completion(message,sectionsArray,status)
//                            } else {
//                                // Failed server response
//                                let errorMessage = data["error_msgs"].stringValue
//                                self.reportError(message: errorMessage)
//                                completion(errorMessage,[],status)
//                            }
//                        case .failure(let error):
//
//                            if error._code == NSURLErrorTimedOut {
//                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
//                            }
//                            else if error._code == NSFileNoSuchFileError {
//                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
//                            }
//                            else {
//                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
//                            }
//                        }
//                    }
//                case .failure(let error):
//
//                    if error._code == NSURLErrorTimedOut {
//                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
//                    }
//                    else if error._code == NSFileNoSuchFileError {
//                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
//                    }
//                    else {
//                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
//                    }
//                }
//            })
//
//        }

    
    func getSectionsPerModule(user: User, completion: @escaping(_ message: String?, _ sectionData: [ClassPerModule]?, _ status: Int?)->Void){
        let getSectionsURL = "\(GET_SCHOOL_URL)/get_employee_classes"
        

        var sectionsArray: [ClassPerModule] = []


        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header: \(headers)")
        var userRole = "admin"
        if(user.userType == 1){
            userRole = "admin"
        }
        else if(user.userType == 2){
            userRole = "teacher"
        }
        else if(user.userType == 3){
            userRole = "student"
        }
        else{
            userRole = "parent"
        }
        print("employee classes: \(GET_SCHOOL_URL)/get_employee_classes?employeeId=\(user.imperiumCode)&schoolId=\(user.schoolId)&userRole=\(userRole)")
        
        self.manager.request("\(GET_SCHOOL_URL)/get_employee_classes?employeeId=\(user.imperiumCode)&schoolId=\(user.schoolId)&userRole=\(userRole)", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    print("school activation1: \(json)")
                    let data = json["response"]
                    let status = 200
                    let message = json["message"].stringValue
                    print(data)
                    
                    if(user.userType == 1 || user.userType == 2){
                        for ay in data{
                            let classOfAcademicYears = ay.1["classOfAcademicYears"]
                            for cay in classOfAcademicYears{
                                let sections = cay.1["sections"]
                                let cayId = cay.1["id"].intValue
                                let cayName = cay.1["name"].stringValue
                                let cayCode = cay.1["code"].stringValue
                                for sec in sections{
                                    let secId = sec.1["id"].intValue
                                    let secCode = sec.1["code"].stringValue
                                    
                                    for subject in sec.1["subjects"]{
                                        let subjectId = subject.1["id"].intValue
                                        let subjectCode = subject.1["code"].stringValue
                                        let displayName = "\(cayName) - \(secCode)"
                                        
                                        
                                        let section = ClassPerModule.init(batchId: secId, className: "", imperiumCode: cayCode, module: 1, cayId: cayId,
                                                                          cayCode: cayCode, cayName: cayName, secId: secId, secCode: secCode, subjectId: subjectId, subjectCode: subjectCode, displayName: displayName)
                                        
                                        let section1 = ClassPerModule.init(batchId: secId, className: "", imperiumCode: cayCode, module: 2, cayId: cayId,
                                                                          cayCode: cayCode, cayName: cayName, secId: secId, secCode: secCode, subjectId: subjectId, subjectCode: subjectCode, displayName: displayName)
                                        
                                        let section2 = ClassPerModule.init(batchId: secId, className: "", imperiumCode: cayCode, module: 3, cayId: cayId,
                                                                          cayCode: cayCode, cayName: cayName, secId: secId, secCode: secCode, subjectId: subjectId, subjectCode: subjectCode, displayName: displayName)
                                        
                                        let section3 = ClassPerModule.init(batchId: secId, className: "", imperiumCode: cayCode, module: 4, cayId: cayId,
                                                                          cayCode: cayCode, cayName: cayName, secId: secId, secCode: secCode, subjectId: subjectId, subjectCode: subjectCode, displayName: displayName)
                                        
                                        let section4 = ClassPerModule.init(batchId: secId, className: "", imperiumCode: cayCode, module: 6, cayId: cayId,
                                                                          cayCode: cayCode, cayName: cayName, secId: secId, secCode: secCode, subjectId: subjectId, subjectCode: subjectCode, displayName: displayName)
                                        let found = sectionsArray.filter({$0.batchId == secId})
                                        if(found.isEmpty){
                                            sectionsArray.append(section)
                                            sectionsArray.append(section1)
                                            sectionsArray.append(section2)
                                            sectionsArray.append(section3)
                                            sectionsArray.append(section4)

                                        }
                                       

                                    }
                                }
                            }
                            
                        
                        
                        }
                    }
                    
                
                    
                    print("final final: \(sectionsArray)")
                    
                    completion(message,sectionsArray,status)
                    
                case .failure(let error):
                    
                    let schoolData = SchoolActivation(id: 0, logo: "", schoolURL: "", schoolId: "", name: "", website: "", location: "", lat: 0.0, long: 0.0, facebook: "", twitter: "", linkedIn: "", google: "", instagram: "", phone: "", code: "")
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,sectionsArray,App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,sectionsArray,App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,sectionsArray,App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
        
    }
    
    func getEmployeesByDepartment(user: User, departmentId: String, completion: @escaping(_ message: String?, _ departmentResult: [CalendarEventItem]?, _ status: Int?)->Void){
              
        var employeesArray: [CalendarEventItem] = []
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header: \(headers)")
        
        self.manager.request("\(GET_TEACHERS_URL)/get_employees_by_department/\(departmentId)", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    print("getEmployeeDepartments: \(json)")
                    let data = json["response"]
                    let status = 200
                    let message = json["message"].stringValue
                    print(data)
                    
                    for dep in data{
                        let id = dep.1["employee"]["userId"].intValue
                        let departmentId = dep.1["departmentId"].stringValue
                        let name = "\(dep.1["employee"]["user"]["firstName"].stringValue) \(dep.1["employee"]["user"]["lastName"].stringValue)"
                        let department = CalendarEventItem(id: "\(id)", title: departmentId, active: false, studentId: name)

                        employeesArray.append(department)
                        
                    }
                    
                    completion(message,employeesArray,status)
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
        
    }
    
    func getEmployeesByDepartment2(user: User, departmentId: String, completion: @escaping(_ message: String?, _ departmentResult: [Student]?, _ status: Int?)->Void){
              
        var employeesArray: [Student] = []
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header: \(headers)")
        
        self.manager.request("\(GET_TEACHERS_URL)/get_employees_by_department/\(departmentId)", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    print("getEmployeeDepartments: \(json)")
                    let data = json["response"]
                    let status = 200
                    let message = json["message"].stringValue
                    print(data)
                    
                    for dep in data{
                        let departmentId = dep.1["departmentId"].stringValue
                        let name = "\(dep.1["employee"]["user"]["firstName"].stringValue) \(dep.1["employee"]["user"]["lastName"].stringValue)"
                        let photo = dep.1["employee"]["user"]["profilePictureUrl"].stringValue
                        let gender = dep.1["employee"]["user"]["gender"].stringValue
                        let id = dep.1["employee"]["user"]["id"].stringValue


                        let user = Student(index: "0", id: id, fullName: name, photo: photo, mark: 0.0, selected: false, gender: gender, parent: false)
                        employeesArray.append(user)
                        
                    }
                    print("employeeArray: \(employeesArray)")
                    completion(message,employeesArray,status)
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
        
    }
    func getDepartments(user: User, completion: @escaping(_ message: String?, _ departmentResult: [CalendarEventItem]?, _ status: Int?)->Void){
              
        var departmentsArray: [CalendarEventItem] = []
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header: \(headers)")
        
        self.manager.request("\(GET_TEACHERS_URL)/get_departments_by_school/\(user.schoolId)", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    print("getDepartments: \(json)")
                    let data = json["response"]
                    let status = 200
                    let message = json["message"].stringValue
                    print(data)
                    
                    for dep in data{
                        let name = dep.1["name"].stringValue
                        let schoolId = dep.1["school_id"].intValue
                        let id = dep.1["id"].intValue
                        
                        let department = CalendarEventItem(id: "\(id)", title: name, active: false, studentId: "")
                        departmentsArray.append(department)
                    }
                    
                    
                    
                    completion(message,departmentsArray,status)
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
        
    }
    
    func getSections(user: User, completion: @escaping(_ message: String?, _ sectionResult: [CalendarEventItem]?, _ status: Int?)->Void){
              
        var sectionsArray: [CalendarEventItem] = []

        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header: \(headers)")
        
        self.manager.request("\(GET_SCHOOL_URL)/classofacademicyears/\(user.schoolId)", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    let data = json["response"]
                    let status = 200
                    let message = json["message"].stringValue
                    print(data)
                    
                    for cls in data{
                        let sections = cls.1["sections"]
                        for section in sections{
                            let name = "\(cls.1["code"].stringValue) - \(section.1["code"].stringValue)"
                            let schoolId = section.1["school_id"].intValue
                            let id = section.1["id"].intValue
                            
                            let sec = CalendarEventItem(id: "\(id)", title: name, active: false, studentId: "")
                            sectionsArray.append(sec)
                        }
                        
                    }
                    
                    print("getClassSections: \(sectionsArray)")

                    
                    
                    
                    completion(message,sectionsArray,status)
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
        
    }
    
    func getStudentsBySection(user: User, sectionId: String, completion: @escaping(_ message: String?, _ sectionResult: [CalendarEventItem]?, _ status: Int?)->Void){
              
        var sectionsArray: [CalendarEventItem] = []

        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header: \(headers)")
        
        self.manager.request("\(GET_STUDENTS_URL)/student_view_by_section?sectionId=\(sectionId)", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    let data = json["response"]
                    let status = 200
                    let message = json["message"].stringValue
                    print(data)
                    
                    for std in data{
                        let id = std.1["userId"].intValue
                        let sectionId = std.1["sectionId"].stringValue
                        let studentName = "\(std.1["user"]["firstName"].stringValue) \(std.1["user"]["lastName"].stringValue)"
                        let sec = CalendarEventItem(id: "\(id)", title: sectionId, active: false, studentId: studentName)
                        sectionsArray.append(sec)

                    }
                    
                    print("getClassSections: \(sectionsArray)")
                    
                    completion(message,sectionsArray,status)
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
        
    }
    
    func getParentsBySection(user: User, sectionId: String, completion: @escaping(_ message: String?, _ sectionResult: [CalendarEventItem]?, _ status: Int?)->Void){
              
        var sectionsArray: [CalendarEventItem] = []

        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header: \(headers)")
        
        self.manager.request("\(GET_STUDENTS_URL)/  ?sectionId=\(sectionId)", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    let data = json["response"]
                    let status = 200
                    let message = json["message"].stringValue
                    print(data)
                    
                    for std in data{
                        let id = std.1["userId"].intValue
                        let sectionId = std.1["sectionId"].stringValue
                        let sec = CalendarEventItem(id: "\(id)", title: sectionId, active: false, studentId: "")
                        sectionsArray.append(sec)

                    }
                    
                    print("getClassSections: \(sectionsArray)")
                    
                    completion(message,sectionsArray,status)
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
        
    }
    
    
    func getStudentsBySection2(user: User, sectionId: String, completion: @escaping(_ message: String?, _ sectionResult: [Student]?, _ status: Int?)->Void){
              
        var sectionsArray: [Student] = []

        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("header header: \(headers)")
        
        self.manager.request("\(GET_STUDENTS_URL)/student_view_by_section?sectionId=\(sectionId)", method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    let data = json["response"]
                    let status = 200
                    let message = json["message"].stringValue
                    print(data)
                    
                    for std in data{
                        
                        let name = "\(std.1["user"]["firstName"].stringValue) \(std.1["user"]["lastName"].stringValue)"
                        let photo = std.1["user"]["profilePictureUrl"].stringValue
                        let gender = std.1["user"]["gender"].stringValue
                        let id = std.1["user"]["id"].stringValue

                        let user = Student(index: "0", id: id, fullName: name, photo: photo, mark: 0.0, selected: false, gender: gender, parent: false)
                        sectionsArray.append(user)

                    }
                    
                    print("getClassSections: \(sectionsArray)")
                    
                    completion(message,sectionsArray,status)
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
        
    }
    
    
    //Get Terms API:
    func getTerms(user: User, completion: @escaping(_ message: String?, _ result: [GradesTerm]?, _ status: Int?)->Void){
        let getStudentURL = "\(baseURL!)/api/grades/get_terms"
        
        var params = ["":""]
        if user.userType == 4{
            params = [
                "student_username": "\(user.admissionNo)",
                "token": "\(user.token)",
            ]
        }else{
            params = [
                "student_username": "\(user.userName)",
                "token": "\(user.token)",
            ]
        }
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: getStudentURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            var termArray: [GradesTerm] = []
                            let termsArray = data["terms"]
                            for term in termsArray{
                                let name = term.1["name"].stringValue
                                let id = term.1["id"].intValue
                                let termObject = GradesTerm.init(id: id, name: name)
                                termArray.append(termObject)
                            }
                            completion(message,termArray,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    
    //Get Sub-Terms API:
    func getSubTerms(user: User, batchId: Int, completion: @escaping(_ message: String?, _ result: [GradesSubTerm]?, _ status: Int?)->Void){
        let getStudentURL = "\(baseURL!)/api/grades/get_sub_terms"

        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "section_id": "\(batchId)",
        ]

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }

        }, to: getStudentURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            var subTermArray: [GradesSubTerm] = []
                            let subTermsArray = data["sub_terms"]
                            for subTerm in subTermsArray{
                                let code = subTerm.1["code"].stringValue
                                let termId = subTerm.1["term"].intValue
                                let published = subTerm.1["result_published"].boolValue
                                let name = subTerm.1["name"].stringValue
                                let id = subTerm.1["id"].stringValue
                                let subTermObject = GradesSubTerm.init(code: code, termId: termId, published: published, name: name, id: id)
                                subTermArray.append(subTermObject)
                            }
                            completion(message,subTermArray,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }

                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Get Calendar Data:
    func getGradeSettings(user: User, sectionId: Int, completion: @escaping(_ message: String?, _ result: JSON, _ status: Int?)->Void){
       
        let gradesUrl: String = "\(GRADEBOOK_URL)/gradingSettings/settings/get?section_id=\(sectionId)"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.token)",
            "Content-Type": "application/json"
        ]
    
        self.manager.request(gradesUrl, method: .get, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                    .responseJSON { response in
                        switch response.result{
                        case .success(let j):
                            let json = JSON(j)
                            print("get grade settings events new: \(json)")
                            let data = json["response"]
                            let status = 200
                            let message = json["message"].stringValue
                            print(data)
                            let events = data["events"]
                            
                            var eventData: [Event] = []
                            var duesArray: [EventDetail] = []
                            var eventsArray: [EventDetail] = []
                            var holidaysArray: [EventDetail] = []
                            
                            
                            
                     
                            completion(message,data,status)
        
                        case .failure(let error):
        
                            let schoolData = SchoolActivation(id: 0, logo: "", schoolURL: "", schoolId: "", name: "", website: "", location: "", lat: 0.0, long: 0.0, facebook: "", twitter: "", linkedIn: "", google: "", instagram: "", phone: "", code: "")
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                }
    }
    
    //Get Calendar Data:
    func getGrades(user: User, sectionId: Int, fullMark: String, theme: AppTheme, completion: @escaping(_ message: String?, _ result: [TermAverage]?, _ status: Int?)->Void){
       
        let gradesUrl: String = "\(GRADEBOOK_URL)/reportCard/get?studentId=\(user.admissionNo)&schoolId=\(user.schoolId)&sectionId=\(sectionId)&fullMark=\(fullMark)"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(user.token)",
            "Content-Type": "application/json"
        ]
    
        print("get grade settings events new2: \(gradesUrl)")

        self.manager.request(gradesUrl, method: .get, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                    .responseJSON { response in
                        switch response.result{
                        case .success(let j):

                            let json = JSON(j)
                            print("==>userGrades: \(json)")
                            let message = json["message"].stringValue
                            let status = 200
                            let data = json["response"]["results"]
                            let subGroupsTotal = json["response"]["subjectGroups"]
                            print("data data: \(data)")
                            var totalSubjectsWeight = Float(0.0)
                            if status == 200{
                                var subjectArrayTemp: [SubjectHeaderItem] = []
                                
                                for subject in subGroupsTotal{
                                    
                                
                                    let code = subject.1["name"].stringValue
                                    //here
                                    let name = subject.1["name"].stringValue
                                    //                                        let name = subject.1["subject_name"].stringValue
                                    let mark = subject.1["monthly_average"].floatValue
                                    let id = subject.1["id"].stringValue
                                    let subjectFullMark = subject.1["fullMark"].floatValue
                                    let checked = false
                                    
                                    var color = ""
                                    var icon = ""
                                    let subjectTheme = theme.subjectTheme.filter({$0.code == code})
                                    if !subjectTheme.isEmpty{
                                        color = subjectTheme.first!.bg
                                        icon = subjectTheme.first!.icon
                                    }
                                    //                                        if color.isEmpty{
                                    color = "#fa487a"
                                    //                                        }
                                    
                                    var subSubjectArray: [SubSubjectItem] = []
                                    let subSubjectData = subject.1["subjects"]
                                    print("subSubjects subSubjects: \(subSubjectData)")
                                    
                                    for subSubject in subSubjectData{
                                        let name = subSubject.1["name"].stringValue
                                        //                                            let name = subSubject.1["title"].stringValue
                                        let mark = subSubject.1["weight"].floatValue
                                        totalSubjectsWeight += mark
                                        let id = subSubject.1["id"].stringValue
                                        let subFullMark = subSubject.1["weight"].floatValue
                                        
                                        var subTermArray: [SubTerm] = []
                                        
                                        let subTermData = subSubject.1["assessments"]
                                        //                                                for quiz in subTermData{
                                        //                                                    let name = quiz.1["name"].stringValue
                                        //                                                    let mark = quiz.1["mark"].floatValue
                                        //                                                    let id = quiz.1["id"].stringValue
                                        //                                                    let fullMark = quiz.1["full_mark"].floatValue
                                        //
                                        //                                                    let quizObject = SubTerm.init(termId: id, termName: name, termsMark: Float(round(100*mark)/100), editable: false, published: false, fullMark: fullMark)
                                        //                                                    subTermArray.append(quizObject)
                                        //                                                }
                                        
                                        let subSubjectObject = SubSubjectItem.init(id: id, subName: name, subMark: Float(round(100*mark)/100), isOpen: false, editable: false, fullMark: subFullMark, terms: subTermArray)
                                        subSubjectArray.append(subSubjectObject)
                                    }
                                    
                                    let subjectObject = SubjectHeaderItem.init(id: id, subjectColor: color, subjectIcon: icon, subjectTitle: name, subjectMark: Float(round(100*mark)/100), subjectCode: code, fullMark: subjectFullMark, isOpen: false, checked: checked, editable: false, items: subSubjectArray)
                                    subjectArrayTemp.append(subjectObject)
                                }
                                
                                
                                
                                
                                
                                
                            var averageArray: [TermAverage] = []
                            for res in data{
                                let termData = res.1["terms"]
                                print("terms terms: \(termData)")
                                for term in termData{
                                   
                                    let average = 0.0
                                    let termCode = term.1["code"].stringValue
                                    let classAvg = 0.0
                                    let id = term.1["id"].stringValue
                                    let subTermsData = term.1["examGroups"]
                                    let termRemarkBody = term.1["remark_body"].stringValue
                                    let termRemarkTitle = term.1["remark_title"].stringValue
                                    let full_marks = term.1["full_marks"].floatValue
                                    //here
                                    let color = ""
                                    print("subterms subterms: \(subTermsData)")
                                    
                                    var termArray: [Term] = []
                                    for (index,subTerm) in subTermsData.enumerated(){
                                        let subAverage = subTerm.1["total_marks"].floatValue
                                        let totalSubjects = subTerm.1["total_weight"].floatValue
                                       
                                        let subCode = subTerm.1["name"].stringValue
                                        let subClassAvg = Float((subAverage * full_marks) / totalSubjects)
                                        let remarkTitle = subTerm.1["remark_title"].stringValue
                                        print("remark title: \(remarkTitle)")
                                        //here
                                        let subjectName = ""
                                        let teacher = ""
                                        //                                    let fullMark = subTerm.1["average_full_mark"].floatValue
                                        let remarkBody = subTerm.1["remark_body"].stringValue
                                        let remarkId = subTerm.1["id"].stringValue
                                        var color = ""
                                        switch index{
                                        case 0:
                                            color = theme.gradesTheme.subTerm_1
                                        case 1:
                                            color = theme.gradesTheme.subTerm_2
                                        case 2:
                                            color = theme.gradesTheme.subTerm_3
                                        case 3:
                                            color = theme.gradesTheme.subTerm_4
                                        case 4:
                                            color = theme.gradesTheme.subTerm_5
                                        case 5:
                                            color = theme.gradesTheme.subTerm_6
                                        default:
                                            color = theme.gradesTheme.allSubterms
                                        }
                                        
                                        let subjectGroupData = subTerm.1["subjectGroups"]
                                        var subjectArray: [SubjectHeaderItem] = []
                                        
                                        for subjectGroup in subjectGroupData{

                                            let subjectData = subjectGroup.1["subjects"]
                                            print("subjects subjects: \(subjectData)")
                                            let groupId = subjectGroup.1["id"].stringValue

                                            let foundSubjectGroup = subjectArrayTemp.first(where: { $0.id == groupId })

                                            for subject in subjectData {
                                                
                                                let code = subject.1["name"].stringValue
                                                //here
                                                let name = subject.1["name"].stringValue
                                                //                                        let name = subject.1["subject_name"].stringValue
                                                let mark = subject.1["monthly_average"].floatValue
                                                let id = subject.1["id"].stringValue
                                                
                                                
                                                print("found found: \(subjectArrayTemp)")

                                                var subjectFull: Float = 0.0
                                                
                                                
                                                let foundSubject = foundSubjectGroup?.items.first(where: { $0.id == id })
                                                if foundSubject != nil {
                                                    subjectFull = foundSubject?.fullMark ?? 0.0
                                                }
                                                
                                                if foundSubject != nil {
                                                    subjectFull = foundSubject?.fullMark ?? 0.0
                                                }
                                                
                                                let subjectFullMark = subjectFull
                                                let checked = false
                                                
                                                var color = ""
                                                var icon = ""
                                                let subjectTheme = theme.subjectTheme.filter({$0.code == code})
                                                if !subjectTheme.isEmpty{
                                                    color = subjectTheme.first!.bg
                                                    icon = subjectTheme.first!.icon
                                                }
                                                //                                        if color.isEmpty{
                                                color = "#fa487a"
                                                //                                        }
                                                
                                                var subSubjectArray: [SubSubjectItem] = []
                                                let subSubjectData = subject.1["subSubjects"]
                                                print("subSubjects subSubjects: \(subSubjectData)")
                                                
                                                for subSubject in subSubjectData{
                                                    let name = subSubject.1["name"].stringValue
                                                    //                                            let name = subSubject.1["title"].stringValue
                                                    let mark = subSubject.1["sub_subject_avg"].floatValue
                                                    let id = subSubject.1["id"].stringValue
                                                    let isPercentage = subSubject.1["is_percentage"].boolValue
                                                                                                        
                                                    var subFullMark: Float = 0.0
                                                    if(isPercentage == true){
                                                        subFullMark = subjectFullMark
                                                    }
                                                    else{
                                                        subFullMark = subSubject.1["sub_subject_total_weight"].floatValue
                                                    }
                                                    
                                                    var subTermArray: [SubTerm] = []
                                                    
                                                    print("check point: \(id)")
                                                    if(id == "null" || id == ""){
                                                        let subTermData = subSubject.1["assessments"]
                                                        for quiz in subTermData{
                                                            let name = quiz.1["name"].stringValue
                                                            let mark = quiz.1["student_mark"].floatValue
                                                            let id = quiz.1["id"].stringValue
                                                            var fullMark = quiz.1["full_mark"].floatValue
//                                                            if(isPercentage == true){
//                                                                fullMark = subjectFullMark
//                                                            }
//                                                            else{
//                                                                fullMark = quiz.1["full_mark"].floatValue
//                                                            }
                                                        
                                                            let subSubjectObject = SubSubjectItem.init(id: id, subName: name, subMark: Float(round(100*mark)/100), isOpen: false, editable: false, fullMark: fullMark, terms: subTermArray)
                                                            
                                                            print("samer grades: ")
                                                            print(subSubjectObject)
                                                            subSubjectArray.append(subSubjectObject)
                                                        }
                                                        
                                                      
                                                    }
                                                    else {
                                                        let subTermData = subSubject.1["assessments"]
                                                        for quiz in subTermData{
                                                            let name = quiz.1["name"].stringValue
                                                            let mark = quiz.1["student_mark"].floatValue
                                                            let id = quiz.1["id"].stringValue
                                                            let fullMark = quiz.1["full_mark"].floatValue
                                                        
                                                            let quizObject = SubTerm.init(termId: id, termName: name, termsMark: Float(round(100*mark)/100), editable: false, published: false, fullMark: fullMark)
                                                            subTermArray.append(quizObject)
                                                        }
                                                        
                                                        let subSubjectObject = SubSubjectItem.init(id: id, subName: name, subMark: Float(round(100*mark)/100), isOpen: false, editable: false, fullMark: subFullMark, terms: subTermArray)
                                                        subSubjectArray.append(subSubjectObject)
                                                    }
                                                    
                                                }
                                                
                                                let subjectObject = SubjectHeaderItem.init(id: id, subjectColor: color, subjectIcon: icon, subjectTitle: name, subjectMark: Float(round(100*mark)/100), subjectCode: code, fullMark: subjectFullMark, isOpen: false, checked: checked, editable: false, items: subSubjectArray)
                                                subjectArray.append(subjectObject)
                                                
                                            }
                                            
                                           
                                            
                                            
                                        }
                                        
                                        let termObject = Term.init(id: remarkId, name: subCode, avg: Float(round(100*subAverage)/100), classAvg: Float(round(100*subClassAvg)/100), remarkTile: remarkTitle, remarkBody: remarkBody, teacherName: teacher, subject: subjectName, color: color, selected: false, subjectsArray: subjectArray)
                                        termArray.append(termObject)
                                    }
                                   
                                    //All Subjects
                                    var allSubjects: [SubjectHeaderItem] = []
                                    let allSubjectsData = term.1["subjects"]
                                    for subject in allSubjectsData{
                                        let subjectName = subject.1["name"].stringValue
                                        let subjectCode = subject.1["code"].stringValue
                                        let subjectMark = subject.1["mark"].floatValue
                                        let subjectFullMark = subject.1["full_mark"].floatValue
                                        let subjectId = subject.1["id"].stringValue
                                        let subSubjectData = subject.1["sub_subjects"]
                                        
                                        var subSubjectArray: [SubSubjectItem] = []
                                        for subSubject in subSubjectData{
                                            let subSubjectName = subSubject.1["name"].stringValue
                                            let subSubjectMark = subSubject.1["mark"].floatValue
                                            let subSubjectFullMark = subSubject.1["full_mark"].floatValue
                                            let subSubjectId = subSubject.1["id"].stringValue
                                            let assessmentData = subSubject.1["assessments"]
                                            
                                            var assessmentArray: [SubTerm] = []
                                            for assessment in assessmentData{
                                                let name = assessment.1["name"].stringValue
                                                let mark = assessment.1["mark"].floatValue
                                                let fullMark = assessment.1["full_mark"].floatValue
                                                let id = assessment.1["id"].stringValue
                                                let assessmentObject = SubTerm.init(termId: id, termName: name, termsMark: mark, editable: false, published: false, fullMark: fullMark)
                                                assessmentArray.append(assessmentObject)
                                            }
                                            let subSubjectObject = SubSubjectItem.init(id: subSubjectId, subName: subSubjectName, subMark: Float(round(100*subSubjectMark)/100), isOpen: false, editable: false, fullMark: subSubjectFullMark, terms: assessmentArray)
                                            subSubjectArray.append(subSubjectObject)
                                        }
                                        // here: All Subjects Color and Icons:
                                        var subjectColor = ""
                                        let subjectIcon = subject.1["imperium_code"].stringValue
                                        let checked = false
                                        
                                        let subjectTheme = theme.subjectTheme.filter({$0.code == subjectCode})
                                        if !subjectTheme.isEmpty{
                                            subjectColor = subjectTheme.first!.bg
                                        }
                                        let subject = SubjectHeaderItem.init(id: subjectId, subjectColor: subjectColor, subjectIcon: subjectIcon, subjectTitle: subjectName, subjectMark: Float(round(100*subjectMark)/100), subjectCode: subjectCode, fullMark: subjectFullMark, isOpen: false, checked: checked, editable: false, items: subSubjectArray)
                                        allSubjects.append(subject)
                                    }
                                    
                                    let allSubTermColor = theme.gradesTheme.allSubterms
                                    for sub in allSubjects{
                                        print("subjects info: \(sub.subjectTitle)")
                                        print("subjects info: \(sub.subjectMark)")
                                    }
                                    let allTerm = Term.init(id: "0", name: "All", avg: Float(round(100*average)/100), classAvg: Float(round(100*classAvg)/100), remarkTile: "", remarkBody: "", teacherName: "", subject: "", color: allSubTermColor, selected: false, subjectsArray: allSubjects)
                                    termArray.append(allTerm)
                                    
                                    print("term code: \(termCode)")
                                    let subTermObject = TermAverage.init(id: id, name: termCode, average: Float(round(100*average)/100), classAverage: Float(round(100*classAvg)/100), values: termArray, color: color, termRemarkTitle: termRemarkTitle, termRemarkBody: termRemarkBody)
                                    averageArray.append(subTermObject)
                                }
                            }
                                completion(message,averageArray,status)
                            }else{
                                let errorMessage = data["error_msgs"].stringValue
                                self.reportError(message: errorMessage)
                                completion(errorMessage,[],status)
                            }
                            
                        case .failure(let error):
                        
                            if error._code == NSURLErrorTimedOut {
                                completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                            }
                            else if error._code == NSFileNoSuchFileError {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                            else {
                                completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                            }
                        }
                }
    }
    
    
    
    
    //Get Grades API:
//    func getGrades(user: User, studentUsername: String, theme: AppTheme, completion: @escaping(_ message: String?, _ result: [TermAverage]?, _ status: Int?)->Void){
//        let getStudentURL = "\(baseURL!)/api/grades/get_grades"
//
//        let params = [
//            "username": "\(user.userName)",
//            "token": "\(user.token)",
//            "student_username": "\(studentUsername)",
//        ]
//
//        self.manager.upload(multipartFormData: {
//            multipartFormData in
//            for (key, value) in params{
//                multipartFormData.append(value.data(using: .utf8)!, withName: key)
//            }
//
//        }, to: getStudentURL, encodingCompletion: {
//            (result) in
//            switch result {
//            case .success(let upload, _, _):
//                upload.responseJSON {
//                    response in
//                    switch response.result {
//                    case .success(let j):
//
//                        let json = JSON(j)
//                        print("==>userGrades: \(json)")
//                        let message = json["statusMessage"].stringValue
//                        let status = json["statusCode"].intValue
//                        let data = json["data"]
//                        if status == 200{
//                            var averageArray: [TermAverage] = []
//                            let termData = data["terms"]
//                            for term in termData{
//                                let average = term.1["average"].floatValue
//                                let termCode = term.1["code"].stringValue
//                                let classAvg = term.1["class_avg"].floatValue
//                                let id = term.1["id"].stringValue
//                                let subTermsData = term.1["sub_terms"]
//                                let termRemarkBody = term.1["remark_body"].stringValue
//                                let termRemarkTitle = term.1["remark_title"].stringValue
//                                //here
//                                let color = ""
//
//                                var termArray: [Term] = []
//                                for (index,subTerm) in subTermsData.enumerated(){
//                                    let subAverage = subTerm.1["average"].floatValue
//                                    let subCode = subTerm.1["code"].stringValue
//                                    let subClassAvg = subTerm.1["class_avg"].floatValue
//                                    let remarkTitle = subTerm.1["remark_title"].stringValue
//                                    print("remark title: \(remarkTitle)")
//                                    //here
//                                    let subjectName = ""
//                                    let teacher = ""
////                                    let fullMark = subTerm.1["average_full_mark"].floatValue
//                                    let remarkBody = subTerm.1["remark_body"].stringValue
//                                    let remarkId = subTerm.1["id"].stringValue
//                                    var color = ""
//                                    switch index{
//                                    case 0:
//                                        color = theme.gradesTheme.subTerm_1
//                                    case 1:
//                                        color = theme.gradesTheme.subTerm_2
//                                    case 2:
//                                        color = theme.gradesTheme.subTerm_3
//                                    case 3:
//                                        color = theme.gradesTheme.subTerm_4
//                                    case 4:
//                                        color = theme.gradesTheme.subTerm_5
//                                    case 5:
//                                        color = theme.gradesTheme.subTerm_6
//                                    default:
//                                        color = theme.gradesTheme.allSubterms
//                                    }
//
//                                    let subjectData = subTerm.1["subjects"]
//                                    var subjectArray: [SubjectHeaderItem] = []
//                                    for subject in subjectData{
//                                        let code = subject.1["code"].stringValue
//                                        //here
//                                        let name = subject.1["name"].stringValue
////                                        let name = subject.1["subject_name"].stringValue
//                                        let mark = subject.1["mark"].floatValue
//                                        let id = subject.1["id"].stringValue
//                                        let subjectFullMark = subject.1["full_mark"].floatValue
//                                        let checked = false
//
//                                        var color = ""
//                                        var icon = ""
//                                        let subjectTheme = theme.subjectTheme.filter({$0.code == code})
//                                        if !subjectTheme.isEmpty{
//                                            color = subjectTheme.first!.bg
//                                            icon = subjectTheme.first!.icon
//                                        }
////                                        if color.isEmpty{
//                                            color = "#fa487a"
////                                        }
//
//                                        var subSubjectArray: [SubSubjectItem] = []
//                                        let subSubjectData = subject.1["sub_subjects"]
//                                        for subSubject in subSubjectData{
//                                            let name = subSubject.1["name"].stringValue
////                                            let name = subSubject.1["title"].stringValue
//                                            let mark = subSubject.1["mark"].floatValue
//                                            let id = subSubject.1["id"].stringValue
//                                            let subFullMark = subSubject.1["full_mark"].floatValue
//
//                                            var subTermArray: [SubTerm] = []
//
//                                            let subTermData = subSubject.1["assessments"]
//                                            for quiz in subTermData{
//                                                let name = quiz.1["name"].stringValue
//                                                let mark = quiz.1["mark"].floatValue
//                                                let id = quiz.1["id"].stringValue
//                                                let fullMark = quiz.1["full_mark"].floatValue
//
//                                                let quizObject = SubTerm.init(termId: id, termName: name, termsMark: Float(round(100*mark)/100), editable: false, published: false, fullMark: fullMark)
//                                                subTermArray.append(quizObject)
//                                            }
//
//                                            let subSubjectObject = SubSubjectItem.init(id: id, subName: name, subMark: Float(round(100*mark)/100), isOpen: false, editable: false, fullMark: subFullMark, terms: subTermArray)
//                                            subSubjectArray.append(subSubjectObject)
//                                        }
//
//                                        let subjectObject = SubjectHeaderItem.init(id: id, subjectColor: color, subjectIcon: icon, subjectTitle: name, subjectMark: Float(round(100*mark)/100), subjectCode: code, fullMark: subjectFullMark, isOpen: false, checked: checked, editable: false, items: subSubjectArray)
//                                        subjectArray.append(subjectObject)
//                                    }
//
//                                    let termObject = Term.init(id: remarkId, name: subCode, avg: Float(round(100*subAverage)/100), classAvg: Float(round(100*subClassAvg)/100), remarkTile: remarkTitle, remarkBody: remarkBody, teacherName: teacher, subject: subjectName, color: color, selected: false, subjectsArray: subjectArray)
//                                    termArray.append(termObject)
//                                }
//                                //All Subjects
//                                var allSubjects: [SubjectHeaderItem] = []
//                                let allSubjectsData = term.1["subjects"]
//                                for subject in allSubjectsData{
//                                    let subjectName = subject.1["name"].stringValue
//                                    let subjectCode = subject.1["code"].stringValue
//                                    let subjectMark = subject.1["mark"].floatValue
//                                    let subjectFullMark = subject.1["full_mark"].floatValue
//                                    let subjectId = subject.1["id"].stringValue
//                                    let subSubjectData = subject.1["sub_subjects"]
//
//                                    var subSubjectArray: [SubSubjectItem] = []
//                                    for subSubject in subSubjectData{
//                                        let subSubjectName = subSubject.1["name"].stringValue
//                                        let subSubjectMark = subSubject.1["mark"].floatValue
//                                        let subSubjectFullMark = subSubject.1["full_mark"].floatValue
//                                        let subSubjectId = subSubject.1["id"].stringValue
//                                        let assessmentData = subSubject.1["assessments"]
//
//                                        var assessmentArray: [SubTerm] = []
//                                        for assessment in assessmentData{
//                                            let name = assessment.1["name"].stringValue
//                                            let mark = assessment.1["mark"].floatValue
//                                            let fullMark = assessment.1["full_mark"].floatValue
//                                            let id = assessment.1["id"].stringValue
//                                            let assessmentObject = SubTerm.init(termId: id, termName: name, termsMark: mark, editable: false, published: false, fullMark: fullMark)
//                                            assessmentArray.append(assessmentObject)
//                                        }
//                                        let subSubjectObject = SubSubjectItem.init(id: subSubjectId, subName: subSubjectName, subMark: Float(round(100*subSubjectMark)/100), isOpen: false, editable: false, fullMark: subSubjectFullMark, terms: assessmentArray)
//                                        subSubjectArray.append(subSubjectObject)
//                                    }
//                                    // here: All Subjects Color and Icons:
//                                    var subjectColor = ""
//                                    let subjectIcon = subject.1["imperium_code"].stringValue
//                                    let checked = false
//
//                                    let subjectTheme = theme.subjectTheme.filter({$0.code == subjectCode})
//                                    if !subjectTheme.isEmpty{
//                                        subjectColor = subjectTheme.first!.bg
//                                    }
//                                    let subject = SubjectHeaderItem.init(id: subjectId, subjectColor: subjectColor, subjectIcon: subjectIcon, subjectTitle: subjectName, subjectMark: Float(round(100*subjectMark)/100), subjectCode: subjectCode, fullMark: subjectFullMark, isOpen: false, checked: checked, editable: false, items: subSubjectArray)
//                                    allSubjects.append(subject)
//                                }
//
//                                let allSubTermColor = theme.gradesTheme.allSubterms
//                                for sub in allSubjects{
//                                    print("subjects info: \(sub.subjectTitle)")
//                                    print("subjects info: \(sub.subjectMark)")
//                                }
//                                let allTerm = Term.init(id: "0", name: "All", avg: Float(round(100*average)/100), classAvg: Float(round(100*classAvg)/100), remarkTile: "", remarkBody: "", teacherName: "", subject: "", color: allSubTermColor, selected: false, subjectsArray: allSubjects)
//                                termArray.append(allTerm)
//
//                                print("term code: \(termCode)")
//                                let subTermObject = TermAverage.init(id: id, name: termCode, average: Float(round(100*average)/100), classAverage: Float(round(100*classAvg)/100), values: termArray, color: color, termRemarkTitle: termRemarkTitle, termRemarkBody: termRemarkBody)
//                                averageArray.append(subTermObject)
//                            }
//                            completion(message,averageArray,status)
//                        }else{
//                            let errorMessage = data["error_msgs"].stringValue
//                            self.reportError(message: errorMessage)
//                            completion(errorMessage,[],status)
//                        }
//
//                    case .failure(let error):
//
//                        if error._code == NSURLErrorTimedOut {
//                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
//                        }
//                        else if error._code == NSFileNoSuchFileError {
//                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
//                        }
//                        else {
//                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
//                        }
//                    }
//                }
//            case .failure(let error):
//
//                if error._code == NSURLErrorTimedOut {
//                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
//                }
//                else if error._code == NSFileNoSuchFileError {
//                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
//                }
//                else {
//                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
//                }
//            }
//        })
//    }
    
    
//    //Change password API:
//    func changePassword(user: User, newPassword: String, oldPassword: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
//        let getStudentURL = "\(baseURL!)/api/user/change_password"
//
//        let params = [
//            "username": "\(user.userName)",
//            "token": "\(user.token)",
//            "new_password": "\(newPassword)",
//            "confirm_password": "\(newPassword)",
//            "old_password": "\(oldPassword)",
//        ]
//
//        self.manager.upload(multipartFormData: {
//            multipartFormData in
//            for (key, value) in params{
//                multipartFormData.append(value.data(using: .utf8)!, withName: key)
//            }
//
//        }, to: getStudentURL, encodingCompletion: {
//            (result) in
//            switch result {
//            case .success(let upload, _, _):
//                upload.responseJSON {
//                    response in
//                    switch response.result {
//                    case .success(let j):
//
//                        let json = JSON(j)
////                        let message = json["statusMessage"].stringValue
//                        let status = json["statusCode"].intValue
//                        let data = json["data"]
//                        if status == 200{
//                            let message = data["message"].stringValue
//                            completion(message,data,status)
//                        }else{
//                            let errorMessage = data["error_msgs"].stringValue
//                            completion(errorMessage,"",status)
//                        }
//
//                    case .failure(let error):
                    
//                        if error._code == NSURLErrorTimedOut {
//                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
//                        }
//                        else if error._code == NSFileNoSuchFileError {
//                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                        }
//                        else {
//                            completion(error.localizedDescription,"",App.STATUS_INVALID_RESPONSE)
//                        }
//                    }
//                }
//            case .failure(let error):
                    
//                if error._code == NSURLErrorTimedOut {
//                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
//                }
//                else if error._code == NSFileNoSuchFileError {
//                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
//                }
//                else {
//                    completion(error.localizedDescription,"",App.STATUS_INVALID_RESPONSE)
//                }
//            }
//        })
//    }
    
    
    //Get Exams API:
    func getExams(user: User, sectionId: Int, theme: AppTheme, completion: @escaping(_ message: String?, _ result: [TermAverage]?, _ status: Int?)->Void){
  
        let examURL = "https://a2wqr2yg0f.execute-api.eu-west-1.amazonaws.com/devo/get_teacher_gradebook?sectionId=119"
    
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjUwNywiZW1haWwiOiJhZG1pbkB3ZWxsc3ByaW5nLmNvbSIsInVzZXJOYW1lIjoiYWRtaW4iLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE2OTM1NTE5NTAsImV4cCI6MTY5MzYzODM1MH0.LnMbgn1AGIIF75dM-etY1DHABgbRC0ijogFRxyR3A7U"
        ]
        
        print("examURL: \(examURL)")
        self.manager.request(examURL, method: .get, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
#if DEBUG
                    print("getExams", json)
#endif
                    
                    let message = json["message"].stringValue
                    let status = 200
                    let termData = json["response"]
                    
                    if status == 200{
#if DEBUG
                        print("getExams", json)
#endif
                        var averageArray: [TermAverage] = []
                        for term in termData{
                            let code = term.1["title"].stringValue
                            let id = term.1["id"].stringValue
                            let subTermsData = term.1["exams"]
                            //here
                            let color = ""
                            var termArray: [Term] = []
                            for (subIndex,subTerm) in subTermsData.enumerated(){
                                let subCode = subTerm.1["title"].stringValue
                                let remarkId = subTerm.1["id"].stringValue
                                //here
                                var color = ""
                                switch subIndex{
                                case 0:
                                    color = theme.gradesTheme.subTerm_1
                                case 1:
                                    color = theme.gradesTheme.subTerm_2
                                case 2:
                                    color = theme.gradesTheme.subTerm_3
                                case 3:
                                    color = theme.gradesTheme.subTerm_4
                                case 4:
                                    color = theme.gradesTheme.subTerm_5
                                case 5:
                                    color = theme.gradesTheme.subTerm_6
                                default:
                                    color = theme.gradesTheme.allSubterms
                                }
                                
                                let subjectData = subTerm.1["subSubjects"]
                                var subjectArray: [SubjectHeaderItem] = []
                                for subject in subjectData{
                                    let subjectEditable = subject.1["editable"].boolValue
                                    let subjectCode = subject.1["title"].stringValue
                                    let subjectName = subject.1["title"].stringValue
                                    let subjectClassAvg = subject.1["class_avg"].floatValue
                                    let subjectFullMark = subject.1["weight"].floatValue
                                    let subjectId = subject.1["id"].stringValue
                                    let checked = false
                                    //here
                                    var subjectColor = ""
                                    let subjectIcon = subject.1["imperium_code"].stringValue
                                    let subjectTheme = theme.subjectTheme.filter({$0.code == subjectCode})
                                    if !subjectTheme.isEmpty{
                                        subjectColor = subjectTheme.first!.bg
                                    }
                                    //                        if subjectColor.isEmpty{
                                    subjectColor = "#fa487a"
                                    //                        }
                                    
                                    var subSubjectArray: [SubSubjectItem] = []
                                    let subSubjectData = subject.1["sub_subjects"]
                                    for subSubject in subSubjectData{
                                        let subSubjectEdit = subSubject.1["editable"].boolValue
                                        let subSubjectName = subSubject.1["title"].stringValue
                                        let subSubjectClassAvg = subSubject.1["class_avg"].floatValue
                                        let subSubjectFullMark = subSubject.1["full_mark"].floatValue
                                        let subSubjectId = subSubject.1["id"].stringValue
                                        
                                        var subTermArray: [SubTerm] = []
                                        //here
                                        let subTermData = subSubject.1["assessments"]
                                        for quiz in subTermData{
                                            let quizEdit = quiz.1["editable"].boolValue
                                            let quizAverage = quiz.1["class_avg"].floatValue
                                            let quizName = quiz.1["name"].stringValue
                                            let quizFullMark = quiz.1["full_mark"].floatValue
                                            let quizId = quiz.1["id"].stringValue
                                            
                                            let quizObject = SubTerm.init(termId: quizId, termName: quizName, termsMark: Float(round(100*quizAverage)/100), editable: quizEdit, published: false, fullMark: quizFullMark)
                                            subTermArray.append(quizObject)
                                        }
                                        
                                        let subSubjectObject = SubSubjectItem.init(id: subSubjectId, subName: subSubjectName, subMark: Float(round(100*subSubjectClassAvg)/100), isOpen: false, editable: subSubjectEdit, fullMark: subSubjectFullMark, terms: subTermArray)
                                        subSubjectArray.append(subSubjectObject)
                                    }
                                    
                                    let subjectObject = SubjectHeaderItem.init(id: subjectId, subjectColor: subjectColor, subjectIcon: subjectIcon, subjectTitle: subjectName, subjectMark: Float(round(100*subjectClassAvg)/100), subjectCode: subjectCode, fullMark: subjectFullMark, isOpen: false, checked: checked, editable: subjectEditable, items: subSubjectArray)
                                    subjectArray.append(subjectObject)
                                }
                                var selected = false
                                if subIndex == 0{
                                    selected = true
                                }
                                let termObject = Term.init(id: remarkId, name: subCode, avg: 0, classAvg: 0, remarkTile: "", remarkBody: "", teacherName: "", subject: "", color: color, selected: selected, subjectsArray: subjectArray)
                                termArray.append(termObject)
                            }
                            
                            let subTermObject = TermAverage.init(id: id, name: code, average: 0, classAverage: 0, values: termArray, color: color, termRemarkTitle: "", termRemarkBody: "")
                            averageArray.append(subTermObject)
                        }
                        completion(message,averageArray,status)
                    }else{
                        let errorMessage = message
                        self.reportError(message: errorMessage)
                        completion(errorMessage,[],status)
                    }
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                    }
                }
            }
    }
    
    //Get Student Marks API:
    func getStudentMarks(user: User, sectionId: Int, type: String, id: String, completion: @escaping(_ message: String?, _ result: [Student]?, _ status: Int?)->Void){
        let getStudentMarksURL = "\(baseURL!)/api/grades/get_student_marks"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "section_id": "\(sectionId)",
            "type": "\(type)",
            "id":"\(id)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: getStudentMarksURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        print("getStudentMarks", json)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            var studentArray: [Student] = []
                            let studentMarksData = data["marks"]
                            for student in studentMarksData{
                                let id = student.1["student_id"].stringValue
                                let photo = student.1["photo_link"].stringValue
                                let name = student.1["student_name"].stringValue.capitalized
                                let mark = student.1["mark"].floatValue
                                var gender = student.1["gender"].stringValue
                                if gender.isEmpty{
                                    gender = "m"
                                }
                                
                                let nameIndex = name.first ?? " "
                                let object = Student.init(index: "\(nameIndex)", id: id, fullName: name, photo: photo, mark: mark, selected: false, gender: gender, parent: false)
                                studentArray.append(object)
                            }
                            completion(message,studentArray,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    
    //Submit Student Marks API:
    func submitStudentMarks(user: User, sectionId: Int, type: String, id: String, students: [Student], completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let submitStudentMarksURL = "\(baseURL!)/api/grades/submit_student_marks"
        
        var studentsParam = ""
        var marks = ""
        
        for (index, student) in students.enumerated(){
            if students.count > 1{
                if index == 0{
                    studentsParam = "\(student.id)"
                    marks = "\(student.mark)"
                }else{
                    studentsParam = "\(studentsParam),\(student.id)"
                    marks = "\(marks),\(student.mark)"
                }
            }else{
                studentsParam = student.id
                marks = "\(student.mark)"
            }
        }
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "section_id": "\(sectionId)",
            "type": "\(type)",
            "id":"\(id)",
            "students": "\(studentsParam)",
            "marks": "\(marks)"
        ]
        
//        print("gradesparams",params)
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
//            do {
//                let studentData = try JSONSerialization.data(withJSONObject: students.map({return "\($0.id)"}), options: .prettyPrinted)
//                var studentss = String(data: studentData, encoding: .utf8)
//                studentss = studentss?.replacingOccurrences(of: "\n", with: "")
//                multipartFormData.append((studentss ?? "").data(using: .utf8)!, withName: "students")
//
//                let markData = try JSONSerialization.data(withJSONObject: students.map({return "\($0.mark)"}), options: .prettyPrinted)
//                var marks = String(data: markData, encoding: .utf8)
//                marks = marks?.replacingOccurrences(of: "\n", with: "")
//                multipartFormData.append((marks ?? "").data(using: .utf8)!, withName: "marks")
//            }
//            catch {
//
//            }
           
//            for id in students.map({return "\($0.id)"}){
//                multipartFormData.append(id.data(using: .utf8)!, withName: "students")
//            }
//
//            for mark in students.map({return "\($0.mark)"}){
//                multipartFormData.append(mark.data(using: .utf8)!, withName: "marks")
//            }
            
        }, to: submitStudentMarksURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    
    //Verify Code API:
    func verifyCode(user: User, code: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let submitStudentMarksURL = "\(baseURL!)/api/user/verify_code"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "code": "\(code)",
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: submitStudentMarksURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    
    //Change password API:
    func changePassword(user: User, oldPassword: String, newPassword: String, confirmPassword: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let submitStudentMarksURL = "\(LOGIN_URL)/change_password"
        
        let params = [
            "id": user.userId,
            "password": "\(oldPassword)",
            "newPassword": "\(newPassword)",
            "schoolId": "\(user.schoolId)",
        ] as [String : Any]
        
        print("change change: \(submitStudentMarksURL)")
        print("change change: \(params)")

        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        
        self.manager.request(submitStudentMarksURL, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .validate { request, response, data in
                        return .success
                    }
                .responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let data = JSON(j)
                        print("response: \(data)")

                        let message = data["message"].stringValue
                        var status = 0
                        if(message.contains("changed successfully")){
                            status = 200
                        }
                        let dataArray = data["response"]
                        if status == 200{
                            completion(message,dataArray,status)
                        }else{
                            self.reportError(message: message)
                            completion(message,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
 

    }
    
    
    //Remove Remark API:
    func removeRemark(user: User, remarkId: Int, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let removeRemarkURL = "\(baseURL!)/api/remarks/remove_remark"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "remark": "\(remarkId)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: removeRemarkURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //Remove Assignment API:
    func removeAssignment(user: User, assignmentId: Int, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let removeAssignmentURL = "\(AGENDA_ASSIGNMENTS_URL)/deleteassignment/\(assignmentId)"
//        print("occasion occasion1: \(filename)")
        
        let params = [
            "userId" : "\(user.userId)"
        ]
        
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
       
        #if DEBUG
            print("createOccasion params",params)
        #endif
        

        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }


//            if profile?.size != CGSize(width: 0.0, height: 0.0){
//                if let profile = profile {
//                    multipartFormData.append(profile.jpeg(.lowest)!, withName: "file", fileName: filename, mimeType: "image/jpeg")
//                }
//            }

        }, to: removeAssignmentURL, method: .put, headers: headers, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):

                        let json = JSON(j)
                        print(json)
                        let message = json["message"].stringValue
                        var status = 0
                        if message.contains("success") {
                            let data = json["data"]
                            status = 200
                            completion(message,"",status)
                        }
                        else {
                        // Failed server response
                            let error = JSON(j)
                            let statusCode = error["statusCode"].intValue
                            let data = error["data"]
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,error,statusCode)
                        }
                    case .failure(let error):

                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):

                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    
    //Verify Absence API:
    func verifyAbsence(user: User, studentUsername: String, reason: String, id: Int, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let verifyAbsenceURL = "\(baseURL!)/api/attendance/verify_absence"
        
        let params = [
            "username": "\(user.userName)",
            "student_username": "\(studentUsername)",
            "token": "\(user.token)",
            "reason": "\(reason)",
            "id": "\(id)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: verifyAbsenceURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,"",status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    //TimeTable API:
    func getTimeTable(user: User, sectionId: Int, theme: [SubjectTheme], date: Date, completion: @escaping(_ message: String?, _ result: [Period]?, _ status: Int?)->Void){
        
        print("user user timetable: \(sectionId)")
        var timeTableURL = ""
        if user.userType == 1{
            timeTableURL = "\(TIMETABLE_URL)/get_student_timetable?sectionId=\(sectionId)"
        }
        else if user.userType == 2{
            timeTableURL = "\(TIMETABLE_URL)/get_teacher_timetable?teacher_id=\(user.imperiumCode)"
        }else{
            var sectionId = 0
            if(user.classes.count > 0){
                sectionId = user.classes[0].batchId
            }
            timeTableURL = "\(TIMETABLE_URL)/get_student_timetable?sectionId=\(sectionId)"
        }
        
        var params = ["":""]
        
        print("called called timetable1: \(timeTableURL)")
        
//        if user.userType == 4{
//            params = [
//                "username": "\(user.admissionNo)",
//                "token": "\(user.token)",
//            ]
//        }else{
//            params = [
//                "username": "\(user.userName)",
//                "token": "\(user.token)",
//            ]
//        }
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        
        self.manager.request(timeTableURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("getAttendanceTimeTable", json)
                        #endif
                        let message = json["message"].stringValue
                        let status = 200
                        let data = json["response"]
                        
                        if status == 200{
                            var selectedDayId: Int = 0
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "EEEE"
                            let weekDay = dateFormatter.string(from: date)
                            
                            switch weekDay{
                            case "Monday":
                                selectedDayId = 1
                            case "Tuesday":
                                selectedDayId = 2
                            case "Wednesday":
                                selectedDayId = 3
                            case "Thursday":
                                selectedDayId = 4
                            case "Friday":
                                selectedDayId = 5
                            case "Saturday":
                                selectedDayId = 6
                            default:
                                selectedDayId = 7
                            }
                            
                            var periodArray: [Period] = []
                            
                                let periodData = data["schedules"]
                                for period in periodData{
                                    let time = period.1["scheduledTime"].stringValue
                                    let subjectId = period.1["subject_id"].stringValue
                                    let periodId = period.1["id"].intValue
                                    let subjectCode = period.1["subjectName"].stringValue
                                    let subjectName = period.1["subjectName"].stringValue
                                    let classCode = period.1["teacherName"].stringValue
                                    let endTime = period.1["end_time"].stringValue
                                    let dayName = period.1["weekDay"].stringValue
                                    
                                    var dayId = 0

                                    switch dayName{
                                    case "Monday":
                                        dayId = 1
                                    case "Tuesday":
                                        dayId = 2
                                    case "Wednesday":
                                        dayId = 3
                                    case "Thursday":
                                        dayId = 4
                                    case "Friday":
                                        dayId = 5
                                    case "Saturday":
                                        dayId = 6
                                    default:
                                        dayId = 7
                                    }
                                    
                                    let subjectIcon = period.1["imperium_code"].stringValue
                                    
                                   
                                    
                                    var dateString = ""
                                    if dayId < selectedDayId{
                                        let difference = selectedDayId - dayId
                                        let periodDate = Calendar.current.date(byAdding: .day, value: 7 - difference, to: date)
                                        dateString = self.formatter.string(from: periodDate!)
                                    }else{
                                        let difference = dayId - selectedDayId
                                        let periodDate = Calendar.current.date(byAdding: .day, value: difference, to: date)
                                        dateString = self.formatter.string(from: periodDate!)
                                    }
                                    
                                    let periodObject = Period(dayId: dayId, date: dateString, subjectId: subjectId, periodId: periodId, subjectName: subjectName, subjectIcon: subjectIcon, subjectCode: subjectCode, time: time, classCode: classCode, selected: false, endTime: endTime, dayName: dayName)
                                        periodArray.append(periodObject)
                                    
                                    print("period object: \(periodObject)")
                                }
                            
                            
                            completion(message,periodArray,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,[],status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,[],App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,[],App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
    }
    
    
    //Get Notifications Count API:
    func getNotificationCount(user: User, studentUsername: String, appTheme: AppTheme, completion: @escaping(_ message: String?, _ result: AppTheme?, _ status: Int?)->Void){
        let notificationCountURL = "https://lts.madrasatie.com/api/notifications/get_notification_count"
        
        let params = [
            "username": "E125",
            "token": "5a45b3a54f727a7b13f23c36ff6e66149c0d9de2d32ebd6253988cf07d4e744e",
            "student_username": "S001"
        ]

        #if DEBUG
            print("getNotificationCountparams", params)
        #endif
        
        var theme = appTheme
        theme.calendarTheme.notificationCount = 0
        theme.attendanceTheme.notificationCount = 0
        theme.agendaTheme.notificationCount = 0
        theme.remarkTheme.notificationCount = 0
        
        completion("",theme,200)
       
    }
    
    
    //Vote For Activate Module:
    func VoteForActivate(user: User, schoolID: Int, moduleID: Int, completion: @escaping(_ message: String?, _ data: JSON?, _ status: Int)->Void){
        
        let params: Parameters = [
            "userID": user.userId,
            "schoolID": schoolID,
            "moduleID": moduleID,
            "name": "\(user.firstName) \(user.lastName)"
        ]
        
        self.manager.request("\(imperiumURL)vote.php", method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(let j):
                    let json = JSON(j)
                    let data = json["data"]
                    let status = json["statusCode"].intValue
                    let message = json["message"].stringValue
                    
                    completion(message,data,status)
                    
                case .failure(let error):
                    
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,"",App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,"",App.STATUS_INVALID_RESPONSE)
                    }
                }
        }
    }
    
    //Reset Notifications Count API:
    func resetNotificationCount(user: User, studentUsername: String, moduleId: Int, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let resetNotificationCountURL = "\(baseURL!)/api/notifications/reset_notifications_count"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "student_username": "\(studentUsername)",
            "section_id": "\(moduleId)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: resetNotificationCountURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,nil,status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    
    //Check Birthday API:
    func checkBirthday(user: User, studentUsername: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void){
        let checkBirthdayURL = "\(baseURL!)/api/user/check_bday_page"
        
        let params = [
            "username": "\(user.userName)",
            "token": "\(user.token)",
            "student_username": "\(studentUsername)"
        ]
        
        self.manager.upload(multipartFormData: {
            multipartFormData in
            for (key, value) in params{
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            
        }, to: checkBirthdayURL, encodingCompletion: {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    switch response.result {
                    case .success(let j):
                        
                        let json = JSON(j)
                        let message = json["statusMessage"].stringValue
                        let status = json["statusCode"].intValue
                        let data = json["data"]
                        
                        if status == 200{
                            completion(message,data,status)
                        }else{
                            let errorMessage = data["error_msgs"].stringValue
                            self.reportError(message: errorMessage)
                            completion(errorMessage,nil,status)
                        }
                        
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                    }
                }
            case .failure(let error):
                    
                if error._code == NSURLErrorTimedOut {
                    completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                }
                else if error._code == NSFileNoSuchFileError {
                    completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                }
                else {
                    completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                }
            }
        })
    }
    
    // augmental api integration
    
    func getSchool(user: User, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void) {
        let getSchoolURL = "\(BLENDED_LEARNING_URL)/get_school?schoolId=\(user.schoolId)"
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("getSchoolURL: ", getSchoolURL)

        self.manager.request(getSchoolURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON {
                response in
                switch response.result{
                case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("getSchool JSON: ", json)
                        #endif
                        let status = 200
                        let message = json["message"].stringValue
                        let data = json["response"]
                        
                        if status == 200 {
                            
                            completion(message, data, status)
                        }
                        else {
                            // Failed server response
                            
                            completion(message, data, status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                    }
            }
    }
    
    func isUserFound(user: User, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void) {
        let isUserFoundURL = "\(BLENDED_LEARNING_URL)/is_user_found?schoolId=\(user.schoolId)&userId=\(user.userId)"
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("isUserFoundURL: ", isUserFoundURL)

        self.manager.request(isUserFoundURL, method: .get, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON {
                response in
                switch response.result{
                case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("isUserFound JSON: ", json)
                        #endif
                        let status = 200
                        let message = json["message"].stringValue
                        let data = json["response"]
                        
                        if status == 200 {
                            
                            completion(message, data, status)
                        }
                        else {
                            // Failed server response
                            
                            completion(message, data, status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                    }
            }
    }
    
    
    func augmentalSignUp(user: User, accountCode: String, schoolLink: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void) {
        let augmentalSignUpURL = "\(AUGMENTAL_URL)/\(accountCode)/Users"
        
        var role = ""
        
        if(user.userType == 1){
            role = "Administrator"
        } else if (user.userType == 2){
            role = "Instructor"
        } else if (user.userType == 3){
            role = "Learner"
        } else{
            role="Learner"
        }
        
        var gender = ""

        if(user.gender == "m" || user.gender == "M"){
            gender = "Male"
        } else if (user.gender == "f" || user.gender == "F"){
            gender = "Female"
        } else{
            gender = "Male"
        }
        
        let params = [
            "email": "\(user.email)",
            "firstName": "\(user.firstName)",
            "lastName": "\(user.lastName)",
            "gender": "\(gender)",
            "languageIsoCode": "en",
            "role": "\(role)",
            ]
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
        ]
        
        print("augmentalSignUpURL: ", augmentalSignUpURL)

        self.manager.request(augmentalSignUpURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON {
                response in
                switch response.result{
                case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("augmentalSignUp JSON: ", json)
                        #endif
                        let status = 200
                        let message = json["message"].stringValue
                        var data: Any?
                        if json["error"] != nil {
                            data = json["error"]
                        } else {
                            data = json
                        }
                        
                        if status == 200 {
                            
                            completion(message, data as! JSON, status)
                        }
                        else {
                            // Failed server response
                            
                            completion(message, data as! JSON, status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                    }
            }
    }
    
    func enrollUser(user: User, accountCode: String, userCode: String, className: String, classCode: String, completion: @escaping(_ message: String?, _ result: JSON?, _ userCode: String?, _ status: Int?)->Void) {
        let enrollUserURL = "\(AUGMENTAL_URL)/\(accountCode)/Users/\(userCode)/Classes/Enrollments"
        
        let params = [
            "class": "\(className)",
            "group": "\(classCode)",
            "languageIsoCode": "en",
            ]
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
        ]
        
        print("enrollUserURL: ", enrollUserURL)

        self.manager.request(enrollUserURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON {
                response in
                switch response.result{
                case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("enrollUser params: ", params)
                            print("enrollUser JSON: ", json)
                        #endif
                        let status = 200
                        let message = json["description"].stringValue
                        let data = json
                        
                        if status == 200 {
                            
                            completion(message, data, userCode, status)
                        }
                        else {
                            // Failed server response
                            
                            completion(message, data, "", status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,nil,"",App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,nil,"",App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,nil,"",App.STATUS_INVALID_RESPONSE)
                        }
                    }
            }
    }
    
    func registerUser(user: User, accountCode: String, userCode: String, schoolLink: String, completion: @escaping(_ message: String?, _ result: JSON?, _ status: Int?)->Void) {
        let registerUserURL = "\(BLENDED_LEARNING_URL)/register_user"
        
        let params = [
            "userId": "\(user.userId)",
            "schoolId": "\(user.schoolId)",
            "accountCode": "\(accountCode)",
            "userCode": "\(userCode)",
            "schoolLink": "\(schoolLink)"
            ]
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
            "Authorization": "Bearer \(user.token)"
        ]
        
        print("registerUserURL: ", registerUserURL)

        self.manager.request(registerUserURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseJSON {
                response in
                switch response.result{
                case .success(let j):
                        let json = JSON(j)
                        #if DEBUG
                            print("registerUser JSON: ", json)
                        #endif
                        let status = 200
                        let message = json["message"].stringValue
                        let data = json["response"]
                        
                        if status == 200 {
                            
                            completion(message, data, status)
                        }
                        else {
                            // Failed server response
                            
                            completion(message, data, status)
                        }
                    case .failure(let error):
                    
                        if error._code == NSURLErrorTimedOut {
                            completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                        }
                        else if error._code == NSFileNoSuchFileError {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                        else {
                            completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                        }
                    }
            }
    }
    
    func loginUser(userCode: String, completion: @escaping(_ message: String?, _ result: String?, _ status: Int?)->Void) {
        let loginUserURL = "\(AUGMENTAL_LOGIN_URL)/login?authentication=\(userCode)"
        
        let headers: HTTPHeaders = [
            "origin": baseURL!, // You can add more headers as needed
        ]
        
        print("loginUserURL: ", loginUserURL)

        self.manager.request(loginUserURL, method: .post, encoding: JSONEncoding.default, headers: headers)
            .validate { request, response, data in
                return .success
            }
            .responseString { response in
                switch response.result {
                case .success(let data):
                    #if DEBUG
                        print("registerUser DATA: ", data)
                    #endif
                    let status = 200
                    let message = ""
                    
                    if status == 200 {
                        
                        completion(message, data, status)
                    }
                    else {
                        // Failed server response
                        
                        completion(message, data, status)
                    }
                    
                    
                    
                case .failure(let error):
                    if error._code == NSURLErrorTimedOut {
                        completion(App.CONNECTION_TIMEOUT,nil,App.STATUS_TIMEOUT)
                    }
                    else if error._code == NSFileNoSuchFileError {
                        completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                    }
                    else {
                        completion(App.INVALID_RESPONSE,nil,App.STATUS_INVALID_RESPONSE)
                    }
                }
            }
    }

}

