//
//  iCarouselView.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/13/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation
import UIKit

class iCarouselView: UIView{
    
    @IBOutlet weak var studentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        studentImageView.layer.cornerRadius = studentImageView.frame.width / 2
    }
    
}
