//
//  AddUsernameTableViewController.swift
//  simple-snapchat
//
//  Created by JIANGXUE on 5/10/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase
class AddUsernameTableViewController: UITableViewController {

    
    let cellID = "AddUserNameCell"
    var allusers = [User]()
    var filterUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellID)

        fetchUser()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
       
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filterUsers = allusers.filter({ (allusers) -> Bool in
            return (allusers.name?.localizedLowercase.contains(searchText.localizedLowercase))!
        })
        filterUsers.forEach { (user) in
            print(user.name!)
        }
        tableView.reloadData()
    }

    func fetchUser(){
        
        self.allusers = [User]()
        if let myID = FIRAuth.auth()?.currentUser?.uid{
            FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    user.id = snapshot.key
                    
                    if user.id != myID {
                         let friendRef = FIRDatabase.database().reference().child("friendship").child(myID)
                        friendRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let dictionary = snapshot.value as? [String : AnyObject]{
                                //Check if the user has already been my friend
                                var canAdd : Bool
                                canAdd = true
                                
                                for(key,value) in dictionary {
                                    if value as? Int == 2  && user.id == key{
                                        canAdd = false
                                    }
                                }
                                if canAdd && !self.allusers.contains(user) {
                                    self.allusers.append(user)
                                }
                            }else{
                                
                            // Have no friend ship yet, can add all users.
                                if !self.allusers.contains(user){
                                    self.allusers.append(user)
                                }
                            }
                            
                            DispatchQueue.global().async {
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }

                         })
                    }
                }
            })
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.searchBar.text != "" {
            return filterUsers.count
        }else{
            return allusers.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        let user : User
        if searchController.searchBar.text != "" {
            user = filterUsers[indexPath.row]
 
        }else {
            user = allusers[indexPath.row]
        }
        cell.textLabel!.text = user.name!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user: User
    
                if self.searchController.searchBar.text != "" {
                    user = self.filterUsers[indexPath.row]
                    self.dismiss(animated: true, completion: nil)
                }else {
                    user = self.allusers[indexPath.row]
                }
            
            let fromID = (FIRAuth.auth()?.currentUser?.uid)!
            let toID = user.id!
            
            // "0": wait for partner's acceptance
            // "1": receive a new request, the user can choose to accept or reject
            // "2": establish the friendship
            
            let senderFriendRef = FIRDatabase.database().reference().child("friendship").child(fromID)
            senderFriendRef.updateChildValues([toID : 0])
            let receiverFriendRef = FIRDatabase.database().reference().child("friendship").child(toID)
            receiverFriendRef.updateChildValues([fromID: 1])
            
            let alertView = UIAlertView();
            alertView.addButton(withTitle: "Done");
            alertView.title = "Request is sent!";
            let name = user.name!
            alertView.message = "You sent a request to \(name)! Wait for the confirmation...";
            alertView.show();

            
            
        }
    }
}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   


extension AddUsernameTableViewController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
