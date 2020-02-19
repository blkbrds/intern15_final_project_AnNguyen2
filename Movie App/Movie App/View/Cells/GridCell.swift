//
//  MoviesCell.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/22/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

final class GridCell: UICollectionViewCell {

    @IBOutlet private weak var voteCountLabel: UILabel!
    @IBOutlet private weak var movieImageView: UIImageView!
    
    private var viewModel = GridCellViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        configCell()
    }
    
    private func configCell(){
        movieImageView.borderImage()
        voteCountLabel.borderLabel()
    }

    func setupViewModel(movie: Movie) {
        viewModel = GridCellViewModel(movie: movie)
        guard let movie = viewModel.getMovie() else { return }
        voteCountLabel.text = " \(movie.voteCount.parseToThousandUnit()) K"
        movieImageView.image = #imageLiteral(resourceName: "default_image")
        viewModel.loadImageData { [weak self] (done, error, urlStr) in
            guard let `self` = self else { return }
            if done, let data = self.viewModel.getImageData(), APIManager.Path.baseImage3URL + movie.posterPath == urlStr {
                self.movieImageView.image = UIImage(data: data)
            }
        }
    }
}
