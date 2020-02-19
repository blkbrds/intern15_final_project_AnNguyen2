//
//  RowCellViewModel.swift
//  Movie App
//
//  Created by An Nguyễn on 2/10/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

final class DownloadCellViewModel {
    var movie: Movie?
    var indexPath: IndexPath?
    
    init() {}
    
    init(movie: Movie, indexPath: IndexPath) {
        self.movie = movie
        self.indexPath = indexPath
    }
    
    func getIndexPath() -> IndexPath? {
        return indexPath
    }
    
    func getMovie() -> Movie? {
        return movie
    }
    
    func getImageData() -> Data? {
        return movie?.imageData
    }
}
