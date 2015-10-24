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

    @IBOutlet weak var button1: UIButton!
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
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.me"))
        }()

    // MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // case of normal image
        let image1 = UIImage(named: "LonelyCircle.pdf")!
        self.button1.setImage(image1, forState: UIControlState.Normal)

        networkHandler.nearbyCourse(100, latitude: 100, context: context, success: nil, failure: nil) { () -> Void in
            self.tableView.reloadData()
        }
    }
    @IBAction func Pressed(sender: UIButton) {
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
