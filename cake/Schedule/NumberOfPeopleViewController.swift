//
//  NumberOfPeopleViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/14.
//

import UIKit
import FSCalendar

class NumberOfPeopleViewController: UIViewController {
    
    @IBOutlet weak var numberOfPeopleCalendar: FSCalendar!
    
    // 存放日曆 已選日期
    private var chooseDate = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 讀取已存的公休日
        loadPublicHoliday()
        numberOfPeopleCalendar.reloadData()
    }
    
    private func setCalendar() {
        
        // 月曆顯示切換語言
        numberOfPeopleCalendar.locale = Locale(identifier: "zh_cn")
        // 月曆的星期顯示格式變更
        numberOfPeopleCalendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        // 第一天是星期幾(星期一是2)
        numberOfPeopleCalendar.appearance.calendar.firstWeekday = 2
        // 複選日期
        numberOfPeopleCalendar.allowsMultipleSelection = true
        // 隱藏其他月份日期
        numberOfPeopleCalendar.appearance.calendar.placeholderType = .none
        
        numberOfPeopleCalendar.delegate = self
        numberOfPeopleCalendar.dataSource = self
    }
    
    // 讀取已存的公休日
    private func loadPublicHoliday() {
        
        guard let list =  (UserDefaults.standard.object(forKey: "publicHolidayListKey")) as? [Date]  else { return }
        chooseDate = list
        print(chooseDate)
        
        for date in chooseDate {
            numberOfPeopleCalendar.select(date)
        }
    }
    
    @IBAction func setPublicHolidayButton(_ sender: Any) {
        
        // 檢查是否日曆有選日期 如沒選取日期 彈出警告視窗
        if chooseDate.isEmpty {
            noChooseDateAlert()
            return
        }

        // 呼叫API上傳設定公休日
        setSchedulePublicHoliday()
    }
    
    
    
    // 如沒選取日期 彈出警告視窗
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
   
    
    // 呼叫API
    private func setSchedulePublicHoliday() {
        
        // 先將原先選擇日期清單 轉為[Int] 因為API輸入要求
        var publicHolidayListInt = [Int]()
        for date in chooseDate {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            let dateString = dateFormatter.string(from: date)
            
            guard let dateInt = Int(dateString) else { return }
            
            publicHolidayListInt.append(dateInt)
        }
        
        APIManager.setSchedulePublicHoliday(publicHolidayList: publicHolidayListInt) {
            result in
            switch result {
            case .success(let boolResult):
                
                if boolResult == true {
                    
                    // 成功設定 日曆畫面重新載入
                    self.numberOfPeopleCalendar.reloadData()
                    
                    // 儲存已選日期清單
                    UserDefaults.standard.set(self.chooseDate, forKey: "publicHolidayListKey")
                    print("publicHolidayList 已儲存")
                    
                    // 顯示成功 提示訊息
                    self.customizeAlert(alertText: "設定成功", actionText: "太好了")

                }else {
                    
                    self.customizeAlert(alertText: "設定失敗", actionText: "確認")
                }
                
            case .failure(let error):
                
                print("[setSchedulePublicHoliday] 錯誤\(error)")
            }
        }
    }

}


extension NumberOfPeopleViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        chooseDate.append(date)

    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        guard let dateAt = chooseDate.firstIndex(of: date) else { return }
        chooseDate.remove(at: dateAt)
        
    }
}

extension NumberOfPeopleViewController: FSCalendarDataSource {
    
    // 設定日曆事件自訂義圖示
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        if self.chooseDate.contains(date) {
            return UIImage(systemName: "moon.zzz.fill")
        }
        return nil
        
    }
}




