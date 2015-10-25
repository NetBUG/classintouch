//
//  QuestionViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController, LGChatControllerDelegate {

    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()
    
    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.club"))
        }()
    
    var discussion: Discussion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let discussionId = discussion?.id else {
            return
        }
        
        networkHandler.getPost(discussionId, context: context, success: { (result: [AnyObject]!) -> Void in
            if let posts = result as? [Post] {
                for post: Post in posts {
                    post.whichDiscussion = self.discussion
                }
            }
            do {
                try self.context.save()
            } catch {
                // TODO: Handle error in the future
            }
            }, failure: nil) { () -> Void in
                self.launchChatController()
        }
    }
    
    // MARK: Launch Chat Controller
    
    func launchChatController() {
        let chatController = LGChatController()
        chatController.title = discussion?.title
        
        var messages: [LGChatMessage] = Array()
        if let posts = discussion?.posts?.array as? [Post] {
            for post: Post in posts  {
                if let content = post.content {
                    messages.append(LGChatMessage(content: content, sentBy: .Opponent))
                }
            }
        }
        
        chatController.messages = messages
        chatController.delegate = self
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    
    // MARK: LGChatControllerDelegate
    
    func chatController(chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
        let userID = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
        guard let discussionID = self.discussion?.id else {
            return
        }
        
        self.networkHandler.createPost(userID, discussionId: discussionID, title: message.content, text: message.content, context: context, success: nil, failure: nil, finish: nil)
        print("Did Add Message: \(message.content)")
    }
    
    func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        /*
        Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
        */
        return true
    }

}
