//
//  TriangleView.swift
//  Madrasati
//
//  Created by Tarek on 5/8/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation
import UIKit
class TriangleView : UIView {
    let strokeColor = UIColor(red: 0.806, green: 0.809, blue: 0.791, alpha: 1.000)
    let fillColor = UIColor(red: 1.000, green: 0.999, blue: 0.996, alpha: 1.000)

    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: width * 0.98, y: height * 1))
        bezierPath.addLine(to: CGPoint(x: width * 0.02, y: height * 1))
        bezierPath.addCurve(to: CGPoint(x: width * 0, y: height * 0.97), controlPoint1: CGPoint(x: width * 0.01, y: height * 1), controlPoint2: CGPoint(x: width * 0, y: height * 0.99))
        bezierPath.addLine(to: CGPoint(x: width * 0, y: height * 0.07))
        bezierPath.addCurve(to: CGPoint(x: width * 0.02, y: height * 0.04), controlPoint1: CGPoint(x: width * 0, y: height * 0.05), controlPoint2: CGPoint(x: width * 0.01, y: height * 0.04))
        bezierPath.addLine(to: CGPoint(x: width * 0.81, y: height * 0.04))
        bezierPath.addLine(to: CGPoint(x: width * 0.83, y: height * 0.01))
        bezierPath.addCurve(to: CGPoint(x: width * 0.87, y: height * 0.01), controlPoint1: CGPoint(x: width * 0.84, y: height * -0), controlPoint2: CGPoint(x: width * 0.86, y: height * -0))
        bezierPath.addLine(to: CGPoint(x: width * 0.89, y: height * 0.04))
        bezierPath.addLine(to: CGPoint(x: width * 0.98, y: height * 0.04))
        bezierPath.addCurve(to: CGPoint(x: width * 1, y: height * 0.07), controlPoint1: CGPoint(x: width * 0.99, y: height * 0.04), controlPoint2: CGPoint(x: width * 1, y: height * 0.05))
        bezierPath.addLine(to: CGPoint(x: width * 1, y: height * 0.97))
        bezierPath.addCurve(to: CGPoint(x: width * 0.98, y: height * 1), controlPoint1: CGPoint(x: width * 1, y: height * 0.99), controlPoint2: CGPoint(x: width * 0.99, y: height * 1))
        bezierPath.close()
        strokeColor.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
    }
}

