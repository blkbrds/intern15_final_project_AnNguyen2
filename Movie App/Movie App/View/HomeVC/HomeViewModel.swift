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
    case tv, discover, popular, topRated, trending, similar, recommendations, upcoming

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
        case .upcoming:
            return "Upcoming"
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
        case .upcoming:
            return APIManager.Path.Upcoming().url
        default:
            return ""
        }
    }
}

final class HomeViewModel {
    let movieCategories: [MovieCategory] = [.popular, .discover, .topRated, .trending, .tv, .upcoming]
    var movies: [[Movie]] = [[], [], [], [], [], []]
    var isLoading: [Bool] = Array(repeating: true, count: 6)

    func moviesViewModel(at index: Int) -> MoviesViewModel {
        return MoviesViewModel(type: movieCategories[index])
    }

    func detailViewModel(for id: Int) -> DetailViewModel {
        return DetailViewModel(by: id)
    }

    func getTitleForHeader(at index: Int) -> String {
        return movieCategories[index].title
    }

    func getMovies(for indexPath: IndexPath) -> [Movie] {
        return movies[indexPath.section]
    }

    func numberOfSections() -> Int {
        return movies.count
    }

    func resetMovies() {
        movies = Array(repeating: [], count: movieCategories.count)
        isLoading = Array(repeating: true, count: 6)
    }
    
    func isLoadingData(indexPath: IndexPath) -> Bool {
        return isLoading[indexPath.section]
    }

    func fetchData(completion: @escaping CompletionWithIndex) {
        let urls = movieCategories.map({ $0.defaultURL })
        let group = DispatchGroup()
        for i in 0..<urls.count {
            group.enter()
            API.shared().request(with: urls[i]) { (result) in
                switch result {
                case .failure(_):
                    print("")
                case .success(let data):
                    guard let data = data else {
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
                }
                group.leave()
                self.isLoading[i] = false
                print("Loaded \(i)")
            }
        }
        group.notify(queue: .main) {
            print("Loaded all.")
            completion(true, 0, nil)
        }
    }
}
