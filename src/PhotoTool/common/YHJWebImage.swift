//
//  YHJWebImage.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/11/28.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//

import UIKit
import Foundation

extension UIImageView {
    /**
     *  read images by time
     */
    func setImage(timeStamp: Int, isThumbnail: Bool) {
        //  set defualt images for avoid value error
        if let data = YHJImgCacheCenter.readImgFromCache(timeStamp: timeStamp, isThumbnail: isThumbnail) {
            self.image=UIImage(data: data)
        } else {
            self.image=UIImage(named: "errorImg")
        }
    }
}

class YHJImgCacheCenter {
    static let LoaclChache = "/Library/Cache/PhotoTool"
    // set local path
    class func readImgFromCache(timeStamp: Int, isThumbnail: Bool)-> Data? {
        guard let path = YHJImgCacheCenter.getFullCachePath(timeStamp: timeStamp, isThumbnail: isThumbnail),
            FileManager.default.fileExists(atPath: path),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        return data
    }
    
    class func writeImgToCache(data: Data, timeStap: Int, isThumbnail: Bool){
        guard let path: String = YHJImgCacheCenter.getFullCachePath(timeStamp: timeStap, isThumbnail: isThumbnail) else { return }
        do {
            let pathUrl = URL(fileURLWithPath: path)
//            print("保存了：\(pathUrl)")
            try data.write(to: pathUrl, options: [])
        } catch let err as NSError {
            print(err.description)
        }
    }
    
    class func getFullCachePath(timeStamp: Int, isThumbnail: Bool)-> String? {
        let chchePath = NSHomeDirectory() + LoaclChache
        let fileManager: FileManager = FileManager.default
        if !(fileManager.fileExists(atPath: chchePath)){
            do {
                try? fileManager.createDirectory(at: URL(fileURLWithPath: chchePath), withIntermediateDirectories: true, attributes: nil)
            } catch let err as NSError {
                print(err.description)
            }
        }
        
        // format time
        let timeInterval = TimeInterval(timeStamp)
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd_HHmmss"
        var str = dateformatter.string(from: Date(timeIntervalSince1970: timeInterval))

        if isThumbnail {
            str += "_Thumbnail"
        }
        return chchePath + "/" + "Img_" + str + ".png"
    }
    
    // delete cache
    class func removeAllCache(){
        let chchePath = NSHomeDirectory() + LoaclChache
        let fileManager: FileManager = FileManager.default
        if fileManager.fileExists(atPath: chchePath) {
            try? fileManager.removeItem(atPath: chchePath)
        }
    }
}

extension String{
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        return String(format: hash as String)
    }
}
