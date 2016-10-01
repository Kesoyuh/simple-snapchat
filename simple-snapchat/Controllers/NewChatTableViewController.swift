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
    var firends = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target:self, action: #selector(handleCancel))
        navigationItem.title = "Chat with..."
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor(red: 102, green: 178, blue: 255)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 102, green: 178, blue: 255)]
        navigationController?.navigationBar.isHidden = false
        
        fetchFriends()

  }
    
    //************************************************************************TODO: Change to fetch friend latter
    func fetchFriends(){
        
        self.firends = [User]()
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                self.firends.append(user)
                DispatchQueue.global().async {
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }

            }
            
            
            }, withCancel: nil)
    }

    func handleCancel(){
       /* let usersController = usersTableViewController()
        let navController = UINavigationController(rootViewController: usersController)
        present(navController, animated:true, completion:nil)*/
        
        dismiss(animated: true, completion: nil)

    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firends.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        let user = firends[indexPath.row]
        
        cell.textLabel?.text = user.name
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.firends[indexPath.row]
            self.chatListController?.showChatLogControllerForUser(uid: user.id!)
        }
    }
}
