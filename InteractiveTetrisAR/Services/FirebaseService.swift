//
//  FirebaseService.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

/// 負責與 Firebase Firestore 互動（同步分數、使用者設定）
final class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()

    private init() { }

    // MARK: - 分數排行榜

    /// 上傳單筆分數到 Firestore
    /// - Parameter record: 要上傳的 ScoreRecord
    func uploadScore(_ record: ScoreRecord) {
        let data: [String: Any] = [
            "id": record.id.uuidString,
            "playerName": record.playerName,
            "score": record.score,
            "date": Timestamp(date: record.date)
        ]
        db.collection("scores")
            .document(record.id.uuidString)
            .setData(data) { error in
                if let err = error {
                    print("Firebase 上傳分數失敗：\(err)")
                }
            }
    }

    /// 刪除單筆分數
    /// - Parameter record: 要刪除的 ScoreRecord
    func deleteScore(_ record: ScoreRecord) {
        db.collection("scores")
            .document(record.id.uuidString)
            .delete() { error in
                if let err = error {
                    print("Firebase 刪除分數失敗：\(err)")
                }
            }
    }

    /// 取得前 N 名分數
    /// - Parameters:
    ///   - limit: 要取得的筆數上限（預設 10）
    ///   - completion: 回傳取得的 ScoreRecord 陣列
    func fetchTopScores(limit: Int = 10, completion: @escaping ([ScoreRecord]) -> Void) {
        db.collection("scores")
            .order(by: "score", descending: true)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    print("Firebase 讀取排行榜失敗：\(error?.localizedDescription ?? "未知錯誤")")
                    completion([])
                    return
                }
                let records = docs.compactMap { doc -> ScoreRecord? in
                    let data = doc.data()
                    guard
                        let name = data["playerName"] as? String,
                        let score = data["score"] as? Int,
                        let ts = data["date"] as? Timestamp,
                        let idString = data["id"] as? String,
                        let uuid = UUID(uuidString: idString)
                    else {
                        return nil
                    }
                    return ScoreRecord(
                        id: uuid,
                        playerName: name,
                        score: score,
                        date: ts.dateValue()
                    )
                }
                completion(records)
            }
    }

    /// 清空所有分數（僅用於開發或測試，實際使用請慎用）
    func clearAllScores() {
        db.collection("scores").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else {
                print("Firebase 讀取需刪除文檔失敗：\(error?.localizedDescription ?? "未知錯誤")")
                return
            }
            let batch = self.db.batch()
            docs.forEach { batch.deleteDocument($0.reference) }
            batch.commit { err in
                if let e = err {
                    print("Firebase 批次刪除分數失敗：\(e)")
                }
            }
        }
    }

    // MARK: - 使用者設定

    /// 更新使用者設定（聲音、震動、音樂、主題、靈敏度）
    /// - Parameter settings: 要同步到 Firebase 的 SettingsData
    func updateUserSettings(_ settings: SettingsData) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = [
            "playerName": settings.playerName,
            "isSoundOn": settings.isSoundOn,
            "isHapticsOn": settings.isHapticsOn,
            "isMusicOn": settings.isMusicOn,
            "selectedTheme": settings.selectedTheme.rawValue,
            "gestureSensitivity": settings.gestureSensitivity
        ]
        db.collection("userSettings")
            .document(uid)
            .setData(data, merge: true) { error in
                if let e = error {
                    print("Firebase 更新使用者設定失敗：\(e)")
                }
            }
    }

    /// 讀取使用者設定
    /// - Parameter completion: 回傳讀取到的 SettingsData，若不存在則回傳 nil
    func fetchUserSettings(completion: @escaping (SettingsData?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        db.collection("userSettings")
            .document(uid)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    completion(nil)
                    return
                }
                let name = data["playerName"] as? String ?? "Player"
                let isSound = data["isSoundOn"] as? Bool ?? true
                let isHaptics = data["isHapticsOn"] as? Bool ?? true
                let isMusic = data["isMusicOn"] as? Bool ?? true
                let themeRaw = data["selectedTheme"] as? String ?? AppTheme.`default`.rawValue
                let theme = AppTheme(rawValue: themeRaw) ?? AppTheme.`default`
                let sensitivity = data["gestureSensitivity"] as? Double ?? 1.0
                let settings = SettingsData(
                    playerName: name,
                    isSoundOn: isSound,
                    isHapticsOn: isHaptics,
                    isMusicOn: isMusic,
                    selectedTheme: theme,
                    gestureSensitivity: sensitivity
                )
                completion(settings)
            }
    }
}
