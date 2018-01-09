//
//  ImagesCollectionViewController.swift
//  Images
//
//  Created by V Lanfranchi on 15/11/2017.
//  Copyright © 2017 V Lanfranchi. All rights reserved.
//


import UIKit
import Photos
import CoreLocation
import MapKit

class ImagesCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate{
    
    var cameraRoll: PHAssetCollection!
    var photoAssets: PHFetchResult<AnyObject>!
    var assetThumbnailSize: CGSize!
    var selectedPhoto: PHAsset!
    var imagePickerController : UIImagePickerController!
    var photoAssetsWithMap = [PHAsset]()
    var selectedSign: Bool = false
    var selectedPhotos = Set<IndexPath>()
    var imageVModel = [ImageViewModel]()
    let gpsStr = "{GPS}"
    let latitudeStr = "Latitude"
    let longitudeStr = "Longitude"
    
    @IBOutlet weak var selectedBtn: UIBarButtonItem!
    @IBOutlet weak var uploadingIndicator: UIActivityIndicatorView!
    
    @IBAction func enableSelection(_ sender: Any) {
        if selectedSign == false {
            self.selectedSign = true
            self.selectedBtn.title = "Upload"
        } else {
            print(selectedPhotos)
            self.uploadPictures()
            //self.selectedPhotos.removeAll()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Load the camera roll album into memory
        let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        if let first_Obj:AnyObject = collection.firstObject{
            self.cameraRoll = first_Obj as! PHAssetCollection
        }
    }
    
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        
        imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            
            let alertController = UIAlertController.init(title: nil, message: "Sorry, your device does not have a camera.", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: {(alert: UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        else{
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        // Get size of the collectionView cell for thumbnail
        if let layout = self.collectionView!.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        let photoAuth = PHPhotoLibrary.authorizationStatus()
        if photoAuth == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.loadPhotos()
                }
            })
        }
        else if photoAuth == .authorized {
            self.loadPhotos()
        }
        self.uploadingIndicator.isHidden = true
    }
    
