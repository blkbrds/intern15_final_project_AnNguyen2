//
//  Font.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/31/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

extension App.Font {
    static var navigationBar: UIFont {
        return .systemFont(ofSize: 20, weight: .bold)
    }

    static var tableHeaderViewTextLabel: UIFont {
        return .boldSystemFont(ofSize: 14)
    }

    static var tableFooterViewTextLabel: UIFont {
        return .boldSystemFont(ofSize: 14)
    }

    static var tableCellTextLabel: UIFont {
        return .systemFont(ofSize: 14)
    }

    static var buttonTextLabel: UIFont {
        return .boldSystemFont(ofSize: 12)
    }
}
