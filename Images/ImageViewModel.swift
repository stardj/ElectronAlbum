//
//  ImageViewModel.swift
//  Images
//
//  Created by Kent on 02/01/2018.
//  Copyright © 2018 V Lanfranchi. All rights reserved.
//

import Foundation
import Photos

class ImageViewModel {
    
//    static var sharedInstance = ImageViewModel()
//    let dataModelDidUpdateNotification = "dataModelDidUpdateNotification"
//    
//    private init() { }
//    
//    private (set) var name: String?	{
//        didSet {
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: dataModelDidUpdateNotification), object: nil)
//        }
//    }
//    
//    func requestData() {
//        self.name = "Data from wherever"
//    }
//    
//    private func getDataUpdate() {
//        //if let data = ImageViewModel.sharedInstance.data {
//            //print(data)
//        }
//    }

    
    var name: String? {
        get {
            return self.name
        }
        set {
            self.name = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return self.image
        }
        set {
            self.image = newValue
        }
    }
    
}
