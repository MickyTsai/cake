//
//  LabelFilterTableViewCell.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/27.
//

import UIKit

class LabelFilterTableViewCell: UITableViewCell {
    
    
    static let indentifier = "LabelFilterTableViewCell"
    
    @IBOutlet weak var labelName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
