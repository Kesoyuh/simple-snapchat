//
//  NewChatTableViewController.swift
//  simple-snapchat
//
//  Created by Helen on 26/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Parse

// Add a new chat by choosing a friend

class NewChatTableViewController: UITableViewController {
    
    let cellID = "newChatCellId"
    
     //************************************************************************TODO:Currently show all users, latter show firnds
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target:self, action: #selector(handleCancel))
        navigationItem.title = "Chat with..."
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor(red: 102, green: 178, blue: 255)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 102, green: 178, blue: 255)]
        navigationController?.navigationBar.isHidden = false
        
        checkIfUserIsLoggedIn()
        fetchUser()

  }
    
    //************************************************************************TODO: Change to fetch friend latter
    func fetchUser(){
        var query:PFQuery = PFUser.query()!
        // Create a new PFQuery
                // Call findObjectInBackground
        query.findObjectsInBackground{(objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                
                print("Successfully retrieved \(objects!.count) users.")

                self.users = [User]()

                if let objects = objects {
                    
                    for userObject in objects {
                        
                        let user = User()
                        user.username = userObject["username"] as! String?
                        user.email = userObject["email"] as! String?
                        user.id = userObject.objectId
                        print(user.username, user.email,user.id)
                        self.users.append(user)
                        //---------------------Swift 3 dispatch---------------//
                        DispatchQueue.global().async {
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            } else {
                
            }
        }
        
    }
    
    //TEST: for get user info 以后可以借鉴获取friend信息
    func checkIfUserIsLoggedIn() {
        let currentUser = PFUser.current()
        
        if currentUser != nil {
            // User is logged in, change the title with username
            let title = currentUser?.username?.appending(" Friend List")

            self.navigationItem.title = title
        } else {
            // User is not logged in
            let loginRegisterController = LoginRegisterController()
            present(loginRegisterController, animated: true, completion: nil)
        }
    }

    
    func handleCancel(){
       /* let usersController = usersTableViewController()
        let navController = UINavigationController(rootViewController: usersController)
        present(navController, animated:true, completion:nil)*/
        
        dismiss(animated: true, completion: nil)

    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.username
        return cell
    }
    
    var chatListController: ChatListTableViewController?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.chatListController?.showChatLogControllerForUser(user: user)
        }
    }
}
