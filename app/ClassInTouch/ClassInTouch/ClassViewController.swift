//
//  ClassViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class ClassViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LGChatControllerDelegate {

    // MARK: Properties

    @IBOutlet weak var tableView: UITableView!

    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.club"))
        }()

    var context: NSManagedObjectContext?
    var registeredClass: Class?
    var selectedDiscussion: Discussion?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = registeredClass?.name
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let context = self.context else {
            return
        }
        
        guard let id = registeredClass?.id else {
            return
        }
        
        networkHandler.getDiscussion(id, context: context, success: { (result: [AnyObject]!) -> Void in
            if let discussions = result as? [Discussion] {
                for discussion: Discussion in discussions {
                    discussion.whichClass = self.registeredClass
                }
            }
            do {
                try self.context?.save()
            } catch {
                // TODO: Handle error in the future
            }
            }, failure: { (error: NSError!) -> Void in
                    print(error)
            }) { () -> Void in
                self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController {
            if let askViewController = navigationController.topViewController as? AskViewController {
                askViewController.selectedClass = registeredClass
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassCell", forIndexPath: indexPath)
        let discussion: Discussion? = registeredClass?.discussions?[indexPath.row] as? Discussion
        cell.textLabel?.text = discussion?.title
        cell.detailTextLabel?.text = discussion?.content
        cell.textLabel?.font = UIFont (name: "HelveticaNeue-UltraLight", size: 30)
        cell.detailTextLabel?.font = UIFont (name: "HelveticaNeue-Light", size: 20)

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredClass?.discussions?.count ?? 0
    }

    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.selectedDiscussion = registeredClass?.discussions?[indexPath.row] as? Discussion

        guard let discussionId = selectedDiscussion?.id else {
            return
        }
        
        guard let context = self.context else {
            return
        }
        
        networkHandler.getPost(discussionId, context: context, success: { (result: [AnyObject]!) -> Void in
            if let posts = result as? [Post] {
                for post: Post in posts {
                    post.whichDiscussion = self.selectedDiscussion
                }
            }
            do {
                try self.context?.save()
            } catch {
                // TODO: Handle error in the future
            }
            }, failure: nil) { () -> Void in
                self.launchChatController()
        }
    }

    // MARK: - Chat
    
    // MARK: Launch Chat Controller
    
    func launchChatController() {
        let chatController = LGChatController()
        chatController.title = selectedDiscussion?.title
        
        var messages: [LGChatMessage] = Array()
        if let posts = selectedDiscussion?.posts?.array as? [Post] {
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
        guard let discussionID = self.selectedDiscussion?.id else {
            return
        }
        
        guard let context = self.context else {
            return
        }
        
        self.networkHandler.createPost(userID, discussionId: discussionID, title: message.content, text: message.content, context: context, success: nil, failure: nil, finish: nil)
        print("Did Add Message: \(message.content)")
    }
    
    func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        return true
    }
}
