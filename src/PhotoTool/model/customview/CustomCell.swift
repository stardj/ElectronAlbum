//
//  CustomCell.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/2.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    func setInfo(photoId: Int, titleStr: String, count: Int) {
        imgView.setImage(timeStamp: photoId, isThumbnail: true)
        titleLabel.text = titleStr
        countLabel.text = "\(count)"
    }
}

class SearchCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    func setInfo(photo: PhotoModel) {
        imgView.setImage(timeStamp: photo.id, isThumbnail: true)
        titleLabel.text = "Title :   \(photo.name)"
        addrLabel.text =  "Addr  :   \(photo.addr)"
        dateLabel.text =  "Date  :   \(photo.dateTime)"
        descLabel.text =  "Desc  :   \(photo.desc)"
    }
}

class ImageBaseCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    
    func setImg(timeStamp: Int, isThumbnail: Bool, isFit:Bool=false) {
        imgView.setImage(timeStamp: timeStamp, isThumbnail: isThumbnail)
        if isFit {
            imgView.contentMode = .scaleAspectFit
        }
    }
}

class ImageCellWithSelected: ImageBaseCell {
    @IBOutlet weak var tickImg: UIImageView!

    func setImg(timeStamp: Int, isSelected: Bool=false, isThumbnail: Bool) {
        super.setImg(timeStamp: timeStamp, isThumbnail: isThumbnail)
        setSelected(isSelect: isSelected)
    }

    func setSelected(isSelect: Bool) {
        tickImg?.isHidden = !isSelect
    }
}

class CollectionHeaderCell: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    
    func setInfo(titleStr: String) {
        titleLabel.text = titleStr
    }
}

@objc protocol WaterFallLayoutDelegate {
    //waterFall的列数
    @objc optional func columnOfWaterFall(_ collectionView: UICollectionView) -> Int
    //每个item的高度
    @objc optional func waterFall(_ collectionView: UICollectionView, layout waterFallLayout: WaterFallLayout, heightForItemAt indexPath: IndexPath) -> CGFloat
}


class WaterFallLayout: UICollectionViewLayout {
    
