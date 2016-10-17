//
//  ChatCell.swift
//  simple-snapchat
//
//  Created by Helen on 29/09/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//
import Foundation
import UIKit
import Firebase

class ChatCell: UITableViewCell{
    
    var message: Message?{
        didSet{
            
            // set name and image
            setupNameAndImgae()
            
            //TODO: check message type, show message if the type is text, others show "New message"
            // set message label
            self.detailTextLabel?.text = message?.text
            
            // set time label
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds )
                
                //TODO: Change the info of date displayed latter( ** ago, or dd/mm)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)

            }
            


            
        }
    }
    
    private func setupNameAndImgae(){
        let chatParrtnerID = message?.chatPartnerId()

        if let id = chatParrtnerID{
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text =  dictionary["name"] as? String
                    
                }
                
                }, withCancel: nil)
        }
    }
    
    
    let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
        }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "HH:MM:SS"
        label.font  = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect( x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: (detailTextLabel?.frame.width)!, height: detailTextLabel!.frame.height)
        
        
    }
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(leftImageView)
        addSubview(timeLabel)
        leftImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        leftImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        leftImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        leftImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant:18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    
}
