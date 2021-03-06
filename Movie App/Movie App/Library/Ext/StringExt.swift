//
//  String.swift
//  MyApp
//
//  Created by iOSTeam on 2/21/18.
//  Copyright © 2018 Asian Tech Co., Ltd. All rights reserved.
//

import Foundation

enum Process {
    case encode
    case decode
}

extension String {
    var trimmed: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func base64(_ method: Process) -> String? {
        switch method {
        case .encode:
            guard let data = data(using: .utf8) else { return nil }
            return data.base64EncodedString()
        case .decode:
            guard let data = Data(base64Encoded: self) else { return nil }
            return String(data: data, encoding: .utf8)
        }
    }
}

extension String {
    var url: URL? {
        return URL(string: self)
    }

    // The host, conforming to RFC 1808. (read-only)
    var host: String {
        if let url = url, let host = url.host {
            return host
        }
        return ""
    }
}

extension String {
    static func / (left: String, right: String) -> String {
        return left + "/" + right
    }
}

extension String {
    func toDate() -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let date = dateFormater.date(from: self)
        return date
    }
}
