//
//  User+CoreDataProperties.swift
//  ClassInTouch
//
//  Created by Ethan Wang on 10/25/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var classes: NSOrderedSet?
    @NSManaged var posts: NSOrderedSet?
    @NSManaged var discussions: NSOrderedSet?

}
