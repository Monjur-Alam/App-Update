//
//  LoginViewController.swift
//  AppUpdate
//
//  Created by MunjurAlam on 12/6/25.
//

import UIKit

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        VersionChecker.checkForUpdate { needsUpdate in
            DispatchQueue.main.async {
                if needsUpdate {
                    VersionChecker.showUpdateAlert(on: self)
                }
            }
        }

        // Simulate successful login and move to Home
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.goToHomeScreen()
        }
    }

    private func goToHomeScreen() {
        let homeVC = HomeViewController()
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
}

