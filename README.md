# API-Based Forced App Update (UIKit)

This guide describes how to implement a **forced app update** in an iOS UIKit app using a backend-controlled minimum version number.

## 📌 Requirements
- iOS app in UIKit (programmatic or storyboard-based)
- Backend API that returns a JSON object containing `min_supported_version_ios`

Example API response:
```json
{
  "min_supported_version_ios": "10.10.5"
}
```
## 🎯 Goal
- If app version is less than `min_supported_version_ios` → show a blocking update screen.
- If app version is equal to or greater → continue normally.
- Backend value can be updated anytime without resubmitting the app.

## 1. Version Check Helper
```swift
func isVersion(_ version: String, lessThan minVersion: String) -> Bool {
    let current = version.split(separator: ".").compactMap { Int($0) }
    let minimum = minVersion.split(separator: ".").compactMap { Int($0) }
    
    for i in 0..<max(current.count, minimum.count) {
        let c = i < current.count ? current[i] : 0
        let m = i < minimum.count ? minimum[i] : 0
        if c < m { return true }
        if c > m { return false }
    }
    return false
}
```

## 2. Loading Splash ViewController
This acts as a temporary screen while fetching API data.
```swift
class LoadingViewController: UIViewController {
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
```

## 3. Forced Update ViewController
```swift
class ForceUpdateViewController: UIViewController {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "A new version of the app is required.\nPlease update to continue."
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Now", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(updateTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(messageLabel)
        view.addSubview(updateButton)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            updateButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),
            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateButton.widthAnchor.constraint(equalToConstant: 200),
            updateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func updateTapped() {
        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") {
            UIApplication.shared.open(url)
        }
    }
}
```

## 4. API Fetcher
```swift
class VersionChecker {
    static let shared = VersionChecker()
    
    func fetchMinSupportedVersion(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://your-api.com/config") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let minVersion = json["min_supported_version_ios"] as? String else {
                completion(nil)
                return
            }
            completion(minVersion)
        }.resume()
    }
}
```
## 5. AppDelegate Implementation
```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LoadingViewController()
        window?.makeKeyAndVisible()
        
        // Perform version check in the background
        VersionChecker.shared.fetchMinSupportedVersion { minVersion in
            DispatchQueue.main.async {
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                
                if let minVersion = minVersion, isVersion(currentVersion, lessThan: minVersion) {
                    self.window?.rootViewController = ForceUpdateViewController()
                } else {
                    self.window?.rootViewController = MainTabBarController() // Replace with your real main VC
                }
            }
        }
        
        return true
    }
}
```
## Or, Integrate in SceneDelegate
```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = LoadingViewController()
        window?.makeKeyAndVisible()
        
        // Perform version check in the background
        VersionChecker.shared.fetchMinSupportedVersion { minVersion in
            DispatchQueue.main.async {
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
                
                if let minVersion = minVersion, isVersion(currentVersion, lessThan: minVersion) {
                    self.window?.rootViewController = ForceUpdateViewController()
                } else {
                    self.window?.rootViewController = MainTabBarController() // Replace with your real main VC
                }
            }
        }
    }
}
```

## 6. Flow
1. App starts → Shows `LoadingViewController` immediately (no black screen).
2. API call runs → Fetches `min_supported_version_ios`.
3. If current version < min version → Show `ForceUpdateViewController` (blocking).
4. Else → Load your real app UI (`MainTabBarController`).
