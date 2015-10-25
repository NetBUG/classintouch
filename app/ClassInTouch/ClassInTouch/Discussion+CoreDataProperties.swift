//
//  Discussion+CoreDataProperties.swift
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

extension Discussion {

    @NSManaged var content: String?
    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var title: String?
    @NSManaged var likes: NSNumber?
    @NSManaged var poster: User?
    @NSManaged var posts: NSOrderedSet?
    @NSManaged var whichClass: Class?

}
