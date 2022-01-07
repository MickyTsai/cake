//
//  PreviewViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/23.
//

import Foundation
import UIKit
import FSCalendar
import SwiftKeychainWrapper
import Alamofire

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var previewCalendar: FSCalendar!
    
    private var publicholidaylist = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPublicHoliday()
        previewCalendar.reloadData()
    }
    
    
    private func setCalendar() {
        
        // 月曆顯示切換語言
        previewCalendar.locale = Locale(identifier: "zh_cn")
        // 月曆的星期顯示格式變更
        previewCalendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        // 第一天是星期幾(星期一是2)
        previewCalendar.appearance.calendar.firstWeekday = 2
        // 隱藏其他月份日期
        previewCalendar.appearance.calendar.placeholderType = .none
        
        previewCalendar.delegate = self
        previewCalendar.dataSource = self
    }
    
    // 生成班表
    @IBAction func generateScheduleButton(_ sender: Any) {
        
        // 目前班表 ID
        guard let scheduleId = KeychainWrapper.standard.integer(forKey: "nowScheduleIdKey") else { return }
        // 取得目前班別ID清單
        let schedualClassifyIdList = getSchedualClassifyIdList()
        
        // 生成班表-步驟1（每日班別生成）
        APIManager.generateSchedule(schedualClassifyIdList: schedualClassifyIdList) {
            result in
            switch result {
            
            case .success(let data):
                
                // 將班表資料存下來
                UserDefaults.standard.set(data, forKey: "scheduleData\(scheduleId)")
                
                // 生成班表-步驟2（每日每班別配近成員）
                APIManager.autoRosterSchedual {
                    result in
                    switch result {
                     
                    case .success(let boolResult):
                        
                        if boolResult == true {
                            
                            self.customizeAlert(alertText: "生成班表成功", actionText: "太好了")
                        }else {
                            self.customizeAlert(alertText: "生成班表失敗", actionText: "確認")
                        }
                        
                        
                    case .failure(let error):
                        
                        self.customizeAlert(alertText: "生成班表失敗", actionText: "確認")
                        print("[autoRosterSchedual] 錯誤 \(error)")
                    }
                }

            case .failure(let error):
                
                self.customizeAlert(alertText: "生成班表失敗", actionText: "確認")
                print("[generateSchedule] 錯誤 \(error)")
            }
        }
    }
    
    // 取得目前班別ID清單
    private func getSchedualClassifyIdList() -> [Int] {
        
        var schedualClassifyIdList = [Int]()
        
        APIManager.getAllschedualClassify {
            result in
            switch result {
            
            case .success(let dataList):
                
                for data in dataList {
                    
                    schedualClassifyIdList.append(data.id)
                }
                
                print("[getAllschedualClassify] schedualClassifyIdList清單儲存成功")
                
            case .failure(let error):
                
                print("[getAllschedualClassify] 錯誤 \(error)")
            }
        }
        
        return schedualClassifyIdList
    }
    
    // 讀取已存的公休日
    private func loadPublicHoliday() {
        
        guard let list =  (UserDefaults.standard.object(forKey: "publicHolidayListKey")) as? [Date]  else { return }
        publicholidaylist = list
    }
    
    // 顯示自訂義訊息
    private func customizeAlert(alertText: String, actionText: String) {
        
        let alert = UIAlertController(title: alertText, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionText, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension PreviewViewController: FSCalendarDelegate {
    
}

extension PreviewViewController: FSCalendarDataSource {
    
    // 設定日曆事件自訂義圖示
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        
        // 公休日圖示
        if self.publicholidaylist.contains(date) {
            return UIImage(systemName: "moon.zzz.fill")
        }
        return nil
        
    }
}
