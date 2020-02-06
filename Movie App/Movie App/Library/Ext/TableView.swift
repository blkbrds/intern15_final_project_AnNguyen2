//
//  TableView.swift
//  Movie App
//
//  Created by An Nguyễn on 2/6/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

extension UITableView {
    
    func reloadSection(section: Int){
        let indexSet = IndexSet(integer: section)
        reloadSections(indexSet, with: .fade)
    }
    
    func register(_ cellClass: AnyClass) {
        let identifier = String(describing: cellClass)
        let nib = UINib(nibName: identifier, bundle: .main)
        register(nib, forCellReuseIdentifier: identifier)
    }

    func dequeueReusableCell<T>(_ cellClass: T.Type, with indexPath: IndexPath? = nil) -> T {
        let identifier = String(describing: cellClass)
        if let indexPath = indexPath {
            let cell = dequeueReusableCell(cellClass, with: indexPath)
            return cell
        }
        guard let cell = dequeueReusableCell(withIdentifier: identifier) as? T else {
            fatalError("Can't load cell")
        }
        return cell
    }
}

