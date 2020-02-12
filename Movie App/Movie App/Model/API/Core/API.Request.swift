//
//  Request.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/30/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

enum MethodType: String {
    case get = "GET"
    case post = "POST"
}

extension API {

    //with url string
    func request(
        method: MethodType = .get,
        with urlString: String,
        body: Data? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (APIResult) -> Void) {
        guard let url = urlString.url else {
            completion(.failure(.errorURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 60
        config.waitsForConnectivity = true
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, _, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.error(error.localizedDescription)))
                } else {
                    guard let data = data else {
                        completion(.failure(.emptyData))
                        return
                    }
                    completion(.success(data))
                }
            }
        }
        dataTask.resume()
    }
}
