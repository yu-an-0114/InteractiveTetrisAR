//
//  LocalizationService.swift
//  InteractiveTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation

/// 語言服務，負責管理多語言支援
class LocalizationService: ObservableObject {
    static let shared = LocalizationService()
    
    @Published var currentLanguage: String = "繁體中文"
    
    private let userDefaultsKey = "SelectedLanguage"
    
    private init() {
        // 從 UserDefaults 載入語言設定
        currentLanguage = UserDefaults.standard.string(forKey: userDefaultsKey) ?? "繁體中文"
    }
    
    /// 設置語言
    /// - Parameter language: 語言名稱
    func setLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: userDefaultsKey)
    }
    
    /// 獲取本地化文字
    /// - Parameter key: 文字鍵值
    /// - Returns: 本地化文字
    func localizedString(for key: LocalizationKey) -> String {
        switch currentLanguage {
        case "繁體中文":
            return key.chinese
        case "English":
            return key.english
        case "日本語":
            return key.japanese
        case "한국어":
            return key.korean
        case "Español":
            return key.spanish
        case "Français":
            return key.french
        default:
            return key.chinese // 預設使用繁體中文
        }
    }
}

/// 本地化文字鍵值
enum LocalizationKey {
    case startGame
    case settings
    case leaderboard
    case tutorial
    case playerName
    case gameDifficulty
    case handGestureSettings
    case audioSettings
    case languageSelection
    case soundEffects
    case vibrationFeedback
    case backgroundMusic
    case confirm
    case cancel
    case save
    case back
    case score
    case time
    case pause
    case resume
    case gameOver
    case next
    case veryEasy
    case easy
    case normal
    case hard
    case veryHard
    case extreme
    case dropInterval
    case gestureSensitivity
    case handTutorial
    case moveControl
    case rotationControl
    case quickDrop
    case tips
    case editPlayerName
    case enterPlayerName
    case nameWillShowInLeaderboard
    case adjustGameAudioAndFeedback
    case blockMovementSoundEffects
    case vibrationPromptForGestures
    case backgroundMusicDuringGame
    case adjustGestureRecognitionParameters
    case low
    case high
    case pinchDistanceThreshold
    case controlIndexThumbTouchDistance
    case fistDistanceThreshold
    case controlFistGestureDistance
    case fingerExtensionThreshold
    case controlFingerExtensionRecognition
    case gestureChangeCooldown
    case preventRapidGestureSwitching
    case minConfidenceThreshold
    case minimumConfidenceForGestureRecognition
    case resetToDefaults
    case reload
    case yourScore
    case handDetected
    case noGesture
    case leftRotation
    case rightRotation
    case fingersClosed
    case learnGestureControlTechniques
    case palmLeftRightMovement
    case leftArea1To4
    case middleArea5To6
    case rightArea7To10
    case palmLeftRotationOver40
    case palmRightRotationOver40
    case palmHorizontal40To40
    case needToReturnToNormalAngle
    case fingerTipsCloseToCenter
    case palmPositionMustBeInMiddleArea
    case bothConditionsMustBeMet
    case keepPalmInCameraView
    case palmMovementShouldBeSmooth
    case keepPalmStableDuringRotation
    case ensureAllFingertipsAreClose
    case practiceGesturesOnTestPage
    case gameConfigurationAndPreferences
    case useGestureControl
    case viewHighestScoreRecords
    case version
    case interactiveTetrisAR
    case futureTechTetris
    case gestureInstructionMoveControl
    case gestureInstructionRotationControl
    case gestureInstructionQuickDrop
    case gestureInstructionTips
    case gestureInstructionPalmMovement
    case gestureInstructionLeftArea
    case gestureInstructionMiddleArea
    case gestureInstructionRightArea
    case gestureInstructionPalmLeftRotation
    case gestureInstructionPalmRightRotation
    case gestureInstructionPalmHorizontal
    case gestureInstructionReturnToNormalAngle
    case gestureInstructionFingerTipsClose
    case gestureInstructionPalmPositionMiddle
    case gestureInstructionBothConditions
    case gestureInstructionKeepPalmInView
    case gestureInstructionSmoothMovement
    case gestureInstructionStableRotation
    case gestureInstructionEnsureFingertipsClose
    case gestureInstructionPracticeOnTestPage
    case futureTechnologyRussianBlock
    case startGameDescription
    case settingsDescription
    case leaderboardDescription
    case tutorialDescription
    case finalScore
    case playTime
    case difficulty
    case playAgain
    case backToMain
    case scoreSaved
    case scoreSavedMessage
    
