//
//  HomeViewModel.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/21/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

typealias Completion = (Bool, APIError?) -> Void
typealias CompletionWithIndex = (Bool, Int, APIError?) -> Void


enum MovieCategory: CaseIterable {
    case tv, discover, popular, topRated, trending, similar, recommendations

    var title: String {
        switch self {
        case .trending:
            return "Trending"
        case .discover:
            return "Discover"
        case .popular:
            return "Popular"
        case .topRated:
            return "Top rated"
        case .tv:
            return "TV"
        case .recommendations:
            return "Recommendations"
        case .similar:
            return "Similar"
        }

    }

    var defaultURL: String {
        switch self {
        case .trending:
            return APIManager.Path.Trending().url
        case .discover:
            return APIManager.Path.Discover().url
        case .popular:
            return APIManager.Path.Popular().url
        case .topRated:
            return APIManager.Path.TopRated().url
        case .tv:
            return APIManager.Path.TV().url
        default:
            return ""
        }
    }
}

final class HomeViewModel {
    let movieCategories: [MovieCategory] = [.popular, .discover, .topRated, .trending, .tv]
    var movies: [[Movie]] = [[], [], [], [], []]

    func moviesViewModel(at index: Int) -> MoviesViewModel {
        return MoviesViewModel(type: movieCategories[index])
    }
    
    func detailViewModel(for id: Int) -> DetailViewModel {
        return DetailViewModel(by: id)
    }

    func getTitleForHeader(at index: Int) -> String {
        return movieCategories[index].title
    }

    func getMovies(for section: Int) -> [Movie] {
        return movies[section]
    }

    func numberOfSections() -> Int {
        return movies.count
    }

    func resetMovies() {
        for i in 0..<movieCategories.count {
            movies[i] = []
        }
    }

    func fetchData(completion: @escaping CompletionWithIndex) {
        let urls = movieCategories.map({ $0.defaultURL })
        for i in 0..<urls.count {
            API.shared().request(with: urls[i]) { (result) in
                switch result {
                case .failure(let error):
                    completion(false, i, error)
                case .success(let data):
                    guard let data = data else {
                        completion(false, i, APIError.emptyData)
                        return
                    }
                    let json = data.toJSObject()
                    var items: [Movie] = []
                    if let results = json["results"] as? JSArray {
                        for item in results {
                            let movie = Movie(json: item)
                            items.append(movie)
                        }
                    }
                    self.movies[i] = items
                    completion(true, i, nil)
                }
            }
        }
    }
}
