//
//  PhotoEx.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/1.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit
struct ColorsAry {
    static let colorBlack6 = UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    static let colorTabbar = UIColor.init(red: 116/255, green: 123/255, blue: 223/255, alpha: 1)//UIColor(hexString: "747bdf")!
}

extension UIViewController {
    func setReturnBtn(isShow: Bool) {
        if isShow {
            let item = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain, target: self, action: #selector(returnBtnClickCom))
            let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace , target: nil, action: nil)
            spacer.width = -10
            navigationItem.leftBarButtonItems = [spacer, item]
        } else {
            let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace , target: nil, action: nil)
            spacer.width = -10
            navigationItem.leftBarButtonItems = [spacer]
        }
    }
    
    func showAlert(title: String, message: String, buttonTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    func setTabBarItem(tag: Int, titleStr: String, titleSelecteColor: String, defaultImageStr: String, selectImageStr: String) {
        tabBarItem.tag = tag
        tabBarItem.title = titleStr
        tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font : Tools.getNewFont(size: 14), NSAttributedStringKey.foregroundColor : ColorsAry.colorBlack6], for: .normal)
        tabBarItem.image = UIImage(named: defaultImageStr)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem.selectedImage = UIImage(named: selectImageStr)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : ColorsAry.colorTabbar, NSAttributedStringKey.font : Tools.getNewFont(size: 14) ], for: .selected)
//        if DeviceInfo.isPad && UIDevice.current.systemVersion>="11" {
//            let imgSize = (tabBarItem.image?.size)!
//            let padding: CGFloat = (imgSize.height)/2
//            let strSize = getStrSize(titleStr, font: NewLabelFontSize.LabelFont14)
//            let wid = (imgSize.width)+strSize.width
//            tabBarItem.titlePositionAdjustment = UIOffset(horizontal: -(wid-strSize.width)/2, vertical: padding)
//            tabBarItem.imageInsets = UIEdgeInsets(top: -padding, left: (wid-imgSize.width+10)/2, bottom: padding, right: -(wid-imgSize.width+10)/2)
//        }
    }
}

extension UIImageView {
    func setImageViewShadow() {
        self.layer.shadowOpacity = 0.8
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}

extension UIViewController {
    func setStatusBarStyle(isDefault: Bool) {
        if isDefault {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        } else {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        }
    }
    
    func setNavigationBar(isModal: Bool=false, isBackShow: Bool, bgImgName: String, titleName: String, titleColor: UIColor) {
        self.navigationController?.navigationBar.isHidden = false
        if let bgImage = UIImage(named: bgImgName) {
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar
                .setBackgroundImage(bgImage, for: .default)
        } else {
            removeNavigationBarLine()
        }
        
        navigationController?.navigationBar.tintColor = titleColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : titleColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)]
        title = titleName
        if isBackShow {
            var item = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain, target: self, action: #selector(returnBtnClickCom))
            if isModal {
                item = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain, target: self, action: #selector(returnBtnDismiss))
            }
            let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace , target: nil, action: nil)
            spacer.width = -10
            navigationItem.leftBarButtonItems = [spacer, item]
        } else {
            let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace , target: nil, action: nil)
            navigationItem.leftBarButtonItems = [spacer]
        }
    }
    
    
    @objc func returnBtnClickCom() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func returnBtnDismiss()  {
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    func removeNavigationBarLine() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}

