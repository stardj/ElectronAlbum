//
//  MainVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/11/24.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
        
        if SystemPhotoManager.share.isRightPhoto() {
            SystemPhotoManager.share.synchroPhotos(block: { (_, _) in
            })
        } else {
            showAlert(title: "ERROR", message: "Open the use of album permissions to settings", buttonTitle: "OK")
        }
    }
    @IBAction func loginBtnClick(_ sender: UIButton) {
        if SystemPhotoManager.share.isRightPhoto() {
            SystemPhotoManager.share.synchroPhotos(block: { (_, _) in
            })
        } else {
            showAlert(title: "ERROR", message: "Open the use of album permissions to settings", buttonTitle: "OK")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let detailVC = segue.identifier as? String {
//
//        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        accountTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}
