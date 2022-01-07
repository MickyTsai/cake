//
//  ScheduleData.swift
//  cake
//
//  Created by TSAI MICKY on 2022/1/3.
//

import Foundation

struct ScheduleData: Codable {
    
    var id: Int
    var groupId: Int
    var yearMonth: String
    var customName: String?
    var remarkContent: String?
    
}
