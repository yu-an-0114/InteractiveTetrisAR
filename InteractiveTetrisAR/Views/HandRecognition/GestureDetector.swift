//
//  GestureDetector.swift
//  InteractiveTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation
import Vision
import UIKit

// MARK: - 手勢檢測器
class GestureDetector: ObservableObject {
    
    // MARK: - 屬性
    enum GestureType: String {
        case none = "無手勢"
        case rotateLeft = "左旋轉"
        case rotateRight = "右旋轉"
        case fingersClosed = "手指併攏"
    }
    
    @Published var currentGesture: GestureType = .none
    @Published var palmXPosition: Int = 5 // 手掌X軸位置 (1-10)
    @Published var palmZRotation: Float = 0.0 // 手掌Z軸旋轉角度 (-180到180度)
    
    // 添加手掌位置歷史記錄用於平滑
    private var palmXHistory: [CGFloat] = []
    private let maxPalmHistorySize = 5
    
    // 防彈跳機制
    private var gestureHistory: [GestureType] = []
    private let maxGestureHistorySize = 5
    private var gestureConfidence: [GestureType: Int] = [:]
    private var lastGestureChangeTime: TimeInterval = 0
    private let gestureChangeCooldown: TimeInterval = 0.5 // 減少手勢切換冷卻時間
    private let minConfidenceThreshold = 3 // 降低最小置信度閾值
    
    // 手勢檢測參數
    private let rotationThreshold: Float = 40.0 // 設置旋轉角度閾值為45度
    private let rotationCooldown: TimeInterval = 0.1 // 降低旋轉冷卻時間
    private var lastRotationTime: TimeInterval = 0
    
    // 手指併攏檢測參數
    private let fingerCloseThreshold: CGFloat = 0.07 // 降低手指併攏距離閾值，使其更難觸發
    private let fingerCloseCooldown: TimeInterval = 0.3 // 手指併攏冷卻時間
    private var lastFingerCloseTime: TimeInterval = 0
    private var fingerCloseState: FingerCloseState = .open
    
    // 添加旋轉狀態跟踪
    private var rotationState: RotationState = .normal
    private var lastRotationDirection: GestureType = .none
    
    // 手指併攏狀態枚舉
    private enum FingerCloseState {
        case open      // 手指張開
        case closed    // 手指併攏
    }
    
    // 旋轉狀態枚舉
    private enum RotationState {
        case normal      // 正常狀態，可以觸發旋轉
        case triggered   // 已觸發旋轉，需要等待恢復
    }
    
    // MARK: - 主要檢測函數
    func detectGestures(points: [VNHumanHandPoseObservation.JointName: CGPoint]) {
        // 檢測手掌X軸位置
        detectPalmXPosition(points: points)
        
        // 檢測手掌Z軸旋轉角度
        detectPalmZRotation(points: points)
        
        // 檢測手指併攏
        detectFingersClosed(points: points)
        
        // 檢測當前手勢
        let detectedGesture = detectCurrentGesture(points: points)
        
        // 直接更新手勢，跳過防彈跳機制
        if detectedGesture != .none {
            updateGesture(detectedGesture)
        } else {
            // 只有無手勢時才使用防彈跳機制
            updateGestureHistory(detectedGesture)
            let finalGesture = applyDebouncingLogic()
            updateGesture(finalGesture)
        }
    }
    
