//
//  DetailCell.swift
//  Movie App
//
//  Created by An Nguyễn on 2/5/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

private final class Config {
    static let withReuseIdentifier = "movieCell"
    static let nibNameCell = "MovieCell"
    static let defautIdentifier = "defaultCell"
}

enum DetailCellActionType {
    case didSelectItem
}

protocol DetailCellDelegate: class {
    func detailCell(_ homeCell: DetailCell, didSelectItem: Movie, perform action: DetailCellActionType)
}

class DetailCell: UITableViewCell {

    @IBOutlet private weak var moviesCollectionView: UICollectionView!
    @IBOutlet private weak var loadActivityIndicator: UIActivityIndicatorView!
    private var movies: [Movie] = [] {
        didSet {
            moviesCollectionView.reloadData()
        }
    }
    weak var delegate: DetailCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configMoviesCollectionView()
    }

    func setupData(movies: [Movie]) {
        if movies.isEmpty {
            loadActivityIndicator.startAnimating()
            loadActivityIndicator.isHidden = false
        } else {
            loadActivityIndicator.stopAnimating()
            loadActivityIndicator.isHidden = true
        }
        self.movies = movies
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func configMoviesCollectionView() {
        loadActivityIndicator.isHidden = false
        let nib = UINib(nibName: Config.nibNameCell, bundle: .main)
        moviesCollectionView.register(nib, forCellWithReuseIdentifier: Config.withReuseIdentifier)
        moviesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Config.defautIdentifier)
        let layout = LayoutCustom() //Flow layout
        moviesCollectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        moviesCollectionView.collectionViewLayout = layout
        moviesCollectionView.showsHorizontalScrollIndicator = false
        moviesCollectionView.backgroundColor = App.Color.mainColor
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
    }
}

//MARK: -UICollectionViewDataSource
extension DetailCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.defautIdentifier, for: indexPath)
        if let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.withReuseIdentifier, for: indexPath) as? MovieCell {
            let movie = movies[indexPath.row]
            movieCell.setupView(movie: movie)
            cell = movieCell
        }
        return cell
    }
}

//MARK: -UICollectionViewDelegate
extension DetailCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        delegate?.detailCell(self, didSelectItem: movie, perform: .didSelectItem)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4) {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
