//
//  DateExt.swift
//  Movie App
//
//  Created by An Nguyễn on 2/8/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

extension Date {
    func toString() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .long
        let dateStr = dateFormater.string(from: self)
        return dateStr
    }
}
