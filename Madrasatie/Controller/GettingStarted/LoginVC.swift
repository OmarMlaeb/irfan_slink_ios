//
//  LoginVC.swift
//  Madrasati
//
//  Created by Tarek on 5/4/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage /// Load images from URL
import ActionSheetPicker_3_0
//import GoogleSignIn /// Google Login
//import MSAL /// Microsoft Office Login
import SwiftyJSON
import CoreData
import MSAL


class LoginVC: UIViewController, URLSessionDelegate {
    
    @IBOutlet weak var schoolLogo: UIImageView!
    @IBOutlet weak var txt_username: LoginRoundedTextField!
    @IBOutlet weak var txt_password: LoginRoundedTextField!
    @IBOutlet weak var noUserNameLabel: UILabel!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var usernameDropdownImage: UIImageView!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var forgetPasswordButton: RoundedButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var rememberMeButton: RadioButton!
    @IBOutlet weak var rememberMeView: UIView!
    @IBOutlet weak var rememberMeLabel: UILabel!
    @IBOutlet weak var schoolLogoCollectionView: UICollectionView!
//    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var microsoftButton: UIButton!
    @IBOutlet weak var rightDropDownButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var resetPassword = false
    var userNameArray: [String] = [""]
    var multiSchool = false
    var schoolLogoArray: [String] = ["add-school"]
    var user: User!
    var schoolInfo: SchoolActivation!
    var schoolDataArray: [SchoolActivation] = []
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var setting = false
    var appTheme: AppTheme!
    let uuid = NSUUID().uuidString.lowercased()
    var deviceToken = UserDefaults.standard.string(forKey: "DEVICETOKEN")
    var type = ""
    var language = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    
    //Microsoft Credentials:
//    let kClientID = "3c3ec29e-b341-46ce-aeaa-ff6e75fc47ba"
//    let kAuthority = "https://login.microsoftonline.com/common/v2.0"
//
//    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
//    let kScopes: [String] = ["https://graph.microsoft.com/user.read"]
//
//    var accessToken = String()
//    var applicationContext = MSALPublicClientApplication.init()
    
    //microsoft sso
    //Microsoft Credentials:
    // Update the below to your client ID you received in the portal. The below is for running the demo only
    let kClientID = "bd68a1bb-5e76-4cf7-87d2-aaa49bca0e15"
    let kRedirectUri = "msauth.madrasatie.app.wb://auth"
    let kAuthority = "https://login.microsoftonline.com/common"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kScopes: [String] = ["user.read"] // request permission to read the profile of the signed-in user

    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParameters : MSALWebviewParameters?
    var currentAccount: MSALAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureNoUserNameLabel()
        usernameButton.isHidden = true
        usernameButton.isUserInteractionEnabled = false
        usernameDropdownImage.isHidden = true
        rightDropDownButton.isHidden = true
        forgetPasswordButton.isHidden = true
        forgetPasswordButton.setTitle("I forgot my password".localiz(), for: .normal)
        rememberMeView.alpha = 0
        rememberMeView.layer.cornerRadius = rememberMeView.frame.width / 2
        rememberMeButton.layer.cornerRadius = rememberMeButton.frame.width / 2
        rememberMeButton.layer.borderWidth = 1
        rememberMeButton.layer.borderColor = #colorLiteral(red: 0.8549019608, green: 0.8588235294, blue: 0.862745098, alpha: 1)
        schoolLogoCollectionView.delegate = self
        schoolLogoCollectionView.dataSource = self
        schoolLogoCollectionView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        rememberMeButton.isToggled = !rememberMeButton.isToggled
        rememberMeView.alpha = 1
        
//        let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
//        let aboutVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//        aboutVC.modalPresentationStyle = .fullScreen
//        self.show(aboutVC, sender: self)
        
        //TODO: Fix this, has to do with MSAL Framework
//        do {
            // Initialize a MSALPublicClientApplication with a given clientID and authority
//            self.applicationContext = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
//        } catch {
//            print("Error: \(error)")
//        }
        
