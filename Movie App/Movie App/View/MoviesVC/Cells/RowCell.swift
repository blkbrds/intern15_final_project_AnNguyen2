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

    private func configView() {
        movieImageView.borderImage()
        voteCountLabel.text = "..."
        voteCountLabel.borderLabel()
    }

    func setupView(movie: Movie) {
        movieImageView.image = #imageLiteral(resourceName: "default_image")
        voteCountLabel.text = " \(movie.voteCount.parseToThousandUnit()) K"
        let urlString = APIManager.Path.baseImageURL + movie.posterPath
        APIManager.Downloader.downloadImage(with: urlString) { [weak self] (image, error) in
            guard let this = self else { return }
            if let error = error {
                print(error)
                return
            }
            DispatchQueue.main.async {
                this.movieImageView.image = image
            }
        }
    }

}
