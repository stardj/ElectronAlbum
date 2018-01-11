//
//  WaterfallVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/2.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit

class WaterfallVC: UIViewController, UICollectionViewDataSource, WaterFallLayoutDelegate, UICollectionViewDelegate {

    fileprivate let columnCount = DeviceInfo.isPad ? 3 : 2
    
    fileprivate lazy var cellSize:CGSize = {
        let picWidth = DeviceInfo.ScreenWidth*0.33
        return CGSize(width: picWidth, height: picWidth*1.3)
    }()
    fileprivate var photoAry: [PhotoModel] = []
    fileprivate var titleName = ""
    
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var chooseAry: [Int] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        (collectionView.collectionViewLayout as? WaterFallLayout)?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(isBackShow: true, bgImgName: "bg_top_white", titleName: titleName, titleColor: UIColor.black)
    }
    
    func setPhotoIdAry(titleStr: String, ary: [PhotoModel]) {
        photoAry = ary
        titleName = titleStr
    }
    
    //MARK: UICollectionViewDelegate
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
//        super.didRotate(from: fromInterfaceOrientation)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let browserVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoBrowserVC") as? PhotoBrowserVC else { return }
        browserVC.setImgAry(ary: photoAry, index: indexPath.row)
        self.present(browserVC, animated: true, completion: nil)
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellWithSelectedID", for: indexPath) as? ImageCellWithSelected {
            let photo = photoAry[indexPath.row]
            cell.setImg(timeStamp: photo.id, isSelected: chooseAry.contains(photo.id), isThumbnail: true)
            return cell
        } else {
            return ImageCellWithSelected()
        }
    }
    
    
    //MARK: WaterFallLayoutDelegate
    func waterFall(_ collectionView: UICollectionView, layout waterFallLayout: WaterFallLayout, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let height = 150 + arc4random() % 150
        return CGFloat(height)
    }
    
    func columnOfWaterFall(_ collectionView: UICollectionView) -> Int {
        return columnCount
    }

}
