//
//  FloatExt.swift
//  Movie App
//
//  Created by An Nguyễn on 2/3/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

extension Float {
    func toString() -> String {
        return String(format: "%.1f", self)
    }
}
