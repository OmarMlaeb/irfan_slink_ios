//
//  FaqViewController.swift
//  Madrasatie
//
//  Created by hisham noureddine on 9/12/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class FaqViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var faqArray: [FAQ] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNavigation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Description: Init Navigation bar and back button:
    func initNavigation(){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "FAQ".localiz()
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
        self.navigationController?.navigationBar.barTintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 18)!]
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    @objc func backButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    // Mark: - UItableview Delegate and DataSource Functions:
    func numberOfSections(in tableView: UITableView) -> Int {
        return faqArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faqReuse")
        let bodyLabel = cell?.viewWithTag(1) as! UILabel
        bodyLabel.text = faqArray[indexPath.section].body
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "headerReuse")
        let titleLabel = header?.viewWithTag(2) as! UILabel
        titleLabel.text = faqArray[section].title
        return header?.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

}
