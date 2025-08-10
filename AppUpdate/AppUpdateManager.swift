//
//  AppUpdateManager.swift
//  AppUpdate
//
//  Created by MunjurAlam on 12/7/25.
//

import UIKit

struct UpdateInfo: Codable {
    let latestVersion: String
    let minRequiredVersion: String
}

class AppUpdateManager {

    static let shared = AppUpdateManager()
    private init() {}

    func checkForUpdate() {
        // Option 1: Check App Store version
        checkAppStoreVersion()

        // Option 2: Check custom backend or Firebase
        checkRemoteConfigVersion()
    }

    // MARK: - 1. App Store Version Check
    private func checkAppStoreVersion() {
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)")!

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let appStoreVersion = results.first?["version"] as? String,
                  let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            else { return }

            if appStoreVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                DispatchQueue.main.async {
                    self.promptUpdate(version: appStoreVersion)
                }
            }
        }.resume()
    }

    private func promptUpdate(version: String) {
        guard let window = UIApplication.shared.windows.first,
              let rootVC = window.rootViewController else { return }

        let alert = UIAlertController(title: "Update Available",
                                      message: "Version \(version) is available. Please update now.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Update", style: .default) { _ in
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1451513467") {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: nil))
        rootVC.present(alert, animated: true)
    }

    // MARK: - 2. Remote Config or Backend
    private func checkRemoteConfigVersion() {
        let url = URL(string: "https://your-api.com/update-info")!

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let updateInfo = try? JSONDecoder().decode(UpdateInfo.self, from: data),
                  let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }

            if current.compare(updateInfo.minRequiredVersion, options: .numeric) == .orderedAscending {
                self.showForceUpdate()
            } else if current.compare(updateInfo.latestVersion, options: .numeric) == .orderedAscending {
                self.showOptionalUpdate()
            }
        }.resume()
    }

    private func showForceUpdate() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first,
                  let rootVC = window.rootViewController else { return }

            let alert = UIAlertController(title: "Update Required",
                                          message: "Please update to continue using the app.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Update", style: .default) { _ in
                UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID")!)
            })
            rootVC.present(alert, animated: true)
        }
    }

    private func showOptionalUpdate() {
        DispatchQueue.main.async {
            self.promptUpdate(version: "latest")
        }
    }

    // MARK: - 3. Background Fetch (Optional)
    func performBackgroundUpdateCheck(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        checkAppStoreVersion()
        completion(.newData)
    }

    // MARK: - 4. Silent Push
    func handleSilentPush(userInfo: [AnyHashable: Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        if let updateCheck = userInfo["updateCheck"] as? Bool, updateCheck {
            checkAppStoreVersion()
        }
        completion(.newData)
    }
}
