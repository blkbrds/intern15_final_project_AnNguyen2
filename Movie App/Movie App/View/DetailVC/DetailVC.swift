//
//  DetailVC.swift
//  Movie App
//
//  Created by An Nguyễn on 1/20/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit
import AVKit

class DetailVC: BaseViewController {
    @IBOutlet weak private var loadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var detailScrollView: UIScrollView!
    @IBOutlet weak private var moviePosterImageView: UIImageView!
    @IBOutlet weak private var movieImageView: UIImageView!
    @IBOutlet weak private var idmScoreLabel: UILabel!
    @IBOutlet weak private var releaseDateLabel: UILabel!
    @IBOutlet weak private var voteCountLabel: UILabel!
    @IBOutlet weak private var movieNameLabel: UILabel!
    @IBOutlet weak private var overviewMovieLabel: UILabel!
    @IBOutlet weak private var taglineLabel: UILabel!
    @IBOutlet weak private var playVideoButton: UIButton!
    @IBOutlet weak private var moreLikeThisMoviesTableView: UITableView!
    @IBOutlet weak private var downloadButton: UIButton!
    @IBOutlet weak private var favoriteButton: UIButton!

    var viewModel = DetailViewModel()
    enum Action {
        case reload, load
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupData() {
        fetchData(for: .load)
    }

    private func updateUI() {
        let movie = viewModel.movie
        taglineLabel.text = movie?.tagLine ?? "..."
        overviewMovieLabel.text = movie?.overview ?? "..."
        movieNameLabel.text = movie?.originalTitle ?? "..."
        voteCountLabel.text = "\(movie?.voteCount ?? 0) votes"
        releaseDateLabel.text = movie?.releaseDate ?? "..."
        idmScoreLabel.text = "IDM \(movie?.voteAverage ?? 0)"
        let urlString = APIManager.Path.baseImage3URL + (movie?.posterPath ?? "")
        APIManager.Downloader.downloadImage(with: urlString) { (image, error) in
            if let error = error {
                print(error, "downloadImage")
                return
            }
            DispatchQueue.main.async {
                self.movieImageView.image = image
                self.moviePosterImageView.image = image
            }
            self.checkMovieDownLoad()
        }
    }

    private func checkMovieInFavorite() {
        if viewModel.isFavorited {
            favoriteButton.tintColor = App.Color.favoritedButton
            favoriteButton.setImage(UIImage.init(systemName: "heart.fill"), for: .normal)
            print("Movie In Favorite!")
        } else {
            favoriteButton.tintColor = App.Color.notFavoritedButton
            favoriteButton.setImage(UIImage.init(systemName: "heart"), for: .normal)
            print("Movie not In Favorite!")
        }
    }
    
    private func checkMovieDownLoad(){
        if let _ = self.viewModel.localUrl {
            self.downloadButton.tintColor = UIColor.green
            self.downloadButton.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
        }
    }

    private func updateUIForMoreLikeTableView(sectionIndex: Int) {
        let indexSet = IndexSet(integer: sectionIndex)
        self.moreLikeThisMoviesTableView.reloadSections(indexSet, with: .fade)
    }

    private func fetchData(for action: Action) {
        getURLMovieVideo()
        if action == .reload {
            viewModel.movie = nil
            updateUI()
        }
        loadActivityIndicator.startAnimating()
        loadActivityIndicator.isHidden = false
        viewModel.fetchMovieData { (done, error) in
            if done {
                self.checkMovieInFavorite()
                self.updateUI()
            } else if let error = error {
                self.alert(errorString: error.localizedDescription)
            }
        }
        loadActivityIndicator.stopAnimating()
        loadActivityIndicator.isHidden = true
        fetchSimilarRecommendMovie(for: .load)
    }

    private func fetchSimilarRecommendMovie(for action: Action) {
        if action == .reload {
            viewModel.resetMovies()
            moreLikeThisMoviesTableView.reloadData()
        }
        viewModel.fetchSimilarRecommendMovie { (done, index, error) in
            if done {
                self.updateUIForMoreLikeTableView(sectionIndex: index)
            } else if let error = error {
                self.alert(errorString: error.localizedDescription)
            }
        }
    }

