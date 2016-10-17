//
//  PublicStoryCell.swift
//  simple-snapchat
//
//  Created by Jeffrey on 16/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class PublicStoryCell: UICollectionViewCell, UIWebViewDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var publicStory = PublicStory() {
        didSet{
            reload()
        }
    }
    var isLoaded = false
    
    let storyView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .white
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let titleView: UITextView = {
        let tl = UITextView()
        tl.font = UIFont.boldSystemFont(ofSize: 32)
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.isScrollEnabled = false
        return tl
    }()
    
    let authorLable: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: 16)
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    
    lazy var contentWebView: UIWebView = {
        let cv = UIWebView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.scrollView.isScrollEnabled = false
        cv.scalesPageToFit = true
        cv.delegate = self
        return cv
    }()
    
    var storyViewHeightConstraint: NSLayoutConstraint?
    var titleHeightConstraint: NSLayoutConstraint?
    var contentHeightConstraint: NSLayoutConstraint?
    func setupView() {
        addSubview(storyView)
//        storyView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 3000)
//        storyView.contentSize.height = 2000
        storyView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        storyView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        storyView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        storyViewHeightConstraint = storyView.heightAnchor.constraint(equalToConstant: 1000)
        storyViewHeightConstraint?.isActive = true
        
        storyView.addSubview(titleView)
        titleView.leftAnchor.constraint(equalTo: storyView.leftAnchor, constant: 20).isActive = true
        titleView.topAnchor.constraint(equalTo: storyView.topAnchor, constant: 50).isActive = true
        titleView.widthAnchor.constraint(equalTo: storyView.widthAnchor, constant: -40).isActive = true
        titleHeightConstraint = titleView.heightAnchor.constraint(equalToConstant: 100)
        titleHeightConstraint?.isActive = true
        
        storyView.addSubview(authorLable)
        authorLable.text = "Changchang Wang"
        authorLable.leftAnchor.constraint(equalTo: storyView.leftAnchor, constant: 25).isActive = true
        authorLable.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 5).isActive = true
        authorLable.widthAnchor.constraint(equalTo: storyView.widthAnchor, constant: -40).isActive = true
        authorLable.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        storyView.addSubview(contentWebView)
        contentWebView.leftAnchor.constraint(equalTo: storyView.leftAnchor, constant: 20).isActive = true
        contentWebView.topAnchor.constraint(equalTo: authorLable.bottomAnchor, constant: 5).isActive = true
        contentWebView.widthAnchor.constraint(equalTo: storyView.widthAnchor, constant: -40).isActive = true
        contentHeightConstraint = contentWebView.heightAnchor.constraint(equalToConstant: 500)
        contentHeightConstraint?.isActive = true
        
    }
    
    func reload() {
        titleView.text = publicStory.title
        // fix the height of titleView
        let fixedWidth = frame.width - 40
        let newTitleSize = titleView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        titleHeightConstraint?.isActive = false
        titleHeightConstraint = titleView.heightAnchor.constraint(equalToConstant: newTitleSize.height)
        
        // modify contentWebView

        let html = "<html><head><meta name=\"viewport\" content=\"width=320\"/></head>" + publicStory.content
        contentWebView.loadHTMLString(html, baseURL: nil)
        isLoaded = true
        print("reloading")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if contentWebView.isLoading {
            return
        }
        let fixedWidth = frame.width - 40
        let newContentSize = contentWebView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        contentHeightConstraint?.isActive = false
        contentHeightConstraint = contentWebView.heightAnchor.constraint(equalToConstant: newContentSize.height)
        contentHeightConstraint?.isActive = true
        print("finish loading")
        // modify the height of the whole view
//        storyViewHeightConstraint?.isActive = false
//        storyViewHeightConstraint = storyView.bottomAnchor.constraint(equalTo: contentWebView.bottomAnchor)
//        storyViewHeightConstraint?.isActive = true
    }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
//        if indexPath.item == 0 {
//            cell.addSubview(titleView)
//            titleView.text = publicStory.title
//            titleView.frame = CGRect(x: 20, y: 50, width: cell.frame.width - 60, height: cell.frame.height)
//        } else if indexPath.item == 1 {
//            cell.addSubview(authorLable)
//            authorLable.text = publicStory.author
//            authorLable.frame = CGRect(x: 20, y: 0, width: cell.frame.width, height: cell.frame.height)
//        }
//        cell.backgroundColor = .yellow
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if indexPath.item == 0 {
//            let cell = collectionView.cellForItem(at: indexPath)
//            if !titleView.text.isEmpty {
//                let fixedWidth = (cell?.frame.width)! - 60
//                let newSize = titleView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
//                return CGSize(width: frame.width, height: newSize.height)
//            }
//        } else if indexPath.item == 1 {
//            return CGSize(width: frame.width, height: 200)
//        }
//        return CGSize(width: frame.width, height: 100)
//    }
    
}
