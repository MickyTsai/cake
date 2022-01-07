//
//  ScheduleShiftsViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/15.
//

import UIKit
import FSCalendar
import SwiftKeychainWrapper

class ScheduleShiftsViewController: UIViewController {

    @IBOutlet weak var scheduleOfWorkButton: UIButton!
    
    @IBOutlet weak var scheduleOfDayOffButton: UIButton!
    
    @IBOutlet weak var calendarView: FSCalendar!
    
    @IBOutlet weak var scheduleMonthLabel: UILabel!
    
    // 存放日曆 已選日期
    private var chooseDate = [Date]()
    
    // 已設定公休日的日期
    private var publicHolidayList = [Date]()
    
    // 測試日曆事件假資料
    private var scheduleShifts = ["2021/12/27", "2021/12/16", "2021/12/27", "2021/12/27", "2021/12/22", "2021/12/22"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 讀取已存的劃班/休日期清單
        loadPublicHoliday()
        loadPublicHolidayList()
        calendarView.reloadData()
    }
    
    
    
    // 日曆設定
    private func setCalendar() {
        
        // 月曆顯示切換語言
        calendarView.locale = Locale(identifier: "zh_cn")
        // 月曆的星期顯示格式變更
        calendarView.appearance.caseOptions = .weekdayUsesSingleUpperCase
        // 第一天是星期幾(星期一是2)
        calendarView.appearance.calendar.firstWeekday = 2
        // 隱藏日曆header左右的月份顯示
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        // 複選日期
        calendarView.allowsMultipleSelection = true
        // 隱藏其他月份日期
        calendarView.appearance.calendar.placeholderType = .none


        calendarView.delegate = self
        calendarView.dataSource = self
    }
    
    // 清除已選劃休
    @IBAction func clearButton(_ sender: Any) {
        
        // 清除已存的點選日期
        chooseDate.removeAll()
        // 清除日曆顯示已選日期
        for date in calendarView.selectedDates {
            calendarView.deselect(date)
        }
        
        // 上傳
        uploadSchedule()

        calendarView.reloadData()  
    }
    
    // 前往統計畫面
    @IBAction func chartButton(_ sender: Any) {
        
        let statisticStoryBoard = UIStoryboard(name: "StatisticsView", bundle: .main)
        if let statisticsVC = statisticStoryBoard.instantiateViewController(withIdentifier: "StatisticsView") as? StatisticsViewController {
            
            navigationController?.pushViewController(statisticsVC, animated: true)
        }
    }
    
    
    // 前往劃班頁面
//    @IBAction func scheduleOfWorkButton(_ sender: Any) {
//
//        // 檢查是否日曆有選日期
//        if chooseDate.isEmpty {
//            noChooseDateAlert()
//            return
//        }
//
//        let storyBoard = UIStoryboard(name: "ScheduleOfWorkView", bundle: .main)
//        if let scheduleOfWorkVC = storyBoard.instantiateViewController(withIdentifier: "ScheduleOfWorkView") as? ScheduleOfWorkViewController {
//
//            // 要把日曆以勾選日期丟過去
////            scheduleOfWorkVC.chooseDate = chooseDate
//
//            present(scheduleOfWorkVC, animated: true, completion: nil)
//        }
//    }
    
    
    // 上傳劃班/休
    @IBAction func upLoadSchedule(_ sender: Any) {
        
        // 檢查是否有選日期
        if chooseDate.isEmpty {
            noChooseDateAlert()
            return
        }
        
        // 上傳
        uploadSchedule()
    }
    
    // 上傳劃休
    private func uploadSchedule() {
        
        // 取得選擇日期清單[Int]
        let chooseHolidayList = dateListToIntList(chooseDateList: chooseDate)
        
        // 取得目前帳號
        guard let account = KeychainWrapper.standard.string(forKey: "accountKey") else { return }
        
        // 取得目前帳號id
        APIManager.getAccountId(account: account) {
            result in
            switch result {
                
            case .success(let accountId):
                
                // 呼叫上傳劃班/休 API
                APIManager.staffChooseHoliday(accountId: accountId, chooseHolidayList: chooseHolidayList) {
                    result in
                    switch result {
                        
                    case .success(let boolResult):
                        
                        if boolResult == true {
                            
                            // 成功設定 日曆畫面重新載入
                            self.calendarView.reloadData()
                            
                            // 儲存已劃班/休日期清單
                            UserDefaults.standard.set(self.chooseDate, forKey: "chooseHolidayListKey")
                            print("chooseHolidayList 已儲存")
                            
                            // 顯示成功 提示訊息
                            self.customizeAlert(alertText: "設定成功", actionText: "太好了")

                        }else {
                            
                            self.customizeAlert(alertText: "設定失敗", actionText: "確認")
                        }
                        
                    case .failure(let error):
                        
                        print("[staffChooseHoilday] 錯誤 \(error)")
                    }
                    
                
                }
                
            case .failure(let error):
                
                print("[getAccountId] 錯誤 \(error)")
            }
        }
    }
    
    // 先將原先選擇日期清單 轉為[Int] 因為API輸入要求
    private func dateListToIntList(chooseDateList: [Date]) -> [Int] {
        
        var chooseHolidayListInt = [Int]()
        for date in chooseDateList {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            let dateString = dateFormatter.string(from: date)
            
            guard let dateInt = Int(dateString) else { return [] }
            
            chooseHolidayListInt.append(dateInt)
        }
        return chooseHolidayListInt
    }
    
    // 讀取已存的劃班/休日期清單
    private func loadPublicHoliday() {
        
        guard let list =  (UserDefaults.standard.object(forKey: "chooseHolidayListKey")) as? [Date]  else { return }
        chooseDate = list
        
        for date in chooseDate {
            calendarView.select(date)
        }
    }
    
    
    // 沒選取日期 彈出警告視窗
    private func noChooseDateAlert() {
        
        let alertController = UIAlertController(title: "沒選擇日期", message: "請於日曆中點選日期（可複選）", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "了解", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // 顯示自訂義訊息
    private func customizeAlert(alertText: String, actionText: String) {
        
        let alert = UIAlertController(title: alertText, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionText, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // 讀取已存的公休日
    private func loadPublicHolidayList() {
        
        guard let list =  (UserDefaults.standard.object(forKey: "publicHolidayListKey")) as? [Date]  else { return }
        publicHolidayList = list
        
    }
}


extension ScheduleShiftsViewController: FSCalendarDelegate {
    
    // 選擇日期 將已選日期存入List
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        // 檢查所選日是不是公休日
        if self.publicHolidayList.contains(date) {
            
            customizeAlert(alertText: "公休日不可劃休", actionText: "確認")
            calendarView.deselect(date)
            return
            
        }else {
            
            chooseDate.append(date)
        }
        
    }
    
    // 取消選擇日期 要從已選日期清單中移除
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        guard let dateAt = chooseDate.firstIndex(of: date) else { return }
        chooseDate.remove(at: dateAt)
        
    }
    
    // 設定日曆事件
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let dateString = formatter.string(from: date)
        
        var count = 0

        if self.scheduleShifts.contains(dateString) {
            count += 3
        }
        return count
    }
    
}
    
extension ScheduleShiftsViewController: FSCalendarDataSource {
    
    // 設定日曆事件自訂義圖示
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        // 已儲存的劃休
        if self.chooseDate.contains(date) {
            return UIImage(systemName: "person.crop.circle.badge.moon")
        }
        
        // 已設定的公休日
        if self.publicHolidayList.contains(date) {
            return UIImage(systemName: "moon.zzz.fill")
        }
        
        return nil
    }
    
}