    private func getURLMovieVideo() {
        viewModel.getURLMovieVideo { (done, error) in
            if done {
                print("Get video url success!")
            } else if let error = error {
                self.alert(errorString: error.localizedDescription)
            }
        }
    }

    override func setupUI() {
        title = "Details"
        detailScrollView.backgroundColor = App.Color.mainColor
        refeshControl.addTarget(self, action: #selector(handleRefreshData), for: .valueChanged)
        detailScrollView.refreshControl = refeshControl
        movieImageView.borderImage()
        playVideoButton.borderButton()
        configMovieTableView()
    }

    private func configMovieTableView() {
        moreLikeThisMoviesTableView.backgroundColor = App.Color.mainColor
        moreLikeThisMoviesTableView.register(DetailCell.self)
        let footerView = UIView()
        moreLikeThisMoviesTableView.showsVerticalScrollIndicator = false
        moreLikeThisMoviesTableView.tableFooterView = footerView
        moreLikeThisMoviesTableView.dataSource = self
        moreLikeThisMoviesTableView.delegate = self
    }

    @objc private func handleRefreshData() {
        fetchData(for: .reload)
        fetchSimilarRecommendMovie(for: .reload)
        refeshControl.endRefreshing()
    }

    @IBAction private func playVideoButton(_ sender: Any) {
        guard let urlOnline = viewModel.urlVideo else {
            alert(errorString: "URL video is empty!")
            return
        }
        let url = viewModel.localUrl ?? urlOnline
        print(url.absoluteString)
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }

    @IBAction private func favoriteButton(_ sender: Any) {
        if viewModel.isFavorited {
            viewModel.removeInFavorite { (done, error) in
                if done {
                    self.checkMovieInFavorite()
                    print("Remove Favorite success.")
                }else {
                    print(error?.localizedDescription ?? "")
                }
            }
        } else {
            viewModel.addMoviewToFavorite { (done, error) in
                if done {
                    self.checkMovieInFavorite()
                    print("addMoviewToFavorite")
                } else {
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }

    @IBAction private func downloadButton(_ sender: Any) {
        if let _ = viewModel.localUrl { return }
        print("Download...")
        downloadButton.setImage(UIImage.init(systemName: "slowmo"), for: .normal)
        viewModel.saveOfflineVideo { (url, error) in
            if let error = error {
                self.alert(errorString: error.localizedDescription)
            }
            self.downloadButton.tintColor = UIColor.green
            self.downloadButton.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
            print("Download success!")
        }
    }

    @IBAction private func shareButton(_ sender: Any) {
        guard let movie = viewModel.movie, let url = movie.homePage.url else {
            alert(errorString: APIError.errorURL.localizedDescription)
            return
        }
        let items: [Any] = ["Watch this movie \(url.absoluteString)"]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    @IBAction private func openWebsiteButton(_ sender: Any) {
        guard let movie = viewModel.movie, let url = movie.homePage.url else {
            alert(errorString: "URL website error!")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

//MARK: -UITableViewDataSource
extension DetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = App.Color.mainColor
        let titleLabel = Label()
        titleLabel.text = viewModel.movieCategories[section].title
        headerView.addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 5).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(DetailCell.self)
        cell.delegate = self
        let movies = viewModel.movies[indexPath.section]
        cell.setupData(movies: movies)
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.movieCategories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

//MARK: -UITableViewDelegate
extension DetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
}

//MARK: -DetailCellDelegate
extension DetailVC: DetailCellDelegate {
    func detailCell(_ homeCell: DetailCell, didSelectItem: Movie, perform action: DetailCellActionType) {
        let detailVC = DetailVC()
        let detailViewModel = viewModel.detailViewModel(for: didSelectItem.id)
        detailVC.viewModel = detailViewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
