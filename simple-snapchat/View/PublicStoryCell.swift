//
//  PublicStoryCell.swift
//  simple-snapchat
//
//  Created by Jeffrey on 16/10/16.
//  Copyright © 2016 University of Melbourne. All rights reserved.
//

import UIKit

class PublicStoryCell: UICollectionViewCell, UIWebViewDelegate, UIGestureRecognizerDelegate {
    var publicStoryController: PublicStoryController?
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
        sv.bounces = false
        return sv
    }()
    
    lazy var titleView: UITextView = {
        let tl = UITextView()
        tl.font = UIFont.boldSystemFont(ofSize: 32)
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.isScrollEnabled = false
        tl.isEditable = false
        
        // add gesture to dismiss the controller
        tl.isUserInteractionEnabled = true
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeDown.direction = .down
        swipeDown.delegate = self
        tl.addGestureRecognizer(swipeDown)
        return tl
    }()
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if storyView.contentOffset.y == 0{
            return true
        }
        return false
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        return true
//    }
    
    lazy var authorLable: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: 16)
        tl.translatesAutoresizingMaskIntoConstraints = false
        
        // add gesture to dismiss the controller
        tl.isUserInteractionEnabled = true
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeDown.direction = .down
        swipeDown.delegate = self
        tl.addGestureRecognizer(swipeDown)
        return tl
    }()
    
    lazy var contentWebView: UIWebView = {
        let cv = UIWebView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.scrollView.isScrollEnabled = false
        cv.scalesPageToFit = true
        cv.delegate = self
        
        // add gesture to dismiss the controller
        cv.isUserInteractionEnabled = true
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeDown.direction = .down
        swipeDown.delegate = self
        cv.addGestureRecognizer(swipeDown)
        return cv
    }()
    
    func handleDismiss(swipeGesture: UIGestureRecognizer) {
        publicStoryController?.dismiss(animated: true, completion: nil)
    }
    
    var titleHeightConstraint: NSLayoutConstraint?
    var contentHeightConstraint: NSLayoutConstraint?
    func setupView() {
        addSubview(storyView)
        storyView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        storyView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        storyView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        storyView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        storyView.addSubview(titleView)
        titleView.leftAnchor.constraint(equalTo: storyView.leftAnchor, constant: 20).isActive = true
        titleView.topAnchor.constraint(equalTo: storyView.topAnchor, constant: 50).isActive = true
        titleView.widthAnchor.constraint(equalTo: storyView.widthAnchor, constant: -40).isActive = true
        titleHeightConstraint = titleView.heightAnchor.constraint(equalToConstant: 100)
        titleHeightConstraint?.isActive = true
        
        storyView.addSubview(authorLable)
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
        
        authorLable.text = publicStory.author
        
        // modify contentWebView

        let html = "<html><head><meta name=\"viewport\" content=\"width=320\"/></head>" + publicStory.content
        contentWebView.loadHTMLString(html, baseURL: nil)
        isLoaded = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if contentWebView.isLoading {
            return
        }
        var fixedWidth = frame.width - 40
        let newTitleSize = titleView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        
        fixedWidth = frame.width - 40
        let newContentSize = contentWebView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        contentHeightConstraint?.isActive = false
        contentHeightConstraint = contentWebView.heightAnchor.constraint(equalToConstant: newContentSize.height)
        contentHeightConstraint?.isActive = true

        // modify the height of the whole view
        storyView.contentSize = CGSize(width: frame.width - 40, height: newTitleSize.height + newContentSize.height + CGFloat(90))
    }
    
}
