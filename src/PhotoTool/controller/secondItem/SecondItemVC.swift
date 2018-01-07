//
//  SecondItemVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/2.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class SecondItemVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    fileprivate var photoAry: [PhotoModel] = []
    
    fileprivate lazy var cellSize:CGSize = {
        return CGSize(width: 85, height: 100)
    }()
    
    fileprivate lazy var leftBtn: UIBarButtonItem = {
        let item = UIBarButtonItem.init(title: "Exit", style: .plain, target: self, action: #selector(returnBtnDismiss))
        return item
    }()
    
    fileprivate var annotaionView: MKAnnotationView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setStatusBarStyle(isDefault: false)
        setNavigationBar(isBackShow: false, bgImgName: "", titleName: PageTitle.Map, titleColor: UIColor.black)
        navigationItem.leftBarButtonItems = [leftBtn]
        
        loadData()
        addAnnotation()
        collectionView.reloadData()
    }
    
    fileprivate func loadData() {
        photoAry = PhotoModel.rows(filter: "addr is not null", order: "id DESC") as? [PhotoModel] ?? []
    }
    
    fileprivate func addAnnotation() {
        for photo in photoAry {
            if let post = photo.getPosition(){
                let p = PhotoAnnoation.init(coordinate: post)
                p.photoId = photo.id
                mapView.addAnnotation(p)
                mapView.region = MKCoordinateRegionMake(post,MKCoordinateSpanMake(0.5, 0.5))
                return
            }
        }
    }
    
    // MARK: UICollectionViewDelegate Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageBaseCellID", for: indexPath) as? ImageBaseCell else { return UICollectionViewCell() }
        let photoId = photoAry[indexPath.row].id
        cell.setImg(timeStamp: photoId, isThumbnail: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photoAry[indexPath.row]
        guard let post = photo.getPosition() else {
            showAlert(title: "Warning", message: "This picture has no address information", buttonTitle: "ok")
            return
        }
        annotaionView?.annotation = PhotoAnnoation(coordinate: post, photoId: photo.id)
    }
    
    // MKMapViewDelegate
    //显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象.1)该方法首先显示大头针的时候会调用2)向地图上添加大头针的时候也会调用
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? PhotoAnnoation {
            annotaionView = PhotoAnnotationView.create(mapView: mapView)
            annotaionView?.annotation = annotation
        }

        return annotaionView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("kkkkkkkkkkkkkkk")
    }
}

class PhotoAnnoation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    var photoId: Int?
    convenience init(coordinate: CLLocationCoordinate2D, photoId: Int) {
        self.init(coordinate: coordinate)
        self.photoId = photoId
    }
    
}

class PhotoAnnotationView: MKPinAnnotationView {
    lazy var btnView: UIButton = {
        let width = 80
        let img = UIButton(frame: CGRect(x: -width/2, y: -width, width: width, height: width))
        self.addSubview(img)
        return img
    }()
    
    override var annotation: MKAnnotation?{
        willSet(callOutAnnotation){
            if let callOutAnnotation = callOutAnnotation as? PhotoAnnoation,
                let photoId = callOutAnnotation.photoId {
                DispatchQueue.main.async {
        self.btnView.setBackgroundImage(Tools.getImage(timeStamp: photoId, isThumbnail: true), for: .normal)
                }
            }
        }
    }
    
    //#MARK: 创建弹出视图
    class func create(mapView: MKMapView)-> PhotoAnnotationView? {
        let indentifier = "PhotoAnnotationView"
        var calloutView = mapView.dequeueReusableAnnotationView(withIdentifier: indentifier) as? PhotoAnnotationView
        if calloutView == nil{
            let calloutViewT = PhotoAnnotationView()
//            calloutViewT.tit
//            calloutViewT.canShowCallout = true
            calloutViewT.pinTintColor = UIColor.blue
            calloutViewT.isHidden = false
            calloutView = calloutViewT
        }
        return calloutView!
    }
    
}


