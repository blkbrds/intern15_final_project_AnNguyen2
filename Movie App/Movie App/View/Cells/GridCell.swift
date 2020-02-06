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
        voteCountLabel.text = "..."
        voteCountLabel.borderLabel()
    }

    func setupView(movie: Movie) {
        movieImageView.image = #imageLiteral(resourceName: "default_image")
        voteCountLabel.text = " \(movie.voteCount.parseToThousandUnit()) K"
        let urlString = APIManager.Path.baseImage5URL + movie.posterPath
        APIManager.Downloader.downloadImage(with: urlString) { (image, error) in
            if let error = error {
                print(error)
                return
            }
            DispatchQueue.main.async {
                self.movieImageView.image = image
            }
        }
    }
}