    // MARK: - 手勢檢測邏輯
    private func detectCurrentGesture(points: [VNHumanHandPoseObservation.JointName: CGPoint]) -> GestureType {
        let currentTime = CACurrentMediaTime()
        
        // 檢查旋轉冷卻時間
        if currentTime - lastRotationTime < rotationCooldown {
            //print("⏰ 旋轉冷卻中，剩餘時間: \(rotationCooldown - (currentTime - lastRotationTime))秒")
            return .none
        }
        
        // 檢查是否需要恢復到正常狀態
        if rotationState == .triggered {
            // 如果角度回到正常範圍（小於閾值），重置狀態
            if abs(palmZRotation) < rotationThreshold {
                rotationState = .normal
                //print("🔄 旋轉狀態重置為正常，角度: \(palmZRotation)°")
            } else {
                // 仍在觸發狀態，不允許新的旋轉
                //print("⏳ 等待恢復正常角度，當前角度: \(palmZRotation)°")
                return .none
            }
        }
        
        // 檢測手指併攏手勢
        if fingerCloseState == .closed && palmXPosition >= 3 && palmXPosition <= 7 {
            //print("🤏 檢測到手指併攏手勢: X位置=\(palmXPosition)")
            return .fingersClosed
        }
        
        // 根據手掌Z軸旋轉角度判斷旋轉方向（45度閾值）
        if palmZRotation > rotationThreshold && rotationState == .normal {
            lastRotationTime = currentTime
            rotationState = .triggered
            lastRotationDirection = .rotateRight
            print("🔄 檢測到右旋轉手勢: 角度=\(palmZRotation)°, 閾值=\(rotationThreshold)°")
            return .rotateRight
        } else if palmZRotation < -rotationThreshold && rotationState == .normal {
            lastRotationTime = currentTime
            rotationState = .triggered
            lastRotationDirection = .rotateLeft
            print("🔄 檢測到左旋轉手勢: 角度=\(palmZRotation)°, 閾值=\(rotationThreshold)°")
            return .rotateLeft
        }
        
        // 無手勢
        return .none
    }
    
    // MARK: - 防彈跳機制
    private func updateGestureHistory(_ gesture: GestureType) {
        // 添加當前檢測到的手勢到歷史記錄
        gestureHistory.append(gesture)
        if gestureHistory.count > maxGestureHistorySize {
            gestureHistory.removeFirst()
        }
        
        // 更新置信度
        gestureConfidence.removeAll()
        for g in [GestureType.none, .rotateLeft, .rotateRight, .fingersClosed] {
            let count = gestureHistory.filter { $0 == g }.count
            gestureConfidence[g] = count
        }
    }
    
    private func applyDebouncingLogic() -> GestureType {
        let currentTime = CACurrentMediaTime()
        
        // 找到置信度最高的手勢
        let mostConfidentGesture = gestureConfidence.max { $0.value < $1.value }?.key ?? .none
        let confidence = gestureConfidence[mostConfidentGesture] ?? 0
        
        // 特殊處理旋轉手勢 - 立即生效，不檢查冷卻時間
        if mostConfidentGesture == .rotateLeft || mostConfidentGesture == .rotateRight {
            if confidence >= 1 && mostConfidentGesture != currentGesture { // 進一步降低旋轉手勢的置信度要求
                lastGestureChangeTime = currentTime
                print("🔄 立即確認旋轉手勢: \(mostConfidentGesture.rawValue), 置信度: \(confidence)")
                return mostConfidentGesture
            }
        } else {
            // 非旋轉手勢的常規處理
            // 檢查冷卻時間
            if currentTime - lastGestureChangeTime < gestureChangeCooldown {
                return currentGesture
            }
            
            if confidence >= minConfidenceThreshold && mostConfidentGesture != currentGesture {
                lastGestureChangeTime = currentTime
                return mostConfidentGesture
            }
        }
        
        // 如果當前手勢的置信度仍然足夠，保持當前手勢
        let currentConfidence = gestureConfidence[currentGesture] ?? 0
        if currentConfidence >= minConfidenceThreshold {
            return currentGesture
        }
        
        // 如果沒有足夠置信度的手勢，返回無手勢
        return .none
    }
    
