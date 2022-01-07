//
//  GroupMemberInfoData.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/30.
//

import Foundation

struct GroupMemberInfoData: Codable {
    
    var id: Int
    var account1: String
    var name: String
    var phone: String?
    var email: String?
    var isFullTimeJob: Bool
    var isCompanyDirector: Bool
    var holidayNumber: Int
    var salary: Int?
    var groupId: Int
}
