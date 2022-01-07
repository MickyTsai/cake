//
//  MemberViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/14.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import Alamofire
import SystemConfiguration

class MemberViewController: UIViewController {
    
    
    @IBOutlet weak var addMemberButton: UIBarButtonItem!
    
    @IBOutlet weak var labelFilterButton: UIButton!
    
    @IBOutlet weak var setLabelButton: UIButton!
    
    @IBOutlet weak var memberListCollectionView: UICollectionView!
        
    
    // 標籤清單
    private var labelListModel = LabelModel()
    
    // 成員清單
    private var allGroupMemberModelList = MemberModel()
    
    // 每個標籤內成員清單
//    private var everyLabelHaveAccountList = [[MemberData]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 上方標籤成員清單CollectionView
        memberListCollectionView.delegate = self
        memberListCollectionView.dataSource = self
        memberListCollectionView.register(UINib(nibName: "MemberListCollectionViewCell",
                                                bundle: nil),
                                          forCellWithReuseIdentifier: MemberListCollectionViewCell.identifier)
        
        labelListModel.delegate = self
        allGroupMemberModelList.delegate = self
        
        // 觀察 新增或編輯標籤 成功需要更新的通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateMemberList"), object: nil, queue: nil) {
            _ in
            
            // 收到編輯或新增標籤成功通知後 更新memberListCollectionView
            self.labelListModel.fetchData()
            self.allGroupMemberModelList.fetchData()
            print("memberListCollectionView已更新")
        }
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 抓取標籤清單
        labelListModel.fetchData()
        
        // 抓取群組所有成員
        allGroupMemberModelList.fetchData()
        
        // 顯示各標籤內的成員
        
    }

    // 取得目前群組所有成員
    
    // 顯示自訂義訊息
    private func customizeAlert(alertText: String, actionText: String) {
        
        let alert = UIAlertController(title: alertText, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionText, style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // 彈出選擇標籤頁面 過濾顯示成員
    @IBAction func labelFilterButton(_ sender: Any) {
        
        let labelFilterStoryBoard = UIStoryboard(name: "LabelFilterView", bundle: .main)
        if let labelFilterVC = labelFilterStoryBoard.instantiateViewController(withIdentifier: "LabelFilterNavigationController") as? LabelFilterNavigationController {
            
           present(labelFilterVC, animated: true, completion: nil)
        }
    }
    
    // 前往設定標籤頁面
    @IBAction func setLabelButton(_ sender: Any) {
        
        let labelEditStoryBoard = UIStoryboard(name: "LabelEditView", bundle: .main)
        if let labelEditVC = labelEditStoryBoard.instantiateViewController(withIdentifier: "LabelEditNavigationController") as? LabelEditNavigationController {
            
           present(labelEditVC, animated: true, completion: nil)
        }
    }
    
    
    // 跳出刪除成員操作視窗
    @IBAction func removeMemberButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: "刪除成員", message: "請輸入帳號名稱將成員“移出”群組", preferredStyle: .alert)
        
        alertController.addTextField {
            textField in
            textField.placeholder = "帳號名稱"
        }
        
        // 點選“確認” 呼叫API將成員移出群組
        let okAction = UIAlertAction(title: "確認", style: .default) {
            _ in
            guard let userAccount = alertController.textFields?[0].text else { return }
            
            // 呼叫移出群組API
            self.removeGroupMember(userAccount: userAccount)
            
        }
        alertController.addAction(okAction)
        
        let canelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(canelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 呼叫移出群組API
    private func removeGroupMember(userAccount: String) {
        
        // 先透過帳號抓accountId
        APIManager.getAccountId(account: userAccount) {
            result in
            switch result {
                
            case .success(let accountId):
                
                // 先取得目前所在群組
                guard let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
                    
                    print("[removeGroupMember] 找不到groupId")
                    return
                }
                
                // 將帳號移出群組
                APIManager.removeGroupMember(accountId: accountId, groupId: groupId) {
                    result in
                    switch result {
                        
                    case .success(let result):
                        
                        if result == true {
                            // 顯示成功訊息
                            self.customizeAlert(alertText: "移出群組成功", actionText: "太棒了")
                            
                        }else {
                            
                            // 顯示失敗訊息
                            self.customizeAlert(alertText: "移出群組失敗", actionText: "再試試")
                        }
                        
                    case .failure(let error):
                        
                        // 顯示失敗訊息
                        self.customizeAlert(alertText: "移出群組失敗", actionText: "再試試")
                        print("[removeGroupMember] 錯誤：\(error)")
                    }
                }
                
            case .failure(let error):
                
                // 顯示失敗訊息
                self.customizeAlert(alertText: "移出群組失敗", actionText: "再試試")
                print("[getAccountId] 失敗\(error)")
            }
        }
    }
    
    // 跳出新增成員操作視窗
    @IBAction func addMemberButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: "新增成員", message: "請輸入帳號名稱將成員加入群組", preferredStyle: .alert)
        
        alertController.addTextField {
            textField in
            textField.placeholder = "帳號名稱"
        }
        
        // 點選“確認” 呼叫API將成員新增至群組
        let okAction = UIAlertAction(title: "確認", style: .default) {
            _ in
            guard let userAccount = alertController.textFields?[0].text else { return }
            
            // 呼叫加入群組API
            self.inviteGroup(userAccount: userAccount)
            
        }
        alertController.addAction(okAction)
        
        let canelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(canelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 呼叫加入群組API
    private func inviteGroup(userAccount: String) {
        
        // 先透過帳號抓accountId
        APIManager.getAccountId(account: userAccount) {
            result in
            switch result {
                
            case .success(let accountId):
                
                // 先取得目前所在群組
                guard let groupId = KeychainWrapper.standard.integer(forKey: "nowGroupIdKey") else {
                    
                    print("[inviteGroup] 找不到groupId")
                    return
                }
                
                // 將帳號加入群組
                APIManager.inviteGroup(accountId: accountId, groupId: groupId) {
                    result in
                    switch result {
                        
                    case .success(let result):
                        
                        if result == true {
                            
                            // 顯示成功訊息
                            self.customizeAlert(alertText: "加入群組成功", actionText: "太棒了")
                            
                        }else {
                            
                            // 顯示失敗訊息
                            self.customizeAlert(alertText: "加入群組失敗", actionText: "再試試")
                        }
                        
                    case .failure(let error):
                        
                        // 顯示失敗訊息
                        self.customizeAlert(alertText: "加入群組失敗", actionText: "再試試")
                        print("[inviteGroup] 錯誤：\(error)")
                    }
                }
                
            case .failure(let error):
                
                // 顯示失敗訊息
                self.customizeAlert(alertText: "加入群組失敗", actionText: "再試試")
                print("[getAccountId] 失敗\(error)")
            }
        }
    }
    
}


