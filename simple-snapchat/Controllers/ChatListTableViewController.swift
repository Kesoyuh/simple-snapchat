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
    var friends = [Friend]()
    var filterFriends = [Friend]()
    var searchController = UISearchController(searchResultsController: nil)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "NewChat", style: .plain, target: self, action: #selector(addNewChat))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Camera", style: .plain, target: self, action: #selector(cameraView))
        
        navigationItem.title = "Chat"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 102, green: 178, blue: 255)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        navigationController?.navigationBar.isHidden = false
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        friends.removeAll()
        uid = FIRAuth.auth()?.currentUser?.uid
        fetchFriends()
    }
    
    func filterContentForSearch(searchText: String, scope: String = "All"){
        filterFriends = friends.filter({ (friend) -> Bool in
            return (friend.name?.localizedLowercase.contains(searchText.localizedLowercase))!
        })
        print("This is the filter function", filterFriends)
        tableView.reloadData()
        
    }
    
    
    
    
    func fetchFriends(){
        guard  let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("friendship-level").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            print("Here I fetch the friends",snapshot)
            let thisFriend = Friend()
            let friendID = snapshot.key
            thisFriend.id = friendID
            thisFriend.friendLevel = snapshot.value as! Int?
            let friendRef = FIRDatabase.database().reference().child("users").child(friendID)
            friendRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    thisFriend.email = dictionary["email"] as! String?
                    thisFriend.name = dictionary["name"] as! String?
                    self.friends.append(thisFriend)
                    
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            print("Here I reload the data!")
                        }
                    }
                }
            })
            
        })
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterFriends.count
        }
        
        return friends.count
    }
    
    
    // Display value for cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let friend : Friend
        
        if searchController.isActive && searchController.searchBar.text != "" {
            friend = filterFriends[indexPath.row]
        }else {
            friend = friends[indexPath.row]
        }
        
        cell.textLabel?.text = friend.name
        cell.detailTextLabel?.text = friend.getFriendshipLevel()
        
        return cell
        
    }
    
    //Start a chat --> ChatLogController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend : Friend
        if searchController.isActive  && searchController.searchBar.text != "" {
            print("This is a filter friend!There are ", filterFriends.count, " the index is ", indexPath.row)
            friend = filterFriends[indexPath.row]
            print(filterFriends)
        }else{
            print("This is a friend! There are ", friends.count, " the index is ", indexPath.row)
            friend = friends[indexPath.row]
            print(friends)
        }
        
        guard let chatPartnerId = friend.id else {
            return
        }
        if searchController.isActive  && searchController.searchBar.text != "" {
            searchController.dismiss(animated: true) {
                self.searchController.searchBar.text = ""
                self.searchController.isActive = false
                print("I want to chat with filter friend",indexPath.row, "in", self.filterFriends.count)
                print(self.filterFriends)
                self.showChatLogControllerForUser(uid: chatPartnerId)
            }
        }else{
            print("I want to chat with friend",indexPath.row, "in", friends.count)
            print(friends)
            self.showChatLogControllerForUser(uid: chatPartnerId)
        }
        
        
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
        let scrollView = self.navigationController?.view?.superview as? UIScrollView
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            scrollView!.contentOffset.x = self.view.frame.width
            }, completion: nil)
  
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

