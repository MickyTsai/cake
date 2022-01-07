//
//  ScheduleViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/14.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class ScheduleViewControllor: UIViewController {
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    @IBOutlet weak var addScheduleButton: UIButton!
    
    private var scheduleClassifyList = ScheduleClassifyModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.register(UINib(nibName: "ScheduleListTableViewCell", bundle: nil), forCellReuseIdentifier: ScheduleListTableViewCell.identifier)
        
        scheduleClassifyList.delegat = self
        
        // SetScheduleViewController 裡的saveButton（新增或編輯班別是否成功的通知）
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateSchedualClassify"), object: nil, queue: nil) {
            _ in
            
            // 收到編輯或新增班別成功通知後 更新scheduleTableView
            self.scheduleClassifyList.fetchData()
            print("scheduleTableView已更新")
        }
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scheduleClassifyList.fetchData()
    }
    

    
    // 前往新增 班別
    @IBAction func addScheduleButton(_ sender: Any) {
        
        let setScheduleStoryBoard = UIStoryboard(name: "SetScheduleView", bundle: .main)
        if let setScheduleVC = setScheduleStoryBoard.instantiateViewController(withIdentifier: "SetScheduleView") as? SetScheduleViewController {
            
            present(setScheduleVC, animated: true, completion: nil)
        }
    }
}


// 設定已有班別清單
extension ScheduleViewControllor: UITableViewDelegate {
    
    // cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension ScheduleViewControllor: UITableViewDataSource {
    
    // 設定section數量（一個班別一個section：為了讓每個班別各自一張卡片效果）
    func numberOfSections(in tableView: UITableView) -> Int {
        return scheduleClassifyList.getDataCount()
    }
    
    // 設定section內有幾個cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    //  設定cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleListTableViewCell", for: indexPath) as? ScheduleListTableViewCell else {
            
            return UITableViewCell()
        }
        
        guard let data = scheduleClassifyList.getData(index: indexPath.section) else {
            
            return UITableViewCell()
        }
        
        cell.setCell(scheduleClassify: data)
        
        return cell
    }
    
    // 點選cell 後跳至編輯班別頁面
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        let editScheduleStoryBoard = UIStoryboard(name: "EditScheduleView", bundle: .main)
        if let editScheduleVC = editScheduleStoryBoard.instantiateViewController(withIdentifier: "EditScheduleView") as? EditScheduleViewController {
            
            // 要抓點選的cell 將資料帶入轉跳的班別頁面
            guard let singleScheduleClassify = scheduleClassifyList.getData(index: indexPath.section) else {
                return
            }
            
            // 儲存目前所選班別
            editScheduleVC.scheduleClassifyData = singleScheduleClassify

            present(editScheduleVC, animated: true, completion: nil)
        }
    }
    
    
}

extension ScheduleViewControllor: ScheduleClassifyDelegate {
    
    func didFetchData(delegateResult: Result<[ScheduleClassifyData], Error>) {
        switch delegateResult {
            
        case .success(_):
            
            self.scheduleTableView.reloadData()
            
        case .failure(let error):
            
            print("[getAllschedualClassify] 錯誤 \(error)")
        }
    }
    
    
}
