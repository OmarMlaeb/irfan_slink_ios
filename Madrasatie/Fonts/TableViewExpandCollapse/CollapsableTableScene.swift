//
//  RRNCollapsableTableViewController.swift
//  Mr Grocer
//
//  Created by Miled Aoun on 22/09/2015.
//  Copyright © 2015 Miled Aoun. All rights reserved.
//

import UIKit

class CollapsableTableViewController: UIViewController, CollapsableSectionHeaderGalleryProtocol {
    func galleryTapped(_ view: CollapsableSectionHeaderProtocol) {
        if let tableView = self.collapsableTableView() {
                   
                   let section = view.tag
                   
                   switch section {
                   case let x where x-4 < (self.model ?? []).count:
                       tableView.beginUpdates()
                       
                       var foundOpenUnchosenMenuSection = false
                       let menu = self.model
                       
                       if let menu = menu {
                           
                           var count = 0
                           
                           for var menuSection in menu {
                               
                               let chosenMenuSection = (section-4 == count)
                               
                               let isVisible = menuSection.isVisible
                               
                               if isVisible && chosenMenuSection {
                                   
                                   menuSection.isVisible = false
                                   self.model?[count] = menuSection
                                   
                                   view.close(true)
                                   
                                   let indexPaths = self.indexPaths(section-4, menuSection: menuSection)
                                   
                                   tableView.deleteRows(at: indexPaths, with: (foundOpenUnchosenMenuSection) ? .bottom : .top)
                                   tableView.endUpdates()
                                   
                               } else if !isVisible && chosenMenuSection {
                                   
                                   menuSection.isVisible = true
                                   self.model?[count] = menuSection
                                   
                                   view.open(true)
                                   
                                   let indexPaths = self.indexPaths(section-4, menuSection: menuSection)
                                   tableView.insertRows(at: indexPaths, with: (foundOpenUnchosenMenuSection) ? .bottom : .top)
                                   tableView.endUpdates()
                                   
                               } else if isVisible && !chosenMenuSection && self.singleOpenSelectionOnly() {
                                   
                                   foundOpenUnchosenMenuSection = true
                                   
                                   menuSection.isVisible = false
                                   self.model?[count] = menuSection
                                   
                                   let headerView = tableView.headerView(forSection: count)
                                   
                                   if let headerView = headerView as? CollapsableSectionHeaderProtocol {
                                       headerView.close(true)
                                   }
                                   
                                   let indexPaths = self.indexPaths(count, menuSection: menuSection)
                                   
                                   tableView.deleteRows(at: indexPaths, with: (view.tag > count) ? .top : .bottom)
                                   tableView.endUpdates()
                               }
                               
                               count += 1
                           }
                           
                       }
                   default:
                       break
                   }
               }
    }
    
    
    var model: [CollapsableSectionItemProtocol]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let
            _ = self.collapsableTableView(),
            let nibName = self.sectionHeaderNibName(),
            let _ = self.sectionHeaderReuseIdentifier()
        {
            _ = UINib(nibName: nibName, bundle: nil)
//            tableView.register(nib, forHeaderFooterViewReuseIdentifier: reuseID)
        }
    }
    
    func collapsableTableView() -> UITableView? {
        return nil
    }
    
    func singleOpenSelectionOnly() -> Bool {
        return false
    }
    
    func sectionHeaderNibName() -> String? {
        return nil
    }
    
    func sectionHeaderReuseIdentifier() -> String? {
        return (self.sectionHeaderNibName())!
    }
}

