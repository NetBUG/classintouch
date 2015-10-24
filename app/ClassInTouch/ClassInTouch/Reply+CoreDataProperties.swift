//
//  Reply+CoreDataProperties.swift
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

extension Reply {

    @NSManaged var content: String?
    @NSManaged var date: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var poster: User?
    @NSManaged var whichQuestion: Question?

}
