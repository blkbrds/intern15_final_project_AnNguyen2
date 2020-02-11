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
    func detailCell(_ homeCell: DetailCell, didSelectItem: Movie, perform action: DetailCellActionType)
}

class DetailCell: UITableViewCell {

    @IBOutlet private weak var moviesCollectionView: UICollectionView!
    @IBOutlet private weak var loadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var serverResponseNoDataLabel: UILabel!
    private var viewModel = DetailCellViewModel()
    
    weak var delegate: DetailCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configMoviesCollectionView()
    }
    
    private func updateUI(isLoading: Bool){
        if isLoading {
            loadActivityIndicator.startAnimating()
            loadActivityIndicator.isHidden = false
            serverResponseNoDataLabel.isHidden = true
        } else if viewModel.moviesEmpty {
            loadActivityIndicator.stopAnimating()
            loadActivityIndicator.isHidden = true
            serverResponseNoDataLabel.isHidden = false
        } else {
            loadActivityIndicator.isHidden = true
            serverResponseNoDataLabel.isHidden = true
        }
    }

    func setupData(movies: [Movie], isLoading: Bool) {
        viewModel = DetailCellViewModel(movies: movies, isLoading: isLoading)
        updateUI(isLoading: isLoading)
        moviesCollectionView.reloadData()
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
        return viewModel.numberOfItemsInSection()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: MovieCell.self, for: indexPath)
        let movie = viewModel.getMovie(indexPath: indexPath)
        cell.setupView(movie: movie)
        return cell
    }
}

//MARK: -UICollectionViewDelegate
extension DetailCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.getMovie(indexPath: indexPath)
        delegate?.detailCell(self, didSelectItem: movie, perform: .didSelectItem)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4) {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
