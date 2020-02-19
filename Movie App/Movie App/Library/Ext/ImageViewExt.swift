//
//  ImageViewExt.swift
//  Movie App
//
//  Created by An Nguyễn on 2/3/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

extension UIImageView {
    func borderImage(cornerRadius: CGFloat = 5) {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
