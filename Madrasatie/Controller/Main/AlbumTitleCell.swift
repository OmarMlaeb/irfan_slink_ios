//
//  AlbumTitleCell.swift
//  Madrasatie
//
//  Created by Maher Jaber on 4/17/20.
//  Copyright © 2020 IQUAD. All rights reserved.
//

import UIKit

class AlbumTitleCell: UITableViewCell {

    @IBOutlet weak var albumTitleTextView: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
