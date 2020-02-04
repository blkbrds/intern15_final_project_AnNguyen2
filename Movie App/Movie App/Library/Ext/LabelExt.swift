//
//  LabelExt.swift
//  Movie App
//
//  Created by An Nguyễn on 2/3/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

extension UILabel {
    func borderLabel(){
        self.layer.cornerRadius = 4
        self.backgroundColor = .lightGray
        self.clipsToBounds = true
    }
}
