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
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.club"))
        }()

    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()

    var user: User?

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

        do {
            let id = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
            self.user = try self.context.object("User", identifier: id, key: "id") as? User
        } catch {
            self.user = nil
        }

        self.networkHandler.myClass(user?.id?.integerValue ?? 0, context: context, success: { (result: [AnyObject]!) -> Void in
            self.currentClasses = result as? [Class]
            do {
                try self.context.save()
            } catch {
                // TODO: Handler error in the future
            }

            }, failure: { (error: NSError!) -> Void in
                print(error)
            }) { () -> Void in
                self.tableView.reloadData()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let classViewController = segue.destinationViewController as? ClassViewController {
            classViewController.registeredClass = selectedClass
            classViewController.context = context
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassListCell", forIndexPath: indexPath)
        cell.textLabel?.text = currentClasses?[indexPath.row].name
        cell.textLabel?.font = UIFont (name: "HelveticaNeue-UltraLight", size: 30)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentClasses?.count ?? 0
    }

    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedClass = currentClasses?[indexPath.row]
        self.performSegueWithIdentifier("ClassSegue", sender: self)
    }

}
