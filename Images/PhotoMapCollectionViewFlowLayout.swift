//
//  PhotoMapCollectionViewFlowLayout.swift
//  Images
//
//  Created by Lei Zhang on 29/12/2017.
//  Copyright © 2017 Lei Zhang, Zhiminxing Wang, Yinghui Jiang. All rights reserved.
//

import UIKit

class PhotoMapCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var itemW: CGFloat = 100
    var itemH: CGFloat = 100
    
    lazy var inset: CGFloat = {
        return  (self.collectionView?.bounds.width ?? 0)  * 0.5 - self.itemSize.width * 0.5
    }()
    
    override init() {
        super.init()
        self.itemSize = CGSize(width: itemW, height: itemH)
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 0
    }

    override func prepare() {
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
        
    
}
