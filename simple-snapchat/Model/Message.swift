//
//  Message.swift
//  simple-snapchat
//
//  Created by Helen on 28/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit




class Messages:NSObject{
    var type: String!
    var content: AnyObject!
    var timestamp: NSNumber!
    var users: [User] = []
    
    func addNewMessage(newType: String, newContent: AnyObject, newDate: NSNumber, newUsers: [User]){
        type = newType
        content = newContent
        timestamp = newDate
        users = newUsers
        
    }
}
