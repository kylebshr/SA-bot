//
//  LocationSelectionController.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import UIKit

class LocationSelectionController: UITableViewController {

    var delegate: LocationSelectorDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: Tableview functions

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return keys.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as! UITableViewCell

        // set the label text to the user friends name
        cell.textLabel?.text = locations[keys[indexPath.row]]

        return cell
    }

    // when it's selected, tell the delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        delegate?.locationWasSelected(self, id: keys[indexPath.row])
    }
}

// delegate function for when the location is picked
protocol LocationSelectorDelegate {

    func locationWasSelected(controller: LocationSelectionController, id: String)
}