//
//  DataHandler.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func object(type: String, identifier: String, key: String) throws -> AnyObject? {
        let request = NSFetchRequest(entityName: type)
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: [key, identifier])
        return try executeFetchRequest(request).first
    }

    func objects(type: String) throws -> [AnyObject] {
        return try executeFetchRequest(NSFetchRequest(entityName: type))
    }
}

