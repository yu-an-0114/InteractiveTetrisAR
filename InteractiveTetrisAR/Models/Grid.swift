
import Foundation

/// 代表整個遊戲邏輯格子（高度與寬度固定）
/// 每個格子可以是空的（.empty）或填滿某個顏色（.filled）
struct Grid {
    static let numRows = 20
    static let numCols = 10

    /// 二維陣列：儲存每個 (row, col) 的狀態
    /// - .empty: 格子空閒
    /// - .filled(color): 已被方塊佔據，並記錄方塊顏色
    private(set) var cells: [[CellState]] = Array(
        repeating: Array(repeating: .empty, count: Grid.numCols),
        count: Grid.numRows
    )

    /// 將當前 Tetromino 鎖定到格子中
    /// - Parameters:
    ///   - tetro: 要鎖定的 Tetromino
    ///   - color: 填滿格子的顏色
    mutating func lockTetromino(_ tetro: Tetromino, color: CellState) {
        for (dr, dc) in tetro.blocks {
            let r = tetro.gridPosition.row - dr
            let c = tetro.gridPosition.col + dc
            guard r >= 0, r < Grid.numRows, c >= 0, c < Grid.numCols else { continue }
            cells[r][c] = color
        }
    }

    /// 檢查是否有整行滿格，若滿格則消除該列，並將上方格子往下推
    /// - Returns: 清除的列數
    mutating func clearFullRows() -> Int {
        var newCells: [[CellState]] = Array(
            repeating: Array(repeating: .empty, count: Grid.numCols),
            count: Grid.numRows
        )
        var newRowIndex = 0
        var clearedCount = 0

        for r in 0..<Grid.numRows {
            // 如果第 r 列全部都是 .filled，跳過（代表消除）
            if cells[r].allSatisfy({ cell in
                if case .filled = cell {
                    return true
                } else {
                    return false
                }
            }) {
                clearedCount += 1
            } else {
                // 沒滿格的列就複製到 newCells
                newCells[newRowIndex] = cells[r]
                newRowIndex += 1
            }
        }
        // 在上方補滿空白列
        for r in newRowIndex..<Grid.numRows {
            newCells[r] = Array(repeating: .empty, count: Grid.numCols)
        }
        cells = newCells
        return clearedCount
    }

    /// 檢查指定的 Tetromino 是否可以放置在目前的格子位置（不碰牆且不與其他已佔據格子衝突）
    /// - Parameter tetro: 要檢查的 Tetromino
    /// - Returns: 可以放置回傳 true，否則 false
    func canPlaceTetromino(_ tetro: Tetromino) -> Bool {
        for (dr, dc) in tetro.blocks {
            let r = tetro.gridPosition.row - dr
            let c = tetro.gridPosition.col + dc
            // 檢查是否超出邊界
            if r < 0 || r >= Grid.numRows || c < 0 || c >= Grid.numCols {
                return false
            }
            // 檢查是否與已佔據格子衝突
            if case .filled(_) = cells[r][c] {
                return false
            }
        }
        return true
    }
}

/// 每個格子的狀態：
/// - empty: 空格
/// - filled(color): 已被方塊填滿，並記錄該方塊的顏色
enum CellState {
    case empty
    case filled(color: SIMD4<Float>)
}
