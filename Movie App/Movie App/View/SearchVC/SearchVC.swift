//
//  SearchVC.swift
//  Movie App
//
//  Created by An Nguyễn on 1/30/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class SearchVC: BaseViewController {
    @IBOutlet weak private var searchCollectionView: UICollectionView!
    @IBOutlet weak private var loadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var noResultTextStackView: UIStackView!

    private let viewModel = SearchViewModel()
    enum Action {
        case reload, load
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCollectionView()
    }

    private func updateCollectionView() {
        layoutForSearchCollectionView()
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
    }

    override func setupUI() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search movies..."
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        configMoviesCollectionView()
    }

    private func updateUI() {
        loadActivityIndicator?.isHidden = true
        searchCollectionView.reloadData()
    }

    private func fetchData(with action: Action, page: Int = 1) {
        if action == .reload {
            viewModel.resetMovies()
            updateUI()
        }
        let searctText = navigationItem.searchController?.searchBar.text
        if searctText == "" {
            loadActivityIndicator?.isHidden = true
        } else {
            loadActivityIndicator?.isHidden = false
        }
        viewModel.fetchSearchData(page: page) { [weak self] (_, error) in
            guard let this = self else { return }
            if error != nil || this.viewModel.isEmptyMovie {
                this.noResultTextStackView.isHidden = false
            } else {
                this.noResultTextStackView.isHidden = true
            }
            this.updateUI()
            print(this.viewModel.numberOfItems())
        }
    }

    //MARK: - Layout collectionView
    private func layoutForSearchCollectionView() {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        let itemWidth: CGFloat = (searchCollectionView.bounds.width - 30) / 3
        let itemHeight: CGFloat = itemWidth * 1.4
        collectionViewFlowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        collectionViewFlowLayout.minimumLineSpacing = 5
        collectionViewFlowLayout.minimumInteritemSpacing = 5
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        searchCollectionView.collectionViewLayout = collectionViewFlowLayout
    }

    private func configMoviesCollectionView() {
        searchCollectionView.backgroundColor = App.Color.mainColor
        searchCollectionView.register(GridCell.self)
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
        let text =  searchController.searchBar.text?.lowercased() ?? ""
        viewModel.getTimer()?.invalidate()
        let timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (_) in
            self.viewModel.updateQuery(text: text)
            if self.viewModel.isNotLoadData() {
                self.fetchData(with: .reload)
                print("Reload! \(text)")
            }
        }
        viewModel.updateOldTimer(timer: timer)
    }
}

//MARK: - UICollectionViewDataSource
extension SearchVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: GridCell.self, for: indexPath)
        let movie = viewModel.getMovie(indexPath: indexPath)
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
        if scrollHeight + scrollViewContentOffsetY >= contentSizeHeight && viewModel.isNotLoadData(), viewModel.getTotalPags() > viewModel.getCurrentPage() {
            let nextPage = viewModel.getCurrentPage() + 1
            fetchData(with: .load, page: nextPage)
            print("\(viewModel.numberOfItems()) items")
        }
        scrollView.keyboardDismissMode = .onDrag
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailVC()
        let movie = viewModel.getMovie(indexPath: indexPath)
        let detailViewModel = viewModel.detailViewModel(for: movie.id)
        detailVC.viewModel = detailViewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
