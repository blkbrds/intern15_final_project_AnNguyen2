//
//  API.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/30/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

typealias APICompletion<T> = (Result<T, APIError>) -> Void

enum APIResult {
    case success(Data?)
    case failure(APIError)
}

// MARK: - Defines
enum APIError: Error {
    case error(String)
    case errorURL
    case errorJSON
    case errorNetwork
    case emptyData
    case emptyID
    case invalidURL
    case cancelRequest
    case canNotGetVideoURL

    var localizedDescription: String {
        switch self {
        case .error(let string):
            return string
        case .errorURL:
            return "URL String is error."
        case .errorJSON:
            return "The operation couldn’t be completed."
        case .emptyData:
            return "Server returns no data."
        case .invalidURL:
            return "Cannot detect URL."
        case .errorNetwork:
            return "he internet connection appears to be offline."
        case .cancelRequest:
            return "Server returns no information and closes the connection."
        case .emptyID:
            return "ID is empty."
        case .canNotGetVideoURL:
            return "Can't get video online url."
        }
    }
}

struct API {
    private static var shareAPI: API = {
        let shareAPI = API()
        return shareAPI
    }()

    static func shared() -> API {
        return shareAPI
    }

    private init() { }
}
