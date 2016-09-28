//
//  NewMessageTableViewController.swift
//  simple-snapchat
//
//  Created by Helen on 27/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Parse

class ChatLogController: UICollectionViewController, UITextFieldDelegate {

    var user: User?{
        didSet{
            navigationItem.title = user?.username
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let sendButton:UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor(red: 102, green: 178, blue: 255), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        setUpInputComponents()
    }
    
    
    func setUpInputComponents(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
         //-----------------------------------Add bottom container-----------------------------
        view.addSubview(containerView)
        
        //x,y,w,h constraint anchors for input container
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //-----------------------------------Add send button-----------------------------------
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h constraint anchors for send button
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
         //-----------------------------------Add input textfield--------------------------------
        containerView.addSubview(inputTextField)
        //x,y,w,h constraint anchors for input textfield
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        //-------------------Add a line separating input container and messages view --------------
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red:220, green: 220, blue: 255)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h constraint anchors for separatorLine
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

}
    // Send button tapped function
    func handleSend(){
        // Call the end editing method and disable the send button & input field
        self.inputTextField.endEditing(true)
        self.inputTextField.isEnabled = false
        self.sendButton.isEnabled = false
        
        // Create a PFObject
        // Create a PFObject
        let newMessageObject: PFObject = PFObject(className: "Messages")
        
        //Set the Text key to the text of the messageTextField
        newMessageObject["Type"] = "Text"
        newMessageObject["Content"] = self.inputTextField.text
        newMessageObject["Users"] = chatWithPFUser()
        
        //Save the PFObject
        newMessageObject.saveInBackground {  (success: Bool, error: Error?) -> Void in
            if (success) {
                // The object has been saved.
                print("Message saved sucessfully")
                
                // Retrieve the latest messages and reload the table
                //self.retrieveMessages()
                
            } else {
                // There was a problem, check error.description
                NSLog(error as! String)
            }
            DispatchQueue.global().async {
                
                DispatchQueue.main.async {
                    self.inputTextField.isEnabled = true
                    self.sendButton.isEnabled = true
                    self.inputTextField.text = ""
                }
            }

            
        }
        //TODO: Load IMG....
        
    }
    
    
    
    func chatWithPFUser() -> [PFUser]{
        var users:[PFUser] = []
        users.append(PFUser.current()!)
        
        var query = PFUser.query()!
        if user?.id != nil {
            do {
                let pfUser = try query.getObjectWithId((user?.id)!) as! PFUser
                 users.append(pfUser)
            }
            catch{
                print("Query with user id failed.")
            }
        }
         return users
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }


}







class Messages:NSObject{
    var type: String!
    var content: AnyObject!
    var date: Date!
    var users: [User] = []
    
    func addNewMessage(newType: String, newContent: AnyObject, newDate: Date, newUsers: [User]){
        type = newType
        content = newContent
        date = newDate
        users = newUsers
    
    }
}
