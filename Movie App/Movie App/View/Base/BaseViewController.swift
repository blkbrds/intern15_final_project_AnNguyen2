//
//  BaseViewController.swift
//  Movie App
//
//  Created by An Nguyễn on 1/20/20.
//  Copyright © 2020 An Nguyễn. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }

    func setupUI() { }
    
    func setupData() { }
}
