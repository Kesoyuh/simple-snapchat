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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target:self, action: #selector(handleCancel))
        navigationItem.title = "Chat with..."
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor(red: 102, green: 178, blue: 255)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 102, green: 178, blue: 255)]
        navigationController?.navigationBar.isHidden = false
        
        checkIfUserIsLoggedIn()

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
       /* let chatListController = ChatListTableViewController()
        let navController = UINavigationController(rootViewController: chatListController)
        present(navController, animated:true, completion:nil)*/
        
        dismiss(animated: true, completion: nil)

    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        cell.textLabel?.text = "hisahdaiosdhaiosd"
        return cell
    }
}
