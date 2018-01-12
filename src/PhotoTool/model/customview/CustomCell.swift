//
//  CustomCell.swift
//  PhotoTool
//
//  Created by  YH_Jiang L_Zhang ZMX_Wang on 2018/1/2.
//  Copyright © 2018 year  YH_Jiang L_Zhang ZMX_Wang. All rights reserved.
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
    //waterFall columns
    @objc optional func columnOfWaterFall(_ collectionView: UICollectionView) -> Int
    //each item's height
    @objc optional func waterFall(_ collectionView: UICollectionView, layout waterFallLayout: WaterFallLayout, heightForItemAt indexPath: IndexPath) -> CGFloat
}


class WaterFallLayout: UICollectionViewLayout {
    
    //dalegate
    weak var delegate: WaterFallLayoutDelegate?
    //line space
    @IBInspectable var lineSpacing: CGFloat   = 0
    //column space
    @IBInspectable var columnSpacing: CGFloat = 0
    //section's top
    @IBInspectable var sectionTop: CGFloat    = 0 {
        willSet {
            sectionInsets.top = newValue
        }
    }
    //section's Bottom
    @IBInspectable var sectionBottom: CGFloat  = 0 {
        willSet {
            sectionInsets.bottom = newValue
        }
    }
    //section left
    @IBInspectable var sectionLeft: CGFloat   = 0 {
        willSet {
            sectionInsets.left = newValue
        }
    }
    //section right
    @IBInspectable var sectionRight: CGFloat  = 0 {
        willSet {
            sectionInsets.right = newValue
        }
    }
    //section Insets
    @IBInspectable var sectionInsets: UIEdgeInsets      = UIEdgeInsets.zero
    
    // the height for each lines
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
            
