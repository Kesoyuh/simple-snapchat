//
//  PublicStoryController.swift
//  simple-snapchat
//
//  Created by Jeffrey on 16/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class PublicStoryController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let storyCellId = "StoryCellId"
    
    var publicStories = [PublicStory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPublicStoryView()
        fetchFeeds()
    }
    
    func fetchFeeds() {
        let urlString = "https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=10&q=https://www.buzzfeed.com/andyneuenschwander.xml"
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, reponse, error) in
            if error != nil {
                print(error)
                return
            }
            // parse json
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
                let responseData = parsedData?["responseData"] as? [String: AnyObject]
                let feedDictionary = responseData?["feed"] as? [String: AnyObject]
                let entryDictionaries = feedDictionary?["entries"] as? [[String: AnyObject]]
                for entryDictionary in entryDictionaries! {
                    let publicStory = PublicStory()
                    publicStory.author = entryDictionary["author"] as! String
                    publicStory.content = entryDictionary["content"] as! String
                    publicStory.title = entryDictionary["title"] as! String
                    self.publicStories.append(publicStory)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            } catch  {
                
            }
            }.resume()
    }
    
    func setupPublicStoryView() {
        collectionView?.backgroundColor = .white
        collectionView?.register(PublicStoryCell.self, forCellWithReuseIdentifier: storyCellId)
        collectionView?.isPagingEnabled = true
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publicStories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyCellId, for: indexPath) as! PublicStoryCell
        cell.publicStory = publicStories[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
//    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let index = targetContentOffset.pointee.x / view.frame.width
//        let indexPath = IndexPath(item: Int(index), section: 0)
//    }

}
