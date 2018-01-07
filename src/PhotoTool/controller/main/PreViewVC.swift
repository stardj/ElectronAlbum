//
//  PreViewVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/11/24.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//

import UIKit
import MapKit
import Photos
import AVFoundation

class PreViewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var pictureCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
//    fileprivate var imgAry: [String] = ["https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=644701570,1471147815&fm=27&gp=0.jpg", "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1187077172,2563639533&fm=200&gp=0.jpg", "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3565185884,2248353566&fm=27&gp=0.jpg", "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3430625942,2154503364&fm=27&gp=0.jpg", "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=1325447658,3557924380&fm=27&gp=0.jpg", "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2909352837,4034562327&fm=27&gp=0.jpg", "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=216557540,268792798&fm=200&gp=0.jpg", "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3033037990,1425076943&fm=200&gp=0.jpg"]
    fileprivate var imgAry: [Int] = [1514720372, 1514720374, 1514720375, 1514720421, 1514720422, 1514720424, 1514720425, 1514720427]
    
    fileprivate lazy var cellSize:CGSize = {
        let picWidth = 150 * DeviceInfo.ScaleSizeW
        if DeviceInfo.isPadPro {
            return CGSize(width: 270, height: 361)
        }
        return CGSize(width: picWidth, height: picWidth*1.3)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        setStatusBarStyle(isDefault: false)
        setNavigationBar(isBackShow: false, bgImgName: "bg_top_blue", titleName: "照片管家", titleColor: UIColor.white)
        let rightBtn = UIBarButtonItem.init(title: "📷", style: .plain, target: self, action: #selector(takePhotoBtnClick))
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItems = [rightBtn]
        
        let leftBtn = UIBarButtonItem.init(title: "Exit", style: .plain, target: self, action: #selector(exitBtnClick))
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.leftBarButtonItems = [leftBtn]
    }

    @IBAction func gridCheckClick(_ sender: UIButton) {
        
    }
    
    @IBAction func mapCheckClick(_ sender: UIButton) {
        
    }
    
    @objc fileprivate func takePhotoBtnClick() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
//            print("111111111111")
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        //设置图片来源
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        //模态弹出ImagePickerView
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc fileprivate func exitBtnClick() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    // MARK: UICollectionViewDelegate Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgAry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCellID", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        let imgName = imgAry[indexPath.row]
        cell.setImg(timeStamp: imgName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    func setImg(timeStamp: Int) {
        imgView.setImage(timeStamp: timeStamp)
    }
}
