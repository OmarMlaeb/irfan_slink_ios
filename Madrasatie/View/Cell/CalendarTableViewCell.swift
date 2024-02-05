//
//  CalendarTableViewCell.swift
//  Madrasatie
//
//  Created by hisham noureddine on 2/5/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit
import SwipeCellKit

class CalendarTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var holidayIcon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
