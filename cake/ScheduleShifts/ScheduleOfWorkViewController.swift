//
//  SchrduleOfWorkViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/15.
//

import UIKit
import FSCalendar

class ScheduleOfWorkViewController: UIViewController {
    
    // 上方顯示已複選的日期
    @IBOutlet weak var chooseDayCollectionView: UICollectionView!
    
    // 下方顯示 現有可選班別
    @IBOutlet weak var scheduleListOfWorkTableView: UITableView!
    
    var chooseDate = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        chooseDayCollectionView.dataSource = self
        chooseDayCollectionView.delegate = self
        chooseDayCollectionView.register(UINib(nibName: "ChooseDayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ChooseDayCollectionViewCell.identifier)
        
        scheduleListOfWorkTableView.dataSource = self
        scheduleListOfWorkTableView.delegate = self
        scheduleListOfWorkTableView.register(UINib(nibName: "ScheduleListOfWorkTableViewCell", bundle: nil), forCellReuseIdentifier: ScheduleListOfWorkTableViewCell.identifier)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
    // 左上x點選後 退回前畫面
    @IBAction func xMarkButton(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ScheduleOfWorkViewController: UICollectionViewDelegate {

}

extension ScheduleOfWorkViewController: UICollectionViewDataSource {
    
    // 選了多少個日期（目前假資料）
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chooseDate.count
    }
    
    // sectionHeader設定
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ChooseDayHeader", for: indexPath) as? ChooseDayHeaderViewController else {
            return UICollectionReusableView()
        }
        
        return headerView
    }
    
    // Cell設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseDayCollectionViewCell", for: indexPath) as? ChooseDayCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.layer.cornerRadius = 5
        // 設定每個cell顯示的日期
        chooseDate = chooseDate.sorted()
        cell.dateLabel.text = chooseDate[indexPath.row]
        
        return cell
    }
}

extension ScheduleOfWorkViewController: UICollectionViewDelegateFlowLayout {
    
    // cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 25)
    }
}

extension ScheduleOfWorkViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension ScheduleOfWorkViewController: UITableViewDataSource {
    
    // 幾個section 3為暫時假資料
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // 每個section有幾個cell (為了達到每個班別一張卡片效果 一個section只放一個cell)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleListOfWorkTableViewCell", for: indexPath) as? ScheduleListOfWorkTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        // 點選Cell後出現勾選圖示 再次點擊 取消勾選
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
        }else {
            cell.accessoryType = .checkmark
        }
        // 已有勾選 將選取狀態清除掉
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        // 要將tableViewCell選擇的項目（班別）存起來
        
    }
}
