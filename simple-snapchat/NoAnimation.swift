//
//  NoAnimation.swift
//  simple-snapchat
//
//  Created by Boqin Hu on 30/9/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class NoAnimation : UIStoryboardSegue {
    override func perform() {
        if let sourceVC = self.source as? UIViewController {
            sourceVC.present(self.destination , animated: false, completion: nil)
        }
    }
    

}
