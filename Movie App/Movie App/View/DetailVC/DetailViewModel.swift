//
//  DetailViewModel.swift
//  Movie App
//
//  Created by An Nguyễn on 2/5/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation
import XCDYouTubeKit

final class DetailViewModel {
    var movie: Movie?
    var movieID: Int?
    var movies: [[Movie]] = [[], []]
    var movieCategories: [MovieCategory] = [.similar, .recommendations]
    var urlVideo: URL?
    var keyVideo: String?
    var isLoading: [Bool] = [true, true]

    init() { }

    init(by id: Int) {
        self.movieID = id
    }

    func resetMovie() {
        movie = nil
    }

    func getMovie() -> Movie? {
        return movie
    }

    func getVideoUrl() -> URL? {
        return urlVideo
    }

    func getTitle(section: Int) -> String {
        return movieCategories[section].title
    }

    func numberOfSections() -> Int {
        return movies.count
    }

    func moviesIn(indexPath: IndexPath) -> [Movie] {
        return movies[indexPath.section]
    }

    func detailViewModel(for id: Int) -> DetailViewModel {
        return DetailViewModel(by: id)
    }

    func getLoading(indexPath: IndexPath) -> Bool {
        return isLoading[indexPath.section]
    }

    func resetMovies() {
        movies = Array(repeating: [], count: movieCategories.count)
    }

    func fetchMovieData(completion: @escaping Completion) {
        guard let id = movieID else {
            completion(false, APIError.emptyID)
            return
        }
        let url = APIManager.Path.Details(id: "\(id)").url
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
                self.movie = Movie(json: json)
                completion(true, nil)
            }
        }
    }

    func fetchSimilarRecommendMovie(completion: @escaping Completion) {
        guard let id = movieID else {
            isLoading[0] = false
            isLoading[1] = false
            return
        }
        let urls: [String] = [
            APIManager.Path.Similar(id: "\(id)").url,
            APIManager.Path.Recommendations(id: "\(id)").url,
        ]
        let group = DispatchGroup()
        print("Loading data...")
        for i in 0..<urls.count {
            group.enter()
            API.shared().request(with: urls[i]) { (result) in
                switch result {
                case .failure(_):
                    self.isLoading[i] = false
                case .success(let data):
                    if let data = data {
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
                }
                self.isLoading[i] = false
                group.leave()
                print("Loaded data \(i)...")
            }
        }
        group.notify(queue: .main) {
            print("Finished task")
            completion(true, nil)
        }
    }

    func getURLMovieVideo(completion: @escaping Completion) {
        guard let id = movieID else {
            completion(false, APIError.emptyID)
            return
        }
        let url = APIManager.Path.Trailer(id: id).url
        API.shared().request(with: url) { (result) in
            switch result {
            case .failure(let error):
                completion(false, error)
                return
            case .success(let data):
                guard let data = data else {
                    completion(false, APIError.emptyData)
                    return
                }
                let json = data.toJSObject()
                guard let results = json["results"] as? JSArray, !results.isEmpty else {
                    completion(false, APIError.emptyData)
                    return
                }
                guard let key = results[0]["key"] as? String else {
                    completion(false, APIError.emptyData)
                    return
                }
                self.keyVideo = key
                XCDYouTubeClient.default().getVideoWithIdentifier("\(key)") { (video, error) in
                    if let _ = error {
                        completion(false, APIError.canNotGetVideoURL)
                        return
                    }
                    guard let video = video else {
                        completion(false, APIError.canNotGetVideoURL)
                        return
                    }
                    self.urlVideo = video.streamURL
                    completion(true, nil)
                }
            }
        }
    }
}
