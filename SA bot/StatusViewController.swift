//
//  StatusViewController.swift
//  SA bot
//
//  Created by Kyle Bashour on 4/17/15.
//
//

import UIKit
import Parse

class StatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var statusTable: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!

    var statuses = [PrinterStatus]()
    var pendingUpdate = false
    var issuesOnly = false
    var connectedRecently = false

    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the cell
        statusTable.registerNib(UINib(nibName: "StatusCell", bundle: nil), forCellReuseIdentifier: "StatusCell")

        // add pull to refresh and hook it up
        statusTable.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "updateStatus", forControlEvents: .ValueChanged)

        // set up autolayout height for cells
        statusTable.estimatedRowHeight = 62
        statusTable.rowHeight = UITableViewAutomaticDimension

        // get the schedule on loading the view
        refreshControl.beginRefreshing()
        updateStatus()

        // set the settings button image
        settingsButton.image = Assets.imageOfSettings
        settingsButton.title = ""
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        updateStatus()
    }

    func showOrHideMessage() {

        if statuses.count == 0 {
            messageLabel.hidden = false
            if !connectedRecently {
                messageLabel.text = "We're having trouble connecting to the printers. Check back later!"
            }
            else if issuesOnly {
                messageLabel.text = "Everything looks good! There aren't any printers with issues right now."
            }
        }
        else {
            messageLabel.hidden = true
            messageLabel.text = ""
        }
    }

    func updateStatus() {

        if !pendingUpdate {

            issuesOnly = NSUserDefaults.standardUserDefaults().boolForKey("issuesOnly")

            pendingUpdate = true

            var updatedStatuses = [PrinterStatus]()
            let statusQuery = PFQuery(className: "PrinterStatus")

            if issuesOnly {
                statusQuery.orderByAscending("Number")
                statusQuery.orderByDescending("StatusColor,PrinterName")
                statusQuery.whereKey("StatusColor", greaterThan: 0)
            }
            else {
                statusQuery.orderByAscending("PrinterName,Number")
            }

            statusQuery.findObjectsInBackgroundWithBlock({ (objects, error) in

                self.loadingIndicator.stopAnimating()

                if error == nil {
                    for status in objects! {

                        if let
                            name = status["PrinterName"] as? String,
                            message = status["StatusMessage"] as? String,
                            color = status["StatusColor"] as? Int,
                            location = locations[name]
                        {
                            var finalName = location
                            if let pn = status["Number"] as? Int {
                                finalName += " \(pn)"
                            }
                            let newStatus = PrinterStatus(name: finalName, message: message, color: color)
                            updatedStatuses.append(newStatus)
                        }
                    }

                    self.statuses = updatedStatuses
                    self.connectedRecently = true
                    self.showOrHideMessage()

                    self.statusTable.beginUpdates()
                    self.statusTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                    self.statusTable.endUpdates()
                }
                else {
                    NSLog("Error: \(error?.localizedDescription)")
                    self.connectedRecently = false
                }

                var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {

                    self.refreshControl.endRefreshing()
                })
                
                self.showOrHideMessage()
                self.pendingUpdate = false
            })
        }
    }


    // MARK: TableView Functions

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return statuses.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = statusTable.dequeueReusableCellWithIdentifier("StatusCell") as! StatusCell

        // get the status for the index
        let item = statuses[indexPath.row]

        // update the cell
        cell.nameLabel.text = item.name
        cell.messageLabel.text = item.statusMessage

        if item.statusColor == 3 {
            cell.statusImage.image = Assets.imageOfRedstatus
        }
        else if item.statusColor == 2 {
            cell.statusImage.image = Assets.imageOfYellowstatus
        }
        else if item.statusColor == 1 {
            cell.statusImage.image = Assets.imageOfGreystatus
        }
        else if item.statusColor == 0 {
            cell.statusImage.image = Assets.imageOfGreenstatus
        }


        return cell
    }

}
