//
//  RRNCollapsableSectionProtocols.swift
//  Mr Grocer
//
//  Created by Miled Aoun on 22/09/2015.
//  Copyright © 2015 Miled Aoun. All rights reserved.
//

import UIKit

protocol CollapsableSectionHeaderProtocol {
    func open(_ animated: Bool)
    func close(_ animated: Bool)
    var containerView: UIView! { get }
    var sectionTitleLabel: UILabel! { get }
//    var otherButton: UIButton! { get }
    var arrowImageView: UIButton! { get }
    var interactionDelegate: CollapsableSectionHeaderReactiveProtocol! { get set }
    var galleryDelegate: CollapsableSectionHeaderGalleryProtocol! { get set }
    var tag: Int { get set }
}

protocol CollapsableSectionHeaderReactiveProtocol {
    func userTapped(_ view: CollapsableSectionHeaderProtocol)
}
protocol CollapsableSectionHeaderGalleryProtocol {
    func galleryTapped(_ view: CollapsableSectionHeaderProtocol)
}

protocol CollapsableSectionItemProtocol {
    var title: String { get }
    var isVisible: Bool { get set }
    var items: [CalendarEventItem] { get set }
}
