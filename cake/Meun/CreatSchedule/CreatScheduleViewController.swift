//
//  CreatScheduleViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/23.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class CreatScheduleViewController: UIViewController {
    
    @IBOutlet weak var creatScheduleCollectionView: UICollectionView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creatScheduleCollectionView.dataSource = self
        creatScheduleCollectionView.delegate = self
        creatScheduleCollectionView.register(UINib(nibName: "CreatScheduleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CreatScheduleCollectionViewCell.indentifer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 關掉 回到上一頁的back按鈕
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    //  抓當前時間（年/月）
    func getYear() -> Int? {
        
        let timeStamp = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: timeStamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        let yearInt = Int(dateFormatter.string(from: date))
        
        
        return yearInt
    }
    
    func getMonth() -> Int? {
        
        let timeStamp = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: timeStamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        
        let monthInt = Int(dateFormatter.string(from: date))
        
        
        
        return monthInt
    }
    
    // 轉跳主畫面
    func goMeunView() {
        
        let storyboard = UIStoryboard(name: "MeunView", bundle: .main)
        if let meunVC = storyboard.instantiateViewController(withIdentifier: "MeunView") as? MeunViewController {

            // API要載入當前班表的人員清單（日檢視）
            
            navigationController?.pushViewController(meunVC, animated: true)
        }
    }

}

extension CreatScheduleViewController: UICollectionViewDelegate {
    
    // 點選Cell後動作
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 先抓點選的Cell的年月
        var yearLabelInt = getYear() ?? 0
        var monthLabelInt = (getMonth() ?? 0) + indexPath.row
        
        // 如果已經超過12月 重新回到1月
        if monthLabelInt > 12 {
            monthLabelInt = 0 + indexPath.row
            yearLabelInt += 1
        }
        let date = "\(yearLabelInt)-\(monthLabelInt)-01"
        print(date)
        
        // 要等API跑完才轉跳主畫面 否則API還沒跑完 執行緒已經轉跳主畫面
        let group = DispatchGroup()
        
        DispatchQueue.global().async {
            
            group.enter()
            
            // 創建班表
            APIManager.createNewSchedualTable(date: date) {
                result in
                switch result {
                case .success(let result):
                    
                    if result == true {
                        
                        // 紀錄目前所在班表
                        if KeychainWrapper.standard.set("\(yearLabelInt)-\(monthLabelInt)",
                                                        forKey: "nowScheduleDateKey") {
                            
                            print("[createSchedualTable] 儲存目前班表成功：\(date)")
                        }
                    }
                    group.leave()
                 
                case .failure(let error):
                    
                    print("[createSchedualTable] 錯誤：\(error)")
                    group.leave()
                }
            }
            
            group.wait()
            
            group.notify(queue: DispatchQueue.main) {
                print("通知轉跳主畫面")
                // 轉跳主畫面
                self.goMeunView()
            }
        }
        
    }
}

extension CreatScheduleViewController: UICollectionViewDataSource {
    
    // cell數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    // cell設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreatScheduleCollectionViewCell", for: indexPath) as? CreatScheduleCollectionViewCell  else {
            return UICollectionViewCell()
        }
        
        // 設定cell顯示的年月
        var yearLabelInt = getYear() ?? 0
        var monthLabelInt = (getMonth() ?? 0) + indexPath.row
        
        // 如果已經超過12月 重新回到1月
        if monthLabelInt > 12 {
            monthLabelInt = 0 + indexPath.row
            yearLabelInt += 1
        }
        
        cell.yearLabel.text = "\(yearLabelInt)"
        cell.monthLabel.text = "\(monthLabelInt)月"
        
        return cell
    }
}

extension CreatScheduleViewController: UICollectionViewDelegateFlowLayout {
    
    // cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 50)
    }
    
    // 設定每個 selction 之間 上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
