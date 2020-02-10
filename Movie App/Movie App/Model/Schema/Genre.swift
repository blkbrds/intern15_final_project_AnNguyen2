//
//  Genre.swift
//  Movie App
//
//  Created by An Nguyễn on 2/4/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

struct Genre {
    let id: Int
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    init(json: JSObject) {
        self.id = json["id"] as? Int ?? 0
        self.name = json["name"] as? String ?? ""
    }
}
