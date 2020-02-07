//
//  UIKitEx.swift
//  MyApp
//
//  Created by iOSTeam on 2/21/18.
//  Copyright © 2018 Asian Tech Co., Ltd. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(errorString: String) {
        alert(title: "ERROR", msg: errorString, buttons: ["OK"], handler: nil)
    }

    func deleteAlert(title: String? = "Warning!", msg: String, okAction handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "Delete", style: .default, handler: handler)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func alert(title: String? = nil, msg: String, buttons: [String], handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        for button in buttons {
            let action = UIAlertAction(title: button, style: .cancel, handler: { action in
                handler?(action)
            })
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
    }
}
