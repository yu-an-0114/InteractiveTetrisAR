import UIKit
import SwiftUI
import FirebaseCore

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
        // 安全地初始化 Firebase
        configureFirebase()
        
        // 不要再用 let settingsVM = …，改用上面的屬性
        let mainMenuView = MainMenuView()
            .environmentObject(settingsVM)
            .environmentObject(scoreVM)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: mainMenuView)
        self.window = window
        window.makeKeyAndVisible()
        
        // 設置導航通知監聽
        setupNavigationObserver()
        
        return true
    }
    
    // MARK: - Firebase 配置
    private func configureFirebase() {
        // 檢查是否有 GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            // 如果找到配置文件，嘗試初始化 Firebase
            do {
                FirebaseApp.configure()
                print("✅ Firebase 已成功初始化")
            } catch {
                print("❌ Firebase 初始化失敗：\(error)")
            }
        } else {
            print("⚠️ 未找到 GoogleService-Info.plist，Firebase 功能將被禁用")
            print("💡 如需啟用 Firebase 功能，請：")
            print("   1. 前往 Firebase Console 創建專案")
            print("   2. 下載 GoogleService-Info.plist")
            print("   3. 將檔案加入 Xcode 專案")
        }
    }
    
    // MARK: - 導航通知處理
    private func setupNavigationObserver() {
        NotificationCenter.default.addObserver(
            forName: Constants.Notifications.navigateTo,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let destination = notification.object as? String else { return }
            
            switch destination {
            case "Main":
                // 返回主選單
                let mainMenuView = MainMenuView()
                    .environmentObject(self?.settingsVM ?? SettingsViewModel())
                    .environmentObject(self?.scoreVM ?? ScoreViewModel())
                
                self?.window?.rootViewController = UIHostingController(rootView: mainMenuView)
                
            default:
                break
            }
        }
    }
}
