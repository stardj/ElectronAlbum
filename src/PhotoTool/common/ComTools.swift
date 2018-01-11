//
//  ComTools.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/11/24.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//
import UIKit
import Photos


// 时间相关的处理
class DateTools {
    class func getNameByDate(timeStap: Int) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd_HHmmss"
        let str = dateformatter.string(from: Date(timeIntervalSince1970: TimeInterval(timeStap)))
        return "Img_\(str).png"
    }
    
    class func getCurTimeStamp() -> Int {
        let now = Date()
        let timeStamp = Int(now.timeIntervalSince1970)
        return timeStamp
    }
    
    class func dateToTimeStamp(date: Date) -> Int {
        let timeStamp = Int(date.timeIntervalSince1970)
        return timeStamp
    }
    
    class func timeStampToStr(timeStamp: Int) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let str = dateformatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(timeStamp)))
        return str
    }
    
    class func dateToStr(date: Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let str = dateformatter.string(from: date)
        return str
    }
}

class Tools {
    class func getNewFont(size: CGFloat) -> UIFont {
        let font = UIFont.systemFont(ofSize: size * DeviceInfo.ScaleSizeW)
        return font
    }
    
    /// 根据id得到图片data
    ///
    /// - Parameters:
    ///   - timeStamp: photoId
    ///   - isThumbnail: 是否是缩略图
    /// - Returns: 图片data
    class func getImage(timeStamp: Int, isThumbnail: Bool) -> UIImage? {
        if let data = YHJImgCacheCenter.readImgFromCache(timeStamp: timeStamp, isThumbnail: isThumbnail) {
            return UIImage(data: data)
        } else {
            if !isThumbnail {
                if let data = YHJImgCacheCenter.readImgFromCache(timeStamp: timeStamp, isThumbnail: true) {
                    return UIImage(data: data)
                }
            }
        }
        return UIImage(named: "errorImg")
    }
    
    class func minOne<T:Comparable>( _ seq:[T]) -> T{
        assert(seq.count>0)
        return seq.reduce(seq[0]){
            min($0, $1)
        }
    }
}

struct DeviceInfo {
    static let isPad = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
    static let isPadPro = (DeviceInfo.ScreenHeight>1300 || DeviceInfo.ScreenWidth>1300) ? true : false
    static let allowRotation = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
    static let ScreenHeight = UIScreen.main.bounds.height
    static let ScreenWidth = UIScreen.main.bounds.width
    
    static var ScaleSizeW = ScreenWidth / 414
    static var ScaleSizeH = ScreenHeight / 736
    
    static let ScaleSizeWPad = ScreenWidth / 768
    static let ScaleSizeHPad = ScreenHeight / 1024
    
    static let ScreenOriginFrame = getScreenOriginFrame()
    static let AppKeyWindow = UIApplication.shared.keyWindow
    
    static func isLandscape() -> Bool {
        return !UIApplication.shared.statusBarOrientation.isPortrait
    }
    
    static func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static func getScreenOriginFrame() -> CGRect {
        return UIScreen.main.bounds
    }
}


