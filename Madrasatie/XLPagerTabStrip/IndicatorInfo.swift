//  IndicatorInfo.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2017 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

public struct IndicatorInfo {

    public var title: String?
    public var counter: String?
    public var image: UIImage?
    public var backgroundViewColor: UIColor?
    public var highlightedImage: UIImage?
    public var accessibilityLabel: String?
    public var userInfo: Any?
    public var id: Int?
    
    public init(title: String?, counter: String?, backgroundViewColor: UIColor?, id: Int?) {
        self.title = title
        self.counter = counter
        self.accessibilityLabel = title
        self.backgroundViewColor = backgroundViewColor
        self.id = id
    }
    
    public init(image: UIImage?, highlightedImage: UIImage? = nil, userInfo: Any? = nil, id: Int?) {
        self.image = image
        self.highlightedImage = highlightedImage
        self.userInfo = userInfo
        self.id = id
    }
    
    public init(title: String?, counter: String?, image: UIImage?, backgroundViewColor: UIColor?, highlightedImage: UIImage? = nil, userInfo: Any? = nil, id: Int?) {
        self.title = title
        self.counter = counter
        self.accessibilityLabel = title
        self.backgroundViewColor = backgroundViewColor
        self.image = image
        self.highlightedImage = highlightedImage
        self.userInfo = userInfo
        self.id = id
    }
    
    public init(title: String?, counter: String?, accessibilityLabel:String?, image: UIImage?, backgroundViewColor: UIColor?, highlightedImage: UIImage? = nil, userInfo: Any? = nil, id: Int?) {
        self.title = title
        self.counter = counter
        self.accessibilityLabel = accessibilityLabel
        self.image = image
        self.backgroundViewColor = backgroundViewColor
        self.highlightedImage = highlightedImage
        self.userInfo = userInfo
        self.id = id
    }

}

extension IndicatorInfo : ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        title = value
        accessibilityLabel = value
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        title = value
        accessibilityLabel = value
    }

    public init(unicodeScalarLiteral value: String) {
        title = value
        accessibilityLabel = value
    }
}
