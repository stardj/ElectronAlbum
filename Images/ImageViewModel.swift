//
//  ImageViewModel.swift
//  Images
//
//  Created by Kent on 02/01/2018.
//  Copyright © 2018 V Lanfranchi. All rights reserved.
//

import Foundation
import Photos

class ImageViewModel: NSObject {
    
    var _id: Int = 0
    var id: Int {
        get{
            return _id
        }
        set{
            _id = newValue
        }
    }
    
    var _name: String?
    var name: String? {
        get{
            return _name
        }
        set{
            _name = newValue
        }
    }
    
    var _title: String?
    var title: String? {
        get{
            return _title
        }
        set{
            _title = newValue
        }
    }
    
    var _date: Date?
    var date: Date? {
        get{
            return _date
        }
        set{
            _ = date = newValue
        }
    }
    
    var _latitude: CLLocationDegrees?
    var latitude: CLLocationDegrees? {
        get{
            return _latitude
        }
        set{
            _latitude = newValue
        }
    }
    
    var _longitude: CLLocationDegrees?
    var longitude: CLLocationDegrees? {
        get{
            return _longitude
        }
        set{
            _longitude = newValue
        }
    }
    
    var _image: UIImage?
    var image: UIImage? {
        get{
            return _image
        }
        set{
            _image = newValue
        }
    }
    
    var _location: CLLocationCoordinate2D?
    var location: CLLocationCoordinate2D? {
        get{
            return _location
        }
        set{
            _location = newValue
        }
    }
    
    var _desc: UIImage?
    var desc: UIImage? {
        get{
            return _desc
        }
        set{
            _desc = newValue
        }
    }
    

}
