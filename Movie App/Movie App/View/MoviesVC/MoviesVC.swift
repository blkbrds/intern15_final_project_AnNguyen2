//
//  MoviesVC.swift
//  Movie App
//
//  Created by An Nguyễn on 2/3/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

final private class Config {
    static let withReuseDefaultIdentifier = "defaultCell"
    static let withReuseIdentifierGridCell = "gridCell"
    static let nibNameGridCell = "GridCell"
    static let withReuseIdentifierRowCell = "rowCell"
    static let nibNameRowCell = "RowCell"
}

class MoviesVC: BaseViewController {

    @IBOutlet weak private var moviesCollectionView: UICollectionView!
    @IBOutlet private weak var loadActivityIndicator: UIActivityIndicatorView!
    private var filterViewCustom: FilterViewCustom!
    private var fillterBarButtonItem: UIBarButtonItem!
    private var statusBarButtonItem: UIBarButtonItem!
    var viewModel = MoviesViewModel()
    enum Action {
        case reload, load
    }
    private var isShowFilter: Bool = false
    private var filterViewCustomBottomAnchor: NSLayoutConstraint?
    private var filterViewCustomTopAnchor: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        configMoviesCollectionView()
        changedLayout()
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
            let filterHeight: CGFloat = viewModel.movieCategory == .trending ? 170 : 300
            NSLayoutConstraint.activate([
                filterViewCustom.heightAnchor.constraint(equalToConstant: filterHeight),
                filterViewCustom.widthAnchor.constraint(equalToConstant: view.bounds.width),
                filterViewCustom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                ])
            filterViewCustomTopAnchor?.isActive = true
            filterViewCustom.delegate = self
            filterViewCustom.setupAlertFilterViewCustom(genres: self.viewModel.genres)
        }
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
    }

    override func setupData() {
        fetchData(for: .load)
        guard let category = viewModel.movieCategory else { return }
        if category == .discover || category == .tv || category == .trending {
            viewModel.fetchGenre { (done, error) in
                if done {
                    self.filterViewCustom?.setupAlertFilterViewCustom(genres: self.viewModel.genres)
                } else if let error = error {
                    self.alert(errorString: error.localizedDescription)
                }
            }
        }
    }

    private func fetchData(for action: Action, page: Int = 1) {
        if action == .reload {
            viewModel.movies = []
            updateUI()
        }
        loadActivityIndicator.isHidden = false
        viewModel.fetchDataWithFilter(page: page) { (done, error) in
            if done {
                self.updateUI()
            } else if let error = error {
                self.alert(errorString: error.localizedDescription)
            }
            self.loadActivityIndicator.isHidden = true
        }
    }

    private func updateUI() {
        moviesCollectionView?.reloadData()
    }

    private func configMoviesCollectionView() {
        moviesCollectionView.backgroundColor = App.Color.mainColor
        moviesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Config.withReuseDefaultIdentifier)
        let nibForColumn = UINib(nibName: Config.nibNameGridCell, bundle: .main)
        moviesCollectionView.register(nibForColumn, forCellWithReuseIdentifier: Config.withReuseIdentifierGridCell)
        let nibForRow = UINib(nibName: Config.nibNameRowCell, bundle: .main)
        moviesCollectionView.register(nibForRow, forCellWithReuseIdentifier: Config.withReuseIdentifierRowCell)
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

    private func changedLayout() {
        let layout = LayoutCustom() //Flow layout
        layout.scrollDirection = .vertical
        if viewModel.status == .row {
            let widthItem = view.bounds.width
            let heightItem: CGFloat = 120
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            layout.itemSize = CGSize(width: widthItem, height: heightItem)
        } else {
            let widthItem = (view.bounds.width - 30) / 3
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
        viewModel.isShowFilter = !viewModel.isShowFilter
        if viewModel.isShowFilter {
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
        changedLayout()
        updateUI()
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
        let detailVC = DetailVC()
        let movie = viewModel.movies[indexPath.row]
        let detailViewModel = viewModel.detailViewModel(for: movie.id)
        detailVC.viewModel = detailViewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollHeight = scrollView.bounds.height
        let scrollViewContentOffsetY = scrollView.contentOffset.y
        let contentSizeHeight = scrollView.contentSize.height
        if scrollHeight + scrollViewContentOffsetY >= contentSizeHeight && !viewModel.isLoadData, viewModel.totalPages > viewModel.currentPage {
            let nextPage = self.viewModel.currentPage + 1
            fetchData(for: .load, page: nextPage)
            print(viewModel.movies.count)
        }
    }
}

//MARK: -UICollectionViewDataSource
extension MoviesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.withReuseDefaultIdentifier, for: indexPath)
        let movie = viewModel.movies[indexPath.row]
        if viewModel.status == .row {
            guard let rowCell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.withReuseIdentifierRowCell, for: indexPath) as? RowCell else {
                return cell
            }
            rowCell.setupView(movie: movie)
            cell = rowCell
        } else {
            guard let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.withReuseIdentifierGridCell, for: indexPath) as? GridCell else {
                return cell
            }
            gridCell.setupView(movie: movie)
            cell = gridCell
        }
        return cell
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
            viewModel.trendingTypeFilter = didSelectGenre.name == "Day" ? .day: .week
        }else {
            viewModel.genreFilter = didSelectGenre
        }
        fetchData(for: .reload, page: 1)
        print(didSelectGenre)
    }
}
