//
//  MenuBar.swift
//  simple-snapchat
//
//  Created by Jeffrey on 3/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let cellId = "cellId"
    var memoriesViewController: MemoriesController?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        collectionView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom)

    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        if indexPath.row == 0 {
            cell.lableView.text = "SNAPS"
        } else {
            cell.lableView.text = "CAMERA ROLL"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/2, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        memoriesViewController?.scrollToMenuIndex(menuIndex: indexPath.item)
    }
    
    
}

class MenuCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override var isSelected: Bool {
        didSet {
            lableView.textColor = isSelected ? UIColor(r: 255, g: 20, b: 147) : UIColor(r: 160, g: 160, b: 160)
        }
    }
    
    let lableView: UILabel = {
        let lv = UILabel()
        lv.textAlignment = .center
        lv.textColor = UIColor(r: 160, g: 160, b: 160)
        lv.backgroundColor = .white
        lv.font = UIFont.systemFont(ofSize: 14)
        lv.translatesAutoresizingMaskIntoConstraints = false
        return lv
    }()
    
    func setupView() {
        addSubview(lableView)
        lableView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        lableView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        lableView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        lableView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
