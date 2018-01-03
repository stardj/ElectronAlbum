//
//  PhotoMapCollectionViewCell.swift
//  Images
//
//  Created by Kent on 29/12/2017.
//  Copyright © 2017 V Lanfranchi. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView?
    var imageStr: String?
    var location: CLLocationCoordinate2D?
//    {
//        
//        didSet {
//            self.imageView!.image = UIImage(named: self.imageStr! as String)
//        }
//        
//    }
    //var location:CLLocationCoordinate2D?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView = UIImageView()
        self.imageView?.layer.borderColor = UIColor.white.cgColor;
        self.imageView?.layer.borderWidth = 1;
        //self.imageView?.layer.cornerRadius = 3;
        self.imageView?.clipsToBounds = true;
        
        self.addSubview(self.imageView!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
