//
//  SchoolSwitchCell.swift
//  Madrasatie
//
//  Created by Maher Jaber on 4/19/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import UIKit
import PWSwitch

class SchoolSwitchCell: UITableViewCell {
    
    @IBOutlet weak var allSchoolSwitch: PWSwitch!
    @IBOutlet weak var addAlbumText: UILabel!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
       }

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)

           // Configure the view for the selected state
       }
}
