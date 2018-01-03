//
//  PhotoDetailsViewController.swift
//  Images
//
//  Created by V Lanfranchi on 15/11/2017.
//  Copyright © 2017 V Lanfranchi. All rights reserved.
//

import UIKit
import Photos
import MapKit
import CoreLocation

class PhotoDetailsViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var metadataTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    var photo: PHAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHImageManager.default().requestImage(for: self.photo, targetSize: self.photoView.frame.size, contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
            if result != nil {
                self.photoView.image = result
                let imageManager = PHImageManager.default()
                imageManager.requestImageData(for: self.photo, options: nil, resultHandler:{
                    (data, responseString, imageOriet, info) -> Void in
                    let imageData: NSData = data! as NSData
                    if let imageSource = CGImageSourceCreateWithData(imageData, nil) {
                        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary
                        self.metadataTextView.text = imageProperties.description
                        self.showMapInfo(imageProperties: imageProperties)
                        print(imageProperties.description)
                    }
                })
                
                
            }
        })
        
    }
    
    func showMapInfo(imageProperties:NSDictionary) {
        if imageProperties["{GPS}"] != nil {
            let annotation = MKPointAnnotation()
            //print(self.photo.location)
            //location(gps["Latitude"], gps["Longitude"])
            let gps:NSDictionary  = imageProperties["{GPS}"] as! NSDictionary
            let location = CLLocationCoordinate2DMake(gps["Latitude"] as! CLLocationDegrees,gps["Longitude"] as! CLLocationDegrees)
            //print(imageProperties)
            annotation.coordinate = location
            annotation.title = "kkk"
            annotation.subtitle = "..."
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: true)
            print(annotation.coordinate.latitude)
            print(annotation.coordinate.longitude)
        } else {
            self.mapView.isHidden = true
        }
    }
    
}
