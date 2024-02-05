//
//  HelpCenterViewController.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/12/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class HelpCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var askQuestionField: UITextField!
    @IBOutlet weak var backImage: UIImageView!
    
    var pages: Page!
    var isTabBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if pages == nil{
            pages = Page(privacy: FAQ(title: "", body: ""), terms: FAQ.init(title: "", body: ""), faq: [], helpTitle: "", helpText: "", helpQuestion: [])
            getPages()
        }
        hideKeyboardWhenTappedAround()
        /// Add Textfields padding:
        askQuestionField.setLeftPaddingPoints(15)
        askQuestionField.setRightPaddingPoints(15)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    
    /// Description:
    /// - Set back button appearance when language is updated.
    /// - Remove backButton if this page is oppened from tab bar tabs.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if isTabBar{
            backImage.isHidden = true
        }else{
            backImage.isHidden = false
            let languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
            if languageId == "ar"{
                backImage.image = UIImage(named: "white-back-ar")
            }else{
                backImage.image = UIImage(named: "white-back")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Description:
    /// - Check if the text is not empty and call sendQuestion function.
    @IBAction func sendButtonPressed(_ sender: Any) {
        if askQuestionField.text!.isEmpty{
            let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
            App.showAlert(self, title: "", message: "Write a question".localiz(), actions: [ok])
        }else{
            let question = askQuestionField.text!
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.helpQuestion.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case pages.helpQuestion.count:
            let callCell = tableView.dequeueReusableCell(withIdentifier: "callReuse")
            let titleLabel = callCell?.viewWithTag(10) as! UILabel
            titleLabel.text = "Give us a call".localiz()
            let phoneLabel = callCell?.viewWithTag(11) as! UILabel
            phoneLabel.text = pages.helpText
            callCell?.selectionStyle = .none
            callCell?.backgroundColor = .clear
            return callCell!
        default:
            let questionCell = tableView.dequeueReusableCell(withIdentifier: "questionReuse")
            let questionLabel = questionCell?.viewWithTag(1) as! UILabel
            let answerLabel = questionCell?.viewWithTag(2) as! UILabel
            let question = pages.helpQuestion[indexPath.row]
            questionLabel.text = question.title
            answerLabel.text = question.body
            questionCell?.selectionStyle = .none
            questionCell?.backgroundColor = .clear
            return questionCell!
        }
    }
    
    
    /// Description: Send Question
    /// - Parameter question: Text writed in askQuestionField.
    /// - Send question to askQuestion API.

    
    /// Description: Get Pages
    /// - Request to GetPages API and get terms and conditions, privacy policy, help center and faq questions data.
    func getPages(){
        let indicatorView = App.loading()
        indicatorView.tag = 100
        self.view.addSubview(indicatorView)
        
        Request.shared.getPages() { (message, pagesData, status) in
            if status == 200{
                self.pages = pagesData!
                self.tableView.reloadData()
            }
            else{
                let ok = UIAlertAction(title: "OK".localiz(), style: .default, handler: nil)
                App.showAlert(self, title: "ERROR".localiz(), message: message!, actions: [ok])
            }
            if let viewWithTag = self.view.viewWithTag(100){
                viewWithTag.removeFromSuperview()
            }
        }
    }

}
