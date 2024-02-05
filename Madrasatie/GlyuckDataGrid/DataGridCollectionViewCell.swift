//
//  DataGridCollectionViewCell.swift
//  Madrasatie
//
//  Created by hisham noureddine on 9/26/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import UIKit
import SDWebImage

//protocol DataGridCellDelegate {
//    func spreadSheetCell(_ cell: DataGridCollectionViewCell, didUpdateData data: String, atIndexPath indexPath: IndexPath)
//}

class DataGridCollectionViewCell: DataGridViewBaseCell {

    @IBOutlet weak var cellIcon: UIButton!
    var indexPath: IndexPath!
    
//    var delegate: DataGridCellDelegate?
    
    func configureWithData(_ data: String, forIndexPath indexPath: IndexPath) {
        self.indexPath = indexPath
        if data.contains("http"){
//            cellIcon.sd_setShowActivityIndicatorView(true)
//            cellIcon.sd_setIndicatorStyle(.gray)
            cellIcon.sd_setImage(with: URL(string: data), for: .normal) { (image, error, cashe, url) in
//                self.cellIcon.sd_setShowActivityIndicatorView(false)
            }
//            cellIcon.sd_setImage(with: URL(string: data), for: .normal, completed: nil)
        }else{
//            cellIcon.setImage(UIImage(named: data), for: .normal)
            cellIcon.setImage(UIImage(named: "subject"), for: .normal)
        }
    }
    
    func configureIndexPath(indexPath: IndexPath){
        self.indexPath = indexPath
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
