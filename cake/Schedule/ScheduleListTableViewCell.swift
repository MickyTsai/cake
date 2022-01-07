//
//  ScheduleListTableViewCell.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/21.
//

import UIKit

class ScheduleListTableViewCell: UITableViewCell {
    
    static let identifier = "ScheduleListTableViewCell"
    
    @IBOutlet weak var scheduleLabelName: UILabel!
    
    @IBOutlet weak var totalTime: UILabel!
    
    @IBOutlet weak var workTime: UILabel!
    
    @IBOutlet weak var breakTime: UILabel!
    
    @IBOutlet weak var breakTimeTitle: UILabel!
    
    @IBOutlet weak var numberOfStaffLabel: UILabel!
    
    func setCell(scheduleClassify: ScheduleClassifyData) {
        
        scheduleLabelName.text = scheduleClassify.customName
        
        let workStartHour = scheduleClassify.workStartHour
        let workStartMin = scheduleClassify.workStatrMinute
        let workEndHour = scheduleClassify.workOverHour
        let workEndMin = scheduleClassify.workOverMinute
        
        let restStartHour = scheduleClassify.restStartHour
        let restStartMin = scheduleClassify.restStartMinute
        let restEndHour = scheduleClassify.restOverHour
        let restEndMin = scheduleClassify.restOverMinute
        
        let numberOfStaff = scheduleClassify.numberOfStaff
        
        // 上班時間顯示
        workTime.text = "\(workStartHour):\(workStartMin) ~ \(workEndHour):\(workEndMin)"
        
        // 休息時間顯示
        
        if restStartHour == 0, restEndHour == 0 {
            
            breakTime.text = "無"

        }else {
            
            breakTime.text = "\(restStartHour):\(restStartMin) ~ \(restEndHour):\(restEndMin)"
        }
        
        // 總時數顯示
        var totalMin: Int
        var totalHour: Int
        
        totalHour = workEndHour - workStartHour
        
        if (workStartMin - workEndMin) < 0 {
            totalMin = workStartMin + 60 - workEndMin
            totalHour -= 1
        }else {
            totalMin = workStartMin - workEndMin
        }
        
        if totalMin == 0 {
            totalTime.text = "時數：\(totalHour)小時"
        }else {
            totalTime.text = "時數：\(totalHour).\(totalMin / 10)小時"
        }
        
        // 員工人數顯示
        numberOfStaffLabel.text = "人數：\(numberOfStaff) 人"
        
        // 判斷休息時間是否扣除時數
        
    }
    
}
