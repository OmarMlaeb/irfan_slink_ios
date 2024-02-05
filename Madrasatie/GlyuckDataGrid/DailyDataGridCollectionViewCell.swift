//
//  DailyDataGridCollectionViewCell.swift
//  Madrasatie
//
//  Created by hisham noureddine on 2/1/19.
//  Copyright © 2019 Hisham Noureddine. All rights reserved.
//

import UIKit
import SDWebImage

class DailyDataGridCollectionViewCell: DataGridViewBaseCell {
    
    @IBOutlet weak var cellIcon: UIButton!
    @IBOutlet weak var cellLabel: UILabel!
    var indexPath: IndexPath!
    
    func configureWithData(_ data: String, title: String, forIndexPath indexPath: IndexPath) {
        self.indexPath = indexPath
        if data.contains("http"){
//            cellIcon.sd_setShowActivityIndicatorView(true)
//            cellIcon.sd_setIndicatorStyle(.gray)
            cellIcon.sd_setImage(with: URL(string: data), for: .normal) { (image, error, cache, url) in
                if image != nil{
                    self.cellIcon.setImage(image!.withRenderingMode(.alwaysOriginal), for: .normal)
                }
//                self.cellIcon.sd_setShowActivityIndicatorView(false)
            }
        }else{
            cellIcon.setImage(UIImage(named: "subject")!.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        self.cellLabel.text = title
    }
    
    func configureIndexPath(indexPath: IndexPath){
        self.indexPath = indexPath
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellIcon.tintColor = .clear
    }

}
