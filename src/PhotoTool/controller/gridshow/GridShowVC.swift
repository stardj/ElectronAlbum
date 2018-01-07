//
//  GridShowVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/12/16.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//

import UIKit

struct PageTitle {
    static let Home = "Home"
    static let Album = "Album"
    static let Map = "Map"
    static let Me = "Me"
}

class GridShowVC: TakePhotoVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WaterFallLayoutDelegate {
    fileprivate lazy var cellSize:CGSize = {
        let picWidth: CGFloat = DeviceInfo.ScreenWidth*0.25
        return CGSize(width: picWidth, height: picWidth*1.25)
    }()
    
    fileprivate var sortType: SortType? = nil
    fileprivate var showType: CollectionViewShowType = .normal

    fileprivate var photoGroupAry: [BaseGroup?] = []
    fileprivate var photoAry: [PhotoModel] = []
    fileprivate var chooseAry: [Int] = []
    
    fileprivate lazy var searchBtn: UIBarButtonItem = {
        let btn = UIBarButtonItem.init(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchBtnClick))
        return btn
    }()
    
    fileprivate lazy var leftBtn: UIBarButtonItem = {
        let item = UIBarButtonItem.init(title: "Exit", style: .plain, target: self, action: #selector(returnBtnDismiss))
        return item
    }()

    fileprivate lazy var photoBtn: UIBarButtonItem = {
        let item = UIBarButtonItem.init(title: "📷", style: .plain, target: self, action: #selector(takePhotoBtnClick))
        return item
    }()
    
    fileprivate lazy var chooseBtn: UIBarButtonItem = {
        let btnItem = UIBarButtonItem.init(title: "choose", style: .plain, target: self, action: #selector(chooseBtnClick))
        return btnItem
    }()
    
    fileprivate lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = ColorsAry.colorMe
        btn.setTitle("DELETE", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        btn.addTarget(self, action: #selector(deleteBtnClick), for: .touchUpInside)
        
        self.view.addSubview(btn)
        let width = NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 60)
        let right = NSLayoutConstraint(item: btn, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: btn, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        btn.superview?.addConstraint(width)
        btn.addConstraint(height)
        btn.superview?.addConstraint(right)
        btn.superview?.addConstraint(bottom)
        return btn
    }()
    
    @objc fileprivate func deleteBtnClick() {
        SystemPhotoManager.share.deletePhotos(deleteId: chooseAry) {[weak self] (status) in
            guard let weakself = self else { return }
            DispatchQueue.main.async {
                if status {
                    weakself.initData()
                    weakself.chooseBtnClick()
                } else {
                    weakself.showAlert(title: "ERROR", message: "Delete failure", buttonTitle: "I Know")
                }
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        let layout = StickyHeadersFlowLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chooseAry = []
        setNavigationBar(isBackShow: false, bgImgName: "", titleName: PageTitle.Home, titleColor: UIColor.black)
        navigationItem.leftBarButtonItems = [leftBtn]
        chooseBtn.title = "choose"
        navigationItem.rightBarButtonItems = [photoBtn, chooseBtn, searchBtn]
        
//        SystemPhotoManager.share.synchroPhotos() {[weak self]
//            (status, update) in
//            guard let weakself = self else { return }
//            if status && update{
//                DispatchQueue.main.async {
//                    weakself.initData()
//                    weakself.collectionView.reloadData()
//                }
//            }
//        }
    }
    
    @objc fileprivate func searchBtnClick() {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as? SearchVC {
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @objc fileprivate func chooseBtnClick() {
        chooseAry = []
        collectionView.reloadData()

        if getIsChooseMode() {
            chooseBtn.title = "choose"
            deleteBtn.isHidden = true
            navigationItem.rightBarButtonItems = [photoBtn, chooseBtn, searchBtn]
            NotificationCenter.default.post(name: NSNotification.Name.init(PhotoNotiFicationName.HidiBottomBar), object: nil, userInfo: ["isHide": false])
        } else {
            chooseBtn.title = "Cancle"
            deleteBtn.isHidden = false
            navigationItem.rightBarButtonItems = [chooseBtn]
            NotificationCenter.default.post(name: NSNotification.Name.init(PhotoNotiFicationName.HidiBottomBar), object: nil, userInfo: ["isHide": true])
        }
    }
    
    fileprivate func getIsChooseMode() -> Bool {
        guard let title = chooseBtn.title else { return false }
        return title != "choose"
    }
    
    func setInfo(showType: CollectionViewShowType, sortType: SortType?) {
        self.showType = showType
        self.sortType = sortType
    }
    
    func initData() {
        photoGroupAry = []
        photoAry = []
        guard let sortType = sortType else { return }
        switch sortType {
        case .time:
            let timeAry = PhotoModel.getDifferValues(columnName: "dateTime", order: "dateTime DESC")
            for str in timeAry {
                if let ary = PhotoModel.rows(filter: "dateTime = '\(str)'", order: "id DESC") as? [PhotoModel]{
                    let g = BaseGroup(sortType: .time, groupTitle: str, photos: ary)
                    photoGroupAry.append(g)
                    photoAry += ary
                }
            }
        case .local:
            let addrAry = PhotoModel.getDifferValues(columnName: "addr", order: "addr ASC")
            for str in addrAry {
                if let ary = PhotoModel.rows(filter: "addr = '\(str)'", order: "id DESC") as? [PhotoModel]{
                    let g = BaseGroup(sortType: .time, groupTitle: str, photos: ary)
                    photoGroupAry.append(g)
                    photoAry += ary
                }
            }
        }
    }
    
    // TakePhoto Finished
    override func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        SystemPhotoManager.share.synchroPhotos {[weak self] (status, _) in
            guard let weakself = self else { return }
            if status {
                if let newPhoto = PhotoModel.rows(order: "id DESC", limit: 1).first as? PhotoModel {
                    let group1Name = weakself.photoGroupAry.first??.groupTitle ?? ""
                    if group1Name == newPhoto.dateTime {
                        weakself.photoGroupAry.first??.photos.insert(newPhoto, at: 0)
                    weakself.collectionView.reloadSections(IndexSet(integer: 0))
                    } else {
                        DispatchQueue.main.async {
                            weakself.initData()
                            weakself.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    // MARK: UICollectionViewDelegate Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if sortType == nil {
            return 1
        } else {
            return photoGroupAry.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = photoGroupAry[section]?.photos, sortType != nil else { return photoAry.count }
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let header = collectionView.dequeueReusableSupplementaryView(ofKind:
            UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionHeaderCellID", for: indexPath) as? CollectionHeaderCell {
            header.titleLabel.text = photoGroupAry[indexPath.section]?.groupTitle
            return header
        }else {
            return UICollectionReusableView()
        }
    }
    
    //header高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard sortType != nil else {
            return CGSize.zero
        }
        return CGSize(width: UIScreen.main.bounds.size.width, height: DeviceInfo.isPad ? 50 : 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if sortType == nil {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellWithSelectedID", for: indexPath) as? ImageCellWithSelected  else { return UICollectionViewCell() }
            let photo = photoAry[indexPath.row]
            cell.setImg(timeStamp: photo.id, isSelected: chooseAry.contains(photo.id), isThumbnail: true)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellWithSelectedID", for: indexPath) as? ImageCellWithSelected,
                let photo = photoGroupAry[indexPath.section]?.photos[indexPath.row]  else { return UICollectionViewCell() }
            
            cell.setImg(timeStamp: photo.id, isSelected: chooseAry.contains(photo.id), isThumbnail: true)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if getIsChooseMode() {
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCellWithSelected,
                let photo = photoGroupAry[indexPath.section]?.photos[indexPath.row] {
                let photoId = photo.id
                cell.setSelected(isSelect: cell.tickImg.isHidden)
                if cell.tickImg.isHidden {
                    if let index = chooseAry.index(of: photoId) {
                            chooseAry.remove(at: index)
                    }
                } else {
                    chooseAry.append(photoId)
                }
            }
            return
        }
        guard let browserVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoBrowserVC") as? PhotoBrowserVC else { return }
        if let photo = photoGroupAry[indexPath.section]?.photos[indexPath.row],
            let index = getIndexInAry(photo: photo) {
            browserVC.setImgAry(ary: photoAry, index: index)
            self.present(browserVC, animated: true, completion: nil)
        }
    }
    
    fileprivate func getIndexInAry(photo: PhotoModel) -> Int? {
        if let index = photoAry.index(of: photo)?.hashValue {
            return index
        } else {
            return nil
        }
    }
    
    //每个分组的内边距
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    //单元格的行间距
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    //单元格横向的最小间距
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

class TakePhotoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func takePhotoBtnClick() {
        if !SystemPhotoManager.share.isRightCamera() {
            showAlert(title: "ERROR", message: "Open the use of album permissions to settings", buttonTitle: "OK")
            return
        }
        let imagePicker = UIImagePickerController()
        //设置代理
        imagePicker.delegate = self
        //允许编辑
        imagePicker.allowsEditing = true
        //设置图片来源
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        //模态弹出ImagePickerView
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //取消
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //实现UIimagePickerDelegate代理方法
    //UIImagePicker回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = (info as NSDictionary).object(forKey: UIImagePickerControllerEditedImage) as? UIImage else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
    }
    
    //保存图片到沙盒方法
    func saveImage(_ currentImage:UIImage,imageName:String) {
        var imageData = Data()
        imageData = UIImageJPEGRepresentation(currentImage, 0.5)!
        //获取沙盒目录
        let fullPath = ((NSHomeDirectory() as NSString).appendingPathComponent("Documents") as NSString).appendingPathComponent(imageName)
        // 将图片写入文件
        try? imageData.write(to: URL(fileURLWithPath: fullPath), options: [])
    }
}