    var chinese: String {
        switch self {
        case .startGame: return "開始遊戲"
        case .settings: return "設定"
        case .leaderboard: return "排行榜"
        case .tutorial: return "教學"
        case .playerName: return "玩家名稱"
        case .gameDifficulty: return "遊戲難度"
        case .handGestureSettings: return "手部控制設定"
        case .audioSettings: return "音效設定"
        case .languageSelection: return "語言選擇"
        case .soundEffects: return "遊戲音效"
        case .vibrationFeedback: return "震動回饋"
        case .backgroundMusic: return "背景音樂"
        case .confirm: return "確認"
        case .cancel: return "取消"
        case .save: return "儲存"
        case .back: return "返回"
        case .score: return "分數"
        case .time: return "時間"
        case .pause: return "暫停"
        case .resume: return "繼續"
        case .gameOver: return "遊戲結束"
        case .next: return "下一個"
        case .veryEasy: return "非常簡單"
        case .easy: return "簡單"
        case .normal: return "正常"
        case .hard: return "困難"
        case .veryHard: return "非常困難"
        case .extreme: return "極限"
        case .dropInterval: return "落下間隔"
        case .gestureSensitivity: return "手勢靈敏度"
        case .handTutorial: return "手勢教學"
        case .moveControl: return "移動控制"
        case .rotationControl: return "旋轉控制"
        case .quickDrop: return "快速下降"
        case .tips: return "使用技巧"
        case .editPlayerName: return "編輯玩家名稱"
        case .enterPlayerName: return "輸入玩家名稱"
        case .nameWillShowInLeaderboard: return "名稱將顯示在排行榜中"
        case .adjustGameAudioAndFeedback: return "調整遊戲音效與回饋"
        case .blockMovementSoundEffects: return "方塊移動、消除等音效"
        case .vibrationPromptForGestures: return "手勢操作時的震動提示"
        case .backgroundMusicDuringGame: return "遊戲進行時的背景音樂"
        case .adjustGestureRecognitionParameters: return "調整手勢識別參數"
        case .low: return "低"
        case .high: return "高"
        case .pinchDistanceThreshold: return "捏合距離閾值"
        case .controlIndexThumbTouchDistance: return "控制食指與拇指觸碰的識別距離"
        case .fistDistanceThreshold: return "握拳距離閾值"
        case .controlFistGestureDistance: return "控制握拳手勢的識別距離"
        case .fingerExtensionThreshold: return "手指伸展閾值"
        case .controlFingerExtensionRecognition: return "控制手指伸展程度的識別"
        case .gestureChangeCooldown: return "手勢切換冷卻時間"
        case .preventRapidGestureSwitching: return "防止手勢快速切換的冷卻時間"
        case .minConfidenceThreshold: return "最小置信度閾值"
        case .minimumConfidenceForGestureRecognition: return "手勢識別的最小置信度要求"
        case .resetToDefaults: return "重置為預設值"
        case .reload: return "重新載入"
        case .yourScore: return "您的分數"
        case .handDetected: return "手部已檢測到"
        case .noGesture: return "無手勢"
        case .leftRotation: return "左旋轉"
        case .rightRotation: return "右旋轉"
        case .fingersClosed: return "手指併攏"
        case .learnGestureControlTechniques: return "學習手勢控制技巧"
        case .palmLeftRightMovement: return "手掌左右移動控制方塊左右移動"
        case .leftArea1To4: return "左側區域(1-4)：方塊向左移動"
        case .middleArea5To6: return "中間區域(5-6)：方塊不移動"
        case .rightArea7To10: return "右側區域(7-10)：方塊向右移動"
        case .palmLeftRotationOver40: return "手掌向左旋轉(超過40°)：方塊逆時針旋轉"
        case .palmRightRotationOver40: return "手掌向右旋轉(超過40°)：方塊順時針旋轉"
        case .palmHorizontal40To40: return "手掌保持水平(-40°~40°)：無旋轉動作"
        case .needToReturnToNormalAngle: return "需要先恢復到正常角度才能再次旋轉"
        case .fingerTipsCloseToCenter: return "手指併攏：所有指尖點距離中心小於0.07"
        case .palmPositionMustBeInMiddleArea: return "手掌位置：必須在中間區域(3-7)"
        case .bothConditionsMustBeMet: return "同時滿足以上條件觸發快速下降"
        case .keepPalmInCameraView: return "保持手掌在攝像頭視野內"
        case .palmMovementShouldBeSmooth: return "手掌移動要平滑，避免突然動作"
        case .keepPalmStableDuringRotation: return "旋轉時保持手掌穩定"
        case .ensureAllFingertipsAreClose: return "手指併攏時要確保所有指尖都靠近"
        case .practiceGesturesOnTestPage: return "可以通過測試頁面練習手勢"
        case .gameConfigurationAndPreferences: return "遊戲配置與偏好設定"
        case .useGestureControl: return "使用手勢控制"
        case .viewHighestScoreRecords: return "查看最高分數記錄"
        case .version: return "版本"
        case .interactiveTetrisAR: return "互動式TetrisAR"
        case .futureTechTetris: return "未來科技Tetris"
        case .gestureInstructionMoveControl: return "手勢控制指示：移動控制"
        case .gestureInstructionRotationControl: return "手勢控制指示：旋轉控制"
        case .gestureInstructionQuickDrop: return "手勢控制指示：快速下降"
        case .gestureInstructionTips: return "手勢控制指示：使用技巧"
        case .gestureInstructionPalmMovement: return "手勢控制指示：手掌移動"
        case .gestureInstructionLeftArea: return "手勢控制指示：左側區域"
        case .gestureInstructionMiddleArea: return "手勢控制指示：中間區域"
        case .gestureInstructionRightArea: return "手勢控制指示：右側區域"
        case .gestureInstructionPalmLeftRotation: return "手勢控制指示：手掌左旋轉"
        case .gestureInstructionPalmRightRotation: return "手勢控制指示：手掌右旋轉"
        case .gestureInstructionPalmHorizontal: return "手勢控制指示：手掌水平"
        case .gestureInstructionReturnToNormalAngle: return "手勢控制指示：恢復正常角度"
        case .gestureInstructionFingerTipsClose: return "手勢控制指示：手指併攏"
        case .gestureInstructionPalmPositionMiddle: return "手勢控制指示：手掌位置在中間"
        case .gestureInstructionBothConditions: return "手勢控制指示：兩個條件"
        case .gestureInstructionKeepPalmInView: return "手勢控制指示：保持手掌在視野內"
        case .gestureInstructionSmoothMovement: return "手勢控制指示：平滑移動"
        case .gestureInstructionStableRotation: return "手勢控制指示：穩定旋轉"
        case .gestureInstructionEnsureFingertipsClose: return "手勢控制指示：確保手指靠近"
        case .gestureInstructionPracticeOnTestPage: return "手勢控制指示：在測試頁面練習"
        case .futureTechnologyRussianBlock: return "未來科技俄羅斯方塊"
        case .startGameDescription: return "使用手勢控制方塊"
        case .settingsDescription: return "遊戲配置與偏好設定"
        case .leaderboardDescription: return "查看最高分數記錄"
        case .tutorialDescription: return "學習手勢控制技巧"
        case .finalScore: return "最終分數"
        case .playTime: return "遊戲時間"
        case .difficulty: return "遊戲難度"
        case .playAgain: return "再玩一次"
        case .backToMain: return "返回主畫面"
        case .scoreSaved: return "分數已保存"
        case .scoreSavedMessage: return "分數已成功保存"
        }
    }
    
