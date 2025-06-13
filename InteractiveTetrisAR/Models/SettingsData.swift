//
//  SettingsData.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation

/// 可供切換的 App 主題風格
enum AppTheme: String, CaseIterable, Codable {
    case `default`
    case nebula
    case darkMatter

    /// 對應不同主題的描述或顏色參數，可自行擴充
    var displayName: String {
        switch self {
        case .default: return "預設"
        case .nebula: return "星雲"
        case .darkMatter: return "暗物質"
        }
    }
}

/// 使用者設定資料結構，Codable 以便儲存到 UserDefaults 或 Firebase
struct SettingsData: Codable {
    /// 玩家暱稱
    var playerName: String

    /// 是否開啟音效
    var isSoundOn: Bool

    /// 是否開啟震動
    var isHapticsOn: Bool

    /// 是否開啟背景音樂
    var isMusicOn: Bool

    /// 選擇的 App 主題風格
    var selectedTheme: AppTheme

    /// 手勢靈敏度（範圍 0.5 ~ 2.0）
    var gestureSensitivity: Double

    /// 初始化時設定預設值
    init(
        playerName: String = "Player",
        isSoundOn: Bool = true,
        isHapticsOn: Bool = true,
        isMusicOn: Bool = true,
        selectedTheme: AppTheme = .default,
        gestureSensitivity: Double = 1.0
    ) {
        self.playerName = playerName
        self.isSoundOn = isSoundOn
        self.isHapticsOn = isHapticsOn
        self.isMusicOn = isMusicOn
        self.selectedTheme = selectedTheme
        self.gestureSensitivity = gestureSensitivity
    }

    /// 預設設定值
    static let `default` = SettingsData(
        playerName: "Player",
        isSoundOn: true,
        isHapticsOn: true,
        isMusicOn: true, // 音樂預設開啟
        selectedTheme: .`default`,
        gestureSensitivity: 1.0
    )
}
