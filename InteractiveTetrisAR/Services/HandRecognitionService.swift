//
//  HandRecognitionService.swift
//  InteractiveTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation
import Vision
import ARKit
import Combine

/// AR 環境中的手部識別服務
class HandRecognitionService: NSObject, ObservableObject {
    
    // MARK: - Published 屬性
    @Published var currentGesture: GestureDetector.GestureType = .none
    @Published var palmXPosition: Int = 5
    @Published var isHandDetected: Bool = false
    @Published var detectionConfidence: Float = 0.0
    @Published var debugInfo: String = ""
    
    // MARK: - 公共屬性
    var gestureDetector: GestureDetector {
        return _gestureDetector
    }
    
    var palmZRotation: Float {
        return _gestureDetector.palmZRotation
    }
    
    // MARK: - 私有屬性
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private var _gestureDetector = GestureDetector()
    private var processingQueue = DispatchQueue(label: "handRecognitionQueue", qos: .userInteractive)
    private var isProcessing = false
    private var currentHandPoints: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
    
    // 手部識別參數
    private let minConfidenceThreshold: Float = 0.5 // 降低置信度閾值
    private let smoothingFactor: Float = 0.7 // 平滑因子
    private var previousPalmXPosition: Float = 5.0
    
    // MARK: - 初始化
    override init() {
        super.init()
        handPoseRequest.maximumHandCount = 1
        setupGestureDetector()
    }
    
    // MARK: - 設置
    private func setupGestureDetector() {
        // 監聽手勢檢測器的變化
        _gestureDetector.$currentGesture
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentGesture, on: self)
            .store(in: &cancellables)
        
        _gestureDetector.$palmXPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPosition in
                self?.updatePalmPosition(newPosition)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 點位旋轉處理
    private func rotatePoints90Degrees(_ points: [VNHumanHandPoseObservation.JointName: CGPoint]) -> [VNHumanHandPoseObservation.JointName: CGPoint] {
        points.mapValues { point in
            CGPoint(x: point.y, y: 1 - point.x)
        }
    }
    
    // MARK: - 手掌位置平滑處理
    private func updatePalmPosition(_ newPosition: Int) {
        let newPositionFloat = Float(newPosition)
        let smoothedPosition = previousPalmXPosition * (1 - smoothingFactor) + newPositionFloat * smoothingFactor
        previousPalmXPosition = smoothedPosition
        
        let finalPosition = Int(round(smoothedPosition))
        
        // 只在位置真正改變時才更新，避免不必要的狀態變化
        DispatchQueue.main.async {
            if self.palmXPosition != finalPosition {
                //print("📍 X軸位置更新: \(self.palmXPosition) -> \(finalPosition)")
                self.palmXPosition = finalPosition
            }
        }
    }
    
    // MARK: - 手部識別處理
    func processFrame(_ frame: ARFrame) {
        guard !isProcessing else { return }
        isProcessing = true
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            let pixelBuffer = frame.capturedImage
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
            
            do {
                try handler.perform([self.handPoseRequest])
                
                if let observation = self.handPoseRequest.results?.first {
                    let recognizedPoints = try observation.recognizedPoints(.all)
                    
                    // 計算平均置信度
                    let confidences = recognizedPoints.values.map { $0.confidence }
                    let avgConfidence = confidences.reduce(0, +) / Float(confidences.count)
                    
                    // 使用更低的置信度閾值
                    let imagePoints = recognizedPoints.compactMapValues { $0.confidence > self.minConfidenceThreshold ? $0.location : nil }
                    
                    // 應用 90 度旋轉
                    let rotatedPoints = self.rotatePoints90Degrees(imagePoints)
                    
                    DispatchQueue.main.async {
                        self.isHandDetected = true
                        self.detectionConfidence = avgConfidence
                        self.currentHandPoints = rotatedPoints
                        self.debugInfo = "檢測到 \(rotatedPoints.count) 個關節點，平均置信度: \(String(format: "%.2f", avgConfidence))"
                        self._gestureDetector.detectGestures(points: rotatedPoints)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isHandDetected = false
                        self.detectionConfidence = 0.0
                        self.currentHandPoints = [:]
                        self.debugInfo = "未檢測到手部"
                        self._gestureDetector.resetAllGestures()
                    }
                }
            } catch {
                //print("Vision error:", error)
                DispatchQueue.main.async {
                    self.isHandDetected = false
                    self.detectionConfidence = 0.0
                    self.currentHandPoints = [:]
                    self.debugInfo = "識別錯誤: \(error.localizedDescription)"
                }
            }
            
            self.isProcessing = false
        }
    }
    
    // MARK: - 公共方法
    func startRecognition() {
        // 重置狀態
        isHandDetected = false
        currentGesture = .none
        palmXPosition = 5
        previousPalmXPosition = 5.0
        currentHandPoints = [:]
        detectionConfidence = 0.0
        debugInfo = "開始手部識別"
    }
    
    func stopRecognition() {
        isHandDetected = false
        currentHandPoints = [:]
        detectionConfidence = 0.0
        debugInfo = "停止手部識別"
        _gestureDetector.resetAllGestures()
    }
    
    // MARK: - 手部點位數據
    func getHandPoints() -> [VNHumanHandPoseObservation.JointName: CGPoint] {
        return currentHandPoints
    }
    
    // MARK: - 參數調整方法
    func setMinConfidenceThreshold(_ threshold: Float) {
        // 動態調整置信度閾值
    }
    
    func setSmoothingFactor(_ factor: Float) {
        // 動態調整平滑因子
    }
    
    // MARK: - 遊戲動作映射
    private func mapGestureToGameAction() -> GameAction? {
        let gesture = _gestureDetector.currentGesture
        //print("🎮 檢查手勢: \(gesture.rawValue)")
        
        switch gesture {
        case .none:
            return nil
        case .rotateLeft:
            //print("🎮 映射到 rotateLeft")
            return .rotateLeft
        case .rotateRight:
            //print("🎮 映射到 rotateRight")
            return .rotateRight
        case .fingersClosed:
            //print("🎮 映射到 moveDown")
            return .moveDown
        }
    }
    
    // MARK: - 公共遊戲動作方法
    func getGameAction() -> GameAction? {
        guard isHandDetected else { return nil }
        
        // 檢查是否有旋轉手勢
        if let rotationAction = mapGestureToGameAction() {
            //print("🎮 遊戲動作: \(rotationAction)")
            return rotationAction
        }
        
        // 如果沒有旋轉手勢，根據手掌位置決定左右移動
        // 將 1-10 的範圍分為三個區域：
        // 1-4: 左移（擴大左移區域）
        // 5-6: 不移動（縮小中間區域）
        // 7-10: 右移（擴大右移區域）
        if palmXPosition <= 4 {
            //print("🎮 遊戲動作: moveLeft (X位置: \(palmXPosition))")
            return .moveLeft
        } else if palmXPosition >= 7 {
            //print("🎮 遊戲動作: moveRight (X位置: \(palmXPosition))")
            return .moveRight
        }
        
        // 5-6 範圍不移動
        return nil
    }
}

// MARK: - 遊戲動作枚舉
enum GameAction {
    case moveLeft
    case moveRight
    case moveDown
    case rotateLeft
    case rotateRight
} 
