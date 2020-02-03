//
//  BaseNavigationController.swift
//  Order food
//
//  Created by An Nguyễn on 1/5/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }

    private func setupNavBar() {
        navigationBar.barStyle = .black
        navigationBar.tintColor = App.Color.barTint
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
