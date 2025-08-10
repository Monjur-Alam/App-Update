//
//  HomeViewController.swift
//  AppUpdate
//
//  Created by MunjurAlam on 12/6/25.
//

import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue

        VersionChecker.checkForUpdate { needsUpdate in
            DispatchQueue.main.async {
                if needsUpdate {
                    VersionChecker.showUpdateAlert(on: self)
                }
            }
        }
    }
}

