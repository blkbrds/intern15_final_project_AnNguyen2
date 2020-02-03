//
//  BaseTabBarViewController.swift
//  Order food
//
//  Created by An Nguyễn on 1/5/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        let homeVC = HomeVC()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage.init(systemName: "house"), tag: 0)
        let navHomeController = BaseNavigationController(rootViewController: homeVC)

        let searchVC = SearchVC()
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage.init(systemName: "magnifyingglass"), tag: 1)
        let navSearchController = BaseNavigationController(rootViewController: searchVC)

        let comingSoonVC = ComingSoonVC()
        comingSoonVC.tabBarItem = UITabBarItem(title: "Coming Soon", image: UIImage.init(systemName: "greaterthan.square"), tag: 2)
        let navComingSoonController = BaseNavigationController(rootViewController: comingSoonVC)

        let favoriteVC = FavoriteVC()
        favoriteVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage.init(systemName: "heart"), tag: 3)
        let navFavoriteController = BaseNavigationController(rootViewController: favoriteVC)

        viewControllers = [navHomeController, navSearchController, navComingSoonController, navFavoriteController]
        tabBar.tintColor = .white
        tabBar.barStyle = .black
    }
}
