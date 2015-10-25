//
//  Class+CoreDataProperties.swift
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

extension Class {

    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var distance: NSNumber?
    @NSManaged var day: NSNumber?
    @NSManaged var unit: String?
    @NSManaged var discussions: NSOrderedSet?
    @NSManaged var whichUser: User?

}
