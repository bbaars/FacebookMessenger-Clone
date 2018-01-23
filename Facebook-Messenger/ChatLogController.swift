//
//  ChatLogController.swift
//  Facebook-Messenger
//
//  Created by Brandon Baars on 1/20/18.
//  Copyright © 2018 Brandon Baars. All rights reserved.
//

import UIKit
import CoreData

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    private let cellId = "cellId"
    
    var friend: Friend? {
        didSet {
            navigationItem.title = friend?.name
        }
    }
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Message Here..."
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0, green: 0.5254901961, blue: 1, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "Avenir Next", size: 16)
        return button
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend!.name!)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    var blockOperations = [BlockOperation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        do {
            try fetchedResultsController.performFetch()            
        } catch let error {
            print(error)
        }
        
        collectionView?.backgroundColor = UIColor.white
        self.collectionView?.alwaysBounceVertical = true
        
        tabBarController?.tabBar.isHidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotif), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotif), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Custom Functions
    private func setupInputComponents() {
        
        let topBorder = UIView()
        topBorder.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainerView.addSubview(topBorder)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-16-[v0][v1(60)]-8-|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorder)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorder)
    }
    
    @objc func simulate() {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            let _ = FriendsController.createMessage(withText: "Here's a text message that was sent a few minutes ago", friend: friend!, minutesAgo: 2, context: context)
            
            do {
                try context.save()
                
            } catch let error {
                print(error)
            }
        }
    }
    
    @objc func handleSend() {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            if let message = inputTextField.text, let friend = friend {
                
                let _ = FriendsController.createMessage(withText: message, friend: friend, minutesAgo: 0, isSender: true, context: context)
                
                do {
                    try context.save()

                    inputTextField.text = ""

                } catch let error {
                    print(error)
                }
            }
        }
    }
        
    @objc func handleKeyboardNotif(_ notif: Notification) {
        
        if let userInfo = notif.userInfo {
            
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
            
            let keyFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            print(keyFrame)
            
            let isShowing = notif.name == Notification.Name.UIKeyboardWillShow
            let deltaY = isShowing ? -keyFrame.height : 0
            
            self.bottomConstraint?.constant = deltaY
            
            UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIViewKeyframeAnimationOptions(rawValue: curve), animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) in
                
                if isShowing && (self.collectionView?.contentSize.height)! > keyFrame.origin.y {
                    let indexPath = IndexPath(item: self.fetchedResultsController.sections![0].numberOfObjects - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    self.collectionView?.contentOffset.y += self.messageInputContainerView.frame.height + 20
                }
            })
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .insert {
            print("THIS GOT CALLED")
            blockOperations.append(BlockOperation(block: {
                self.collectionView?.insertItems(at:[ newIndexPath!])
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView?.performBatchUpdates({
            
            for operation in blockOperations {
                operation.start()
            }
        }, completion: { (completed) in
            let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
            let newIndexPath = IndexPath(item: lastItem, section: 0)
            self.collectionView?.scrollToItem(at: newIndexPath, at: .bottom, animated: true)
            self.collectionView?.contentOffset.y += self.messageInputContainerView.frame.height + 20
        })
    }
    

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchedResultsController.sections?[0].numberOfObjects {
            return count
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        let message = fetchedResultsController.object(at: indexPath) as! Message
        
//        cell.messageTextView.text = messages?[indexPath.row].text
        cell.messageTextView.text = message.text!
        
        if let messageText = message.text, let  profileImageName = message.friend?.profileImageName {
            let size = CGSize(width: 250, height: 1000)
            
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size , options: options, attributes: [NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 16)!], context: nil)
            
             cell.profileImageView.image = UIImage(named: profileImageName)
            
            // if the message was from the other person
            if !message.isSender {
                
                cell.profileImageView.isHidden = false
                cell.messageTextView.frame = CGRect(x: 56, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: 0, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20)
                cell.messageTextView.textColor = UIColor.black
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
            }
                // if the message was from you
            else {
                
                cell.profileImageView.isHidden = true
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 12 - 8, y: 0, width: estimatedFrame.width + 16 + 12 + 8, height: estimatedFrame.height + 20)
                cell.messageTextView.textColor = UIColor.white
                cell.bubbleImageView.tintColor = #colorLiteral(red: 0, green: 0.5254901961, blue: 1, alpha: 1)
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 12, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = fetchedResultsController.object(at: indexPath) as! Message
        
        if let messageText = message.text {
            let size = CGSize(width: 250, height: 1000)
            
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 16)!], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        
        return CGSize(width: view.frame.width, height: 100)
    }
}


// MARK: - ChatLogMessageCell: BaseCell
class ChatLogMessageCell: BaseCell {
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    static let blueBubbleImage = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Avenir Next", size: 16)
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.text = "Example Message"
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func setupView() {
        super.setupView()
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraintsWithFormat(format: "H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraintsWithFormat(format: "V:|[v0]|", views: bubbleImageView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView)
    }
}
