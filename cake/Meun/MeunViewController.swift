//
//  MeunViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/14.
//

import Foundation
import UIKit
import FSCalendar
import SwiftKeychainWrapper

class MeunViewController: UIViewController {
    
    @IBOutlet weak var scheduleShiftsButton: UIButton!
    
    @IBOutlet weak var addScheduleButton: UIButton!
    
    @IBOutlet weak var setScheduleButton: UIButton!
    
    @IBOutlet weak var memberButton: UIButton!
    
    @IBOutlet weak var chartButton: UIButton!
    
    @IBOutlet weak var calendarView: FSCalendar!
    
    @IBOutlet weak var memberListOfDayTableView: UITableView!
    
    @IBOutlet weak var nowGroupName: UILabel!
    
    @IBOutlet weak var nowScheduleName: UILabel!
    
    @IBOutlet weak var nowDateLabel: UILabel!
    
    // 已設定公休日的日期
    private var publicHolidayList = [Date]()
    
    // 已生成班表資料
    private var schedualNormalAccountModel = SchedualNormalAccountModel()
    
    // 目前主畫面顯示的是哪天
    private var nowDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCalendar()
        
        memberListOfDayTableView.delegate = self
        memberListOfDayTableView.dataSource = self
        memberListOfDayTableView.register(UINib(nibName: "MemberListOfDayTableViewCell", bundle: nil), forCellReuseIdentifier: MemberListOfDayTableViewCell.identifier)
        
        schedualNormalAccountModel.delegate = self
        
        // 以今天是哪天為預設日期
        getNowDate()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 關掉 回到上一頁的back按鈕
        navigationItem.setHidesBackButton(true, animated: true)
        
        // 顯示目前所在群組
        nowGroupName.text = "目前群組：\(nowGroup())"
        
        // 顯示目前所在班表
        nowScheduleName.text = "目前班表：\(nowSchedule())"
        
        // 顯示目前日期
        
        // 讀取已生成的班表
        schedualNormalAccountModel.fetchData()
        
        // 檢查帳號是否為管理者(true或false會自動記錄在KeychainWrapper： isCompanyDirectorKey)
        APIManager.getIsCompanyDirector()
        
        // 如果非主管 隱藏 “設定班表” 與 ”新增班表按鈕“
        if KeychainWrapper.standard.bool(forKey: "isCompanyDirectorKey") == false {
            
            addScheduleButton.isHidden = true
            setScheduleButton.isHidden = true
        }
        