    var english: String {
        switch self {
        case .startGame: return "Start Game"
        case .settings: return "Settings"
        case .leaderboard: return "Leaderboard"
        case .tutorial: return "Tutorial"
        case .playerName: return "Player Name"
        case .gameDifficulty: return "Game Difficulty"
        case .handGestureSettings: return "Hand Gesture Settings"
        case .audioSettings: return "Audio Settings"
        case .languageSelection: return "Language Selection"
        case .soundEffects: return "Sound Effects"
        case .vibrationFeedback: return "Vibration Feedback"
        case .backgroundMusic: return "Background Music"
        case .confirm: return "Confirm"
        case .cancel: return "Cancel"
        case .save: return "Save"
        case .back: return "Back"
        case .score: return "Score"
        case .time: return "Time"
        case .pause: return "Pause"
        case .resume: return "Resume"
        case .gameOver: return "Game Over"
        case .next: return "Next"
        case .veryEasy: return "Very Easy"
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        case .veryHard: return "Very Hard"
        case .extreme: return "Extreme"
        case .dropInterval: return "Drop Interval"
        case .gestureSensitivity: return "Gesture Sensitivity"
        case .handTutorial: return "Hand Tutorial"
        case .moveControl: return "Move Control"
        case .rotationControl: return "Rotation Control"
        case .quickDrop: return "Quick Drop"
        case .tips: return "Tips"
        case .editPlayerName: return "Edit Player Name"
        case .enterPlayerName: return "Enter Player Name"
        case .nameWillShowInLeaderboard: return "Player Name Will Show in Leaderboard"
        case .adjustGameAudioAndFeedback: return "Adjust Game Audio and Feedback"
        case .blockMovementSoundEffects: return "Block Movement Sound Effects"
        case .vibrationPromptForGestures: return "Vibration Prompt for Gestures"
        case .backgroundMusicDuringGame: return "Background Music During Game"
        case .adjustGestureRecognitionParameters: return "Adjust Gesture Recognition Parameters"
        case .low: return "Low"
        case .high: return "High"
        case .pinchDistanceThreshold: return "Pinch Distance Threshold"
        case .controlIndexThumbTouchDistance: return "Control Index Thumb Touch Distance"
        case .fistDistanceThreshold: return "Fist Distance Threshold"
        case .controlFistGestureDistance: return "Control Fist Gesture Distance"
        case .fingerExtensionThreshold: return "Finger Extension Threshold"
        case .controlFingerExtensionRecognition: return "Control Finger Extension Recognition"
        case .gestureChangeCooldown: return "Gesture Change Cooldown"
        case .preventRapidGestureSwitching: return "Prevent Rapid Gesture Switching"
        case .minConfidenceThreshold: return "Min Confidence Threshold"
        case .minimumConfidenceForGestureRecognition: return "Minimum Confidence for Gesture Recognition"
        case .resetToDefaults: return "Reset to Defaults"
        case .reload: return "Reload"
        case .yourScore: return "Your Score"
        case .handDetected: return "Hand Detected"
        case .noGesture: return "No Gesture"
        case .leftRotation: return "Left Rotation"
        case .rightRotation: return "Right Rotation"
        case .fingersClosed: return "Fingers Closed"
        case .learnGestureControlTechniques: return "Learn Gesture Control Techniques"
        case .palmLeftRightMovement: return "Palm Left-Right Movement Controls Block Movement"
        case .leftArea1To4: return "Left Area(1-4)：Block Moves Left"
        case .middleArea5To6: return "Middle Area(5-6)：Block Does Not Move"
        case .rightArea7To10: return "Right Area(7-10)：Block Moves Right"
        case .palmLeftRotationOver40: return "Palm Left Rotation(over 40°)：Block Rotates Counterclockwise"
        case .palmRightRotationOver40: return "Palm Right Rotation(over 40°)：Block Rotates Clockwise"
        case .palmHorizontal40To40: return "Palm Keeps Horizontal(-40°~40°)：No Rotation Action"
        case .needToReturnToNormalAngle: return "Must Return to Normal Angle to Rotate Again"
        case .fingerTipsCloseToCenter: return "Fingers Closed：All Finger Tips Less Than 0.07 from Center"
        case .palmPositionMustBeInMiddleArea: return "Palm Position：Must Be in Middle Area(3-7)"
        case .bothConditionsMustBeMet: return "Both Conditions Must Be Met to Activate Quick Drop"
        case .keepPalmInCameraView: return "Keep Palm in Camera View"
        case .palmMovementShouldBeSmooth: return "Palm Movement Must Be Smooth, Avoid Sudden Movements"
        case .keepPalmStableDuringRotation: return "Keep Palm Stable During Rotation"
        case .ensureAllFingertipsAreClose: return "Ensure All Finger Tips Are Close When Closing Fingers"
        case .practiceGesturesOnTestPage: return "Can Practice Gestures on Test Page"
        case .gameConfigurationAndPreferences: return "Game Configuration and Preferences"
        case .useGestureControl: return "Use Gesture Control"
        case .viewHighestScoreRecords: return "View Highest Score Records"
        case .version: return "Version"
        case .interactiveTetrisAR: return "Interactive TetrisAR"
        case .futureTechTetris: return "Future Tech Tetris"
        case .gestureInstructionMoveControl: return "Gesture Control Instruction：Move Control"
        case .gestureInstructionRotationControl: return "Gesture Control Instruction：Rotation Control"
        case .gestureInstructionQuickDrop: return "Gesture Control Instruction：Quick Drop"
        case .gestureInstructionTips: return "Gesture Control Instruction：Tips"
        case .gestureInstructionPalmMovement: return "Gesture Control Instruction：Palm Movement"
        case .gestureInstructionLeftArea: return "Gesture Control Instruction：Left Area"
        case .gestureInstructionMiddleArea: return "Gesture Control Instruction：Middle Area"
        case .gestureInstructionRightArea: return "Gesture Control Instruction：Right Area"
        case .gestureInstructionPalmLeftRotation: return "Gesture Control Instruction：Palm Left Rotation"
        case .gestureInstructionPalmRightRotation: return "Gesture Control Instruction：Palm Right Rotation"
        case .gestureInstructionPalmHorizontal: return "Gesture Control Instruction：Palm Horizontal"
        case .gestureInstructionReturnToNormalAngle: return "Gesture Control Instruction：Return to Normal Angle"
        case .gestureInstructionFingerTipsClose: return "Gesture Control Instruction：Fingers Closed"
        case .gestureInstructionPalmPositionMiddle: return "Gesture Control Instruction：Palm Position Middle"
        case .gestureInstructionBothConditions: return "Gesture Control Instruction：Both Conditions"
        case .gestureInstructionKeepPalmInView: return "Gesture Control Instruction：Keep Palm in View"
        case .gestureInstructionSmoothMovement: return "Gesture Control Instruction：Smooth Movement"
        case .gestureInstructionStableRotation: return "Gesture Control Instruction：Stable Rotation"
        case .gestureInstructionEnsureFingertipsClose: return "Gesture Control Instruction：Ensure Fingertips Close"
        case .gestureInstructionPracticeOnTestPage: return "Gesture Control Instruction：Practice on Test Page"
        case .futureTechnologyRussianBlock: return "Future Technology Russian Block"
        case .startGameDescription: return "Use Gesture Control"
        case .settingsDescription: return "Game Configuration and Preferences"
        case .leaderboardDescription: return "View Highest Score Records"
        case .tutorialDescription: return "Learn Gesture Control Techniques"
        case .finalScore: return "Final Score"
        case .playTime: return "Play Time"
        case .difficulty: return "Difficulty"
        case .playAgain: return "Play Again"
        case .backToMain: return "Back to Main"
        case .scoreSaved: return "Score Saved"
        case .scoreSavedMessage: return "Score Saved Successfully"
        }
    }
    
