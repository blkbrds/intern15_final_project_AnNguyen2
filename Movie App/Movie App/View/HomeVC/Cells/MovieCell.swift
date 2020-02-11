//
//  MovieCell.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/21/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

final class MovieCell: UICollectionViewCell {

    @IBOutlet private weak var voteCountLabel: UILabel!
    @IBOutlet private weak var movieImageView: ImageView!
    
    private var viewModel = GridCellViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        configCell()
    }
    
    private func configCell(){
        movieImageView.borderImage()
        voteCountLabel.text = "..."
        voteCountLabel.borderLabel()
    }

    func setupViewModel(movie: Movie) {
        viewModel = GridCellViewModel(movie: movie)
        guard let movie = viewModel.getMovie() else { return }
        voteCountLabel.text = " \(movie.voteCount.parseToThousandUnit()) K"
        movieImageView.image = #imageLiteral(resourceName: "default_image")
        viewModel.loadImageData { [weak self] (done, error, urlStr) in
            guard let this = self else { return }
            if done, let data = this.viewModel.getImageData(), APIManager.Path.baseImage3URL + movie.posterPath == urlStr {
                this.movieImageView.image = UIImage(data: data)
            }
        }
    }
}
