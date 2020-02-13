import UIKit
import AVKit
import UICircularProgressRing

final class DetailVC: BaseViewController {
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
    @IBOutlet weak private var moviesTableViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak private var progressDownloadCircularProgressRing: UICircularProgressRing!

    var viewModel = DetailViewModel()
    enum Action {
        case reload, load
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleReloadData), name: .didChangedData, object: nil)
    }

    override func setupData() {
        if viewModel.downloaded() {
            viewModel.getMovieDownloaded()
            updateUI()
            return
        }
        fetchData(for: .load)
    }

    override func setupUI() {
        title = "Details"
        detailScrollView.backgroundColor = App.Color.mainColor
        progressDownloadCircularProgressRing.font = UIFont.systemFont(ofSize: 9)
        refeshControl.addTarget(self, action: #selector(handleRefreshControlReloadData), for: .valueChanged)
        detailScrollView.refreshControl = refeshControl
        movieImageView.borderImage()
        playVideoButton.borderButton()
        configMovieTableView()
    }

    private func updateUI() {
        let movie = viewModel.getMovie()
        taglineLabel.text = movie?.tagLine ?? "..."
        overviewMovieLabel.text = movie?.overview ?? "..."
        movieNameLabel.text = movie?.originalTitle ?? "..."
        voteCountLabel.text = "\(movie?.voteCount ?? 0) votes"
        releaseDateLabel.text = movie?.releaseDate?.toString() ?? "..."
        idmScoreLabel.text = "IDM \(movie?.voteAverage ?? 0)"
        let urlString = APIManager.Path.baseImage3URL + (movie?.posterPath ?? "")
        if let data = movie?.imageData {
            movieImageView.image = UIImage.init(data: data)
            moviePosterImageView.image = UIImage.init(data: data)
            changeIconButtonDownload()
            moreLikeThisMoviesTableView.isHidden = true
            moviesTableViewHeightContraint.constant = 0
            return
        }
        APIManager.Downloader.downloadImage(with: urlString) { [weak self] (data, error) in
            guard let this = self else { return }
            if let error = error {
                this.view.makeToast("\(error.localizedDescription) (image)")
                return
            }
            let imageData = data
            this.viewModel.setDataImageMovie(data: imageData)
            guard let data = data else { return }
            DispatchQueue.main.async {
                this.movieImageView.image = UIImage(data: data)
                this.moviePosterImageView.image = UIImage(data: data)
            }
            this.changeIconButtonDownload()
        }
    }

    private func changeIconButtonDownload() {
        if viewModel.downloaded() {
            downloadButton.tintColor = UIColor.green
            downloadButton.setBackgroundImage(
                UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
            print("Movie is download!")
        } else {
            downloadButton.tintColor = UIColor.white
            downloadButton.setBackgroundImage(
                UIImage.init(systemName: "arrow.down.to.line.alt"), for: .normal)
            print("Movie is not download!")
        }
    }

    private func updateUIForMoreLikeTableView() {
        moreLikeThisMoviesTableView.reloadData()
    }

    private func fetchData(for action: Action) {
        getURLMovieVideo()
        if action == .reload {
            viewModel.resetMovie()
            updateUI()
        }
        loadActivityIndicator.startAnimating()
        loadActivityIndicator.isHidden = false
        viewModel.fetchMovieData { [weak self] (done, error) in
            guard let this = self else { return }
            if done {
                this.updateUI()
            } else if let error = error {
                this.alert(errorString: error.localizedDescription)
            }
            this.changeIconButtonDownload()
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
        viewModel.fetchSimilarRecommendMovie { [weak self] (done, error) in
            guard let this = self else { return }
            if let error = error {
                this.alert(errorString: error.localizedDescription)
            }
            this.updateUIForMoreLikeTableView()
        }
    }

    private func getURLMovieVideo() {
        viewModel.getURLMovieVideo { [weak self] (done, error) in
            guard let this = self else { return }
            if done {
                this.view.makeToast("Get video url success!")
            } else if let error = error {
                this.alert(errorString: "Error video: \(error.localizedDescription)")
            }
        }
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

    private func handleDownload() {
        if viewModel.downloaded() {
            deleteAlert(msg: "Do you want to delete movie in download?") { (_) in
                self.viewModel.removeMovie { [weak self] (done, error) in
                    guard let this = self else { return }
                    if let _ = error {
                        this.view.makeToast("Delete failure!")
                        return
                    }
                    NotificationCenter.default.post(name: .didChangedData, object: nil)
                    if done, this.viewModel.canPop() {
                        this.navigationController?.popViewController(animated: true)
                    }else {
                        this.changeIconButtonDownload()
                    }
                    this.view.makeToast("Delete success!")
                }
            }
        } else {
            if viewModel.isLoadingVideo() {
                alert(errorString: "Video is loading, please wait...")
                return
            }
            print("Downloading...")
            viewModel.addMovieContentToDownload { [weak self] (done, error) in
                guard let this = self else { return }
                if done {
                    NotificationCenter.default.post(name: .didChangedData, object: nil)
                    this.view.makeToast("Saved movie content, video is downloading...")
                } else {
                    this.view.makeToast(error?.localizedDescription ?? "")
                }
            }
            downloadButton.isHidden = true
            progressDownloadCircularProgressRing.isHidden = false
            progressDownloadCircularProgressRing.value = 0
            viewModel.downloadMovie { [weak self] (progress, error) in
                guard let this = self else { return }
                if let _ = error {
                    this.alert(errorString: "Error to download video!")
                    this.changeIconButtonDownload()
                    return
                }
                this.progressDownloadCircularProgressRing.value = CGFloat(progress * 100)
                if progress == 1 {
                    this.downloadButton.isHidden = false
                    this.progressDownloadCircularProgressRing.isHidden = true
                    this.changeIconButtonDownload()
                }
            }
        }
    }

    @objc private func handleReloadData() {
        if !viewModel.canPop() {
            viewModel.getMovieDownloaded()
        }
        changeIconButtonDownload()
    }

    @objc private func handleRefreshControlReloadData() {
        if viewModel.downloaded(), viewModel.canPop() {
            viewModel.getMovieDownloaded()
            updateUI()
            refeshControl.endRefreshing()
            return
        }
        fetchData(for: .reload)
        fetchSimilarRecommendMovie(for: .reload)
        refeshControl.endRefreshing()
    }

    @IBAction private func playVideoButton(_ sender: Any) {
        if viewModel.isLoadingVideo() {
            alert(errorString: "Video is loading, please wait...")
            return
        }
        guard let videoUrl = viewModel.videoUrl() else {
            alert(errorString: "Video is empty!")
            return
        }
        print(videoUrl.absoluteString)
        let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }

    @IBAction private func downloadButton(_ sender: Any) {
        handleDownload()
    }

    @IBAction private func shareButton(_ sender: Any) {
        guard let movie = viewModel.getMovie(), let url = movie.homePage.url else {
            alert(errorString: APIError.errorURL.localizedDescription)
            return
        }
        let items: [Any] = ["Watch this movie \(url.absoluteString)"]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    @IBAction private func openWebsiteButton(_ sender: Any) {
        guard let movie = viewModel.getMovie(), let url = movie.homePage.url else {
            alert(errorString: "URL website error!")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: -UITableViewDataSource
extension DetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = App.Color.mainColor
        let titleLabel = Label()
        titleLabel.text = viewModel.getTitle(section: section)
        headerView.addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 5).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(DetailCell.self)
        cell.delegate = self
        let movies = viewModel.moviesIn(indexPath: indexPath)
        let isLoading = viewModel.getLoading(indexPath: indexPath)
        cell.setupData(movies: movies, isLoading: isLoading)
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
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
    func detailCell(_ cell: DetailCell, didSelectItem: Movie, perform action: DetailCellActionType) {
        let detailVC = DetailVC()
        let detailViewModel = viewModel.detailViewModel(for: didSelectItem.id)
        detailVC.viewModel = detailViewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
