//
//  NotificationHeader.swift
//  Reel
//
//  Created by Miled Aoun on 3/20/17.
//  Copyright © 2017 NOVA4. All rights reserved.
//

import Foundation
import UIKit

final class ProductHeader: UIView, CollapsableSectionHeaderProtocol {
    var galleryDelegate: CollapsableSectionHeaderGalleryProtocol!
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIButton!
    
    var interactionDelegate: CollapsableSectionHeaderReactiveProtocol!
    
    func radians(_ degrees: Double) -> Double {
        return Double.pi * degrees / 180.0
    }
    
    fileprivate var isRotating = false
    
    func close(_ animated: Bool) {
        
        if animated && !isRotating {
            
            isRotating = true
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveLinear], animations: { () -> Void in
                self.arrowImageView.transform = CGAffineTransform.identity
                self.arrowImageView.setImage(UIImage(named: "+"), for: .normal)
            }, completion: { (finished) -> Void in
                self.isRotating = false
            })
        } else {
            layer.removeAllAnimations()
            arrowImageView.transform = CGAffineTransform.identity
            self.arrowImageView.setImage(UIImage(named: "+"), for: .normal)
            isRotating = false
        }
    }
    
    func open(_ animated: Bool) {
        
        if animated && !isRotating {
            
            isRotating = true
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveLinear], animations: { () -> Void in
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(self.radians(180.0)))
                self.arrowImageView.setImage(UIImage(named: "-"), for: .normal)
            }, completion: { (finished) -> Void in
                self.isRotating = false
            })
        } else {
            layer.removeAllAnimations()
            arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(radians(180.0)))
            self.arrowImageView.setImage(UIImage(named: "-"), for: .normal)
            isRotating = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        interactionDelegate?.userTapped(self)
        galleryDelegate?.galleryTapped(self)
    }
}
