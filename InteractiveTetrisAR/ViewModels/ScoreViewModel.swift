//
//  ScoreViewModel.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation
import Combine

/// 管理分數列表，包括本地與 Firebase 同步
final class ScoreViewModel: ObservableObject {
    @Published private(set) var records: [ScoreRecord] = []
    
    private let service = ScoreService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLocalScores()
    }
    
    /// 從本地載入所有分數並排序
    func loadLocalScores() {
        records = service.loadAll()
            .sorted { $0.score > $1.score }
    }
    
    /// 新增一筆分數，先存本地，後推到 Firebase
    func addScore(_ record: ScoreRecord) {
        service.save(record)
        loadLocalScores()
        
        FirebaseService.shared.uploadScore(record)
    }
    
    /// 刪除特定分數：本地刪除與 Firebase 同步刪除
    func deleteScore(_ record: ScoreRecord) {
        service.delete(record)
        loadLocalScores()
        
        FirebaseService.shared.deleteScore(record)
    }
    
    /// 清空所有分數：清本地、清 Firebase
    func clearAll() {
        service.clearAll()
        records = []
        
        FirebaseService.shared.clearAllScores()
    }
    
    /// 用於替換整個列表（例如從 Firebase 重新載入）
    func replaceAll(with newRecords: [ScoreRecord]) {
        // 更新本地儲存
        service.replaceAll(with: newRecords)
        // 更新 published
        records = newRecords.sorted { $0.score > $1.score }
    }
    
    /// 從 Firebase 重新載入排行榜
    func fetchTopScores() {
        FirebaseService.shared.fetchTopScores(limit: 10) { [weak self] records in
            DispatchQueue.main.async {
                self?.replaceAll(with: records)
            }
        }
    }
}
