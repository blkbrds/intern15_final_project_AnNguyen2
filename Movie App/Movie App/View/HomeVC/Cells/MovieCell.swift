//
//  MovieCell.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/21/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class MovieCell: UICollectionViewCell {

    @IBOutlet private weak var voteCountLabel: UILabel!
    @IBOutlet private weak var movieImageView: ImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configCell()
    }
    
    private func configCell(){
        movieImageView.image = UIImage(named: "default_image")
        voteCountLabel.text = "..."
        voteCountLabel.borderLabel()
    }

    func setupView(movie: Movie) {
        let urlString = APIManager.Path.baseImageURL + movie.posterPath
        APIManager.Downloader.downloadImage(with: urlString) { (image, error) in
            if let error = error {
                print(error)
                return
            }
            DispatchQueue.main.async {
                self.voteCountLabel.text = " \(movie.voteCount.parseToThousandUnit()) K"
                self.movieImageView.image = image
            }
        }
    }
}