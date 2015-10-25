//
//  AskViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class AskViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textField: UITextField!

    var selectedClass: Class?

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

    @IBAction func askButtonTapped(sender: AnyObject) {
        guard let classId = selectedClass?.id else {
            return
        }

        self.view.userInteractionEnabled = false

        let discussionTitle = titleField.text ?? "No Title"
        let discussionContent = textField.text ?? "No Text"
        let userId = NSUserDefaults.standardUserDefaults().integerForKey("UserID")

        networkHandler.createDiscussion(userId, classId: classId, title: discussionTitle, text: discussionContent, context: context, success: { (result) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
            }, failure: nil) { () -> Void in
                self.view.userInteractionEnabled = true
        }

    }

}
