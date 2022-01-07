//
//  ViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/14.
//

import UIKit
import Alamofire
import SystemConfiguration

class ViewController: UIViewController {

    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }

    // 進行登入
    @IBAction func singInButton(_ sender: Any) {
        
        APIManager.singIn(userAccount: "micky", userPassword: "222") {
            result in
            switch result {
            case .success(_):
                
                print("[SingIn] 成功")
                
                // 檢查是否帳號有群組
                APIManager.checkGroup {
                    result in
                    switch result {
                        
                    case .success(let data):
                        
                        if data.isEmpty {
                            // 帳號尚無群組 需提示視窗 詢問建立群組或返回登入
                            self.noGroupAlert()
                            
                        }else {
                            // 有群組 檢查班表
                            APIManager.checkSchedule() {
                                result in
                                switch result {
                                case .success(let boolResult):
                                    
                                    // 有群組 有班表 前往主畫面
                                    if boolResult == true {
                                        
                                        self.goMeunView()
                                        
                                    // 有群組 沒班表 前往創建班表
                                    }else {
                                        
                                        self.goCreatScheduleView()
                                    }
                                    
                                case .failure(let error):
                                    
                                    print("[getAllSchedule] 錯誤 \(error)")
                                    
                                }
                            }
                        }
                        
                    case .failure(_):
                        print("[checkGroup] 錯誤")
                    }
                }
            case .failure(_):
                print("[SingIn] 失敗")
            }
        }

    }
    
    // 轉跳註冊頁面
    @IBAction func registerButton(_ sender: Any) {
        
        let registerStoryBoard = UIStoryboard(name: "RegisterView", bundle: .main)
        if let registerVC = registerStoryBoard.instantiateViewController(withIdentifier: "RegisterView") as? RegisterViewContrllor {
            
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }
    
    // 帳號無群組的提示視窗
    func noGroupAlert() {
        
        let alertController = UIAlertController(title: "帳號無群組",
                                                message: "此帳號尚無尚任何群組，請建立一個新群組或返回登入等待被加入群組", preferredStyle: .alert)
        
        let backAction = UIAlertAction(title: "返回登入", style: .cancel, handler: nil)
        alertController.addAction(backAction)
        
        alertController.addTextField {
            textField in
            textField.placeholder = "請輸入新群組名稱"
            
        }
        
        // 設定新群組
        let okAction = UIAlertAction(title: "創建新群組", style: .default) {
            (UIAction: UIAlertAction!) -> Void in
            
            // 檢查是否有輸入新群組名稱（不可為""）
            if let inputText = alertController.textFields?[0].text,
                alertController.textFields?[0].text != "" {

                // 創建群組
                APIManager.creatGroup(groupName: inputText) {
                    result in
                    switch result {
                        
                    case .success(_):
                        
                        // 創建成功 轉跳設定班表
                        self.goCreatScheduleView()
                        
                    case .failure(_):
                        
                        // 創建失敗 提示視窗
                        let alert = UIAlertController(title: "新群組創建失敗", message: nil, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }else {
                
                // 沒輸入名稱 提示視窗
                let alert = UIAlertController(title: "請輸入新群組名稱", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // 轉跳主畫面
    private func goMeunView() {
        
        let storyboard = UIStoryboard(name: "MeunView", bundle: .main)
        if let meunVC = storyboard.instantiateViewController(withIdentifier: "MeunView") as? MeunViewController {
            
            navigationController?.pushViewController(meunVC, animated: true)
        }
    }
    
    // 轉跳創建班表畫面
    private func goCreatScheduleView() {
        
        let storyboard = UIStoryboard(name: "CreatScheduleView", bundle: .main)
        if let creatScheduleVC = storyboard.instantiateViewController(withIdentifier: "CreatScheduleView") as? CreatScheduleViewController {

            navigationController?.pushViewController(creatScheduleVC, animated: true)
            
        }
    }
    
    
}

