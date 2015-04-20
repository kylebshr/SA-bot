//
//  ViewController.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import UIKit
import Parse

class ScheduleController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewShiftDelegate {

    @IBOutlet weak var scheduleTable: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addMessageLabel: UILabel!
    
    var schedule = [Shift]()
    var pendingUpdate = false

    let refreshControl = UIRefreshControl()
    let statusQuery = PFQuery(className: "Shift")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the cell
        scheduleTable.registerNib(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")

        // add pull to refresh and hook it up
        scheduleTable.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "refreshSchedule", forControlEvents: .ValueChanged)

        // set up autolayout height for cells
        scheduleTable.estimatedRowHeight = 62
        scheduleTable.rowHeight = UITableViewAutomaticDimension

        // get the schedule on loading the view
        refreshControl.beginRefreshing()
        getSchedule()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        getSchedule()
    }

    func showOrHideAddMessage() {

        if schedule.count == 0 {
            addMessageLabel.text = "Use the + button to add shifts\nto your schedule"
            addMessageLabel.hidden = false
        }
        else {
            addMessageLabel.hidden = true
        }
    }

    // MARK: Linked actions

    // edit/done button was pressed
    @IBAction func enterEditMode(sender: UIBarButtonItem) {

        // if we're editing, make us not-editing; if we're not editing, make us editing
        if scheduleTable.editing {

            scheduleTable.setEditing(false, animated: true)
            sender.title = "Edit"
            sender.style = UIBarButtonItemStyle.Plain
        }
        else {

            scheduleTable.setEditing(true, animated: true)
            sender.title = "Done"
            sender.style = UIBarButtonItemStyle.Done
        }
    }

    // MARK: Networking

    // just calls get schedule, might do other stuff here though
    func refreshSchedule() {

        getSchedule()
    }

    // get's the current schedule from the server
    func getSchedule() {

        if let user = PFUser.currentUser() {

            if !pendingUpdate {

                pendingUpdate = true

                // for storing the schedule as we parse it
                var newSchedule = [Shift]()

                statusQuery.whereKey("User", equalTo: user)
                statusQuery.orderByAscending("StartTime")

                statusQuery.findObjectsInBackgroundWithBlock({ (objects, error) in

                    self.loadingIndicator.stopAnimating()

                    if error == nil {
                        for shift in objects! {

                            if let
                                id = shift["Place"] as? String,
                                start = shift["StartTime"] as? Double,
                                end = shift["EndTime"] as? Double
                            {
                                let newShift = Shift(place: id, start: start, end: end, shift: shift as? PFObject)
                                newSchedule.append(newShift)
                            }
                        }

                        self.schedule = newSchedule
                        self.showOrHideAddMessage()

                        self.scheduleTable.beginUpdates()
                        self.scheduleTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                        self.scheduleTable.endUpdates()
                    }
                    else {
                        NSLog("Error: \(error?.localizedDescription)")
                        self.showAlert("Failed to download schedule", message: nil)
                    }

                    var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {

                        self.refreshControl.endRefreshing()
                    })
                    
                    self.pendingUpdate = false
                })
            }
        }
    }

    // MARK: Table functions

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return schedule.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = scheduleTable.dequeueReusableCellWithIdentifier("ScheduleCell") as! ScheduleCell

        // get the shift for that schedule from the array
        let item = schedule[indexPath.row]

        // change the text appropiately 
        // (if the place has a name in locations, set it to that, else just set it to the ID)
        cell.locationLabel.text = locations[item.place] ?? item.place
        cell.timeLabel.text = getDateString(item.start, end: item.end)
        
        return cell
    }


    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        return true
    }

    // when a cell is deleted, this gets called
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == UITableViewCellEditingStyle.Delete {

            // remove the item from our array, animate the deletion, and put the new schedule
            schedule[indexPath.row].pfShift?.deleteInBackgroundWithBlock(nil)
            schedule.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            showOrHideAddMessage()
        }
    }


    // MARK: Misc functions

    // We're using doubles where 1 = 1 hour to keep track of shifts. 
    // this takes a start and end time and returns a 24 hour time range
    func getDateString(start: Double, end: Double) -> String {

        // get the day
        let dayIndex = Int(start) / 24

        // get the hour for start and end
        var startTime = start % 24
        var endTime = end % 24

        // format the start and end time
        let startString = NSString(format: "%02d:%02d", Int(startTime), Int((startTime % 1) * 60))
        let endString = NSString(format: "%02d:%02d", Int(endTime), Int((endTime % 1) * 60))

        // return a day and time in the form "Day, 00:00 - 00:00"
        return "\(days[dayIndex]), \(startString) - \(endString)"
    }

    // shows a generic UIAlert with an OK button and the given title and message
    func showAlert(title: String, message: String?) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: Delegate functions

    // a delegate function for when a new shift is made by NewShiftController
    func newShiftWasMade(controller: NewShiftController, location: String, start: Double, stop: Double) {

        // make a new shift with the given params
        let newShift = Shift(place: location, start: start, end: stop, shift: nil)
        schedule.append(newShift)

        // save the new shift to parse
        let saveShift = PFObject(className: "Shift")
        saveShift["StartTime"] = start
        saveShift["EndTime"] = stop
        saveShift["Place"] = location
        saveShift["User"] = PFUser.currentUser()
        saveShift.saveInBackgroundWithBlock({ (success, error) in

            if let error = error {
                
                NSLog("Networking error: \(error.localizedDescription)")
                self.showAlert("Networking Error", message: "Failed to save your new shift. Please check your internet connection, or try again later")
            }
        })

        // hide the add message maybe, and reload the table
        showOrHideAddMessage()
        scheduleTable.reloadData()

        // dismiss the picker in case it's up, then dismiss the vc
        controller.dismissDatePicker()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    // Sets the delegate to self when we're making a new shift
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "newShiftSegue" {

            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.viewControllers[0] as! NewShiftController
            vc.delegate = self
        }
    }
}