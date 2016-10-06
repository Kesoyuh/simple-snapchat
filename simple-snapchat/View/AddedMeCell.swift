//
//  AddedMeCell.swift
//  simple-snapchat
//
//  Created by Helen on 6/10/2016.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

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

class AddedMeCell: UITableViewCell{
    
    let addButton: UIButton = {
        var id : String?
        let button = UIButton()
        button.setTitle("+Add", for: .normal)
        button.setTitleColor(UIColor.brown, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect( x: 64, y: textLabel!.frame.origin.y + 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        textLabel?.textColor = UIColor.brown
    

        
    }
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(addButton)
        
        addButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        addButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        addButton.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


