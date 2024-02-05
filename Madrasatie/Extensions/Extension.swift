//
//  Extension.swift
//  Madrasatie
//
//  Created by hisham noureddine on 5/13/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        return end - start
    }
}

extension UIApplication {
    class func isRTL() -> Bool {
        return App.languageId == "ar"
    }
    
    class func reload() {
        let windows = UIApplication.shared.windows
        for window in windows {
            for view in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view)
                view.setNeedsDisplay()
            }
        }
    }
}
