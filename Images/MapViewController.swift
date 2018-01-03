//
//  MapViewController.swift
//  Images
//
//  Created by Kent on 18/12/2017.
//  Copyright © 2017 V Lanfranchi. All rights reserved.
//

import UIKit
import Photos
import MapKit
import CoreLocation

class MapViewController: UITableViewController, MKMapViewDelegate {

    var cameraRoll: PHAssetCollection!
    var photoAssets: PHFetchResult<AnyObject>!
    
    @IBOutlet weak var photo: UIImage!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.mapView.mapType = MKMapType.standard
        self.tableView.delegate = self
        var signFirst = false
      
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        navigationController?.pushViewController(MapPhotoCollectionViewController(), animated: true)
//    }
//    


}