        // 讀取已存的公休日
        loadPublicHolidayList()
        
        
 
    }
    
    // 日曆設定
    private func setCalendar() {
        
        // 月曆顯示切換語言
        calendarView.locale = Locale(identifier: "zh_cn")
        // 月曆的星期顯示格式變更
        calendarView.appearance.caseOptions = .weekdayUsesSingleUpperCase
        // 第一天是星期幾(星期一是2)
        calendarView.appearance.calendar.firstWeekday = 2
        // 隱藏其他月份日期
        calendarView.appearance.calendar.placeholderType = .none
        
        calendarView.delegate = self
        calendarView.dataSource = self
    }
    
    // 取得目前所在群組
    private func nowGroup() -> String {
        
        guard let groupName = KeychainWrapper.standard.string(forKey: "nowGroupNameKey") else {
            return ""
        }
        return groupName
    }
    
    // 取得目前所在班表
    private func nowSchedule() -> String {
        
        guard let scheduleDate = KeychainWrapper.standard.string(forKey: "nowScheduleDateKey") else {
            
            return ""
        }
        return scheduleDate
    }
    
    // 取得今天在哪天
    private func getNowDate() {
        
        let timeStamp = Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let dateString = formatter.string(from: date)

        // 現在所在日期更新
        nowDate = date
        
        // 主畫面上方日期更新
        nowDateLabel.text = dateString
    }
    
    // 轉換當天日期為Int
    private func dateToInt() -> Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        guard let date = self.nowDate else { return 0 }
        
        let dateString = dateFormatter.string(from: date)
        guard let dateInt = Int(dateString) else { return 0 }
        
        // 清單從0開始 日期從1開始 所以要減一
        return dateInt - 1
    }
    
    
    // 創建新班表
    @IBAction func newScheduleButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "CreatScheduleView", bundle: .main)
        if let creatScheduleVC = storyboard.instantiateViewController(withIdentifier: "CreatScheduleView") as? CreatScheduleViewController {

            navigationController?.pushViewController(creatScheduleVC, animated: true)
        }
    }
    
    
    // 前往設定班表頁面
    @IBAction func setScheduleButton(_ sender: Any) {
        
        let scheduleStoryBoard = UIStoryboard(name: "ScheduleView", bundle: .main)
        if let scheduleVC = scheduleStoryBoard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarViewController {

            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
    
    
    // 前往成員頁面
    @IBAction func memberButton(_ sender: Any) {
         
        let memberStoryBoard = UIStoryboard(name: "MemberView", bundle: .main)
        if let memberVC = memberStoryBoard.instantiateViewController(withIdentifier: "MemberView") as? MemberViewController {
            
            navigationController?.pushViewController(memberVC, animated: true)
        }
    }
    
    
    // 前往劃班表頁面
    @IBAction func scheduleShiftsButton(_ sender: Any) {
        
        let scheduleShiftsStoryBoard = UIStoryboard(name: "ScheduleShiftsView", bundle: .main)
        if let scheduleShiftsVC = scheduleShiftsStoryBoard.instantiateViewController(withIdentifier: "ScheduleShiftsView") as? ScheduleShiftsViewController {
            
            navigationController?.pushViewController(scheduleShiftsVC, animated: true)
        }
    }
    
    
    // 前往統計頁面
    @IBAction func chartButton(_ sender: Any) {
        
        let statisticStoryBoard = UIStoryboard(name: "StatisticsView", bundle: .main)
        if let statisticsVC = statisticStoryBoard.instantiateViewController(withIdentifier: "StatisticsView") as? StatisticsViewController {
            
            navigationController?.pushViewController(statisticsVC, animated: true)
        }
    }
    
    
    // 月曆檢視顯示
    @IBAction func calendarViewButton(_ sender: Any) {
        
        memberListOfDayTableView.isHidden = true
        calendarView.isHidden = false
    }
    
    // 讀取已存的公休日
    private func loadPublicHolidayList() {
        
        guard let list =  (UserDefaults.standard.object(forKey: "publicHolidayListKey")) as? [Date]  else { return }
        publicHolidayList = list
        
    }
    
    // 顯示自訂義訊息
    private func customizeAlert(alertText: String, actionText: String) {
        
        let alert = UIAlertController(title: alertText, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionText, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension MeunViewController: FSCalendarDelegate {
    
    // 點選日期
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        
        // 檢查所選日是不是公休日
        if self.publicHolidayList.contains(date) {
            
            customizeAlert(alertText: "公休日無上班人員", actionText: "確認")
            calendarView.deselect(date)
            return
            
        }
        
        // 檢查是不是選到其他月份
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let dateString = formatter.string(from: date)

        // 現在所在日期更新
        nowDate = date
        
        // 主畫面上方日期更新
        nowDateLabel.text = dateString
        
        
        // 切換回清單
        calendarView.isHidden = true
        memberListOfDayTableView.isHidden = false
        
        // 檢查所選日期是否有班表（滑動其他月份時）
        
        // 將選擇的日期存起來
        
        // 再次讀取已生成的班表 更新tableView (所選日期的成員)
        schedualNormalAccountModel.fetchData()
        
    }
}

extension MeunViewController: FSCalendarDataSource {
    
    // 設定日曆事件自訂義圖示
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        // 顯示公休日
        if self.publicHolidayList.contains(date) {
            return UIImage(systemName: "moon.zzz.fill")
        }
        
        return nil
        
    }
}


extension MeunViewController: UITableViewDelegate {
    
    // Cell的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension MeunViewController: UITableViewDataSource {
    
    // Section數量 看當天有幾個班別
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // 取得所選日期的Int
        let dateInt = dateToInt()
        
        let scheduleClassifyCount = schedualNormalAccountModel.getScheduleClassifyCountOfDate(date: dateInt)
        print("\(dateInt + 1)號 班別數量\(scheduleClassifyCount)")
        
        return scheduleClassifyCount
    }
    
    // 一個班別（Section）的成員（Cell）數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 取得所選日期的Int
        let dateInt = dateToInt()
        
        let memberCount = schedualNormalAccountModel.getMemberCountOfDateOfScheduleClassify(date: dateInt, scheduleClassifyIndex: section)
        print("\(dateInt + 1)號 班別\(section) 有\(memberCount)個成員")
        
        return memberCount
    }
    
    // 設定Header標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // 取得所選日期的Int
        let dateInt = dateToInt()
        
        let scheduleClassifyList = schedualNormalAccountModel.getscheduleClassifyListOfDate(date: dateInt)
         
        guard let scheduleClassifyName = scheduleClassifyList?[section][0].classifyName else { return "" }
        return scheduleClassifyName
    }
    
    
    // 設定Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberListOfDayTableViewCell", for: indexPath) as? MemberListOfDayTableViewCell else {
            return UITableViewCell()
        }
        
        // cell內 image是依照cell大小比例改變， 故作圓依照抓取圓的寬一半
        cell.memberImage.layer.cornerRadius = cell.memberImage.frame.width / 2
        
        // 取得所選日期的Int
        let dateInt = dateToInt()
        
        guard let memberData = schedualNormalAccountModel.getMemberDataOfDateOfLabel(date: dateInt,
                                                                               lebelIndex: indexPath.section,
                                                                               memberIndex: indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.setCell(memberData: memberData)
        
        return cell
    }
    
}

// 抓取已生成班表 抓取結果通知
extension MeunViewController: SchedualNormalAccountModelDelegate {
    
    func didFetchData(delegateResult: Result<[[[SchedualNormalAccountResultData]]], Error>) {
        
        switch delegateResult {
        
        case .success(_):
            
            memberListOfDayTableView.reloadData()
            print("memberListOfDayTableView 更新完成 ")
            
        case .failure(let error):
            
            print("[getRosterSchedualNormalAccountResult] 錯誤 \(error)")
        }
    }
    
    
}
