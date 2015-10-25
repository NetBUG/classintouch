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

    var currentClasses: [Class]?
    var selectedClass: Class?

    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.me"))
        }()

    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()

    lazy var user: User? = {
        do {
            return try self.context.object("User", identifier: 0, key: "id") as? User
        } catch {
            return nil
        }
    }()

    // MARK: ViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        if (user == nil) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.performSegueWithIdentifier("LoginSegue", sender: self)
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.networkHandler.myClass(0, context: context, success: { (result: [AnyObject]!) -> Void in
            self.currentClasses = result as? [Class]
            }, failure: { (error: NSError!) -> Void in
                print(error)
            }) { () -> Void in
                self.tableView.reloadData()
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
        cell.textLabel?.text = currentClasses?[indexPath.row].name
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = currentClasses?.count {
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
