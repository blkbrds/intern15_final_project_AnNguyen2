//
//  DetailCell.swift
//  Movie App
//
//  Created by An Nguyễn on 2/5/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

enum DetailCellActionType {
    case didSelectItem
}

protocol DetailCellDelegate: class {
    func detailCell(_ cell: DetailCell, didSelectItem: Movie, perform action: DetailCellActionType)
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
        moviesCollectionView.register(MovieCell.self)
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
        let cell = collectionView.dequeueReusableCell(with: MovieCell.self, for: indexPath)
        let movie = movies[indexPath.row]
        cell.setupView(movie: movie)
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
