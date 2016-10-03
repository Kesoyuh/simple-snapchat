//
//  User.swift
//  simple-snapchat
//
//  Created by Helen on 27/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class User: NSObject {
    var id: String?
    var name : String?
    var email : String?
    var stories = [Story]()
    
    func printDetail() {
        print(id)
        print(name)
        for i in 0..<stories.count {
            let story = stories[i]
            print(story.imageURL)
            print(story.timer)
        }
    }
}
