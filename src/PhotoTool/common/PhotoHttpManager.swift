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
    static let share = PhotoHttpManager()
    
    let boundary = "Boundary-\(NSUUID().uuidString)"
    
    /// 根据id下载图片图片
    ///
    /// - Parameters:
    ///   - timeStamp: photoId
    ///   - isThumbnail: 是否是缩略图
    func uploadPicture(chooseAry: [Int], block: @escaping(_ error: String?, _ name: String?)->()) {
        func createDataBody(photo: PhotoModel) -> Data {
            let lineBreak = "\r\n"
            var body = Data()
            let parameters = ["title": photo.name]
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
            let media = Media(key: "image", filename: "image", data: UIImagePNGRepresentation(Tools.getImage(timeStamp: photo.id, isThumbnail: true)!)!, mimeType: "image/png")
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(media.key)\"; filename=\"\(media.key)\"\(lineBreak)")
            body.append("Content-Type: \((media.mimeType) + lineBreak + lineBreak)")
            body.append(media.data)
            body.append(lineBreak)
            body.append("--\(boundary)--\(lineBreak)")
            return body
        }
        guard let url = URL(string: "http://wesenseit-vm1.shef.ac.uk:8091/uploadImages/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var datas = Data()
        for id in chooseAry {
            if let photo = PhotoModel.rowBy(id: id) as? PhotoModel {
                let body = createDataBody(photo: photo)
                datas.append(body)
            }
        }
        request.httpBody = datas
        request.timeoutInterval = 30
        let session = URLSession.shared
        session.dataTask(with: request) { (dataT, response, error) in
            guard error == nil, let data = dataT else {
                block("error", nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    let name = json["title"]
                    block(nil, name)
                }
            } catch {
                block(nil, nil)
            }
            }.resume()
    }
}

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

