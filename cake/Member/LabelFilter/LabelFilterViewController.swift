//
//  ChooseLabelViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/15.
//

import UIKit

class LabelFilterViewController: UIViewController {

    @IBOutlet weak var labelFilterTableView: UITableView!
        
    // 測試成員清單假資料
    private var memberLabelList = ["前場戰鬥人員", "內場支援人員", "主管大大們", "待調教的菜鳥", "神一樣的老鳥"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelFilterTableView.delegate = self
        labelFilterTableView.dataSource = self
        labelFilterTableView.register(UINib(nibName: "LabelFilterTableViewCell", bundle: nil), forCellReuseIdentifier: LabelFilterTableViewCell.indentifier)
        labelFilterTableView.allowsMultipleSelectionDuringEditing = true

    }
    
    // 關閉此View
    @IBAction func xMarkButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
}


extension LabelFilterViewController: UITableViewDelegate {
    
}

extension LabelFilterViewController: UITableViewDataSource {
    
    // cell 數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memberLabelList.count
    }
    
    // 設定cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelFilterTableViewCell", for: indexPath) as? LabelFilterTableViewCell else {
            return UITableViewCell()
        }
        
        // 設定標籤名稱
        cell.labelName.text = memberLabelList[indexPath.row]
        
        return cell
    }
    
    // 選擇cell時動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
        }else {
            cell.accessoryType = .checkmark
        }
        // 已有勾選 將選取狀態清除掉
        tableView.deselectRow(at: indexPath, animated: true)
    }

}


