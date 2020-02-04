//
//  ImageView.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 2/1/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class ImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    private func configView(){
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

