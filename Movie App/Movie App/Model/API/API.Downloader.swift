//
//  API.Downloader.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/31/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation
import Alamofire

let imageCache = NSCache<NSString, NSData>()

extension APIManager.Downloader {
    static func downloadImage(with urlString: String, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        imageCache.countLimit = 100
        if let cachedImageData = imageCache.object(forKey: urlString as NSString) {
            completion(Data(cachedImageData), nil)
        } else {
            API.shared().request(with: urlString) { (result) in
                switch result {
                case .failure(let error):
                    completion(nil, error)
                case .success(let data):
                    if let data = data {
                        imageCache.setObject(data as NSData, forKey: urlString as NSString)
                        completion(data, nil)
                    } else {
                        completion(nil, APIError.emptyData)
                    }
                }
            }
        }
    }

    static func downloadVideo(with url: String, nameFile: String, progressValue: @escaping (_ progress: Double) -> Void, completion: @escaping(_ videoData: Data?, _ error: Error?) -> Void) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(nameFile).mp4")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        Alamofire.download(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, to: destination)
            .downloadProgress(closure: { (progress) in
                progressValue(progress.fractionCompleted)
            })
            .responseData { (response) in
                completion(response.value, response.error)
        }
    }
}
