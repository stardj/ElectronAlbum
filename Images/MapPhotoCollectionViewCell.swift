//
//  MapPhoneCollectionViewCell.swift
//  Images
//
//  Created by Kent on 27/12/2017.
//  Copyright © 2017 V Lanfranchi. All rights reserved.
//

import UIKit
import Photos

class MapPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let photoView = UIImageView(frame: frame)
        contentView.addSubview(photoView)
        self.photoView = photoView
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
