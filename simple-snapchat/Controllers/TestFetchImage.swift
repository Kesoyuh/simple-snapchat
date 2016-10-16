//
//  TestFetchImage.swift
//  simple-snapchat
//
//  Created by Boqin Hu on 10/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Testcontroller : UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    let reuseIndentifier = "emoji"
    var items = ["1","2","3","4","5","6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIndentifier, for: indexPath as IndexPath) as!EmojiCell
        cell.emoji.text = self.items[indexPath.item]
        cell.backgroundColor = UIColor.cyan
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You have selected cell #\(indexPath.item)")
    }

    
    
}
