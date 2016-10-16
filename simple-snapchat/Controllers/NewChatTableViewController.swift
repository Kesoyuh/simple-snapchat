//
//  NewChatTableViewController.swift
//  simple-snapchat
//
//  Created by Helen on 26/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase

// Add a new chat by choosing a friend

class NewChatTableViewController: UITableViewController {
    
    let cellID = "newChatCellId"
    var chatListController: ChatListTableViewController?
    
    //************************************************************************TODO:Currently show all users, latter show firnds
    var friends = [User]()
    var filterFriends = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target:self, action: #selector(handleCancel))
        navigationItem.title = "Chat with..."
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor(red: 102, green: 178, blue: 255)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 102, green: 178, blue: 255)]
        navigationController?.navigationBar.isHidden = false
        
        fetchFriends()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filterFriends = friends.filter({ (friend) -> Bool in
            return (friend.name?.localizedLowercase.contains(searchText.localizedLowercase))!
        })
        tableView.reloadData()
    }
    
    
    func fetchFriends(){
        if let myID = FIRAuth.auth()?.currentUser?.uid{
            let friendRef = FIRDatabase.database().reference().child("friendship").child(myID)
            friendRef.observe(.childAdded, with: { (snapshot) in
                if snapshot.value as? Int == 2 {
                    let key = snapshot.key
                    let user = User()
                    let userRef = FIRDatabase.database().reference().child("users").child(key)
                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            user.setValuesForKeys(dictionary)
                            user.id = key
                            self.friends.append(user)}
                        
                        DispatchQueue.global().async {
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }  }, withCancel: nil)
        }
    }
    
    func handleCancel(){
        /* let usersController = usersTableViewController()
         let navController = UINavigationController(rootViewController: usersController)
         present(navController, animated:true, completion:nil)*/
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterFriends.count
        }else{
            return friends.count
        }
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        let user : User
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterFriends[indexPath.row]
        }else {
            user = friends[indexPath.row]
        }
        
        cell.textLabel?.text = user.name
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user: User?
            
            if self.searchController.searchBar.text != ""{
                
                user = self.filterFriends[indexPath.row]
                
                self.handleCancel()
            }else{
                user = self.friends[indexPath.row]
            }
            
            self.chatListController?.showChatLogControllerForUser(uid: (user?.id!)!)
            print("Show chat log controller with uid", user?.name)
        }
    }
}

extension NewChatTableViewController : UISearchResultsUpdating{
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
