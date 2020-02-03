//
//  Movie.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/21/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

class Movie {
    var popularity: Double
    var voteCount: Int
    var posterPath: String
    var id: Int
    var backdropPath: String
    var originalTitle: String
    var title: String
    var overview: String
    var voteAverage: Int
    var releaseDate: String
    var page: Int = 0
    
    init(json: JSON) {
        self.id = json["id"] as? Int ?? 0
        self.popularity = json["popularity"] as? Double ?? 0.0
        self.voteCount = json["vote_count"] as? Int ?? 0
        self.posterPath = json["poster_path"] as? String ?? ""
        self.backdropPath = json["backdrop_path"] as? String ?? ""
        self.originalTitle = json["original_title"] as? String ?? ""
        self.title = json["title"] as? String ?? ""
        self.overview = json["overview"] as? String ?? ""
        self.voteAverage = json["vote_average"] as? Int ?? 0
        self.releaseDate = json["release_date"] as? String ?? ""
    }
}
