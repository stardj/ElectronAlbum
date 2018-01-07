//
//  SystemPhotoManager.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/5.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import AssetsLibrary

//相簿列表项
class AlbumItem {
    //相簿名称
    var title = ""
    var count = 0
    
    //相簿内的资源
    var fetchResult: PHFetchResult<PHAsset>
    
    init(title:String, fetchResult: PHFetchResult<PHAsset>, count: Int){
        self.title = title
        self.fetchResult = fetchResult
        self.count = count
    }
}

class SystemPhotoManager {
    static let share: SystemPhotoManager = SystemPhotoManager()
    /// 带缓存的图片管理对象
    var imageCacheManager: PHCachingImageManager!
    let imgMg = PHImageManager()
    
    // 相机权限
    func isRightCamera() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return authStatus != .restricted && authStatus != .denied
    }
    
    // 相册权限
    func isRightPhoto() -> Bool {
        let authStatus = ALAssetsLibrary.authorizationStatus()
        return authStatus != .restricted && authStatus != .denied
    }
    
    // 相簿
    func getAlbumItems(block: @escaping(_ albumItems: [AlbumItem])->()) {
        let smartOptions = PHFetchOptions()
        //            smartOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]  //倒序取出
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: smartOptions)
        if var itemAry = convertCollection(collection: smartAlbums as! PHFetchResult<AnyObject>) as? [AlbumItem] {
            for (index, item) in itemAry.enumerated() {
                if item.title == "Recently Deleted" {
                    itemAry.remove(at: index)
                }
            }
            block(itemAry)
            return
        }
        block([])
    }
    
    // 缩略图
    func getThumbnailImg(asset: PHAsset, size: CGSize, block: @escaping(_ img: UIImage?)->()) {
        let imageRequestOption = PHImageRequestOptions()
        imageRequestOption.isSynchronous = true
        imageRequestOption.resizeMode = .none
        imageRequestOption.deliveryMode = .highQualityFormat
        imgMg.requestImage(for: asset, targetSize: size,
                                       contentMode: PHImageContentMode.aspectFill,
                                       options: imageRequestOption) { (image, info) in
                block(image)
        }
    }
    
    // 原图
    func getOriginImg(asset: PHAsset, block: @escaping(_ img: UIImage?)->()) {
        imgMg.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil){ (image, info) in
                block(image)
        }
    }
    
    fileprivate func convertCollection(collection: PHFetchResult<AnyObject>) -> [AnyObject]{
        var itemAry: [AlbumItem] = []
        for i in 0..<collection.count{
            //获取出但前相簿内的图片
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d",PHAssetMediaType.image.rawValue)
            guard let c = collection[i] as? PHAssetCollection, let itemTitle = c.localizedTitle else { return [] }
            let assetsFetchResult = PHAsset.fetchAssets(in: c ,options: resultsOptions)
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0{
                itemAry.append(AlbumItem(title: itemTitle, fetchResult: assetsFetchResult, count: assetsFetchResult.count))
            }
        }
        return itemAry
    }
    
    func getAllAssets() -> PHFetchResult<PHAsset> {
        let smartOptions = PHFetchOptions()
        smartOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]  //倒序取出
        smartOptions.predicate = NSPredicate(format: "mediaType = %d",PHAssetMediaType.image.rawValue)
        let assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                                     options: smartOptions)
        return assetsFetchResults
    }
    
    func isSysAllow(block: @escaping(_ status: Bool)->()) {
        PHPhotoLibrary.requestAuthorization {(status) in
            if status != .authorized {
                block(false)
            }
            block(true)
        }
    }
    
    // 保存assets
    func saveAssets(assets: PHFetchResult<PHAsset>) {
        assets.enumerateObjects({[weak self] (asset, count, status) in
            guard let weakself = self else { return }
            weakself.getAssetToPhoto(asset: asset, block: { (photo) in
                guard let photo = photo else { return }
                _ = photo.save()
            })
            weakself.saveThumbnailImg(asset: asset)
            weakself.saveOriginImg(asset: asset)
        })
    }
    
    func saveAssets(assets: [PHAsset]) {
        for asset in assets {
            getAssetToPhoto(asset: asset, block: { (photo) in
                guard let photo = photo else { return }
                _ = photo.save()
            })
            saveThumbnailImg(asset: asset)
            saveOriginImg(asset: asset)
        }
    }
    
    // 保存原图
    func saveOriginImg(asset: PHAsset) {
        getOriginImg(asset: asset) {(image) in
            guard let img = image, let data = UIImagePNGRepresentation(img), let date = asset.creationDate else {
                return
            }
            YHJImgCacheCenter.writeImgToCache(data: data, timeStap: DateTools.dateToTimeStamp(date: date), isThumbnail: false)

        }
    }
    
    // 保存缩略图
    func saveThumbnailImg(asset: PHAsset) {
        let size = DeviceInfo.isPad ? CGSize(width: 200, height: 200) : CGSize(width: 130, height: 130)
        getThumbnailImg(asset: asset, size: size) { (image) in
            guard let img = image, let data = UIImagePNGRepresentation(img), let date = asset.creationDate else { return }
            YHJImgCacheCenter.writeImgToCache(data: data, timeStap: DateTools.dateToTimeStamp(date: date), isThumbnail: true)
        }
    }
    
    func getAssetToPhoto(asset: PHAsset, block: @escaping(_ photo: PhotoModel?)->()) {
        guard let date = asset.creationDate else {
            block(nil)
            return
        }
        let timeStamp = DateTools.dateToTimeStamp(date: date)
        let imgName = DateTools.getNameByDate(timeStap: timeStamp)
        
        if let addr = asset.location {
            locationToCity(currLocation: addr, block: { (city) in
                let post = "\(addr.coordinate.latitude),\(addr.coordinate.longitude)"

                let photo = PhotoModel(id: timeStamp, name: imgName, dateTime: DateTools.dateToStr(date: date), addr: city ?? "", position: post, desc: "")
                block(photo)
            })
        } else {
            let photo = PhotoModel(id: timeStamp, name: imgName, dateTime: DateTools.dateToStr(date: date), addr: "", position: "", desc: "")
            block(photo)
        }
    }
        
    
    
    // MARK: - 将PHAsset对象转为UIImage对象
