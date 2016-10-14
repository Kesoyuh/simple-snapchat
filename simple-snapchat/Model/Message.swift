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
    var messageID : String!
    var text: String!

    var timestamp: NSNumber!
    var fromID: String!
    var toID: String!
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    var timer: Int?
 
    
    var latitude : String?
    var longitude: String?
    
    var partnerName: String!
    
    func chatPartnerId() ->String?{
        return fromID == FIRAuth.auth()?.currentUser?.uid ? toID: fromID
    }
    
    
//    func chatPartnerName() -> String?{
//        var name: String?
//        
//        var partnerID = chatPartnerId()
//        let partNameRef = FIRDatabase.database().reference().child("user").child(partnerID!).child("name")
//        partNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            name = snapshot as! String
//            print("Chat partner's name is :", name)
//            }, withCancel: nil)
//        while name == nil {
//            print("Wait for name...")
//        }
//        return name!
//    }
//    
    init(dictionary : [String: AnyObject]){
        super.init()

        fromID = dictionary["fromID"] as? String
        text = dictionary["text"] as? String
        toID = dictionary["toID"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
        latitude = dictionary["latitude"] as? String
        longitude = dictionary["longitude"] as? String
        timer = dictionary["timer"] as? Int
        
        
        
    }
    
}
