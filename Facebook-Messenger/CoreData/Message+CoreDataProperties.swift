//
//  Message+CoreDataProperties.swift
//  Facebook-Messenger
//
//  Created by Brandon Baars on 1/19/18.
//  Copyright © 2018 Brandon Baars. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var friend: Friend?
}
