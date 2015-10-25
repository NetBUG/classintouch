//
//  NearbyViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    // MARK: Properties

    @IBOutlet weak var navigationUI: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()

    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.club"))
        }()

    var nearbyClasses: [AnyObject]?
    var longitude: Float?
    var latitude: Float?

    // MARK: ViewController

    override func viewWillAppear(animated: Bool) {

        let noLocation = longitude == nil || latitude == nil
        self.tableView.hidden = noLocation
        self.navigationItem.rightBarButtonItem?.enabled = !noLocation
        self.buttonLabel.hidden = !noLocation
        self.button1.hidden = !noLocation

        refresh()
    }

    func refresh() {
        guard let latitude = self.latitude else {
            return
        }

        guard let longitude = self.longitude else {
            return
        }

        self.networkHandler.nearbyCourse(longitude, latitude: latitude, context: context, success: { (result: AnyObject!) -> Void in
            self.nearbyClasses = result as? [AnyObject]
            }, failure: { (error: NSError!) -> Void in
                print(error)
            }) { () -> Void in
                self.tableView.reloadData()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController {
            if let createViewController = navigationController.topViewController as? CreateViewController {
                createViewController.longitude = longitude
                createViewController.latitude = latitude
            }
        }
    }

    @IBAction func Pressed(sender: UIButton) {
#if (TARGET_OS_IPHONE)
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
#else
        longitude = 0
        latitude = 0

        UIView.transitionWithView(self.view, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.tableView.hidden = false
            self.buttonLabel.hidden = true
            self.button1.hidden = true
            self.refresh()
            }, completion: nil)
#endif
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        if let coordinateLatitude = location?.coordinate.latitude {
            latitude = Float(coordinateLatitude)
        }

        if let coordinateLongitude = location?.coordinate.longitude {
            longitude = Float(coordinateLongitude)
        }

        UIView.transitionWithView(self.view, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.tableView.hidden = false
            self.buttonLabel.hidden = true
            self.button1.hidden = true
            self.refresh()
            }, completion: nil)
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NearbyCell", forIndexPath: indexPath)
        let nearbyClass = nearbyClasses?[indexPath.row] as? [String: AnyObject]
        cell.textLabel?.text = nearbyClass?["name"] as? String
        cell.textLabel?.font = UIFont (name: "HelveticaNeue-UltraLight", size: 30)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyClasses?.count ?? 0
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let nearbyClass = nearbyClasses?[indexPath.row] as? [String: AnyObject] else {
            return
        }

        guard let classId = nearbyClass["id"] as? NSNumber else {
            return
        }

        let userId = NSUserDefaults.standardUserDefaults().integerForKey("UserID")
        
        networkHandler.joinClass(classId, userId: userId, context: context, success: { (result) -> Void in
            self.tabBarController?.selectedIndex = 0
            }, failure: nil, finish: nil)
    }
}
