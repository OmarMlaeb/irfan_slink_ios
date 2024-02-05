//
//  UIImageExtension.swift
//  Madrasati
//
//  Created by hisham noureddine on 8/9/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    func scaleImage(scaledToSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
