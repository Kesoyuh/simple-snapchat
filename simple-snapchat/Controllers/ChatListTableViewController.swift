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
    var uid : String?
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
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
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if uid != FIRAuth.auth()?.currentUser?.uid{
            messages.removeAll()
            messagesDictionary.removeAll()
            uid = FIRAuth.auth()?.currentUser?.uid
            observeUserMessages()
        }
        
    }
    
    func observeUserMessages(){
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            print("observe current user's messages...")
            print(uid)
            let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
            ref.observe(.childAdded, with: { (snapshot) in
                if let messageID = snapshot.key as? String {
                    let msgRef = FIRDatabase.database().reference().child("messages").child(messageID)
                    msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        print(snapshot)
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            let message = Message()
                            message.setValuesForKeys(dictionary)
                            
                            // Group messages by id
                            if let chatPartnerId = message.chatPartnerId() {
                                self.messagesDictionary[chatPartnerId] = message
                                self.messages = Array(self.messagesDictionary.values)
                            
                            }
                            //Sort the messages by timestamp
                            self.messages.sort(by: {
                                (m1,m2) ->Bool in
                                return (m1.timestamp?.intValue)! > (m2.timestamp?.intValue)!
                            })

                                DispatchQueue.global().async {
                                DispatchQueue.main.async {
                                    
                                    self.tableView.reloadData()
                                   
                                }
                            }
                        }
                        }, withCancel: nil)
                }
            })
        }
    }
        
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    // Display value for cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell

    }
    
        //Start a chat --> ChatLogController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        showChatLogControllerForUser(uid: chatPartnerId)
    }
    
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    

    func showChatLogControllerForUser(uid: String){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
        chatLogController.partnerId = uid
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
