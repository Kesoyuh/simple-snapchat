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
    
    var currentUid = String()
    var currentUsername = String()
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
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.currentUid = uid
            // Fetch current user's name
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.currentUsername = dictionary["name"] as! String
                }
            })
            
            for i in 0..<photos.count {
                let imageName = NSUUID().uuidString
                let sharedRef = FIRStorage.storage().reference().child("sharedImages").child(imageName)
                let image = photos[i].image!
                let uploadData = UIImagePNGRepresentation(image)
                
                sharedRef.put(uploadData!, metadata: nil, completion: { (metaData, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    } else {
                        if let imageURL = metaData?.downloadURL()?.absoluteString {
                            // Store image's url
                            self.photos[i].imageURL = imageURL
                            
                            for j in 0..<self.sendList.count {
                                if self.sendList[j] == "My Story" {
                                    self.sendToMyStory(photoIndex: i)
                                } else {
                                    self.sendToFriend(photoIndex: i, uid: self.sendList[j])
                                }
                            }
                        }
                        
                    }
                })
            }
            
            dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    func sendToMyStory(photoIndex: Int) {
        
        // Create story reference
        let storiesRef = FIRDatabase.database().reference().child("stories")
        
        let timer = photos[photoIndex].timer!
        let imageURL = photos[photoIndex].imageURL!
        
        let storyRef = storiesRef.childByAutoId()
        storyRef.updateChildValues(["userID": self.currentUid, "username": self.currentUsername, "imageURL": imageURL, "timer": timer], withCompletionBlock: {(error, ref) in
            if error != nil {
                print(error)
                return
            }
        })
    }
    
    func sendToFriend(photoIndex: Int, uid: String) {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromID = FIRAuth.auth()!.currentUser!.uid
        let toID = uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = [ "timer": photos[photoIndex].timer!, "toID": toID, "fromID": fromID, "timestamp": timestamp, "imageUrl": photos[photoIndex].imageURL!] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            //Update user-messages for both sender and receiver
            let senderMsgRef = FIRDatabase.database().reference().child("user-messages").child(fromID).child(toID)
            senderMsgRef.updateChildValues([childRef.key : 1])
            let receiverMsgRef = FIRDatabase.database().reference().child("user-messages").child(toID).child(fromID)
            receiverMsgRef.updateChildValues([childRef.key : 1])
        }

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
