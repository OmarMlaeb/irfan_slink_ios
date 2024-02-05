//
//  FrenchBubbleView.swift
//  Madrasati
//
//  Created by Tarek on 5/3/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//


import UIKit

/// Description:
/// French bubble drawed using UIBezierPath.
class FrenchBubbleView: UIView {
    
    var fillColor = UIColor(red: 0.497, green: 0.419, blue: 0.634, alpha: 0.200)
    var isToggle = false
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let bezierPath = UIBezierPath()
        if isToggle == false {
            bezierPath.move(to: CGPoint(x: width * 0.05, y: height * 0.04))
            bezierPath.addCurve(to: CGPoint(x: width * 0.03, y: height * 0.07), controlPoint1: CGPoint(x: width * 0.05, y: height * 0.04), controlPoint2: CGPoint(x: width * 0.04, y: height * 0.05))
            bezierPath.addCurve(to: CGPoint(x: width * 0.02, y: height * 0.12), controlPoint1: CGPoint(x: width * 0.02, y: height * 0.08), controlPoint2: CGPoint(x: width * 0.02, y: height * 0.1))
            bezierPath.addLine(to: CGPoint(x: width * 0.06, y: height * 0.59))
            bezierPath.addCurve(to: CGPoint(x: width * 0.09, y: height * 0.65), controlPoint1: CGPoint(x: width * 0.06, y: height * 0.63), controlPoint2: CGPoint(x: width * 0.08, y: height * 0.65))
            bezierPath.addLine(to: CGPoint(x: width * 0.22, y: height * 0.65))
            bezierPath.addLine(to: CGPoint(x: width * 0.22, y: height * 0.91))
            bezierPath.addLine(to: CGPoint(x: width * 0.36, y: height * 0.67))
            bezierPath.addCurve(to: CGPoint(x: width * 0.39, y: height * 0.65), controlPoint1: CGPoint(x: width * 0.37, y: height * 0.66), controlPoint2: CGPoint(x: width * 0.38, y: height * 0.65))
            bezierPath.addLine(to: CGPoint(x: width * 0.95, y: height * 0.57))
            bezierPath.addCurve(to: CGPoint(x: width * 0.98, y: height * 0.5), controlPoint1: CGPoint(x: width * 0.97, y: height * 0.57), controlPoint2: CGPoint(x: width * 0.98, y: height * 0.54))
            bezierPath.addLine(to: CGPoint(x: width * 0.98, y: height * 0.22))
            bezierPath.addCurve(to: CGPoint(x: width * 0.95, y: height * 0.15), controlPoint1: CGPoint(x: width * 0.98, y: height * 0.19), controlPoint2: CGPoint(x: width * 0.96, y: height * 0.15))
            bezierPath.addLine(to: CGPoint(x: width * 0.06, y: height * 0.04))
            bezierPath.addLine(to: CGPoint(x: width * 0.05, y: height * 0.04))
            bezierPath.close()
            bezierPath.move(to: CGPoint(x: width * 0.2, y: height * 1))
            bezierPath.addLine(to: CGPoint(x: width * 0.2, y: height * 0.69))
            bezierPath.addLine(to: CGPoint(x: width * 0.09, y: height * 0.69))
            bezierPath.addCurve(to: CGPoint(x: width * 0.04, y: height * 0.6), controlPoint1: CGPoint(x: width * 0.07, y: height * 0.69), controlPoint2: CGPoint(x: width * 0.04, y: height * 0.66))
            bezierPath.addLine(to: CGPoint(x: width * 0, y: height * 0.13))
            bezierPath.addCurve(to: CGPoint(x: width * 0.01, y: height * 0.04), controlPoint1: CGPoint(x: width * -0, y: height * 0.1), controlPoint2: CGPoint(x: width * 0, y: height * 0.06))
            bezierPath.addCurve(to: CGPoint(x: width * 0.06, y: height * 0), controlPoint1: CGPoint(x: width * 0.03, y: height * 0.01), controlPoint2: CGPoint(x: width * 0.04, y: height * -0))
            bezierPath.addLine(to: CGPoint(x: width * 0.95, y: height * 0.11))
            bezierPath.addCurve(to: CGPoint(x: width * 1, y: height * 0.22), controlPoint1: CGPoint(x: width * 0.98, y: height * 0.11), controlPoint2: CGPoint(x: width * 1, y: height * 0.16))
            bezierPath.addLine(to: CGPoint(x: width * 1, y: height * 0.5))
            bezierPath.addCurve(to: CGPoint(x: width * 0.95, y: height * 0.61), controlPoint1: CGPoint(x: width * 1, y: height * 0.56), controlPoint2: CGPoint(x: width * 0.98, y: height * 0.61))
            bezierPath.addLine(to: CGPoint(x: width * 0.39, y: height * 0.69))
            bezierPath.addCurve(to: CGPoint(x: width * 0.37, y: height * 0.71), controlPoint1: CGPoint(x: width * 0.39, y: height * 0.69), controlPoint2: CGPoint(x: width * 0.38, y: height * 0.7))
            bezierPath.addLine(to: CGPoint(x: width * 0.2, y: height * 1))
        } else {
            
            bezierPath.move(to: CGPoint(x: width *  0.2, y: height *  1))
            bezierPath.addLine(to: CGPoint(x: width *  0.2, y: height *  0.69))
            bezierPath.addLine(to: CGPoint(x: width *  0.09, y: height *  0.69))
            bezierPath.addCurve(to: CGPoint(x: width *  0.04, y: height *  0.6), controlPoint1: CGPoint(x: width *  0.07, y: height *  0.69), controlPoint2: CGPoint(x: width *  0.04, y: height *  0.66))
            bezierPath.addLine(to: CGPoint(x: width *  0, y: height *  0.13))
            bezierPath.addCurve(to: CGPoint(x: width *  0.01, y: height *  0.04), controlPoint1: CGPoint(x: width *  -0, y: height *  0.1), controlPoint2: CGPoint(x: width *  0, y: height *  0.06))
            bezierPath.addCurve(to: CGPoint(x: width *  0.06, y: height *  0), controlPoint1: CGPoint(x: width *  0.03, y: height *  0.01), controlPoint2: CGPoint(x: width *  0.04, y: height *  -0))
            bezierPath.addLine(to: CGPoint(x: width *  0.95, y: height *  0.11))
            bezierPath.addCurve(to: CGPoint(x: width *  1, y: height *  0.22), controlPoint1: CGPoint(x: width *  0.98, y: height *  0.11), controlPoint2: CGPoint(x: width *  1, y: height *  0.16))
            bezierPath.addLine(to: CGPoint(x: width *  1, y: height *  0.5))
            bezierPath.addCurve(to: CGPoint(x: width *  0.95, y: height *  0.61), controlPoint1: CGPoint(x: width *  1, y: height *  0.56), controlPoint2: CGPoint(x: width *  0.98, y: height *  0.61))
            bezierPath.addLine(to: CGPoint(x: width *  0.39, y: height *  0.69))
            bezierPath.addCurve(to: CGPoint(x: width *  0.37, y: height *  0.71), controlPoint1: CGPoint(x: width *  0.39, y: height *  0.69), controlPoint2: CGPoint(x: width *  0.38, y: height *  0.7))
            bezierPath.addLine(to: CGPoint(x: width *  0.2, y: height *  1))
        }
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
    }
}
