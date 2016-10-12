//
//  SendToController.swift
//  simple-snapchat
//
//  Created by Jeffrey on 9/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Firebase


class SendToController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cellId = "cellId"
    
    var photos = [SendingPhoto]()
    var friendList = [User]()
    var sendList = [String]()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Send To...", style: .plain, target: self, action: #selector(handleCancle))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 55, green: 179, blue: 229)
        navigationController?.navigationBar.isTranslucent = false
        setupTableView()
        fetchFriends()
        
    }
    
    let bottomSelectView: UIView = {
        let bs = UIView()
        bs.backgroundColor = UIColor(colorLiteralRed: 55/255, green: 179/255, blue: 229/255, alpha: 1)
        bs.translatesAutoresizingMaskIntoConstraints = false
        return bs
    }()
    
    lazy var sendButtonView: UIImageView = {
        let sb = UIImageView()
        sb.image = UIImage(named: "send-button")?.withRenderingMode(.alwaysTemplate)
        sb.tintColor = UIColor.white
        sb.isUserInteractionEnabled = true
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSend)))
        return sb
    }()
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.register(SendToCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    func setSendBar() {
        // Set bottom select view
        view.addSubview(bottomSelectView)
        bottomSelectView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomSelectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomSelectView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        bottomSelectView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Set send button
        bottomSelectView.addSubview(sendButtonView)
        sendButtonView.centerYAnchor.constraint(equalTo: bottomSelectView.centerYAnchor).isActive = true
        sendButtonView.centerXAnchor.constraint(equalTo: bottomSelectView.rightAnchor, constant: -30).isActive = true
        sendButtonView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        sendButtonView.widthAnchor.constraint(equalToConstant: 35).isActive = true
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
    
    func handleSend() {
        for i in 0..<sendList.count {
            if sendList[i] == "My Story" {
                sendToMyStory()
            } else {
                sendToFriend(uid: sendList[i])
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func sendToMyStory() {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        var username = String()
        
        // Create story reference
        let storiesRef = FIRDatabase.database().reference().child("stories")
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                username = dictionary["name"] as! String
            }
        })
        
        for i in 0..<photos.count {
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("stories").child(imageName)
            let image = photos[i].image!
            let timer = photos[i].timer!
            let uploadData = UIImagePNGRepresentation(image)
            
            storageRef.put(uploadData!, metadata: nil, completion: { (metaData, error) in
                
                if error != nil {
                    print(error)
                    return
                } else {
                    
                    // update database after successfully uploaded
                    let storyRef = storiesRef.childByAutoId()
                    if let imageURL = metaData?.downloadURL()?.absoluteString {
                        storyRef.updateChildValues(["userID": uid!, "username": username, "imageURL": imageURL, "timer": timer], withCompletionBlock: { (error, ref) in
                            if error != nil {
                                print(error)
                                return
                            }
                        })
                    }
                }
            })
        }
    }
    
    func sendToFriend(uid: String) {
        print("sended to ", uid)
        //********************To be implemented by Hailun*************************
    }
    
    func handleCancle() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SendToCell
        if indexPath.section == 0 {
            cell.isStoryCell = true
            cell.textLabel?.text = "My Story"
        } else {
            cell.isStoryCell = false
            cell.user = friendList[indexPath.item]
            cell.textLabel?.text = cell.user.name
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : friendList.count
    }
    
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! SendToCell
        
        if sendList.count == 0 {
            setSendBar()
        }
        
        if indexPath.section == 0 {
            sendList.append("My Story")
        } else {
            sendList.append(cell.user.id!)
        }
        
        print(sendList)
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SendToCell
        
        if indexPath.section == 0 {
            sendList = sendList.filter({ $0 != "My Story" })
        } else {
            sendList = sendList.filter({ $0 != cell.user.id })
        }
        
        if sendList.count == 0 {
            sendButtonView.removeFromSuperview()
            bottomSelectView.removeFromSuperview()
        }
        print(sendList)

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "" : "FRIENDS"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor(red: 55, green: 179, blue: 229)
            headerView.tintColor = .white
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 14)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

class SendToCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .blue
        tintColor = UIColor(red: 55, green: 179, blue: 229)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var isStoryCell = false
    var user = User()
}
