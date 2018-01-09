//
//  PhotoModel.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/3.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//
import Foundation
import CoreLocation

class PhotoModel: SQLTable {
    var id = 0
    var name = ""
//    var groupTitle = ""
    var dateTime = ""
    var addr = ""
    var position = ""
    var desc = ""

    required init() { super.init() }
    convenience init(id: Int, name: String, dateTime: String, addr: String, position: String, desc: String="") {
        self.init()
        self.id = id
        self.name = name
//        self.groupTitle = groupTitle
        self.dateTime = dateTime
        self.addr = addr
        self.position = position
        self.desc = desc
    }
    
    func getPosition() -> CLLocationCoordinate2D? {
        let postStr = position.components(separatedBy: ",")
        guard postStr.count == 2, let latitude = CLLocationDegrees(postStr[0]), let longitude = CLLocationDegrees(postStr[1]) else {
            return nil
        }
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    override var description:String {
        return "id: \(id), name: \(name), dateTime: \(dateTime), addr: \(addr), position: \(position), desc: \(desc)\n"
    }
}


enum CollectionViewShowType: UInt {
    case normal
    case waterfall
}

enum SortType: UInt {
    case time
    case local
}

enum CellType: Int {
    case group
    case photo
}
class BaseGroup: NSObject {
    var sortType: SortType = .time
    var groupTitle = ""
    var photos: [PhotoModel?] = []
    override init() { super.init() }
    convenience init(sortType: SortType, groupTitle: String, photos: [PhotoModel?]) {
        self.init()
        self.sortType = sortType
        self.groupTitle = groupTitle
        self.photos = photos
    }
}

class FirstVCGroup: BaseGroup {
    var color: String = ""
    
    //    override init(sortType: SortType, groupTitle: String, photos: [PhotoModel?]) {
    //        super.init(sortType: sortType, groupTitle: groupTitle, photos: photos)
    //    }
    
    convenience init(sortType: SortType, groupTitle: String, photos: [PhotoModel?], color: String) {
        self.init(sortType: sortType, groupTitle: groupTitle, photos: photos)
        self.color = color
    }
}