    // MARK: - 手掌X軸位置檢測（改進版）
    private func detectPalmXPosition(points: [VNHumanHandPoseObservation.JointName: CGPoint]) {
        // 更靈活的關節點檢查，只需要基本的MCP關節點
        let requiredPoints: [VNHumanHandPoseObservation.JointName] = [.indexMCP, .middleMCP, .ringMCP, .littleMCP]
        let availablePoints = requiredPoints.compactMap { points[$0] }
        
        guard availablePoints.count >= 3 else {
            // 如果缺少太多關節點，跳過X軸位置檢測
            return
        }
        
        // 使用可用的關節點計算手掌中心
        let palmCenter = CGPoint(
            x: availablePoints.map { $0.x }.reduce(0, +) / CGFloat(availablePoints.count),
            y: availablePoints.map { $0.y }.reduce(0, +) / CGFloat(availablePoints.count)
        )
        
        // 將X軸位置映射到1-10，偏向中間位置
        let rawXPosition = palmCenter.x * 10
        // 調整映射範圍，讓中間位置更寬
        let adjustedPosition = max(0.5, min(9.5, rawXPosition))
        let clampedPosition = max(1, min(10, Int(round(adjustedPosition))))
        
        // 添加歷史記錄用於平滑
        palmXHistory.append(rawXPosition)
        if palmXHistory.count > maxPalmHistorySize {
            palmXHistory.removeFirst()
        }
        
        // 計算平滑後的位置
        let smoothedPosition = palmXHistory.reduce(0, +) / CGFloat(palmXHistory.count)
        let finalPosition = max(1, min(10, Int(round(smoothedPosition))))
        
        // 實時更新，移除閾值限制以提高響應性
        DispatchQueue.main.async {
            if self.palmXPosition != finalPosition {
                //print("📍 X軸位置更新: \(self.palmXPosition) -> \(finalPosition)")
                self.palmXPosition = finalPosition
            }
        }
    }
    
    // MARK: - 手掌Z軸旋轉角度檢測
    private func detectPalmZRotation(points: [VNHumanHandPoseObservation.JointName: CGPoint]) {
        // 使用手腕和MCP關節點計算手掌方向
        guard let wrist = points[.wrist] else { 
            //print("❌ 缺少手腕關節點")
            return
        }
        
        let mcpPoints = [.indexMCP, .middleMCP, .ringMCP, .littleMCP].compactMap { points[$0] }
        guard mcpPoints.count >= 3 else { 
            //print("❌ 缺少MCP關節點，只有 \(mcpPoints.count) 個")
            return
        }
        
        // 計算手掌中心
        let palmCenter = CGPoint(
            x: mcpPoints.map { $0.x }.reduce(0, +) / CGFloat(mcpPoints.count),
            y: mcpPoints.map { $0.y }.reduce(0, +) / CGFloat(mcpPoints.count)
        )
        
        // 計算手掌方向向量（從手腕到手掌中心）
        let directionVector = CGPoint(
            x: palmCenter.x - wrist.x,
            y: palmCenter.y - wrist.y
        )
        
        // 計算旋轉角度（相對於水平向右方向，順時針為正）
        // 使用 atan2(y, x) 來計算角度，然後調整基準
        let angleInRadians = atan2(directionVector.y, directionVector.x)
        let angleInDegrees = Float(angleInRadians * 180 / CGFloat.pi)
        
        // 調整基準，讓手掌正面朝前時角度接近0度
        let adjustedAngle = angleInDegrees - 90 // 減去90度來調整基準
        
        // 將角度範圍調整為 -180 到 180 度
        let normalizedAngle = adjustedAngle > 180 ? adjustedAngle - 360 : (adjustedAngle < -180 ? adjustedAngle + 360 : adjustedAngle)
        
        // 更新旋轉角度
        DispatchQueue.main.async {
            if abs(self.palmZRotation - normalizedAngle) > 1.0 { // 只在角度變化超過1度時更新
                //print("🔄 Z軸旋轉角度更新: \(self.palmZRotation)° -> \(normalizedAngle)°")
               // print("📍 方向向量: (\(directionVector.x), \(directionVector.y))")
               // print("📍 角度計算: atan2(\(directionVector.y), \(directionVector.x)) = \(angleInRadians) rad = \(angleInDegrees)°")
                //print("📍 調整後角度: \(adjustedAngle)° -> 標準化: \(normalizedAngle)°")
                self.palmZRotation = normalizedAngle
            }
        }
    }
    
