//
//  ComTools.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/11/24.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//
import UIKit
import Photos

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
    class func getImage(timeStamp: Int, isThumbnail: Bool) -> UIImage {
        //set the default image to avoid value error
        //        self.image=UIImage(named: "2")
        if let data = YHJImgCacheCenter.readImgFromCache(timeStamp: timeStamp, isThumbnail: isThumbnail) {
            return UIImage(data: data) ?? UIImage(named: "errorImg")!
        }
        return UIImage(named: "errorImg")!
    }
    
    class func getNewFont(size: CGFloat) -> UIFont {
        let font = UIFont.systemFont(ofSize: size * DeviceInfo.ScaleSizeW)
        return font
    }
    
    class func toJSONString(ary: Any) -> String? {
        let data = try? JSONSerialization.data(withJSONObject: ary, options: .prettyPrinted)
        let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return str as String?
    }
    
    class func toJSONString(dict: Dictionary<String, Any>!) -> String? {
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return str as String?
    }
    
//    class func propertyList(model: NSObject) -> [String: Any?] {
//        var props: [String: Any?] = [:]
//        var outCount:UInt32 = 0
//
//        let properties: UnsafeMutablePointer<objc_property_t>! = class_copyPropertyList(type(of: model), &outCount)
//        for i in 0..<Int(outCount) {
//            guard let pty = properties?[i] else { continue}
//            let cName = property_getName(pty)
//            guard let name = String(utf8String: cName) else {continue}
//            let value = model.value(forKey: name)
//            props = [name: value]
//        }
//
//        return props
//    }
    
    class func getPropertyList(model: NSObject) -> [String] {
        var pros: [String] = []
        let morror = Mirror(reflecting: model)
        
        for (name, _) in (morror.children) {
            //            print("子类属性名:\(name) 值: \(value)")
            guard let name = name else { continue }
            pros.append(name)
        }
        
        return pros
    }
    
    class func getValueList(model: NSObject) -> [Any?] {
        var values: [Any?] = []
        let morror = Mirror(reflecting: model)
        
        for (_, value) in (morror.children) {
            //            print("子类属性名:\(name) 值: \(value)")
//            guard let value = value else { continue }
            values.append(value)
        }
        
        return values
    }
    
    class func propertyDic(model: NSObject) -> [String: Any?] {
        var dic: [String: Any] = [:]
        
        let morror = Mirror(reflecting: model)

        for (name, value) in (morror.children) {
//            print("子类属性名:\(name) 值: \(value)")
            guard let name = name else { continue }
            dic = [name : value]
        }
        
        return dic
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