// 設定memberList的CollectionView
extension MemberViewController: UICollectionViewDelegate {
    
    // 點選成員cell後 跳轉成員詳細資料畫面
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard(name: "MemberDetilView", bundle: .main)
        
        if let memberDetilVC = storyBoard.instantiateViewController(withIdentifier: "MemberDetilView") as? MemberDetilViewController {
            
            
            // 將點選的Cell 的帳號Id傳遞至memberDetilVC
            guard let memberListOfSingleLabel = labelListModel.getMemberList(index: indexPath.section) else {

                return
            }
            
            let singleMember = memberListOfSingleLabel[indexPath.row]
            
            memberDetilVC.accountId = singleMember.accountId
            
            present(memberDetilVC, animated: true, completion: nil)
        }
    }
}


extension MemberViewController: UICollectionViewDataSource {
    
    // section 分類數量
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        // 依照標籤數量
        let sectionNumber = labelListModel.getDataCount()
        print("共\(sectionNumber)個section")
        return sectionNumber
    }
    
    // 每個section 內有多少cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
        guard let singleLabel = labelListModel.getData(index: section) else {
            
            return 0
        }
        
        // 依照當個標籤內成員數量
        let cellCount: Int
        
        guard let memberList = singleLabel.memberList else {
            
            cellCount = 0
            print("section： \(section) 為空")
            return cellCount
        }
        
            
        cellCount = memberList.count
        print("section： \(section) 有 \(cellCount)個cell")
        
        return cellCount
        
    }
    
    // Section的Header設定
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: "Header",
                                                                               for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        
        // 設定header的標籤
        headerView.labelName.text = labelListModel.getData(index: indexPath.section)?.customName

        return headerView
    }
    
    // Cell設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberListCollectionViewCell", for: indexPath) as? MemberListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let memberListOfSingleLabel = labelListModel.getMemberList(index: indexPath.section) else {
            
            return UICollectionViewCell()
        }
        

            
        let singleMember = memberListOfSingleLabel[indexPath.row]
        cell.setCell(name: singleMember.name)
    
        return cell
    }
    
     
    
    
}
// 設定 CollectionView Cell 與 Cell 之間的間距 等等
extension MemberViewController: UICollectionViewDelegateFlowLayout {
    
    // cell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    // 設定每個 selction 之間 上、下、左、下間的距離
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 20, bottom: 10, right: 20)
    }
    
    // LineSpacing:滑動方向為「垂直」的話即「上下Cell」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // InteritemSpacing:滑動方向為「垂直」的話即「左右Cell」的間距(預設為重直)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// 抓取標籤清單 完成後動作
extension MemberViewController: LabelModelDelegate {
    
    func didFetchData(delegateResult: Result<[LabelData], Error>) {
        
        switch delegateResult {
            
        case .success(let data):
            
            let group = DispatchGroup()
            
            DispatchQueue.global().async {
                
                // 每個標籤都要去抓取一次有多少成員
                for (index, singleLabel) in data.enumerated() {
                    
                    print("抓取 \(singleLabel.customName) - id：\(singleLabel.id) 內成員")
                    group.enter()
                    
                    // 抓取指定標籤內 成員清單
                    APIManager.getAllHaveLabelAccount(labelId: singleLabel.id) {
                        result in
                        switch result {

                        case .success(let memberDataList):

                            self.labelListModel.setMemberList(index: index, memberList: memberDataList)
                            
                            print("標籤： \(singleLabel.customName) 內成員已存入清單 共\(memberDataList.count)個")
                            group.leave()

                        case .failure(let error):

                            print("[getAllHaveLabelAccount] 失敗 \(error)")
                            group.leave()
                        }
                    }
                    
                }
                group.wait()
                
                // 需等以上兩個API都完成才能更新memberListCollectionView畫面
                group.notify(queue: DispatchQueue.main) {
                    
                    print("可以更新了")
                    self.memberListCollectionView.reloadData()
                    print("更新memberListCollectionView完成")
                }
            }
       
        case .failure(let error):
            
            print("[allLabelInGroup] 錯誤\(error)")
        }
    }

}

// 抓取群組所有成員後動作
extension MemberViewController: MemberModelDelegate {
    
    func didFetchData(delegateResult: Result<[GetAllGroupMemberData], Error>) {
        switch delegateResult {
            
        case .success(_):
            
            self.memberListCollectionView.reloadData()
            
        case .failure(let error):
            
            print("[getAllgroupMember] 錯誤\(error)")
        }
    }
    
    
}


