//
//  API.Downloader.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/31/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit
import Foundation

let imageCache = NSCache<NSString, UIImage>()

extension APIManager.Downloader {
    static func downloadImage(with urlString: String, completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        imageCache.countLimit = 100
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage, nil)
        } else {
            API.shared().request(with: urlString) { (result) in
                switch result {
                case .failure(let error):
                    completion(nil, error)
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        completion(image, nil)
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
