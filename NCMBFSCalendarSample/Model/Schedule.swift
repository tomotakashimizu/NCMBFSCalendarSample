//
//  Schedule.swift
//  NCMBFSCalendarSample
//
//  Created by 清水智貴 on 2021/07/06.
//

import UIKit

class Schedule: NSObject {
    var date: String
    var events: [String]
    var eventCount: Int
    
    init(date: String, events: [String], eventCount: Int) {
        self.date = date
        self.events = events
        self.eventCount = eventCount
    }
}
