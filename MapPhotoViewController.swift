//
//  MapTableViewController.swift
//  Images
//
//  Created by Kent on 21/12/2017.
//  Copyright © 2017 V Lanfranchi. All rights reserved.
//

import UIKit
import Photos
import MapKit
import CoreLocation

class MapPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var cameraRoll: PHAssetCollection!
    var photoAssets: PHFetchResult<AnyObject>!
    var assetThumbnailSize: CGSize!
    var numberOfItems: Int = 0
    
    //let UICollectionViewDelegate

    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    private let cellWidth: CGFloat = 100
    private let cellHeight: CGFloat = 100
    private let reuseIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.mapView.delegate = self
        self.mapView.mapType = MKMapType.standard
        var signFirst = false
        
        if (self.mapView.annotations.count == 0) {
            self.photoAssets.enumerateObjects({ (object, count, stop) in
                let photo:PHAsset = object as! PHAsset
                let imageSize = CGSize(width: photo.pixelWidth,
                                       height: photo.pixelHeight)
                PHImageManager.default().requestImage(for: photo, targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
                    if result != nil {
                        //                    self.photoView.image = result
                        let imageManager = PHImageManager.default()
                        imageManager.requestImageData(for: photo, options: nil, resultHandler:{
                            (data, responseString, imageOriet, info) -> Void in
                            let imageData: NSData = data! as NSData
                            if let imageSource = CGImageSourceCreateWithData(imageData, nil) {
                                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary
                                if imageProperties["{GPS}"] != nil {
                                    let annotation = MKPointAnnotation()
                                    let gps:NSDictionary  = imageProperties["{GPS}"] as! NSDictionary
                                    let location = CLLocationCoordinate2DMake(gps["Latitude"] as! CLLocationDegrees,gps["Longitude"] as! CLLocationDegrees)
                                    print(imageProperties)
                                    annotation.coordinate = location
                                    annotation.title = "title"
                                    annotation.subtitle = "subTitle"
                                    self.mapView.addAnnotation(annotation)
                                    if signFirst == false {
                                        self.mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpanMake(100, 100)), animated: true)
                                        signFirst = true
                                    }
                                } else {
                                    //self.mapView.isHidden = true
                                }
                            }
                        })
                    }
                })
            })
        }
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // Do any additional setup after loading the view, typically from a nib
        
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        
//        let flowLayout = MapPhotoCollectionViewLayout()
//        //flowLayout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 50)
//        flowLayout.itemSize = CGSize(width: screenWidth, height: screenWidth)
//        self.assetThumbnailSize = flowLayout.itemSize
//        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - cellHeight, width: UIScreen.main.bounds.width, height: cellHeight)
//        flowLayout.scrollDirection = .horizontal
//        flowLayout.minimumInteritemSpacing = 0
//        flowLayout.minimumLineSpacing = 0
//        //let cellSize = flowLayout.itemSize
//        let collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
//        collectionView.collectionViewLayout = flowLayout
//        
//        //let collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
//        collectionView.register(MapPhotoCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
//        //collectionView.decelerationRate = UIScrollViewDecelerationRateFast
//        collectionView.backgroundColor = .clear
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.tag = 100
//        view.addSubview(collectionView)
        
        PHCachingImageManager().startCachingImages(for: self.photoAssets.objects(at: [0, self.photoAssets.count-1]) as! [PHAsset], targetSize: self.assetThumbnailSize, contentMode: .aspectFit, options: nil)

        
    }

    override func viewWillLayoutSubviews() {
        let collectionView:UICollectionView = view.viewWithTag(100) as! UICollectionView
        collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - cellHeight, width: UIScreen.main.bounds.width, height: cellHeight)
        collectionView.tag = 100
        view.addSubview(collectionView)

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if  authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if authorizationStatus == .denied {
            showAlert("The location service is disabled. Please enable it in the settings")
        } else if authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func showAlert(_ title: String) {
        print(title)
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    private let numberOfItems: Int = 30
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return numberOfItems + 1
//    }
    
    func numberOfItemsInSection(section: Int)-> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.photoAssets != nil){
            self.numberOfItems = self.photoAssets.count
            return self.photoAssets.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let asset: PHAsset = self.photoAssets[indexPath.item] as! PHAsset
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as? PhotoMapCollectionViewCell
        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {
            (result, info) in
            if result != nil {
                //cell?.photoView.image = result
            }
        })
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout

        //间隔
        
        let spacing:CGFloat = 0
        
        //水平间隔
        
        layout.minimumInteritemSpacing = spacing
        let columnsNum = 1        //垂直行间距
        
        layout.minimumLineSpacing = spacing
        let collectionViewWidth = collectionView.bounds.width
        
        let leftGap = (collectionViewWidth - spacing * CGFloat(columnsNum-1)
            
            - CGFloat(columnsNum) * layout.itemSize.width) / 2
        
        print(leftGap)
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
        
        return cell!
    }

    
    // MARK: - Collection view flow layout delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        switch indexPath.item {
//        case self.numberOfItems:
//            let n = Int(UIScreen.main.bounds.width / cellWidth)
//            let d = UIScreen.main.bounds.width - cellWidth * CGFloat(n)
//            return CGSize(width: d, height: cellHeight)
//        default:
//            return CGSize(width: cellWidth, height: cellHeight)
//        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: - Scroll view delegate
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let x = targetContentOffset.pointee.x
//        let pageWidth = cellWidth
//        var index = Int(x / pageWidth)
//        let divideX = CGFloat(index) * pageWidth + pageWidth * 0.5
//        if x > divideX {
//            index += 1
//        }
//        targetContentOffset.pointee.x = pageWidth * CGFloat(index)
    }
    
    
}
