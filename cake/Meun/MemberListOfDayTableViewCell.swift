//
//  MemberListOfDayTableViewCell.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/22.
//

import UIKit

class MemberListOfDayTableViewCell: UITableViewCell {

    static let identifier = "MemberListOfDayTableViewCell"
    
    @IBOutlet weak var memberNameLabel: UILabel!
    
    @IBOutlet weak var memberImage: UIImageView!
    
    func setCell(memberData: SchedualNormalAccountResultData) {
        
        memberNameLabel.text = memberData.name
    }

}
