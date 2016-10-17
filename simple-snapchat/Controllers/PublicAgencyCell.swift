//
//  AgencyCell.swift
//  snapchat
//
//  Created by Jeffrey on 28/08/2016.
//  Copyright © 2016 Boqin Hu. All rights reserved.
//

import UIKit

class PublicAgencyCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var storiesViewController: StoriesViewController?
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
        
        agenciesCollectionView.delegate = self
        agenciesCollectionView.dataSource = self
        
        agenciesCollectionView.register(AgencyCell.self, forCellWithReuseIdentifier: cellId)
        
        agenciesCollectionView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        agenciesCollectionView.heightAnchor.constraint(equalTo: heightAnchor, constant: 0).isActive = true
        
    }
    
    func handleDisplayPublicStories(tapGesture: UITapGestureRecognizer) {
        let layout = UICollectionViewFlowLayout()
        let publicStoryController = PublicStoryController(collectionViewLayout: layout)
        let agencyCell = tapGesture.view as! AgencyCell
        publicStoryController.agency = agencyCell.agency
        storiesViewController!.present(publicStoryController, animated: false, completion: nil)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AgencyCell
        switch indexPath.item {
        case 0:
            cell.agency = "buzzfeed"
            cell.imageView.image = UIImage(named: "buzzfeed")
        case 1:
            cell.agency = "dailymail"
            cell.imageView.image = UIImage(named: "dailymail")
        case 2:
            cell.agency = "comedycentral"
            cell.imageView.image = UIImage(named: "comedycentral")
        case 3:
            cell.agency = "espn"
            cell.imageView.image = UIImage(named: "espn")
        case 4:
            cell.agency = "cnn"
            cell.imageView.image = UIImage(named: "cnn")
        default:
            cell.agency = ""
            cell.imageView.image = nil
        }
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDisplayPublicStories)))
        return cell
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
    
    var agency = String()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    
    
    func setupViews() {
        addSubview(imageView)
        isUserInteractionEnabled = true
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
}
