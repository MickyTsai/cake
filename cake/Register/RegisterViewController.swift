//
//  RegisterViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/14.
//

import Foundation
import UIKit

class RegisterViewContrllor: UIViewController {
    
    
    @IBOutlet weak var accountTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        
        // 檢查欄位是否都有輸入
        guard accountTextField.text != "",
              passwordTextField.text != "",
              confirmPasswordTextField.text != "",
              nicknameTextField.text != "" else {
                  
                  print("欄位輸入不完整")
                  return
              }
        if passwordTextField.text != confirmPasswordTextField.text {
            
            print("密碼不相符")
        }
        
        guard let account = accountTextField.text,
              let password = passwordTextField.text,
              let name = nicknameTextField.text else {
                  return
              }
        
        APIManager.register(account: account, password: password, name: name) {
            result in
            switch result {
                
            case .success(_):
                
                print("[register] 成功")
                
                // 轉跳回登入畫面
                let storyBoard = UIStoryboard(name: "Main", bundle: .main)
                if let mainVC = storyBoard.instantiateViewController(withIdentifier: "Main") as? ViewController {
                    
                    self.navigationController?.pushViewController(mainVC, animated: true)
                }
                
            case .failure(let error):
                
                print("[register] 失敗\(error)")
            }
        }
    }
}
