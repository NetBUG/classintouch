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

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let storyboard = UIStoryboard(name:"Main", bundle: nil)
            let loginView = storyboard.instantiateViewControllerWithIdentifier("LoginView") as! EntryViewController
            // EntryViewController()
            //self.performSegueWithIdentifier("Login", sender: self)
            self.viewWillDisappear(true)
            loginView.viewWillAppear(true)
            self.tabBarController?.presentViewController(loginView, animated: false, completion: { self.viewDidDisappear(true); loginView.viewDidAppear(true)})
        }

        let networkHandler = PGNetworkHandler(baseURL: NSURL(string: "http://gw.skuuper.com"))

        networkHandler.GET("123", parameters: nil, success: { (result: AnyObject!) -> Void in
                print(result)
            }, failure: { (error: NSError!) -> Void in
                print(error)
            }) { () -> Void in
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassListCell", forIndexPath: indexPath)
        cell.textLabel?.text = "ECS 101"
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ClassSegue", sender: self)
    }

    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
