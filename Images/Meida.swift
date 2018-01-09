//
//  Meida.swift
//  Images
//
//  Created by Lei Zhang on 08/01/2018.
//  Copyright © 2018 Lei Zhang, Zhiminxing Wang, Yinghui Jiang. All rights reserved.
//

import UIKit

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/png"
        self.filename = "sheffied.jpg"
        guard let data = UIImagePNGRepresentation(image) else { return nil }
        self.data = data
    }
    
}
