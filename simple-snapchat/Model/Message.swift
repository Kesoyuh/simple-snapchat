//
//  Message.swift
//  simple-snapchat
//
//  Created by Helen on 28/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase

class Message:NSObject{
    //var type: String!
    var text: String!
    var timestamp: NSNumber!
    var fromID: String!
    var toID: String!
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    func chatPartnerId() ->String?{
        return fromID == FIRAuth.auth()?.currentUser?.uid ? toID: fromID
    }
    
    init(dictionary : [String: AnyObject]){
        super.init()
        
        fromID = dictionary["fromID"] as? String
        text = dictionary["text"] as? String
        toID = dictionary["toID"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
    }
    
}
