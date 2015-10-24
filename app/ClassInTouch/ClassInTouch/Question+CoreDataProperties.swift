//
//  Question+CoreDataProperties.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Question {

    @NSManaged var title: String?
    @NSManaged var content: String?
    @NSManaged var id: NSNumber?
    @NSManaged var replies: NSSet?
    @NSManaged var whichClass: Class?
    @NSManaged var poster: User?

}
