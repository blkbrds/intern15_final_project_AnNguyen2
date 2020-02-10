//
//  API.Downloader.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/31/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

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
                    }else {
                        completion(nil, APIError.emptyData)
                    }
                }
            }
        }
    }
    
    static func downloadVideo(with url: URL, completion: @escaping(_ videoData: Data?, _ error: Error?) -> Void){
        API.shared().request(with: url.absoluteString) { (result) in
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let data):
                if let data = data {
                    completion(data, nil)
                }else {
                    completion(nil, APIError.emptyData)
                }
            }
        }
    }
}
