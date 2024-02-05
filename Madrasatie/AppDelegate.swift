//
//  AppDelegate.swift
//  Madrasati
//
//  Created by Tarek on 5/2/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
//import GoogleSignIn
//import MSAL
import CoreData
import UserNotifications
import AWSSNS
//import Fabric
//import Crashlytics
import Firebase
import Siren
import FirebaseMessaging
import FirebaseCore

extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
}

let gcmMessageIDKey = "gcm.message_id"
/// The SNS Platform application ARN
//#if DEBUG
//let SNSPlatformApplicationArn = "arn:aws:sns:eu-west-1:412363195158:app/APNS/IrfanSchoolsiOS"
//#else
let SNSPlatformApplicationArn = "arn:aws:sns:eu-west-1:892667948359:app/APNS/irfanAppleApplication-prod"
//#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var forceUpdate = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
//        GIDSignIn.sharedInstance().clientID = "139079344989-o8ibmqvq980d3sbd2su08de1uslq2inu.apps.googleusercontent.com"
        FirebaseApp.configure()

//        Fabric.with([Crashlytics.self])
        // Override point for customization after application launch.
        window?.makeKeyAndVisible()
        
        //fetch remote config
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
//        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        let expirationDuration: TimeInterval = 12
        
        remoteConfig.fetch(withExpirationDuration: expirationDuration) { (status, error) -> Void in
          if status == .success {
            remoteConfig.activate()
            print("Config fetched")
            
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
        }
        
        /// Setup AWS Cognito credentials
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.EUWest1, identityPoolId: "eu-west-1:af446f0b-d5d9-404b-bf8c-b2c074cbe6ad")
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.EUWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfiguration
        
        registerForPushNotifications(application: application)
        
        return true
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        let sourceApplication =  options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
//        let annotation = options[UIApplication.OpenURLOptionsKey.annotation]
//
////        let googleDidHandle = GIDSignIn.sharedInstance().handle(url,sourceApplication: sourceApplication,annotation: annotation)
//
//        return googleDidHandle
//            //|| MSALPublicClientApplication.handleMSALResponse(url)
//    }
    
    // Change Root ViewController:
    func SetMainController(viewController: UIViewController){
        window?.rootViewController = viewController
//        window?.makeKeyAndVisible()
    }
    
//    func application(_ application: UIApplication,
//                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//
////        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
//            //|| MSALPublicClientApplication.handleMSALResponse(url)
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
            AppstoreReviewHandler().recordAppLaunch()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }


    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let siren = Siren.shared
//        self.forceUpdate = RemoteConfig.remoteConfig().configValue(forKey: "force_update").stringValue ?? "optional"
//
//        if (forceUpdate == "critical"){
            siren.rulesManager = RulesManager(globalRules: .critical, showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)
            siren.wail(performCheck: .onForeground, completion: nil)
//        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        UserDefaults.standard.set(token, forKey: "DEVICETOKEN")
        
//        let token1 = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        UserDefaults.standard.set(token1, forKey: "DEVICETOKEN")

           // Print or use the device token as needed
//           print("Device Token: \(token1)")
        
        var token =  deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("token token: \(token)")
        UserDefaults.standard.set(token, forKey: "DEVICETOKEN")

//        for i in 0..<deviceToken.count {
//            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
//            print("token token: \(token)")
//        }
        print(token)
//        UserDefaults.standard.set(token, forKey: "DEVICETOKEN")
        /// Create a platform endpoint. In this case, the endpoint is a
        /// device endpoint ARN
        let sns = AWSSNS.default()
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.token = token
        request?.platformApplicationArn = SNSPlatformApplicationArn
        print("SNSPlatformApplicationArn", SNSPlatformApplicationArn)
        sns.createPlatformEndpoint(request!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("error error: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
                
                if let endpointArnForSNS = createEndpointResponse.endpointArn {
                    print("endpointArn: \(endpointArnForSNS)")
                }
            }
            return nil
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func registerForPushNotifications(application: UIApplication) {
        /// The notifications settings
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted)
                {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                else{
                    //Do stuff if unsuccessful…
                }
            })
        } else {
            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Madrasati")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // iOS 9 and below
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Madrasati", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            //try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        if #available(iOS 10.0, *) {
            
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
            } else {
                // iOS 9.0 and below - however you were previously handling it
                if managedObjectContext.hasChanges {
                    do {
                        try managedObjectContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                }
                
            }
        }
    }
    
}

extension AppDelegate{
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let messageID = userInfo[gcmMessageIDKey]{
            print("Message ID 1: \(messageID)")
        }
        self.handleNotification(userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey]{
            print("Message ID 2: \(messageID)")
        }
        self.handleNotification(userInfo: userInfo)
    }
    
    func handleNotification(userInfo: [AnyHashable: Any]){
        let message = userInfo["message"] as? String
        let title = userInfo["title"] as? String
        if let sectionId = userInfo["section_id"] as? String{
//        let sectionId = 3
            self.showModule(sectionId: Int(sectionId)!, title: title ?? "", body: message ?? "")
        }
    }
    
    func showModule(sectionId: Int, title: String, body: String){
        if UIApplication.shared.applicationState != .inactive {
            if let controller = UIViewController.top as? SectionVC {
                controller.openModule(sectionID: sectionId)
                return
            }
            else {
                let cancel = UIAlertAction(title: "Cancel", style: .default, handler: {
                    action in
                })
                let view = UIAlertAction(title: "View", style: .default, handler: {
                    action in
                    if let nav = UIViewController.top?.navigationController {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//                        controller.visitID = visit
                        nav.viewControllers.last?.show(controller, sender: nil)
                    }
                })
                App.showAlert(self.window!.rootViewController!, title: title, message: body, actions: [cancel,view])
            }
        }
        else {
            // application is closed
//            App.showMainScreen(with: .transitionCrossDissolve, pushController: .feedback(visitID: visit))
            App.showSplashScreen(with: .transitionCrossDissolve, pushController: .module(moduleID: sectionId))
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        self.handleNotification(userInfo: userInfo)
        // Change this to your preferred presentation option
        completionHandler( [.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        self.handleNotification(userInfo: userInfo)
        completionHandler()
    }
    
}


