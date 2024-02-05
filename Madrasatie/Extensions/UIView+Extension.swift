//
//  UIView+Extension.swift
//  SUMSUNG
//
//  Created by Miled Aoun on 8/7/18.
//  Copyright © 2018 NOVA4. All rights reserved.
//

import UIKit

@IBDesignable extension UIView {
    
    func superview(up: Int = 1) -> UIView? {
        func view(_ index: Int, total: Int, super s: UIView?) -> UIView? {
            if index == total {
                return s
            }
            return view(index + 1, total: total, super: s?.superview)
        }
        return view(0, total: up, super: self)
    }
    
    class func loadFromNibNamed(nibNamed: String, bundle: Bundle? = nil) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
    func addGradientBorder(with lineWidth: CGFloat, colors: [CGColor], angle: Float) {
        if (layer.sublayers?.index(where: {$0 is CAGradientLayer})) != nil {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            let gradient = CAGradientLayer()
            gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
            gradient.colors = colors
            
            let alpha: Float = angle / 360
            let startPointX = powf(sinf(2 * Float.pi * ((alpha + 0.75) / 2)), 2)
            let startPointY = powf(sinf(2 * Float.pi * ((alpha + 0) / 2)), 2)
            let endPointX = powf(sinf(2 * Float.pi * ((alpha + 0.25) / 2)), 2)
            let endPointY = powf(sinf(2 * Float.pi * ((alpha + 0.5) / 2)), 2)
            
            gradient.endPoint = CGPoint(x: CGFloat(endPointX),y: CGFloat(endPointY))
            gradient.startPoint = CGPoint(x: CGFloat(startPointX), y: CGFloat(startPointY))
            
            let shape = CAShapeLayer()
            shape.lineWidth = lineWidth
            shape.path = UIBezierPath(rect: self.bounds).cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            gradient.mask = shape
            
            self.layer.addSublayer(gradient)
        })
    }
    
    func removeGradientBorder() {
        if let index = layer.sublayers?.index(where: {$0 is CAGradientLayer}) {
            layer.sublayers?.remove(at: index)
        }
    }
    
    func dropShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        
        self.layer.rasterizationScale = UIScreen.main.scale
        
    }
    
    /**
     Rounds the given set of corners to the specified radius
     
     - parameter corners: Corners to round
     - parameter radius:  Radius to round to
     */
    func round(corners: UIRectCorner, radius: CGFloat) {
        _ = _round(corners: corners, radius: radius)
    }
    
    /**
     Rounds the given set of corners to the specified radius with a border
     
     - parameter corners:     Corners to round
     - parameter radius:      Radius to round to
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func round(corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let mask = _round(corners: corners, radius: radius)
        addBorder(mask: mask, borderColor: borderColor, borderWidth: borderWidth)
    }
    
    /**
     Fully rounds an autolayout view (e.g. one with no known frame) with the given diameter and border
     
     - parameter diameter:    The view's diameter
     - parameter borderColor: The border color
     - parameter borderWidth: The border width
     */
    func fullyRound(diameter: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = diameter / 2
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor;
    }
    
    func removeBorders() {
        let tags = [1000, 2000, 3000, 4000]
        for tag in tags {
            if let index = self.subviews.firstIndex(where: {$0.tag == tag}) {
                self.subviews[index].removeFromSuperview()
            }
        }
    }
    
