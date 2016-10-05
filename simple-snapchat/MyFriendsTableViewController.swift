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
    
   
    var friends = [User]()
    var filterFriends = [User]()
   // let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }

   
    @IBAction func back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    
   
    func fetchFriends(){
        
        self.friends = [User]()
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                self.friends.append(user)
                DispatchQueue.global().async {
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }
            
            
            }, withCancel: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyFriends")

        // Configure the cell...
        let user : User
        user = friends[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        return cell
    }
    

    

    
    

}
