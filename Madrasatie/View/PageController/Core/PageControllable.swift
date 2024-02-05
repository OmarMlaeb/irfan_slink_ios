//
//  PageControllable.swift
//  Senboke
//
//  Created by Miled Aoun on 3/21/19.
//  Copyright © 2019 NOVA4. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

protocol PageControllable: class {
    var numberOfPages: Int { get set }
    var currentPage: Int { get }
    var progress: Double { get set }
    var hidesForSinglePage: Bool { get set }
    var borderWidth: CGFloat { get set }

    func set(progress: Int, animated: Bool)
}
