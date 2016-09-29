//
//  CameraRollController.swift
//  simple-snapchat
//
//  Created by Jeffrey on 29/9/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class CameraRollController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Memories"
        
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
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        cell.addSubview(<#T##view: UIView##UIView#>)
        
        return cell
    }



    
}
