//
//  ScheduleClassifyData.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/30.
//

import Foundation

struct ScheduleClassifyData: Codable {
    var id: Int
    var groupId: Int
    var customName: String
    var numberOfStaff: Int
    
    var workStartHour: Int
    var workStatrMinute: Int
    
    var workOverHour: Int
    var workOverMinute: Int
    
    var restStartHour: Int
    var restStartMinute: Int
    
    var restOverHour: Int
    var restOverMinute: Int
    
    var remarkContent: String?
}

