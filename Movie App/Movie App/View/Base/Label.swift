//
//  Label.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/22/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class Label: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = App.Color.titleColor
        self.font = UIFont.boldSystemFont(ofSize: 18)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
