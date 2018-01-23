//
//  ViewController.swift
//  Facebook-Messenger
//
//  Created by Brandon Baars on 1/17/18.
//  Copyright © 2018 Brandon Baars. All rights reserved.
//

import UIKit
import CoreData

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    // MARK: - Variables
    
    // cell identifier
    private let cellId = "messageCell"
    
    var blockOperations = [BlockOperation]()
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Recent"
    
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupData()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Mark", style: .plain, target: self, action: #selector(addMark))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc func addMark() {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            mark.name = "Mark Zuckerberg"
            mark.profileImageName = "zuckprofile"
            
            let _ =  FriendsController.createMessage(withText: "Hello, my name is Mark. Nice to meet you", friend: mark, minutesAgo: 0, context: context)
            
            let bill = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            bill.name = "Bill Gates"
            bill.profileImageName = "gates"
            
             let _ =  FriendsController.createMessage(withText: "Hello, my name is Bill Gates", friend: bill, minutesAgo: 0, context: context)
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
        })
    }
    
    
    // MARK: - Collection View Data Source
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let count = fetchedResultsController.sections?[0].numberOfObjects {
            return count
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let friend = fetchedResultsController.object(at: indexPath) as! Friend
        cell.message = friend.lastMessage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        let friend = fetchedResultsController.object(at: indexPath) as! Friend
        controller.friend = friend
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
}


class MessageCell: BaseCell {
    
    // MARK: - Setup Variables
    var message: Message? {
        didSet {
            nameLabel.text = message?.friend?.name
            
            if let profileImageName = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: profileImageName)
                hasReadImageView.image = UIImage(named: profileImageName)
            }
            
            messageLabel.text = message?.text
            
            if let date = message?.date {
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                let secondsInDay: TimeInterval = 60 * 60 * 24
                
                if elapsedTimeInSeconds > secondsInDay * 7 {
                    dateformatter.dateFormat = "MM/dd/yy"
                } else if elapsedTimeInSeconds > secondsInDay {
                    dateformatter.dateFormat = "EEE"
                }
                
                timeLabel.text = dateformatter.string(from: date as Date)
            }
        }
    }
    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Next", size: 18.0)
        label.text = "Mark Zuckerberg"
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Friends Message and something else..."
         label.font = UIFont(name: "Avenir Next", size: 15.0)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:14 pm"
        label.font = UIFont(name: "Avenir Next", size: 15.0)
        label.textColor = UIColor.darkGray
        label.textAlignment = .right
        return label
    }()
    
    let hasReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    // override highlighted method
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? #colorLiteral(red: 0, green: 0.5254901961, blue: 1, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1) : UIColor.black
            timeLabel.textColor = isHighlighted ? #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1) : UIColor.darkGray
            messageLabel.textColor = isHighlighted ? #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1) : UIColor.darkGray
        }
    }
    
    override func setupView() {
        
        profileImageView.image = UIImage(named: "zuckprofile")
        hasReadImageView.image = UIImage(named: "zuckprofile")
        addSubview(profileImageView)
        addSubview(hasReadImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        // create our constraints for our profile image view
        addConstraintsWithFormat(format: "H:|-12-[v0(68)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(68)]", views: profileImageView)
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat(format: "H:|-82-[v0]|", views: dividerLineView)
        addConstraintsWithFormat(format: "V:[v0(0.75)]|", views: dividerLineView)
    }
    
    private func setupContainerView() {
        
        let containerView = UIView()
        addSubview(containerView)
        
        addConstraintsWithFormat(format: "H:|-90-[v0]|", views: containerView)
        addConstraintsWithFormat(format: "V:[v0(50)]", views: containerView)
         addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        containerView.addConstraintsWithFormat(format: "H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        containerView.addConstraintsWithFormat(format: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        containerView.addConstraintsWithFormat(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
        containerView.addConstraintsWithFormat(format: "V:|[v0(24)]", views: timeLabel)
        containerView.addConstraintsWithFormat(format: "V:[v0(20)]|", views: hasReadImageView)
    }
}

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
       // preconditionFailure("Override this method")
    }
}

extension UIView {
    
    // helper function for adding constraints
    func addConstraintsWithFormat(format: String, views: UIView...) {
        
        var viewsDict = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            
            let key = "v\(index)"
            viewsDict[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewsDict))
    }
}
