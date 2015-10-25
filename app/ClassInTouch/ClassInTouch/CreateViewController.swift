//
//  CreateViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!

    var longitude: Float?
    var latitude: Float?

    lazy var context: NSManagedObjectContext = {
        let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
        }()

    lazy var networkHandler: PGNetworkHandler = {
        return PGNetworkHandler(baseURL: NSURL(string: "http://classintouch.club"))
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneButtonTapped(sender: AnyObject) {
        guard let longitude = self.longitude else {
            return
        }

        guard let latitude = self.latitude else {
            return
        }

        guard let name = titleField.text else {
            return
        }

        self.view.userInteractionEnabled = false

        networkHandler.createClass(longitude, latitude: latitude, name: name, context: context, success: { (result) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            }, failure: nil) { () -> Void in
                self.view.userInteractionEnabled = true
        }
    }
}
