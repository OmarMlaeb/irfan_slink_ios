//
//  NSManagedObject+Extension.swift
//  Tensator
//
//  Created by Miled Aoun on 8/6/18.
//  Copyright © 2018 Forofor. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    func integer(forKey key: String) -> Int {
        return self.value(forKey: key) as? Int ?? 0
    }
    
    func string(forKey key: String) -> String {
        return self.value(forKey: key) as? String ?? ""
    }
    
    func double(forKey key: String) -> Double {
        return self.value(forKey: key) as? Double ?? 0
    }
    
    func bool(forKey key: String) -> Bool {
        return self.value(forKey: key) as? Bool ?? false
    }
    
    func strings(forKey key: String) -> [String] {
        return self.value(forKey: key) as? [String] ?? []
    }
    
    func object(forKey key: String) -> NSManagedObject? {
        return self.value(forKey: key) as? NSManagedObject
    }
    
    func dates(forKey key: String) -> Date {
        return self.value(forKey: key) as? Date ?? Date()
    }
}
