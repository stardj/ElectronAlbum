//
//  SearchVC.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/4.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noresultLabel: UILabel!
    
    fileprivate lazy var searchBar: CountrySearBar = {
        let searchBar = CountrySearBar()
        searchBar.sizeToFit()
        searchBar.autocorrectionType = .no
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        searchBar.placeholder = "Enter picture related information"
        return searchBar
    }()
    
    fileprivate var photoAry: [PhotoModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        topView = searchBar
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle(isDefault: false)
        setNavigationBar(isBackShow: true, bgImgName: "top_bg_gray", titleName: "", titleColor: UIColor.white)
        navigationItem.titleView = searchBar
    }

    fileprivate func reFreshSearchList(text: String) {
        guard let photos = PhotoModel.rows(filter: "name like '%\(text)%'", order:"id DESC") as? [PhotoModel] else { return }
        
        if photos.count == 0 {
            noresultLabel.isHidden = false
        } else {
            noresultLabel.isHidden = true
        }
        photoAry = photos
        tableView.reloadData()
    }
    
    // MARK:- UITableViewDelegate Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return photoAry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCellID") as? SearchCell {
            cell.setInfo(photo: photoAry[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let browserVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoBrowserVC") as? PhotoBrowserVC else { return }
        browserVC.setImgAry(ary: [photoAry[indexPath.row]], index: 0)
        self.present(browserVC, animated: true, completion: nil)
    }
    
    // MARK: UISearchDisplayDelegate, UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        photoAry.removeAll()
        searchBar.resignFirstResponder()
        reFreshSearchList(text: text)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
}


class CountrySearBar: UISearchBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.placeholder = "搜索"
        self.barTintColor = ColorsAry.colorBlack6
//        self.backgroundColor = ColorsAry.lightSonghall
        
        for view in self.subviews[0].subviews {
            if let textFiled = view as? UITextField {
                textFiled.font = UIFont.systemFont(ofSize: 19)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