        do {
                    try self.initMSAL()
                } catch let error {
                    
                    self.updateLogging(text: "Unable to create Application Context \(error)")
                }

//                self.loadCurrentAccount()
//                self.platformViewDidLoadSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        configureSchoolLogo()
        getLoggedInUsers()
        getRemainingUsers()
//        if setting{
//            backButton.isHidden = false
//        }else{
//            backButton.isHidden = true
//        }
    }
    
    func platformViewDidLoadSetup() {

        NotificationCenter.default.addObserver(self,
                            selector: #selector(appCameToForeGround(notification:)),
                            name: UIApplication.willEnterForegroundNotification,
                            object: nil)

    }

    @objc func appCameToForeGround(notification: Notification) {
        self.loadCurrentAccount()
    }
    
    func initMSAL() throws {
            print("initMSAL")
            guard let authorityURL = URL(string: kAuthority) else {
                self.updateLogging(text: "Unable to create authority URL")
                return
            }

            let authority = try MSALAADAuthority(url: authorityURL)

            let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: kRedirectUri, authority: authority)
            self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
            self.initWebViewParams()
        }
    
    func initWebViewParams() {
        print("initWebViewParams")
        self.webViewParameters = MSALWebviewParameters(parentViewController: self)
        }
    
    func getGraphEndpoint() -> String {
            return kGraphEndpoint.hasSuffix("/") ? (kGraphEndpoint + "v1.0/me/") : (kGraphEndpoint + "/v1.0/me/");
        }

    func callGraphAPI() {

        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParameters else { return }
        

        let msalParameters = MSALAccountEnumerationParameters()
//        msalParameters.completionBlockQueue = DispatchQueue.main
        
        msalParameters.returnOnlySignedInAccounts = false
        
        applicationContext.accountsFromDevice(for: msalParameters, completionBlock:{(accounts, error) in
            if let error = error
            {
                print("no users found: \(error)")
            }
                guard accounts != nil else {return}

                let tokenParameters = MSALInteractiveTokenParameters(scopes: self.kScopes, webviewParameters: webViewParameters)
            tokenParameters.promptType = .selectAccount

                applicationContext.acquireToken(with: tokenParameters, completionBlock:{(result, error) in
                            if let error = error
                            {
                                //handle error
                                print("no users found: \(error)")

                            }

                            guard let resp = result else {return} //process result

                    print("result result: \(resp.accessToken)")
                    let email = resp.account.username
                    let idToken = resp.accessToken
                   
                    print("email email: \(resp.account.username)")
                    
        //                print("userId: \(userId!)\nidToken: \(idToken!)\nfirstName: \(givenName!)\nlastName: \(familyName!)\nemail: \(email!)")
//                    self.SignIn(userName: "", password: "", email: email!, token: idToken, clientId: self.kClientID, clientSecret: "4d9~P2j6RlE_3jz44.~zpaqHmmvbVZ9P.~", grantType: "microsoft")
                    
                    
                    
                    
                    


                })
            
            
                                                                                                                                                                
      })

//            self.loadCurrentAccount { (account) in
//
//                guard let currentAccount = account else {
//
//                    // We check to see if we have a current logged in account.
//                    // If we don't, then we need to sign someone in.
//                    self.acquireTokenInteractively()
//                    return
//                }
//
//                self.acquireTokenSilently(currentAccount)
//            }
        }

        typealias AccountCompletion = (MSALAccount?) -> Void

        func loadCurrentAccount(completion: AccountCompletion? = nil) {

            var scopeArr = ["https://graph.microsoft.com/.default"]

            guard let applicationContext = self.applicationContext else { return }

            let msalParameters = MSALAccountEnumerationParameters()
            msalParameters.completionBlockQueue = DispatchQueue.main
            
            applicationContext.accountsFromDevice(for: msalParameters, completionBlock:{(accounts, error) in
                if let error = error
                {
                   //Handle error
                }
                
                guard let accountObjs = accounts else {return}
                
                let tokenParameters = MSALSilentTokenParameters(scopes:scopeArr, account: accountObjs[0]);
                                                                                                          
                applicationContext.acquireTokenSilent(with: tokenParameters, completionBlock:{(result, error) in
                            if let error = error
                            {
                                //handle error
                            }
                                              
                            guard let resp = result else {return} //process result
                    
                    print("result result: \(resp.accessToken)")
                    self.initWebViewParams()

                                                                                                    
                })
                                                                                                                                                                    
          })

            applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in

                if let error = error {
                    self.updateLogging(text: "Couldn't query current account with error: \(error)")
                    return
                }

                if let currentAccount = currentAccount {

                    self.updateLogging(text: "Found a signed in account \(String(describing: currentAccount.username)). Updating data for that account...")

                    self.updateCurrentAccount(account: currentAccount)

                    if let completion = completion {
                        completion(self.currentAccount)
                    }

                    return
                }

                self.updateLogging(text: "Account signed out. Updating UX")
                self.accessToken = ""
                self.updateCurrentAccount(account: nil)

                if let completion = completion {
                    completion(nil)
                }
            })
           
        }
    
    func acquireTokenInteractively() {

        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParameters else { return }

        // #1
        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount

        // #2
        applicationContext.acquireToken(with: parameters) { (result, error) in

            // #3
            if let error = error {

                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }

            guard let result = result else {

                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }

            // #4
            self.accessToken = result.accessToken
            self.updateLogging(text: "Access token is \(self.accessToken)")
            self.updateCurrentAccount(account: result.account)
            self.getContentWithToken()
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {

            guard let applicationContext = self.applicationContext else { return }

            /**

             Acquire a token for an existing account silently

             - forScopes:           Permissions you want included in the access token received
             in the result in the completionBlock. Not all scopes are
             guaranteed to be included in the access token returned.
             - account:             An account object that we retrieved from the application object before that the
             authentication flow will be locked down to.
             - completionBlock:     The completion block that will be called when the authentication
             flow completes, or encounters an error.
             */

            let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)

            applicationContext.acquireTokenSilent(with: parameters) { (result, error) in

                if let error = error {

                    let nsError = error as NSError

                    // interactionRequired means we need to ask the user to sign-in. This usually happens
                    // when the user's Refresh Token is expired or if the user has changed their password
                    // among other possible reasons.

                    if (nsError.domain == MSALErrorDomain) {

                        if (nsError.code == MSALError.interactionRequired.rawValue) {

                            DispatchQueue.main.async {
                                self.acquireTokenInteractively()
                            }
                            return
                        }
                    }

                    self.updateLogging(text: "Could not acquire token silently: \(error)")
                    return
                }

                guard let result = result else {

                    self.updateLogging(text: "Could not acquire token: No result returned")
                    return
                }

                self.accessToken = result.accessToken
                self.updateLogging(text: "Refreshed Access token is \(self.accessToken)")
                self.updateSignOutButton(enabled: true)
                self.getContentWithToken()
            }
        }
    
    func getContentWithToken() {

            // Specify the Graph API endpoint
            let graphURI = getGraphEndpoint()
            let url = URL(string: graphURI)
            var request = URLRequest(url: url!)

            // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
            request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in

                if let error = error {
                    self.updateLogging(text: "Couldn't get graph result: \(error)")
                    return
                }

                guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {

                    self.updateLogging(text: "Couldn't deserialize result JSON")
                    return
                }

                self.updateLogging(text: "Result from Graph: \(result))")

                }.resume()
        }
    @objc func signOut(_ sender: AnyObject) {

            guard let applicationContext = self.applicationContext else { return }

            guard let account = self.currentAccount else { return }

            do {

                /**
                 Removes all tokens from the cache for this application for the provided account

                 - account:    The account to remove from the cache
                 */

                let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParameters!)
                signoutParameters.signoutFromBrowser = false // set this to true if you also want to signout from browser or webview

                applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in

                    if let error = error {
                        self.updateLogging(text: "Couldn't sign out account with error: \(error)")
                        return
                    }

                    self.updateLogging(text: "Sign out completed successfully")
                    self.accessToken = ""
                    self.updateCurrentAccount(account: nil)
                })

            }
        }
    
    func updateLogging(text : String) {

            if Thread.isMainThread {
                print("logging text: \(text)")
            } else {
                DispatchQueue.main.async {
                    print("logging text: \(text)")

                }
            }
        }

        func updateSignOutButton(enabled : Bool) {
            if Thread.isMainThread {
                print("signed out successfully")

            } else {
                DispatchQueue.main.async {
                    print("signed out successfully")

                }
            }
        }

        func updateAccountLabel() {

            guard let currentAccount = self.currentAccount else {
                print("signed out successfully")

                return
            }

            print("signed out successfully: \(currentAccount.username)")
        }

        func updateCurrentAccount(account: MSALAccount?) {
            self.currentAccount = account
            self.updateAccountLabel()
            self.updateSignOutButton(enabled: account != nil)
        }
    @objc func getDeviceMode(_ sender: AnyObject) {

            if #available(iOS 13.0, *) {
                self.applicationContext?.getDeviceInformation(with: nil, completionBlock: { (deviceInformation, error) in

                    guard let deviceInfo = deviceInformation else {
                        self.updateLogging(text: "Device info not returned. Error: \(String(describing: error))")
                        return
                    }

                    let isSharedDevice = deviceInfo.deviceMode == .shared
                    let modeString = isSharedDevice ? "shared" : "private"
                    self.updateLogging(text: "Received device info. Device is in the \(modeString) mode.")
                })
            } else {
                self.updateLogging(text: "Running on older iOS. GetDeviceInformation API is unavailable.")
            }
        }
    /// Description:
    /// - Apply textAlignment changes when change the current language.
    override func viewDidLayoutSubviews() {
        switch self.language{
        case "ar":
            self.txt_username.textAlignment = .right
            self.txt_password.textAlignment = .right
        default:
            self.txt_username.textAlignment = .left
            self.txt_password.textAlignment = .left
        }
    }
    
    
    /// Description:
    /// - Fetch School data from core data to schoolDataArray.
    /// - Get selected school info from schoolDataArray and set selected school logo.
    func configureSchoolLogo(){
        let schoolFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SCHOOL")
        let school = try? managedContext.fetch(schoolFetchRequest) as! [SCHOOL]
        schoolDataArray = []
        if school != nil{
            for object in school! {
                let schoolObject = SchoolActivation(id: Int(object.id), logo: object.logo!, schoolURL: object.url!, schoolId: object.schoolId!, name: object.name!, website: object.website!, location: object.location!, lat: object.lat, long: object.long, facebook: object.facebook!, twitter: object.twitter!, linkedIn: object.linkedIn!, google: object.google!, instagram: object.instagram!, phone: object.phone!, code: object.code!)
                schoolDataArray.append(schoolObject)
            }
        }
        
        if schoolInfo == nil{
            if !schoolDataArray.isEmpty{
                let schoolId = UserDefaults.standard.integer(forKey: "SCHOOLID")
                schoolInfo = schoolDataArray.filter({$0.id == schoolId}).first
                if schoolId == 0 || schoolInfo == nil{
                    schoolInfo = schoolDataArray.first!
                    UserDefaults.standard.set(schoolInfo.id, forKey: "SCHOOLID")
                    UserDefaults.standard.set(schoolInfo.schoolURL, forKey: "BASEURL")
                }
            }else{
                return
            }
        }
        
        if let url = URL(string: self.schoolInfo.logo){
            App.addImageLoader(imageView: self.schoolLogo, button: nil)
            self.schoolLogo.sd_setImage(with: url) { (image, error, chache, url) in
                App.removeImageLoader(imageView: self.schoolLogo, button: nil)
            }
        }
        if schoolDataArray.isEmpty{
            self.schoolLogo.image = UIImage(named: "empty")
        }
        schoolLogoCollectionView.reloadData()
    }
    
    func getRemainingUsers(){
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
        let users = try? managedContext.fetch(userFetchRequest) as! [USER]
        print("users count: \(users!.count)")
            if(users!.count == 0){
                 UserDefaults.standard.set(false, forKey: "REMEMBERME")
                backButton.isHidden = true
            }else{
                UserDefaults.standard.set(true, forKey: "REMEMBERME")
                backButton.isHidden = false
            }
        }
    
    /// Description:
    /// - Fetch previous logged in users from core data to use in suggestions dropdown.
    func getLoggedInUsers(){
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SUGGESTION")
        let users = try? managedContext.fetch(userFetchRequest) as! [SUGGESTION]
        self.userNameArray = []
        if users != nil{
            for user in users!{
                print("username logged: \(user.username!)")
                self.userNameArray.append(user.username!)
            }
        }
        if userNameArray.count == 0{
            userNameArray = [""]
        }else{
            rightDropDownButton.isHidden = false
            usernameDropdownImage.isHidden = false
        }
    }
    
    
    /// Description:
    /// - Set padding to username field.
    func customizeView() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: self.txt_username.frame.height))
        txt_username.leftView = paddingView
        txt_username.leftViewMode = UITextField.ViewMode.always
    }
    
    
    /// Description:
    /// - This function is used to configure help attributed text and a listener to the text.
    func configureNoUserNameLabel(){
        noUserNameLabel.text = "I do not have a username and password I need help".localiz()
        let text = noUserNameLabel.text!
        let attributesText = NSMutableAttributedString(string: text)
        let noUserText = (text as NSString).range(of: "I do not have a username and password".localiz())
        attributesText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(red:0.43, green:0.43, blue:0.44, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Light", size: 13)!], range: noUserText)
        let helpText = (text as NSString).range(of: "I need help".localiz())
        attributesText.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor(red:0.42, green:0.07, blue:0.42, alpha:1.0), NSAttributedString.Key.font: UIFont(name: "OpenSans-Bold", size: 13)!], range: helpText)
        noUserNameLabel.attributedText = attributesText
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        noUserNameLabel.addGestureRecognizer(gesture)
        noUserNameLabel.isUserInteractionEnabled = true
    }
    
    
    /// Description:
    /// - Handle help gesture event.
    @objc func tapLabel(gesture: UITapGestureRecognizer){
        let text = (noUserNameLabel.text)!
        let helpRange = (text as NSString).range(of: "I need help".localiz())
        if gesture.didTapAttributedTextInLabel(label: noUserNameLabel, inRange: helpRange) {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
            aboutVC.schoolName = schoolInfo.name
            aboutVC.info = self.schoolInfo
            self.show(aboutVC, sender: self)
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        if let fbUrl = URL(string: schoolInfo.facebook){
            UIApplication.shared.open(fbUrl, options: [:], completionHandler: nil)
        }else{
            App.showMessageAlert(self, title: "", message: "School doesn't have Facebook".localiz(), dismissAfter: 2.0)
        }
    }
    
    @IBAction func webButtonPressed(_ sender: Any) {
        if let webUrl = URL(string: schoolInfo.website){
            UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
        }else{
            App.showMessageAlert(self, title: "", message: "This School doesn't have Website".localiz(), dismissAfter: 2.0)
        }
    }
    
    @IBAction func phoneButtonPressed(_ sender: Any) {
        let phone = schoolInfo.phone
        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            App.showMessageAlert(self, title: "", message: "Phone number not available", dismissAfter: 1.5)
        }
    }
    
    @IBAction func mapButtonPressed(_ sender: Any) {
        let lat = schoolInfo.lat
        let long = schoolInfo.long
        let url = "http://maps.apple.com/maps?saddr=&daddr=\(lat),\(long)"
        UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func aboutButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        aboutVC.schoolName = schoolInfo.name
        aboutVC.info = self.schoolInfo
        self.show(aboutVC, sender: self)
    }
    
    
    /// Description:
    /// - Check if the button is checking for OTP or reset password in order to call the suitable API.
    @IBAction func bt_forgotPasswordWasPressed(_ sender: Any) {
//        App.showMessageAlert(self, title: "", message: "This feature is not active".localiz(), dismissAfter: 2.0)
        if !resetPassword{
            if !txt_username.text!.isEmpty{
                self.SignIn(userName: txt_username.text!, password: txt_password.text!, schoolUrl: schoolInfo.schoolURL, grantType: "nopassword")
            }else{
                //here
                App.showMessageAlert(self, title: "", message: "Enter username to reset your password".localiz(), dismissAfter: 1.5)
            }
        }else{
            self.sendOTP(userName: txt_username.text!, type: self.type, user: self.user)
        }
    }
    
    @IBAction func rememberMeButtonPressed(_ sender: Any) {
        rememberMeButton.isToggled = !rememberMeButton.isToggled
        if rememberMeButton.isToggled {
            rememberMeView.alpha = 1
        } else {
            rememberMeView.alpha = 0
        }
    }
    
    @IBAction func bt_showPasswordWasPressed(_ sender: Any) {
        txt_password.isSecureTextEntry.toggle()
    }
    
    @IBAction func bt_showPasswordWasHolded(_ sender: Any) {
//         txt_password.isSecureTextEntry = false
    }
    
    
    /// Description:
    /// - Open Action  Picker.
    @IBAction func usernameButtonPressed(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Select username".localiz(), rows: userNameArray, initialSelection: 0, doneBlock: {
            picker, ind, values in
            
            self.txt_username.text = self.userNameArray[ind]
            return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func rightDropDownButtonPressed(_ sender: Any) {
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Description:
    /// - Check if the field is checking for OTP or password in order to call the suitable API.
    @IBAction func bt_loginWasPressed(_ sender: Any) {
        if !resetPassword{
            self.SignIn(userName: txt_username.text!, password: txt_password.text!, schoolUrl: schoolInfo.schoolURL, grantType: "password")
        }else{
            self.verifyOTP(user: self.user, code: txt_password.text!)
        }
    }
    
    /// Description:
    /// - Google sign in configuration, if the account isn't signed out it will sign in without asking for permissions.
    @IBAction func googleSignInButtonPressed(_ sender: Any) {
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)

//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance()?.presentingViewController = self
//
//        if ((GIDSignIn.sharedInstance()?.hasPreviousSignIn()) != nil){
//            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
//        }else{
//            GIDSignIn.sharedInstance().signIn()
//        }
    }
    
    
    /// Description:
    /// - Microsoft Login configuration.
    @IBAction func microsoftButtonPressed(_ sender: Any) {
        print("microsoft pressed")
        callGraphAPI()
//        App.showMessageAlert(self, title: "", message: "Feature coming soon".localiz(), dismissAfter: 2.0)
//        // SignIn:
//        do {
//
//            // We check to see if we have a current logged in user. If we don't, then we need to sign someone in.
//            // We throw an interactionRequired so that we trigger the interactive signin.
//
//            if  try self.applicationContext.users().isEmpty {
//
//                throw NSError.init(domain: "MSALErrorDomain", code: MSALErrorCode.interactionRequired.rawValue, userInfo: nil)
//            } else {
//
//                // Acquire a token for an existing user silently
//
//                try self.applicationContext.acquireTokenSilent(forScopes: self.kScopes, user: applicationContext.users().first) { (result, error) in
//
//                    if error == nil {
//                        self.accessToken = (result?.accessToken)!
//                        print(self.accessToken)
////                        self.loggingText.text = "Refreshing token silently)"
////                        self.loggingText.text = "Refreshed Access token is \(self.accessToken)"
////
////                        self.signoutButton.isEnabled = true;
//                        self.getContentWithToken()
//
//                    } else {
//                        print("Could not acquire token silently: \(error ?? "No error information" as! Error)")
////                        self.loggingText.text = "Could not acquire token silently: \(error ?? "No error information" as! Error)"
//
//                    }
//                }
//            }
//        }  catch let error as NSError {
//            print(error.localizedDescription)
//            // interactionRequired means we need to ask the user to sign-in. This usually happens
//            // when the user's Refresh Token is expired or if the user has changed their password
//            // among other possible reasons.
//
//            if error.code == MSALErrorCode.interactionRequired.rawValue {
//
//                self.applicationContext.acquireToken(forScopes: self.kScopes) { (result, error) in
//                    if error == nil {
//                        self.accessToken = (result?.accessToken)!
////                        self.loggingText.text = "Access token is \(self.accessToken)"
////                        self.signoutButton.isEnabled = true;
//                        self.getContentWithToken()
//
//                    } else  {
//                        print("Could not acquire token: \(error ?? "No error information" as! Error)")
////                        self.loggingText.text = "Could not acquire token: \(error ?? "No error information" as! Error)"
//                    }
//                }
//
//            }
//        } catch {
//
//            // This is the catch all error.
//            print("Unable to acquire token. Got error: \(error)")
////            self.loggingText.text = "Unable to acquire token. Got error: \(error)"
//        }
//
//        //SignOut:
////        do {
////
////            // Removes all tokens from the cache for this application for the provided user
////            // first parameter:   The user to remove from the cache
////
////            try self.applicationContext.remove(self.applicationContext.users().first)
////            self.signoutButton.isEnabled = false;
////
////        } catch let error {
////            self.loggingText.text = "Received error signing user out: \(error)"
////        }
        
    }
    
    
    /// Description:
    /// - Microsoft Login configuration.
//    func getContentWithToken() {
//        let indicatorView = App.loading()
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
//        let sessionConfig = URLSessionConfiguration.default
//
//        // Specify the Graph API endpoint
//        let url = URL(string: kGraphURI)
//        var request = URLRequest(url: url!)
//
//        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
//        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
//        let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
//
//        urlSession.dataTask(with: request) { data, response, error in
//            let result = try? JSONSerialization.jsonObject(with: data!, options: [])
//            if result != nil {
////                print(result.debugDescription)
//                let json = JSON(result ?? "")
//                let id = json["id"].stringValue
//                let firstName = json["givenName"].stringValue
//                let lastName = json["surname"].stringValue
//                let displayName = json["displayName"].stringValue
//                let userName = json["userPrincipalName"].stringValue
//                print("id: \(id)\nfirstName: \(firstName)\nlastName: \(lastName)\ndisplayName: \(displayName)\nuserName: \(userName)")
////                self.showHome()
////                self.loggingText.text = result.debugDescription
//                if let viewWithTag = self.view.viewWithTag(100){
//                    viewWithTag.removeFromSuperview()
//                }
//            }else{
//                if let viewWithTag = self.view.viewWithTag(100){
//                    viewWithTag.removeFromSuperview()
//                }
//            }
//            }.resume()
//    }
    
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource:
extension LoginVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return schoolDataArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = schoolLogoCollectionView.dequeueReusableCell(withReuseIdentifier: "schoolCellReuse", for: indexPath)
        let logoImageView = cell.viewWithTag(1) as! UIImageView
        let xButton = cell.viewWithTag(5) as! UIButton
        
        switch indexPath.row{
        /// Description:
        /// - case 0 is add school case.
        case 0:
            logoImageView.image = UIImage(named: schoolLogoArray[indexPath.row])
            logoImageView.backgroundColor = .clear
            logoImageView.alpha = 1
            logoImageView.layer.borderWidth = 0
            xButton.isHidden = true
        default:
            let school = self.schoolDataArray[indexPath.row - 1]
            let url = URL(string: school.logo)
            logoImageView.backgroundColor = App.hexStringToUIColorCst(hex: "#D1D3D4", alpha: 0.3)
            App.addImageLoader(imageView: logoImageView, button: nil)
            logoImageView.sd_setImage(with: url) { (image, error, cache, url) in
                App.removeImageLoader(imageView: logoImageView, button: nil)
            }
            xButton.isHidden = false
            xButton.addTarget(self, action: #selector(xButtonPressed), for: .touchUpInside)
            
            if school.schoolId == self.schoolInfo.schoolId{
                logoImageView.alpha = 1
                logoImageView.layer.borderWidth = 1
                logoImageView.layer.borderColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0).cgColor
                UserDefaults.standard.set(schoolInfo.id, forKey: "SCHOOLID")
                UserDefaults.standard.set(schoolInfo.schoolURL, forKey: "BASEURL")
            }else{
                logoImageView.alpha = 0.5
                logoImageView.layer.borderWidth = 0
            }
        }
        logoImageView.layer.cornerRadius = logoImageView.frame.width / 2
        cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row{
        /// Description:
        /// - Back key is used to pop Activation page on submit instead of load a new login view.
        /// - Delegate is inialized to update the selected school on submit from Activation page.
        case 0:
            let storyboard = UIStoryboard(name: "GettingStarted", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ActivationVC") as! ActivationVC
            vc.back = true
            vc.delegate = self
            self.show(vc, sender: self)
        /// Description:
        /// - Update current school id and URL saved into userdefaults.
        default:
            let school = self.schoolDataArray[indexPath.row - 1]
            self.schoolInfo = school
            UserDefaults.standard.set(self.schoolInfo.id, forKey: "SCHOOLID")
            UserDefaults.standard.set(self.schoolInfo.schoolURL, forKey: "BASEURL")
            let url = URL(string: self.schoolInfo.logo)
            App.addImageLoader(imageView: self.schoolLogo, button: nil)
            self.schoolLogo.sd_setImage(with: url) { (image, error, cache, url) in
                App.removeImageLoader(imageView: self.schoolLogo, button: nil)
            }
            self.schoolLogoCollectionView.reloadData()
        }
    }
    
    /// Description:
    /// - Remove selected school from the list of schools and core data.
    /// - Call configureSchoolLogo to select the next school as selected school.
    @objc func xButtonPressed(sender: UIButton){
        let cell = sender.superview?.superview as! UICollectionViewCell
        let index = schoolLogoCollectionView.indexPath(for: cell)
        let schoolId = self.schoolDataArray[index!.row - 1].schoolId
        let ok = UIAlertAction(title: "OK".localiz(), style: .default) { (UIAlertAction) in
            _ = App.removeSchoolUsers(activationCode: schoolId)
            self.configureSchoolLogo()
//            self.backButton.isHidden = true
        }
        let cancel = UIAlertAction(title: "CANCEL".localiz(), style: .default, handler: nil)
        App.showAlert(self, title: "", message: "Are you sure you want to remove this school ?".localiz(), actions: [ok,cancel])
    }
    
}


