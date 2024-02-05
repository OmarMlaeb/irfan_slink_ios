//
//  TextView.swift
//  Mr Grocer
//
//  Created by Miled Aoun on 9/6/17.
//  Copyright © 2017 Nova4. All rights reserved.
//

import UIKit

@IBDesignable
class TextView: UITextView {
    
    private struct Constants {
        static let defaultiOSPlaceholderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
    }
    let placeholderLabel: UILabel = UILabel()
    
    private var placeholderLabelConstraints = [NSLayoutConstraint]()
    
    @IBInspectable var maxLength: Int = Int.max
    
    @IBInspectable var paddingTop:CGFloat = 5.0 {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    @IBInspectable var paddingBottom: CGFloat = 5.0 {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    @IBInspectable var paddingLeft: CGFloat = 5.0 {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    @IBInspectable var paddingRight: CGFloat = 5.0 {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.font = font
        }
    }
    
    @IBInspectable var placeholderColor: UIColor = TextView.Constants.defaultiOSPlaceholderColor {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    
    private weak var userDelegate: UITextViewDelegate?
    
    override var delegate: UITextViewDelegate? {
        get { return userDelegate }
        set { userDelegate = newValue }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
        
        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.text = placeholder
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.textAlignment = textAlignment
        addSubview(placeholderLabel)
        bringSubviewToFront(placeholderLabel)
        updateConstraintsForPlaceholderLabel()
    }
    
    private func updateConstraintsForPlaceholderLabel() {
        placeholderLabel.removeAllConstraints()
        _ = placeholderLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: paddingTop, leftConstant: paddingLeft, bottomConstant: paddingBottom, rightConstant: paddingRight, widthConstant: frame.width - paddingLeft - paddingRight, heightConstant: 0)
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if self.textAlignment == .center {
            return
        }
        
        if UIApplication.isRTL()  {
            if self.textAlignment == .right {
                return
            }
            self.textAlignment = .right
            placeholderLabel.textAlignment = .right
            
        } else {
            if self.textAlignment == .left {
                return
            }
            self.textAlignment = .left
            placeholderLabel.textAlignment = .left
        }
        
        textContainerInset = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        textContainer.lineFragmentPadding = 0
//        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
    
}

extension TextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        return self.delegate?.textViewDidBeginEditing?(textView) ?? ()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.count + (text.count - range.length)
        return self.delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? (newLength <= maxLength)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        return self.delegate?.textViewDidBeginEditing?(textView) ?? ()
    }

    func textViewDidChange(_ textView: UITextView) {
        return self.delegate?.textViewDidChange?(textView) ?? ()
    }
}
