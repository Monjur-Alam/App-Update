//
//  VersionChecker.swift
//  AppUpdate
//
//  Created by MunjurAlam on 12/6/25.
//

import UIKit

class VersionChecker {
    static func checkForUpdate(completion: @escaping (Bool) -> Void) {
        let latestVersion = "5.6.22"
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

        if latestVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
            completion(true)
        } else {
            completion(false)
        }
    }

    static func showUpdateAlert(on viewController: UIViewController) {
        let alert = UIAlertController(title: "Update Available",
                                      message: "A new version of the app is available. Please update to continue.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Update Now", style: .default) { _ in
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1451513467") {
                UIApplication.shared.open(url)
            }
        })
        viewController.present(alert, animated: true)
    }
}
