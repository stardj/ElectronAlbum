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
    
//    fileprivate lazy var chooseBtn: UIBarButtonItem = {
//        let btnItem = UIBarButtonItem.init(title: "choose", style: .plain, target: self, action: #selector(chooseBtnClick))
//        return btnItem
//    }()
    
//    fileprivate lazy var deleteBtn: UIButton = {
//        let btn = UIButton()
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.backgroundColor = ColorsAry.colorMe
//        btn.setTitle("DELETE", for: .normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 24)
//        btn.addTarget(self, action: #selector(deleteBtnClick), for: .touchUpInside)
//
//        self.view.addSubview(btn)
//        let width = NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0)
//        let height = NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 60)
//        let right = NSLayoutConstraint(item: btn, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
//        let bottom = NSLayoutConstraint(item: btn, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
//        btn.superview?.addConstraint(width)
//        btn.addConstraint(height)
//        btn.superview?.addConstraint(right)
//        btn.superview?.addConstraint(bottom)
//        return btn
//    }()
    
    fileprivate var chooseAry: [Int] = []
//    @objc fileprivate func deleteBtnClick() {
//        for i in chooseAry {
////            _ = PhotoModel.remove(filter: "id = \(i)")
//        }
//
//
//        SystemPhotoManager.share.deletePhotos(deleteId: chooseAry) {[weak self]
//            status in
//            guard let weakself = self else { return }
//            DispatchQueue.main.async {
//                if status {
//                    for (index, photo) in weakself.photoAry.enumerated() {
//                        if weakself.chooseAry.contains(photo.id) {
//                            weakself.photoAry.remove(at: index)
//                            weakself.chooseBtnClick()
//                        }
//                    }
//                } else {
//                    weakself.showAlert(title: "ERROR", message: "Delete failure", buttonTitle: "I Know")
//                }
//            }
//        }
//    }
    
//    @objc fileprivate func chooseBtnClick() {
//        chooseAry = []
//        collectionView.reloadData()
//
//        if getIsChooseMode() {
//            deleteBtn.isHidden = true
//            setNavigationBar(isBackShow: true, bgImgName: "bg_top_white", titleName: titleName, titleColor: UIColor.black)
//            chooseBtn.title = "choose"
//            navigationItem.rightBarButtonItems = [chooseBtn]
//        } else {
//            deleteBtn.isHidden = false
//            setNavigationBar(isBackShow: false, bgImgName: "bg_top_white", titleName: "Choose Picture", titleColor: UIColor.black)
//            chooseBtn.title = "Cancle"
//            navigationItem.rightBarButtonItems = [chooseBtn]
//        }
//    }
    
//    fileprivate func getIsChooseMode() -> Bool {
//        guard let title = chooseBtn.title else { return false }
//        return title != "choose"
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (collectionView.collectionViewLayout as? WaterFallLayout)?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(isBackShow: true, bgImgName: "bg_top_white", titleName: titleName, titleColor: UIColor.black)
//        navigationItem.rightBarButtonItems = [chooseBtn]
//        deleteBtn.isHidden = true
    }
    
    func setPhotoIdAry(titleStr: String, ary: [PhotoModel]) {
        photoAry = ary
        titleName = titleStr
    }
    
    //MARK: UICollectionViewDelegate
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotate(from: fromInterfaceOrientation)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if getIsChooseMode() {
//            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCellWithSelected {
//                cell.setSelected(isSelect: cell.tickImg.isHidden)
//                let photoId = photoAry[indexPath.row].id
//                if cell.tickImg.isHidden {
//                    if let index = chooseAry.index(of: photoId) {
//                        chooseAry.remove(at: index)
//                    }
//                } else {
//                    chooseAry.append(photoId)
//                }
//            }
//            return
//        }
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
