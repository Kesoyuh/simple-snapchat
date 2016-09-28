//
//  ChatListTableViewController.swift
//  simple-snapchat
//
//  Created by Helen on 26/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Parse

class ChatListTableViewController: UITableViewController {

    let cellId = "ChatCellId"
    
    var chatHistory = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "NewChat", style: .plain, target: self, action: #selector(addNewChat))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Camera", style: .plain, target: self, action: #selector(cameraView))
    
        navigationItem.title = "Chat"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 102, green: 178, blue: 255)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        navigationController?.navigationBar.isHidden = false
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellId)
        
        
        //fetchUser()
        observeMessage()
        
        
    }
    
    func observeMessage(){
    
    }
        
    
    //************************************************************************TODO: Change to fetch friend latter
    func fetchUser(){
        var query:PFQuery = PFUser.query()!
        // Create a new PFQuery
        // Call findObjectInBackground
        query.findObjectsInBackground{(objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                
                /*** Do something with the found objects ***/
                
                // 1. Clear the users so that there is no duplications
                self.chatHistory = [User]()
                
                // 2. Loop through the objects array
                if let objects = objects {
                    for userObject in objects {
                        let user = User()
                        user.username = userObject["username"] as! String?
                        user.email = userObject["email"] as! String?
                        user.id = userObject.objectId
                        print(user.username, user.email)
                        self.chatHistory.append(user)
                        
                        //***********************Swift 3 dispatch*******************//
                        DispatchQueue.global().async {
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
                
            } else {
                print("fetch error!")
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatHistory.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let user = chatHistory[indexPath.row]
        
        cell.textLabel?.text = user.username
        
        //*********************************************************************************TODO: Chage this to last chat time***********************
        cell.detailTextLabel?.text = user.email
        return cell
    }

    //Start a chat --> ChatLogController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = chatHistory[indexPath.row]
        showChatLogControllerForUser(user: user)
    }
    
    func showChatLogControllerForUser(user: User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
        chatLogController.user = user
        print(user)
    }
    
    //TODO: When click the top left button, choosing a friend to chat with
        func addNewChat(){
            let newChatController = NewChatTableViewController()
            newChatController.chatListController = self
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


class ChatCell: UITableViewCell{
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
}


}
