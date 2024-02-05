//
//  SectionCell.swift
//  Madrasati
//
//  Created by Tarek on 5/7/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import UIKit

class SectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var triangle_view: ViewWithTriangle!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet var notificationView: UIView!
    @IBOutlet weak var lbl_number: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
