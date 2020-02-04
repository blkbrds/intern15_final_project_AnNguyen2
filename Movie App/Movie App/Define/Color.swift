//
//  Color.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/30/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

extension App.Color {
//    static let mainColor = UIColor(displayP3Red: 86 / 255, green: 87 / 255, blue: 86 / 255, alpha: 1)
    static let mainColor = UIColor(displayP3Red: 25 / 255, green: 25 / 255, blue: 25 / 255, alpha: 1)
    static let titleColor = UIColor.white
    static let barTint = UIColor.white
    static let navigationBar = UIColor.black
    static let tableFooterView = UIColor.red
    static let tableCellTextLabel = UIColor.yellow

    static func button(state: UIControl.State) -> UIColor {
        switch state {
        case UIControl.State.normal: return App.Color.titleColor
        default: return .black
        }
    }
}