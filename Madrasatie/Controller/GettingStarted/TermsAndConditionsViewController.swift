//
//  TermsAndConditionsViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 9/10/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {
    
    @IBOutlet weak var termsTextView: UITextView!
    var terms: FAQ!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termsTextView.text = terms.body
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNavigation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /// Description:
    /// Initialize navigation bar view.
    /// Set a specific back button image for Arabic language.
    func initNavigation(){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Terms and conditions".localiz()
        let backButton = UIBarButtonItem(title: nil, style: .done, target: self, action: #selector(backButtonPressed))
        let languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
        if languageId == "ar"{
            backButton.image = UIImage(named: "white-nav-back-ar")
        }else{
            backButton.image = UIImage(named: "white-nav-back")
        }
        backButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = App.hexStringToUIColorCst(hex: "#568EF6", alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 18)!]
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
}
