//
//  ChatLogController.swift
//  Facebook-Messenger
//
//  Created by Brandon Baars on 1/20/18.
//  Copyright © 2018 Brandon Baars. All rights reserved.
//

import UIKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    var friend: Friend? {
        didSet {
            navigationItem.title = friend?.name
            messages = friend?.messages?.allObjects as? [Message]
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
        }
    }
    
    var messages: [Message]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.backgroundColor = UIColor.white
        self.collectionView?.alwaysBounceVertical = true
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = messages?.count {
            return count
        }
        
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        cell.messageTextView.text = messages?[indexPath.row].text
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}

class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Avenir Next", size: 16)
        textView.text = "Example Message"
        return textView
    }()
    
    override func setupView() {
        super.setupView()
        addSubview(messageTextView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: messageTextView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: messageTextView)
    }
}
