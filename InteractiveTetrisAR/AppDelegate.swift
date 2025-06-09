import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    // 直接以普通屬性保存 VM
    let settingsVM = SettingsViewModel()
    let scoreVM    = ScoreViewModel()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 不要再用 let settingsVM = …，改用上面的屬性
        let mainMenuView = MainMenuView()
            .environmentObject(settingsVM)
            .environmentObject(scoreVM)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: mainMenuView)
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
}
