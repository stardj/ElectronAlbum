//
//  FourItem.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2018/1/5.
//  Copyright © 2018年 YingHui Jiang. All rights reserved.
//

import UIKit

class FourItemVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(isBackShow: false, bgImgName: "", titleName: PageTitle.Me, titleColor: UIColor.black)
    }

}
