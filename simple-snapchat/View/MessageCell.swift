//
//  MessageCell.swift
//  simple-snapchat
//
//  Created by Helen on 30/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    var chatLogController : ChatLogController?
    var imageType : Int?
    
    var lat : String?
    var lng: String?
    var timer: Int?
    var openTimes: Int?
    
    var messageID: String?
    var index : Int?
    var imageURL : String?
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "lalalal"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        // The default background color is white, need to be clear or the bubble view won't be seen.
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.isEditable = false
        return tv
    }()
    
    lazy var messageImageView: UIImageView =  {
        let imageView = UIImageView()
 
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        return imageView
    }()
    
    func handleTap(tapGesture: UITapGestureRecognizer){
        // Type 0 : normal
        // Type 1 : location
        // Type 2 : with view constraint
        
        if imageType == 0 {
            handleZoomTap(tapGesture: tapGesture)
        }else if imageType == 1 {
            handleShareLocation(tapGesture: tapGesture)
        }else if imageType == 2 {
            handleTimer(tapGesture: tapGesture)
            
        }
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer){
        // *Do not put lots of custom logic in View
        // *Delegate this function to ChatLogContoller
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
        }

    }
    
    func handleShareLocation(tapGesture: UITapGestureRecognizer){
        self.chatLogController?.handleShareLocation(lat:lat!, lng: lng!)
    }
    
    func handleTimer(tapGesture: UITapGestureRecognizer){
        openTimes! += 1
        self.chatLogController?.handleTimer(time: timer!, imageURL: imageURL!, openTimes: openTimes!, messageID: messageID!, index: index!)
        if openTimes == 1 {
            messageImageView.image = UIImage(named:"can_see_one_more_time")
        }
    }
    
    
    static let blueColor = UIColor(red: 0, green: 137, blue: 249)
    static let grayColor = UIColor(red: 240, green: 240, blue: 240)
    
    let bubbleView: UIView = {
        let view = UIView()
        //view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        bubbleView.addSubview(messageImageView)
        
        // Contraints for bubble view
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        //bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        //bubbleViewLeftAnchor?.isActive = true
        
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
        
        // Constraints for message image view
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true

        self.backgroundColor = UIColor.white
        
        self.bubbleView.isUserInteractionEnabled = true

        
    }

    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}
