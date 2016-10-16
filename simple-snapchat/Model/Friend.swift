//
//  Friend.swift
//  simple-snapchat
//
//  Created by Helen on 16/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class Friend: NSObject {
    var id: String?
    var name : String?
    var email : String?
    var friendLevel : Int?
    
    func getFriendshipLevel() -> String {
        if friendLevel! < 10 {
            return "New Friend"
        }else if friendLevel! >= 10 {
            return "Good Friend"
        }else if friendLevel! > 20 {
            return "Best Friend"
        }else {
            return ""
        }
    }
}
