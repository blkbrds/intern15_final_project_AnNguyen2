//
//  HomeCell.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/21/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

private final class Config {
    static let withReuseIdentifier = "movieCell"
    static let nibNameCell = "MovieCell"
    static let defautIdentifier = "defaultCell"
}

class HomeCell: UITableViewCell {

    @IBOutlet private weak var moviesCollectionView: UICollectionView!
    private var movies: [Movie] = [] {
        didSet {
            moviesCollectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configMoviesCollectionView()
    }

    func setupData(movies: [Movie]) {
        self.movies = movies
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func configMoviesCollectionView() {
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
extension HomeCell: UICollectionViewDataSource {
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
extension HomeCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: -Show Details Screen
        print("didSelectItem")
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4) {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