    var japanese: String {
        switch self {
        case .startGame: return "ゲーム開始"
        case .settings: return "設定"
        case .leaderboard: return "ランキング"
        case .tutorial: return "チュートリアル"
        case .playerName: return "プレイヤー名"
        case .gameDifficulty: return "ゲーム難易度"
        case .handGestureSettings: return "ハンドジェスチャー設定"
        case .audioSettings: return "音声設定"
        case .languageSelection: return "言語選択"
        case .soundEffects: return "効果音"
        case .vibrationFeedback: return "振動フィードバック"
        case .backgroundMusic: return "BGM"
        case .confirm: return "確認"
        case .cancel: return "キャンセル"
        case .save: return "保存"
        case .back: return "戻る"
        case .score: return "スコア"
        case .time: return "時間"
        case .pause: return "一時停止"
        case .resume: return "再開"
        case .gameOver: return "ゲームオーバー"
        case .next: return "次"
        case .veryEasy: return "とても簡単"
        case .easy: return "簡単"
        case .normal: return "普通"
        case .hard: return "難しい"
        case .veryHard: return "とても難しい"
        case .extreme: return "極限"
        case .dropInterval: return "落下間隔"
        case .gestureSensitivity: return "ジェスチャー感度"
        case .handTutorial: return "ハンドチュートリアル"
        case .moveControl: return "移動制御"
        case .rotationControl: return "回転制御"
        case .quickDrop: return "クイックドロップ"
        case .tips: return "ヒント"
        case .editPlayerName: return "プレイヤー名編集"
        case .enterPlayerName: return "プレイヤー名を入力"
        case .nameWillShowInLeaderboard: return "プレイヤー名がランキングに表示されます"
        case .adjustGameAudioAndFeedback: return "ゲーム音声とフィードバックの調整"
        case .blockMovementSoundEffects: return "ブロック移動・消去などの効果音"
        case .vibrationPromptForGestures: return "ジェスチャー操作時の振動プロンプト"
        case .backgroundMusicDuringGame: return "ゲーム中のBGM"
        case .adjustGestureRecognitionParameters: return "ジェスチャー認識パラメータの調整"
        case .low: return "低"
        case .high: return "高"
        case .pinchDistanceThreshold: return "ピンチ距離閾値"
        case .controlIndexThumbTouchDistance: return "人差し指と親指の接触距離制御"
        case .fistDistanceThreshold: return "握り拳距離閾値"
        case .controlFistGestureDistance: return "握り拳ジェスチャー距離制御"
        case .fingerExtensionThreshold: return "指伸展閾値"
        case .controlFingerExtensionRecognition: return "指伸展認識制御"
        case .gestureChangeCooldown: return "ジェスチャー変更クールダウン"
        case .preventRapidGestureSwitching: return "急速なジェスチャー切り替え防止"
        case .minConfidenceThreshold: return "最小信頼度閾値"
        case .minimumConfidenceForGestureRecognition: return "ジェスチャー認識の最小信頼度"
        case .resetToDefaults: return "デフォルトにリセット"
        case .reload: return "再読み込み"
        case .yourScore: return "あなたのスコア"
        case .handDetected: return "手が検出されました"
        case .noGesture: return "ジェスチャーなし"
        case .leftRotation: return "左回転"
        case .rightRotation: return "右回転"
        case .fingersClosed: return "指を閉じる"
        case .learnGestureControlTechniques: return "ジェスチャー制御技術を学ぶ"
        case .palmLeftRightMovement: return "手のひらの左右移動でブロックを左右に移動"
        case .leftArea1To4: return "左側エリア(1-4)：ブロックを左に移動"
        case .middleArea5To6: return "中央エリア(5-6)：ブロックは移動しない"
        case .rightArea7To10: return "右側エリア(7-10)：ブロックを右に移動"
        case .palmLeftRotationOver40: return "手のひらを左に回転(40° 以上)：ブロックを反時計回りに回転"
        case .palmRightRotationOver40: return "手のひらを右に回転(40° 以上)：ブロックを時計回りに回転"
        case .palmHorizontal40To40: return "手のひらを水平に保持(-40°~40°)：回転動作なし"
        case .needToReturnToNormalAngle: return "再度回転するには正常な角度に戻す必要があります"
        case .fingerTipsCloseToCenter: return "指を閉じる：すべての指先が中心から0.07未満"
        case .palmPositionMustBeInMiddleArea: return "手のひら位置：中央エリア(3-7)である必要があります"
        case .bothConditionsMustBeMet: return "上記の条件を両方満たすとクイックドロップが発動"
        case .keepPalmInCameraView: return "手のひらをカメラビュー内に保持"
        case .palmMovementShouldBeSmooth: return "手のひらの動きは滑らかに、急な動作を避ける"
        case .keepPalmStableDuringRotation: return "回転中は手のひらを安定させる"
        case .ensureAllFingertipsAreClose: return "指を閉じる時はすべての指先が近づいていることを確認"
        case .practiceGesturesOnTestPage: return "テストページでジェスチャーを練習できます"
        case .gameConfigurationAndPreferences: return "ゲーム設定と設定"
        case .useGestureControl: return "ジェスチャー制御を使用"
        case .viewHighestScoreRecords: return "最高スコア記録を表示"
        case .version: return "バージョン"
        case .interactiveTetrisAR: return "インタラクティブTetrisAR"
        case .futureTechTetris: return "未来のテクノロジーTetris"
        case .gestureInstructionMoveControl: return "ジェスチャー制御指示：移動制御"
        case .gestureInstructionRotationControl: return "ジェスチャー制御指示：回転制御"
        case .gestureInstructionQuickDrop: return "ジェスチャー制御指示：クイックドロップ"
        case .gestureInstructionTips: return "ジェスチャー制御指示：ヒント"
        case .gestureInstructionPalmMovement: return "ジェスチャー制御指示：手掌移動"
        case .gestureInstructionLeftArea: return "ジェスチャー制御指示：左側エリア"
        case .gestureInstructionMiddleArea: return "ジェスチャー制御指示：中央エリア"
        case .gestureInstructionRightArea: return "ジェスチャー制御指示：右側エリア"
        case .gestureInstructionPalmLeftRotation: return "ジェスチャー制御指示：手掌左回転"
        case .gestureInstructionPalmRightRotation: return "ジェスチャー制御指示：手掌右回転"
        case .gestureInstructionPalmHorizontal: return "ジェスチャー制御指示：手掌水平"
        case .gestureInstructionReturnToNormalAngle: return "ジェスチャー制御指示：正常角度に戻る"
        case .gestureInstructionFingerTipsClose: return "ジェスチャー制御指示：手指閉じる"
        case .gestureInstructionPalmPositionMiddle: return "ジェスチャー制御指示：手掌位置中央"
        case .gestureInstructionBothConditions: return "ジェスチャー制御指示：両条件"
        case .gestureInstructionKeepPalmInView: return "ジェスチャー制御指示：手掌を視野内に保持"
        case .gestureInstructionSmoothMovement: return "ジェスチャー制御指示：滑らかな動き"
        case .gestureInstructionStableRotation: return "ジェスチャー制御指示：安定した回転"
        case .gestureInstructionEnsureFingertipsClose: return "ジェスチャー制御指示：手指を閉じる"
        case .gestureInstructionPracticeOnTestPage: return "ジェスチャー制御指示：テストページで練習"
        case .futureTechnologyRussianBlock: return "Future Technology Russian Block"
        case .startGameDescription: return "Use Gesture Control"
        case .settingsDescription: return "遊戲配置與偏好設定"
        case .leaderboardDescription: return "Leaderboard Description"
        case .tutorialDescription: return "Tutorial Description"
        case .finalScore: return "Final Score"
        case .playTime: return "Play Time"
        case .difficulty: return "Difficulty"
        case .playAgain: return "Play Again"
        case .backToMain: return "Back to Main"
        case .scoreSaved: return "Score Saved"
        case .scoreSavedMessage: return "Score Saved Successfully"
        }
    }
    
