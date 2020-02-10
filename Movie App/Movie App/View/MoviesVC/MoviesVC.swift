//
//  MoviesVC.swift
//  Movie App
//
//  Created by An Nguyễn on 2/3/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

final class MoviesVC: BaseViewController {

    @IBOutlet weak private var moviesCollectionView: UICollectionView!
    @IBOutlet private weak var loadActivityIndicator: UIActivityIndicatorView!
    private var filterViewCustom: FilterViewCustom!
    private var fillterBarButtonItem: UIBarButtonItem!
    private var statusBarButtonItem: UIBarButtonItem!
    var viewModel = MoviesViewModel()
    enum Action {
        case reload, load
    }
    private var filterViewCustomBottomAnchor: NSLayoutConstraint?
    private var filterViewCustomTopAnchor: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        configMoviesCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCollectionView()
    }

    override func setupUI() {
        title = viewModel.movieCategory?.title
        setupNavigationBar()
        if let filterView = Bundle.main.loadNibNamed("FilterViewCustom", owner: self, options: nil)?.first as? FilterViewCustom {
            filterViewCustom = filterView
            view.addSubview(filterViewCustom)
            filterViewCustom.translatesAutoresizingMaskIntoConstraints = false
            filterViewCustomBottomAnchor = filterViewCustom.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            filterViewCustomTopAnchor = filterViewCustom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            let filterHeight: CGFloat = viewModel.movieCategory == .trending ? 130 : 200
            NSLayoutConstraint.activate([
                filterViewCustom.heightAnchor.constraint(equalToConstant: filterHeight),
                filterViewCustom.widthAnchor.constraint(equalToConstant: view.bounds.width),
                filterViewCustom.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])
            filterViewCustomTopAnchor?.isActive = true
            filterViewCustom.delegate = self
            filterViewCustom.setupAlertFilterViewCustom(genres: self.viewModel.genres)
        }
    }

    override func setupData() {
        fetchData(for: .load)
        guard let category = viewModel.getMovieCategory() else { return }
        if category == .discover || category == .tv || category == .trending {
            viewModel.fetchGenre { [weak self] (done, error) in
                guard let this = self else { return }
                if done {
                    this.filterViewCustom?.setupAlertFilterViewCustom(genres: this.viewModel.genres)
                } else if let error = error {
                    this.alert(errorString: error.localizedDescription)
                }
            }
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let safeAreaInsetsLeft: CGFloat = view.safeAreaInsets.left
        print("safeAreaInsets left", safeAreaInsetsLeft)
        let width = view.bounds.width - 2 * safeAreaInsetsLeft
        changedLayout(with: width)
        moviesCollectionView.reloadData()
    }

    private func fetchData(for action: Action, page: Int = 1) {
        if action == .reload {
            viewModel.movies = []
            updateUI()
        }
        loadActivityIndicator.isHidden = false
        viewModel.fetchDataWithFilter(page: page) { [weak self] (done, error) in
            guard let this = self else { return }
            if done {
                this.updateUI()
            } else if let error = error {
                this.alert(errorString: error.localizedDescription)
            }
            this.loadActivityIndicator.isHidden = true
        }
    }

    private func updateUI() {
        moviesCollectionView?.reloadData()
    }

    private func updateCollectionView() {
        let width = moviesCollectionView.bounds.width
        changedLayout(with: width)
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
    }

    private func configMoviesCollectionView() {
        moviesCollectionView.backgroundColor = App.Color.mainColor
        moviesCollectionView.register(GridCell.self)
        moviesCollectionView.register(RowCell.self)
        refeshControl.addTarget(self, action: #selector(handleReloadData), for: .valueChanged)
        moviesCollectionView.refreshControl = refeshControl
    }

    private func setupNavigationBar() {
        fillterBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "f.circle.fill"), style: .plain, target: self, action: #selector(handleFilterMovies))
        statusBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "square.grid.2x2"), style: .plain, target: self, action: #selector(handleChangedStatus))
        guard let category = viewModel.movieCategory else { return }
        if category == .discover || category == .tv || category == .trending { navigationItem.rightBarButtonItems = [statusBarButtonItem, fillterBarButtonItem]
        } else {
            navigationItem.rightBarButtonItem = statusBarButtonItem
        }
    }

    private func handleChangeStatusForButtonItem() {
        if viewModel.status == .row {
            statusBarButtonItem.image = UIImage.init(systemName: "square.grid.2x2")
        } else {
            statusBarButtonItem.image = UIImage.init(systemName: "line.horizontal.3")
        }
    }

    private func changedLayout(with width: CGFloat) {
        let layout = LayoutCustom() //Flow layout
        layout.scrollDirection = .vertical
        if viewModel.status == .row {
            let widthItem = width
            let heightItem: CGFloat = 120
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            layout.itemSize = CGSize(width: widthItem, height: heightItem)
        } else {
            let widthItem = (width - 30) / 3
            let heightItem = 1.4 * widthItem
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 5
            layout.itemSize = CGSize(width: widthItem, height: heightItem)
        }
        handleChangeStatusForButtonItem()
        moviesCollectionView.collectionViewLayout = layout
        moviesCollectionView.showsVerticalScrollIndicator = true
    }

    private func handleChangedStatusFilterMovies() {
        viewModel.changedShowFilter()
        if viewModel.getShowFilter() {
            filterViewCustomBottomAnchor?.isActive = true
            filterViewCustomTopAnchor?.isActive = false
        } else {
            filterViewCustomBottomAnchor?.isActive = false
            filterViewCustomTopAnchor?.isActive = true
        }
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func handleChangedStatus() {
        viewModel.changedStatus()
        let width = moviesCollectionView.bounds.width
        changedLayout(with: width)
        moviesCollectionView.reloadData()
    }

    @objc private func handleReloadData() {
        fetchData(for: .reload)
        refeshControl.endRefreshing()
    }

    @objc private func handleFilterMovies() {
        handleChangedStatusFilterMovies()
    }
}