    //代理
    weak var delegate: WaterFallLayoutDelegate?
    //行间距
    @IBInspectable var lineSpacing: CGFloat   = 0
    //列间距
    @IBInspectable var columnSpacing: CGFloat = 0
    //section的top
    @IBInspectable var sectionTop: CGFloat    = 0 {
        willSet {
            sectionInsets.top = newValue
        }
    }
    //section的Bottom
    @IBInspectable var sectionBottom: CGFloat  = 0 {
        willSet {
            sectionInsets.bottom = newValue
        }
    }
    //section的left
    @IBInspectable var sectionLeft: CGFloat   = 0 {
        willSet {
            sectionInsets.left = newValue
        }
    }
    //section的right
    @IBInspectable var sectionRight: CGFloat  = 0 {
        willSet {
            sectionInsets.right = newValue
        }
    }
    //section的Insets
    @IBInspectable var sectionInsets: UIEdgeInsets      = UIEdgeInsets.zero
    //每行对应的高度
    private var columnHeights: [Int: CGFloat]                  = [Int: CGFloat]()
    private var attributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    
    //MARK: Initial Methods
    init(lineSpacing: CGFloat, columnSpacing: CGFloat, sectionInsets: UIEdgeInsets) {
        super.init()
        self.lineSpacing      = lineSpacing
        self.columnSpacing    = columnSpacing
        self.sectionInsets    = sectionInsets
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: Public Methods
    
    fileprivate lazy var cellSize:CGSize = {
        let picWidth = DeviceInfo.ScreenWidth*0.33
        return CGSize(width: picWidth, height: picWidth*1.3)
    }()
    
    //MARK: Override
    override var collectionViewContentSize: CGSize {
        var maxHeight: CGFloat = 0
        for height in columnHeights.values {
            if height > maxHeight {
                maxHeight = height
            }
        }
        return CGSize.init(width: collectionView?.frame.width ?? 0, height: maxHeight + sectionInsets.bottom)
    }
    
    override func prepare() {
        super.prepare()
        guard collectionView != nil else {
            return
        }
        if let columnCount = delegate?.columnOfWaterFall?(collectionView!) {
            for i in 0..<columnCount {
                columnHeights[i] = sectionInsets.top
            }
        }
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        attributes.removeAll()
        for i in 0..<itemCount {
            if let att = layoutAttributesForItem(at: IndexPath.init(row: i, section: 0)) {
                attributes.append(att)
            }
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let collectionView = collectionView {
            //根据indexPath获取item的attributes
            let att = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            //获取collectionView的宽度
            let width = collectionView.frame.width
            if let columnCount = delegate?.columnOfWaterFall?(collectionView) {
                guard columnCount > 0 else {
                    return nil
                }
                //item的宽度 = (collectionView的宽度 - 内边距与列间距) / 列数
                let totalWidth  = (width - sectionInsets.left - sectionInsets.right - (CGFloat(columnCount) - 1) * columnSpacing)
                let itemWidth   = totalWidth / CGFloat(columnCount)
                //获取item的高度，由外界计算得到
                let itemHeight  = delegate?.waterFall?(collectionView, layout: self, heightForItemAt: indexPath) ?? 0
                //找出最短的那一列
                var minIndex = 0
                for column in columnHeights {
                    if column.value < columnHeights[minIndex] ?? 0 {
                        minIndex = column.key
                    }
                }
                //根据最短列的列数计算item的x值
                let itemX  = sectionInsets.left + (columnSpacing + itemWidth) * CGFloat(minIndex)
                //item的y值 = 最短列的最大y值 + 行间距
                let itemY  = (columnHeights[minIndex] ?? 0) + lineSpacing
                //设置attributes的frame
                att.frame  = CGRect.init(x: itemX, y: itemY, width: itemWidth, height: itemHeight)
                //更新字典中的最大y值
                columnHeights[minIndex] = att.frame.maxY
            }
            return att
        }
        return nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }
}

//自定义的具有粘性分组头的Collection View布局类
class StickyHeadersFlowLayout: UICollectionViewFlowLayout {
    
    //边界发生变化时是否重新布局（视图滚动的时候也会调用）
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    //所有元素的位置属性
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
            //从父类得到默认的所有元素属性
            guard let layoutAttributes = super.layoutAttributesForElements(in: rect)
                else { return nil }
            
            //用于存储元素新的布局属性,最后会返回这个
            var newLayoutAttributes = [UICollectionViewLayoutAttributes]()
            //存储每个layout attributes对应的是哪个section
            let sectionsToAdd = NSMutableIndexSet()
            
            //循环老的元素布局属性
            for layoutAttributesSet in layoutAttributes {
                //如果元素师cell
                if layoutAttributesSet.representedElementCategory == .cell {
                    //将布局添加到newLayoutAttributes中
                    newLayoutAttributes.append(layoutAttributesSet)
                } else if layoutAttributesSet.representedElementCategory == .supplementaryView {
                    //将对应的section储存到sectionsToAdd中
                    sectionsToAdd.add(layoutAttributesSet.indexPath.section)
                }
            }
            
            //遍历sectionsToAdd，补充视图使用正确的布局属性
            for section in sectionsToAdd {
                let indexPath = IndexPath(item: 0, section: section)
                
                //添加头部布局属性
                if let headerAttributes = self.layoutAttributesForSupplementaryView(ofKind:
                    UICollectionElementKindSectionHeader, at: indexPath) {
                    newLayoutAttributes.append(headerAttributes)
                }
                
                //添加尾部布局属性
                if let footerAttributes = self.layoutAttributesForSupplementaryView(ofKind:
                    UICollectionElementKindSectionFooter, at: indexPath) {
                    newLayoutAttributes.append(footerAttributes)
                }
            }
            
            return newLayoutAttributes
    }
    
    //补充视图的布局属性(这里处理实现粘性分组头,让分组头始终处于分组可视区域的顶部)
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //先从父类获取补充视图的布局属性
        guard let layoutAttributes = super.layoutAttributesForSupplementaryView(ofKind:
            elementKind, at: indexPath) else { return nil }
        
        //如果不是头部视图则直接返回
        if elementKind != UICollectionElementKindSectionHeader {
            return layoutAttributes
        }
        
        //根据section索引，获取对应的边界范围
        guard let boundaries = boundaries(forSection: indexPath.section)
            else { return layoutAttributes }
        guard let collectionView = collectionView else { return layoutAttributes }
        
        //保存视图内入垂直方向的偏移量
        let contentOffsetY = collectionView.contentOffset.y
        //补充视图的frame
        var frameForSupplementaryView = layoutAttributes.frame
        
        //计算分组头垂直方向的最大最小值
        let minimum = boundaries.minimum - frameForSupplementaryView.height
        let maximum = boundaries.maximum - frameForSupplementaryView.height
        
        //如果内容区域的垂直偏移量小于分组头最小的位置，则将分组头置于其最小位置
        if contentOffsetY < minimum {
            frameForSupplementaryView.origin.y = minimum
        }
            //如果内容区域的垂直偏移量大于分组头最小的位置，则将分组头置于其最大位置
        else if contentOffsetY > maximum {
            frameForSupplementaryView.origin.y = maximum
        }
            //如果都不满足，则说明内容区域的垂直便宜量落在分组头的边界范围内。
            //将分组头设置为内容偏移量，从而让分组头固定在集合视图的顶部
        else {
            frameForSupplementaryView.origin.y = contentOffsetY
        }
        
        //更新布局属性并返回
        layoutAttributes.frame = frameForSupplementaryView
        return layoutAttributes
    }
    
    //根据section索引，获取对应的边界范围（返回一个元组）
    func boundaries(forSection section: Int) -> (minimum: CGFloat, maximum: CGFloat)? {
        //保存返回结果
        var result = (minimum: CGFloat(0.0), maximum: CGFloat(0.0))
        
        //如果collectionView属性为nil，则直接fanhui
        guard let collectionView = collectionView else { return result }
        
        //获取该分区中的项目数
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        //如果项目数位0，则直接返回
        guard numberOfItems > 0 else { return result }
        
        //从流布局属性中获取第一个、以及最后一个项的布局属性
        let first = IndexPath(item: 0, section: section)
        let last = IndexPath(item: (numberOfItems - 1), section: section)
        if let firstItem = layoutAttributesForItem(at: first),
            let lastItem = layoutAttributesForItem(at: last) {
            //分别获区边界的最小值和最大值
            result.minimum = firstItem.frame.minY
            result.maximum = lastItem.frame.maxY
            
            //将分区都的高度考虑进去，并调整
            result.minimum -= headerReferenceSize.height
            result.maximum -= headerReferenceSize.height
            
            //将分区的内边距考虑进去，并调整
            result.minimum -= sectionInset.top
            result.maximum += (sectionInset.top + sectionInset.bottom)
        }
        
        //返回最终的边界值
        return result
    }
}
