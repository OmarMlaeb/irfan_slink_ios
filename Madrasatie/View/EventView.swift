//
//  EventView.swift
//  Madrasati
//
//  Created by hisham noureddine on 5/21/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class EventView: UIView {

    override func draw(_ rect: CGRect) {
        
        let fillColor: UIColor! = UIColor(red: 0.196, green: 0.654, blue: 0.563, alpha: 1)
        let fillColor2: UIColor! = UIColor(red: 0.106, green: 0.556, blue: 0.49, alpha: 1)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: rect.width, y: 39.56))
        bezierPath.addLine(to: CGPoint(x: rect.width - 0, y: 193.06))
        bezierPath.addCurve(to: CGPoint(x: rect.width - 5.21, y: 200.1), controlPoint1: CGPoint(x: rect.width - 2.33, y: 196.95), controlPoint2: CGPoint(x: rect.width - 5.21, y: 200.1))
        bezierPath.addLine(to: CGPoint(x: 4.64, y: 200.1))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 193.06), controlPoint1: CGPoint(x: 2.08, y: 200.1), controlPoint2: CGPoint(x: 0, y: 196.95))
        bezierPath.addLine(to: CGPoint(x: 0, y: 39.56))
        bezierPath.addLine(to: CGPoint(x: rect.width - 2.33, y: 39.56))
        bezierPath.close()
        bezierPath.lineCapStyle = .square
        bezierPath.lineJoinStyle = .round
        fillColor.setFill()
        bezierPath.fill()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: rect.width - 4.64, y: 51.98))
        bezier2Path.addLine(to: CGPoint(x: 4.64, y: 51.98))
        bezier2Path.addCurve(to: CGPoint(x: 0, y: 45.9), controlPoint1: CGPoint(x: 2.08, y: 51.98), controlPoint2: CGPoint(x: 0, y: 49.26))
        bezier2Path.addLine(to: CGPoint(x: 0, y: 6.08))
        bezier2Path.addCurve(to: CGPoint(x: 4.64, y: -0), controlPoint1: CGPoint(x: 0, y: 2.72), controlPoint2: CGPoint(x: 2.08, y: -0))
        bezier2Path.addLine(to: CGPoint(x: rect.width - 4.64, y: -0))
        bezier2Path.addCurve(to: CGPoint(x: rect.width - 0, y: 6.08), controlPoint1: CGPoint(x: rect.width - 2.08, y: -0), controlPoint2: CGPoint(x: rect.width - 0, y: 2.72))
        bezier2Path.addLine(to: CGPoint(x: rect.width - 0, y: 45.9))
        bezier2Path.addCurve(to: CGPoint(x: rect.width - 4.64, y: 51.98), controlPoint1: CGPoint(x: rect.width - 0, y: 49.26), controlPoint2: CGPoint(x: rect.width - 2.08, y: 51.98))
        bezier2Path.close()
        fillColor2.setFill()
        bezier2Path.fill()

    }

}
