//
//  ControlLayer.swift
//  Senboke
//
//  Created by Miled Aoun on 3/21/19.
//  Copyright © 2019 NOVA4. All rights reserved.
//

import QuartzCore

class ControlLayer: CAShapeLayer {
    override init() {
        super.init()
        self.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "position": NSNull()
        ]
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
