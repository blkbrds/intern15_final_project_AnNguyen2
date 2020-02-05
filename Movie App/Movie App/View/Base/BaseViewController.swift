//
//  BaseViewController.swift
//  Movie App
//
//  Created by An Nguyễn on 1/20/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    let refeshControl: UIRefreshControl = {
        let refeshControl = UIRefreshControl()
        refeshControl.tintColor = .white
        return refeshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        setupData()
        setupUI()
    }
    
    func configView(){
        view.backgroundColor = App.Color.mainColor
    }
    
    func setupUI() { }
    
    func setupData() { }
}
