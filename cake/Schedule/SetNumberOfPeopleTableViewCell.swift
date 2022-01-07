//
//  SetNumberOfPeopleTableViewCell.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/21.
//

import UIKit

class SetNumberOfPeopleTableViewCell: UITableViewCell {
    
    static let identifier = "SetNumberOfPeopleTableViewCell"
    
    @IBOutlet weak var setNumberTextField: UITextField!
    
    @IBOutlet weak var scheduleLabelName: UILabel!
    
    @IBOutlet weak var workTime: UILabel!
    
    @IBOutlet weak var breakTime: UILabel!
    
    
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
        
        // 上班時間顯示
        workTime.text = "\(workStartHour):\(workStartMin) ~ \(workEndHour):\(workEndMin)"
        
        // 休息時間顯示
        
        if restStartHour == 0, restEndHour == 0 {
            
            breakTime.text = "無"

        }else {
            
            breakTime.text = "\(restStartHour):\(restStartMin) ~ \(restEndHour):\(restEndMin)"
        }
        
        
        
        // 判斷休息時間是否扣除時數
        
    }
}
