//
//  MessageCell.swift
//  simple-snapchat
//
//  Created by Helen on 30/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "lalalal"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        // The default background color is white, need to be clear or the bubble view won't be seen.
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white

        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 137, blue: 249)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        
        // Contraints for bubble view
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        
        // Contraints for text view
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        self.backgroundColor = UIColor.white
        
    }

    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}
