//
//  API.Path.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 2/1/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

enum TrendingType: String {
    case week = "Week"
    case day = "Day"
}

extension APIManager.Path {
    struct TV {
        var page: Int = 1
        var with_genres: Int = 12
        var url: String {
            return APIManager.Path.baseURL / "discover" / "tv" + "?api_key=\(App.Key.apiKey)&language=en-US&sort_by=popularity.desc&page=\(page)&timezone=America%2FNew_York&with_genres=\(with_genres)&include_null_first_air_dates=false"
        }
        
        init() {}
        
        init(page: Int) {
            self.page = page
        }
        
        init(page: Int, with_genres: Int) {
            self.page = page
            self.with_genres = with_genres
        }
    }

    struct Discover {
        var page: Int = 1
        var with_genres: Int = 12
        var url: String {
            return APIManager.Path.baseURL / "discover" / "movie" + "?api_key=\(App.Key.apiKey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)&with_genres=\(with_genres)"
        }
        
        init() {}
        
        init(page: Int) {
            self.page = page
        }
        
        init(page: Int, with_genres: Int) {
            self.page = page
            self.with_genres = with_genres
        }
    }

    struct TopRated {
        var page: Int = 1
        var url: String {
            return APIManager.Path.baseURL / "movie" / "top_rated?api_key=\(App.Key.apiKey)&language=en-US&page=\(page)"
        }
    }

    struct Trending {
        var page: Int = 1
        var trendingType: TrendingType = .week
        var url: String {
            return APIManager.Path.baseURL / "trending" / "movie" / "\(trendingType.rawValue)?api_key=\(App.Key.apiKey)"
        }
        
        init() {}
        
        init(page: Int) {
            self.page = page
        }
        
        init(page: Int, trendingType: TrendingType ) {
            self.page = page
            self.trendingType = trendingType
        }
    }

    struct Popular {
        var page: Int = 1
        var url: String {
            return APIManager.Path.baseURL / "movie" / "popular?api_key=\(App.Key.apiKey)&language=en-US&page=\(page)"
        }
    }

    struct Upcoming {
        var page: Int = 1
        var url: String {
            return APIManager.Path.baseURL / "movie" / "upcoming?api_key=\(App.Key.apiKey)&language=en-US&page=\(page)"
        }
    }

    struct Details {
        var id: String
        var url: String {
            return APIManager.Path.baseURL / "movie" / "\(id)" + "?api_key=\(App.Key.apiKey)&language=en-US"
        }
    }

    struct Recommendations {
        var id: String
        var page: Int = 1
        var url: String {
            return APIManager.Path.baseURL / "movie" / "\(id)" / "recommendations?api_key=\(App.Key.apiKey)&language=en-US&page=\(page)"
        }
    }

    struct Similar {
        var id: String
        var page: Int = 1
        var url: String {
            return APIManager.Path.baseURL / "movie" / "\(id)" / "similar?api_key=\(App.Key.apiKey)&language=en-US&page=\(page)"
        }
    }

    struct Search {
        var query: String
        var page: Int = 1
        var url: String {
            return APIManager.Path.baseURL / "search" / "movie" + "?api_key=\(App.Key.apiKey)&language=en-US&query=\(query)&page=\(page)&include_adult=false"
        }
    }
    
    struct GenresTV {
        var url: String {
            return APIManager.Path.baseURL / "genre" / "movie" / "list?api_key=\(App.Key.apiKey)&language=en-US"
        }
    }
    
    struct GenresMovie {
        var url: String {
            return APIManager.Path.baseURL / "genre" / "tv" / "list?api_key=\(App.Key.apiKey)&language=en-US"
        }
    }
}
