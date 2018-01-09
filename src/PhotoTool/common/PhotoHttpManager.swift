//
//  PhotoHttpManager.swift
//  PhotoTool
//
//  Created by 江荧辉 on 2017/11/30.
//  Copyright © 2017年 YingHui Jiang. All rights reserved.
//

import UIKit
typealias ReturnBlock = (_ result: Any?, _ error: String?) -> Void

class PhotoHttpManager: NSObject {

    class func get(url: String, params: [String: AnyObject], success: ReturnBlock) {
        let data = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        var string = "json="
        
        let Str = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        //拼接
        string = string + Str!
        let Url = URL.init(string: "http://facaiyoudao.com/api/user/login")
        
        let request = NSMutableURLRequest.init(url: Url!)
        request.timeoutInterval = 30
        //请求方式，跟OC一样的
        request.httpMethod = "POST"
        request.httpBody = string.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if (error != nil) {
                return
            }
            else {
                //此处是具体的解析，具体请移步下面
                let json: Any = try! JSONSerialization.jsonObject(with: data!, options: [])
//                print(json)
            }
        }
        dataTask.resume()
    }
    
}
