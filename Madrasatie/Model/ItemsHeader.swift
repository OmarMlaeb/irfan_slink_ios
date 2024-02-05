//
//  ItemsHeader.swift
//  Madrasati
//
//  Created by hisham noureddine on 8/6/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

struct ItemsHeader: CollapsableSectionItemProtocol{
    var isVisible: Bool
    var items: [CalendarEventItem]
    var title: String
}
