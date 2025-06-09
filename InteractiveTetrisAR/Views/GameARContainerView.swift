//
//  GameARContainerView.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import RealityKit
import ARKit

/// SwiftUI 層級，用以包裝 RealityKit 的 ARView 並疊加分數、計時、暫停、下一個方塊預覽等 UI
struct GameARContainerView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var scoreVM: ScoreViewModel
    @StateObject private var gameVM = GameViewModel()
    @State private var showGameOverAlert = false

    var body: some View {
        ZStack {
            // MARK: - 1. 底層：AR 3D 場景
            GameARView(gameVM: gameVM, difficulty: settingsVM.gestureSensitivity)
                .edgesIgnoringSafeArea(.all)

            // MARK: - 2. 分數、時間、暫停、下一個方塊
            VStack {
                HStack {
                    // 分數顯示
                    Text("Score: \(gameVM.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)

                    Spacer()

                    // 經過時間顯示
                    Text("Time: \(Int(gameVM.timer.elapsedTime))s")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)

                    Spacer()

                    // 暫停/繼續按鈕
                    Button(action: {
                        if gameVM.isPaused {
                            gameVM.resumeGame()
                        } else {
                            gameVM.pauseGame()
                        }
                    }) {
                        Image(systemName: gameVM.isPaused ? "play.fill" : "pause.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 40)

                Spacer()

                // 下一個方塊預覽
                if let next = gameVM.nextTetromino {
                    VStack(spacing: 4) {
                        Text("Next")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        NextTetrominoPreview(tetromino: next)
                            .frame(width: 70, height: 70)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            gameVM.startGame()
        }
        .alert(isPresented: $showGameOverAlert) {
            Alert(
                title: Text("遊戲結束"),
                message: Text("您的最終分數：\(gameVM.score)"),
                primaryButton: .default(Text("存檔"), action: {
                    let record = ScoreRecord(
                        playerName: settingsVM.playerName,
                        score: gameVM.score
                    )
                    scoreVM.addScore(record)                        // 本地儲存
                    FirebaseService.shared.uploadScore(record)      // Firebase 上傳
                    NotificationCenter.default.post(name: Constants.Notifications.navigateTo, object: "Score")
                }),
                secondaryButton: .cancel(Text("返回主畫面"), action: {
                    NotificationCenter.default.post(name: Constants.Notifications.navigateTo, object: "Main")
                })
            )
        }
        .onReceive(gameVM.$isGameOver) { isOver in
            if isOver {
                showGameOverAlert = true
            }
        }
    }
}

/// 下一個 Tetromino 的簡易 2D 預覽視圖
struct NextTetrominoPreview: View {
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

struct GameARContainerView_Previews: PreviewProvider {
    static var previews: some View {
        GameARContainerView()
            .environmentObject(SettingsViewModel())
            .environmentObject(ScoreViewModel())
    }
}   
