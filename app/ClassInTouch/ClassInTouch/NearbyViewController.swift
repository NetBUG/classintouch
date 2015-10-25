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

    @IBOutlet weak var navigationUI: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var blueNeighborBig: UIImageView!

    @IBOutlet weak var blueNeighborSmall: UIImageView!
    @IBOutlet weak var button1: UIButton!
    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()

    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.club"))
        }()

    var classes: [Class]?

    // MARK: ViewController

    override func viewDidLoad() {
        // Set up the button
        super.viewDidLoad()
        // case of normal image
        let image1 = UIImage(named: "Circle")!
        self.button1.setImage(image1, forState: UIControlState.Normal)
            //Hide the bar's + button, and temporarily name
            //self.navigationUI.rightBarButtonItem.
    }

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
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.blueNeighborBig.hidden=true
        self.blueNeighborSmall.hidden=true
        
        self.buttonLabel.hidden = false
    }
    
    @IBAction func Pressed(sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.blueNeighborBig.hidden=false
        self.blueNeighborSmall.hidden=false
        
        self.buttonLabel.hidden = true
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