    var korean: String {
        switch self {
        case .startGame: return "게임 시작"
        case .settings: return "설정"
        case .leaderboard: return "리더보드"
        case .tutorial: return "튜토리얼"
        case .playerName: return "플레이어 이름"
        case .gameDifficulty: return "게임 난이도"
        case .handGestureSettings: return "손 제스처 설정"
        case .audioSettings: return "오디오 설정"
        case .languageSelection: return "언어 선택"
        case .soundEffects: return "효과음"
        case .vibrationFeedback: return "진동 피드백"
        case .backgroundMusic: return "배경음악"
        case .confirm: return "확인"
        case .cancel: return "취소"
        case .save: return "저장"
        case .back: return "뒤로"
        case .score: return "점수"
        case .time: return "시간"
        case .pause: return "일시정지"
        case .resume: return "재개"
        case .gameOver: return "게임 오버"
        case .next: return "다음"
        case .veryEasy: return "매우 쉬움"
        case .easy: return "쉬움"
        case .normal: return "보통"
        case .hard: return "어려움"
        case .veryHard: return "매우 어려움"
        case .extreme: return "극한"
        case .dropInterval: return "낙하 간격"
        case .gestureSensitivity: return "제스처 감도"
        case .handTutorial: return "손 튜토리얼"
        case .moveControl: return "이동 제어"
        case .rotationControl: return "회전 제어"
        case .quickDrop: return "빠른 낙하"
        case .tips: return "팁"
        case .editPlayerName: return "플레이어 이름 편집"
        case .enterPlayerName: return "플레이어 이름 입력"
        case .nameWillShowInLeaderboard: return "플레이어 이름이 리더보드에 표시됩니다"
        case .adjustGameAudioAndFeedback: return "게임 오디오 및 피드백 조정"
        case .blockMovementSoundEffects: return "블록 이동, 제거 등의 효과음"
        case .vibrationPromptForGestures: return "제스처 조작 시 진동 알림"
        case .backgroundMusicDuringGame: return "게임 중 배경음악"
        case .adjustGestureRecognitionParameters: return "제스처 인식 매개변수 조정"
        case .low: return "낮음"
        case .high: return "높음"
        case .pinchDistanceThreshold: return "핀치 거리 임계값"
        case .controlIndexThumbTouchDistance: return "검지와 엄지 접촉 거리 제어"
        case .fistDistanceThreshold: return "주먹 거리 임계값"
        case .controlFistGestureDistance: return "주먹 제스처 거리 제어"
        case .fingerExtensionThreshold: return "손가락 확장 임계값"
        case .controlFingerExtensionRecognition: return "손가락 확장 인식 제어"
        case .gestureChangeCooldown: return "제스처 변경 쿨다운"
        case .preventRapidGestureSwitching: return "빠른 제스처 전환 방지"
        case .minConfidenceThreshold: return "최소 신뢰도 임계값"
        case .minimumConfidenceForGestureRecognition: return "제스처 인식의 최소 신뢰도"
        case .resetToDefaults: return "기본값으로 재설정"
        case .reload: return "다시 로드"
        case .yourScore: return "당신의 점수"
        case .handDetected: return "손이 감지되었습니다"
        case .noGesture: return "제스처 없음"
        case .leftRotation: return "좌회전"
        case .rightRotation: return "우회전"
        case .fingersClosed: return "손가락 접기"
        case .learnGestureControlTechniques: return "제스처 제어 기술 학습"
        case .palmLeftRightMovement: return "손바닥 좌우 이동으로 블록 좌우 이동 제어"
        case .leftArea1To4: return "왼쪽 영역(1-4)：블록을 왼쪽으로 이동"
        case .middleArea5To6: return "중앙 영역(5-6)：블록이 이동하지 않음"
        case .rightArea7To10: return "오른쪽 영역(7-10)：블록을 오른쪽으로 이동"
        case .palmLeftRotationOver40: return "손바닥을 왼쪽으로 회전(40° 이상)：블록을 반시계 방향으로 회전"
        case .palmRightRotationOver40: return "손바닥을 오른쪽으로 회전(40° 이상)：블록을 시계 방향으로 회전"
        case .palmHorizontal40To40: return "손바닥을 수평으로 유지(-40°~40°)：회전 동작 없음"
        case .needToReturnToNormalAngle: return "다시 회전하려면 정상 각도로 돌아가야 합니다"
        case .fingerTipsCloseToCenter: return "손가락 접기：모든 손가락 끝이 중심에서 0.07 미만"
        case .palmPositionMustBeInMiddleArea: return "손바닥 위치：중앙 영역(3-7)에 있어야 합니다"
        case .bothConditionsMustBeMet: return "위 조건을 모두 만족하면 빠른 낙하가 발동됩니다"
        case .keepPalmInCameraView: return "손바닥을 카메라 뷰 내에 유지"
        case .palmMovementShouldBeSmooth: return "손바닥 움직임은 부드럽게, 갑작스러운 동작을 피하세요"
        case .keepPalmStableDuringRotation: return "회전 중에는 손바닥을 안정적으로 유지"
        case .ensureAllFingertipsAreClose: return "손가락을 접을 때는 모든 손가락 끝이 가까이 있는지 확인"
        case .practiceGesturesOnTestPage: return "테스트 페이지에서 제스처를 연습할 수 있습니다"
        case .gameConfigurationAndPreferences: return "게임 설정 및 설정"
        case .useGestureControl: return "손 제스처 제어 사용"
        case .viewHighestScoreRecords: return "최고 점수 기록 보기"
        case .version: return "버전"
        case .interactiveTetrisAR: return "인터랙티브 TetrisAR"
        case .futureTechTetris: return "미래의 기술 Tetris"
        case .gestureInstructionMoveControl: return "손 제스처 제어 지시：이동 제어"
        case .gestureInstructionRotationControl: return "손 제스처 제어 지시：회전 제어"
        case .gestureInstructionQuickDrop: return "손 제스처 제어 지시：빠른 낙하"
        case .gestureInstructionTips: return "손 제스처 제어 지시：팁"
        case .gestureInstructionPalmMovement: return "손 제스처 제어 지시：손바닥 이동"
        case .gestureInstructionLeftArea: return "손 제스처 제어 지시：왼쪽 영역"
        case .gestureInstructionMiddleArea: return "손 제스처 제어 지시：중앙 영역"
        case .gestureInstructionRightArea: return "손 제스처 제어 지시：오른쪽 영역"
        case .gestureInstructionPalmLeftRotation: return "손 제스처 제어 지시：손바닥 좌회전"
        case .gestureInstructionPalmRightRotation: return "손 제스처 제어 지시：손바닥 우회전"
        case .gestureInstructionPalmHorizontal: return "손 제스처 제어 지시：손바닥 수평"
        case .gestureInstructionReturnToNormalAngle: return "손 제스처 제어 지시：정상 각도로 돌아가기"
        case .gestureInstructionFingerTipsClose: return "손 제스처 제어 지시：손가락 접기"
        case .gestureInstructionPalmPositionMiddle: return "손 제스처 제어 지시：손바닥 위치 중앙"
        case .gestureInstructionBothConditions: return "손 제스처 제어 지시：두 조건"
        case .gestureInstructionKeepPalmInView: return "손 제스처 제어 지시：손바닥을 보기 내에 유지"
        case .gestureInstructionSmoothMovement: return "손 제스처 제어 지시：부드러운 움직임"
        case .gestureInstructionStableRotation: return "손 제스처 제어 지시：안정된 회전"
        case .gestureInstructionEnsureFingertipsClose: return "손 제스처 제어 지시：손가락을 접기"
        case .gestureInstructionPracticeOnTestPage: return "손 제스처 제어 지시：테스트 페이지에서 연습"
        case .futureTechnologyRussianBlock: return "Future Technology Russian Block"
        case .startGameDescription: return "Use Gesture Control"
        case .settingsDescription: return "게임 설정 및 설정"
        case .leaderboardDescription: return "최고 점수 기록 보기"
        case .tutorialDescription: return "손 제스처 제어 기술 학습"
        case .finalScore: return "최종 점수"
        case .playTime: return "플레이 시간"
        case .difficulty: return "난이도"
        case .playAgain: return "다시 플레이"
        case .backToMain: return "메인으로 돌아가기"
        case .scoreSaved: return "점수 저장"
        case .scoreSavedMessage: return "점수가 성공적으로 저장되었습니다"
        }
    }
    
