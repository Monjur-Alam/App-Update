//
//  SplashViewController.swift
//  AppUpdate
//
//  Created by MunjurAlam on 12/6/25.
//

import UIKit

class SplashViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        VersionChecker.checkForUpdate { needsUpdate in
            DispatchQueue.main.async {
                if needsUpdate {
                    VersionChecker.showUpdateAlert(on: self)
                } else {
                    self.goToLoginScreen()
                }
            }
        }
    }

    private func goToLoginScreen() {
        let loginVC = LoginViewController()
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}

