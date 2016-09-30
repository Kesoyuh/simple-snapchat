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
    
    func chatPartnerId() ->String?{
        return fromID == FIRAuth.auth()?.currentUser?.uid ? toID: fromID
    }
    
}
