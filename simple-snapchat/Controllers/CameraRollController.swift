//
//  CameraRollController.swift
//  simple-snapchat
//
//  Created by Jeffrey on 29/9/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Photos
import Firebase

private let reuseIdentifier = "Cell"

class CameraRollController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Memories"
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 255/255, green: 20/255, blue: 147/255, alpha: 1)]
        
        let checkIcon = UIImage(named: "check-icon")
        // set icon size
        UIGraphicsBeginImageContext(CGSize(width: 25, height: 25))
        checkIcon?.draw(in: CGRect(x: 0, y: 3, width: 20, height: 20))
        let newCheckIcon = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysTemplate)
        UIGraphicsEndImageContext()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newCheckIcon, style: .plain, target: self, action: #selector(handleSelectImage))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(colorLiteralRed: 255/255, green: 20/255, blue: 147/255, alpha: 1)
    
        grabPhotos()
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.allowsSelection = false
        
    }
    
    var didClickSelectButton: Bool = false
    
    let bottomSelectView: UIView = {
        let bs = UIView()
        bs.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 20/255, blue: 147/255, alpha: 1)
        return bs
    }()
    
    lazy var sendButtonView: UIImageView = {
        let sb = UIImageView()
        sb.image = UIImage(named: "send-button")?.withRenderingMode(.alwaysTemplate)
        sb.tintColor = UIColor.white
        sb.isUserInteractionEnabled = true
        sb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSend)))
        return sb
    }()
    
    func handleSend() {
        if let selectedPhotos = collectionView?.indexPathsForSelectedItems, let uid = FIRAuth.auth()?.currentUser?.uid {
            
            // Create new story ref
            let storiesRef = FIRDatabase.database().reference().child("users").child(uid).child("stories")
            let storyRef = storiesRef.childByAutoId()
            
            for i in 0..<selectedPhotos.count {
                let imageName = NSUUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("stories").child(imageName)
                let cell = collectionView?.cellForItem(at: selectedPhotos[i]) as! PhotoCell
                let image = cell.imageView.image
                let uploadData = UIImagePNGRepresentation(image!)
                
                storageRef.put(uploadData!, metadata: nil, completion: { (metaData, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    } else {
                        
                        // update database after successfully uploaded
                        let imageRef = storyRef.childByAutoId()
                        if let imageURL = metaData?.downloadURL()?.absoluteString {
                            let values = ["imageURL": imageURL]
                            imageRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                                if error != nil {
                                    print(error)
                                    return
                                } else {
                                    self.handleSelectImage()
                                    self.didClickSelectButton = true
                                }
                            })
                        }
                        
                    }
                    
                })
            }
        }

    }
    
    func handleSelectImage() {
        if didClickSelectButton == false {
            
            didClickSelectButton = true
            
            navigationItem.rightBarButtonItem?.tintColor = UIColor(colorLiteralRed: 174/255, green: 2/255, blue: 2/255, alpha: 1)
            
            collectionView?.allowsSelection = true
            collectionView?.allowsMultipleSelection = true
            if let cells = collectionView?.visibleCells {
                for i in 0..<cells.count {
                    let photoCell = cells[i] as? PhotoCell
                    photoCell?.imageView.isUserInteractionEnabled = false
                }
            }
            // Set bottom select view
            view.addSubview(bottomSelectView)
            bottomSelectView.translatesAutoresizingMaskIntoConstraints = false
            bottomSelectView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            bottomSelectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            bottomSelectView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            bottomSelectView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            // Set send button
            bottomSelectView.addSubview(sendButtonView)
            sendButtonView.translatesAutoresizingMaskIntoConstraints = false
            sendButtonView.centerYAnchor.constraint(equalTo: bottomSelectView.centerYAnchor).isActive = true
            sendButtonView.centerXAnchor.constraint(equalTo: bottomSelectView.rightAnchor, constant: -30).isActive = true
            sendButtonView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            sendButtonView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        } else {
            
            didClickSelectButton = false
            
            navigationItem.rightBarButtonItem?.tintColor = UIColor(colorLiteralRed: 255/255, green: 20/255, blue: 147/255, alpha: 1)
        
            if let cells = collectionView?.visibleCells {
                for i in 0..<cells.count {
                    let photoCell = cells[i] as? PhotoCell
                    collectionView?.deselectItem(at: IndexPath(row: i, section: 0), animated: true)
                    photoCell?.imageView.isUserInteractionEnabled = true
                    photoCell?.imageView.alpha = 1
                }
            }
            collectionView?.allowsSelection = false
            collectionView?.allowsMultipleSelection = false
            sendButtonView.removeFromSuperview()
            bottomSelectView.removeFromSuperview()
        }
    }
    
    var imgArray = [UIImage]()
    
    func grabPhotos() {
        
        let imgManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
        if fetchResult.count > 0 {
            
            for i in 0..<fetchResult.count {
                
                imgManager.requestImage(for: fetchResult.object(at: i), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                        self.imgArray.append(image!)
                })
                
            }
            
        } else {
            print("No photos in your library")
        }
            
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        cell.imageView.image = imgArray[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/3 - 2
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? PhotoCell
        selectedCell?.imageView.alpha = 0.5

    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? PhotoCell
        selectedCell?.imageView.alpha = 1
    }
    
}

