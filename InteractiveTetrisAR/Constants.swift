//
//  Constants.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation
import SwiftUI

/// 全域常數定義
struct Constants {
    // MARK: - Grid & Board
    /// 邏輯格子的行數
    static let gridRows: Int = 20
    /// 邏輯格子的列數
    static let gridCols: Int = 10
    /// 每個格子在 AR 世界中的實際大小 (公尺)
    static let cellSize: Float = 0.05
    /// 遊戲版面在 AR 世界中 Z 軸偏移 (鏡頭前方的距離, 公尺)
    static let boardOffsetZ: Float = -0.5
    /// 遊戲版面在 AR 世界中 Y 軸偏移 (抬高版面高度, 公尺)
    static let boardOffsetY: Float = 0.25

    // MARK: - Drop Interval
    /// 預設的方塊自動下墜間隔 (秒)
    static let defaultDropInterval: TimeInterval = 1.0

    // MARK: - Firebase Collections
    static let firebaseScoresCollection = "scores"
    static let firebaseUserSettingsCollection = "userSettings"

    // MARK: - UserDefaults Keys
    static let highScoresKey = "HighScores"
    static let gameSettingsKey = "GameSettings"

    // MARK: - Notification Names
    struct Notifications {
        /// 畫面切換通知 (object 為 "Main"/"Game"/"Score"/"Settings")
        static let navigateTo = Notification.Name("navigateTo")
        /// 新增分數通知 (object 為 ScoreRecord)
        static let addScore = Notification.Name("addScore")
    }
}

/// App 顏色調色盤
extension Color {
    static let sciFiButtonBackground = Color(red: 0.10, green: 0.10, blue: 0.20)
    static let sciFiButtonShadow = Color.purple.opacity(0.8)
    static let darkGradientStart = Color(red: 0.02, green: 0.02, blue: 0.05)
    static let darkGradientEnd = Color(red: 0.05, green: 0.01, blue: 0.10)
}

/// AppTheme 預設值擴充
