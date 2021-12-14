//
//  ViewController.swift
//  cake
//
//  Created by TSAI MICKY on 2021/12/14.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var accountTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func singInButton(_ sender: Any) {
        
        let singInStoryboard = UIStoryboard(name: "MeunView", bundle: .main)
        if let meunVC = singInStoryboard.instantiateViewController(withIdentifier: "MeunView") as? MeunViewController {
            
            navigationController?.pushViewController(meunVC, animated: true)
        }
    }
    
    @IBAction func registerButton(_ sender: Any) {
        
        let registerStoryBoard = UIStoryboard(name: "RegisterView", bundle: .main)
        if let registerVC = registerStoryBoard.instantiateViewController(withIdentifier: "RegisterView") as? RegisterViewContrllor {
            
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }
}

