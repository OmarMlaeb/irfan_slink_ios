//
//  MessageDepartment.swift
//  IRFAN Schools
//
//  Created by Maher Jaber on 25/10/2021.
//  Copyright © 2021 IQUAD. All rights reserved.
//

import Foundation
struct MessageDepartment{
    var id: String
    var name: String
    var employees: [Student]
    var active: Bool
   
    public init(id: String, name: String, employees: [Student], active: Bool){
        self.id = id
        self.name = name
        self.employees = employees
        self.active = active
       
    }
}
