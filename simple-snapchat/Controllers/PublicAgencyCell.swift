//
//  AgencyCell.swift
//  snapchat
//
//  Created by Jeffrey on 28/08/2016.
//  Copyright © 2016 Boqin Hu. All rights reserved.
//

import UIKit

class PublicAgencyCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "agencyCell"
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let agenciesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let separatorView: UIView = {
        let sv = UIView()
        sv.backgroundColor = UIColor.black
        sv.alpha = 0.4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    func setupViews() {
        backgroundColor = UIColor.clear
        
        addSubview(agenciesCollectionView)
//        addSubview(separatorView)
        
        agenciesCollectionView.delegate = self
        agenciesCollectionView.dataSource = self
        
        agenciesCollectionView.register(AgencyCell.self, forCellWithReuseIdentifier: cellId)
        
        agenciesCollectionView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        agenciesCollectionView.heightAnchor.constraint(equalTo: heightAnchor, constant: 0).isActive = true
        
//        separatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        separatorView.topAnchor.constraint(equalTo: agenciesCollectionView.bottomAnchor).isActive = true
//        separatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 4, 0, 4)
    }

}

class AgencyCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "buzzfeed")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    
    func setupViews() {
        addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
    }
}
