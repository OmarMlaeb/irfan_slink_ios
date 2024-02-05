//
//  DistributedTotalPaymentsTableVC.swift
//  Test
//
//  Created by Maher Jaber on 4/6/20.
//  Copyright © 2020 Maher Jaber. All rights reserved.
//

import UIKit

class DistributedTotalPaymentsTableVC: UITableViewCell {

    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var paid: UILabel!
    @IBOutlet weak var remaining: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
