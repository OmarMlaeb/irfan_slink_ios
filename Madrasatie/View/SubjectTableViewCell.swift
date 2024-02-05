//
//  SubjectTableViewCell.swift
//  Madrasatie
//
//  Created by hisham noureddine on 10/24/18.
//  Copyright © 2018 Hisham Noureddine. All rights reserved.
//

import UIKit
import RATreeView

class SubjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var subSubjectTitleLabel: UILabel!
    @IBOutlet weak var expendButton: UIButton!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var viewLeading: NSLayoutConstraint!
    @IBOutlet weak var tickView: UIView!
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var enterGradeButton: UIButton!
    @IBOutlet weak var tickButton: UIButton!
    
    let numberFormatter = NumberFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberFormatter.numberStyle = .decimal
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setup(withItem item: DataObject, title: String, mark: Float, backgroundColor: String, level: Int, userType: Int, currentSection: Int, maxSection: Int, checked: Bool, user: User) {
        subSubjectTitleLabel.text = title
        let fullMark = numberFormatter.string(from: item.fullMark as NSNumber)
        var finalMark = ""
        if(mark == 0){
            finalMark = "-/\(fullMark ?? "")"
            if(item.fullMark == 0){
                finalMark = "-/-"
            }
        }
        else{
            finalMark = "\(mark)/\(fullMark ?? "")"
        }
        markLabel.text = finalMark
        enterGradeButton.isHidden = true
        expendButton.isHidden = false
        markLabel.isHidden = false
        switch level{
        case 0:
            tickButton.isUserInteractionEnabled = false
            break
        case 1:
            if userType == 2{
                tickButton.isHidden = true
                tickView.isHidden = true
                lineView.isHidden = true
                topView.isHidden = true
                bottomView.isHidden = true
                tickView.isHidden = true
                tickImageView.isHidden = true
                if item.children.isEmpty{
                    markLabel.isHidden = true
                    enterGradeButton.isHidden = false
//                    if user.privileges.contains(App.viewResultPrivilege){
//                        enterGradeButton.isHidden = false
                        if item.editable{
                            if mark > 0{
                                enterGradeButton.setTitle("Edit Grades".localiz(), for: .normal)
                            }else{
                                enterGradeButton.setTitle("Enter Grades".localiz(), for: .normal)
                            }
                        }else{
                            enterGradeButton.setTitle("View Grades".localiz(), for: .normal)
                        }
//                    }else{
//                        enterGradeButton.isHidden = true
//                    }
                }else{
                    markLabel.isHidden = false
                    enterGradeButton.isHidden = true
                }
            }else{
                tickButton.isHidden = false
                tickButton.isUserInteractionEnabled = true
                lineView.isHidden = true
                topView.isHidden = false
                bottomView.isHidden = false
                tickView.isHidden = false
                tickImageView.isHidden = false
                if currentSection == 0{
                    topView.isHidden = true
                }
                if checked{
                    tickView.backgroundColor = App.hexStringToUIColor(hex: backgroundColor, alpha: 1.0)
                    tickImageView.isHidden = false
                    tickView.layer.borderWidth = 0
                }else{
                    tickView.backgroundColor = .white
                    tickImageView.isHidden = true
                    tickView.layer.borderWidth = 1
                    tickView.layer.borderColor = App.hexStringToUIColorCst(hex: "#808285", alpha: 1.0).cgColor
                }
            }
            self.subjectView.backgroundColor = App.hexStringToUIColor(hex: backgroundColor, alpha: 1.0)
            if item.children.isEmpty{
                self.expendButton.isHidden = true
            }else{
                self.expendButton.isHidden = false
            }
        case 2:
            if userType == 2{
                tickButton.isHidden = true
                lineView.isHidden = true
                topView.isHidden = true
                bottomView.isHidden = true
                tickView.isHidden = true
                tickImageView.isHidden = true
                if item.children.isEmpty{
                    markLabel.isHidden = true
                    enterGradeButton.isHidden = false
                    if item.editable{
                        if mark > 0{
                            enterGradeButton.setTitle("Edit Grades".localiz(), for: .normal)
                        }else{
                            enterGradeButton.setTitle("Enter Grades".localiz(), for: .normal)
                        }
                    }else{
                        enterGradeButton.setTitle("View Grades".localiz(), for: .normal)
                    }
                }else{
                    markLabel.isHidden = false
                    enterGradeButton.isHidden = true
                }
            }else{
                tickButton.isHidden = false
                tickButton.isUserInteractionEnabled = false
                lineView.isHidden = false
                topView.isHidden = true
                bottomView.isHidden = true
                tickView.isHidden = true
                tickImageView.isHidden = true
            }
            
            self.subjectView.backgroundColor = App.hexStringToUIColor(hex: backgroundColor, alpha: 0.5)
            if item.children.isEmpty{
                self.expendButton.isHidden = true
            }else{
                self.expendButton.isHidden = false
            }
        default:
            tickButton.isUserInteractionEnabled = false
            self.expendButton.isHidden = true
            markLabel.isHidden = false
            lineView.isHidden = false
            topView.isHidden = true
            bottomView.isHidden = true
            tickView.isHidden = true
            tickImageView.isHidden = true
            self.subjectView.backgroundColor = App.hexStringToUIColor(hex: backgroundColor, alpha: 0.5)
            if userType == 2{
                markLabel.isHidden = true
                enterGradeButton.isHidden = false
                expendButton.isHidden = true
                markLabel.isHidden = true
                lineView.isHidden = true
                if item.editable{
                    if mark > 0{
                        enterGradeButton.setTitle("Edit Grades".localiz(), for: .normal)
                    }else{
                        enterGradeButton.setTitle("Enter Grades".localiz(), for: .normal)
                    }
                }else{
                    enterGradeButton.setTitle("View Grades".localiz(), for: .normal)
                }
            }
        }
        if currentSection == maxSection-1{
            bottomView.isHidden = true
            lineView.isHidden = true
        }
        
        let left = 16 * CGFloat(level)
        self.viewLeading.constant = 40 + left
        self.contentView.layoutIfNeeded()
    }
    
}
