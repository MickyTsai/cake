//
//  MemberDetilViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/21.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import Alamofire

class MemberDetilViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var leaveGroupButton: UIButton!
    var accountId: Int?
    @IBOutlet weak var nowGroupNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 抓取群組成員詳細資料
        getGroupMemberInfo()
        
        // 檢查目前登入帳號 是否 與點選的帳號相同 不同的話不能編輯資料
        checkAccountId()
        
    }
    
    // 呼叫API抓取群組成員詳細資料
    private func getGroupMemberInfo() {
        
        guard let accountId = accountId else {
            return
        }

        APIManager.getGroupMemberInfo(accountId: accountId) {
            result in
            switch result {
                
            case .success(let data):
                
                // 設定成員資料
                self.setMemberInfo(memberData: data)
                
            case .failure(let error):
                
                print("[getGroupMemberInfo] 錯誤 \(error)")
            }
        }
    }
    
    // 設定成員資料
    private func setMemberInfo(memberData: GroupMemberInfoData) {
        
        nameTextField.text = memberData.name
        emailTextField.text = memberData.email
        phoneTextField.text = memberData.phone
        nowGroupNameLabel.text = KeychainWrapper.standard.string(forKey: "nowGroupNameKey")
        print("setMemberInfo  設置完成")
    }
    
    // 檢查目前登入帳號 是否 與點選的帳號相同
    private func checkAccountId() {
        
        guard let account = KeychainWrapper.standard.string(forKey: "accountKey") else { return }
        APIManager.getAccountId(account: account) {
            result in
            switch result {
            case .success(let getAccountId):
                
                // 帳號不同 隱藏編輯按鈕
                if self.accountId != getAccountId {
                    
                    self.editButton.isHidden = true
                    self.leaveGroupButton.isHidden = true
                    
                }else {
                    
                    self.editButton.isHidden = false
                }

            case .failure(let error):
                
                print("[getAccountId] 錯誤 \(error)")
            }
        }
    }
    
    
    @IBAction func xMarkButton(_ sender: Any) {
        dismiss(animated: true)
    }

    // 編輯基本資料按鈕
    @IBAction func editButton(_ sender: Any) {
        
        nameTextField.borderStyle = .roundedRect
        emailTextField.borderStyle = .roundedRect
        phoneTextField.borderStyle = .roundedRect
        
        nameTextField.isUserInteractionEnabled = true
        emailTextField.isUserInteractionEnabled = true
        phoneTextField.isUserInteractionEnabled = true
        
        editButton.isHidden = true
        saveButton.isHidden = false
    }
    
    // 結束編輯 儲存按鈕
    @IBAction func saveButton(_ sender: Any) {
        
        nameTextField.borderStyle = .none
        emailTextField.borderStyle = .none
        phoneTextField.borderStyle = .none
        
        nameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        phoneTextField.isUserInteractionEnabled = false
        
        editButton.isHidden = false
        saveButton.isHidden = true
        
        guard let name = nameTextField.text,
              let phone = phoneTextField.text,
              let email = emailTextField.text else { return }
        
        // 先取得accountId
        guard let account = KeychainWrapper.standard.string(forKey: "accountKey") else { return }
        APIManager.getAccountId(account: account) {
            result in
            switch result {
                
            case .success(let accountId):
                
                // 呼叫上傳編輯個人資料api
                APIManager.editUserInfo(accountId: accountId,
                                        name: name,
                                        phone: phone,
                                        email: email) {
                    result in
                    switch result {
                        
                    case .success(let data):
                        
                        print("[editUserInfo] 成功 變更結果： \(data)")
                        
                        // 再抓一次資料更新畫面
                        self.getGroupMemberInfo()
                        
                    case .failure(let error):
                        print("[editUserInfo] 錯誤 \(error)")
                    }
                }
                
            case .failure(let error):
                
                print("[getAccountId] 錯誤 \(error)")
            }
        }
        
    }

    // 點選“離開群組”按鈕
    @IBAction func leaveGroupButton(_ sender: Any) {
        
        let alertController =  UIAlertController(title: "警告", message: "請確認是否離開群組", preferredStyle: .alert)
        
        // 點選確認離開群組 將呼叫退出群組API (後續判斷帳號是否還有群組？ 群組選擇畫面？)
        let okAction = UIAlertAction(title: "確認離開", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        let canelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(canelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
