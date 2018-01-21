//
//  FriendsControllerHelper.swift
//  Facebook-Messenger
//
//  Created by Brandon Baars on 1/19/18.
//  Copyright © 2018 Brandon Baars. All rights reserved.
//

import Foundation
import UIKit
import CoreData


extension FriendsController {
    
    
    // MARK: - Custom Function
    func setupData() {
        
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            mark.name = "Mark Zuckerberg"
            mark.profileImageName = "zuckprofile"
            
            let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            message.friend = mark
            message.text = "hello, my name is mark. Nice to meet you!"
            message.date = NSDate()
            
            let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            steve.name = "Steve Jobs"
            steve.profileImageName = "steve_profile"
            
            let donald = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            donald.name = "Donald Trump"
            donald.profileImageName = "donald_trump_profile"
            
            createMessage(withText: "You're fired", friend: donald, minutesAgo: 5, context: context)
            createMessage(withText: "Are you interested in buying an apple device?", friend: steve, minutesAgo: 4, context: context)
            createMessage(withText: "Good morning...", friend: steve, minutesAgo: 2, context: context)
            createMessage(withText: "Hello, how are you?", friend: steve, minutesAgo: 1, context: context)
            
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
        
        loadData()
    }
    
    func loadData() {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            if let friends = fetchFriends() {
                
                messages = [Message]()
                
                for friend in friends {
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                    fetchRequest.fetchLimit = 1
                    
                    do {
                        let fetchedMessages = try context.fetch(fetchRequest) as? [Message]
                        messages?.append(contentsOf: fetchedMessages!)
                    } catch let error {
                        print(error)
                    }
                }
                
                messages = messages?.sorted(by: {$0.date?.compare($1.date! as Date) == .orderedDescending})
            }
        }
    }
    
    func clearData() {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            do {
                let entityName = ["Friend", "Message"]
                
                for entity in entityName {
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                    
                    let objects = try context.fetch(fetchRequest) as? [NSManagedObject]
                    
                    for object in objects! {
                        context.delete(object)
                    }
                }
                
                try context.save()
                
            } catch let error {
                print(error)
            }
        }
    }
    
    // MARK: - Private Functions
    private func fetchFriends() -> [Friend]? {
    
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            
            do {
                
                return try context.fetch(request) as? [Friend]
                
            } catch let error {
                print(error)
            }
        }
        
        return nil
    }
    
    
    private func createMessage(withText text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext) {
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
    }
}



















