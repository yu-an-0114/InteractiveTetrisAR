//
//  Tetromino.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation

/// 定義七種俄羅斯方塊的形狀
enum TetrominoType: CaseIterable {
    case I, O, T, S, Z, J, L
}

/// Tetromino 結構：包含形狀、目前旋轉狀態、格子位置與相對方塊格子座標
struct Tetromino {
    /// 方塊形狀類型
    let type: TetrominoType
    
    /// 旋轉狀態：0～3 對應四種旋轉方向
    private(set) var rotationIndex: Int
    
    /// 在邏輯格子系統中的參考座標 (row, col)
    /// 表示這個 Tetromino 所佔佈「相對格子陣列」的「頂點參考」位置
    var gridPosition: (row: Int, col: Int)
    
    /// 代表此 Tetromino 在目前 rotationIndex 下所佔據的相對格子 (dr, dc)
    /// dr = row 方向偏移，dc = col 方向偏移
    var blocks: [(Int, Int)]
    
    /// 初始化：隨機產生一個形狀，並放在最上方中央位置
    init(type: TetrominoType) {
        self.type = type
        self.rotationIndex = 0
        // 初始時把方塊放到最上方中央 (row = numRows - 1, col = numCols/2 - 1)
        self.gridPosition = (row: Grid.numRows - 1, col: Grid.numCols / 2 - 1)
        self.blocks = Tetromino.shapes[type]![0]
    }
    
    /// 旋轉順時針：更新 rotationIndex 與 blocks
    mutating func rotateClockwise() {
        rotationIndex = (rotationIndex + 1) % 4
        blocks = Tetromino.shapes[type]![rotationIndex]
    }
    
    /// 旋轉逆時針：更新 rotationIndex 與 blocks
    mutating func rotateCounterClockwise() {
        rotationIndex = (rotationIndex + 3) % 4
        blocks = Tetromino.shapes[type]![rotationIndex]
    }
    
    /// 靜態字典：儲存每種 TetrominoType 在四個旋轉狀態下的相對格子坐標
    private static let shapes: [TetrominoType: [[(Int, Int)]]] = [
        .I: [
            // 旋轉 0 度
            [(0,1), (1,1), (2,1), (3,1)],
            // 旋轉 90 度
            [(2,0), (2,1), (2,2), (2,3)],
            // 旋轉 180 度
            [(0,2), (1,2), (2,2), (3,2)],
            // 旋轉 270 度
            [(1,0), (1,1), (1,2), (1,3)]
        ],
        .O: [
            // O 形不需旋轉，四種狀態皆相同
            [(0,0), (0,1), (1,0), (1,1)],
            [(0,0), (0,1), (1,0), (1,1)],
            [(0,0), (0,1), (1,0), (1,1)],
            [(0,0), (0,1), (1,0), (1,1)]
        ],
        .T: [
            // T 形 0 度
            [(0,1), (1,0), (1,1), (1,2)],
            // T 形 90 度
            [(0,1), (1,1), (1,2), (2,1)],
            // T 形 180 度
            [(1,0), (1,1), (1,2), (2,1)],
            // T 形 270 度
            [(0,1), (1,0), (1,1), (2,1)]
        ],
        .S: [
            // S 形 0 度
            [(1,0), (1,1), (2,1), (2,2)],
            // S 形 90 度
            [(0,1), (1,1), (1,2), (2,2)],
            // S 形 180 度
            [(1,0), (1,1), (2,1), (2,2)],
            // S 形 270 度
            [(0,1), (1,1), (1,2), (2,2)]
        ],
        .Z: [
            // Z 形 0 度
            [(1,1), (1,2), (2,0), (2,1)],
            // Z 形 90 度
            [(0,2), (1,1), (1,2), (2,1)],
            // Z 形 180 度
            [(1,1), (1,2), (2,0), (2,1)],
            // Z 形 270 度
            [(0,2), (1,1), (1,2), (2,1)]
        ],
        .J: [
            // J 形 0 度
            [(0,0), (1,0), (2,0), (2,1)],
            // J 形 90 度
            [(1,0), (1,1), (1,2), (2,0)],
            // J 形 180 度
            [(0,0), (0,1), (1,1), (2,1)],
            // J 形 270 度
            [(1,2), (2,0), (2,1), (2,2)]
        ],
        .L: [
            // L 形 0 度
            [(0,1), (1,1), (2,1), (2,0)],
            // L 形 90 度
            [(1,0), (1,1), (1,2), (2,2)],
            // L 形 180 度
            [(0,1), (0,2), (1,1), (2,1)],
            // L 形 270 度
            [(1,0), (2,0), (2,1), (2,2)]
        ]
    ]
}
