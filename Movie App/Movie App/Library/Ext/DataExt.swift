//
//  NSDataExt.swift
//  MyApp
//
//  Created by Quang Nguyen K. on 12/4/19.
//  Copyright © 2019 Asian Tech Co., Ltd. All rights reserved.
//

import Foundation

typealias JSObject = [String: Any]
typealias JSArray = [JSObject]

extension Data {
    func toJSObject() -> JSObject {
        var json: JSObject = [:]
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? JSObject {
                json = jsonObject
            }
        } catch {
            print(APIError.errorJSON.localizedDescription)
        }
        return json
    }

    func toJSArray() -> JSArray {
        var jsonArray: JSArray = []
        do {
            if let jsonArrayObject = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? JSArray {
                jsonArray = jsonArrayObject
            }
        } catch {
            print(APIError.errorJSON.localizedDescription)
        }
        return jsonArray
    }

    func toString(_ encoding: String.Encoding = String.Encoding.utf8) -> String? {
        return String(data: self, encoding: encoding)
    }
}