    // MARK: - 手指併攏檢測
    private func detectFingersClosed(points: [VNHumanHandPoseObservation.JointName: CGPoint]) {
        let currentTime = CACurrentMediaTime()
        
        // 檢查冷卻時間
        if currentTime - lastFingerCloseTime < fingerCloseCooldown {
            return
        }
        
        // 獲取所有手指的指尖點
        let fingerTips: [VNHumanHandPoseObservation.JointName] = [
            .indexTip, .middleTip, .ringTip, .littleTip
        ]
        
        // 檢查是否有足夠的指尖點
        let availableTips = fingerTips.compactMap { points[$0] }
        guard availableTips.count >= 3 else {
            //print("❌ 缺少指尖點，只有 \(availableTips.count) 個")
            return
        }
        
        // 計算所有指尖點的中心
        let centerX = availableTips.map { $0.x }.reduce(0, +) / CGFloat(availableTips.count)
        let centerY = availableTips.map { $0.y }.reduce(0, +) / CGFloat(availableTips.count)
        let centerPoint = CGPoint(x: centerX, y: centerY)
        
        // 計算每個指尖點到中心的距離
        var maxDistance: CGFloat = 0
        for tip in availableTips {
            let distance = sqrt(pow(tip.x - centerX, 2) + pow(tip.y - centerY, 2))
            maxDistance = max(maxDistance, distance)
        }
        
        // 判斷是否併攏（所有指尖點距離中心都很近）
        let isClosed = maxDistance < fingerCloseThreshold
        
        // 更新狀態
        if isClosed && fingerCloseState == .open {
            fingerCloseState = .closed
            lastFingerCloseTime = currentTime
            //print("🤏 檢測到手指併攏: 最大距離=\(maxDistance), 閾值=\(fingerCloseThreshold)")
        } else if !isClosed && fingerCloseState == .closed {
            fingerCloseState = .open
            //print("✋ 手指張開: 最大距離=\(maxDistance), 閾值=\(fingerCloseThreshold)")
        }
    }
    
    // MARK: - 公共方法
    
    // 獲取手勢描述
    func getGestureDescription() -> String {
        return currentGesture.rawValue
    }
    
    // 重置所有手勢
    func resetAllGestures() {
        DispatchQueue.main.async {
            self.currentGesture = .none
        }
        palmXHistory.removeAll()
        gestureHistory.removeAll()
        gestureConfidence.removeAll()
        lastGestureChangeTime = 0
        lastRotationTime = 0
        
        // 重置旋轉狀態
        rotationState = .normal
        lastRotationDirection = .none
        
        // 重置手指併攏狀態
        fingerCloseState = .open
        lastFingerCloseTime = 0
    }
    
    // MARK: - 參數調整方法
    
    // 調整旋轉角度閾值
    func setRotationThreshold(_ threshold: Float) {
        // 在運行時動態調整參數
    }
    
    // 調整旋轉冷卻時間
    func setRotationCooldown(_ cooldown: TimeInterval) {
        // 在運行時動態調整參數
    }
    
    // 調整手勢切換冷卻時間
    func setGestureChangeCooldown(_ cooldown: TimeInterval) {
        // 在運行時動態調整參數
    }
    
    // 調整最小置信度閾值
    func setMinConfidenceThreshold(_ threshold: Int) {
        // 在運行時動態調整參數
    }
    
    // 獲取當前檢測狀態（用於調試）
    func getDetectionStatus() -> [String: Any] {
        return [
            "currentGesture": currentGesture.rawValue,
            "gestureHistory": gestureHistory.map { $0.rawValue },
            "gestureConfidence": gestureConfidence.mapValues { $0 },
            "palmXPosition": palmXPosition,
            "palmZRotation": palmZRotation,
            "lastGestureChangeTime": lastGestureChangeTime,
            "lastRotationTime": lastRotationTime,
            "timeSinceLastChange": CACurrentMediaTime() - lastGestureChangeTime,
            "rotationState": rotationState == .normal ? "normal" : "triggered",
            "lastRotationDirection": lastRotationDirection.rawValue,
            "fingerCloseState": fingerCloseState == .open ? "open" : "closed",
            "lastFingerCloseTime": lastFingerCloseTime
        ]
    }
    
    private func updateGesture(_ gesture: GestureType) {
        if currentGesture != gesture {
            //print("🔄 手勢更新: \(currentGesture.rawValue) -> \(gesture.rawValue)")
            DispatchQueue.main.async {
                self.currentGesture = gesture
            }
        }
    }
} 