            // get the items' attributes by indexPath
            let att = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            //get the width of collectionView
            let width = collectionView.frame.width
            if let columnCount = delegate?.columnOfWaterFall?(collectionView) {
                guard columnCount > 0 else {
                    return nil
                }
                //item width = (collectionView width - sectionInsets space & line space) / column sum
                let totalWidth  = (width - sectionInsets.left - sectionInsets.right - (CGFloat(columnCount) - 1) * columnSpacing)
                let itemWidth   = totalWidth / CGFloat(columnCount)
                //get item height by outside caculation
                let itemHeight  = delegate?.waterFall?(collectionView, layout: self, heightForItemAt: indexPath) ?? 0
                //find the shortest column
                var minIndex = 0
                for column in columnHeights {
                    if column.value < columnHeights[minIndex] ?? 0 {
                        minIndex = column.key
                    }
                }
                
                // caculated the item's x by the shortest column space
                let itemX  = sectionInsets.left + (columnSpacing + itemWidth) * CGFloat(minIndex)
                
                //item's y = the biggest y of the shortest columns + line space
                let itemY  = (columnHeights[minIndex] ?? 0) + lineSpacing
                //set attributes frame
                att.frame  = CGRect.init(x: itemX, y: itemY, width: itemWidth, height: itemHeight)
                
                //update the biggest y in dictionary
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


//customized the sticky headers layout by using collection view
class StickyHeadersFlowLayout: UICollectionViewFlowLayout {
    
    
    //Relayout when the boundary is changed (The view is also called when the view is scrolling)
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    //Location attributes of all elements
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
            
            //Get all the default element attributes from the parent class
            guard let layoutAttributes = super.layoutAttributesForElements(in: rect)
                else { return nil }
            
            //It is used to store the new layout properties of the element and finally returns this
            var newLayoutAttributes = [UICollectionViewLayoutAttributes]()
            
            // Which section is stored for each layout attributes
            let sectionsToAdd = NSMutableIndexSet()
            
            //Circular old element layout attributes
            for layoutAttributesSet in layoutAttributes {
                //if the element is cell
                if layoutAttributesSet.representedElementCategory == .cell {
                    //Add the layout to the newLayoutAttributes
                    newLayoutAttributes.append(layoutAttributesSet)
                } else if layoutAttributesSet.representedElementCategory == .supplementaryView {
                    //Store the corresponding section into the sectionsToAdd
                    sectionsToAdd.add(layoutAttributesSet.indexPath.section)
                }
            }
            
            //Traversing sectionsToAdd, supplemental views use the correct layout properties
            for section in sectionsToAdd {
                let indexPath = IndexPath(item: 0, section: section)
                
                //Add the header layout property
                if let headerAttributes = self.layoutAttributesForSupplementaryView(ofKind:
                    UICollectionElementKindSectionHeader, at: indexPath) {
                    newLayoutAttributes.append(headerAttributes)
                }
                
                //Add the tail layout property
                if let footerAttributes = self.layoutAttributesForSupplementaryView(ofKind:
                    UICollectionElementKindSectionFooter, at: indexPath) {
                    newLayoutAttributes.append(footerAttributes)
                }
            }
            
            return newLayoutAttributes
    }
    
    //Add the layout properties of the view
    //this is handled to implement the sticky header,so that the header is always at the top of the group visual area
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //Get the layout properties of the supplementary view first from the parent class
        guard let layoutAttributes = super.layoutAttributesForSupplementaryView(ofKind:
            elementKind, at: indexPath) else { return nil }
        
        //Return directly if not the head view
        if elementKind != UICollectionElementKindSectionHeader {
            return layoutAttributes
        }
        
        //Get the corresponding boundary range based on the section index
        guard let boundaries = boundaries(forSection: indexPath.section)
            else { return layoutAttributes }
        guard let collectionView = collectionView else { return layoutAttributes }
        
        //Save the offset in the vertical direction in the view
        let contentOffsetY = collectionView.contentOffset.y
        //Frame to supplement the view
        var frameForSupplementaryView = layoutAttributes.frame
        
        //The maximum minimum value for calculating the vertical direction of a packet head
        let minimum = boundaries.minimum - frameForSupplementaryView.height
        let maximum = boundaries.maximum - frameForSupplementaryView.height
        
        //If the vertical offset of the content area is smaller than the minimum position of the packet head,
        //the group head is placed at its minimum position
        if contentOffsetY < minimum {
            frameForSupplementaryView.origin.y = minimum
        }
        //If the vertical offset of the content area is larger than the minimum position of the packet head,
        //the group head is placed at its maximum position
        else if contentOffsetY > maximum {
            frameForSupplementaryView.origin.y = maximum
        }
        
        //If they are not satisfied, the vertical cheapest amount of the content area falls within the boundary of the head of the group.
        //Set the header of the packet to the content offset so that the header is fixed at the top of the collection view
        else {
            frameForSupplementaryView.origin.y = contentOffsetY
        }
        
        //Update the layout properties and return
        layoutAttributes.frame = frameForSupplementaryView
        return layoutAttributes
    }
    
    //Get the corresponding boundary range (return a tuple) according to the section index.
    func boundaries(forSection section: Int) -> (minimum: CGFloat, maximum: CGFloat)? {
        //Save the return result
        var result = (minimum: CGFloat(0.0), maximum: CGFloat(0.0))
        
        //If the collectionView attribute is nil, the direct fanhui
        guard let collectionView = collectionView else { return result }
        
        //Get the number of items in the partition
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        //If the project is 0, it returns directly
        guard numberOfItems > 0 else { return result }
        
        //Get the first and the last item layout attributes from flow layout attributes
        let first = IndexPath(item: 0, section: section)
        let last = IndexPath(item: (numberOfItems - 1), section: section)
        if let firstItem = layoutAttributesForItem(at: first),
            let lastItem = layoutAttributesForItem(at: last) {
            //The minimum and maximum value of the region boundary respectively
            result.minimum = firstItem.frame.minY
            result.maximum = lastItem.frame.maxY
            
            //Take the height of the partition into consideration and adjust
            result.minimum -= headerReferenceSize.height
            result.maximum -= headerReferenceSize.height
            
            //Take the inner margins of the partition into consideration and adjust
            result.minimum -= sectionInset.top
            result.maximum += (sectionInset.top + sectionInset.bottom)
        }
        
        //Return the final boundary value
        return result
    }
}
