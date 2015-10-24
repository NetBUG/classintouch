//
//  ClassListViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit
import CoreData;

class ClassListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties

    @IBOutlet weak var tableView: UITableView!

    var selectedClass: Class?

    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()

    lazy var currentUser: User? = {
        do {
            guard let userID = NSUserDefaults.standardUserDefaults().objectForKey("UserID") as? NSNumber else {
                return nil
            }
            return try self.context.object("User", identifier: userID, key: "id") as? User
        } catch {
            return nil
        }
    }()

    // MARK: ViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        if (currentUser == nil) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.performSegueWithIdentifier("LoginSegue", sender: self)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let classViewController = segue.destinationViewController as? ClassViewController {
            classViewController.registeredClass = selectedClass
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassListCell", forIndexPath: indexPath)
        cell.textLabel?.text = currentUser?.classes?[indexPath.row].name
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = currentUser?.classes?.count {
            return count
        } else {
            return 0
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ClassSegue", sender: self)
    }

}
