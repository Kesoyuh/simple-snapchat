//
//  AddedMeTableViewController.swift
//  simple-snapchat
//
//  Created by JIANGXUE on 4/10/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase

class AddedMeTableViewController: UITableViewController {

    let cellID = "cellID"
    var friendRequest = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AddedMeCell.self, forCellReuseIdentifier: cellID)
        self.tableView.delegate = self
        self.tableView.dataSource = self

        fetchRequest()
    }

    func fetchRequest(){
   
        if let myID = FIRAuth.auth()?.currentUser?.uid{
            let ref = FIRDatabase.database().reference().child("friendship").child(myID)
            ref.observe(.childAdded, with: { (snapshot) in
                if (snapshot.value as! Int == 1) {
                    let requestID = snapshot.key
                    let userRef = FIRDatabase.database().reference().child("users").child(requestID)
                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String : AnyObject]{
                            let user = User()
                            user.setValuesForKeys(dictionary)
                            user.id = requestID
                            self.friendRequest.append(user)
                            DispatchQueue.global().async {
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    print("We reload the table")
                                }
                            }
                        }
                    },withCancel: nil)}
                }, withCancel: nil)
        }
       
    }
    
    func addFriend(sender: UIButton){
        let targetUser = friendRequest[sender.tag]
        if let requesterID = targetUser.id {
            let accepterID = FIRAuth.auth()?.currentUser?.uid
            
            let reqRef = FIRDatabase.database().reference().child("friendship").child(requesterID)
            reqRef.updateChildValues([accepterID! : 2])
            
            let accRef = FIRDatabase.database().reference().child("friendship").child(accepterID!)
            accRef.updateChildValues([requesterID : 2])
            let name = targetUser.name!
            
            let alert  = UIAlertController(title: "New Friend Added", message: "You can chat with \(name) now!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            friendRequest.remove(at: sender.tag)
            self.tableView.reloadData()
            
            

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
        print(friendRequest.count)
        return friendRequest.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! AddedMeCell
        
        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(addFriend) , for: .touchUpInside)
        cell.textLabel?.text = friendRequest[indexPath.row].name

        return cell
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

}
