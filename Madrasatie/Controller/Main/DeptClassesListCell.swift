//
//  DeptClassesListCell.swift
//  Madrasatie
//

import UIKit
import PWSwitch

class DeptClassesListCell: UITableViewCell {
    
//    @IBOutlet weak var entireDepSwitch: PWSwitch!
//    @IBOutlet weak var plusImage: UIImageView!
//    @IBOutlet weak var depName: UILabel!
    
    @IBOutlet weak var entireClassSwitch: PWSwitch!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var classPlusImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

