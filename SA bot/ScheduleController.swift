//
//  ViewController.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import UIKit
import Alamofire
import SwiftyJSON

class ScheduleController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewShiftDelegate {

    @IBOutlet weak var scheduleTable: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addMessageLabel: UILabel!
    
    var schedule = [Shift]()
    var pendingUpdate = false

    let uid = NSUserDefaults.standardUserDefaults().stringForKey("uid") as String!
    let refreshControl = UIRefreshControl()

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
        getSchedule()
    }

    func showOrHideAddMessage() {

        if schedule.count == 0 {
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

        // for storing the schedule as we parse it
        var newSchedule = [Shift]()

        // send the request w/ the uid
        Alamofire.request(.GET, baseURL + "schedule", parameters: ["uuid": uid])
            .responseJSON { (request, _, data, error) in

                // if there was an error, let the user know
                if (error != nil) {

                    NSLog("Networking error: \(error!.localizedDescription)")

                    self.showAlert("Networking Error", message: "Failed to download schedule")
                }
                // if no error, parse the json
                else {

                    let json = JSON(data!)

                    for shift in json["schedule"].arrayValue {

                        if let id = shift["location"].string {
                            if let begin = shift["begin"].double {
                                if let end = shift["end"].double {

                                    let newShift = Shift(place: id, start: begin, end: end)
                                    newSchedule.append(newShift)
                                }
                            }
                        }
                    }
                    // assign the new schedule to our array, reload the table
                    self.schedule = newSchedule
                    self.scheduleTable.reloadData()
                    self.showOrHideAddMessage()
                }

                // end the refresher and the loading indicator that's animating on the first load
                self.loadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
        }
    }

    // this gices the schedule to the server if we change it
    func putSchedule() {

        // builds the json for the server
        var shifts = [[String: AnyObject]]()

        // add all the current shifts
        for shift in schedule {

            var newShift: [String: AnyObject] = ["location": shift.place, "begin": shift.start, "end": shift.end]
            shifts.append(newShift)
        }

        // build the json with the uid and shifts
        let parameters: [String: AnyObject] = ["uuid": uid, "schedule": shifts]

        // send the request
        Alamofire.request(.PUT, baseURL + "schedule", parameters: parameters, encoding: .JSON)
            .response { (request, response, data, error) in

                // if we fail to send it, let the user know
                if error != nil {

                    NSLog("Networking error: \(error!.localizedDescription)")

                    self.showAlert("Networking Error", message: "Failed to send your new schedule to the server. Please check your connection, or try again later")
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
            schedule.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            showOrHideAddMessage()
            putSchedule()
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
    func showAlert(title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: Delegate functions

    // a delegate function for when a new shift is made by NewShiftController
    func newShiftWasMade(controller: NewShiftController, location: String, start: Double, stop: Double) {

        // make a new shift with the given params
        let newShift = Shift(place: location, start: start, end: stop)
        schedule.append(newShift)

        // hide the add message maybe, and reload the table
        showOrHideAddMessage()
        scheduleTable.reloadData()

        // dismiss the picker in case it's up, then dismiss the vc
        controller.dismissDatePicker()
        controller.dismissViewControllerAnimated(true, completion: nil)

        // put the new schedule
        putSchedule()
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