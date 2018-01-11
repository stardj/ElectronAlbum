//
//  PhotoBrowserVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/12/16.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//

import UIKit

class PhotoBrowserVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate{
    fileprivate func getCellSize() -> CGSize {
        return CGSize(width: DeviceInfo.getScreenWidth(), height: DeviceInfo.getScreenHeight())
    }
    
    fileprivate var photoAry: [PhotoModel] = []
    fileprivate var curIndex = 0
    fileprivate var isAppeared = false

    fileprivate lazy var detailBtn: UIButton = {
        let size = CGSize(width: 60, height: 60)
        let btn = UIButton(frame: CGRect(x: DeviceInfo.getScreenWidth()-size.width-5, y: DeviceInfo.getScreenHeight()/2-size.height, width: size.width, height: size.height))
        btn.setBackgroundImage(UIImage(named: "detail_icon"), for: .normal)
        btn.addTarget(self, action: #selector(detailBtnClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    @IBOutlet weak var collectionView: UICollectionView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    func setImgAry(ary: [PhotoModel], index: Int) {
        photoAry = ary
        curIndex = index
    }

    @objc fileprivate func detailBtnClick() {
        Tools.addDetailView(photo: photoAry[curIndex])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isPagingEnabled = true
        collectionView.bounces = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(detailBtn)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.scrollToItem(at: IndexPath.init(row: curIndex, section: 0), at: UICollectionViewScrollPosition.right, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isAppeared = true
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
//        super.didRotate(from: fromInterfaceOrientation)
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDelegate Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageBaseCellID", for: indexPath) as? ImageBaseCell else { return UICollectionViewCell() }
        let photoId = photoAry[indexPath.row].id
        cell.setImg(timeStamp: photoId, isThumbnail: false, isFit: true)
        if isAppeared {
            curIndex = indexPath.row
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let transform = CGAffineTransform(rotationAngle: 0)
        let onceImageViewHistoryRect = CGRect(x: 0, y: 0, width: DeviceInfo.getScreenWidth(), height: DeviceInfo.getScreenHeight())
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.transform = transform
            self.view.frame = onceImageViewHistoryRect
        }, completion: { (finished) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard curIndex < photoAry.count && curIndex >= 0 else {
            return
        }
    }
    
}

extension PhotoBrowserVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YHJPresentAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YHJDismissAnimator()
    }
}

