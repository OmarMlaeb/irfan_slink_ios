//
//  LanguageVC.swift
//  Madrasati
//
//  Created by Tarek on 5/3/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class LanguageVC: UIViewController {

    @IBOutlet weak var armenianClickableView: ArmenianBubbleView!
    @IBOutlet weak var frenchClickableView: FrenchBubbleView!
    @IBOutlet weak var englishClickableView: EnglishBubbleView!
    @IBOutlet weak var txt_armenian: UILabel!
    @IBOutlet weak var txt_english: UILabel!
    @IBOutlet weak var txt_francais: UILabel!
    @IBOutlet weak var txt_arabic: UILabel!
    @IBOutlet weak var bt_next: RoundedButton!
    @IBOutlet weak var bt_english: UIButton!
    @IBOutlet weak var bt_francais: UIButton!
    @IBOutlet weak var bt_arabic: UIButton!
    @IBOutlet weak var bt_armenian: UIButton!
    @IBOutlet weak var arabicClickableView: ArabicBubbleView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var setting = false
    var languageId: String?
    
    /// Description:
    /// Set languages bubble colors:
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        frenchClickableView.fillColor = UIColor(red: 0.497, green: 0.419, blue: 0.634, alpha: 1.000)
        frenchClickableView.setNeedsDisplay()
        englishClickableView.fillColor = UIColor(red: 0.826, green: 0.860, blue: 0.205, alpha: 1.000)
        englishClickableView.setNeedsDisplay()
        arabicClickableView.fillColor = UIColor(red: 0.531, green: 0.752, blue: 0.254, alpha: 1.000)
        arabicClickableView.setNeedsDisplay()
        armenianClickableView.fillColor = UIColor(red: 0.84, green: 0.25, blue: 0.25, alpha: 1.000)
        armenianClickableView.setNeedsDisplay()
    }
    
    /// Description:
    /// - In case this page was oppening from the settings, navigation bar should appear otherwise shouldn't.
    override func viewWillAppear(_ animated: Bool) {
        if setting{
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            initNavigation()
        }else{
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    
    /// Description:
    /// - This function is used to configure the navigation bar and override the default back button.
    func initNavigation(){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Language".localiz()
        let backButton = UIBarButtonItem(title: nil, style: .done, target: self, action: #selector(backButtonPressed))
        backButton.image = UIImage(named: "white-nav-back")
        backButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.barTintColor = App.hexStringToUIColorCst(hex: "#568EF6", alpha: 1.0)
        self.navigationController?.navigationBar.backgroundColor = App.hexStringToUIColorCst(hex: "#568EF6", alpha: 1.0)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 18)!]
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// Description: for Francais, Arabic and English
    /// - Reset all bubble views and make the next button active.
    /// - Set the languageId based on the selected one.
    /// - Make the selected bubble selected by updating the view using UIBezierPath.
    /// - After selecting a language, if the screen device is small, the view will scroll to the next bottom.
    @IBAction func bt_francaisWasPressed(_ sender: Any) {
        untoggle()
        bt_next.alpha = 1
        bt_francais.isUserInteractionEnabled = false
        self.languageId = "fr"
        UIView.animate(withDuration: 0.2) {
            self.frenchClickableView.isToggle = true
            self.frenchClickableView.setNeedsDisplay()
            self.txt_francais.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.scrollToBottom()
        }
    }
    
    @IBAction func bt_armenianWasPressed(_ sender: Any) {
        untoggle()
        bt_next.alpha = 1
        bt_armenian.isUserInteractionEnabled = false
        self.languageId = "hy"
        UIView.animate(withDuration: 0.2) {
            self.armenianClickableView.isToggle = true
            self.armenianClickableView.setNeedsDisplay()
            self.txt_armenian.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.scrollToBottom()
        }
    }
    
    @IBAction func bt_arabicWasPressed(_ sender: Any) {
        untoggle()
        bt_next.alpha = 1
        bt_arabic.isUserInteractionEnabled = false
        self.languageId = "ar"
        UIView.animate(withDuration: 0.2) {
            self.arabicClickableView.isToggle = true
            self.arabicClickableView.setNeedsDisplay()
            self.txt_arabic.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.scrollToBottom()
        }
    }
    
    @IBAction func bt_englishWasPressed(_ sender: Any) {
        untoggle()
        bt_next.alpha = 1
        bt_english.isUserInteractionEnabled = false
        self.languageId = "en"
        UIView.animate(withDuration: 0.2) {
            self.englishClickableView.isToggle = true
            self.englishClickableView.setNeedsDisplay()
            self.txt_english.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.scrollToBottom()
        }
    }
    
    
    /// Description:
    /// - After next button pressed we need to check if the langauge has changed or not.
    /// - If the language has changed, we need to update it in LanguageManager.
    /// - We need to check if the user open this page from settings to restart the app to apply the changes.
    @IBAction func bt_nextWasPressed(_ sender: Any) {
         if self.setting{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default) { (UIAlertAction) in
                switch self.languageId{
                case "ar":
                   LanguageManger.shared.setLanguage(language: .ar)
                   UserDefaults.standard.set("ar", forKey: "LanguageId")
                case "fr":
                   LanguageManger.shared.setLanguage(language: .fr)
                   UserDefaults.standard.set("fr", forKey: "LanguageId")
                case "hy":
                   LanguageManger.shared.setLanguage(language: .hy)
                   UserDefaults.standard.set("hy", forKey: "LanguageId")
                default:
                   LanguageManger.shared.setLanguage(language: .en)
                   UserDefaults.standard.set("en", forKey: "LanguageId")
                }
                //exit the app so the user can re-launch it and the app language gets updated
                exit(0)
            }
            let cancel = UIAlertAction(title: "Cancel".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "Language Change".localiz(), message: "Are you sure you want to change the language ? This requires the app to be restarted, please re-enter the app after it exits".localiz(), actions: [ok,cancel])
        }else{
            switch self.languageId{
            case "ar":
                LanguageManger.shared.setLanguage(language: .ar)
                UserDefaults.standard.set("ar", forKey: "LanguageId")
            case "fr":
                LanguageManger.shared.setLanguage(language: .fr)
                UserDefaults.standard.set("fr", forKey: "LanguageId")
            case "hy":
                LanguageManger.shared.setLanguage(language: .hy)
                UserDefaults.standard.set("hy", forKey: "LanguageId")
            default:
                LanguageManger.shared.setLanguage(language: .en)
                UserDefaults.standard.set("en", forKey: "LanguageId")
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ActivationVC") as! ActivationVC
            self.show(vc, sender: self)
        }
    }
    
    
    /// Description:
    /// - This functions is used to scroll to the next button.
    func scrollToBottom(){
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    
    /// Description:
    /// - This function is used to reset all the bubble views.
    func untoggle() {
        englishClickableView.isToggle = false
        englishClickableView.setNeedsDisplay()
        txt_english.textColor = #colorLiteral(red: 0.8431372549, green: 0.8745098039, blue: 0.137254902, alpha: 1)
        
        frenchClickableView.isToggle = false
        frenchClickableView.setNeedsDisplay()
        txt_francais.textColor = #colorLiteral(red: 0.6055435538, green: 0.5368794799, blue: 0.7579702139, alpha: 1)
        
        arabicClickableView.isToggle = false
        arabicClickableView.setNeedsDisplay()
        txt_arabic.textColor = #colorLiteral(red: 0.6255808473, green: 0.8122056127, blue: 0, alpha: 1)
        
        armenianClickableView.isToggle = false
        armenianClickableView.setNeedsDisplay()
        txt_armenian.textColor = #colorLiteral(red: 0.8342520595, green: 0.2586418986, blue: 0.2585687637, alpha: 1)
        
        bt_english.isUserInteractionEnabled = true
        bt_francais.isUserInteractionEnabled = true
        bt_arabic.isUserInteractionEnabled = true
        bt_armenian.isUserInteractionEnabled = true
        
        languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
    }
}