// MARK: - GIDSignInUIDelegate, GIDSignInDelegate:
//extension LoginVC: GIDSignInDelegate{
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//
//        if (error == nil) {
////            let userId = user.userID
//            let idToken = user.authentication.idToken
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email
////            var pic = URL(string: "")
////            if user.profile.hasImage{
////                pic = user.profile.imageURL(withDimension: 100)
////            }
//
//            if givenName == "" || familyName == ""{
//                let returnAction = UIAlertAction(title: "Return".localiz(), style: UIAlertAction.Style.default, handler: nil)
//                App.showAlert(self, title: "Error".localiz(), message: "Can't access all required fields from this google account".localiz(), actions: [returnAction])
//                GIDSignIn.sharedInstance().signOut()
//            }
//            else{
////                print("userId: \(userId!)\nidToken: \(idToken!)\nfirstName: \(givenName!)\nlastName: \(familyName!)\nemail: \(email!)")
////                self.SignIn(userName: "", password: "", email: email!, token: idToken!, clientId: "fb9d80c20956d2e489322564b6b0ef2262b92d51e7d527408567ef4feb3cc045", clientSecret: "bc8a340bdcb3baef7cd031df3f3b843fabfff4561fccae6e647d8812c3e0531a", grantType: "google")
//            }
//        }
//
//        if let viewWithTag = self.view.viewWithTag(100){
//            viewWithTag.removeFromSuperview()
//        }
//    }
//
//    // Implement these methods only if the GIDSignInUIDelegate is not a subclass of
//    // UIViewController.
//    // Stop the UIActivityIndicatorView animation that was started when the user
//    // pressed the Sign In button
////    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
////        //        UIActivityIndicatorView.stopAnimating()
////    }
////    // Present a view that prompts the user to sign in with Google
////    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
////        self.show(viewController, sender: self)
////        self.present(viewController, animated: true, completion: nil)
////    }
////    // Dismiss the "Sign in with Google" view
////    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
////        self.dismiss(animated: true, completion: nil)
////    }
////    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
////              withError error: Error!) {
////        // Perform any operations when the user disconnects from app here.
////        // ...
////    }
//}


