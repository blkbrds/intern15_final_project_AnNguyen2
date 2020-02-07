//
//  FavoriteViewModel.swift
//  Movie App
//
//  Created by An Nguyễn on 2/6/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

final class FavoriteViewModel {
    var movies: [Movie] = []
    var isEmptyItems: Bool {
        return movies.isEmpty
    }

    func resetMovies() {
        movies = []
    }

    func getMovie(in indexPath: IndexPath) -> Movie {
        return movies[indexPath.row]
    }

    func detailViewModel(for id: Int) -> DetailViewModel {
        return DetailViewModel(by: id)
    }

    func fetchData(completion: @escaping Completion) {
        let movies = RealmManager.shared().getAllObjects(object: Movie.self)
        self.movies = movies
        completion(true, nil)
    }

    func removeMovieInFavorite(movie: Movie?, completion: @escaping Completion) {
        guard let movie = movie else { return }
        RealmManager.shared().deleteObject(object: movie, forPrimaryKey: movie.id) { (done, error) in
            completion(done, error)
        }
    }

    func removeMoviesInFavorite(movies: [Movie], completion: @escaping Completion) {
        let forPrimaryKeys = movies.map({ $0.id })
        RealmManager.shared().deleteObjects(object: Movie.self, forPrimaryKeys: forPrimaryKeys) { (done, error) in
            completion(done, error)
        }
    }
}
