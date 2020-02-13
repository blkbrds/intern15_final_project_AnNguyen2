//
//  LayoutCustom.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/22/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class LayoutCustom: UICollectionViewFlowLayout {
    override init() {
        super.init()
        setupLayout()
    }

    func setupLayout() {
        itemSize = CGSize(width: 110, height: 150)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
