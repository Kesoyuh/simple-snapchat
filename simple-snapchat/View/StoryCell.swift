//
//  StoryCell.swift
//  simple-snapchat
//
//  Created by Jeffrey on 3/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
class StoryCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var userID: String?
    
    let nameLable: UILabel = {
        let nl = UILabel()
        nl.font = UIFont.systemFont(ofSize: 20)
        return nl
    }()
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = nil
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 30
        iv.layer.masksToBounds = true
        return iv
    }()
    
    func setupViews() {
        backgroundColor = UIColor.white
        addSubview(imageView)
        addSubview(nameLable)
        
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        nameLable.frame = CGRect(x: 84, y: imageView.frame.midY, width: frame.width, height: 80)
    }
}
