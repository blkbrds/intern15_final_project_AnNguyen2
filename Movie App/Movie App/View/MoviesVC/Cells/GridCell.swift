//
//  MoviesCell.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/22/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class GridCell: UICollectionViewCell {

    @IBOutlet private weak var voteCountLabel: UILabel!
    @IBOutlet private weak var movieImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configCell()
    }
    
    private func configCell(){
        movieImageView.borderImage()
        voteCountLabel.borderLabel()
        movieImageView.image = UIImage(named: "default_image")
    }

    func setupView(movie: Movie) {
        
    }
}
