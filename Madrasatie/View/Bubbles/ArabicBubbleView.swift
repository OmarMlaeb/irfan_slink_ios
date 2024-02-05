//
//  ArabicBubbleView.swift
//  Madrasati
//
//  Created by Tarek on 5/3/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

/// Description:
/// Arabic bubble drawed using UIBezierPath
class ArabicBubbleView: UIView {
    
    var fillColor = UIColor(red: 0.531, green: 0.752, blue: 0.254, alpha: 0.200)
    var isToggle = false
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let bezierPath = UIBezierPath()
        if isToggle == false {
            bezierPath.move(to: CGPoint(x: width * 0.06, y: height * 0.39))
            bezierPath.addLine(to: CGPoint(x: width * 0.22, y: height * 0.68))
            bezierPath.addLine(to: CGPoint(x: width * 0.24, y: height * 0.81))
            bezierPath.addCurve(to: CGPoint(x: width * 0.26, y: height * 0.89), controlPoint1: CGPoint(x: width * 0.25, y: height * 0.85), controlPoint2: CGPoint(x: width * 0.25, y: height * 0.87))
            bezierPath.addCurve(to: CGPoint(x: width * 0.3, y: height * 0.94), controlPoint1: CGPoint(x: width * 0.27, y: height * 0.92), controlPoint2: CGPoint(x: width * 0.29, y: height * 0.94))
            bezierPath.addLine(to: CGPoint(x: width * 0.94, y: height * 0.82))
            bezierPath.addCurve(to: CGPoint(x: width * 0.98, y: height * 0.72), controlPoint1: CGPoint(x: width * 0.96, y: height * 0.82), controlPoint2: CGPoint(x: width * 0.98, y: height * 0.77))
            bezierPath.addLine(to: CGPoint(x: width * 0.98, y: height * 0.32))
            bezierPath.addCurve(to: CGPoint(x: width * 0.94, y: height * 0.22), controlPoint1: CGPoint(x: width * 0.98, y: height * 0.27), controlPoint2: CGPoint(x: width * 0.96, y: height * 0.22))
            bezierPath.addLine(to: CGPoint(x: width * 0.94, y: height * 0.22))
            bezierPath.addLine(to: CGPoint(x: width * 0.25, y: height * 0.06))
            bezierPath.addCurve(to: CGPoint(x: width * 0.2, y: height * 0.19), controlPoint1: CGPoint(x: width * 0.23, y: height * 0.06), controlPoint2: CGPoint(x: width * 0.22, y: height * 0.07))
            bezierPath.addCurve(to: CGPoint(x: width * 0.2, y: height * 0.31), controlPoint1: CGPoint(x: width * 0.2, y: height * 0.24), controlPoint2: CGPoint(x: width * 0.2, y: height * 0.3))
            bezierPath.addLine(to: CGPoint(x: width * 0.2, y: height * 0.33))
            bezierPath.addLine(to: CGPoint(x: width * 0.06, y: height * 0.39))
            bezierPath.close()
            bezierPath.move(to: CGPoint(x: width * 0.3, y: height * 1))
            bezierPath.addLine(to: CGPoint(x: width * 0.3, y: height * 1))
            bezierPath.addCurve(to: CGPoint(x: width * 0.25, y: height * 0.94), controlPoint1: CGPoint(x: width * 0.28, y: height * 1), controlPoint2: CGPoint(x: width * 0.26, y: height * 0.98))
            bezierPath.addCurve(to: CGPoint(x: width * 0.22, y: height * 0.84), controlPoint1: CGPoint(x: width * 0.23, y: height * 0.91), controlPoint2: CGPoint(x: width * 0.23, y: height * 0.88))
            bezierPath.addLine(to: CGPoint(x: width * 0.2, y: height * 0.72))
            bezierPath.addLine(to: CGPoint(x: width * 0, y: height * 0.35))
            bezierPath.addLine(to: CGPoint(x: width * 0.18, y: height * 0.28))
            bezierPath.addCurve(to: CGPoint(x: width * 0.18, y: height * 0.18), controlPoint1: CGPoint(x: width * 0.18, y: height * 0.25), controlPoint2: CGPoint(x: width * 0.18, y: height * 0.22))
            bezierPath.addLine(to: CGPoint(x: width * 0.18, y: height * 0.18))
            bezierPath.addCurve(to: CGPoint(x: width * 0.25, y: height * 0), controlPoint1: CGPoint(x: width * 0.19, y: height * 0.13), controlPoint2: CGPoint(x: width * 0.2, y: height * -0.01))
            bezierPath.addLine(to: CGPoint(x: width * 0.25, y: height * 0))
            bezierPath.addLine(to: CGPoint(x: width * 0.94, y: height * 0.16))
            bezierPath.addCurve(to: CGPoint(x: width * 1, y: height * 0.32), controlPoint1: CGPoint(x: width * 0.97, y: height * 0.16), controlPoint2: CGPoint(x: width * 1, y: height * 0.23))
            bezierPath.addLine(to: CGPoint(x: width * 1, y: height * 0.72))
            bezierPath.addCurve(to: CGPoint(x: width * 0.94, y: height * 0.88), controlPoint1: CGPoint(x: width * 1, y: height * 0.81), controlPoint2: CGPoint(x: width * 0.97, y: height * 0.88))
            bezierPath.addLine(to: CGPoint(x: width * 0.3, y: height * 1))
        } else {
            bezierPath.move(to: CGPoint(x: width *  0.3, y: height *  1))
            bezierPath.addLine(to: CGPoint(x: width *  0.3, y: height *  1))
            bezierPath.addCurve(to: CGPoint(x: width *  0.25, y: height *  0.94), controlPoint1: CGPoint(x: width *  0.28, y: height *  1), controlPoint2: CGPoint(x: width *  0.26, y: height *  0.98))
            bezierPath.addCurve(to: CGPoint(x: width *  0.22, y: height *  0.84), controlPoint1: CGPoint(x: width *  0.23, y: height *  0.91), controlPoint2: CGPoint(x: width *  0.23, y: height *  0.88))
            bezierPath.addLine(to: CGPoint(x: width *  0.2, y: height *  0.72))
            bezierPath.addLine(to: CGPoint(x: width *  0, y: height *  0.35))
            bezierPath.addLine(to: CGPoint(x: width *  0.18, y: height *  0.28))
            bezierPath.addCurve(to: CGPoint(x: width *  0.18, y: height *  0.18), controlPoint1: CGPoint(x: width *  0.18, y: height *  0.25), controlPoint2: CGPoint(x: width *  0.18, y: height *  0.22))
            bezierPath.addLine(to: CGPoint(x: width *  0.18, y: height *  0.18))
            bezierPath.addCurve(to: CGPoint(x: width *  0.25, y: height *  0), controlPoint1: CGPoint(x: width *  0.19, y: height *  0.13), controlPoint2: CGPoint(x: width *  0.2, y: height *  -0.01))
            bezierPath.addLine(to: CGPoint(x: width *  0.25, y: height *  0))
            bezierPath.addLine(to: CGPoint(x: width *  0.94, y: height *  0.16))
            bezierPath.addCurve(to: CGPoint(x: width *  1, y: height *  0.32), controlPoint1: CGPoint(x: width *  0.97, y: height *  0.16), controlPoint2: CGPoint(x: width *  1, y: height *  0.23))
            bezierPath.addLine(to: CGPoint(x: width *  1, y: height *  0.72))
            bezierPath.addCurve(to: CGPoint(x: width *  0.94, y: height *  0.88), controlPoint1: CGPoint(x: width *  1, y: height *  0.81), controlPoint2: CGPoint(x: width *  0.97, y: height *  0.88))
            bezierPath.addLine(to: CGPoint(x: width *  0.3, y: height *  1))
        }
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
    }
}


