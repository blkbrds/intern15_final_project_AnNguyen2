//
//  FavoriteCell.swift
//  Movie App
//
//  Created by An Nguyễn on 2/6/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

enum DownloadCellActionType {
    case delete
}

protocol DownloadCellDelegate: class {
    func favoriteCell(_ cell: DownloadCell, delete item: Movie?, in indexPath: IndexPath?,  perform action: DownloadCellActionType)
}

final class DownloadCell: UITableViewCell {
    
    @IBOutlet weak private var movieImageView: UIImageView!
    @IBOutlet weak private var movieNameLabel: UILabel!
    @IBOutlet weak private var releaseDateLabel: UILabel!
    @IBOutlet weak private var overviewLabel: UILabel!
    @IBOutlet weak private var voteCountLabel: UILabel!
    @IBOutlet weak private var deleteMovieButton: UIButton!
    private var movie: Movie?
    private var indexPath: IndexPath?
    
    weak var delegate: DownloadCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    private func configView(){
        deleteMovieButton.setTitleColor(App.Color.button(state: .selected), for: .selected)
        movieImageView.borderImage()
        voteCountLabel.text = "..."
        voteCountLabel.borderLabel()
    }
    
    func setupView(movie: Movie, indexPath: IndexPath) {
        self.movie = movie
        movieImageView.image = #imageLiteral(resourceName: "default_image")
        voteCountLabel.text = " \(movie.voteCount.parseToThousandUnit()) K"
        overviewLabel.text = movie.overview
        releaseDateLabel.text = movie.releaseDate?.toString()
        movieNameLabel.text = movie.originalTitle
        let urlString = APIManager.Path.baseImage5URL + movie.posterPath
        APIManager.Downloader.downloadImage(with: urlString) {[weak self] (image, error) in
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
    
    @IBAction private func deleteMovieButton(sender: Any){
        delegate?.favoriteCell(self, delete: movie, in: indexPath,  perform: .delete)
    }
}