    private func loadPhotos() {
        self.photoAssets = (PHAsset.fetchAssets(in: self.cameraRoll, options: nil) as AnyObject!) as! PHFetchResult<AnyObject>!
        self.getAssetWithMap()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.photoAssets != nil){
            return self.photoAssets.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath as IndexPath) as! PhotoCollectionViewCell
        let asset: PHAsset = self.photoAssets[indexPath.item] as! PHAsset
        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {
            (result, info) in
            var imageVModel = ImageViewModel()
            let imageManager = PHImageManager.default()
            imageManager.requestImageData(for: asset, options: nil, resultHandler:{
                (data, responseString, imageOriet, info) -> Void in
                let imageData: NSData = data! as NSData
                let imageSource = CGImageSourceCreateWithData(imageData, nil)
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)! as NSDictionary
                let title = ((info?["PHImageFileURLKey"] as! NSURL).lastPathComponent)
                if imageProperties[self.gpsStr] != nil {
                    //print("GPS empty")
                    let gps:NSDictionary  =  imageProperties[self.gpsStr] as! NSDictionary
                    let location = CLLocationCoordinate2DMake(gps[self.latitudeStr] as! CLLocationDegrees,gps[self.longitudeStr] as! CLLocationDegrees)
                    cell.imageVModel?.location = location
                }
                imageVModel.title = title!
                imageVModel.image = result!
                imageVModel.id = indexPath.item
                cell.photoView.image = imageVModel.image
                cell.imageVModel = imageVModel
            })
            self.imageVModel.append(imageVModel)
        })
        
        if selectedSign == false {
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPhoto = self.photoAssets[indexPath.item] as! PHAsset
        let cell:PhotoCollectionViewCell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        print(indexPath.item)
        if selectedSign == true {
            if cell.layer.borderWidth == 5 {
                cell.layer.borderWidth = 0
                if (self.selectedPhotos.contains(indexPath)) {
                    self.selectedPhotos.remove(indexPath)
                }
            } else {
                cell.layer.borderWidth = 5
                self.selectedPhotos.insert(indexPath)
            }
        } else {
            self.performSegue(withIdentifier: "photoDetails", sender: self)
        }
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoDetails" {
            if let nextVC = segue.destination as? PhotoDetailsViewController {
                nextVC.photo = self.selectedPhoto
            }
        }
        
        //Go to photo map view
        if segue.identifier == "photoMap" {
            if let nextVC = segue.destination as? PhotoMapViewController {
                //nextVC.cameraRoll = self.cameraRoll
                nextVC.photoAssets = self.photoAssets
                nextVC.photoAssetsWithMap = self.photoAssetsWithMap
            }
        }
        
    }
    
    //Get all picture asset including location info
    func getAssetWithMap(){
        if self.photoAssetsWithMap != nil && self.photoAssetsWithMap.count == 0 {
            self.photoAssets.enumerateObjects({ (object, count, stop) in
                let photo:PHAsset = object as! PHAsset
                let imageSize = CGSize(width: photo.pixelWidth, height: photo.pixelHeight)
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                PHImageManager.default().requestImage(for: photo, targetSize: imageSize, contentMode: .aspectFill, options: option, resultHandler: {(result, info) in
                    if result != nil {
                        let imageManager = PHImageManager.default()
                        imageManager.requestImageData(for: photo, options: option, resultHandler:{
                            (data, responseString, imageOriet, info) -> Void in
                            let imageData: NSData = data! as NSData
                            if let imageSource = CGImageSourceCreateWithData(imageData, nil) {
                                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary
                                if imageProperties["{GPS}"] != nil {
                                    self.photoAssetsWithMap.append(photo)
                                } else {
                                    
                                }
                            }
                        })
                    }
                })
            })
        }
    }
    
    //Create photo info for uploading
    func initParameters() -> [String: Any] {
        var parameters: [String: Any] = [:]
        for indexPath in self.selectedPhotos {
            let cell:PhotoCollectionViewCell = self.collectionView?.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            let timeInterval: String = String((Int)(Date().timeIntervalSince1970 * 100000))
            //print(timeInterval)
            var data: [String: Any] = [:]
            data["Title"] = cell.imageVModel?.title
            data["Description"] = cell.imageVModel?.desc
            data["Date"] = cell.imageVModel?.date
            data["Latitude"] = cell.imageVModel?.location?.latitude
            data["Longtitude"] = cell.imageVModel?.location?.longitude
            let image = cell.imageVModel?.image
            //let imageData: NSData? = UIImagePNGRepresentation((cell.imageVModel?.image!)!) as NSData?
            //let base64Encoded = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: UInt(0)))
            data["Image"] = image
            parameters[timeInterval] = data
            
        }
        return parameters
    }
    
    //Upload pictures
    func uploadPictures(){
        self.uploadingIndicator.isHidden = false
        self.uploadingIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        guard let url = URL(string: "http://wesenseit-vm1.shef.ac.uk:8091/uploadImages/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = generateBoundary()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var dataBody = Data()
        for para in self.initParameters() {
            var imgInfo = para.value as! [String : Any]
            let parametersImg = imgInfo.remove(at: (imgInfo.index(forKey: "Image"))!)
            let image = parametersImg.value
            guard let mediaImage = Media(withImage: image as! UIImage, forKey: "image") else { return }
            dataBody = createDataBody(params: (imgInfo as! [String : String]), media: [mediaImage], boundary: boundary)
            request.httpBody = dataBody
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                        DispatchQueue.main.async(execute: {
                            self.uploadingIndicator.stopAnimating()
                            self.uploadingIndicator.isHidden = true
                            self.showAlert("Uploading succeeded!")
                            self.selectedSign = false
                            self.selectedBtn.title = "Select"
                            self.collectionView?.reloadData()
                            self.view.isUserInteractionEnabled = true
                        })
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
        
    }
    
    //Define an alert function
    func showAlert(_ title: String) {
        print(title)
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    //Generate UUID String
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    //Create request body
    func createDataBody(params: [String:String]?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }

}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