    var spanish: String {
        switch self {
        case .startGame: return "Iniciar Juego"
        case .settings: return "Configuración"
        case .leaderboard: return "Clasificación"
        case .tutorial: return "Tutorial"
        case .playerName: return "Nombre del Jugador"
        case .gameDifficulty: return "Dificultad del Juego"
        case .handGestureSettings: return "Configuración de Gestos"
        case .audioSettings: return "Configuración de Audio"
        case .languageSelection: return "Selección de Idioma"
        case .soundEffects: return "Efectos de Sonido"
        case .vibrationFeedback: return "Retroalimentación Táctil"
        case .backgroundMusic: return "Música de Fondo"
        case .confirm: return "Confirmar"
        case .cancel: return "Cancelar"
        case .save: return "Guardar"
        case .back: return "Atrás"
        case .score: return "Puntuación"
        case .time: return "Tiempo"
        case .pause: return "Pausar"
        case .resume: return "Reanudar"
        case .gameOver: return "Fin del Juego"
        case .next: return "Siguiente"
        case .veryEasy: return "Muy Fácil"
        case .easy: return "Fácil"
        case .normal: return "Normal"
        case .hard: return "Difícil"
        case .veryHard: return "Muy Difícil"
        case .extreme: return "Extremo"
        case .dropInterval: return "Intervalo de Caída"
        case .gestureSensitivity: return "Sensibilidad de Gestos"
        case .handTutorial: return "Tutorial de Manos"
        case .moveControl: return "Control de Movimiento"
        case .rotationControl: return "Control de Rotación"
        case .quickDrop: return "Caída Rápida"
        case .tips: return "Consejos"
        case .editPlayerName: return "Editar Nombre del Jugador"
        case .enterPlayerName: return "Ingresar Nombre del Jugador"
        case .nameWillShowInLeaderboard: return "El Nombre Aparecerá en la Clasificación"
        case .adjustGameAudioAndFeedback: return "Ajustar Audio y Retroalimentación del Juego"
        case .blockMovementSoundEffects: return "Efectos Sonores de Mouvement de Blocs"
        case .vibrationPromptForGestures: return "Aviso de Vibración para Gestos"
        case .backgroundMusicDuringGame: return "Música de Fond Durante el Juego"
        case .adjustGestureRecognitionParameters: return "Ajustar Parámetros de Reconocimiento de Gestos"
        case .low: return "Bajo"
        case .high: return "Alto"
        case .pinchDistanceThreshold: return "Umbral de Distancia de Pellizco"
        case .controlIndexThumbTouchDistance: return "Contrôler la Distance de Contact Index-Pulgar"
        case .fistDistanceThreshold: return "Umbral de Distancia de Poing"
        case .controlFistGestureDistance: return "Contrôler la Distance de Geste de Poing"
        case .fingerExtensionThreshold: return "Umbral de Extensión de Dedos"
        case .controlFingerExtensionRecognition: return "Contrôler la Reconnaissance d'Extension de Dedos"
        case .gestureChangeCooldown: return "Tiempo de Espera de Cambio de Gestos"
        case .preventRapidGestureSwitching: return "Prevenir Cambio Rápido de Gestes"
        case .minConfidenceThreshold: return "Umbral Mínimo de Confianza"
        case .minimumConfidenceForGestureRecognition: return "Confianza Mínima para Reconocimiento de Gestos"
        case .resetToDefaults: return "Restablecer a Valores Predeterminados"
        case .reload: return "Recargar"
        case .yourScore: return "Tu Puntuación"
        case .handDetected: return "Mano Detectada"
        case .noGesture: return "Sin Gesto"
        case .leftRotation: return "Rotation Gauche"
        case .rightRotation: return "Rotation Droite"
        case .fingersClosed: return "Dedos Cerrados"
        case .learnGestureControlTechniques: return "Aprender Técnicas de Contrôle par Gestes"
        case .palmLeftRightMovement: return "Mouvement de Palma Izquierda-Derecha Controla Movimiento de Bloques"
        case .leftArea1To4: return "Zone Gauche(1-4)：Bloc Se Déplace Vers la Gauche"
        case .middleArea5To6: return "Zone Centrale(5-6)：Bloc Ne Se Déplace Pas"
        case .rightArea7To10: return "Zone Droite(7-10)：Bloc Se Déplace Vers la Droite"
        case .palmLeftRotationOver40: return "Rotation de Palma Vers la Gauche(sur 40°)：Bloc Tourne dans le Sens Inverse des Aiguilles"
        case .palmRightRotationOver40: return "Rotation de Palma Vers la Droite(sur 40°)：Bloc Tourne dans le Sens des Aiguilles"
        case .palmHorizontal40To40: return "Paume Maintient Horizontale(-40°~40°)：Aucune Action de Rotation"
        case .needToReturnToNormalAngle: return "Doit Retourner à l'Angle Normal pour Tourner à Nouveau"
        case .fingerTipsCloseToCenter: return "Dedos Cerrados：Toutes les Pointes de Dedos a Menos de 0.07 du Centre"
        case .palmPositionMustBeInMiddleArea: return "Position de Paume：Doit Être dans la Zone Centrale(3-7)"
        case .bothConditionsMustBeMet: return "Les Deux Conditions Doivent Être Remplies pour Activer la Chute Rapide"
        case .keepPalmInCameraView: return "Maintenir la Paume dans la Vue de la Caméra"
        case .palmMovementShouldBeSmooth: return "Le Mouvement de Paume Doit Être Fluide, Éviter les Mouvements Brusques"
        case .keepPalmStableDuringRotation: return "Maintenir la Paume Stable Pendant la Rotation"
        case .ensureAllFingertipsAreClose: return "En Fermant les Doigts, S'assurer que Toutes les Pointes Sont Proches"
        case .practiceGesturesOnTestPage: return "Peut Pratiquer les Gestes sur la Page de Test"
        case .gameConfigurationAndPreferences: return "Configuration du Jeu et Préférences"
        case .useGestureControl: return "Utiliser le Contrôle par Gestes"
        case .viewHighestScoreRecords: return "Voir les Records de Meilleur Score"
        case .version: return "Version"
        case .interactiveTetrisAR: return "Interactive TetrisAR"
        case .futureTechTetris: return "Future Tech Tetris"
        case .gestureInstructionMoveControl: return "Instruction de Contrôle par Gestes：Contrôle de Mouvement"
        case .gestureInstructionRotationControl: return "Instruction de Contrôle par Gestes：Contrôle de Rotation"
        case .gestureInstructionQuickDrop: return "Instruction de Contrôle par Gestes：Chute Rapide"
        case .gestureInstructionTips: return "Instruction de Contrôle par Gestes：Conseils"
        case .gestureInstructionPalmMovement: return "Instruction de Contrôle par Gestes：Mouvement de Palma"
        case .gestureInstructionLeftArea: return "Instruction de Contrôle par Gestes：Zone Gauche"
        case .gestureInstructionMiddleArea: return "Instruction de Contrôle par Gestes：Zone Centrale"
        case .gestureInstructionRightArea: return "Instruction de Contrôle par Gestes：Zone Droite"
        case .gestureInstructionPalmLeftRotation: return "Instruction de Contrôle par Gestes：Rotation de Palma à la Gauche"
        case .gestureInstructionPalmRightRotation: return "Instruction de Contrôle par Gestes：Rotation de Palma à la Droite"
        case .gestureInstructionPalmHorizontal: return "Instruction de Contrôle par Gestes：Palma Horizontal"
        case .gestureInstructionReturnToNormalAngle: return "Instruction de Contrôle par Gestes：Retourner à l'Angle Normal"
        case .gestureInstructionFingerTipsClose: return "Instruction de Contrôle par Gestes：Dedos Cerrados"
        case .gestureInstructionPalmPositionMiddle: return "Instruction de Contrôle par Gestes：Position de Paume au Milieu"
        case .gestureInstructionBothConditions: return "Instruction de Contrôle par Gestes：Les Deux Conditions"
        case .gestureInstructionKeepPalmInView: return "Instruction de Contrôle par Gestes：Maintenir la Paume dans la Vue"
        case .gestureInstructionSmoothMovement: return "Instruction de Contrôle par Gestes：Mouvement Fluide"
        case .gestureInstructionStableRotation: return "Instruction de Contrôle par Gestes：Rotation Stable"
        case .gestureInstructionEnsureFingertipsClose: return "Instruction de Contrôle par Gestes：S'assurer que les Doigts sont Proches"
        case .gestureInstructionPracticeOnTestPage: return "Instruction de Contrôle par Gestes：Pratiquer sur la Page de Test"
        case .futureTechnologyRussianBlock: return "Future Technology Russian Block"
        case .startGameDescription: return "Use Gesture Control"
        case .settingsDescription: return "Configuration du Jeu et Préférences"
        case .leaderboardDescription: return "Voir les Records de Meilleur Score"
        case .tutorialDescription: return "Aprender Técnicas de Contrôle par Gestes"
        case .finalScore: return "Final Score"
        case .playTime: return "Play Time"
        case .difficulty: return "Difficulty"
        case .playAgain: return "Play Again"
        case .backToMain: return "Back to Main"
        case .scoreSaved: return "Score Saved"
        case .scoreSavedMessage: return "Score Saved Successfully"
        }
    }
    
