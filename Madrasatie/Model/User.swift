//
//  User.swift
//  Madrasati
//
//  Created by hisham noureddine on 7/23/18.
//  Copyright © 2018 nova4lb. All rights reserved.
//

import Foundation

//usertypes
//1-admin
//2-employee
//3-student
//4-parent

struct User{
//    var tokenId: Int
//    var refreshToken: String
    var token: String
//    var oauthId: Int
    var userName: String
    var schoolId: String
    var firstName: String
    var lastName: String
    var userId: Int
    var email: String
    var googleToken: String
    var gender: String
    var cycle: String
    var photo: String
    var userType: Int
    var batchId: Int
    var imperiumCode: String
    var className: String
    var childrens: [Children]
    var classes: [Class]
    var privileges: [String]
    var firstLogin: Bool
    var admissionNo: String
    var bdDate: Date
    var isBdChecked: Bool
    var blocked: Bool
    var password: String
    
//    var emplayee: Bool
//    var blocked: Bool
//    var email: String
//    var admin: Bool
//    var firstLognIn: Bool
//    var parent: Bool
//    var student: Bool
//    var deleted: Bool
//    var phone: String
}
