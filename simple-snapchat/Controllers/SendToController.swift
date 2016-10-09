//
//  SendToController.swift
//  simple-snapchat
//
//  Created by Jeffrey on 9/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase


class SendToController: UITableViewController {
    let cellId = "cellId"
    var friendList = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SendToCell.self, forCellReuseIdentifier: cellId)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Send To...", style: .plain, target: self, action: #selector(handleCancle))
        
        fetchFriends()
    }
    
    func fetchFriends() {
        if let currentUserId = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("friendship").child(currentUserId).observe(.childAdded, with: { (snapshot) in
                if snapshot.value as? Int == 2 {
                    let friendId = snapshot.key
                    FIRDatabase.database().reference().child("users").child(friendId).observeSingleEvent(of: .value, with: { (friendSnapshot) in
                        if let dictionary = friendSnapshot.value as? [String: String] {
                            let user = User()
                            user.setValuesForKeys(dictionary)
                            user.id = friendId
                            self.friendList.append(user)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        }, withCancel: nil)
                }
                
                }, withCancel: nil)
        
        }
        
    }
    
    func handleCancle() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SendToCell
        cell.user = friendList[indexPath.item]
        cell.textLabel?.text = cell.user.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SendToCell
        cell.textLabel?.text = "adfad"
    }

}

class SendToCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var user = User()
}
