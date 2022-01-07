//
//  MemberListCollectionViewCell.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/21.
//

import UIKit
import SDWebImage

class MemberListCollectionViewCell: UICollectionViewCell {

    static let identifier = "MemberListCollectionViewCell"
    
    @IBOutlet weak var memberImage: UIImageView!
    
    @IBOutlet weak var memberName: UILabel!
    
    // 設定cell內資料
    func setCell(name: String) {
        
        // 設定頭像
//        guard let url = URL(string: imageUrl) else { return }
//        memberImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.fill"))
        
        // 設定名稱
        memberName.text = name
    }
}
