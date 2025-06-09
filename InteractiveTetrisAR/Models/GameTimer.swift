//
//  GameTimer.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation
import Combine

/// 遊戲計時器，用於驅動方塊自動下墜與更新經過時間
final class GameTimer: ObservableObject {
    /// 已經經過的秒數
    @Published private(set) var elapsedTime: TimeInterval = 0
    
    private var timerCancellable: Cancellable? = nil

    /// 啟動計時器：每秒更新一次 elapsedTime
    func start() {
        elapsedTime = 0
        timerCancellable = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedTime += 1
            }
    }
    
    /// 停止計時器
    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    /// 重置計時器
    func reset() {
        stop()
        elapsedTime = 0
    }
}
