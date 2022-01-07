//
//  LabelEditViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/15.
//

import UIKit
import Alamofire
import SystemConfiguration

class LabelEditViewController: UITableViewController {

    @IBOutlet var labelEditTableView: UITableView!

    private var labelListModel = LabelModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        labelEditTableView.delegate = self
        labelEditTableView.dataSource = self
        labelEditTableView.register(UINib(nibName: "LabelEditTableViewCell", bundle: nil), forCellReuseIdentifier: LabelEditTableViewCell.identifier)

        labelListModel.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 抓取群組的標籤
        labelListModel.fetchData()
    }


    //  點選右上“＋”時：新增標籤
    @IBAction func addLabelButton(_ sender: Any) {

        popUpAlert(labelText: nil, indexPath: nil)
    }

    // 點選左上“Ｘ” 關閉View
    @IBAction func xMarkButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // 顯示自訂義訊息
    private func customizeAlert(alertText: String, actionText: String) {
        
        let alert = UIAlertController(title: alertText, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionText, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }



    //  可自定義內容的alertController
    private func popUpAlert(labelText: String?, indexPath: IndexPath?) {

        let alertTitle: String

        // 如果有點選cell 就是編輯標籤 沒選時 變成新增標籤
        if labelText == nil {
            alertTitle = "新增標籤"
        }else {
            alertTitle = "編輯標籤"
        }

        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alert.addTextField {
            textField in
            textField.placeholder = "請輸入標籤名稱"
            textField.text = labelText
        }

        let okAction = UIAlertAction(title: "確認", style: .default) {
            okAction in

            // 如果輸入的欄位有值
            if let inputText = alert.textFields?[0].text {

                //  沒選cell時 新增標籤
                if labelText == nil {
                    
                    APIManager.groupAddNewLabel(labelId: nil, labelName: inputText) {
                        result in
                        switch result {
                            
                        case .success(let result):
                            
                            if result == true {
                                
                                // 重新抓取群組的標籤
                                self.labelListModel.fetchData()
                                
                                // 通知MemberList去更新
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMemberList"), object: nil)
                                
                                // 顯示成功訊息
                                self.customizeAlert(alertText: "新增標籤成功", actionText: "太棒了")
                                
                            }else {
                                
                                // 顯示失敗訊息
                                self.customizeAlert(alertText: "新增標籤失敗", actionText: "再試試")
                                
                            }
                            
                        case .failure(let error):
                            
                            print("[groupAddNewLabel] 錯誤\(error)")
                        }
                    }

                // 如果有點選cell 就是編輯標籤
                }else {

                    guard let indexPath = indexPath else { return }
                    guard let labelId = self.labelListModel.getData(index: indexPath.row)?.id else { return }
                    
                    APIManager.groupAddNewLabel(labelId: labelId, labelName: inputText) {
                        result in
                        switch result {
                            
                        case .success(let result):
                            
                            if result == true {
                                
                                // 重新抓取群組的標籤
                                self.labelListModel.fetchData()
                                
                                // 通知MemberList去更新
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMemberList"), object: nil)
                                
                                // 顯示成功訊息
                                self.customizeAlert(alertText: "編輯標籤成功", actionText: "太棒了")
                                
                                
                            }else {
                                
                                // 顯示失敗訊息
                                self.customizeAlert(alertText: "編輯標籤失敗", actionText: "再試試")
                            }
                            
                        case .failure(let error):
                            
                            print("[groupAddNewLabel] 錯誤\(error)")
                        }
                    }
                    self.labelEditTableView.reloadData()
                }
            }
        }
        alert.addAction(okAction)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    
 
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return labelListModel.getDataCount()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelEditTableViewCell", for: indexPath) as? LabelEditTableViewCell else {
            print("cell失敗")
            return UITableViewCell()
        }

        guard let singleData = labelListModel.getData(index: indexPath.row) else {
            print("singleData失敗")
            return UITableViewCell()
        }

        // 設定標籤名稱
        cell.labelName.text = singleData.customName
        
//        // 第一個標籤 群組成員不出現編輯圖示
//        if indexPath.row == 0 {
//
//            cell.editImageView.isHidden = true
//        }
        
        return cell
    }

    // cell左滑的編輯動作
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 抓取所在cell資料
        guard let singleData = labelListModel.getData(index: indexPath.row) else {
            
            return UISwipeActionsConfiguration()
        }
        
        // 編輯動作
        let editAction = UIContextualAction(style: .normal, title: "編輯") {
            _, _, completionHandler in
            self.popUpAlert(labelText: singleData.customName, indexPath: indexPath)

            // 要呼叫 completionHandler，否則點選 button 將，cell 不會回到正常顯示的狀態。
            completionHandler(true)
        }
        editAction.backgroundColor = .gray

        // 刪除動作
        let deletAction = UIContextualAction(style: .normal, title: "刪除") {
            _, _, completionHandler in
            
            guard let labelId = self.labelListModel.getData(index: indexPath.row)?.id else {
                return
            }
            
            APIManager.removeLabelInGroup(labelId: labelId) {
                result in
                switch result {
                    
                case .success(let removeLabelResult):
                    
                    if removeLabelResult == true {
                        
                        // 重新抓取群組的標籤
                        self.labelListModel.fetchData()
                        
                        // 通知MemberList去更新
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateMemberList"), object: nil)
                        
                        // 顯示成功訊息
                        let alert = UIAlertController(title: "刪除標籤成功", message: nil, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "太棒了", style: .default, handler: nil)
                        alert.addAction(okAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }else {
                        
                        // 顯示失敗訊息
                        let alert = UIAlertController(title: "刪除標籤失敗", message: nil, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "再試試", style: .default, handler: nil)
                        alert.addAction(okAction)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                
                case .failure(let error):
                    
                    print("[removeLabelInGroup] 錯誤\(error)")
                }
            }
            
            completionHandler(true)
        }
        deletAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [editAction, deletAction])
        
        // 防止滑到底觸發第一個 button 的 action
        configuration.performsFirstActionWithFullSwipe = false
        
//        // 第一個標籤 群組成員 不能編輯
//        if indexPath.row == 0 {
//            return nil
//        }

        return configuration
    }

}

// 當抓取labelListModel完成後收到通知的動作
extension LabelEditViewController: LabelModelDelegate {

    func didFetchData(delegateResult: Result<[LabelData], Error>) {
        
        switch delegateResult {

        case .success(_):
            
            self.labelEditTableView.reloadData()
            print("[allLabelInGroup] 更新labelEditTableView完成")

        case .failure(let error):

            print("[allLabelInGroup] 錯誤\(error)")
        }
    }


}
