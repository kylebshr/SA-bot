//
//  File.swift
//  SA bot
//
//  Created by Kyle Bashour on 2/27/15.
//
//

import Foundation
import Parse

// simple class for keeping track of shift objects

class Shift {

    var place: String!
    var start: Double!
    var end: Double!
    var pfShift: PFObject?

    init(place: String?, start: Double, end: Double, shift: PFObject?) {

        // this may or may not exist
        if place != nil {
            self.place = place
        }
        else {
            self.place = "Unknown!"
        }
        self.start = start
        self.end = end
        self.pfShift = shift
    }
}