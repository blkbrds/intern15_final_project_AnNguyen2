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
    
    func detailViewModel(for id: Int) -> DetailViewModel {
        return DetailViewModel(by: id)
    }
    
    func fetchData(completion: @escaping Completion){
        let movies = RealmManager.shared().getAllObjects(object: Movie.self)
        self.movies = movies
        completion(true, nil)
    }
    
    func removeInFavorite(movie: Movie?, completion: @escaping Completion){
        guard let movie = movie else { return }
        RealmManager.shared().deleteItem(object: movie, forPrimaryKey: movie.id) { (done, error) in
            completion(done, error)
        }
    }
}
