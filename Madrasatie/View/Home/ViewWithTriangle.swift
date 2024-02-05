//
//  ViewWithTriangle.swift
//  Madrasati
//
//  Created by Tarek on 5/7/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class ViewWithTriangle: UIView {
    
    var rectangleColor = UIColor(red: 1.000, green: 0.999, blue: 0.996, alpha: 1.000)
    var triangleColor = UIColor(red: 0.933, green: 0.923, blue: 0.787, alpha: 1.000)
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let bezierPath = UIBezierPath()
        let rectanglePath = UIBezierPath(rect: CGRect(x: 0.025, y: 0, width: width * 1, height: height * 1.25))
        rectangleColor.setFill()
        rectanglePath.fill()
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: width * 1.25, y: height * 1.25))
        bezierPath.addLine(to: CGPoint(x: width * 1.25, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.close()
        triangleColor.setFill()
        bezierPath.fill()
    }
}
