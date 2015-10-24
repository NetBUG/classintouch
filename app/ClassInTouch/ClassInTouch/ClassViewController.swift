//
//  ClassViewController.swift
//  ClassInTouch
//
//  Created by Justin Jia on 10/24/15.
//  Copyright © 2015 ClassInTouch. All rights reserved.
//

import UIKit

class ClassViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties

    @IBOutlet weak var tableView: UITableView!

    var context: NSManagedObjectContext?
    var registeredClass: Class?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = registeredClass?.name
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassCell", forIndexPath: indexPath)
        let discussion: Discussion? = registeredClass?.discussions?[indexPath.row] as? Discussion
        cell.textLabel?.text = discussion?.title
        cell.detailTextLabel?.text = discussion?.content
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rows = registeredClass?.discussions?.count else {
            return 0
        }
        return rows
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("QuestionSegue", sender: self)
    }

}
