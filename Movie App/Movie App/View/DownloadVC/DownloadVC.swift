//
//  FavoriteVC.swift
//  Movie App
//
//  Created by An Nguyễn on 1/20/20
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class DownloadVC: BaseViewController {

    @IBOutlet weak private var favoriteTableView: UITableView!
    @IBOutlet weak private var noItemsLabel: UILabel!
    private var rightEditBarButtonItem: UIBarButtonItem?
    private var leftDeleteBarButtonItem: UIBarButtonItem?
    private let viewModel = DownloadViewModel()
    enum Action {
        case reload, load
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData(for: .load)
    }

    override func setupUI() {
        title = "Downloads"
        configFavoriteTableView()
        rightEditBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEditChangedItems))
        leftDeleteBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "trash"), style: .plain, target: self, action: #selector(handleDeleteItems))
        navigationItem.rightBarButtonItem = rightEditBarButtonItem
    }

    override func setupData() {
        fetchData(for: .load)
    }

    private func updateUI() {
        favoriteTableView?.reloadData()
        if viewModel.isEmptyItems {
            favoriteTableView.isHidden = true
            noItemsLabel.isHidden = false
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = rightEditBarButtonItem
            favoriteTableView.isHidden = false
            noItemsLabel.isHidden = true
        }
    }

    private func fetchData(for action: Action) {
        if action == .reload {
            viewModel.resetMovies()
            updateUI()
        }
        viewModel.fetchData { [weak self] (done, error) in
            guard let this = self else { return }
            if done {
                this.updateUI()
            } else if let error = error {
                this.alert(errorString: error.localizedDescription)
            }
        }
    }

    private func configFavoriteTableView() {
        favoriteTableView.tableFooterView = UIView(frame: .zero)
        favoriteTableView.showsVerticalScrollIndicator = true
        favoriteTableView.register(DownloadCell.self)
        favoriteTableView.backgroundColor = App.Color.mainColor
        favoriteTableView.allowsSelectionDuringEditing = true
        favoriteTableView.allowsMultipleSelectionDuringEditing = true
        refeshControl.addTarget(self, action: #selector(handleReloadData), for: .valueChanged)
        favoriteTableView.refreshControl = refeshControl
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
    }

    @objc private func handleReloadData() {
        fetchData(for: .reload)
        refeshControl.endRefreshing()
    }

    @objc private func handleEditChangedItems() {
        let isNotEditing = !favoriteTableView.isEditing
        favoriteTableView.setEditing(isNotEditing, animated: true)
        if favoriteTableView.isEditing {
            rightEditBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleEditChangedItems))
            navigationItem.leftBarButtonItem = leftDeleteBarButtonItem
        } else {
            rightEditBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEditChangedItems))
            navigationItem.leftBarButtonItem = nil
        }
        navigationItem.rightBarButtonItem = rightEditBarButtonItem
    }

    @objc private func handleDeleteItems() {
        guard let indexPaths = favoriteTableView.indexPathsForSelectedRows else { return }
        let movies: [Movie] = indexPaths.map({ viewModel.getMovie(in: $0) })
        viewModel.removeMoviesInFavorite(movies: movies) { [weak self] (done, error) in
            guard let this = self else { return }
            if done {
                this.fetchData(for: .reload)
                this.updateUI()
                print("Delete movies success!")
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
}

//MARK: - UITableViewDelegate
extension DownloadVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailVC()
        let movie = viewModel.getMovie(in: indexPath)
        let detailViewModel = viewModel.detailViewModel(for: movie.id)
        detailViewModel.setupMovie(movie: movie)
        detailVC.viewModel = detailViewModel
        if tableView.isEditing { return }
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

//MARK: - UITableViewDataSource
extension DownloadVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(DownloadCell.self)
        cell.delegate = self
        let movie = viewModel.getMovie(in: indexPath)
        cell.setupView(movie: movie, indexPath: indexPath)
        return cell
    }
}

//MARK: - FavoriteCellDelegate
extension DownloadVC: DownloadCellDelegate {
    func favoriteCell(_ cell: DownloadCell, delete item: Movie?, in indexPath: IndexPath?, perform action: DownloadCellActionType) {
        deleteAlert(msg: "Do you want to delete \(item?.originalTitle ?? "") in your favorites?") { (_) in
            self.viewModel.removeMovieInFavorite(movie: item) { [weak self] (done, error) in
                guard let this = self else { return }
                if done {
                    this.fetchData(for: .load)
                } else {
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }
}
