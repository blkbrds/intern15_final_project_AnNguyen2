//
//  RowCell.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/27/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class RowCell: UICollectionViewCell {

    @IBOutlet weak private var movieImageView: UIImageView!
    @IBOutlet weak private var movieNameLabel: UILabel!
    @IBOutlet weak private var releaseDateLabel: UILabel!
    @IBOutlet weak private var overviewLabel: UILabel!
    @IBOutlet weak private var voteCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    private func configView(){
        movieImageView.borderImage()
        voteCountLabel.borderLabel()
        movieImageView.image = UIImage(named: "default_image")
    }
    
    func setupView(movie: Movie) {
        
    }

}
