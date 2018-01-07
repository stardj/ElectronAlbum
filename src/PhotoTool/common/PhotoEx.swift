//
//  PhotoEx.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/1.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit
struct ColorsAry {
    static let colorBlack3 = UIColor(hexString: "333333")!
    static let colorBlack6 = UIColor(hexString: "666666")!
    static let colorBlack9 = UIColor(hexString: "999999")!
    static let colorHome = UIColor(hexString: "1bcd99")!
    static let colorSongHall = UIColor(hexString: "00cdeb")!
    static let colorPractice = UIColor(hexString: "8e9ff9")!
    static let colorFriends = UIColor(hexString: "ff9b4f")!
    static let colorMe = UIColor(hexString: "fe587b")!
    static let colorBackgray = UIColor(hexString: "cfcfd1")!
    static let colorLightgray = UIColor(hexString: "F6F6F6")!
    static let colorTabbar = UIColor(hexString: "747bdf")!
    static let colorLogin = UIColor(hexString: "7793EE")!
    static let lightSonghall = UIColor(hexString: "E1F6FA")!
    static let warningyellow = UIColor(hexString: "FD8A00")!
    static let purplered = UIColor(hexString: "FB28AC")!
    static let yellow = UIColor(hexString: "FFA13D")
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
    
    func showAlertMessageWithBlock(title: String, message: String, buttonTitle: String, isShowCancle: Bool?=false, block:@escaping ()->()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler:{
            action in
            block()
        }))
        
        if let isShow = isShowCancle {
            if isShow {
                let canelAction = UIAlertAction(title: "Cancel",style: UIAlertActionStyle.cancel,handler: nil)
                alertController.addAction(canelAction)
            }
        }
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

extension UIView {
    // 去除所有手势
    func removeAllGestureRecognizers() {
        if let gests = self.gestureRecognizers {
            for i in gests {
                self.removeGestureRecognizer(i)
            }
        }
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
            //            removeNavigationBarLine()
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
    func setNavigationbarTitle(isBackShow: Bool, titleName: String, titleColor: UIColor,  bgColor: UIColor?) {
        navigationController?.navigationBar.isHidden = false
        title = titleName
        navigationController?.navigationBar.backgroundColor = bgColor
        navigationController?.navigationBar.tintColor = titleColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : titleColor]
        if isBackShow {
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
    // MARK: 设置无返回按钮导航栏
    
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

extension UIColor {
    convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
    convenience init?(hexString: String, alpha: Float) {
        var hex = hexString
        
        if hex.hasPrefix("#") {
            hex = hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 1))
        }
        
        if let _ = hex.range(of: "(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .regularExpression) {
            if hex.lengthOfBytes(using: String.Encoding.utf8) == 3 {
                let redHex = hex.substring(to: hex.characters.index(hex.startIndex, offsetBy: 1))
                let greenHex = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 1) ..< hex.characters.index(hex.startIndex, offsetBy: 2)))
                let blueHex = hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 2))
                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
            }
            let redHex = hex.substring(to: hex.characters.index(hex.startIndex, offsetBy: 2))
            let greenHex = hex.substring(with: Range<String.Index>(hex.characters.index(hex.startIndex, offsetBy: 2) ..< hex.characters.index(hex.startIndex, offsetBy: 4)))
            let blueHex = hex.substring(with: Range<String.Index>( hex.characters.index(hex.startIndex, offsetBy: 4) ..< hex.characters.index(hex.startIndex, offsetBy: 6)))
            
            var redInt:   CUnsignedInt = 0
            var greenInt: CUnsignedInt = 0
            var blueInt:  CUnsignedInt = 0
            
            Scanner(string: redHex).scanHexInt32(&redInt)
            Scanner(string: greenHex).scanHexInt32(&greenInt)
            Scanner(string: blueHex).scanHexInt32(&blueInt)
            
            self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: CGFloat(alpha))
        }
        else
        {
            self.init()
            return nil
        }
    }
    
    convenience init?(hex: Int) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    convenience init?(hex: Int, alpha: Float) {
        let hexString = NSString(format: "%2X", hex)
        self.init(hexString: hexString as String, alpha: alpha)
    }
}
