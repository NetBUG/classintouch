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

    lazy var classes: [Class] = {
        do {
            return try self.context.objects("Class") as! [Class]
        } catch {
            return []
        }
        }()

    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://dev.classintouch.me"))
        }()

    // MARK: ViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        networkHandler.GET("classnearby.json", parameters: ["lon": 100, "lat": 100], to: self.context, mapping: PGNetworkMapping.classMapping, success: { (result: [AnyObject]!) -> Void in // Success block (async, will execute if the everything is correct)
                print(result)
            }, failure: { (error: NSError!) -> Void in // failure block (async, will execute if the request -> failed, JSON -> failed, or Core Data -> failed)
                print(error)
            }) { () -> Void in // finish block (async, will execute no matter the GET operation is succeed or not, always after success or failure block)
                self.tableView.reloadData()
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NearbyCell", forIndexPath: indexPath)
        cell.textLabel?.text = classes[indexPath.row].name
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            // TODO: Create class
            self.tabBarController?.selectedIndex = 0
        } else {
            self.performSegueWithIdentifier("CreateSegue", sender: self)
        }
    }
}
