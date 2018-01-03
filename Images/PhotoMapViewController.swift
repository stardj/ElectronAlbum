//
//  PhotoMapViewController.swift
//  Images
//
//  Created by Kent on 29/12/2017.
//  Copyright © 2017 V Lanfranchi. All rights reserved.
//

import UIKit
import MapKit
import Photos
import CoreLocation

class PhotoMapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    var collectionView: UICollectionView!
    var photoAssets: PHFetchResult<AnyObject>!
    var numberOfItems: Int = 0
    
    let cellWidth: CGFloat = 100
    let cellHeight: CGFloat = 100
    var assetThumbnailSize: CGSize!
    let reuseIdentifier = "ImageCell"
    let gpsStr = "{GPS}"
    let latitudeStr = "Latitude"
    let longitudeStr = "Longitude"
    var imageWithMap: Dictionary<String, UIImage>!
    var photoAssetsWithMap: [PHAsset]!
    
    @IBOutlet weak var mapView: MKMapView!
    
   
    override func viewDidLoad() {
        self.assetThumbnailSize = CGSize(width: cellWidth, height: cellHeight)
        self.initCollectionView()
        PHCachingImageManager().startCachingImages(for: self.photoAssets.objects(at: [0, self.photoAssets.count-1]) as! [PHAsset], targetSize: self.assetThumbnailSize, contentMode: .aspectFit, options: nil)
        //self.initMapView()

        
//        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: dataModelDidUpdateNotification), object: nil)
//        ImageViewModel.sharedInstance.requestData()
    }
    
    
    
    func initCollectionView(){
        let collectionView =  UICollectionView(frame: CGRect(x: 0, y: self.view.bounds.height - cellHeight, width: self.view.bounds.width, height: cellHeight), collectionViewLayout: PhotoMapCollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.groupTableViewBackground// UIColor(displayP3Red: 0.977, green: 0.960, blue: 0.929, alpha: 0.35)
        collectionView.dataSource  = self
        collectionView.delegate = self
        collectionView.tag = 1000
        collectionView.register(PhotoMapCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        self.collectionView = collectionView
        self.view.addSubview(collectionView)
    }

    func initMapView(){
        
        self.mapView.frame(forAlignmentRect: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - cellHeight))
        if (self.photoAssets != nil && self.photoAssets.count != 0 ) {
            self.photoAssets.enumerateObjects({ (object, count, stop) in
                let photo:PHAsset = object as! PHAsset
                let imageSize = CGSize(width: photo.pixelWidth, height: photo.pixelHeight)
                PHImageManager.default().requestImage(for: photo, targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
                    if result != nil {
                        let imageManager = PHImageManager.default()
                        imageManager.requestImageData(for: photo, options: nil, resultHandler:{
                        (data, responseString, imageOriet, info) -> Void in
                            let imageData: NSData = data! as NSData
                            if let imageSource = CGImageSourceCreateWithData(imageData, nil) {
                                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary
                                if imageProperties[self.gpsStr] != nil {
                                    //self.imageWithMap[String(count)] = result
                                    print("add\(count)")
                                    self.numberOfItems += 1
                                    let annotation = MKPointAnnotation()
                                    let gps:NSDictionary  = imageProperties[self.gpsStr] as! NSDictionary
                                    let location = CLLocationCoordinate2DMake(gps[self.latitudeStr] as! CLLocationDegrees,gps[self.longitudeStr] as! CLLocationDegrees)
                                    //print("=========\(imageProperties)==========")
                                    annotation.coordinate = location
                                    annotation.title = "title"
                                    annotation.subtitle = "subtitle"
                                    self.mapView.addAnnotation(annotation)
                                    //                                    
                                    //if signFirst == false {
                                    //                                        self.mapView.setRegion(MKCoordinateRegion(center: location, span: MKCoordinateSpanMake(100, 100)), animated: true)
                                    //                                        
                                    //  signFirst = true
                                    //                                    }
                                    
                                } else {
                                    print("empty")
                                }
                            }
                        })
                        
                    }
                })
                
            })
        }
        
    }
    
    func initImage(){
        
        //var images: Array<ImageViewModel> = Array()
        var images = Dictionary<String, UIImage>()
        
        if (self.photoAssets != nil && self.photoAssets.count != 0 ) {
            self.photoAssets.enumerateObjects({ (object, count, stop) in
                let photo:PHAsset = object as! PHAsset
                let imageSize = CGSize(width: photo.pixelWidth, height: photo.pixelHeight)
                PHImageManager.default().requestImage(for: photo, targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
                    if result != nil {
                        //print(count)
                        images[String(count)] = result
                        
                    }
                    
                })
                if count == (self.photoAssets.count - 1) {
                    stop.initialize(to: true)
                    return
                }
            })
        }
        
        //print(images)
        print(images.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let locationManager = CLLocationManager()
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if  authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if authorizationStatus == .denied {
            showAlert("The location service is disabled. Please enable it in the settings")
        } else if authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        self.firstCellDefultSelected(selected: true)
        

    }
    
    func showAlert(_ title: String) {
        print(title)
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //print("how many picture\(self.imageWithMap.count)")
        if (self.photoAssetsWithMap != nil){
            return self.photoAssetsWithMap.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset: PHAsset = self.photoAssetsWithMap[indexPath.item]
        let cell:PhotoMapCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as? PhotoMapCollectionViewCell)!
        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {
            (result, info) in
                let imageManager = PHImageManager.default()
                imageManager.requestImageData(for: asset, options: nil, resultHandler:{
                    (data, responseString, imageOriet, info) -> Void in
                    let imageData: NSData = data! as NSData
                    let imageSource = CGImageSourceCreateWithData(imageData, nil)
                    let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)! as NSDictionary
                    let annotation = MKPointAnnotation()
                    let gps:NSDictionary  = imageProperties[self.gpsStr] as! NSDictionary
                    let location = CLLocationCoordinate2DMake(gps[self.latitudeStr] as! CLLocationDegrees,gps[self.longitudeStr] as! CLLocationDegrees)
                    //print("=========\(imageProperties)==========")
                    let title = ((info?["PHImageFileURLKey"] as! NSURL).lastPathComponent)
                    annotation.coordinate = location
                    annotation.title = title
                    annotation.subtitle = "subtitle"
                    self.mapView.addAnnotation(annotation)
                    cell.imageStr = title
                    cell.location = location
                })
                cell.imageView?.image = result
        })
        return cell
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //collectionView = view.viewWithTag(1000) as! UICollectionView
        self.collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - cellHeight, width: UIScreen.main.bounds.width, height: cellHeight)
        self.mapView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - cellHeight)
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.firstCellDefultSelected(selected: false)
        let cell:PhotoMapCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PhotoMapCollectionViewCell
        cell.imageView?.layer.borderWidth = 5
        self.mapView.setRegion(MKCoordinateRegion(center: cell.location!, span: MKCoordinateSpanMake(100, 100)), animated: true)
        for anno in self.mapView.annotations {
            if (anno.title! == cell.imageStr) {
                self.mapView.selectAnnotation(anno, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell:PhotoMapCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PhotoMapCollectionViewCell
        cell.imageView?.layer.borderWidth = 1
        for anno in self.mapView.annotations {
            if (anno.title! == cell.imageStr) {
                self.mapView.selectAnnotation(anno, animated: false)
            }
        }
    }
    
    func firstCellDefultSelected(selected:Bool){
        let indexPathFirstCell = IndexPath(row: 0, section: 0)
        let cell:PhotoMapCollectionViewCell = collectionView.cellForItem(at: indexPathFirstCell) as! PhotoMapCollectionViewCell
        if selected == true {
            cell.imageView?.layer.borderWidth = 5
        } else {
            cell.imageView?.layer.borderWidth = 1
        }
//        for anno in self.mapView.annotations {
//            if (anno.title! == cell.imageStr) {
        self.mapView.setRegion(MKCoordinateRegion(center: cell.location!, span: MKCoordinateSpanMake(100, 100)), animated: true)
        
        for anno in self.mapView.annotations {
            if (anno.title! == cell.imageStr) {
                self.mapView.selectAnnotation(anno, animated: true)
            }
        }
//            }
//        }
            //
    }
    
}