//    @discardableResult func addBorders(edges: UIRectEdge, color: UIColor = .green, thickness: CGFloat = 1.0) -> [UIView] {
//
//        var borders = [UIView]()
//
//        func border() -> UIView {
//            let border = UIView(frame: CGRect.zero)
//            border.backgroundColor = color
//            border.translatesAutoresizingMaskIntoConstraints = false
//            border.clipsToBounds = self.clipsToBounds
//            return border
//        }
//
//        if edges.contains(.top) || edges.contains(.all) {
//            let top = border()
//            let tag = 1000
//            top.tag = tag
//            if let index = self.subviews.index(where: {$0.tag == tag}) {
//                self.subviews[index].removeFromSuperview()
//            }
//            addSubview(top)
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]", options: [], metrics: ["thickness": thickness], views: ["top": top]))
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|", options: [], metrics: nil, views: ["top": top]))
//            borders.append(top)
//        }
//
//        if edges.contains(.left) || edges.contains(.all) {
//            let left = border()
//            let tag = 2000
//            left.tag = tag
//            if let index = self.subviews.index(where: {$0.tag == tag}) {
//                self.subviews[index].removeFromSuperview()
//            }
//            addSubview(left)
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]", options: [],  metrics: ["thickness": thickness], views: ["left": left]))
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|", options: [], metrics: nil, views: ["left": left]))
//            borders.append(left)
//        }
//
//        if edges.contains(.right) || edges.contains(.all) {
//            let right = border()
//            let tag = 3000
//            right.tag = tag
//            if let index = self.subviews.index(where: {$0.tag == tag}) {
//                self.subviews[index].removeFromSuperview()
//            }
//            addSubview(right)
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|", options: [], metrics: ["thickness": thickness], views: ["right": right]))
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|", options: [], metrics: nil, views: ["right": right]))
//            borders.append(right)
//        }
//
//        if edges.contains(.bottom) || edges.contains(.all) {
//            let bottom = border()
//            let tag = 4000
//            bottom.tag = tag
//            if let index = self.subviews.index(where: {$0.tag == tag}) {
//                self.subviews[index].removeFromSuperview()
//            }
//            addSubview(bottom)
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|", options: [], metrics: ["thickness": thickness], views: ["bottom": bottom]))
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|", options: [], metrics: nil, views: ["bottom": bottom]))
//            borders.append(bottom)
//        }
//
//        return borders
//    }
    
    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    func removeAllConstraints() {
        var superview = self.superview
        while superview != nil {
            for c in superview?.constraints ?? [] {
                if (c.firstItem as? UIView) == self || (c.secondItem as? UIView) == self {
                    superview?.removeConstraint(c)
                }
            }
            superview = superview?.superview
        }
        removeConstraints(constraints)
        translatesAutoresizingMaskIntoConstraints = true
    }
    
    func blink() {
        let duration: Double = 0.5
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0.2
        }, completion: {
            finished in
            UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {self.alpha = 1.0}, completion: nil)
        })
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: CGFloat {
        get {
            return CGFloat(self.layer.shadowOpacity)
        }
        set {
            self.layer.shadowOpacity = Float(newValue)
        }
    }
    
//    @IBInspectable var cornerRadius: CGFloat {
//        get {
//            return self.layer.cornerRadius
//        }
//        set {
//            self.layer.cornerRadius = newValue
//        }
//    }
//
//    @IBInspectable var borderWidth: CGFloat {
//        get {
//            return self.layer.borderWidth
//        }
//        set {
//            self.layer.borderWidth = newValue
//        }
//    }
//
//    @IBInspectable var borderColor: UIColor {
//        get {
//            return UIColor(cgColor: self.layer.borderColor!)
//        }
//        set {
//            self.layer.borderColor = newValue.cgColor
//        }
//    }

    func assignbackground() {
        let background = UIImage(named: "bluelight")

        let imageView = UIImageView(frame: bounds)
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = center
        addSubview(imageView)
        self.sendSubviewToBack(imageView)
    }
}

private extension UIView {
    
    @discardableResult func _round(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.frame = bounds
        self.layer.mask = mask
        return mask
    }
    
    func addBorder(mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let prevLayer = layer.sublayers?.filter({$0.accessibilityValue == "10"}).first as? CAShapeLayer
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        borderLayer.accessibilityValue = "10"
        let widthAnimation = CABasicAnimation(keyPath: "lineWidth")
        widthAnimation.fromValue = borderWidth == 0 ? prevLayer?.lineWidth ?? 0 : 0
        widthAnimation.toValue = borderWidth
        widthAnimation.duration = 0.2
        widthAnimation.fillMode = CAMediaTimingFillMode.forwards
        widthAnimation.isRemovedOnCompletion = false
        
        if prevLayer == nil {
            borderLayer.add(widthAnimation, forKey: "border")
            layer.addSublayer(borderLayer)
        }
        else {
            prevLayer?.removeAllAnimations()
            prevLayer?.add(widthAnimation, forKey: "border")
        }
    }
    
}
