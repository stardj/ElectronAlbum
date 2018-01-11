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
    /// 根据id设置图片
    ///
    /// - Parameters:
    ///   - timeStamp: photoId
    ///   - isThumbnail: 是否是缩略图
    func setImage(timeStamp: Int, isThumbnail: Bool) {
        //设置默认图片,避免读出图片数据有误
        if let data = YHJImgCacheCenter.readImgFromCache(timeStamp: timeStamp, isThumbnail: isThumbnail) {
            self.image=UIImage(data: data)
        } else {
            if !isThumbnail {
                if let data = YHJImgCacheCenter.readImgFromCache(timeStamp: timeStamp, isThumbnail: true) {
                    self.image=UIImage(data: data)
                }
                if let photo = PhotoModel.rows(filter: "id = \(timeStamp)").first as? PhotoModel{
                    DispatchQueue.global().async {
                        SystemPhotoManager.share.getOriginImg(identifier: photo.identifier) {
                            img in
                            DispatchQueue.main.async {
                                if let image = img {
                                    self.image = image
                                } else {
                                    if let data = YHJImgCacheCenter.readImgFromCache(timeStamp: timeStamp, isThumbnail: true) {
                                        self.image=UIImage(data: data)
                                    } else {
                                        self.image=UIImage(named: "errorImg")
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                self.image=UIImage(named: "errorImg")
            }
        }
    }
}

class YHJImgCacheCenter {
    static let LoaclChache = "/Documents/PhotoTool"

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
            try data.write(to: pathUrl, options: [])
        } catch let err as NSError {
            print(err.description)
        }
    }
    
    /// 得到图片缓存路径
    ///
    /// - Parameters:
    ///   - timeStamp: photoId
    ///   - isThumbnail: 是否是缩略图
    /// - Returns: 图片data
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
        
        let timeInterval = TimeInterval(timeStamp)
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd_HHmmss"
        var str = dateformatter.string(from: Date(timeIntervalSince1970: timeInterval))

        if isThumbnail {
            str += "_Thumbnail"
        }
        return chchePath + "/" + "Img_" + str + ".png"
    }
    

    /// 删除缓存图片
    ///
    /// - Parameters:
    ///   - timeStamp: photoId
    ///   - isThumbnail: 是否是缩略图
    /// - Returns: 图片data
    class func removeAllCache(){
        let chchePath = NSHomeDirectory() + LoaclChache
        let fileManager: FileManager = FileManager.default
        if fileManager.fileExists(atPath: chchePath) {
            try? fileManager.removeItem(atPath: chchePath)
        }
    }
}

