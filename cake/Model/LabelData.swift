//
//  LabelData.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/29.
//

import Foundation

struct LabelData: Codable {
    var id: Int
    var groupId: Int
    var customName: String
    var rosterPriority: Int?
    var memberList: [MemberData]?
  
}

