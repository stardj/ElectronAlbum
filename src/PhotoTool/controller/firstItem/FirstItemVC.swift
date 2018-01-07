//
//  FirstItemVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/2.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit
import AVFoundation

class FirstItemVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    fileprivate let tableHeight: CGFloat = DeviceInfo.ScreenHeight > 800 ? 500 : 330 * DeviceInfo.ScaleSizeH
    
    fileprivate lazy var cellSize:CGSize = {
        let rate: CGFloat = DeviceInfo.isPad ? 0.3 : 0.35
        let picWidth = DeviceInfo.ScreenWidth*rate
        return CGSize(width: picWidth, height: picWidth*1.35)
    }()
    
    fileprivate var photoGroups: [FirstVCGroup] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle(isDefault: false)
        setNavigationBar(isBackShow: false, bgImgName: "bg_top_blue", titleName: "照片管家", titleColor: UIColor.white)
        let rightBtn = UIBarButtonItem.init(title: "📷", style: .plain, target: self, action: #selector(takePhotoBtnClick))
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItems = [rightBtn]
        
        let leftBtn = UIBarButtonItem.init(title: "Exit", style: .plain, target: self, action: #selector(exitBtnClick))
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.leftBarButtonItems = [leftBtn]
    }

    fileprivate func loadData() {
        let timeAry = PhotoModel.getDifferValues(columnName: "dateTime", order: "dateTime DESC")
        let groupAry = PhotoModel.getDifferValues(columnName: "groupTitle", order: "dateTime ASC")
        var ary1: [PhotoModel] = []
        for str in timeAry {
            if let p = PhotoModel.row(number: 1, filter: "dateTime = '\(str)'", order: "") as? PhotoModel {
                ary1.append(p)
            }
        }
        let g1 = FirstVCGroup(sortType: .time, groupTitle: "根据时间查看", photos: ary1, color: "1bcd99")
        ary1 = []
        for str in groupAry {
            if let p = PhotoModel.row(number: 1, filter: "addr = '\(str)'", order: "") as? PhotoModel {
                ary1.append(p)
            }
        }
        let g2 = FirstVCGroup.init(sortType: .local, groupTitle: "根据地点查看", photos: ary1, color: "8e9ff9")
        photoGroups = [g2, g1]
    }
    
    @objc fileprivate func takePhotoBtnClick() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
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
    
    // MARK:- UITableViewDelegate Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCollectionTableViewCellID")! as! HomeCollectionTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let collectionCell = cell as? HomeCollectionTableViewCell else { return }
        let tmp = photoGroups[indexPath.row]
        collectionCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.row)
        collectionCell.setTitleLabel(isShowMoreBtn: true, typeId: tmp.sortType, title: tmp.groupTitle, color: UIColor(hexString: tmp.color) ?? UIColor.white)
        collectionCell.showMoreBtn.addTarget(self, action: #selector(showMoreBtnClick(sender:)), for: UIControlEvents.touchUpInside)
        collectionCell.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    @objc func showMoreBtnClick(sender: UIButton) {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "GridShowVC") as? GridShowVC,
            let sortType = SortType(rawValue: UInt(sender.tag))  {
            nextVC.setInfo(showType: .normal, sortType: sortType)
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableHeight
    }
    
    // MARK: UICollectionViewDelegate Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoGroups[collectionView.tag].photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionCellID", for: indexPath) as! BookCollectionCell
        let group = photoGroups[collectionView.tag]
        if let photo = group.photos[indexPath.row] {
            cell.initCellWithInfo(cellType: CellType.group, imgId: photo.id, musicImg: photo.name, detailStr: group.sortType == .time ? photo.dateTime : photo.addr)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "GridShowVC") as? GridShowVC  {
//            nextVC.setInfo(showType: .normal, sortType: nil)
//            self.navigationController?.pushViewController(nextVC, animated: true)
//        }
//        return
        let group = photoGroups[collectionView.tag]
        if let _ = group.photos[indexPath.row], let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "WaterfallVC") as? WaterfallVC {
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}
enum CollectionViewShowType: UInt {
    case normal
    case waterfall
}

enum SortType: UInt {
    case time
    case local
}

enum CellType: Int {
    case group
    case photo
}
class BaseGroup: NSObject {
    var sortType: SortType = .time
    var groupTitle = ""
    var photos: [PhotoModel?] = []
    override init() { super.init() }
    convenience init(sortType: SortType, groupTitle: String, photos: [PhotoModel?]) {
        self.init()
        self.sortType = sortType
        self.groupTitle = groupTitle
        self.photos = photos
    }
}

class FirstVCGroup: BaseGroup {
    var color: String = ""

//    override init(sortType: SortType, groupTitle: String, photos: [PhotoModel?]) {
//        super.init(sortType: sortType, groupTitle: groupTitle, photos: photos)
//    }
    
    convenience init(sortType: SortType, groupTitle: String, photos: [PhotoModel?], color: String) {
        self.init(sortType: sortType, groupTitle: groupTitle, photos: photos)
        self.color = color
    }
}
