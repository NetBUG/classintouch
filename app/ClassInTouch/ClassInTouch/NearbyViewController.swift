//
//  NearbyViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties

    @IBOutlet weak var tableView: UITableView!

    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()

    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.me"))
        }()

    var classes: [Class]?

    // MARK: ViewController

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.networkHandler.nearbyCourse(50.1, latitude: 55.2, context: context, success: { (result: AnyObject!) -> Void in
            self.classes = result as? [Class]
            }, failure: { (error: NSError!) -> Void in
                print(error)
            }) { () -> Void in
                self.tableView.reloadData()
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NearbyCell", forIndexPath: indexPath)
        let cellClass = classes?[indexPath.row]
        cell.textLabel?.text = cellClass?.name
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes?.count ?? 0
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let classId = classes?[indexPath.row].id?.integerValue else {
            return
        }

        let userId = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
        
        networkHandler.joinClass(classId, userId: userId, context: context, success: { (result) -> Void in
            self.tabBarController?.selectedIndex = 0
            }, failure: nil, finish: nil)
    }
}
