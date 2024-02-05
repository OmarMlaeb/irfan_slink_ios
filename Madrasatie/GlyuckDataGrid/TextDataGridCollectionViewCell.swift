//
//  TextDataGridCollectionViewCell.swift
//  Madrasatie
//
//  Created by hisham noureddine on 2/6/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit

class TextDataGridCollectionViewCell: DataGridViewBaseCell {

    @IBOutlet weak var titleTextLabel: UILabel!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWithData(_ data: String, forIndexPath indexPath: IndexPath) {
        self.indexPath = indexPath
        self.titleTextLabel.text = data
    }
    
    func configureIndexPath(indexPath: IndexPath){
        self.indexPath = indexPath
    }

}
