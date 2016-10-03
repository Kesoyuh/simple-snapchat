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
    
    var searchController = UISearchController(searchResultsController: nil)
    var filterMessages = [Message]()
    
    
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
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
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
    
    func filterContentForSearch(searchText: String, scope: String = "All"){
        
        filterMessages = messages.filter({ (message) -> Bool in
            let index = messages.index(of: message)! as Int
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ChatCell {
                  return (cell.textLabel?.text!.localizedLowercase.contains(searchText.localizedLowercase))!
            }else {
                return false
            }
//            return (cell.textLabel?.text!.localizedLowercase.contains(searchText.localizedLowercase))!
     })
        print("----FILTER MESSAGES-------",filterMessages)
        tableView.reloadData()
    }
    

    
    
    func observeUserMessages(){
        guard  let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userID = snapshot.key
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.fetchMessageWithID(messageID: messageID)
                }, withCancel: nil)
        })
    }
    
    private func fetchMessageWithID(messageID: String){
        let msgRef = FIRDatabase.database().reference().child("messages").child(messageID)
        msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message(dictionary: dictionary)
                // Group messages by id
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                self.attemptReloadOfTable()
            }
            }, withCancel: nil)
    }
    
 
    
    private func attemptReloadOfTable(){
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    func handleReloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        //Sort the messages by timestamp
        self.messages.sort(by: {
            (m1,m2) ->Bool in
            return (m1.timestamp?.intValue)! > (m2.timestamp?.intValue)!
        })
        
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                print("We reloaded the table")
                self.tableView.reloadData()
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            print("Update filter messages number!!!!")
            return filterMessages.count
        }
        
        return messages.count
    }
    
    
    // Display value for cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatCell
        let message: Message
        
        if searchController.isActive && searchController.searchBar.text != ""{
            message = filterMessages[indexPath.row]
            print("Update filter messages cell!!!")
        }else{
            message = messages[indexPath.row]
        }
        
        cell.message = message
        return cell
        
    }
    
    //Start a chat --> ChatLogController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message: Message
        print("When I want to start a chat, the index is :", indexPath)
        if searchController.isActive {
         message = filterMessages[indexPath.row]
        }else{
            message = messages[indexPath.row]
        }
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

extension ChatListTableViewController : UISearchResultsUpdating{
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchText: searchController.searchBar.text!)
    }

    
}

/**TODO: Change status bar color Doesn't work!!!!!!
 override var preferredStatusBarStyle: UIStatusBarStyle {
 return .lightContent
 }**/
