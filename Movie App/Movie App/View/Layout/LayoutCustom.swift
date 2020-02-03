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
        self.itemSize = CGSize(width: 110, height: 150)
        self.minimumLineSpacing = 0
        self.scrollDirection = .horizontal
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
