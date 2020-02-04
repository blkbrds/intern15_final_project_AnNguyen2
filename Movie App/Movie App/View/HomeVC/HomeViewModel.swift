//
//  HomeViewModel.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/21/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

typealias Completion = (Bool, APIError?) -> Void

enum MovieCategory: CaseIterable {
    case tv, discover, popular, topRated, trending

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
        }
    }
}

final class HomeViewModel {
    let movieCategories: [MovieCategory] = [.popular, .discover, .topRated, .trending, .tv]
    var movies: [[Movie]] = []

    init() {
        for _ in 1...movieCategories.count {
            movies.append([])
        }
    }

    func resetMovies() {
        for i in 0..<movieCategories.count {
            movies[i] = []
        }
    }

    func fetchData(completion: @escaping Completion) {
        let urls = movieCategories.map({ $0.defaultURL })
        for i in 0..<urls.count {
            API.shared().request(with: urls[i]) { (result) in
                switch result {
                case .failure(let error):
                    completion(false, error)
                case .success(let data):
                    guard let data = data else {
                        completion(false, APIError.emptyData)
                        return
                    }
                    let json = data.toJSObject()
                    var items: [Movie] = []
                    if let results = json["results"] as? [JSON] {
                        for item in results {
                            let movie = Movie(json: item)
                            items.append(movie)
                            completion(true, nil)
                        }
                    }
                    self.movies[i] = items
                }
            }
        }
    }
}