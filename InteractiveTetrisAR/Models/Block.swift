import Foundation
import simd

/// 單個方塊 (cube) 的資料結構
struct Block: Identifiable {
    let id = UUID()
    /// 在 AR 世界座標中的位置 (x, y, z)
    var position: SIMD3<Float>
    /// 方塊顏色 (RGBA)
    var color: SIMD4<Float>
}
