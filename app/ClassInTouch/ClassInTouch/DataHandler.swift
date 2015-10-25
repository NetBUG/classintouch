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
    static var discussionMapping: PGNetworkMapping {
        return PGNetworkMapping(description: [["Discussion": "Discussion"], ["id": "id"]], mapping: ["text": "content", "title": "title", "likes": "likes"])
    }
    static var postMapping: PGNetworkMapping {
        return PGNetworkMapping(description: [["Post": "Post"], ["id": "id"]], mapping: ["text": "content", "title": "title", "likes": "likes"])
    }
   
}

extension PGNetworkHandler {

    func facebookLogin(id: Int, token: String, context: NSManagedObjectContext, success: ((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.GET("profile.json", parameters: ["uid": id, "token": token], success: success, failure: failure, finish: finish)
    }

    func nearbyCourse(longitude: Float, latitude: Float, context: NSManagedObjectContext, success: ((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.GET("classnearby.json", parameters: ["lon": longitude, "lat": latitude], success: success, failure: failure, finish: finish)
    }

    func joinClass(classId: NSNumber, userId: Int, context: NSManagedObjectContext, success: ((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        let parameters = "uid=\(userId)&class_id=\(classId)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())

        self.POST("joinclass.json?\(parameters!)", from: ["uid": userId, "class_id": classId], success: success, failure: failure, finish: finish)
    }

    func createClass(longitude: Float, latitude: Float, name: String, context:NSManagedObjectContext, success:((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        let parameters = "lat=\(latitude)&lon=\(latitude)&name=\(name)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        self.POST("createclass.json?\(parameters!)", from: ["lon": longitude, "lat": latitude, "name": name], success: success, failure: failure, finish: finish)
    }
    
    func myClass(id: NSNumber, context: NSManagedObjectContext, success:((result: [AnyObject]!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.GET("myclass.json", parameters: ["uid": id], to: context, mapping: PGNetworkMapping.classMapping, success: success, failure: failure, finish: finish)
    }

    func createDiscussion(userId: Int, classId: NSNumber, title: String, text: String, context:NSManagedObjectContext, success:((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        let parameters = "uid=\(userId)&class_id=\(classId)&title=\(title)&text=\(text)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        self.POST("posting.json?\(parameters!)", from: ["uid": userId, "class_id": classId, "title": title, "text": text], success: success, failure: failure, finish: finish);
    }
    
    func createPost(userId: Int, discussionId: NSNumber, title: String, text: String, context:NSManagedObjectContext, success:((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        let parameters = "uid=\(userId)&discussion_id=\(discussionId)&title=\(title)&text=\(text)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        self.POST("posting.json?\(parameters!)", from: ["uid": userId, "discussion_id": discussionId, "title": title, "text": text], success: success, failure: failure, finish: finish);
    }
    
    func getDiscussion(classId: NSNumber, context:NSManagedObjectContext, success:((result: [AnyObject]!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.GET("getdiscussion.json", parameters: ["class_id": classId], to: context, mapping: PGNetworkMapping.discussionMapping, success: success, failure: failure, finish: finish)
    }
    
    func getPost(discussionId: NSNumber, context:NSManagedObjectContext, success:((result: [AnyObject]!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.GET("getdiscussionpost.json", parameters: ["discussion_id": discussionId], to: context, mapping: PGNetworkMapping.postMapping, success: success, failure: failure, finish: finish)
    }
    
    func likePost(postId: NSNumber, userId: NSNumber, context:NSManagedObjectContext, success:((result: AnyObject!) -> Void)?, failure: ((error: NSError!) -> Void)?, finish: (() -> Void)?) {
        self.POST("likepost.json", from: ["post_id": postId, "uid": userId], success: success, failure: failure, finish: finish);
    }

    
}