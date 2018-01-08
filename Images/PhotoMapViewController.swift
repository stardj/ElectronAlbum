//
//  PhotoMapViewController.swift
//  Images
//
//  Created by Lei Zhang on 29/12/2017.
//  Copyright © 2017 Lei Zhang, Zhiminxing Wang, Yinghui Jiang. All rights reserved.
//
import UIKit
import MapKit
import Photos
import CoreLocation

class PhotoMapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    var collectionView: UICollectionView!
    var photoAssets: PHFetchResult<AnyObject>!
    var numberOfItems: Int = 0
    var photoAssetsWithMap: [PHAsset]!
    var annotationPreSearch:MKPointAnnotation!
    var assetThumbnailSize: CGSize!
    let cellWidth: CGFloat = 100
    let cellHeight: CGFloat = 100
    let reuseIdentifier = "ImageCell"
    let gpsStr = "{GPS}"
    let latitudeStr = "Latitude"
    let longitudeStr = "Longitude"
    
    @IBOutlet weak var mapView: MKMapView!
    
    //Define search bar
    @IBAction func searchBtn(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    //Search location in the map
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if self.annotationPreSearch != nil {
            self.mapView.removeAnnotation(self.annotationPreSearch)
        }
        
        //Ignoring events from user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Define an Activity Indicator View
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        //Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Create the search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start {(response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil {
                self.showAlert("The location cannot be found.")
            } else {
                
                //Get location data via input
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                //Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.annotationPreSearch = annotation
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: true)
                
                //Zoom in an annotation
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpanMake(100, 100)
                let region = MKCoordinateRegionMake(coordinate, span)
                self.mapView.setRegion(region, animated: true)
                
            }
        
        }
        
    }
   
    //Init collection view
    override func viewDidLoad() {
        self.assetThumbnailSize = CGSize(width: cellWidth, height: cellHeight)
        self.initCollectionView()
        PHCachingImageManager().startCachingImages(for: self.photoAssets.objects(at: [0, self.photoAssets.count-1]) as! [PHAsset], targetSize: self.assetThumbnailSize, contentMode: .aspectFit, options: nil)
    }
    
    //Define a collection view and add it to view
    func initCollectionView(){
        let collectionView =  UICollectionView(frame: CGRect(x: 0, y: self.view.bounds.height - cellHeight, width: self.view.bounds.width, height: cellHeight), collectionViewLayout: PhotoMapCollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.groupTableViewBackground
        collectionView.dataSource  = self
        collectionView.delegate = self
        collectionView.tag = 1000
        collectionView.register(PhotoMapCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        self.collectionView = collectionView
        self.view.addSubview(collectionView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Judge if a location service is enabled
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let locationManager = CLLocationManager()
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if  authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if authorizationStatus == .denied {
            showAlert("The location service is disabled. Please enable it in the settings.")
        } else if authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        self.firstCellDefultSelected(selected: true)
    }
    
    //Define an alert function
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
        if (self.photoAssetsWithMap != nil){
            return self.photoAssetsWithMap.count
        }
        return 0
    }
    
    //Show pictures in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoMapCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as? PhotoMapCollectionViewCell)!
        self.addLocationInfo(cell: cell, asset: self.photoAssetsWithMap[indexPath.item])
        return cell
    }

    //Add locations for pictures in the map
    func addLocationInfo(cell: PhotoMapCollectionViewCell, asset: PHAsset) {
        if (self.photoAssetsWithMap != nil) {
            let asset: PHAsset = asset
            PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {
                (result, info) in
                var imageVModel = ImageViewModel()
                let imageManager = PHImageManager.default()
                imageManager.requestImageData(for: asset, options: nil, resultHandler:{
                    (data, responseString, imageOriet, info) -> Void in
                    let imageData: NSData = data! as NSData
                    let imageSource = CGImageSourceCreateWithData(imageData, nil)
                    let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)! as NSDictionary
                    let annotation = MKPointAnnotation()
                    let gps:NSDictionary  = imageProperties[self.gpsStr] as! NSDictionary
                    let location = CLLocationCoordinate2DMake(gps[self.latitudeStr] as! CLLocationDegrees,gps[self.longitudeStr] as! CLLocationDegrees)
                    let title = ((info?["PHImageFileURLKey"] as! NSURL).lastPathComponent)
                    annotation.coordinate = location
                    annotation.title = title
                    annotation.subtitle = "subtitle"
                    self.mapView.addAnnotation(annotation)
                    cell.imageStr = title
                    imageVModel.title = title!
                    imageVModel.location = location
                })
                imageVModel.image = result!
                cell.imageView?.image = imageVModel.image
                cell.imageVModel = imageVModel
            })
        }
    }
    
    
    //Adjust the layout position when in different transition
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - cellHeight, width: UIScreen.main.bounds.width, height: cellHeight)
        self.mapView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - cellHeight)
        
    }
    
    //Define the layout for the selected cell and show the annotation of the picture in the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.firstCellDefultSelected(selected: false)
        let cell:PhotoMapCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PhotoMapCollectionViewCell
        cell.imageView?.layer.borderWidth = 5
        self.mapView.setRegion(MKCoordinateRegion(center: (cell.imageVModel?.location)!, span: MKCoordinateSpanMake(100, 100)), animated: true)
        for anno in self.mapView.annotations {
            if (anno.title! == cell.imageVModel?.title) {
                self.mapView.selectAnnotation(anno, animated: true)
            }
        }
    }
    
    //Define the layout when unselecting a cell
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) != nil{
            let cell:PhotoMapCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PhotoMapCollectionViewCell
            cell.imageView?.layer.borderWidth = 1
            for anno in self.mapView.annotations {
                if (anno.title! == cell.imageStr) {
                    self.mapView.selectAnnotation(anno, animated: false)
                }
            }
        }
    }
    
    //Define the event for the first cell default selected
    func firstCellDefultSelected(selected:Bool){
        let indexPathFirstCell = IndexPath(row: 0, section: 0)
        if collectionView.cellForItem(at: indexPathFirstCell) != nil {
            let cell:PhotoMapCollectionViewCell = collectionView.cellForItem(at: indexPathFirstCell) as! PhotoMapCollectionViewCell
            if selected == true {
                cell.imageView?.layer.borderWidth = 5
            } else {
                cell.imageView?.layer.borderWidth = 1
            }
            let location = cell.imageVModel?.location
            self.mapView.setRegion(MKCoordinateRegion(center: location!, span: MKCoordinateSpanMake(180, 180)), animated: true)
            for anno in self.mapView.annotations {
                if (anno.title! == cell.imageVModel?.title) {
                    self.mapView.selectAnnotation(anno, animated: true)
                }
            }
        }
    }
    
}
