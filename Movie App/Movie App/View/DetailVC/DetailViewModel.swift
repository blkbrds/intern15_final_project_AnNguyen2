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
    var localUrl: URL?
    var isSaved: Bool = false
    var isLoadVideoOnline: Bool = false
    var isLoading: [Bool] = [true, true]

    init() { }

    init(by id: Int) {
        movieID = id
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

    func downloaded() -> Bool {
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

    func getLoading(indexPath: IndexPath) -> Bool {
        return isLoading[indexPath.section]
    }

    func resetMovies() {
        movies = Array(repeating: [], count: movieCategories.count)
    }

    func setDataImageMovie(data: Data?) {
        movie?.imageData = data
    }

    func isLoadingVideo() -> Bool {
        return isLoadVideoOnline
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

    func fetchSimilarRecommendMovie(completion: @escaping Completion) {
        guard let id = movieID else {
            isLoading[0] = false
            isLoading[1] = false
            completion(false, APIError.emptyID)
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
        isLoadVideoOnline = true
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
                XCDYouTubeClient.default().getVideoWithIdentifier("\(key)") { (video, error) in
                    self.isLoadVideoOnline = false
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

    func downloadMovie(progressUpdating: @escaping (Double, Error?) -> Void) {
        guard let url = urlVideo else {
            progressUpdating(0, APIError.invalidURL)
            return
        }
        if let _ = localUrl {
            progressUpdating(0, APIError.error("Saved!"))
            return
        }
        guard let movie = movie else {
            progressUpdating(0, APIError.error("Movie!"))
            return
        }
        APIManager.Downloader.downloadVideo(
            with: url.absoluteString,
            nameFile: "\(movie.id).mp4",
            progressValue: { (progress) in
                progressUpdating(progress, nil)

            }, completion: { data, error in
                if let _ = error {
                    progressUpdating(0, APIError.error("Can't download video movie!"))
                }
            })
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

    func checkMovieInDownload() {
        guard let movie = movie else { return }
        RealmManager.shared().getObjectForKey(object: Movie.self, forPrimaryKey: movie.id) { (movie, error) in
            if let _ = error {
                return
            }
            self.isSaved = true
        }
    }

    func addMovieContentToDownload(completion: @escaping Completion) {
        guard let movie = movie else { return }
        RealmManager.shared().addNewObject(object: movie) { (done, error) in
            self.isSaved = true
            completion(done, error)
        }
    }

    func deleteVieo(movieID: Int) {
        let fileManager = FileManager.default

        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let filePath: String = documentDirectory.path + "/\(movieID).mp4"
            if fileManager.fileExists(atPath: filePath) {
                print("Exist")
                let itemUrl = URL(fileURLWithPath: filePath)
                try fileManager.removeItem(at: itemUrl)
                print("Delete local movie video sucess!")
            } else {
                print("Video not exist!")
            }
        } catch {
            print(APIError.errorURL.localizedDescription)
        }
    }

    func removeMovie(completion: @escaping Completion) {
        guard let movie = movie else { return }
        self.deleteVieo(movieID: movie.id)
        RealmManager.shared().deleteObject(object: movie, forPrimaryKey: movie.id) { (done, error) in
            self.isSaved = false
            completion(done, error)
        }
    }
}
