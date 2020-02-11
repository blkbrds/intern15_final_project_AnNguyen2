//
//  GridCellViewModel.swift
//  Movie App
//
//  Created by An Nguyễn on 2/10/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

final class GridCellViewModel {
    var movie: Movie?
    var imageData: Data?
    
    init() {}
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    func getMovie() -> Movie? {
        return movie
    }
    
    func getImageData() -> Data? {
        return imageData
    }
    
    func loadImageData(completion: @escaping (Bool, APIError?, String) -> Void){
        guard let movie = movie else { return }
        let urlString = APIManager.Path.baseImage3URL + movie.posterPath
        APIManager.Downloader.downloadImage(with: urlString) {(data, error) in
            if let error = error {
                completion(false, APIError.error(error.localizedDescription), urlString)
                return
            }
            self.imageData = data
            completion(true, nil, urlString)
        }
    }
}
