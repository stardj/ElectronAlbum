//
//  MapVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/2.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class MapVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    fileprivate var photoAry: [PhotoModel] = []
    fileprivate var groups: [BaseGroup] = []
    fileprivate var curIndex = 0
    
    fileprivate var annotaionViewDic: [String: PhotoAnnotationView?] = [:]
    fileprivate lazy var cellSize:CGSize = {
        return CGSize(width: 85, height: 90)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setStatusBarStyle(isDefault: false)
        setNavigationBar(isBackShow: false, bgImgName: "", titleName: PageTitle.Map, titleColor: UIColor.black)
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    fileprivate func loadData() {
        curIndex = 0
        photoAry = []
        groups = []
        annotaionViewDic = [:]

        for (_, value) in annotaionViewDic {
                if let annoview = value {
                    annoview.removeFromSuperview()
                }
        }
        let addrs = PhotoModel.getDifferValues(columnName: "addr", order: "id DESC")
        
        for item in addrs {
            if item == "" {
                continue
            }
            if let ary = PhotoModel.rows(filter: "addr = '\(item)'") as? [PhotoModel] {
                photoAry += ary
                let group = BaseGroup(groupTitle: item, photos: ary)
                groups.append(group)
                addAnnotation(group: group)
            }
        }
        
        let positonAry = PhotoModel.getDifferValues(columnName: "position", filter: "addr = ''", order: "id DESC")
        if positonAry.count > 0 {
            let addrs = PhotoModel.getDifferValues(columnName: "position", order: "id DESC")
            for item in addrs {
                if item == "" {
                    continue
                }
                if let ary = PhotoModel.rows(filter: "position = '\(item)'") as? [PhotoModel] {
                    photoAry += ary
                    let group = BaseGroup(groupTitle: item, photos: ary)
                    groups.append(group)
                    addAnnotation(group: group)
                }
            }
        }
        
        collectionView.reloadData()
        if photoAry.count > curIndex, let pose = photoAry[curIndex].getPosition() {
            mapView.region = MKCoordinateRegion(center: pose, span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20))
        }
    }
    
    fileprivate func addAnnotation(group: BaseGroup) {
        guard let fPhoto = group.photos.first as? PhotoModel , fPhoto.id > 0 else {
            return
        }
        var isSelect = false
        if photoAry.count > curIndex, photoAry[curIndex].position == fPhoto.position {
            isSelect = true
        }
        let annoation = PhotoGroupAnnoation(group: group, isSelect: isSelect)
        mapView.addAnnotation(annoation)
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
        cell.backgroundColor = (curIndex == indexPath.row) ?  UIColor.blue : UIColor.white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photoAry[indexPath.row]
        for (key, value) in annotaionViewDic {
            if key == photo.addr || key == photo.position {
                if let annoview = value {
                    annoview.changeImg(photoId: photo.id)
                    annoview.setImgStatus(isSelected: true)
                }
            } else {
                if let annoview = value {
                    annoview.setImgStatus(isSelected: false)
                }
            }
        }
        if let pose = photo.getPosition() {
            mapView.setRegion(MKCoordinateRegion.init(center: pose, span: MKCoordinateSpanMake(10, 10)), animated: true)
        }
        if  curIndex != indexPath.row {
            curIndex = indexPath.row
            collectionView.reloadData()
        }
    }
    
    // MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotaionView: MKAnnotationView?
        if let annotationT = annotation as? PhotoGroupAnnoation {
            annotaionView = PhotoAnnotationView.create(mapView: mapView)
            annotaionView?.annotation = annotationT
            if var groupTitle = annotationT.title, let view = annotaionView as? PhotoAnnotationView {
                if groupTitle == "" {
                    groupTitle = "\(annotationT.coordinate.latitude),\(annotationT.coordinate.longitude)"
                }
                annotaionViewDic[groupTitle] = view
                if photoAry.count > curIndex {
                    if groupTitle == photoAry[curIndex].addr {
                        view.setImgStatus(isSelected: true)
                    }
                }
            }
        }
        return annotaionView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let anno = view as? PhotoAnnotationView, let group = anno.group, let photos = group.photos as? [PhotoModel], let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "WaterfallVC") as? WaterfallVC {
            nextVC.setPhotoIdAry(titleStr: group.groupTitle, ary: photos)
            self.navigationController?.pushViewController(nextVC
                , animated: true)
        }
    }
    
}


