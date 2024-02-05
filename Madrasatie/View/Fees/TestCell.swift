//
//  TestCell.swift
//  Test
//
//  Created by Maher Jaber on 4/2/20.
//  Copyright © 2020 Maher Jaber. All rights reserved.
//

import UIKit

class TestCell: UITableViewCell {

    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var value: UILabel!
    
    @IBOutlet weak var test: UILabel!
    @IBOutlet weak var background: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        background.layer.cornerRadius = background.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
