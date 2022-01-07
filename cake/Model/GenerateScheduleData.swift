//
//  GenerateScheduleData.swift
//  cake
//
//  Created by TSAI MICKY on 2022/1/5.
//

import Foundation

struct GenerateScheduleDate: Codable {
    var id: Int
    var groupId: Int
    var schedualTableId: Int
    var dateOfMonth: Int
    var classifyName: String
    var numberOfStaff: Int
    var workStartHour: Int
    var workStatrMinute: Int
    var workOverHour: Int
    var workOverMinute: Int
    var restStartHour: Int
    var restStartMinute: Int
    var restOverHour: Int
    var restOverMinute: Int
    var remarkContent: String
    
}
