//
//  MoviesViewModel.swift
//  Movie App
//
//  Created by An Nguyễn on 2/4/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

enum DisplayType {
    case row, grid
}

final class MoviesViewModel {
    var status: DisplayType = .grid
    var movies: [Movie] = []
    var currentPage: Int = 1
    var totalPages: Int = 0
    var movieCategory: MovieCategory?
    var url: String?
    var totalResults: Int = 0
    var isLoadData = false
    var genres: [Genre] = []
    var isShowFilter: Bool = false
    var genreFilter: Genre?
    var trendingTypeFilter: TrendingType?


    init() { }

    init(type: MovieCategory = .discover) {
        self.movieCategory = type
    }

    func detailViewModel(for id: Int) -> DetailViewModel {
        return DetailViewModel(by: id)
    }

    func handleUrl(page: Int = 1) {
        guard let category = self.movieCategory else { url = ""; return }
        switch category {
        case .trending:
            if let trendingType = trendingTypeFilter {
                url = APIManager.Path.Trending(page: page, trendingType: trendingType) .url
            } else {
                url = APIManager.Path.Trending(page: page) .url

            }
        case .discover:
            if let genre = genreFilter {
                url = APIManager.Path.Discover(page: page, with_genres: genre.id).url
            } else {
                url = APIManager.Path.Discover(page: page).url
            }
        case .tv:
            if let genre = genreFilter {
                url = APIManager.Path.TV(page: page, with_genres: genre.id) .url
            } else {
                url = APIManager.Path.TV(page: page).url
            }
        case .popular:
            url = APIManager.Path.Popular(page: page).url
        case .topRated:
            url = APIManager.Path.TopRated(page: page).url
        case .upcoming:
            url = APIManager.Path.Upcoming(page: page).url
        default:
            url = ""
        }
    }

    func fetchDataWithFilter(page: Int = 1, completion: @escaping Completion) {
        handleUrl(page: page)
        guard let url = url else {
            completion(false, APIError.errorURL)
            return
        }
        isLoadData = true
        API.shared().request(with: url) { (result) in
            switch result {
            case .failure(let error):
                completion(false, error)
            case .success(let data):
                guard let data = data else {
                    completion(false, APIError.emptyData)
                    return
                }
                let json = data.toJSObject()
                self.totalResults = json["total_results"] as? Int ?? 0
                if self.totalResults <= 0 {
                    completion(false, APIError.emptyData)
                    return
                }
                self.totalPages = json["total_pages"] as? Int ?? 0
                self.currentPage = json["page"] as? Int ?? 0
                if let results = json["results"] as? JSArray {
                    for item in results {
                        let movie = Movie(json: item)
                        self.movies.append(movie)
                    }
                }
                completion(true, nil)
                self.isLoadData = false
            }
        }
    }

    func fetchGenre(completion: @escaping Completion) {
        print("Fetching genres...")
        guard let category = movieCategory else { return }
        var url: String = ""
        if category == .tv {
            url = APIManager.Path.GenresTV().url
        } else if category == .discover {
            url = APIManager.Path.GenresMovie().url
        } else if category == .trending {
            genres = [
                Genre(id: 1, name: TrendingType.day.rawValue),
                Genre(id: 2, name: TrendingType.week.rawValue)
            ]
            completion(true, nil)
            return
        }
        API.shared().request(with: url) { (result) in
            switch result {
            case .failure(let error):
                completion(false, error)
            case .success(let data):
                guard let data = data else {
                    completion(false, APIError.emptyData)
                    return
                }
                let json = data.toJSObject()
                if let results = json["genres"] as? JSArray {
                    for item in results {
                        let genre = Genre(json: item)
                        self.genres.append(genre)
                    }
                }
                completion(true, nil)
            }
        }
    }

    func changedStatus() {
        if status == .row {
            status = .grid
        } else {
            status = .row
        }
    }

    func chageGenreFilter(genre: Genre) {
        genreFilter = genre
    }

    func changedTrendingTypeFilter(genre: Genre) {
        trendingTypeFilter = genre.name == "Day" ? .day : .week
    }

    func getMovie(at: IndexPath) -> Movie {
        return movies[at.row]
    }

    func numberOfItemsInSection() -> Int {
        return movies.count
    }

    func nextPage() -> Int {
        return currentPage + 1
    }

    func isNotLoadData() -> Bool {
        return !isLoadData
    }

    func getShowFilter() -> Bool {
        return isShowFilter
    }

    func changedShowFilter() {
        isShowFilter = !isShowFilter
    }

    func getMovieCategory() -> MovieCategory? {
        return movieCategory
    }
}
