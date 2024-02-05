//
//  DIYCalendarCell.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 06/11/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import Foundation
//import FSCalendar
import UIKit

enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}


class DIYCalendarCell: FSCalendarCell {
    
    weak var circleImageView: UIImageView!
    weak var selectionLayer: CAShapeLayer!
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let circleImageView = UIImageView(image: #imageLiteral(resourceName: "empty"))
        self.contentView.insertSubview(circleImageView, at: 0)
        self.circleImageView = circleImageView
        self.circleImageView.isHidden = true
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.black.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        self.shapeLayer.isHidden = true
        
        let view = UIView(frame: self.bounds)
        view.backgroundColor = UIColor.clear
        self.backgroundView = view;
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.circleImageView.frame = self.contentView.bounds
        self.circleImageView.frame = CGRect(x: self.contentView.bounds.minX + 2.5, y: self.contentView.bounds.minY - 3, width: self.contentView.bounds.width - 5, height: self.contentView.bounds.height + 2.5)
//        self.circleImageView.center = self.contentView.center
        self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
        self.selectionLayer.frame = self.contentView.bounds
        
        if selectionType == .middle {
            self.selectionLayer.path = UIBezierPath(rect: CGRect(x: self.selectionLayer.bounds.minX, y: self.selectionLayer.bounds.minY + 1, width: self.selectionLayer.bounds.width, height: self.selectionLayer.bounds.height - 6)).cgPath
            self.selectionLayer.shadowOpacity = 0
        }
        else if selectionType == .leftBorder {
            self.selectionLayer.path = UIBezierPath(roundedRect: CGRect(x: self.selectionLayer.bounds.minX, y: self.selectionLayer.bounds.minY + 1, width: self.selectionLayer.bounds.width, height: self.selectionLayer.bounds.height - 6), byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2 - 6)).cgPath
            self.selectionLayer.shadowOpacity = 0
        }
        else if selectionType == .rightBorder {
            self.selectionLayer.path = UIBezierPath(roundedRect: CGRect(x: self.selectionLayer.bounds.minX, y: self.selectionLayer.bounds.minY + 1, width: self.selectionLayer.bounds.width, height: self.selectionLayer.bounds.height - 6), byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: self.selectionLayer.frame.width / 2, height: self.selectionLayer.frame.width / 2 - 6)).cgPath
            self.selectionLayer.shadowOpacity = 0
        }
        else if selectionType == .single {
            let diameter: CGFloat = min(self.selectionLayer.frame.height, self.selectionLayer.frame.width)
            self.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: self.contentView.frame.width / 2 - diameter / 2 + 2.5, y: self.contentView.frame.height / 2 - diameter / 2 + 1, width: diameter - 6, height: diameter - 6)).cgPath
            self.selectionLayer.shadowOffset = CGSize(width: 0, height: 1)
            self.selectionLayer.shadowColor = UIColor.black.cgColor
            self.selectionLayer.shadowOpacity = 0.5
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        // Override the build-in appearance configuration
        if self.isPlaceholder {
            self.eventIndicator.isHidden = true
            self.titleLabel.textColor = UIColor.lightGray
        }
    }
    
}
