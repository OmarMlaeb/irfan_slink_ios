//
//  DistributedPaymentsTableViewCell.swift
//  Test
//
//  Created by Maher Jaber on 4/3/20.
//  Copyright © 2020 Maher Jaber. All rights reserved.
//

import UIKit

class DistributedPaymentsTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentsCount: UILabel!
    @IBOutlet weak var paymentCountValue: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var amountValue: UILabel!
    @IBOutlet weak var paidAmount: UILabel!
    @IBOutlet weak var remaining: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var dueDateValue: UILabel!
    
    @IBOutlet weak var remainingValue: UILabel!
    
    @IBOutlet weak var distributedBackground: UIView!
    
    @IBOutlet weak var paidAmountValue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
