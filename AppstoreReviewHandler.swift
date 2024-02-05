//
//
//  AppstoreReviewHandler.swift
//  Madrasati
//
//  Created by Maher Jaber on 8/31/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import UIKit
import StoreKit

class AppstoreReviewHandler: NSObject {
    
    private let MINIMUM_APP_LAUNCHES_UNTIS_FIRST_REQUEST = 8
    private let REVIEW_SESSION_COUNT_KEY = "app_sessions_count_key"
    
    private let defaults = UserDefaults.standard
    
    override init() {
        super.init()
    }
    
    public func recordAppLaunch() {
        var appLaunches = defaults.integer(forKey: REVIEW_SESSION_COUNT_KEY)
        appLaunches += 1
        defaults.set(appLaunches, forKey: REVIEW_SESSION_COUNT_KEY)
        defaults.synchronize()
    }
    
    public func tryToGetAppstoreReview() {
        var appLaunches = defaults.integer(forKey: REVIEW_SESSION_COUNT_KEY)
        print("entered review1: \(appLaunches)")
        print("entered review2: \(MINIMUM_APP_LAUNCHES_UNTIS_FIRST_REQUEST)")

        if  appLaunches >= MINIMUM_APP_LAUNCHES_UNTIS_FIRST_REQUEST {
            appLaunches = 0
            defaults.set(appLaunches, forKey: REVIEW_SESSION_COUNT_KEY)
            defaults.synchronize()
            self.askForReview()
        }
    }
    
    private func askForReview() {
        if #available( iOS 10.3,*) {
            // Note that this is not shown every time you want it.
            // Apple handles it in their own way so that a user will see it max three times a year.
            SKStoreReviewController.requestReview()
        }
    }
}
