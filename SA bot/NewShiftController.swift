//
//  NewShiftController.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import UIKit

class NewShiftController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, LocationSelectorDelegate {

    @IBOutlet weak var startTimeText: UITextField!
    @IBOutlet weak var endTimeText: UITextField!
    @IBOutlet weak var selectedLocationLabel: UILabel!

    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var selectedCell: Int?
    let startDatePicker = UIPickerView()
    let endDatePicker = UIPickerView()
    var doneBar: UIToolbar!
    var times = [Double]()
    var selectedStartTime: Double?
    var selectedEndTime: Double?
    var selectedLocation: String? = nil
    var delegate: NewShiftDelegate!


    override func viewDidLoad() {
        super.viewDidLoad()

        // each time has its own picker, set both of the delegates to self
        startDatePicker.delegate = self
        startDatePicker.dataSource = self
        endDatePicker.delegate = self
        endDatePicker.dataSource = self

        // create a done button that dismisses the time picker
        let doneBarButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "dismissDatePicker")
        // add the button to a toolbar
        doneBar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.width, 44))
        doneBar.backgroundColor = UIColor.whiteColor()
        doneBar.items = [doneBarButton]

        // set the input views and toolbar for the time cells
        startTimeText.inputView = startDatePicker
        endTimeText.inputView = endDatePicker
        endTimeText.inputAccessoryView = doneBar
        startTimeText.inputAccessoryView = doneBar
    }

    // MARK: Linked actions

    // linked to cancel. just dismisses back to the root table view
    @IBAction func cancelWasPressed(sender: AnyObject) {

        dismissDatePicker()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // Done was pressed
    @IBAction func doneWasPressed(sender: AnyObject) {


        if selectedLocation != nil && selectedStartTime != nil && selectedEndTime != nil {
            // call the delegate with the
            delegate?.newShiftWasMade(self, location: selectedLocation!, start: selectedStartTime!, stop: selectedEndTime!)
        }
        else {
            // flash missing labels red
            flashLabels()
        }
    }

    // this flashes the labels red for any missing parameters
    func flashLabels() {

        if selectedLocation == nil {

            UIView.transitionWithView(locationLabel, duration: 0, options: .TransitionCrossDissolve, animations: {
                self.locationLabel.textColor = UIColor.redColor()
                }, completion: { finished in
                    UIView.transitionWithView(self.locationLabel, duration: 2.0, options: .TransitionCrossDissolve, animations: {
                        self.locationLabel.textColor = UIColor.blackColor()
                        }, completion: nil)
            })
        }
        if selectedStartTime == nil {

            UIView.transitionWithView(startLabel, duration: 0, options: .TransitionCrossDissolve, animations: {
                self.startLabel.textColor = UIColor.redColor()
                }, completion: { finished in
                    UIView.transitionWithView(self.startLabel, duration: 2.0, options: .TransitionCrossDissolve, animations: {
                        self.startLabel.textColor = UIColor.blackColor()
                        }, completion: nil)
            })
        }
        if selectedEndTime == nil {

            UIView.transitionWithView(endLabel, duration: 0, options: .TransitionCrossDissolve, animations: {
                self.endLabel.textColor = UIColor.redColor()
                }, completion: { finished in
                    UIView.transitionWithView(self.endLabel, duration: 2.0, options: .TransitionCrossDissolve, animations: {
                        self.endLabel.textColor = UIColor.blackColor()
                        }, completion: nil)
            })
        }
    }

    // simply dismisses the picker on both time selectors
    func dismissDatePicker() {

        startTimeText.resignFirstResponder()
        endTimeText.resignFirstResponder()
    }

    // MARK: Tableview functions

    // check which cell was tapped
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        selectedCell = indexPath.row

        // disable both time inputs
        startTimeText.enabled = false
        endTimeText.enabled = false

        // dismiss the picker in case the one we click doesn't have a picker
        dismissDatePicker()

        // if it's the first picker, enable it
        if indexPath.row == 1 {
            startTimeText.enabled = true
            startTimeText.becomeFirstResponder()
        }
        // if second time picker, see if it's the first time tapping as well
        else if indexPath.row == 2 {
            endTimeText.enabled = true
            endTimeText.becomeFirstResponder()

            // if they haven't selected an end date, set the date and time to the start date and time
            // (it's probably close to the one they need to pick)
            if endDatePicker.selectedRowInComponent(0) == 0 {
                endDatePicker.selectRow(startDatePicker.selectedRowInComponent(0), inComponent: 0, animated: false)
                endDatePicker.selectRow(startDatePicker.selectedRowInComponent(1), inComponent: 1, animated: false)
                endDatePicker.selectRow(startDatePicker.selectedRowInComponent(3), inComponent: 3, animated: false)
            }
        }
    }

    // MARK: Picker view functions

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if component == 0 {
            return days.count
        }
        // 24h time
        else if component == 1 {
            return 24
        }
        // clock separator
        else if component == 2 {
            return 1
        }
        // :00, :15, :30 and :45 minute intervals
        else {
            return 4
        }
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {

        // day, hour, :, minutes
        return 4
    }

    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {

        if component == 0 {
            return 160
        }
        else if component == 1 {
            return 38
        }
        else if component == 2 {
            return 15
        }
        else {
            return 38
        }
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {

        // return the day
        if component == 0 {
            return days[row]
        }
        // return the row number formatted for 25 hour time
        else if component == 1 {
            return NSString(format: "%02d", row) as String
        }
        // time delimiter (hacky I know... is there a better way to do this?)
        else if component == 2 {
            return ":"
        }
        // the minutes
        else {
            return NSString(format: "%02d", row * 15) as String
        }
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        // get the day, hour and minute. build a string for the hour and minute
        let day = pickerView.selectedRowInComponent(0)
        let hour = pickerView.selectedRowInComponent(1)
        let minute = pickerView.selectedRowInComponent(3)
        let hourString = NSString(format: "%02d", hour)
        let minuteString = NSString(format: "%02d", minute * 15)

        // this is for the label — shows the selected day and hour
        let dateString = "\(days[day]), \(hourString):\(minuteString)"

        // this is the start cell. calculate and save the hours from 00:00 on monday
        if selectedCell == 1 {

            startTimeText.text = dateString
            selectedStartTime = Double(day * 24) + Double(hour) + (Double(minute) / 4.0)
        }
        // this is the end cell
        else if selectedCell == 2 {

            endTimeText.text = dateString
            selectedEndTime = Double(day * 24) + Double(hour) + (Double(minute) / 4.0)
        }
    }

    // MARK: Delegate stuff

    // this is a delegate function for when the location is selected from the location view
    func locationWasSelected(controller: LocationSelectionController, id: String) {

        // set the label to the user friendly location, save the ID, then pop the picker view
        selectedLocationLabel.text = locations[id]
        selectedLocation = id
        controller.navigationController?.popViewControllerAnimated(true)
    }

    // set self delegate for the location picker view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if segue.identifier == "locationSegue" {

            let vc = segue.destinationViewController as! LocationSelectionController
            vc.delegate = self
        }
    }
}

// This tells the root table when we've made a new shift
protocol NewShiftDelegate {

    func newShiftWasMade(controller: NewShiftController, location: String, start: Double, stop: Double)
}