// MARK: - ResetPasswordDelegate, ChangePasswordDelegate:
extension LoginVC: ResetPasswordDelegate, ChangePasswordDelegate{
    
    /// Description:
    /// - Update the design view to be able to reset the password and submit the OTP to the API.
    func forgetPassword(username: String, type: String) {
        resetPassword = true
        txt_username.isUserInteractionEnabled = false
        rightDropDownButton.isUserInteractionEnabled = false
        usernameDropdownImage.isHidden = true
        usernameButton.isHidden = true
        usernameButton.isUserInteractionEnabled = false
        lockImageView.isHidden = true
        showPasswordButton.isHidden = true
        txt_password.isSecureTextEntry = false
        txt_password.placeholder = "OTP".localiz()
        forgetPasswordButton.setTitle("Resend OTP".localiz(), for: .normal)
//        here
        self.type = type
        rememberMeView.isHidden = true
        rememberMeButton.isHidden = true
        rememberMeLabel.isHidden = true
        if !multiSchool{
            userNameArray = ["\(username)"]
        }
    }
    
    /// Description:
    /// - Reset the design view to the default.
    /// - Call sign in function to automatic sign in once the user successfully reset his password.
    func saveNewPassword(user: User, password: String) {
        getLoggedInUsers()
        resetPassword = false
        txt_username.isUserInteractionEnabled = true
        rightDropDownButton.isHidden = false
        rightDropDownButton.isUserInteractionEnabled = true
        usernameDropdownImage.isHidden = false
        usernameButton.isHidden = true
        usernameButton.isUserInteractionEnabled = true
        lockImageView.isHidden = true
        showPasswordButton.isHidden = false
        txt_password.isSecureTextEntry = true
        txt_password.placeholder = "Password".localiz()
        txt_password.text = ""
        forgetPasswordButton.isHidden = true
        forgetPasswordButton.setTitle("I forgot my password".localiz(), for: .normal)
        rememberMeView.isHidden = false
        rememberMeButton.isHidden = false
        rememberMeLabel.isHidden = false
        rememberMeButton.isToggled = true
        
//        self.SignIn(userName: user.userName, password: password, email: "", token: "", clientId: "fb9d80c20956d2e489322564b6b0ef2262b92d51e7d527408567ef4feb3cc045", clientSecret: "bc8a340bdcb3baef7cd031df3f3b843fabfff4561fccae6e647d8812c3e0531a", grantType: "password")
        
        self.SignIn(userName: user.userName, password: password, schoolUrl: schoolInfo.schoolURL, grantType: "password")
    }
    
    
    /// Description:
    /// - Update data model version due to the app updates.
    /// - Redirect to tab bar with needed data.
    func showHome(){
        let modelVersion = UserDefaults.standard.integer(forKey: "VERSION")
        if modelVersion < App.dbVersion{
            UserDefaults.standard.set(App.dbVersion, forKey: "VERSION")
        }
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier:"TabBarViewController") as! TabBarViewController
        vc.user = self.user
        vc.loggedInUser = self.user
        vc.schoolInfo = self.schoolInfo
        vc.appTheme = self.appTheme
        self.show(vc, sender: self)
    }
}


