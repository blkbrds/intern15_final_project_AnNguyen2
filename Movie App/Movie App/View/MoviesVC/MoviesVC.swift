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
    static let nibNameCollectionViewCell = "GridCell"
    static let withReuseIdentifierRowCell = "rowCell"
    static let nibNameRowCell = "RowCell"
}

class MoviesVC: BaseViewController {

    @IBOutlet weak private var moviesCollectionView: UICollectionView!
    var movieCategory: MovieCategory? {
        didSet {
            title = movieCategory?.title
        }
    }
    let moviesViewModel = MoviesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configMoviesCollectionView()
        changedLayout()
    }
    
    override func setupUI() {
        setupNavigationBar()
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
    }

    private func configMoviesCollectionView() {
        moviesCollectionView.backgroundColor = App.Color.mainColor
        moviesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Config.withReuseDefaultIdentifier)
        let nibForColumn = UINib(nibName: Config.nibNameCollectionViewCell, bundle: .main)
        moviesCollectionView.register(nibForColumn, forCellWithReuseIdentifier: Config.withReuseIdentifierGridCell)
        let nibForRow = UINib(nibName: Config.nibNameRowCell, bundle: .main)
        moviesCollectionView.register(nibForRow, forCellWithReuseIdentifier: Config.withReuseIdentifierRowCell)
        refeshControl.addTarget(self, action: #selector(handleReloadData), for: .valueChanged)
        moviesCollectionView.refreshControl = refeshControl
    }

    private func setupNavigationBar() {
        handleChangeStatusForButtonItem()
    }

    private func handleChangeStatusForButtonItem() {
        if moviesViewModel.status == .row {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "table"), style: .plain, target: self, action: #selector(handleChangedStatus))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(handleChangedStatus))
        }
    }

    private func changedLayout() {
        let layout = LayoutCustom() //Flow layout
        layout.scrollDirection = .vertical
        if moviesViewModel.status == .row {
            let widthItem = view.bounds.width
            let heightItem: CGFloat = 120
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            layout.itemSize = CGSize(width: widthItem, height: heightItem)
        } else {
            let widthItem = (view.bounds.width - 41) / 3
            let heightItem = 1.3 * widthItem
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumLineSpacing = 10
            layout.itemSize = CGSize(width: widthItem, height: heightItem)
        }
        handleChangeStatusForButtonItem()
        moviesCollectionView.collectionViewLayout = layout
        moviesCollectionView.showsVerticalScrollIndicator = true
    }

    @objc private func handleChangedStatus() {
        moviesViewModel.changedStatus()
        changedLayout()
        moviesCollectionView.reloadData()
    }

    @objc private func handleReloadData() {
        refeshControl.endRefreshing()
    }
}

//MARK: -UICollectionViewDelegate
extension MoviesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: -Show detail
        let detailVC = DetailVC()
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

//MARK: -UICollectionViewDataSource
extension MoviesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesViewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: Config.withReuseDefaultIdentifier, for: indexPath)
        let movie = moviesViewModel.movies[indexPath.row]
        if moviesViewModel.status == .row {
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