//MARK: -UICollectionViewDelegate
extension MoviesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: -Show detail
        let detailVC = DetailVC()
        let movie = viewModel.getMovie(at: indexPath)
        let detailViewModel = viewModel.detailViewModel(for: movie.id)
        detailVC.viewModel = detailViewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollHeight = scrollView.bounds.height
        let scrollViewContentOffsetY = scrollView.contentOffset.y
        let contentSizeHeight = scrollView.contentSize.height
        if scrollHeight + scrollViewContentOffsetY >= contentSizeHeight && viewModel.isNotLoadData() {
            let nextPage = viewModel.nextPage()
            fetchData(for: .load, page: nextPage)
            print(viewModel.movies.count)
        }
    }
}

//MARK: -UICollectionViewDataSource
extension MoviesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = viewModel.getMovie(at: indexPath)
        if viewModel.status == .row {
            let rowCell = collectionView.dequeueReusableCell(with: RowCell.self, for: indexPath)
            rowCell.setupViewModel(movie: movie)
            return rowCell
        } else {
            let gridCell = collectionView.dequeueReusableCell(with: GridCell.self, for: indexPath)
            gridCell.setupViewModel(movie: movie)
            return gridCell
        }
    }
}

//MARK: -FilterViewCustomDelegate
extension MoviesVC: FilterViewCustomDelegate {
    func closedFilterView(_ view: FilterViewCustom, perform action: FilterViewActionType) {
        handleChangedStatusFilterMovies()
    }

    func filterViewCustom(_ view: FilterViewCustom, didSelectGenre: Genre, perform action: FilterViewActionType) {
        handleChangedStatusFilterMovies()
        if didSelectGenre.name == "Day" || didSelectGenre.name == "Week" {
            viewModel.changedTrendingTypeFilter(genre: didSelectGenre)
        } else {
            viewModel.chageGenreFilter(genre: didSelectGenre)
        }
        fetchData(for: .reload, page: 1)
        print(didSelectGenre)
    }
}
