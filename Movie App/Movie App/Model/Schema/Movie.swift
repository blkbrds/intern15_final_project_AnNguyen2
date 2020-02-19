//
//  Movie.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 1/21/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import RealmSwift

final class Movie: Object {
    @objc dynamic var popularity: Double = 0.0
    @objc dynamic var voteCount: Int = 0
    @objc dynamic var posterPath: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var backdropPath: String = ""
    @objc dynamic var originalTitle: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var overview: String = ""
    @objc dynamic var voteAverage: Float = 0.0
    @objc dynamic var releaseDate: Date?
    @objc dynamic var page: Int = 0
    @objc dynamic var tagLine: String = ""
    @objc dynamic var homePage: String = ""
    @objc dynamic var imageData: Data?

    convenience init(json: JSObject) {
        self.init()
        self.id = json["id"] as? Int ?? 0
        self.popularity = json["popularity"] as? Double ?? 0.0
        self.voteCount = json["vote_count"] as? Int ?? 0
        self.posterPath = json["poster_path"] as? String ?? ""
        self.backdropPath = json["backdrop_path"] as? String ?? ""
        self.originalTitle = json["original_title"] as? String ?? ""
        self.title = json["title"] as? String ?? ""
        self.overview = json["overview"] as? String ?? ""
        self.voteAverage = json["vote_average"] as? Float ?? 0.0
        let dateStr = json["release_date"] as? String
        self.releaseDate = dateStr?.toDate()
        self.tagLine = json["tagline"] as? String ?? ""
        self.homePage = json["homepage"] as? String ?? ""
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
