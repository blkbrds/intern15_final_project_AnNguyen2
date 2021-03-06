//
//  LabelExt.swift
//  Movie App
//
//  Created by An Nguyễn on 2/3/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

extension UILabel {
    func borderLabel() {
        layer.cornerRadius = 4
        backgroundColor = App.Color.backgroundColorLabel
        clipsToBounds = true
        font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
}
