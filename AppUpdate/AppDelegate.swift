//
//  AppDelegate.swift
//  AppUpdate
//
//  Created by MunjurAlam on 11/6/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

//    func applicationDidBecomeActive(_ application: UIApplication) {
//        let lastCheckKey = "lastUpdateCheckDate"
//        let today = Calendar.current.startOfDay(for: Date())
//        let lastChecked = UserDefaults.standard.object(forKey: lastCheckKey) as? Date
//
//        if lastChecked == nil || Calendar.current.isDate(today, inSameDayAs: lastChecked!) {
//            UserDefaults.standard.set(today, forKey: lastCheckKey)
//
//            if let rootVC = window?.rootViewController {
//                VersionChecker.checkForUpdate { needsUpdate in
//                    DispatchQueue.main.async {
//                        if needsUpdate {
//                            VersionChecker.showUpdateAlert(on: rootVC)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        window = UIWindow(frame: UIScreen.main.bounds)
//        let navController = UINavigationController(rootViewController: SplashViewController())
//        window?.rootViewController = navController
//        window?.makeKeyAndVisible()
//        return true
//    }
    
    
     func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         AppUpdateManager.shared.performBackgroundUpdateCheck(completion: completionHandler)
     }
    
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         AppUpdateManager.shared.handleSilentPush(userInfo: userInfo, completion: completionHandler)
     }
}

