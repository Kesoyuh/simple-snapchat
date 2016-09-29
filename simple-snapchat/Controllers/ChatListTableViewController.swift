//
//  ChatListTableViewController.swift
//  simple-snapchat
//
//  Created by Helen on 26/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase

class ChatListTableViewController: UITableViewController {

    let cellId = "ChatCellId"
    
    var chatHistory = [User]()
    var messages = [Message]()
    
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
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }

            }
           print("Observe messages:")
           print(self.messages)
            
            }, withCancel: nil)
    }
        
    
    //************************************************************************TODO: Change to fetch chat list latter
    func fetchUser(){
        
        self.chatHistory = [User]()
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                self.chatHistory.append(user)
            }
            
            DispatchQueue.global().async {
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

            }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    // Display value for cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let message = messages[indexPath.row]

        //TODO: check message type, show message if the type is text, others show "New message"
        cell.textLabel?.text = message.toID
        
        cell.detailTextLabel?.text = message.text
        return cell

    }
    

    //Start a chat --> ChatLogController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let user = chatHistory[indexPath.row]
        //showChatLogControllerForUser(user: user)
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
