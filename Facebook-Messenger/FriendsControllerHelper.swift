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
    
    // MARK: - Custom Functions
    func setupData() {
        
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
        
            let donald = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            donald.name = "Donald Trump"
            donald.profileImageName = "donald_trump_profile"
            
            let gandhi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            gandhi.name = "Mahatma Gandhi"
            gandhi.profileImageName = "gandhi"
            
            let hilary = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            hilary.name = "Hilary Clinton"
            hilary.profileImageName = "hillary_profile"
            
            // Donald Trump
             let _ =  FriendsController.createMessage(withText: "You're fired", friend: donald, minutesAgo: 10, context: context)
            
            // Steve Jobs
            createSteveMessages(withContext: context)
            
        
           // Gandhi
             let _ =  FriendsController.createMessage(withText: "Love peace and joy.", friend: gandhi, minutesAgo: 60 * 23, context: context)
             let _ =  FriendsController.createMessage(withText: "You are truely insprirational ", friend: gandhi, minutesAgo: 60 * 24, isSender: true, context: context)
            
            // Hilary Clinton
             let _ =  FriendsController.createMessage(withText: "Please vote for me", friend: hilary, minutesAgo: 60 * 24 * 8, context: context)
            
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
        
//        loadData()
    }
    
    private func createSteveMessages(withContext context: NSManagedObjectContext) {
        
        let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve_profile"
        
        // Steve Jobs
        let _ =   FriendsController.createMessage(withText: "Good morning...", friend: steve, minutesAgo: 4, context: context)
         let _ =  FriendsController.createMessage(withText: "Hello, how are you?", friend: steve, minutesAgo: 3, context: context)
         let _ =  FriendsController.createMessage(withText: "Are you interested in buying an Apple device? We have a wide variety of apple devices that suit your needs. Please make a purchase with us.", friend: steve, minutesAgo: 2, context: context)
        
         let _ =  FriendsController.createMessage(withText: "I totally understand, we at Apple try to make the best possible devices so that there are no faults in the hardware or software.", friend: steve, minutesAgo: 0, context: context)
        
        // response messages
         let _ =  FriendsController.createMessage(withText: "Yes, totally looking to buy an  iPhone X.", friend: steve, minutesAgo: 2, isSender: true, context: context)
         let _ =  FriendsController.createMessage(withText: "I might have to wait though because the new iPhone is being built a lot slower and has a higher demand than previous phones", friend: steve, minutesAgo: 1, isSender: true, context: context)
         let _ =  FriendsController.createMessage(withText: "Yeah, thanks for that Mr. Jobs", friend: steve, minutesAgo: 0, isSender: true, context: context)
        
    }
    
    func loadData() {
        
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//
//        if let context = delegate?.persistentContainer.viewContext {
//
//            if let friends = fetchFriends() {
//
//                messages = [Message]()
//
//                for friend in friends {
//
//                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
//                    fetchRequest.fetchLimit = 1
//
//                    do {
//                        let fetchedMessages = try context.fetch(fetchRequest) as? [Message]
//                        messages?.append(contentsOf: fetchedMessages!)
//                    } catch let error {
//                        print(error)
//                    }
//                }
//
//                messages = messages?.sorted(by: {$0.date?.compare($1.date! as Date) == .orderedDescending})
//            }
//        }
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
    
    // MARK: - Private/Static Functions
//    private func fetchFriends() -> [Friend]? {
    
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//
//        if let context = delegate?.persistentContainer.viewContext {
//
//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
//
//            do {
//
//                return try context.fetch(request) as? [Friend]
//
//            } catch let error {
//                print(error)
//            }
//        }
//
//        return nil
//    }
    
    
    static func createMessage(withText text: String, friend: Friend, minutesAgo: Double, isSender: Bool = false, context: NSManagedObjectContext) -> Message {
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
        message.isSender = isSender
        friend.lastMessage = message
        
        return message
    }
}



















