//
//  ClassViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class ClassViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
        
        if let questionViewController = segue.destinationViewController as? QuestionViewController {
            questionViewController.discussion = selectedDiscussion
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassCell", forIndexPath: indexPath)
        let discussion: Discussion? = registeredClass?.discussions?[indexPath.row] as? Discussion
        cell.textLabel?.text = discussion?.title
        cell.detailTextLabel?.text = discussion?.content
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredClass?.discussions?.count ?? 0
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedDiscussion = registeredClass?.discussions?[indexPath.row] as? Discussion
        self.performSegueWithIdentifier("QuestionSegue", sender: self)
    }

}
