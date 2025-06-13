//
//  SettingsService.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation

/// 本地使用者設定儲存服務：使用 UserDefaults + JSON 編碼/解碼
final class SettingsService {
    private let key = "GameSettings"

    /// 讀取本地儲存的使用者設定
    func load() -> SettingsData {
        guard let data = UserDefaults.standard.data(forKey: key),
              let settings = try? JSONDecoder().decode(SettingsData.self, from: data) else {
            // 若無本地設定，回傳預設值（音樂預設開啟）
            return SettingsData(
                playerName: "Player",
                isSoundOn: true,
                isHapticsOn: true,
                isMusicOn: true, // 音樂預設開啟
                selectedTheme: .default,
                gestureSensitivity: 1.0
            )
        }
        return settings
    }

    /// 將使用者設定儲存到本地
    func save(_ settings: SettingsData) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
