//
//  Color.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/30/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

extension App.Color {
    static let mainColor = UIColor(displayP3Red: 33/255, green: 177/255, blue: 243/255, alpha: 1)
    static let titleColor = UIColor.black
    static let barTint = UIColor.gray
    static let seeMoreButton = UIColor.gray
    static let navigationBar = UIColor.black
    static let tableView = UIColor(displayP3Red: 25, green: 25, blue: 25, alpha: 1)
    static let tableHeaderView = UIColor.lightGray
    static let tableFooterView = UIColor.red
    static let tableCellTextLabel = UIColor.yellow

    static func button(state: UIControl.State) -> UIColor {
        switch state {
        case UIControl.State.normal: return .blue
        default: return .gray
        }
    }
}
