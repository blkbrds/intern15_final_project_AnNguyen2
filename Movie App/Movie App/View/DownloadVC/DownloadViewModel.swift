//
//  FavoriteViewModel.swift
//  Movie App
//
//  Created by An Nguyễn on 2/6/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

final class DownloadViewModel {
    var movies: [Movie] = []
    var isEmptyItems: Bool {
        return movies.isEmpty
    }

    func resetMovies() {
        movies = []
    }

    func removeMovie(at: IndexPath) {
        movies.remove(at: at.row)
    }

    func getIndexPath(forID id: Int) -> IndexPath? {
        for index in 0..<movies.count {
            if movies[index].id == id {
                return IndexPath(row: index, section: 0)
            }
        }
        return nil
    }

    func numberOfRowsInSection() -> Int {
        return movies.count
    }

    func getMovie(in indexPath: IndexPath) -> Movie {
        return movies[indexPath.row]
    }

    func detailViewModel(for id: Int) -> DetailViewModel {
        return DetailViewModel(by: id)
    }

    func fetchData(completion: @escaping Completion) {
        let movies = RealmManager.shared().getAllObjects(type: Movie.self)
            .sorted { (movie1, movie2) -> Bool in
                movie1.originalTitle.lowercased() < movie2.originalTitle.lowercased()
        }
        self.movies = movies
        completion(true, nil)
    }

    func removeMovieInFavorite(movie: Movie?, completion: @escaping Completion) {
        guard let movie = movie else { return }
        deleteVieo(movieID: movie.id)
        RealmManager.shared()
            .deleteObject(type: Movie.self,
                forPrimaryKey: movie.id) { [weak self] (done, error) in
                guard let _ = self else { return }
                if done {
                    completion(done, nil)
                    print("Delete movie")
                } else {
                    completion(false, error)
                    print("Can't Delete movie")
                }
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

    func removeMoviesInFavorite(movies: [Movie], completion: @escaping Completion) {
        let forPrimaryKeys = movies.map({ $0.id })
        forPrimaryKeys.forEach({
            deleteVieo(movieID: $0)
        })
        RealmManager.shared().deleteObjects(type: Movie.self, forPrimaryKeys: forPrimaryKeys) { [weak self] (done, error) in
            guard let _ = self else { return }
            completion(done, error)
        }
    }
}
