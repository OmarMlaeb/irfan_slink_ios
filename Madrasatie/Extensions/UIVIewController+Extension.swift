//
//  UIVIewController+Extension.swift
//  Madrasatie
//
//  Created by hisham noureddine on 8/30/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var loading: UIView {
        self.view.subviews.forEach({if $0.tag == 1500 {$0.removeFromSuperview()}})
        return App.loading()
    }
    
    var loadingBlending: UIView {
        self.view.subviews.forEach({if $0.tag == 1500 {$0.removeFromSuperview()}})
        return App.loadingBlendedLearing()
    }
    
    
    static var top: UIViewController? {
        get {
            return topViewController()
        }
    }
    
    static var root: UIViewController? {
        get {
            return UIApplication.shared.delegate?.window??.rootViewController
        }
    }
    
    class func topViewController(from viewController: UIViewController? = UIViewController.root) -> UIViewController? {
        if let tabBarViewController = viewController as? UITabBarController {
            return topViewController(from: tabBarViewController.selectedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        } else {
            return viewController
        }
    }
    
    func setMessageMenu(){
        let optionsButton = UIButton()
        optionsButton.setImage(UIImage(named: "top_button")?.scaleImage(scaledToSize: CGSize(width: 50, height: 25)), for: .normal)
        optionsButton.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        optionsButton.clipsToBounds = false
        optionsButton.addTarget(self, action: #selector(optionButtonPressed), for: .touchUpInside)
        
        let options = UIBarButtonItem(customView: optionsButton)
        
        self.navigationItem.rightBarButtonItem = options
    }
    
    
    func setBackButton(){
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "white-back")?.scaleImage(scaledToSize: CGSize(width: 28, height: 28)), for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        backButton.clipsToBounds = false
        backButton.addTarget(self, action: #selector(pop), for: .touchUpInside)
        
        let back = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = back
    }
    
    func setMailNavigation(with title: String = ""){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = title
        let backButton = UIBarButtonItem(title: nil, style: .done, target: self, action: #selector(pop))
        let languageId = UserDefaults.standard.string(forKey: "LanguageId") ?? "en"
        if languageId == "ar"{
            backButton.image = UIImage(named: "white-nav-back-ar")
        }else{
            backButton.image = UIImage(named: "white-nav-back")
        }
        backButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    
    func initNavBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = App.hexStringToUIColorCst(hex: "#014e80", alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "OpenSans-Bold", size: 18)!]
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    @objc func optionButtonPressed(_ sender: UIButton){
    }
    
    @objc func pop(){
        self.navigationController?.popViewController(animated: true)
    }
}
