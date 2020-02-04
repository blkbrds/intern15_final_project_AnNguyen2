//
//  IntExt.swift
//  Movie App
//
//  Created by An Nguyễn on 2/3/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

extension Int {
    func parseToThousandUnit() -> String{
        let thousand: Double = Double(self) / 1000.0
        return String(format: "%.2f", thousand)
    }
}
