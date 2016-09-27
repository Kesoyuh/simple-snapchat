//
//  NewMessageTableViewController.swift
//  simple-snapchat
//
//  Created by Helen on 27/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class ChatLogController: UICollectionViewController {

    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Chat Log Controller"
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
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor(red: 102, green: 178, blue: 255), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
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
    
    func handleSend(){
       print(inputTextField.text)
    }

}
