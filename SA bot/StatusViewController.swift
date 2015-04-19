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

    var statuses = [PrinterStatus]()
    var pendingUpdate = false

    let refreshControl = UIRefreshControl()
    let statusQuery = PFQuery(className: "PrinterStatus")

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
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        updateStatus()
    }

    func showOrHideMessage() {

        if statuses.count == 0 {
            messageLabel.hidden = false
        }
        else {
            messageLabel.hidden = true
        }
    }

    func updateStatus() {

        if !pendingUpdate {

            pendingUpdate = true

            var updatedStatuses = [PrinterStatus]()

            statusQuery.orderByAscending("PrinterName,Number")
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
                    self.showOrHideMessage()
                    self.statusTable.reloadData()
                }
                else {
                    NSLog("Error: \(error?.localizedDescription)")
                }

                var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {

                    self.refreshControl.endRefreshing()
                })
                
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

        if item.statusColor == 2 {
            cell.statusImage.image = Assets.imageOfRedstatus
        }
        else if item.statusColor == 1 {
            cell.statusImage.image = Assets.imageOfYellowstatus
        }
        else if item.statusColor == 0 {
            cell.statusImage.image = Assets.imageOfGreenstatus
        }
        else {
            cell.statusImage.image = Assets.imageOfGreystatus
        }

        return cell
    }

}
