//
//  GameViewModel.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation
import Combine
import simd

/// 處理遊戲邏輯：當前方塊、格子狀態、分數、手勢命令映射
final class GameViewModel: ObservableObject {
    // MARK: - Published 屬性（供 View 監聽並更新）
    @Published private(set) var grid = Grid()
    @Published private(set) var currentTetromino: Tetromino?
    @Published private(set) var nextTetromino: Tetromino?
    @Published private(set) var placedBlocks: [Block] = []      // 已鎖定方塊 (3D 世界座標)
    @Published private(set) var score: Int = 0
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var isPaused: Bool = false

    /// 遊戲計時器，用於顯示經過時間
    let timer = GameTimer()

    private var cancellables = Set<AnyCancellable>()

    /// 方塊自動下墜的間隔（秒），可由外部傳入或設定
    var dropInterval: TimeInterval = 1.0
    private var dropCancellable: AnyCancellable?

    // MARK: - 初始化
    init() {
        // 監聽需要時可擴充
        bindTimer()
        spawnTetrominoes()
    }

    private func bindTimer() {
        // 可以監聽 elapsedTime 來做其他行為
        timer.$elapsedTime
            .sink { _ in }
            .store(in: &cancellables)
    }

    // MARK: - 遊戲流程控制

    /// 開始新遊戲
    func startGame() {
        grid = Grid()
        placedBlocks = []
        score = 0
        isGameOver = false
        isPaused = false

        timer.reset()
        timer.start()

        spawnTetrominoes()
        startAutoDrop()
    }

    /// 暫停遊戲
    func pauseGame() {
        guard !isGameOver else { return }
        isPaused = true
        timer.stop()
        dropCancellable?.cancel()
    }

    /// 繼續遊戲
    func resumeGame() {
        guard isPaused, !isGameOver else { return }
        isPaused = false
        timer.start()
        startAutoDrop()
    }

    /// 結束遊戲
    func endGame() {
        isGameOver = true
        timer.stop()
        dropCancellable?.cancel()
    }

    // MARK: - 方塊生成與下墜

    /// 隨機生成下一個方塊序列，並設置 currentTetromino 與 nextTetromino
    func spawnTetrominoes() {
        if nextTetromino == nil {
            nextTetromino = Tetromino(type: TetrominoType.allCases.randomElement()!)
        }
        currentTetromino = nextTetromino
        nextTetromino = Tetromino(type: TetrominoType.allCases.randomElement()!)

        // 如果生成後就無法放置，直接結束遊戲
        if let t = currentTetromino, !grid.canPlaceTetromino(t) {
            endGame()
        }
    }

    /// 啟動自動下墜計時器，讓方塊每隔 dropInterval 秒自動下移一格
    func startAutoDrop() {
        dropCancellable?.cancel()
        dropCancellable = Timer
            .publish(every: dropInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.moveDown()
            }
    }

    // MARK: - 手勢對應操作

    /// 向左移動一格
    func moveLeft() {
        guard var t = currentTetromino, !isPaused, !isGameOver else { return }
        t.gridPosition.col -= 1
        if grid.canPlaceTetromino(t) {
            currentTetromino = t
        }
    }

    /// 向右移動一格
    func moveRight() {
        guard var t = currentTetromino, !isPaused, !isGameOver else { return }
        t.gridPosition.col += 1
        if grid.canPlaceTetromino(t) {
            currentTetromino = t
        }
    }

    /// 旋轉逆時針
    func rotateLeft() {
        guard var t = currentTetromino, !isPaused, !isGameOver else { return }
        t.rotateCounterClockwise()
        if grid.canPlaceTetromino(t) {
            currentTetromino = t
        }
    }

    /// 旋轉順時針
    func rotateRight() {
        guard var t = currentTetromino, !isPaused, !isGameOver else { return }
        t.rotateClockwise()
        if grid.canPlaceTetromino(t) {
            currentTetromino = t
        }
    }

    /// 向下移動一格（自然下墜或手勢觸發皆呼叫此方法）
    func moveDown() {
        guard var t = currentTetromino, !isPaused, !isGameOver else { return }
        t.gridPosition.row -= 1
        if grid.canPlaceTetromino(t) {
            currentTetromino = t
        } else {
            lockCurrentTetromino()
        }
    }

    // MARK: - 方塊落地鎖定與消行

    /// 將當前方塊鎖定到格子，並更新 placedBlocks、消行與分數，然後生成下一個
    private func lockCurrentTetromino() {
        guard let t = currentTetromino else { return }
        // 將邏輯格子設為已佔據
        let colorState = CellState.filled(color: randomColor(for: t.type))
        grid.lockTetromino(t, color: colorState)

        // 將鎖定的四個小方塊轉成 3D 世界座標並加入 placedBlocks
        for (dr, dc) in t.blocks {
            let r = t.gridPosition.row - dr
            let c = t.gridPosition.col + dc
            let worldPos = convertGridPositionToWorld(r: r, c: c)
            placedBlocks.append(Block(position: worldPos, color: randomColor(for: t.type)))
        }

        // 檢查是否有消除列
        let cleared = grid.clearFullRows()
        if cleared > 0 {
            score += cleared * 100
        }

        // 生成下一個方塊
        spawnTetrominoes()
    }

    // MARK: - 顏色與座標轉換

    /// 根據不同的 TetrominoType 回傳對應顏色 (RGBA)
    func randomColor(for type: TetrominoType) -> SIMD4<Float> {
        switch type {
        case .I: return SIMD4<Float>(0, 1, 1, 1)       // 青色
        case .O: return SIMD4<Float>(1, 1, 0, 1)       // 黃色
        case .T: return SIMD4<Float>(0.5, 0, 0.5, 1)   // 紫色
        case .S: return SIMD4<Float>(0, 1, 0, 1)       // 綠色
        case .Z: return SIMD4<Float>(1, 0, 0, 1)       // 紅色
        case .J: return SIMD4<Float>(0, 0, 1, 1)       // 藍色
        case .L: return SIMD4<Float>(1, 0.5, 0, 1)     // 橙色
        }
    }

    /// 將格子 (row, col) 轉換為 AR 世界座標 (x, y, z)
    /// - 這裡假設遊戲版面置於相機前方 0.5 公尺，且每格大小 0.05 公尺
    func convertGridPositionToWorld(r: Int, c: Int) -> SIMD3<Float> {
        let boardOffsetY: Float = 0.25   // 提前 elevating board
        let cellSize: Float = 0.05
        let x = (Float(c) - Float(Grid.numCols) / 2 + 0.5) * cellSize
        let y = (Float(r) - Float(Grid.numRows) / 2 + 0.5) * cellSize + boardOffsetY
        let z: Float = -0.5
        return SIMD3<Float>(x, y, z)
    }
}