//    func PHAssetToUIImage(asset: PHAsset) -> UIImage {
//        var image = UIImage()
//
//        let imageManager = PHImageManager.default()
//
//        let imageRequestOption = PHImageRequestOptions()
//        imageRequestOption.isSynchronous = true
//        // 缩略图的压缩模式设置为无
//        imageRequestOption.resizeMode = .none
//        // 缩略图的质量为高质量，不管加载时间花多少
//        imageRequestOption.deliveryMode = .highQualityFormat
//        // 按照PHImageRequestOptions指定的规则取出图片
//        imageManager.requestImage(for: asset, targetSize: self.imageSize, contentMode: .aspectFill, options: imageRequestOption, resultHandler: {
//            (result, _) -> Void in
//            image = result!
//        })
//        return image
//    }
    
    func locationToCity(currLocation: CLLocation, block: @escaping(_ addr: String?)->()) {
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currLocation) { (placemark, error) in
            guard error == nil, let array = placemark, let mark = array.first, let country = mark.country, let city = mark.locality else{
                block(nil)
                return
            }
            block("\(country).\(city)")
        }
    }
    
    class func changeAssetsToPhotos(assets: PHFetchResult<PHAsset>, block: @escaping(_ photos:[PhotoModel])->()) {
        var num = 0
        var photos: [PhotoModel] = []
        assets.enumerateObjects() { (asset, count, stop) in
            SystemPhotoManager.share.getAssetToPhoto(asset: asset, block: { (photo) in
                if let photo = photo {
                    photos.append(photo)
                }
                num += 1
                if num == assets.count {
                    block(photos)
                }
            })
        }
    }
    
    func deletePhotos(deleteId: [Int], block: @escaping(_ status: Bool)->()) {
        var deleteAsset: [PHAsset] = []
        let allAssets = getAllAssets()
        
        var num = 0
        allAssets.enumerateObjects { (asset, count, stop) in
            if let dateTime = asset.creationDate, deleteId.contains(DateTools.dateToTimeStamp(date: dateTime)) {
                deleteAsset.append(asset)
            }
            num += 1
            
            if num == allAssets.count {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.deleteAssets(deleteAsset as NSFastEnumeration)
                }, completionHandler: { (status, error) in
                    PhotoModel.remove(ary: deleteId)
                    block(status)
                })
            }
        }
        
    }
    
    func synchroPhotos(block: @escaping(_ status: Bool, _ isUpdate: Bool)->()) {
        let assets = getAllAssets()
        let countSys = assets.count
        var latestDateSys = 0
        if let date = assets.firstObject?.creationDate {
            latestDateSys = DateTools.dateToTimeStamp(date: date)
        }
        
        let photosSql = PhotoModel.rows(order: "id DESC") as? [PhotoModel] ?? []
        let countSql = photosSql.count
        let latestDateSql = photosSql.first?.id ?? 0
        
        if countSys == 0 {
            _ = PhotoModel.remove()
            block(true, true)
        } else if countSql == 0 {
            saveAssets(assets: assets)
            block(true, true)
        } else if (countSql == countSys) && (latestDateSql != 0) && (latestDateSys == latestDateSql) {
            block(true, false)
        } else {
            var assetsDic: [String: PHAsset] = [:]
            var newAssets: [PHAsset] = []
            var num = 0
            
            assets.enumerateObjects(){[weak self] (asset, count, status) in
                guard let weakself = self, let dateTime = asset.creationDate else {
                    block(false, false)
                    return
                }
                assetsDic["\(DateTools.dateToTimeStamp(date: dateTime))"] = asset
                newAssets.append(asset)
                num += 1
                
                if num ==  countSys {
                    for photo in photosSql {
                        if let check = assetsDic["\(photo.id)"] {
                            if let index = newAssets.index(of: check) {
                                newAssets.remove(at: index)
                            }
                        } else {
                            _ = PhotoModel.remove(filter: "id = \(photo.id)")
                        }
                    }
                    weakself.saveAssets(assets: newAssets)
                    block(true, true)
                }
            }
        }
    }
}

