//
//  SplashViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 5/15/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import CoreData

enum PushController{
    case module(moduleID: Int)
}

class SplashViewController: UIViewController {

    
    var schoolActivated = false
    var pushController: PushController?
    var schoolRequests = 0
    var userSchools = 0
    var schoolIds: [String] = []
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /// Description
    ///
    /// - PushController used to handle notifications.
    /// - Here we checked if the app is used for the first time, language page should be open.
    ///   If their is a logged in user and remember me is checked, home page should be open.
    ///   If their is no school activated, school activation page should be open.
    override func viewWillAppear(_ animated: Bool) {
        if pushController == nil{
            let when = DispatchTime.now() + 2
            let firstTime = UserDefaults.standard.bool(forKey: "FIRSTTIME")
            DispatchQueue.main.asyncAfter(deadline: when) {
                let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
                var vc = UIViewController()
                if !firstTime{
                    UserDefaults.standard.set(true, forKey: "FIRSTTIME")
                    vc = storyboard.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
                }else if !UserDefaults.standard.bool(forKey: "REMEMBERME"){
                    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
                    //let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOLDATA")
                    let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
                    let school = try? managedContext.fetch(schoolFetchRequest) as! [SCHOOL]
                    if school != nil{
                        for _ in school! {
                            self.schoolActivated = true

                        }
                    }
                    if !self.schoolActivated{
                        vc = storyboard.instantiateViewController(withIdentifier: "ActivationVC") as! ActivationVC
                    }else{
                        print("login4")
                        vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    }
                }else{
                   
                    let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
                    let school = try? self.managedContext.fetch(schoolFetchRequest) as! [SCHOOL]
                    self.userSchools = school!.count
                    for object in school! {
                        print("schoolid111: \(object.url!)")
                        self.submitActivation(activationCode: object.code!)
                    }
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    vc = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                }
                let navigationController = UINavigationController(rootViewController: vc)
                vc.modalTransitionStyle = .crossDissolve
                navigationController.modalPresentationStyle = .fullScreen
                self.show(navigationController, sender: self)
            }
        }
    }
    
    
    /// Description
    ///
    /// - Checking for notifications:
    ///   In case of notification, the app should send the notifications data and open home page.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let push = pushController{
            switch push{
            case .module:
                self.pushController = nil
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                vc.pushController = push
                let navigationController = UINavigationController(rootViewController: vc)
                vc.modalTransitionStyle = .crossDissolve
                self.show(navigationController, sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//Call AppDelegate Function:

//let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
//let gotomain: UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
//appDelegate?.SetMainController(viewController: gotomain )

extension SplashViewController{
    func submitActivation(activationCode: String){
              let indicatorView = App.loading()
              indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
              indicatorView.tag = 100
              self.view.addSubview(indicatorView)
              
              Request.shared.GetSchoolURL(activationCode: activationCode) { (message, schoolData, status) in
                  if status == 200{
                      let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
                      //let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOLDATA")
                      let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
                      let school = try? managedContext.fetch(userFetchRequest) as! [SCHOOL]
                      if school != nil{
                        for object in school! {
                            //schoolIds.append(Int(object.id))
//                            let oldURL = object.url!.split(separator: "/")
//                            let newURL = schoolData.schoolURL.split(separator: "/")
//                            print("1: \(oldURL[0])")
//                            print("2: \(newURL[0])")
//                            print("3: \(oldURL[1])")
//                            print("4: \(newURL[1])")
//                            if(oldURL[0].contains("http:") && newURL[0].contains("https:")){
//                                if(oldURL[1].elementsEqual(newURL[1])){
                                    managedContext.delete(object)
                                    let schoolEntity = NSEntityDescription.entity(forEntityName: "SCHOOL", in: managedContext)
                                    let newSchool = NSManagedObject(entity: schoolEntity!, insertInto: managedContext)
                                    newSchool.setValue(schoolData.id, forKey: "id")
                                    newSchool.setValue(schoolData.logo, forKey: "logo")
                                    newSchool.setValue(schoolData.schoolURL, forKey: "url")
                                    newSchool.setValue(schoolData.schoolId, forKey: "schoolId")
                                    newSchool.setValue(schoolData.lat, forKey: "lat")
                                    newSchool.setValue(schoolData.long, forKey: "long")
                                    newSchool.setValue(schoolData.location, forKey: "location")
                                    newSchool.setValue(schoolData.name, forKey: "name")
                                    newSchool.setValue(schoolData.phone, forKey: "phone")
                                    newSchool.setValue(schoolData.facebook, forKey: "facebook")
                                    newSchool.setValue(schoolData.google, forKey: "google")
                                    newSchool.setValue(schoolData.instagram, forKey: "instagram")
                                    newSchool.setValue(schoolData.linkedIn, forKey: "linkedIn")
                                    newSchool.setValue(schoolData.twitter, forKey: "twitter")
                                    newSchool.setValue(schoolData.website, forKey: "website")
                            newSchool.setValue(schoolData.code, forKey: "code")
                                    do{
                                        try managedContext.save()
                                    }
                                    catch{
                                        print("not saved successfully")
                                    }
                                    UserDefaults.standard.set(schoolData.schoolURL, forKey: "BASEURL")
                                    UserDefaults.standard.set(schoolData.id, forKey: "SCHOOLID")
//                                }
//
//                            }
                            
                          }
                      }
                   
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
