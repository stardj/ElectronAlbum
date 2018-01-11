
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


class SystemPhotoManager {
    static let share: SystemPhotoManager = SystemPhotoManager()
    /// 带缓存的图片管理对象
    let imgMg = PHImageManager()
    
    /// 是否获得拍照权限
    ///
    /// - Parameters:
    /// - return:
    func isRightCamera() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    /// 是否获得相册权限
    ///
    /// - Parameters:
    /// - return:
    func isRightPhoto() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    /// 得到系统相簿
    ///
    /// - Parameters:
    /// - return:
    func getAlbumItems(block: @escaping(_ albumItems: [AlbumItem])->()) {
        func convertCollection(collection: PHFetchResult<AnyObject>) -> [AnyObject]{
            var itemAry: [AlbumItem] = []
            for i in 0..<collection.count{
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
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
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
    
    /// 检查更新数据库，将系统图片与本地数据库同步
    ///
    /// - Parameters:
    /// - return:
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
        } else
        {
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
                    weakself.saveAssets(assets: newAssets) {
                        status in
                        block(status, true)
                    }
                }
            }
        }
    }
    
    /// 得到缩略图
    ///
    /// - Parameters:
    /// - return: block：返回缩略图Image
    func getThumbnailImg(asset: PHAsset, size: CGSize, block: @escaping(_ img: UIImage?)->()) {
        let imageRequestOption = PHImageRequestOptions()
        imageRequestOption.isSynchronous = true
//        imageRequestOption.resizeMode = .none
//        imageRequestOption.deliveryMode = .highQualityFormat
        imgMg.requestImage(for: asset, targetSize: size,
                                       contentMode: PHImageContentMode.aspectFill,
                                       options: imageRequestOption) { (image, info) in
                block(image)
        }
    }
    
    /// 根据图片identifier，得到原图得到原图， 同时保存到本地
    ///
    /// - Parameters:
    /// - return:
    func getOriginImg(identifier: String, block: @escaping(_ img: UIImage?)->()) {
        func saveOriginImg(asset: PHAsset, img: UIImage) {
            guard let data = UIImagePNGRepresentation(img), let date = asset.creationDate else {
                return
            }
            YHJImgCacheCenter.writeImgToCache(data: data, timeStap: DateTools.dateToTimeStamp(date: date), isThumbnail: false)
        }
        
        guard let asset = getAssetByIdentifier(str: identifier) else {
            block(nil)
            return
        }
        imgMg.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil){ (image, info) in
            block(image)
            DispatchQueue.global().async {
                if let img = image {
                    saveOriginImg(asset: asset, img: img)
                }
            }
        }
    }
    
    /// 根据图片identifier，得到系统图片PHAsset
    ///
    /// - Parameters:
    /// - return:
    func getAssetByIdentifier(str: String) -> PHAsset? {
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [str], options: nil).firstObject {
            return asset
        }
        return nil
    }
    
    /// 得到所有的系统图片
    ///
    /// - Parameters:
    /// - return:
    func getAllAssets() -> PHFetchResult<PHAsset> {
        let smartOptions = PHFetchOptions()
        smartOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]  //倒序取出
        smartOptions.predicate = NSPredicate(format: "mediaType = %d",PHAssetMediaType.image.rawValue)
        let assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                                     options: smartOptions)
        return assetsFetchResults
    }
    
    
    /// 将系统图片转换为PhotoModel，保存到app数据库
    ///
    /// - Parameters:
    /// - return:
    func saveAssets(assets: PHFetchResult<PHAsset>) {
        assets.enumerateObjects({[weak self] (asset, count, status) in
            guard let weakself = self else { return }
            weakself.getAssetToPhoto(asset: asset, block: { (photo) in
                guard let photo = photo else { return }
                _ = photo.save()
            })
            weakself.saveThumbnailImg(asset: asset)
        })
    }
    
    /// 将系统图片转换为PhotoModel，保存到app数据库
    ///
    /// - Parameters:
    /// - return:
    func saveAssets(assets: [PHAsset], block: @escaping(_ status: Bool)->()) {
        DispatchQueue.global().async { [weak self] in
            guard let weakself = self else {
                block(false)
                return
            }
            for asset in assets {
                weakself.getAssetToPhoto(asset: asset, block: { (photo) in
                    guard let photo = photo else { return }
                    _ = photo.save()
                })
                weakself.saveThumbnailImg(asset: asset)
            }
            block(true)
        }
        
    }
    
    
    
    /// 保存系统图片的缩略图到本地沙盒
    ///
    /// - Parameters:
    /// - return:
    func saveThumbnailImg(asset: PHAsset) {
        let size = CGSize(width: 130, height: 130)
        getThumbnailImg(asset: asset, size: size) { (image) in
            guard let img = image, let data = UIImagePNGRepresentation(img), let date = asset.creationDate else { return }
            YHJImgCacheCenter.writeImgToCache(data: data, timeStap: DateTools.dateToTimeStamp(date: date), isThumbnail: true)
        }
    }
    
    /// 将单个系统图片转换为PhotoModel
    ///
    /// - Parameters:
    /// - return:
    func getAssetToPhoto(asset: PHAsset, block: @escaping(_ photo: PhotoModel?)->()) {
        guard let date = asset.creationDate else {
            block(nil)
            return
        }
        let timeStamp = DateTools.dateToTimeStamp(date: date)
        let imgName = DateTools.getNameByDate(timeStap: timeStamp)
        
        if let addr = asset.location {
            locationToCity(currLocation: addr, block: { (city) in
                let post = "\(Int(addr.coordinate.latitude)),\(Int(addr.coordinate.longitude))"

                let photo = PhotoModel(id: timeStamp, name: imgName, dateTime: DateTools.dateToStr(date: date), addr: city ?? "", position: post, desc: "", identifier: asset.localIdentifier)
                block(photo)
            })
        } else {
            let photo = PhotoModel(id: timeStamp, name: imgName, dateTime: DateTools.dateToStr(date: date), addr: "", position: "", desc: "", identifier: asset.localIdentifier)
            block(photo)
        }
    }
    
    /// 得到CLLocation的地址描述
    ///
    /// - Parameters:
    /// - return:
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
    
    /// 将系统图片数组转换为PhotoModel数组
    ///
    /// - Parameters:
    /// - return:
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
    
    /// 删除系统图片数组
    ///
    /// - Parameters:
    /// - return:
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
                    if status {
                        PhotoModel.remove(ary: deleteId)
                    }
                    block(status)
                })
            }
        }
        
    }
}

