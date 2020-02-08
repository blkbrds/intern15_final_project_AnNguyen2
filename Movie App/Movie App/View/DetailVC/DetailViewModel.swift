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

    func resetMovies() {
        for i in 0..<movieCategories.count {
            movies[i] = []
        }
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


    func fetchSimilarRecommendMovie(completion: @escaping CompletionWithIndex) {
        guard let id = movieID else {
            completion(false, 0, APIError.emptyID)
            return
        }
        let urls: [String] = [
            APIManager.Path.Similar(id: "\(id)").url,
            APIManager.Path.Recommendations(id: "\(id)").url,
        ]
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
