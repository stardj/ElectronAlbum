//
//  AlbumVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/5.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit
import Photos

class AlbumVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    fileprivate var items: [AlbumItem] = []
    fileprivate lazy var assetGridThumbnailSize: CGSize = {
        return CGSize(width: 72*0.85, height: 72)
    }()
    
    fileprivate let tableHeight: CGFloat = 130
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNavigationBar(isBackShow: false, bgImgName: "", titleName: PageTitle.Album, titleColor: UIColor.black)
        navigationController?.navigationBar.tintColor = UIColor.black
        
        loadData()
    }
    
    fileprivate func loadData() {
        SystemPhotoManager.share.getAlbumItems {[weak self] (ary) in
            guard let weakself = self else { return }
            weakself.items = ary
            DispatchQueue.main.async {
                weakself.tableView.reloadData()
            }
        }
    }
    
    // MARK:- UITableViewDelegate Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCellID")! as! AlbumCell
        let item = items[indexPath.row]
        let asset = item.fetchResult[0]
        cell.setInfo(photoId: DateTools.dateToTimeStamp(date: asset.creationDate!) , titleStr: item.title, count: item.count)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
         SystemPhotoManager.changeAssetsToPhotos(assets: item.fetchResult) {[weak self]
            photos in
            guard let weakself = self else { return }
            if let nextVC = weakself.storyboard?.instantiateViewController(withIdentifier: "WaterfallVC") as? WaterfallVC {
                nextVC.setPhotoIdAry(titleStr: item.title, ary: photos)
                weakself.navigationController?.pushViewController(nextVC
                    , animated: true)
            }
        }
    }
}
