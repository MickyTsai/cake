//
//  SetNumberOfPeopleViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/21.
//

import Foundation
import UIKit

class SetNumberOfPeopleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var scheduleClassifyList = ScheduleClassifyModel()
    
    @IBOutlet weak var setNumberOfPeopleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNumberOfPeopleTableView.dataSource = self
        setNumberOfPeopleTableView.delegate = self
        setNumberOfPeopleTableView.register(UINib(nibName: "SetNumberOfPeopleTableViewCell", bundle: nil), forCellReuseIdentifier: SetNumberOfPeopleTableViewCell.identifier)
        
        scheduleClassifyList.delegat = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scheduleClassifyList.fetchData()
    }
    
    
    
    // 關閉視窗
    @IBAction func xMarkButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    // 設定section數量（一個班別一個section：為了讓每個班別各自一張卡片效果）
    func numberOfSections(in tableView: UITableView) -> Int {
        return scheduleClassifyList.getDataCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetNumberOfPeopleTableViewCell", for: indexPath) as? SetNumberOfPeopleTableViewCell else {
            return UITableViewCell()
        }
        
        guard let data = scheduleClassifyList.getData(index: indexPath.section) else {
            
            return UITableViewCell()
        }
        
        cell.setCell(scheduleClassify: data)
        
        return cell
    }
}

extension SetNumberOfPeopleViewController: ScheduleClassifyDelegate {
    
    func didFetchData(delegateResult: Result<[ScheduleClassifyData], Error>) {
        switch delegateResult {
            
        case .success(_):
            
            self.setNumberOfPeopleTableView.reloadData()
            
        case .failure(let error):
            
            print("[getAllschedualClassify] 錯誤 \(error)")
        }
    }
    
    
}
