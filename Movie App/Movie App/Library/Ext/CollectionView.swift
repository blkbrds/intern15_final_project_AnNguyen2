//
//  CollectionView.swift
//  Movie App
//
//  Created by An Nguyễn on 2/6/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register(_ cellClass: AnyClass) {
        let identifier = String(describing: cellClass)
        let nib = UINib(nibName: identifier, bundle: .main)
        register(nib, forCellWithReuseIdentifier: identifier)
    }

    func dequeueReusableCell<T>(with cellClass: T.Type, for indexPath: IndexPath) -> T {
        let identifier = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Can't load cell")
        }
        return cell
    }
}
