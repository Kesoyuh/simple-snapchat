//
//  StoriesViewController.swift
//  snapchat
//
//  Created by Jeffrey on 28/08/2016.
//  Copyright © 2016 Boqin Hu. All rights reserved.
//

import UIKit
import Firebase


class StoriesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "Cell"
    fileprivate let storyCellId = "StoryCell"
    
    // stories for myself and my friends
    var myself: User?
    var friends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(PublicAgencyCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(StoryCell.self, forCellWithReuseIdentifier: storyCellId)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 155/255, green: 88/255, blue: 159/255, alpha: 1)]
        navigationController?.navigationBar.barTintColor = UIColor.white
        observeStories()
    }
    
    func observeStories() {
        FIRDatabase.database().reference().child("stories").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.name = dictionary["username"] as? String
                user.id = dictionary["userID"] as? String
                
                // get story contents under each user
                let enumerator = snapshot.childSnapshot(forPath: "contents").children
                while let storySnapshot = enumerator.nextObject() as? FIRDataSnapshot {
                    if let storyDictionary = storySnapshot.value as? [String: AnyObject] {
                        let story = Story()
                        story.imageURL = storyDictionary["imageURL"] as? String
                        story.timer = storyDictionary["timer"] as? Int
                        user.stories.append(story)
                    }
                }
                if user.id == FIRAuth.auth()?.currentUser?.uid {
                    self.myself = user
                } else {
                    self.friends.append(user)
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                    }
            }, withCancel: nil)
        
        FIRDatabase.database().reference().child("stories").observe(.childChanged, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let userStory = User()
                userStory.name = dictionary["username"] as? String
                userStory.id = dictionary["userID"] as? String
            }
            }, withCancel: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if myself == nil {
            if indexPath.row == 0 {
                // public stories
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PublicAgencyCell
                return cell
            } else {
                // friends' story cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyCellId, for: indexPath) as! StoryCell
                let user = friends[indexPath.row - 1]
                
                cell.nameLable.text = user.name
                
                if let imageURL = user.stories.first?.imageURL{
                    fetchImageAndDisplay(withURL: imageURL, inCell: cell)
                }
                return cell
            }

        } else {
            // The user himself has stories
            if indexPath.row == 0 {
                // my story cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyCellId, for: indexPath) as! StoryCell
                cell.nameLable.text = "My Story"
                
                if let imageURL = myself?.stories.first?.imageURL{
                    fetchImageAndDisplay(withURL: imageURL, inCell: cell)
                }
                return cell
            } else if indexPath.row == 1 {
                //public stories
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PublicAgencyCell
                return cell
            } else {
                // friends' story cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyCellId, for: indexPath) as! StoryCell
                let user = friends[indexPath.row - 1]
                
                cell.nameLable.text = user.name
                
                if let imageURL = user.stories.first?.imageURL{
                    fetchImageAndDisplay(withURL: imageURL, inCell: cell)
                }
                return cell
            }
        }
        
    }
    
    func fetchImageAndDisplay(withURL imageURL: String, inCell cell: StoryCell) {
        let url = URL(string: imageURL)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: data!)
            }
        }).resume()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myself == nil ? friends.count + 1 : friends.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (myself != nil && indexPath.row == 1) || (myself == nil && indexPath.row == 0) {
            return CGSize(width: view.frame.width, height: 100)
        } else {
            return CGSize(width: view.frame.width, height: 80)
        }
    
    }
}





