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
    func object(type: String, identifier: AnyObject, key: String) throws -> AnyObject? {
        let request = NSFetchRequest(entityName: type)
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: [key, identifier])
        return try executeFetchRequest(request).first
    }

    func objects(type: String) throws -> [AnyObject] {
        return try executeFetchRequest(NSFetchRequest(entityName: type))
    }
}

extension PGNetworkMapping {
    static var classMapping: PGNetworkMapping {
        return PGNetworkMapping(description: [["Class": "Class"], ["id": "id"]], mapping: ["name": "name", "lon": "longitude", "lat": "latitude"])
    }
    static var userMapping: PGNetworkMapping {
        return PGNetworkMapping(description: [["User": "User"], ["id": "id"]], mapping: ["name": "name"])
    }
   
}

extension PGNetworkHandler {

    func nearbyCourse(longitude: Float, latitude: Float, context: NSManagedObjectContext, success: ((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.GET("classnearby.json", parameters: ["lon": longitude, "lat": latitude], success: success, failure: failure, finish: finish)
    }
    
    //POST, need to be fixed
    func createClass(longitude: Float, latitude: Float, name: String, context:NSManagedObjectContext, success:((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.POST("createclass.json", from: ["lon": longitude, "lat": latitude, "name": name], success: success, failure: failure, finish: finish)
    }
    
    func myClass(id: Int, context: NSManagedObjectContext, success:((result: [AnyObject]!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.GET("getmyclass.json", parameters: ["uid": id], to: context, mapping: PGNetworkMapping.classMapping, success: success, failure: failure, finish: finish)
    }
    
    //Post, need to be fixed
    func createDiscussion(classId: NSNumber, title: String, text: String, context:NSManagedObjectContext, success:((result: [AnyObject]!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        
    }
    
    //Post, need to be fixed
    func createPost(discussionId: NSNumber, title: String, text: String, context:NSManagedObjectContext, success:((result: [AnyObject]!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        
    }
    
    func getDiscussion(classId: NSNumber, context:NSManagedObjectContext, success:((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.GET("getdiscussion.json", parameters: ["class_id": classId], success: success, failure: failure, finish: finish)
    }
    
    func getPost(classId: NSNumber, context:NSManagedObjectContext, success:((result: [AnyObject]!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
    }
    
    //Post, need to be fixed
    func likePost(postId: NSNumber, userId: NSNumber, context:NSManagedObjectContext, success:((result: [AnyObject]!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
    }

    
}