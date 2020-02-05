//
//  HomeVC.swift
//  Movie App
//
//  Created by An Nguyễn on 1/20/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

final private class Config {
    static let withReuseIdentifier = "homeCell"
    static let nibNameCell = "HomeCell"
    static let defautIdentifier = "defaultCell"
}

class HomeVC: BaseViewController {

    @IBOutlet private weak var movieTableView: UITableView!
    fileprivate let homeViewModel = HomeViewModel()
    
    enum Action {
        case reload, load
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        title = "Home"
        configMovieTableView()
    }
    
    override func setupData() {
        fetchData(for: .load)
    }
    
    private func updateUI(sectionIndex: Int){
        let indexSet = IndexSet(integer: sectionIndex)
        self.movieTableView.reloadSections(indexSet, with: .fade)
    }
    
    private func fetchData(for action: Action){
        if action == .reload {
            homeViewModel.resetMovies()
            movieTableView.reloadData()
        }
        homeViewModel.fetchData { (done, index, error) in
            if done {
                self.updateUI(sectionIndex: index)
            }else if let error = error {
                self.alert(errorString: error.localizedDescription)
            }
        }
    }

    private func configMovieTableView() {
        movieTableView.backgroundColor = App.Color.mainColor
        let nib = UINib(nibName: Config.nibNameCell, bundle: .main)
        movieTableView.register(nib, forCellReuseIdentifier: Config.withReuseIdentifier)
        movieTableView.register(UITableViewCell.self, forCellReuseIdentifier: Config.defautIdentifier)
        let footerView = UIView()
        movieTableView.showsVerticalScrollIndicator = false
        movieTableView.tableFooterView = footerView
        refeshControl.addTarget(self, action: #selector(handleRefeshData), for: .valueChanged)
        movieTableView.refreshControl = refeshControl
    }
    
    @objc private func handleRefeshData(){
        fetchData(for: .reload)
        refeshControl.endRefreshing()
    }

    @objc private func handleSeeMoreButton(sender: UIButton) {
          let moviesVC = MoviesVC()
          moviesVC.movieCategory = homeViewModel.movieCategories[sender.tag]
          navigationController?.pushViewController(moviesVC, animated: true)
    }
}

//MARK: -UITableViewDataSource
extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = App.Color.mainColor
        let titleLabel = Label()
        titleLabel.text = homeViewModel.movieCategories[section].title
        headerView.addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 5).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        let seeMoreButton = Button()
        seeMoreButton.tag = section
        seeMoreButton.setTitle(App.String.seeMoreTitle, for: .normal)
        seeMoreButton.addTarget(self, action: #selector(handleSeeMoreButton), for: .touchUpInside)
        headerView.addSubview(seeMoreButton)
        seeMoreButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 5).isActive = true
        seeMoreButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10).isActive = true
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Config.withReuseIdentifier) as? HomeCell  else {
            return UITableViewCell()
        }
        let movies = homeViewModel.movies[indexPath.section]
        cell.setupData(movies: movies)
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return homeViewModel.movieCategories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

//MARK: -UITableViewDelegate
extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
}
