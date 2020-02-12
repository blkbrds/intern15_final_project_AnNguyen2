//
//  ButtonExt.swift
//  Movie App
//
//  Created by An Nguyễn on 2/5/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

extension UIButton {
    func borderButton() {
        layer.cornerRadius = 6
        clipsToBounds = true
    }
}
