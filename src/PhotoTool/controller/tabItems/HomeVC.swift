//
//  HomeVC.swift
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

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WaterFallLayoutDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    fileprivate lazy var cellSize:CGSize = {
        let wid = Tools.minOne([DeviceInfo.ScreenWidth, DeviceInfo.ScreenHeight])
        let picWidth: CGFloat = DeviceInfo.isPad ? wid*0.16 : wid*0.25
        return CGSize(width: picWidth, height: picWidth*1.1)
    }()

    fileprivate lazy var uploadingView: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView(frame: CGRect(x: 0, y: -60, width: DeviceInfo.getScreenWidth(), height: DeviceInfo.getScreenHeight()+100))
        loading.isHidden = false
        loading.color = UIColor.gray
        loading.backgroundColor = UIColor(white: 0.5, alpha: 0.3)
        self.view.addSubview(loading)
       return loading
    }()
    
    fileprivate var photoGroupAry: [BaseGroup?] = []
    fileprivate var photoAry: [PhotoModel] = []
    fileprivate var chooseAry: [Int] = []
    
    fileprivate lazy var searchBtn: UIBarButtonItem = {
        let btn = UIBarButtonItem.init(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(searchBtnClick))
        return btn
    }()

    fileprivate lazy var photoBtn: UIBarButtonItem = {
        let item = UIBarButtonItem.init(title: "📷", style: .plain, target: self, action: #selector(takePhotoBtnClick))
        return item
    }()
    
    fileprivate lazy var chooseBtn: UIBarButtonItem = {
        let btnItem = UIBarButtonItem.init(title: "choose", style: .plain, target: self, action: #selector(chooseBtnClick))
        return btnItem
    }()
    
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    @IBAction func deleteBtnClick(_ sender: UIButton) {
        SystemPhotoManager.share.deletePhotos(deleteId: chooseAry) {[weak self] (status) in
            guard let weakself = self else { return }
            DispatchQueue.main.async {
                weakself.chooseBtnClick()
                if status {
                    weakself.reFreshData()
                } else {
                    weakself.collectionView.reloadData()
                    weakself.showAlert(title: "ERROR", message: "Delete failure", buttonTitle: "I Know")
                }
            }
        }
    }
    
    @IBAction func uploadBtnClick(_ sender: UIButton) {
        if chooseAry.count == 0 {
            reFreshData()
            return
        } else if chooseAry.count > 5 {
            showAlert(title: "Warning", message: "Select up to five photos uploaded", buttonTitle: "OK")
            return
        }
        uploadingView.startAnimating()
        chooseBtn.isEnabled = false
        PhotoHttpManager.share.uploadPicture(chooseAry: chooseAry) {[weak self] (error, name) in
            if let weakself = self , error == nil {
                weakself.showAlert(title: "Success", message: "Upload succeeded", buttonTitle: "OK")
            } else {
                self?.showAlert(title: "Warning", message: "Upload failure", buttonTitle: "OK")
            }
            
            DispatchQueue.main.async {
                self?.chooseBtn.isEnabled = true
                self?.uploadingView.stopAnimating()
                self?.reFreshData()
                self?.chooseBtnClick()
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = StickyHeadersFlowLayout()
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.reloadData()
        reFreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chooseAry = []
        setNavigationBar(isBackShow: false, bgImgName: "", titleName: PageTitle.Home, titleColor: UIColor.black)
        chooseBtn.title = "choose"
        navigationItem.rightBarButtonItems = [photoBtn, chooseBtn, searchBtn]
        if isUpdate() {
            reFreshData()
        }
        
        if photoAry.count == 0 {
            SystemPhotoManager.share.synchroPhotos {[weak self] (status, update) in
                guard let weakself = self else { return }
                if update {
                    weakself.reFreshData()
                }
            }
        }
    }
    
    fileprivate func isUpdate() -> Bool {
        if let firstId = (PhotoModel.rows(order: "id DESC").first as? PhotoModel)?.id,
            let curFirstId = photoAry.first?.id {
            let countSql = PhotoModel.count()
            let count = photoAry.count
            return !((firstId == curFirstId) && (countSql == count))
        }
        return true
    }
    
    @objc fileprivate func searchBtnClick() {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as? SearchVC {
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @objc fileprivate func chooseBtnClick() {
        chooseAry = []

        if getIsChooseMode() {
            chooseBtn.title = "choose"
            bottomView.isHidden = true
            navigationItem.rightBarButtonItems = [photoBtn, chooseBtn, searchBtn]
            NotificationCenter.default.post(name: NSNotification.Name.init(PhotoNotiFicationName.HidiBottomBar), object: nil, userInfo: ["isHide": false])
        } else {
            chooseBtn.title = "Cancle"
            bottomView.isHidden = false
            navigationItem.rightBarButtonItems = [chooseBtn]
            NotificationCenter.default.post(name: NSNotification.Name.init(PhotoNotiFicationName.HidiBottomBar), object: nil, userInfo: ["isHide": true])
        }
    }
    
    fileprivate func getIsChooseMode() -> Bool {
        guard let title = chooseBtn.title else { return false }
        return title != "choose"
    }
    
    fileprivate func reFreshData() {
        photoGroupAry = []
        photoAry = []
        let timeAry = PhotoModel.getDifferValues(columnName: "dateTime", order: "dateTime DESC")
        for str in timeAry {
            if let ary = PhotoModel.rows(filter: "dateTime = '\(str)'", order: "id DESC") as? [PhotoModel]{
                let g = BaseGroup(groupTitle: str, photos: ary)
                photoGroupAry.append(g)
                photoAry += ary
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // TakePhoto Finished
    
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
    
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        SystemPhotoManager.share.synchroPhotos {[weak self] (status, _) in
            guard let weakself = self else { return }
            if status {
                DispatchQueue.main.async {
                    if let newPhoto = PhotoModel.rows(order: "id DESC", limit: 1).first as? PhotoModel {
                        let group1Name = weakself.photoGroupAry.first??.groupTitle ?? ""
                        if group1Name == newPhoto.dateTime {
                            weakself.photoGroupAry.first??.photos.insert(newPhoto, at: 0)
                            weakself.collectionView.reloadSections(IndexSet(integer: 0))
                        } else {
                            weakself.reFreshData()
                        }
                    }
                }
            }
        }
    }
    // MARK: UICollectionViewDelegate Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoGroupAry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = photoGroupAry[section]?.photos else { return photoAry.count }
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
        return CGSize(width: UIScreen.main.bounds.size.width, height: DeviceInfo.isPad ? 50 : 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellWithSelectedID", for: indexPath) as? ImageCellWithSelected,
            photoGroupAry.count > indexPath.section,
            (photoGroupAry[indexPath.section]?.photos.count)! > indexPath.row,
            let photo = photoGroupAry[indexPath.section]?.photos[indexPath.row]  else { return UICollectionViewCell() }
        
        cell.setImg(timeStamp: photo.id, isSelected: chooseAry.contains(photo.id), isThumbnail: true)
        return cell
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

