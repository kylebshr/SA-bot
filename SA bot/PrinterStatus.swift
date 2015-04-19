//
//  Status.swift
//  SA bot
//
//  Created by Kyle Bashour on 4/17/15.
//
//

import Foundation

// Simple class for each printer status

class PrinterStatus {

    var name: String!
    var statusMessage: String!
    var statusColor: Int!

    init(name: String, message: String, color: Int) {

        self.name = name
        self.statusMessage = message
        self.statusColor = color
    }
}