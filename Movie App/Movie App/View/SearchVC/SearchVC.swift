//
//  SearchVC.swift
//  Movie App
//
//  Created by An Nguyễn on 1/30/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

final private class Config {
    static let withReuseDefaultIdentifier = "defaultCell"
    static let withReuseIdentifierGridCell = "gridCell"
    static let nibNameGridCell = "GridCell"
}

class SearchVC: BaseViewController {
    @IBOutlet weak private var searchCollectionView: UICollectionView!
    @IBOutlet weak private var loadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var noResultTextStackView: UIStackView!

    let viewModel = SearchViewModel()
    enum Action {
        case reload, load
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupUI() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search movies..."
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        configMoviesCollectionView()
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
    }

    private func updateUI() {
        loadActivityIndicator?.isHidden = true
        searchCollectionView.reloadData()
    }

    private func fetchData(with action: Action, page: Int = 1) {
        if action == .reload {
            viewModel.movies = []
            updateUI()
        }
        loadActivityIndicator?.isHidden = false
        viewModel.fetchSearchData(page: page) { (_, error) in
            if error != nil || self.viewModel.movies.isEmpty {
                self.noResultTextStackView.isHidden = false
            }else {
                self.noResultTextStackView.isHidden = true
            }
            self.updateUI()
            print(self.viewModel.movies.count)
        }
    }

    //MARK: - Layout collectionView
    private func layoutForSearchCollectionView() {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        let itemWidth: CGFloat = (view.bounds.width - 30) / 3
        let itemHeight: CGFloat = itemWidth * 1.4
        collectionViewFlowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        collectionViewFlowLayout.minimumLineSpacing = 5
        collectionViewFlowLayout.minimumInteritemSpacing = 5
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        searchCollectionView.collectionViewLayout = collectionViewFlowLayout
    }

    private func configMoviesCollectionView() {
        searchCollectionView.backgroundColor = App.Color.mainColor
        searchCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Config.withReuseDefaultIdentifier)
        let nibForColumn = UINib(nibName: Config.nibNameGridCell, bundle: .main)
        searchCollectionView.register(nibForColumn, forCellWithReuseIdentifier: Config.withReuseIdentifierGridCell)
        refeshControl.addTarget(self, action: #selector(handleReloadData), for: .valueChanged)
        searchCollectionView.refreshControl = refeshControl
        layoutForSearchCollectionView()
    }

    @objc private func handleReloadData() {
        fetchData(with: .reload)
        refeshControl.endRefreshing()
    }
}

//MARK: - UISearchResultsUpdating
extension SearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text?.lowercased() ?? ""
        viewModel.query = text
        fetchData(with: .reload)
    }
}

//MARK: - UICollectionViewDataSource
extension SearchVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.withReuseIdentifierGridCell, for: indexPath) as? GridCell else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.withReuseDefaultIdentifier, for: indexPath)
            return cell
        }
        let movie = viewModel.movies[indexPath.row]
        cell.setupView(movie: movie)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension SearchVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollHeight = scrollView.bounds.height
        let scrollViewContentOffsetY = scrollView.contentOffset.y
        let contentSizeHeight = scrollView.contentSize.height
        if scrollHeight + scrollViewContentOffsetY >= contentSizeHeight && !viewModel.isLoadData, viewModel.totalPages > viewModel.currentPage {
            let nextPage = viewModel.currentPage + 1
            fetchData(with: .load, page: nextPage)
            print(viewModel.movies.count)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailVC()
        let movie = viewModel.movies[indexPath.row]
        let detailViewModel = viewModel.detailViewModel(for: movie.id)
        detailVC.viewModel = detailViewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
