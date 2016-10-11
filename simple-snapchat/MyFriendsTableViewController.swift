//
//  MyFriendsTableViewController.swift
//  simple-snapchat
//
//  Created by JIANGXUE on 4/10/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase
class MyFriendsTableViewController: UITableViewController {
    
   let cellID = "MyFriendCell"
   var friends = [User]()
   let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellID)
        
        fetchFriends()
      
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }

   
    @IBAction func back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)

        // Configure the cell...
        let user : User
        user = friends[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let chatPartnerId = friends[indexPath.row].id{

            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            navigationController?.pushViewController(chatLogController, animated: true)
            chatLogController.partnerId = chatPartnerId
        }
    


    }

}

