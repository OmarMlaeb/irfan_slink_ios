//
//  Line.swift
//  Test
//
//  Created by Maher Jaber on 4/6/20.
//  Copyright © 2020 Maher Jaber. All rights reserved.
//

import UIKit

class Line: UILabel {
    var line = UIBezierPath()
    func graph(){
        line.move(to: .init(x:0, y: bounds.height/2))
        line.addLine(to: .init(x: bounds.width, y: bounds.height/2))
        UIColor.lightGray.setStroke()
        line.lineWidth = 2
        line.stroke()
    }
    override func draw(_ rect: CGRect){
        graph()
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
