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
    var localUrl: URL?
    var isSaved: Bool = false

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
    
    func setupMovie(movie: Movie) {
        self.movie = movie
        isSaved = true
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

    func isDownloaded() -> Bool {
        return isSaved
    }

    func localVideoUrl() -> URL? {
        return localUrl
    }

    func getVideoUrlOnline() -> URL? {
        return urlVideo
    }

    func detailViewModel(for id: Int) -> DetailViewModel {
        return DetailViewModel(by: id)
    }

    func resetMovies() {
        for i in 0..<movieCategories.count {
            movies[i] = []
        }
    }

    func setDataImageMovie(data: Data?) {
        movie?.imageData = data
    }

    func fetchMovieData(completion: @escaping Completion) {
        guard let id = movieID else {
            completion(false, APIError.emptyID)
            return
        }
        if let _ = movie {
            completion(true, nil)
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
                self.getLocalVideoUrl()
                self.checkMovieInDownload()
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
                        completion(false, APIError.error("Video not exist!"))
                        return
                    }
                    self.urlVideo = video.streamURL
                    completion(true, nil)
                }
            }
        }
    }

    func saveOfflineVideo(completion: @escaping(_ data: URL?, _ error: Error?) -> Void) {
        guard let url = urlVideo else {
            completion(nil, APIError.invalidURL)
            return
        }
        if let _ = localUrl {
            completion(nil, APIError.error("Saved!"))
            return
        }
        API.shared().request(with: url.absoluteString) { (result) in
            switch result {
            case .failure(let error):
                completion(nil, error)
                return
            case .success(let data):
                guard let data = data else {
                    completion(nil, APIError.emptyData)
                    return
                }
                let fileManager = FileManager.default
                do {
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    guard let movie = self.movie else {
                        completion(nil, APIError.emptyID)
                        return
                    }
                    let fileURL = documentDirectory.appendingPathComponent("\(movie.id).mp4")
                    print(fileURL.path)
                    try data.write(to: fileURL)
                    completion(fileURL, nil)
                } catch {
                    completion(nil, APIError.errorURL)
                }
            }
        }
    }

    func getLocalVideoUrl() {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            guard let movie = self.movie else {
                print("Video movie in local is empty!")
                return
            }
            let filePath: String = documentDirectory.path + "/\(movie.id).mp4"
            if let _ = fileManager.contents(atPath: filePath) {
                self.localUrl = URL(fileURLWithPath: filePath)
                print("Get success video movie in local!")
            } else {
                print("Video movie in local is empty!")
            }
        } catch {
            print(APIError.errorURL.localizedDescription)
        }
    }

    func deleteVieo() {
        guard let id = movieID else { return }
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let filePath: String = documentDirectory.path + "/\(id).mp4"
            if fileManager.fileExists(atPath: filePath) {
                print("Exist")
                let itemUrl = URL(fileURLWithPath: filePath)
                try fileManager.removeItem(at: itemUrl)
                print("Delete local movie video sucess!")
            }else {
                print("Video not exist!")
            }
        } catch {
            print(APIError.errorURL.localizedDescription)
        }
    }

    func checkMovieInDownload() {
        guard let movie = movie else { return }
        RealmManager.shared().getObjectForKey(object: Movie.self, forPrimaryKey: movie.id) { (movie, error) in
            if let _ = error {
                return
            }
            self.isSaved = true
        }
    }

    func addMoviewToDownload(completion: @escaping Completion) {
        guard let movie = movie else { return }
        RealmManager.shared().addNewObject(object: movie) { (done, error) in
            self.isSaved = true
            completion(done, error)
        }
    }

    func removeInDownload(completion: @escaping Completion) {
        guard let movie = movie else { return }
        RealmManager.shared().deleteObject(object: movie, forPrimaryKey: movie.id) { (done, error) in
            self.isSaved = false
            if done {
                self.deleteVieo()
            }
            completion(done, error)
        }
    }
}
