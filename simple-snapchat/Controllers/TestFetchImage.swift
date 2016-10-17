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
    var emojilist:[[String]] = []
    var sectionTitle: [String] = []
    
    @IBOutlet weak var emojiview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initEmoji()
    }

    override func viewDidAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        
        nav?.barStyle = UIBarStyle.blackTranslucent
        nav?.alpha = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sectionTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIndentifier, for: indexPath as IndexPath) as!EmojiCell
        //cell.emoji.text = emojilist[indexPath.row][1]
        cell.emoji.text = self.sectionTitle[indexPath.item]
        cell.backgroundColor = UIColor.cyan
        return cell
    }
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return self.emojilist.count
//    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You have selected cell #\(indexPath.item)")
    }
    
    func back_to_image(){
        dismiss(animated: false, completion:nil )
    }
    
    func initEmoji(){
        for c in 0x1F601...0x1F64F{
            self.sectionTitle.append(String(describing: UnicodeScalar(c)!))
        }
    }

    
    
}
