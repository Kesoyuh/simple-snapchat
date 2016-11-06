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
    
    var uid: String?
    // stories for myself and my friends
    var myself: User?
    var friends = [String: User]()
    var friendIDAsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(PublicAgencyCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(StoryCell.self, forCellWithReuseIdentifier: storyCellId)
        
        let titleLable = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 40, height: view.frame.height))
        titleLable.text = "Stories"
        titleLable.font = UIFont.systemFont(ofSize: 20)
        titleLable.textColor = UIColor(r: 155, g: 88, b: 159)
        navigationItem.titleView = titleLable

        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if uid != FIRAuth.auth()?.currentUser?.uid{
            myself = nil
            friends.removeAll()
            friendIDAsArray.removeAll()
            uid = FIRAuth.auth()?.currentUser?.uid
            observeStories()
        }
        
    }
    
    
    
    func observeStories() {
        FIRDatabase.database().reference().child("stories").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let userID = dictionary["userID"] as? String
                let username = dictionary["username"] as? String
                let imageURL = dictionary["imageURL"] as? String
                let timer = dictionary["timer"] as? Int
                
                if self.myself != nil && self.myself?.id == userID {
                    // the user is me and my story already exists
                    let story = Story()
                    story.imageURL = imageURL
                    story.timer = timer
                    self.myself?.stories.append(story)
                    
                    // fetch image
                    let storyIndex = self.myself!.stories.count - 1
                    let url = URL(string: imageURL!)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                self.myself?.stories[storyIndex].image = UIImage(data: data!)
                            }
                        }
                    }).resume()
                }
                else if self.myself == nil && userID == FIRAuth.auth()?.currentUser?.uid {
                    // the user is me but I dont have my story yet
                    self.myself = User()
                    self.myself?.id = userID
                    self.myself?.name = username
                    let story = Story()
                    story.imageURL = imageURL
                    story.timer = timer
                    self.myself?.stories.append(story)
                    
                    // fetch image
                    let storyIndex = self.myself!.stories.count - 1
                    let url = URL(string: imageURL!)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                self.myself?.stories[storyIndex].image = UIImage(data: data!)
                            }
                        }
                    }).resume()
                }
                else if let dictionaryIndex = self.friends.index(forKey: userID!) {
                    // the user is my friend and his story already exists
                    let user = self.friends[dictionaryIndex].value
                    let story = Story()
                    story.imageURL = imageURL
                    story.timer = timer
                    user.stories.append(story)
                    self.friends[userID!] = user
                    
                    // fetch image
                    let storyIndex = user.stories.count - 1
                    let url = URL(string: imageURL!)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                self.friends[userID!]?.stories[storyIndex].image = UIImage(data: data!)
                            }
                        }
                    }).resume()
                }
                else {
                    // add a new friend story
                    let user = User()
                    user.id = userID
                    user.name = username
                    let story = Story()
                    story.imageURL = imageURL
                    story.timer = timer
                    user.stories.append(story)
                    self.friends[userID!] = user
                    self.friendIDAsArray.append(userID!)
                    
                    // fetch image
                    let storyIndex = user.stories.count - 1
                    let url = URL(string: imageURL!)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                self.friends[userID!]?.stories[storyIndex].image = UIImage(data: data!)
                            }
                        }
                    }).resume()
                }
                
                
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                
    
                    }
            }, withCancel: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if myself == nil {
            if indexPath.row == 0 {
                // public stories
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PublicAgencyCell
                cell.storiesViewController = self
                return cell
            } else {
                // friends' story cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyCellId, for: indexPath) as! StoryCell
                cell.isUserInteractionEnabled = true
                cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDisplayStories)))
                let user = friends[friendIDAsArray[indexPath.row - 1]]!
                
                cell.userID = user.id
                cell.nameLable.text = user.name
                
                if let imageURL = user.stories.first?.imageURL{
                    fetchImageAndDisplay(withURL: imageURL, indexPath: indexPath)
                }
                return cell
            }

        } else {
            // I have stories
            if indexPath.row == 0 {
                // my story cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyCellId, for: indexPath) as! StoryCell
                
                cell.isUserInteractionEnabled = true
                cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDisplayStories)))

                cell.nameLable.text = "My Story"
                cell.userID = myself!.id
                if let imageURL = myself?.stories.first?.imageURL{
                    fetchImageAndDisplay(withURL: imageURL, indexPath: indexPath)
                }
                return cell
            } else if indexPath.row == 1 {
                //public stories
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PublicAgencyCell
                cell.storiesViewController = self
                return cell
            } else {
                // friends' story cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyCellId, for: indexPath) as! StoryCell
                
                cell.isUserInteractionEnabled = true
                cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDisplayStories)))

                let user = friends[friendIDAsArray[indexPath.row - 2]]!
                
                cell.userID = user.id
                cell.nameLable.text = user.name
                
                if let imageURL = user.stories.first?.imageURL{
                    fetchImageAndDisplay(withURL: imageURL, indexPath: indexPath)
                }
                return cell
            }
        }
        
    }
    
    var startingFrame: CGRect?
    var startingImageView: UIImageView?
    
    func handleDisplayStories(tapGesture: UITapGestureRecognizer) {
        
        let storyCell = tapGesture.view as? StoryCell
        var stories = [Story]()
        if storyCell?.userID == myself?.id {
            stories = myself!.stories
        } else {
            stories = friends[storyCell!.userID!]!.stories
        }
        
        
        if let imageView = storyCell?.imageView, storyCell?.imageView.image != nil {
            
            startingImageView = imageView
            startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
            let zoomingImageView = UIImageView(frame: startingFrame!)
            zoomingImageView.contentMode = .scaleAspectFill
            zoomingImageView.clipsToBounds = true
            zoomingImageView.image = self.startingImageView?.image
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStopStory)))
            
            if let keyWindow = UIApplication.shared.keyWindow {
                
                let blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView.backgroundColor = UIColor.black
                blackBackgroundView.alpha = 0
                keyWindow.addSubview(blackBackgroundView)
                blackBackgroundView.addSubview(zoomingImageView)
                
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    blackBackgroundView.alpha = 1.0
                    
                    let imageWidth: CGFloat? = self.startingImageView?.image?.size.width
                    let imageHeight: CGFloat? = self.startingImageView?.image?.size.height
                    
                    let height = imageHeight! / imageWidth! * blackBackgroundView.frame.width
                    
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: blackBackgroundView.frame.width, height: height)
                    zoomingImageView.center = keyWindow.center
                    }, completion: nil)
                
                // loop from the second story
                var delayTime = Double((stories.first!.timer)!)
                if stories.count > 0{
                    for i in 1..<stories.count {
                        
                        delay(Double(delayTime)) {
                            zoomingImageView.image = stories[i].image
                            let imageWidth: CGFloat? = zoomingImageView.image?.size.width
                            let imageHeight: CGFloat? = zoomingImageView.image?.size.height
                            
                            let height = imageHeight! / imageWidth! * keyWindow.frame.width
                            
                            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                            zoomingImageView.center = keyWindow.center
                        }
                        delayTime = delayTime + Double(stories[i].timer!)
                    }
                }
                // handle zoom out
                delay(delayTime) {
                    zoomingImageView.contentMode = .scaleAspectFill
                    zoomingImageView.clipsToBounds = true
                    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        
                        zoomingImageView.frame = self.startingFrame!
                        zoomingImageView.superview?.alpha = 0
                        
                        }, completion: { (completed) in
                            zoomingImageView.superview?.removeFromSuperview()
                            zoomingImageView.removeFromSuperview()
                    })
                }
            }
      
            
        }
    }
    
    func handleStopStory(tapGesture: UITapGestureRecognizer) {
        if let zoomingImageView = tapGesture.view as? UIImageView{
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomingImageView.frame = self.startingFrame!
                zoomingImageView.superview?.alpha = 0
                
                }, completion: { (completed) in
                    zoomingImageView.superview?.removeFromSuperview()
                    zoomingImageView.removeFromSuperview()
            })
        }
        
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func fetchImageAndDisplay(withURL imageURL: String, indexPath: IndexPath) {
        let url = URL(string: imageURL)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            let cell = self.collectionView?.cellForItem(at: indexPath) as? StoryCell
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    cell?.imageView.image = UIImage(data: data!)
                }
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





