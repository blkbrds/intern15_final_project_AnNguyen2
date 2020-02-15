//
//  SearchViewModel.swift
//  Movie App
//
//  Created by An Nguyễn on 2/5/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

final class SearchViewModel {
    var movies: [Movie] = []
    var isLoadData = false
    var currentPage: Int = 1
    var totalPages: Int = 0
    var totalResults: Int = 0
    var query: String = ""
    var oldQuery: String = ""
    var oldTime: Date = Date()
    var oldTimer: Timer?
    var isEmptyMovie: Bool {
        return movies.isEmpty
    }

    func detailViewModel(for id: Int) -> DetailViewModel {
        return DetailViewModel(by: id)
    }

    func resetMovies() {
        movies = []
    }

    func isNotLoadData() -> Bool {
        return !isLoadData
    }

    func numberOfItems() -> Int {
        return movies.count
    }

    func getMovie(indexPath: IndexPath) -> Movie {
        return movies[indexPath.row]
    }

    func getTotalPags() -> Int {
        return totalPages
    }

    func getCurrentPage() -> Int {
        return currentPage
    }

    func updateQuery(text: String) {
        query = text
    }
    
    func updateOldQuery(text: String) {
        oldQuery = text
    }
    
    func getOldQuery() -> String {
        return oldQuery
    }
    
    func getTimer() -> Timer? {
        return oldTimer
    }
    
    func updateOldTimer(timer: Timer) {
        oldTimer = timer
    }

    func resetPage() {
        currentPage = 0
        totalPages = 0
    }
    
    func fetchSearchData(page: Int = 1, completion: @escaping Completion) {
        query = query.trimmed.replacingOccurrences(of: " ", with: "+") //or %20
        guard query != "" else { return }
        let url = APIManager.Path.Search(query: query, page: page).url
        isLoadData = true
        API.shared().request(with: url) {[weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .failure(let error):
                completion(false, error)
                self.isLoadData = false
            case .success(let data):
                guard let data = data else {
                    completion(false, APIError.emptyData)
                    self.isLoadData = false
                    return
                }
                let json = data.toJSObject()
                self.totalResults = json["total_results"] as? Int ?? 0
                if self.totalResults <= 0 {
                    completion(false, APIError.emptyData)
                    self.isLoadData = false
                    return
                }
                self.totalPages = json["total_pages"] as? Int ?? 0
                self.currentPage = json["page"] as? Int ?? 0
                if let results = json["results"] as? JSArray {
                    for item in results {
                        let movie = Movie(json: item)
                        self.movies.append(movie)
                    }
                }
                completion(true, nil)
                self.isLoadData = false
            }
        }
    }

    func secondsBetween(newTime: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: oldTime, to: newTime).second
    }
}