extension CollapsableTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.model ?? []).count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let menuSection = self.model?[section]
        return (menuSection?.isVisible ?? false) ? menuSection!.items.count : 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 4){
            var view: CollapsableSectionHeaderProtocol?
                   
                   if let reuseID = self.sectionHeaderReuseIdentifier() {
                       view = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseID) as? CollapsableSectionHeaderProtocol
                   }
                   
                   view?.tag = section
                   
                   let menuSection = self.model?[section]
                   view?.sectionTitleLabel.text = (menuSection?.title ?? "").uppercased()
                   view?.galleryDelegate = self
                   
                   return view as? UIView
        }
        else{
            var view: CollapsableSectionHeaderProtocol?
                   
                   if let reuseID = self.sectionHeaderReuseIdentifier() {
                       view = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseID) as? CollapsableSectionHeaderProtocol
                   }
                   
                   view?.tag = section
                   
                   let menuSection = self.model?[section]
                   view?.sectionTitleLabel.text = (menuSection?.title ?? "").uppercased()
                   view?.interactionDelegate = self
                   
                   return view as? UIView
        }
        
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension CollapsableTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if(section == 4 || section == 5){
            if let view = view as? CollapsableSectionHeaderProtocol {
                let menuSection = self.model?[section-4]
                if (menuSection?.isVisible ?? false) {
                    view.open(false)
                } else {
                    view.close(false)
                }
            }
        }
        else{
            if let view = view as? CollapsableSectionHeaderProtocol {
                let menuSection = self.model?[section-8]
                if (menuSection?.isVisible ?? false) {
                    view.open(false)
                } else {
                    view.close(false)
                }
            }
        }
        
    }
}

extension CollapsableTableViewController: CollapsableSectionHeaderReactiveProtocol {
    
    func userTapped(_ view: CollapsableSectionHeaderProtocol) {
        print("usertapped")
        
        if let tableView = self.collapsableTableView() {
            
            let section = view.tag
            
            switch section {
            case let x where x-8 < (self.model ?? []).count:
                tableView.beginUpdates()
                
                var foundOpenUnchosenMenuSection = false
                let menu = self.model
                
                if let menu = menu {
                    
                    var count = 0
                    
                    for var menuSection in menu {
                        
                        let chosenMenuSection = (section-8 == count)
                        
                        let isVisible = menuSection.isVisible
                        
                        if isVisible && chosenMenuSection {
                            
                            menuSection.isVisible = false
                            self.model?[count] = menuSection
                            
                            view.close(true)
                            
                            let indexPaths = self.indexPaths(section-8, menuSection: menuSection)
                            
                            tableView.deleteRows(at: indexPaths, with: (foundOpenUnchosenMenuSection) ? .bottom : .top)
                            tableView.endUpdates()
                            
                        } else if !isVisible && chosenMenuSection {
                            
                            menuSection.isVisible = true
                            self.model?[count] = menuSection
                            
                            view.open(true)
                            
                            let indexPaths = self.indexPaths(section-8, menuSection: menuSection)
                            tableView.insertRows(at: indexPaths, with: (foundOpenUnchosenMenuSection) ? .bottom : .top)
                            tableView.endUpdates()
                            
                        } else if isVisible && !chosenMenuSection && self.singleOpenSelectionOnly() {
                            
                            foundOpenUnchosenMenuSection = true
                            
                            menuSection.isVisible = false
                            self.model?[count] = menuSection
                            
                            let headerView = tableView.headerView(forSection: count)
                            
                            if let headerView = headerView as? CollapsableSectionHeaderProtocol {
                                headerView.close(true)
                            }
                            
                            let indexPaths = self.indexPaths(count, menuSection: menuSection)
                            
                            tableView.deleteRows(at: indexPaths, with: (view.tag > count) ? .top : .bottom)
                            tableView.endUpdates()
                        }
                        
                        count += 1
                    }
                    
                }
            default:
                break
            }
        }
    }
    
    func indexPaths(_ section: Int, menuSection: CollapsableSectionItemProtocol) -> [IndexPath] {
        var collector = [IndexPath]()
        
        var indexPath: IndexPath
        if(section == 4 || section == 5){
            for i in 0 ..< menuSection.items.count {
                indexPath = IndexPath(row: i, section: section+8)
                collector.append(indexPath)
            }
        }
        else{
            for i in 0 ..< menuSection.items.count {
                indexPath = IndexPath(row: i, section: section+8)
                collector.append(indexPath)
            }
        }
        
        
        return collector
    }
}
