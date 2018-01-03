//
//  PhotoMapCollectionViewFlowLayout.swift
//  Images
//
//  Created by Kent on 29/12/2017.
//  Copyright © 2017 V Lanfranchi. All rights reserved.
//

import UIKit

class PhotoMapCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var itemW: CGFloat = 100
    var itemH: CGFloat = 100
    
    lazy var inset: CGFloat = {
        //这样设置，inset就只会被计算一次，减少了prepareLayout的计算步骤
        return  (self.collectionView?.bounds.width ?? 0)  * 0.5 - self.itemSize.width * 0.5
    }()
    
    override init() {
        super.init()
        
        //设置每一个元素的大小
        self.itemSize = CGSize(width: itemW, height: itemH)
        //设置滚动方向
        self.scrollDirection = .horizontal
        //        设置间距
        self.minimumLineSpacing = 0//0.7 *
    }
    
    //苹果推荐，对一些布局的准备操作放在这里
    override func prepare() {
        //设置边距(让第一张图片与最后一张图片出现在最中央)
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     返回true只要显示的边界发生改变就重新布局:(默认是false)
     内部会重新调用prepareLayout和调用
     layoutAttributesForElementsInRect方法获得部分cell的布局属性
     */
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
        
    
}
