//
//  DetailView.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/12/23.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//

import UIKit
import MapKit

class DetailView: UIView, UIScrollViewDelegate, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scollView: UIScrollView!
    @IBOutlet weak var addrLabel: UILabel!
    fileprivate var newPhoto: PhotoModel!
    func setInfo(photo: PhotoModel) {
        newPhoto = photo
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancleBtnClick(_:))))

        titleTextField.text = photo.name != "" ? photo.name : DateTools.getNameByDate(timeStap: photo.id)
        descTextField.text = photo.desc
        dateLabel.text = photo.dateTime
        
        if let pose = photo.getPosition() {
            let p = PhotoAnnoation.init(coordinate: pose, photoId: photo.id, title: photo.addr)
            p.photoId = photo.id
            mapView.addAnnotation(p)
            addrLabel.text = "(\(photo.addr))"
            mapView.region = MKCoordinateRegionMake(pose, MKCoordinateSpanMake(0.5, 0.5))
        } else {
            addrLabel.text = "(This picture has no address information)"
        }
    }
    
    @IBAction func cancleBtnClick(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @IBAction func saveBtnClick(_ sender: UIButton) {
        if let title = titleTextField.text {
            newPhoto.name = title
        }
        newPhoto.desc = descTextField.text ?? ""
        _ = newPhoto.save()
        removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        titleTextField.resignFirstResponder()
        descTextField.resignFirstResponder()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotaionView: MKAnnotationView?
        if let _ = annotation as? PhotoAnnoation {
            annotaionView = PhotoAnnotationView.create(mapView: mapView)
            annotaionView?.annotation = annotation
        }
        
        return annotaionView
    }
}

extension Tools {
    class func addDetailView(photo: PhotoModel) {
        let nibView = Bundle.main.loadNibNamed("DetailView", owner: nil, options: nil)
        if let view = nibView?.first as? DetailView {
            view.frame = DeviceInfo.getScreenOriginFrame()
            view.setInfo(photo: photo)
            DeviceInfo.AppKeyWindow?.addSubview(view)
        }
    }
}
