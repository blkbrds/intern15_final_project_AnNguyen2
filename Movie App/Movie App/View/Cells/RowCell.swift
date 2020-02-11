//
//  RowCell.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/27/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

final class RowCell: UICollectionViewCell {

    @IBOutlet weak private var movieImageView: UIImageView!
    @IBOutlet weak private var movieNameLabel: UILabel!
    @IBOutlet weak private var releaseDateLabel: UILabel!
    @IBOutlet weak private var overviewLabel: UILabel!
    @IBOutlet weak private var voteCountLabel: UILabel!
    
    private var viewModel = RowCellViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    private func configView(){
        movieImageView.borderImage()
        voteCountLabel.borderLabel()
    }

    func setupViewModel(movie: Movie) {
        viewModel = RowCellViewModel(movie: movie)
        guard let movie = viewModel.getMovie() else { return }
        movieImageView.image = #imageLiteral(resourceName: "default_image")
        voteCountLabel.text = " \(movie.voteCount.parseToThousandUnit()) K"
        overviewLabel.text = movie.overview
        releaseDateLabel.text = movie.releaseDate?.toString()
        movieNameLabel.text = movie.originalTitle
        viewModel.loadImageData { [weak self] (done, error, urlStr) in
            guard let this = self else { return }
            if done, let data = this.viewModel.getImageData(), APIManager.Path.baseImage3URL + movie.posterPath == urlStr {
                this.movieImageView.image = UIImage(data: data)
            }
        }
    }
}
