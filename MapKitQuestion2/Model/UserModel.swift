//
//  UserModel.swift
//  MapKitQuestion2
//
//  Created by ChuoiChien on 10/3/24.
//

import UIKit

class UserModel {
    static let shared = UserModel()
    var userName: String?
    var passWord: String?
    var point = 0
    var isLogin = false
    var listItemPurchased = [Item]()
    
    private init() { }
}
