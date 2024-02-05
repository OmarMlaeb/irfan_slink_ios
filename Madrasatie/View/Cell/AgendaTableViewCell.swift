//
//  AgendaTableViewCell.swift
//  Madrasatie
//
//  Created by hisham noureddine on 2/5/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit
import SwipeCellKit
import ActiveLabel

class AgendaTableViewCell: SwipeTableViewCell {
    
//    var actionBlock: (() -> ())?
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tickView: UIView!
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var openStudentsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionLabel.enabledTypes = [.mention, .hashtag, .url]
        descriptionLabel.numberOfLines = 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