// MARK: - ActivationVCDelegate:
extension LoginVC: ActivationVCDelegate{
    
    /// Description:
    /// - Update school info data on school activate successfully.
    func updateSchoolInfo(schooldData: SchoolActivation) {
        self.schoolInfo = schooldData
    }
}


// MARK: - API Calls:
extension LoginVC{
    
    
    /// Description:
    /// - Call token API in two grant type cases.
    /// - Case of login call saveUser function.
    func SignIn(userName: String, password: String, schoolUrl: String, grantType: String){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.SignIn(userName: userName, password: password, schoolUrl: schoolUrl, grantType: grantType) { (message, userData, status) in
            if status == 200{
                self.updateUserDetails(id: userData!.userId, token: userData!.token, schoolUrl: schoolUrl, password: userData!.password)
                print("user user: \(self.user)")
//                if grantType == "nopassword"{
//                    self.getPhoneAndEmail(userName: userName, user: self.user)
//                }else{
//                    self.saveUser(userData: userData)
//                }
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
    
    func updateUserDetails(id: Int, token: String, schoolUrl: String, password: String){
            let indicatorView = App.loading()
            indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            indicatorView.tag = 100
            self.view.addSubview(indicatorView)
    
        Request.shared.getUserDetails(id: id, token: token, schoolUrl: schoolUrl, password: password, completion: { (message, userData, status) in
                if status == 200{
                    print("entered updateUserDetails")
                    print(userData)
                    self.user = userData
                    self.saveUser(userData: userData)
                    self.customizeView()
                    print("user user1: \(self.user)")

                    /// modelVersion variable is the core data model version, used to check if the core data model has been changed to delete users data and resign in again.
                  
    
                    if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                    }
                }
                else{
                    if let viewWithTag = self.view.viewWithTag(100){
                        viewWithTag.removeFromSuperview()
                    }
                }
            })
        }
    
    /// Description:
    /// - Call get_phone_or_email API to get the needed infos for forget password case.
    func getPhoneAndEmail(userName: String, user: User){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        Request.shared.GetPhoneEmail(username: userName, user: user) { (message, emailData, phoneData, status)  in
            if status == 200{
                if emailData!.isEmpty && phoneData!.isEmpty{
                    App.showMessageAlert(self, title: "", message: "Please contact your school".localiz(), dismissAfter: 1.5)
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier:"ResetPasswordModalVC") as? ResetPasswordModalVC
                    vc?.modalTransitionStyle = .crossDissolve
                    vc?.delegate = self
                    vc?.email = emailData!
                    vc?.phone = phoneData!
                    vc?.user = self.user
                    vc?.schoolInfo = self.schoolInfo
                    vc?.modalPresentationStyle = .fullScreen
                    self.present(vc!, animated: true)
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
    
    
    /// Description:
    /// Fetch users username from core data.
    func getUsers() -> [String]{
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
        let users = try? managedContext.fetch(userFetchRequest) as! [USER]
        var usersArray: [String] = []
        if users != nil{
            for user in users!{
                usersArray.append(user.username!)
            }
        }
        return usersArray
    }
    
    
    /// Description:
    /// - Fetch user userID from core data.
    func getUsersID() -> [Int]{
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
        let users = try? managedContext.fetch(userFetchRequest) as! [USER]
        var usersID: [Int] = []
        if users != nil{
            for user in users!{
                usersID.append(user.integer(forKey: "userId"))
            }
        }
        return usersID
    }
    
    /// Description:
    /// - Save user data and class data to core data.
    func saveUser(userData: User?){
        //add user to firebase
        let userIdentifier = (UserDefaults.standard.string(forKey: "BASEURL")?.description ?? "nourl") + " - " + (userData?.userName ?? "N/A")
//        Crashlytics.sharedInstance().setUserIdentifier(userIdentifier)
        Crashlytics.crashlytics().setUserID(userIdentifier)
//        Crashlytics.Crashlytics.setUserIdentifier(userIdentifier)
        print("reacher reacher1")


        if userData?.userType == 4{
            guard let child = userData?.childrens.filter({$0.admissionNo == self.user.childrens.first?.admissionNo}).first else { return }
            let children = Children(gender: child.gender, cycle: child.cycle, photo: child.photo, firstName: child.firstName, lastName: child.lastName, batchId: child.batchId, imperiumCode: child.imperiumCode, className: child.className, admissionNo: child.admissionNo, bdDate: child.bdDate, isBdChecked: child.isBdChecked)
            
            
            self.user = User(token: userData!.token,userName: self.user.userName, schoolId: self.schoolInfo.schoolId, firstName: child.firstName, lastName: child.lastName, userId: userData!.userId, email: userData!.email, googleToken: userData!.googleToken, gender: child.gender, cycle: child.cycle, photo: child.photo, userType: userData!.userType, batchId: child.batchId, imperiumCode: child.imperiumCode, className: child.className, childrens: [children], classes: [], privileges: userData!.privileges, firstLogin: userData!.firstLogin, admissionNo: child.admissionNo, bdDate: child.bdDate, isBdChecked: child.isBdChecked, blocked: userData!.blocked, password: userData!.password)
        }else{
            self.user = User(token: userData!.token, userName: userData!.userName, schoolId: self.schoolInfo.schoolId, firstName: userData!.firstName, lastName: userData!.lastName, userId: userData!.userId, email: userData!.email, googleToken: userData!.googleToken, gender: userData!.gender, cycle: userData!.cycle, photo: userData!.photo, userType: userData!.userType, batchId: userData!.batchId, imperiumCode: userData!.imperiumCode, className: userData!.className, childrens: userData!.childrens, classes: userData!.classes, privileges: userData!.privileges, firstLogin: userData!.firstLogin, admissionNo: userData!.admissionNo, bdDate: userData?.bdDate ?? Date(), isBdChecked: userData?.isBdChecked ?? false, blocked: userData!.blocked, password: userData!.password)
        }
        
//            if self.rememberMeButton.isToggled{
//                UserDefaults.standard.set(true, forKey: "REMEMBERME")
//            }
            let usersId = self.getUsersID()
            print("reacher reacher")
            print(usersId)
            print(self.user.userId)

            if !usersId.contains(self.user.userId){
                if user.userType == 4{
                    for child in userData!.childrens{
                        print("children children login: \(child)")
                        let classEntity = NSEntityDescription.entity(forEntityName: "CLASS", in: self.managedContext)
                        let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                        childClass.batchId = Int64(child.batchId)
                        childClass.classname = child.className
                        childClass.imperiumCode = child.imperiumCode
                        
                        let userEntity = NSEntityDescription.entity(forEntityName: "USER", in: self.managedContext)
                        let newUser = NSManagedObject(entity: userEntity!, insertInto: self.managedContext)
                        newUser.setValue(child.batchId, forKey: "batchId")
                        newUser.setValue(child.className, forKey: "classname")
                        newUser.setValue(child.cycle, forKey: "cycle")
                        newUser.setValue(child.firstName, forKey: "firstName")
                        newUser.setValue(child.gender, forKey: "gender")
                        newUser.setValue(child.imperiumCode, forKey: "imperiumCode")
                        newUser.setValue(child.lastName, forKey: "lastName")
                        newUser.setValue(child.photo, forKey: "photo")
                        newUser.setValue(child.bdDate, forKey: "dob")
                        newUser.setValue(child.isBdChecked, forKey: "isBdChecked")
                        newUser.setValue(self.user.privileges, forKey: "privileges")
                        newUser.setValue(self.user.schoolId, forKey: "schoolId")
                        newUser.setValue(child.admissionNo, forKey: "studentUsername")
                        newUser.setValue(self.user.token, forKey: "token")
                        newUser.setValue(self.user.userId, forKey: "userId")
                        newUser.setValue(self.user.email, forKey: "email")
                        newUser.setValue(self.user.userName, forKey: "username")
                        newUser.setValue(self.user.userType, forKey: "userType")
                        newUser.setValue(self.user.blocked, forKey: "blocked")
                        newUser.setValue(self.user.password, forKey: "password")
                        newUser.setValue(NSOrderedSet(object: childClass), forKey: "classes")
                        do{
                            try self.managedContext.save()
                        }catch{}
                    }
                }else{
                    let classEntity = NSEntityDescription.entity(forEntityName: "CLASS", in: self.managedContext)
                    var classArray = [NSManagedObject]()
                    if self.user.userType == 2{
                        for classObject in self.user.classes{
                            let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                            childClass.batchId = Int64(classObject.batchId)
                            childClass.classname = classObject.className
                            childClass.imperiumCode = classObject.imperiumCode
                            classArray.append(childClass)
                        }
                    }else{
                        let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                        childClass.batchId = Int64(self.user.batchId)
                        childClass.classname = self.user.className
                        childClass.imperiumCode = self.user.imperiumCode
                        classArray.append(childClass)
                    }
                    let userEntity = NSEntityDescription.entity(forEntityName: "USER", in: self.managedContext)
                    let newUser = NSManagedObject(entity: userEntity!, insertInto: self.managedContext)
                    newUser.setValue(self.user.batchId, forKey: "batchId")
                    newUser.setValue(self.user.className, forKey: "classname")
                    newUser.setValue(self.user.cycle, forKey: "cycle")
                    newUser.setValue(self.user.firstName, forKey: "firstName")
                    newUser.setValue(self.user.gender, forKey: "gender")
                    newUser.setValue(self.user.imperiumCode, forKey: "imperiumCode")
                    newUser.setValue(self.user.lastName, forKey: "lastName")
                    newUser.setValue(self.user.photo, forKey: "photo")
                    newUser.setValue(self.user.privileges, forKey: "privileges")
                    newUser.setValue(self.user.schoolId, forKey: "schoolId")
                    newUser.setValue(self.user.admissionNo, forKey: "studentUsername")
                    newUser.setValue(self.user.token, forKey: "token")
                    newUser.setValue(self.user.userId, forKey: "userId")
                    newUser.setValue(self.user.email, forKey: "email")
                    newUser.setValue(self.user.userName, forKey: "username")
                    newUser.setValue(self.user.userType, forKey: "userType")
                    newUser.setValue(self.user.bdDate, forKey: "dob")
                    newUser.setValue(self.user.isBdChecked, forKey: "isBdChecked")
                    newUser.setValue(self.user.blocked, forKey: "blocked")
                    newUser.setValue(self.user.password, forKey: "password")
                    newUser.setValue(NSOrderedSet(array: classArray), forKey: "classes")
                    do{
                        try self.managedContext.save()
                    }catch{}
                }
            }else{
                let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USER")
                let users = try? self.managedContext.fetch(userFetchRequest) as! [USER]
                if users != nil{
                    for object in users!{
                        if object.username == self.user.userName{
                            if self.user.userType == 4{
                                for child in self.user.childrens{
                                    
                                    print("children children login111: \(child)")

                                    if object.studentUsername == child.admissionNo{
                                        let classEntity = NSEntityDescription.entity(forEntityName: "CLASS", in: self.managedContext)
                                        let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                                        childClass.batchId = Int64(child.batchId)
                                        childClass.classname = child.className
                                        childClass.imperiumCode = child.imperiumCode
                                        
                                        object.setValue(child.batchId, forKey: "batchId")
                                        object.setValue(child.className, forKey: "classname")
                                        object.setValue(child.cycle, forKey: "cycle")
                                        object.setValue(child.firstName, forKey: "firstName")
                                        object.setValue(child.gender, forKey: "gender")
                                        object.setValue(child.imperiumCode, forKey: "imperiumCode")
                                        object.setValue(child.lastName, forKey: "lastName")
                                        object.setValue(child.photo, forKey: "photo")
                                        object.setValue(child.bdDate, forKey: "dob")
                                        object.setValue(child.isBdChecked, forKey: "isBdChecked")
                                        object.setValue(self.user.privileges, forKey: "privileges")
                                        object.setValue(self.schoolInfo.schoolId, forKey: "schoolId")
                                        object.setValue(child.admissionNo, forKey: "studentUsername")
                                        object.setValue(self.user.token, forKey: "token")
                                        object.setValue(self.user.userId, forKey: "userId")
                                        object.setValue(self.user.userName, forKey: "username")
                                        object.setValue(self.user.userType, forKey: "userType")
                                        object.setValue(self.user.blocked, forKey: "blocked")
                                        object.setValue(self.user.password, forKey: "password")
                                        object.setValue(NSOrderedSet(object: childClass), forKey: "classes")
                                        do{
                                            try self.managedContext.save()
                                        }catch{}
                                    }
                                }
                            }else{
                                let classEntity = NSEntityDescription.entity(forEntityName: "CLASS", in: self.managedContext)
                                var ChildArray = [NSManagedObject]()
                                if self.user.userType == 2{
                                    for classObject in self.user.classes{
                                        let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                                        childClass.batchId = Int64(classObject.batchId)
                                        childClass.classname = classObject.className
                                        childClass.imperiumCode = classObject.imperiumCode
                                        ChildArray.append(childClass)
                                    }
                                }else{
                                    let childClass = CLASS(entity: classEntity!, insertInto: self.managedContext)
                                    childClass.batchId = Int64(self.user.batchId)
                                    childClass.classname = self.user.className
                                    childClass.imperiumCode = self.user.imperiumCode
                                    ChildArray.append(childClass)
                                }
                                
                                object.setValue(self.user.batchId, forKey: "batchId")
                                object.setValue(self.user.className, forKey: "classname")
                                object.setValue(self.user.cycle, forKey: "cycle")
                                object.setValue(self.user.firstName, forKey: "firstName")
                                object.setValue(self.user.gender, forKey: "gender")
                                object.setValue(self.user.imperiumCode, forKey: "imperiumCode")
                                object.setValue(self.user.lastName, forKey: "lastName")
                                object.setValue(self.user.photo, forKey: "photo")
                                object.setValue(self.user.bdDate, forKey: "dob")
                                object.setValue(self.user.isBdChecked, forKey: "isBdChecked")
                                object.setValue(self.user.privileges, forKey: "privileges")
                                object.setValue(self.schoolInfo.schoolId, forKey: "schoolId")
                                object.setValue(self.user.admissionNo, forKey: "studentUsername")
                                object.setValue(self.user.token, forKey: "token")
                                object.setValue(self.user.userId, forKey: "userId")
                                object.setValue(self.user.email, forKey: "email")
                                object.setValue(self.user.userName, forKey: "username")
                                object.setValue(self.user.userType, forKey: "userType")
                                object.setValue(self.user.blocked, forKey: "blocked")
                                object.setValue(self.user.password, forKey: "password")
                                object.setValue(NSOrderedSet(array: ChildArray), forKey: "classes")
                            }
                        }
                    }
                }
            }
            do{
                try self.managedContext.save()
            }catch{}
            
            self.saveSuggestions()
            self.getTabBarIcons(schoolId: "\(self.schoolInfo!.id)", classId: self.user.batchId, code: self.user.imperiumCode, gender: self.user.gender)
            self.setDeviceToken(user: self.user, deviceId: self.uuid, deviceToken: self.deviceToken ?? "")
        
    }
    
    /// Description:
    /// - Save loggedin user's username in core data.
    func saveSuggestions(){
        if !self.userNameArray.contains(self.user.userName){
                let userEntity = NSEntityDescription.entity(forEntityName: "SUGGESTION", in: self.managedContext)
                let newUser = NSManagedObject(entity: userEntity!, insertInto: self.managedContext)
                newUser.setValue(self.user.userName, forKey: "username")
                do{
                    try self.managedContext.save()
                }catch{}
        }
    }
    
    /// Description: GetIcons
    /// - Call getClassIcons API to get icons and colors of the selected schoold and class.
    func getTabBarIcons(schoolId: String, classId: Int, code: String, gender: String){
//        let indicatorView = App.loading()
//        indicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
//        indicatorView.tag = 100
//        self.view.addSubview(indicatorView)
//
//        Request.shared.GetClassIcons(user: self.user, schoolID: schoolId, classID: classId, code: code, gender: gender) { (message,data,status) in
//            if status == 200{
//                self.appTheme = data
        
        print("getTabBarIcons entered")
                if self.user.firstLogin{
                    self.showChangePassword()
                }else{
                    self.showHome()
                }
//            }
//            else{
//                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
//                App.showAlert(self, title: "ERROR".localiz(), message: message!, actions: [ok])
//            }
//            if let viewWithTag = self.view.viewWithTag(100){
//                viewWithTag.removeFromSuperview()
//            }
//        }
    }
    
    /// Description: Resend OTP
    /// - Call sendOTP API to resent a new OTP.
    func sendOTP(userName: String, type: String, user: User){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        Request.shared.SendOTP(type: type, user: user) { (message, data, status)  in
            if status == 200{}
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    /// Description: Verify Code
    /// - Call verifyOTP API to check if the OTP is correct or not.
    /// - On success call showChangePassword function.
    func verifyOTP(user: User, code: String){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        Request.shared.verifyCode(user: user, code: code) { (message, data, status) in
            if status == 200{
                self.showChangePassword()
            }else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message ?? "", actions: [ok])
                self.txt_password.text = ""
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }
    
    func showChangePassword(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChangePasswordModalVC") as! ChangePasswordModalVC
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        vc.user = self.user
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    /// Description: Set Device Token
    /// - Request to set_token API that send the device token in order to receive notification.
    func setDeviceToken(user: User, deviceId: String, deviceToken: String){
        Request.shared.setDeviceToken(user: user, deviceId: deviceId, deviceToken: deviceToken) { (message, data, status) in
        }
    }
    
}

