//
//  HomeCellViewModel.swift
//  Movie App
//
//  Created by An Nguyễn on 2/10/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

final class HomeCellViewModel {
    var movies: [Movie] = []
    var isLoading: Bool = true
    var moviesEmpty: Bool {
        return movies.isEmpty
    }
    
    init() { }
    
    init(movies: [Movie], isLoading: Bool) {
        self.isLoading = isLoading
        self.movies = movies
    }

    func getLoading() -> Bool {
        return isLoading
    }

    func setLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }

    func getMovies() -> [Movie] {
        return movies
    }

    func setMovies(movies: [Movie]) {
        self.movies = movies
    }
    
    func numberOfItemsInSection() -> Int{
        return movies.count
    }
    
    func getMovie(indexPath: IndexPath) -> Movie {
        return movies[indexPath.row]
    }
}
