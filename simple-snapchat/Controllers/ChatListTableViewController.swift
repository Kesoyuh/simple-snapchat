//
//  ChatListTableViewController.swift
//  simple-snapchat
//
//  Created by Helen on 26/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class ChatListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "NewChat", style: .plain, target: self, action: #selector(addNewChat))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Camera", style: .plain, target: self, action: #selector(cameraView))
    
        navigationItem.title = "Chat"
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 102, green: 178, blue: 255)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        navigationController?.navigationBar.isHidden = false
        
        
     
        
        
    }
        

    
    //TODO: When click the top left button, choosing a friend to chat with
        func addNewChat(){
            let newChatController = NewChatTableViewController()
            let navController = UINavigationController(rootViewController: newChatController)
            present(navController, animated:true, completion:nil)
        }
    
    
        func cameraView(){
            let cameraViewController = CameraViewController()
            present(cameraViewController, animated:true, completion:nil)
        
        }
    }



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}


/**TODO: Change status bar color Doesn't work!!!!!!
 override var preferredStatusBarStyle: UIStatusBarStyle {
 return .lightContent
 }**/


   
