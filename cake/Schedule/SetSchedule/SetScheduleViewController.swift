//
//  SetScheduleViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/14.
//

import UIKit

class SetScheduleViewController: UIViewController {

    @IBOutlet weak var xMarkButton: UIButton!
    
    @IBOutlet weak var schedualClassifyName: UITextField!
    
    @IBOutlet weak var workStartTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var workEndTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var restStartTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var restEndTimeDatePicker: UIDatePicker!
    
    @IBOutlet weak var remarkTextView: UITextView!

    @IBOutlet weak var numberOfStaffTextField: UITextField!
    
    var schedualClassifyId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        // 班別名稱 如果沒輸入 跳出警告
        let customName = schedualClassifyName.text ?? ""
        
        if schedualClassifyName.text == "" {
            
            let alert = UIAlertController(title: "沒有輸入名稱", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
            
        }
        
        // 設定班別需求人數
        let numberOfStaff = 5
        
        
        // 擷取DatePicker所選時間
        let workStartHour = setTimeHour(date: workStartTimeDatePicker.date)
        let workStatrMinute = setTimeMin(date: workStartTimeDatePicker.date)
        
        let workOverHour = setTimeHour(date: workEndTimeDatePicker.date)
        let workOverMinute = setTimeMin(date: workEndTimeDatePicker.date)
        
        let restStartHour = setTimeHour(date: restStartTimeDatePicker.date)
        let restStartMinute = setTimeMin(date: restStartTimeDatePicker.date)
        
        let restOverHour = setTimeHour(date: restEndTimeDatePicker.date)
        let restOverMinute = setTimeMin(date: restEndTimeDatePicker.date)
        
        let remark = remarkTextView.text
         
        // 呼叫API
        APIManager.createNewSchedualClassify(customName: customName,
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
                    
                    print("[createNewSchedualClassify] 收到通知更新")
                    // 通知ScheduleViewControllor裡的scheduleTableView去更新
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSchedualClassify"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                }else {
                    
                    // 新增失敗提示
                    let alert = UIAlertController(title: "新增失敗", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            case .failure(let error):
                
                print("[createNewSchedualClassify] 錯誤 \(error)")

            }
        }
    }

    @IBAction func xMarkButton(_ sender: Any) {
        dismiss(animated: true)
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
