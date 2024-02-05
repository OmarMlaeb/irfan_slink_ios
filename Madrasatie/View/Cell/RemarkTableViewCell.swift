//
//  RemarkTableViewCell.swift
//  Madrasatie
//
//  Created by hisham noureddine on 2/5/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit
import SwipeCellKit

class RemarkTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tickView: UIView!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var signatureLabel: UILabel!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
