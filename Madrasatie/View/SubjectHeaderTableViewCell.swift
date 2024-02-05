//
//  SubjectHeaderTableViewCell.swift
//  Madrasatie
//
//  Created by hisham noureddine on 10/31/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import UIKit

class SubjectHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var subjectGroupLabel: UILabel!
    @IBOutlet weak var subjectImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
