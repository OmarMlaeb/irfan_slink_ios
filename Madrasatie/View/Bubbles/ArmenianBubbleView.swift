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
class ArmenianBubbleView: UIView {
    
    var fillColor = UIColor(red: 0.84, green: 0.25, blue: 0.25, alpha: 0.200)
    var isToggle = false
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let bezierPath = UIBezierPath()
        if isToggle == false {
            bezierPath.move(to: CGPoint(x: width * 0.52, y: height * 0.67))
            bezierPath.addCurve(to: CGPoint(x: width * 0.55, y: height * 0.69), controlPoint1: CGPoint(x: width * 0.53, y: height * 0.67), controlPoint2: CGPoint(x: width * 0.54, y: height * 0.67))
            bezierPath.addLine(to: CGPoint(x: width * 0.73, y: height * 0.91))
            bezierPath.addLine(to: CGPoint(x: width * 0.73, y: height * 0.67))
            bezierPath.addLine(to: CGPoint(x: width * 0.89, y: height * 0.67))
            bezierPath.addCurve(to: CGPoint(x: width * 0.93, y: height * 0.61), controlPoint1: CGPoint(x: width * 0.91, y: height * 0.67), controlPoint2: CGPoint(x: width * 0.92, y: height * 0.64))
            bezierPath.addLine(to: CGPoint(x: width * 0.97, y: height * 0.16))
            bezierPath.addCurve(to: CGPoint(x: width * 0.96, y: height * 0.11), controlPoint1: CGPoint(x: width * 0.98, y: height * 0.14), controlPoint2: CGPoint(x: width * 0.97, y: height * 0.12))
            bezierPath.addCurve(to: CGPoint(x: width * 0.93, y: height * 0.09), controlPoint1: CGPoint(x: width * 0.95, y: height * 0.09), controlPoint2: CGPoint(x: width * 0.94, y: height * 0.08))
            bezierPath.addLine(to: CGPoint(x: width * 0.93, y: height * 0.09))
            bezierPath.addLine(to: CGPoint(x: width * 0.07, y: height * 0.04))
            bezierPath.addCurve(to: CGPoint(x: width * 0.03, y: height * 0.11), controlPoint1: CGPoint(x: width * 0.04, y: height * 0.04), controlPoint2: CGPoint(x: width * 0.03, y: height * 0.07))
            bezierPath.addLine(to: CGPoint(x: width * 0.03, y: height * 0.52))
            bezierPath.addCurve(to: CGPoint(x: width * 0.07, y: height * 0.59), controlPoint1: CGPoint(x: width * 0.03, y: height * 0.56), controlPoint2: CGPoint(x: width * 0.04, y: height * 0.59))
            bezierPath.addLine(to: CGPoint(x: width * 0.07, y: height * 0.59))
            bezierPath.addLine(to: CGPoint(x: width * 0.52, y: height * 0.67))
            bezierPath.close()
            bezierPath.move(to: CGPoint(x: width * 0.76, y: height * 1))
            bezierPath.addLine(to: CGPoint(x: width * 0.54, y: height * 0.72))
            bezierPath.addCurve(to: CGPoint(x: width * 0.51, y: height * 0.71), controlPoint1: CGPoint(x: width * 0.53, y: height * 0.71), controlPoint2: CGPoint(x: width * 0.52, y: height * 0.71))
            bezierPath.addLine(to: CGPoint(x: width * 0.51, y: height * 0.71))
            bezierPath.addLine(to: CGPoint(x: width * 0.06, y: height * 0.63))
            bezierPath.addCurve(to: CGPoint(x: width * 0, y: height * 0.52), controlPoint1: CGPoint(x: width * 0.03, y: height * 0.63), controlPoint2: CGPoint(x: width * 0, y: height * 0.58))
            bezierPath.addLine(to: CGPoint(x: width * 0, y: height * 0.11))
            bezierPath.addCurve(to: CGPoint(x: width * 0.06, y: height * 0), controlPoint1: CGPoint(x: width * 0, y: height * 0.05), controlPoint2: CGPoint(x: width * 0.03, y: height * 0))
            bezierPath.addLine(to: CGPoint(x: width * 0.06, y: height * 0))
            bezierPath.addLine(to: CGPoint(x: width * 0.93, y: height * 0.04))
            bezierPath.addCurve(to: CGPoint(x: width * 0.98, y: height * 0.08), controlPoint1: CGPoint(x: width * 0.95, y: height * 0.04), controlPoint2: CGPoint(x: width * 0.97, y: height * 0.05))
            bezierPath.addCurve(to: CGPoint(x: width * 1, y: height * 0.17), controlPoint1: CGPoint(x: width * 1, y: height * 0.1), controlPoint2: CGPoint(x: width * 1, y: height * 0.14))
            bezierPath.addLine(to: CGPoint(x: width * 0.95, y: height * 0.62))
            bezierPath.addCurve(to: CGPoint(x: width * 0.89, y: height * 0.71), controlPoint1: CGPoint(x: width * 0.95, y: height * 0.67), controlPoint2: CGPoint(x: width * 0.92, y: height * 0.71))
            bezierPath.addLine(to: CGPoint(x: width * 0.76, y: height * 0.71))
            bezierPath.addLine(to: CGPoint(x: width * 0.76, y: height * 1))
        } else {
            bezierPath.move(to: CGPoint(x: width * 0.76, y: height * 1))
            bezierPath.addLine(to: CGPoint(x: width * 0.54, y: height * 0.72))
            bezierPath.addCurve(to: CGPoint(x: width * 0.51, y: height * 0.71), controlPoint1: CGPoint(x: width * 0.53, y: height * 0.71), controlPoint2: CGPoint(x: width * 0.52, y: height * 0.71))
            bezierPath.addLine(to: CGPoint(x: width * 0.51, y: height * 0.71))
            bezierPath.addLine(to: CGPoint(x: width * 0.06, y: height * 0.63))
            bezierPath.addCurve(to: CGPoint(x: width * 0, y: height * 0.52), controlPoint1: CGPoint(x: width * 0.03, y: height * 0.63), controlPoint2: CGPoint(x: width * 0, y: height * 0.58))
            bezierPath.addLine(to: CGPoint(x: width * 0, y: height * 0.11))
            bezierPath.addCurve(to: CGPoint(x: width * 0.06, y: height * 0), controlPoint1: CGPoint(x: width * 0, y: height * 0.05), controlPoint2: CGPoint(x: width * 0.03, y: height * 0))
            bezierPath.addLine(to: CGPoint(x: width * 0.06, y: height * 0))
            bezierPath.addLine(to: CGPoint(x: width * 0.93, y: height * 0.04))
            bezierPath.addCurve(to: CGPoint(x: width * 0.98, y: height * 0.08), controlPoint1: CGPoint(x: width * 0.95, y: height * 0.04), controlPoint2: CGPoint(x: width * 0.97, y: height * 0.05))
            bezierPath.addCurve(to: CGPoint(x: width * 1, y: height * 0.17), controlPoint1: CGPoint(x: width * 1, y: height * 0.1), controlPoint2: CGPoint(x: width * 1, y: height * 0.14))
            bezierPath.addLine(to: CGPoint(x: width * 0.95, y: height * 0.62))
            bezierPath.addCurve(to: CGPoint(x: width * 0.89, y: height * 0.71), controlPoint1: CGPoint(x: width * 0.95, y: height * 0.67), controlPoint2: CGPoint(x: width * 0.92, y: height * 0.71))
            bezierPath.addLine(to: CGPoint(x: width * 0.76, y: height * 0.71))
            bezierPath.addLine(to: CGPoint(x: width * 0.76, y: height * 1))
        }
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
    }
}
