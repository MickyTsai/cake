//
//  ScheduleListOfWorkTableViewCell.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/22.
//

import UIKit

class ScheduleListOfWorkTableViewCell: UITableViewCell {
    
    static let identifier = "ScheduleListOfWorkTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if (selected) {
            backgroundColor = UIColor(displayP3Red: 211/255, green: 232/255, blue: 238/255, alpha: 1)
        }
    }
    
}
