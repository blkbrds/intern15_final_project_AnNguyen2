//
//  FavoriteVC.swift
//  Movie App
//
//  Created by An Nguyễn on 1/20/20
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class FavoriteVC: BaseViewController {

    @IBOutlet weak private var favoriteTableView: UITableView!
    @IBOutlet weak private var noItemsLabel: UILabel!
    private var rightEditBarButtonItem: UIBarButtonItem?
    private var leftDeleteBarButtonItem: UIBarButtonItem?
    var viewModel = FavoriteViewModel()
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
        title = "Favorites"
        configFavoriteTableView()
        rightEditBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEditItems))
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
        } else {
            favoriteTableView.isHidden = false
            noItemsLabel.isHidden = true
        }
    }

    private func fetchData(for action: Action) {
        if action == .reload {
            viewModel.movies = []
            updateUI()
        }
        viewModel.fetchData { (done, error) in
            if done {
                self.updateUI()
            } else if let error = error {
                self.alert(errorString: error.localizedDescription)
            }
        }
    }

    private func configFavoriteTableView() {
        updateUI()
        favoriteTableView.tableFooterView = UIView(frame: .zero)
        favoriteTableView.showsVerticalScrollIndicator = true
        favoriteTableView.register(FavoriteCell.self)
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

    @objc private func handleEditItems() {
        let isNotEditing = !favoriteTableView.isEditing
        favoriteTableView.setEditing(isNotEditing, animated: true)
        if favoriteTableView.isEditing {
            rightEditBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleEditItems))
            leftDeleteBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "trash"), style: .plain, target: self, action: #selector(handleDeleteItems))
        } else {
            rightEditBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEditItems))
            leftDeleteBarButtonItem = nil
        }
        navigationItem.leftBarButtonItem = leftDeleteBarButtonItem
        navigationItem.rightBarButtonItem = rightEditBarButtonItem
    }
    
    @objc private func handleDeleteItems(){
        guard let indexPaths = favoriteTableView.indexPathsForSelectedRows else { return }
        let movies: [Movie] = indexPaths.map({ viewModel.movies[$0.row] })
        viewModel.removeMoviesInFavorite(movies: movies) { (done, error) in
            if done {
                self.fetchData(for: .reload)
                self.updateUI()
                print("Delete movies success!")
            }else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
}

//MARK: - UITableViewDelegate
extension FavoriteVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailVC()
        let movie = viewModel.movies[indexPath.row]
        let detailViewModel = viewModel.detailViewModel(for: movie.id)
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
extension FavoriteVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(FavoriteCell.self)
        cell.delegate = self
        let movie = viewModel.movies[indexPath.row]
        cell.setupView(movie: movie, indexPath: indexPath)
        return cell
    }
}

//MARK: - FavoriteCellDelegate
extension FavoriteVC: FavoriteCellDelegate {
    func favoriteCell(_ cell: FavoriteCell, delete item: Movie?, in indexPath: IndexPath?, perform action: FavoriteCellActionType) {
        deleteAlert(msg: "Do you want to delete \(item?.originalTitle ?? "") in your favorites?") { (_) in
            self.viewModel.removeMovieInFavorite(movie: item) { (done, error) in
                if done {
                    self.fetchData(for: .load)
                } else {
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }
}
