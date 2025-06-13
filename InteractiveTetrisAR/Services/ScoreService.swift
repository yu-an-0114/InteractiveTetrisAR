//
//  ScoreService.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation

/// 本地分數儲存服務：使用 UserDefaults + JSON 編碼/解碼
final class ScoreService {
    private let key = "HighScores"

    /// 讀取所有分數紀錄
    func loadAll() -> [ScoreRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let arr = try? JSONDecoder().decode([ScoreRecord].self, from: data) else {
            return []
        }
        return arr
    }

    /// 新增一筆分數，並儲存到 UserDefaults
    func save(_ record: ScoreRecord) {
        var existing = loadAll()
        existing.append(record)
        if let data = try? JSONEncoder().encode(existing) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// 刪除指定分數
    func delete(_ record: ScoreRecord) {
        var existing = loadAll()
        existing.removeAll { $0.id == record.id }
        if let data = try? JSONEncoder().encode(existing) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// 用新的陣列覆寫所有分數（如從 Firebase 重新載入時）
    func replaceAll(with newRecords: [ScoreRecord]) {
        if let data = try? JSONEncoder().encode(newRecords) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// 清空所有分數紀錄
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
