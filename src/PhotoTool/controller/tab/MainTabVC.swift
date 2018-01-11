//
//  MainTabVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/2.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit

struct PhotoNotiFicationName {
    static let HidiBottomBar = "HidiBottomBar"
    static let BecomeActive = "BecomeActive"
}

class MainTabVC: CustomTabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(hideBottomBar(noti:)), name: NSNotification.Name(rawValue: PhotoNotiFicationName.HidiBottomBar), object: nil)

        setBarItems()
    }

    @objc func hideBottomBar(noti: Notification) {
        guard let dic = noti.userInfo as? [String: AnyObject], let isHide = dic["isHide"] as? Bool else {
            return
        }
        tabBar.isHidden = isHide
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func getImgStr(name: String) -> String {
        if DeviceInfo.isPad {
            return name + "_pad"
        } else {
            return name
        }
    }
    
    func setBarItems() {
        delegate = self
        guard let vc1 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as? HomeVC else {
            return
        }
        let nvc1 = UINavigationController()
        nvc1.pushViewController(vc1, animated: true)
        vc1.setTabBarItem(tag: 0, titleStr: "首页", titleSelecteColor: "1bcd99", defaultImageStr: getImgStr(name: "icon_index_h"), selectImageStr: getImgStr(name:"icon_index"))
        
        guard let vc2 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as? MapVC else {
            return
        }
        let nvc2 = UINavigationController()
        nvc2.pushViewController(vc2, animated: true)
        vc2.setTabBarItem(tag: 1, titleStr: PageTitle.Map, titleSelecteColor: "E1F6FA", defaultImageStr: getImgStr(name: "icon_qyq_h"), selectImageStr: getImgStr(name:"icon_qyq"))
        
        guard let vc3 = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlbumVC") as? AlbumVC else {
            return
        }
        let nvc3 = UINavigationController()
        nvc3.pushViewController(vc3, animated: true)
        vc3.setTabBarItem(tag: 2, titleStr: PageTitle.Album, titleSelecteColor: "E1F6FA", defaultImageStr: getImgStr(name: "icon_qyq_h"), selectImageStr: getImgStr(name:"icon_qyq"))
        
        self.viewControllers = [nvc1,nvc3,nvc2]
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        if DeviceInfo.isPad {
            var tabFrame = self.tabBar.frame
            tabFrame.size.height = 115
            tabFrame.origin.y = view.frame.size.height - 115
            self.tabBar.frame = tabFrame
            self.tabBar.itemPositioning = .fill
        }
    }
}
