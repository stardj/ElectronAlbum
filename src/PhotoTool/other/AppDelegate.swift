//
//  AppDelegate.swift
//  PhotoTool
//
//  Created by  YH_Jiang L_Zhang ZMX_Wang on 2017/11/24.
//  Copyright © 2017 year  YH_Jiang L_Zhang ZMX_Wang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let db = SQLiteDB.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true
        window?.backgroundColor = UIColor.white
        _ = db.openDB(copyFile:false)
        
        SystemPhotoManager.share.synchroPhotos(block: { (_, _) in })
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        SystemPhotoManager.share.synchroPhotos(block: { (_, isUpdate) in
//            NotificationCenter.default.post(name: NSNotification.Name.init(PhotoNotiFicationName.BecomeActive), object: nil, userInfo: ["isUpdate": isUpdate])
//        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

