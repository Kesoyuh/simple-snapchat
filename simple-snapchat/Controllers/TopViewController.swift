//
//  TopViewController.swift
//  snapchat
//
//  Created by Jeffrey on 21/09/2016.
//  Copyright © 2016 Boqin Hu. All rights reserved.
//

import UIKit
import Parse

class TopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: UIButton) {
        PFUser.logOut()
        let loginRegisterController = LoginRegisterController()
        let scrollView = self.view.superview as? UIScrollView
        scrollView!.contentOffset.y = view.bounds.height
        present(loginRegisterController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