class PhotoAnnoation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var photoId: Int?
    var title: String?
    init(coordinate: CLLocationCoordinate2D, photoId: Int, title: String) {
        self.coordinate = coordinate
        self.photoId = photoId
        self.title = title
        super.init()
    }
}

class PhotoGroupAnnoation: NSObject, MKAnnotation {
    fileprivate var group: BaseGroup
    var coordinate: CLLocationCoordinate2D
    fileprivate var photoId: Int?
    var title: String?
    fileprivate var isSelect: Bool
    init(group: BaseGroup, isSelect: Bool) {
        let photo = group.photos[0]
        let pose = photo?.getPosition()
        self.group = group
        self.coordinate = pose!
        self.photoId = photo?.id
        self.title = group.groupTitle
        self.isSelect = isSelect
        super.init()
    }
}


class PhotoAnnotationView: MKPinAnnotationView {
    fileprivate let imgW: CGFloat = 70
    fileprivate let spacing: CGFloat = 6
    fileprivate let labelW: CGFloat = 30

    fileprivate var group: BaseGroup?
    fileprivate lazy var btnView: UIImageView = {
        let img = UIImageView(frame: CGRect(x: -imgW/2, y: -imgW+10, width: imgW, height: imgW))
        if let count = group?.photos.count {
            let label = UILabel(frame: CGRect(x: imgW-labelW, y: 0, width: labelW, height: labelW))
            label.textAlignment = .center
            label.textColor = UIColor.blue
            label.backgroundColor = UIColor.yellow
            label.text = "\(count)"
            img.addSubview(label)
        }
        self.insertSubview(img, at: 1)
        return img
    }()
    
    fileprivate lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: -imgW/2-5, y: -imgW+10-spacing, width: imgW+2*spacing, height: imgW+2*spacing))
        view.backgroundColor = UIColor.blue
        self.insertSubview(view, at: 0)
        return view
    }()
    
    override var annotation: MKAnnotation?{
        willSet(callOutAnnotation){
            if let callOutAnnotation = callOutAnnotation as? PhotoGroupAnnoation {
                DispatchQueue.main.async {
                    let groupT = callOutAnnotation.group
                    self.group = groupT
                    guard let photo = groupT.photos.first, let photoId = photo?.id else { return }
                    self.backView.isHidden = !callOutAnnotation.isSelect
                    self.btnView.setImage(timeStamp: photoId, isThumbnail: true)
                }
            } else if let callOutAnnotation = callOutAnnotation as? PhotoAnnoation {
                DispatchQueue.main.async {
                    guard let photoId = callOutAnnotation.photoId else { return }
                    self.btnView.setImage(timeStamp: photoId, isThumbnail: true)
                }
            }
        }
    }
    
    func changeImg(photoId: Int) {
        btnView.setImage(timeStamp: photoId, isThumbnail: true)
    }
    
    func setImgStatus(isSelected: Bool) {
        backView.backgroundColor = isSelected ? UIColor.blue : UIColor.clear
    }
    
    class func create(mapView: MKMapView)-> PhotoAnnotationView? {
        let indentifier = "PhotoAnnotationView"
        var calloutView = mapView.dequeueReusableAnnotationView(withIdentifier: indentifier) as? PhotoAnnotationView
        if calloutView == nil{
            let calloutViewT = PhotoAnnotationView()
            calloutViewT.canShowCallout = true
            calloutViewT.pinTintColor = UIColor.red
            calloutViewT.isHidden = false
            calloutView = calloutViewT
        }
        return calloutView!
    }
    
}


