//
//  MoviesViewModel.swift
//  Movie App
//
//  Created by An Nguyễn on 2/4/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import Foundation

enum DisplayType {
    case row, grid
}

final class MoviesViewModel {
    var status: DisplayType = .grid
    var movies: [Movie] = []
    
    func changedStatus() {
        if status == .row {
            self.status = .grid
        } else {
            self.status = .row
        }
    }
}