    var french: String {
        switch self {
        case .startGame: return "Commencer le Jeu"
        case .settings: return "Paramètres"
        case .leaderboard: return "Classement"
        case .tutorial: return "Tutoriel"
        case .playerName: return "Nom du Joueur"
        case .gameDifficulty: return "Difficulté du Jeu"
        case .handGestureSettings: return "Paramètres de Gestes"
        case .audioSettings: return "Paramètres Audio"
        case .languageSelection: return "Sélection de Langue"
        case .soundEffects: return "Effets Sonores"
        case .vibrationFeedback: return "Retour Haptique"
        case .backgroundMusic: return "Musique de Fond"
        case .confirm: return "Confirmer"
        case .cancel: return "Annuler"
        case .save: return "Sauvegarder"
        case .back: return "Retour"
        case .score: return "Score"
        case .time: return "Temps"
        case .pause: return "Pause"
        case .resume: return "Reprendre"
        case .gameOver: return "Fin de Partie"
        case .next: return "Suivant"
        case .veryEasy: return "Très Facile"
        case .easy: return "Facile"
        case .normal: return "Normal"
        case .hard: return "Difficile"
        case .veryHard: return "Très Difficile"
        case .extreme: return "Extrême"
        case .dropInterval: return "Intervalle de Chute"
        case .gestureSensitivity: return "Sensibilité des Gestes"
        case .handTutorial: return "Tutoriel des Mains"
        case .moveControl: return "Contrôle de Mouvement"
        case .rotationControl: return "Contrôle de Rotation"
        case .quickDrop: return "Chute Rapide"
        case .tips: return "Conseils"
        case .editPlayerName: return "Modifier le Nom du Joueur"
        case .enterPlayerName: return "Entrer le Nom du Joueur"
        case .nameWillShowInLeaderboard: return "Le Nom Sera Affiché dans le Classement"
        case .adjustGameAudioAndFeedback: return "Ajuster l'Audio et la Rétroaction du Jeu"
        case .blockMovementSoundEffects: return "Effets Sonores de Mouvement de Blocs"
        case .vibrationPromptForGestures: return "Invite de Vibration pour les Gestes"
        case .backgroundMusicDuringGame: return "Musique de Fond Pendant le Jeu"
        case .adjustGestureRecognitionParameters: return "Ajuster les Paramètres de Reconnaissance de Gestes"
        case .low: return "Faible"
        case .high: return "Élevé"
        case .pinchDistanceThreshold: return "Seuil de Distance de Pincement"
        case .controlIndexThumbTouchDistance: return "Contrôler la Distance de Contact Index-Pouce"
        case .fistDistanceThreshold: return "Seuil de Distance de Poing"
        case .controlFistGestureDistance: return "Contrôler la Distance de Geste de Poing"
        case .fingerExtensionThreshold: return "Seuil d'Extension des Doigts"
        case .controlFingerExtensionRecognition: return "Contrôler la Reconnaissance d'Extension des Doigts"
        case .gestureChangeCooldown: return "Temps de Refroidissement de Changement de Geste"
        case .preventRapidGestureSwitching: return "Empêcher le Changement Rapide de Gestes"
        case .minConfidenceThreshold: return "Seuil de Confiance Minimum"
        case .minimumConfidenceForGestureRecognition: return "Confiance Minimum pour la Reconnaissance de Gestes"
        case .resetToDefaults: return "Réinitialiser aux Valeurs par Défaut"
        case .reload: return "Recharger"
        case .yourScore: return "Votre Score"
        case .handDetected: return "Main Détectée"
        case .noGesture: return "Aucun Geste"
        case .leftRotation: return "Rotation Gauche"
        case .rightRotation: return "Rotation Droite"
        case .fingersClosed: return "Doigts Fermés"
        case .learnGestureControlTechniques: return "Apprendre les Techniques de Contrôle par Gestes"
        case .palmLeftRightMovement: return "Mouvement de Paume Gauche-Droite Contrôle le Mouvement des Blocs"
        case .leftArea1To4: return "Zone Gauche(1-4)：Bloc Se Déplace Vers la Gauche"
        case .middleArea5To6: return "Zone Centrale(5-6)：Bloc Ne Se Déplace Pas"
        case .rightArea7To10: return "Zone Droite(7-10)：Bloc Se Déplace Vers la Droite"
        case .palmLeftRotationOver40: return "Rotation de Paume Vers la Gauche(sur 40°)：Bloc Tourne dans le Sens Inverse des Aiguilles"
        case .palmRightRotationOver40: return "Rotation de Paume Vers la Droite(sur 40°)：Bloc Tourne dans le Sens des Aiguilles"
        case .palmHorizontal40To40: return "Paume Maintient Horizontale(-40°~40°)：Aucune Action de Rotation"
        case .needToReturnToNormalAngle: return "Doit Retourner à l'Angle Normal pour Tourner à Nouveau"
        case .fingerTipsCloseToCenter: return "Doigts Fermés：Toutes les Pointes de Doigts a Menos de 0.07 du Centre"
        case .palmPositionMustBeInMiddleArea: return "Position de Paume：Doit Être dans la Zone Centrale(3-7)"
        case .bothConditionsMustBeMet: return "Les Deux Conditions Doivent Être Remplies pour Activer la Chute Rapide"
        case .keepPalmInCameraView: return "Maintenir la Paume dans la Vue de la Caméra"
        case .palmMovementShouldBeSmooth: return "Le Mouvement de Paume Doit Être Fluide, Éviter les Mouvements Brusques"
        case .keepPalmStableDuringRotation: return "Maintenir la Paume Stable Pendant la Rotation"
        case .ensureAllFingertipsAreClose: return "En Fermant les Doigts, S'assurer que Toutes les Pointes Sont Proches"
        case .practiceGesturesOnTestPage: return "Peut Pratiquer les Gestes sur la Page de Test"
        case .gameConfigurationAndPreferences: return "Configuration du Jeu et Préférences"
        case .useGestureControl: return "Utiliser le Contrôle par Gestes"
        case .viewHighestScoreRecords: return "Voir les Records de Meilleur Score"
        case .version: return "Version"
        case .interactiveTetrisAR: return "Interactive TetrisAR"
        case .futureTechTetris: return "Future Tech Tetris"
        case .gestureInstructionMoveControl: return "Instruction de Contrôle par Gestes：Contrôle de Mouvement"
        case .gestureInstructionRotationControl: return "Instruction de Contrôle par Gestes：Contrôle de Rotation"
        case .gestureInstructionQuickDrop: return "Instruction de Contrôle par Gestes：Chute Rapide"
        case .gestureInstructionTips: return "Instruction de Contrôle par Gestes：Conseils"
        case .gestureInstructionPalmMovement: return "Instruction de Contrôle par Gestes：Mouvement de Palma"
        case .gestureInstructionLeftArea: return "Instruction de Contrôle par Gestes：Zone Gauche"
        case .gestureInstructionMiddleArea: return "Instruction de Contrôle par Gestes：Zone Centrale"
        case .gestureInstructionRightArea: return "Instruction de Contrôle par Gestes：Zone Droite"
        case .gestureInstructionPalmLeftRotation: return "Instruction de Contrôle par Gestes：Rotation de Palma à la Gauche"
        case .gestureInstructionPalmRightRotation: return "Instruction de Contrôle par Gestes：Rotation de Palma à la Droite"
        case .gestureInstructionPalmHorizontal: return "Instruction de Contrôle par Gestes：Palma Horizontal"
        case .gestureInstructionReturnToNormalAngle: return "Instruction de Contrôle par Gestes：Retourner à l'Angle Normal"
        case .gestureInstructionFingerTipsClose: return "Instruction de Contrôle par Gestes：Dedos Cerrados"
        case .gestureInstructionPalmPositionMiddle: return "Instruction de Contrôle par Gestes：Position de Paume au Milieu"
        case .gestureInstructionBothConditions: return "Instruction de Contrôle par Gestes：Les Deux Conditions"
        case .gestureInstructionKeepPalmInView: return "Instruction de Contrôle par Gestes：Maintenir la Paume dans la Vue"
        case .gestureInstructionSmoothMovement: return "Instruction de Contrôle par Gestes：Mouvement Fluide"
        case .gestureInstructionStableRotation: return "Instruction de Contrôle par Gestes：Rotation Stable"
        case .gestureInstructionEnsureFingertipsClose: return "Instruction de Contrôle par Gestes：S'assurer que les Doigts sont Proches"
        case .gestureInstructionPracticeOnTestPage: return "Instruction de Contrôle par Gestes：Pratiquer sur la Page de Test"
        case .futureTechnologyRussianBlock: return "Future Technology Russian Block"
        case .startGameDescription: return "Use Gesture Control"
        case .settingsDescription: return "Configuration du Jeu et Préférences"
        case .leaderboardDescription: return "Voir les Records de Meilleur Score"
        case .tutorialDescription: return "Apprendre les Techniques de Contrôle par Gestes"
        case .finalScore: return "Final Score"
        case .playTime: return "Play Time"
        case .difficulty: return "Difficulty"
        case .playAgain: return "Play Again"
        case .backToMain: return "Back to Main"
        case .scoreSaved: return "Score Saved"
        case .scoreSavedMessage: return "Score Saved Successfully"
        }
    }
} 