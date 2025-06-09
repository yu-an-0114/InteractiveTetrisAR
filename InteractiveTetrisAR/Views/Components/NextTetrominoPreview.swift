//
//  NextTetrominoPreview.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

/// 下一個 Tetromino 的 2D 預覽視圖
struct NextTetromino2Preview: View {
    let tetromino: Tetromino

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cell = size / 4

            ZStack {
                Color.clear

                ForEach(0..<tetromino.blocks.count, id: \.self) { i in
                    let (dr, dc) = tetromino.blocks[i]
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: cell, height: cell)
                        .position(
                            x: cell * (CGFloat(dc) + 1),
                            y: cell * (CGFloat(3 - dr))
                        )
                }
            }
        }
    }
}

struct NextTetromino2Preview_Previews: PreviewProvider {
    static var previews: some View {
        DarkBackgroundView {
            NextTetromino2Preview(tetromino: Tetromino(type: .T))
                .frame(width: 100, height: 100)
                .padding()
        }
    }
}
