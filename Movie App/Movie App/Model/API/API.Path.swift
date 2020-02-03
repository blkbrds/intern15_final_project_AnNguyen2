//
//  API.Path.swift
//  Demo Movie App
//
//  Created by An Nguyễn on 2/1/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

extension APIManager.Path {
    struct TV {
        var sort_by: String = "popularity.desc"
        var page: Int = 1
        var with_genres: Int = 12
        var url: String {
            return APIManager.Path.baseURL / "discover" / "tv" + "?api_key=\(App.Key.apiKey)&language=en-US&sort_by=\(sort_by)&page=\(page)&timezone=America%2FNew_York&with_genres=\(with_genres)&include_null_first_air_dates=false"
        }
    }

    struct Discover {
        var sort_by: String = "popularity.desc"
        var page: Int = 1
        var with_genres: Int = 12
        var url: String {
            return APIManager.Path.baseURL / "discover" / "movie" + "?api_key=\(App.Key.apiKey)&language=en-US&sort_by=\(sort_by)&include_adult=false&include_video=false&page=\(page)&with_genres=\(with_genres)"
        }
    }

    struct TopRated {
        var page: Int = 1
        var url: String {
            return APIManager.Path.baseURL / "movie" / "top_rated?api_key=\(App.Key.apiKey)&language=en-US&page=\(page)"
        }
    }

    struct Trending {
        enum TrendingType: String {
            case week, day
        }
        var page: Int = 1
        var trendingType: TrendingType = .week
        var url: String {
            return APIManager.Path.baseURL / "trending" / "movie" / "\(trendingType.rawValue)?api_key=\(App.Key.apiKey)"
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
}
