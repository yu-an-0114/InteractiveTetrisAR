//
//  ScoreRecord.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation

/// 單筆分數資料，用於排行榜顯示與儲存
/// 支援 Codable 以便編碼/解碼到本地或透過 Firebase 讀寫
struct ScoreRecord: Identifiable, Codable {
    /// 唯一識別 ID
    let id: UUID
    
    /// 玩家暱稱
    let playerName: String
    
    /// 得分
    let score: Int
    
    /// 遊戲結束時間
    let date: Date
    
    init(id: UUID = UUID(), playerName: String, score: Int, date: Date = Date()) {
        self.id = id
        self.playerName = playerName
        self.score = score
        self.date = date
    }
}
