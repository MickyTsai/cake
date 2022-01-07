//
//  EditScheduleViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2022/1/3.
//

import Foundation
import UIKit

class EditScheduleViewController: UIViewController {
    
    @IBOutlet weak var scheduleClassifyName: UITextField!

    @IBOutlet weak var remarkTextView: UITextView!
    
    @IBOutlet weak var workStartTime: UIDatePicker!
    
    @IBOutlet weak var workEndTime: UIDatePicker!
    
    @IBOutlet weak var restStartTime: UIDatePicker!
    
    @IBOutlet weak var restEndTime: UIDatePicker!
    
    // 所選cell的班別data
    var scheduleClassifyData: ScheduleClassifyData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let data = scheduleClassifyData else {
            return
        }
        setScheduleClassify(data: data)
//        let scheduleClassifyId = data.id
    }
    
    // 設置已存在班別資料
    private func setScheduleClassify(data: ScheduleClassifyData) {
        
        scheduleClassifyName.text = data.customName
        remarkTextView.text = data.remarkContent
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    // 關閉畫面
    @IBAction func xMarkButton(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    // 儲存編輯
    @IBAction func saveEditButton(_ sender: Any) {
        
        guard let data = scheduleClassifyData else {
            return
        }
        
        // 班別名稱 如果沒輸入 跳出警告
        let customName = scheduleClassifyName.text ?? ""
        
        if scheduleClassifyName.text == "" {
            
            let alert = UIAlertController(title: "沒有輸入名稱", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
            
        }
        
        // 設定班別需求人數
        let numberOfStaff = 5
        
        
        // 擷取DatePicker所選時間
        let workStartHour = setTimeHour(date: workStartTime.date)
        let workStatrMinute = setTimeMin(date: workStartTime.date)
        
        let workOverHour = setTimeHour(date: workEndTime.date)
        let workOverMinute = setTimeMin(date: workEndTime.date)
        
        let restStartHour = setTimeHour(date: restStartTime.date)
        let restStartMinute = setTimeMin(date: restStartTime.date)
        
        let restOverHour = setTimeHour(date: restEndTime.date)
        let restOverMinute = setTimeMin(date: restEndTime.date)
        
        let remark = remarkTextView.text
         
        // 呼叫API
        APIManager.editSchedualClassify(id: data.id,
                                        customName: customName,
                                        numberOfStaff: numberOfStaff,
                                        workStartHour: workStartHour,
                                        workStatrMinute: workStatrMinute,
                                        workOverHour: workOverHour,
                                        workOverMinute: workOverMinute,
                                        restStartHour: restStartHour,
                                        restStartMinute: restStartMinute,
                                        restOverHour: restOverHour,
                                        restOverMinute: restOverMinute,
                                        remarkContent: remark) {
                            
            result in
            switch result {
            case .success(let boolResult):
                
                if boolResult == true {
                    
                    print("[editSchedualClassify] 收到通知更新")
                    // 通知ScheduleViewControllor裡的scheduleTableView去更新
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSchedualClassify"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                    
                }else {
                    
                    // 編輯失敗提示
                    let alert = UIAlertController(title: "編輯失敗", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            case .failure(let error):
                
                print("[editSchedualClassify] 錯誤 \(error)")

            }
        }
    }
    
    
    
    // 刪除班別
    @IBAction func deleteButton(_ sender: Any) {
        
        guard let data = scheduleClassifyData else {
            return
        }
        
        // 呼叫API
        APIManager.deleteScheduleClassify(scheduleClassifyId: data.id) {
            result in
            switch result {
            case .success(let boolResult):
                
                if boolResult == true {
                    
                    print("[deleteScheduleClassify] 收到通知更新")
                    // 通知ScheduleViewControllor裡的scheduleTableView去更新
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSchedualClassify"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                    
                }else {
                    
                    // 刪除失敗提示
                    let alert = UIAlertController(title: "刪除失敗", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }

            case .failure(let error):

                print("[deleteScheduleClassify] 錯誤 \(error)")
            }
        }
    }
    
    
    // 將DatePicker所選的時間 擷取出小時的Int
    private func setTimeHour(date: Date) -> Int{
        
        let dateFormatterHour = DateFormatter()
        dateFormatterHour.dateFormat = "HH"
        let hourTime = dateFormatterHour.string(from: date)
        
        guard let hourTimeInt = Int(hourTime) else {
            
            return 0
        }
        
        return hourTimeInt
    }
    
    // 將DatePicker所選的時間 擷取出分鐘的Int
    private func setTimeMin(date: Date) -> Int {
        
        let dateFormatterMin = DateFormatter()
        dateFormatterMin.dateFormat = "mm"
        let minTime = dateFormatterMin.string(from: date)
        
        guard let minTimeInt = Int(minTime) else {
            
            return 0
        }
        
        return minTimeInt
    }
}
