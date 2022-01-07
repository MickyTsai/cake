//
//  JoinGroupListData.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/29.
//

import Foundation

struct JoinGroupListData: Codable {
    var groupId: Int
    var groupName: String
    var announcement: String?
    
    enum CodingKeys: String, CodingKey{
        case groupId = "id"
        case groupName = "groupName"
        case announcement = "announcement"
    }
}

