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
    @State private var showGameOver = false
    @State private var showTutorial = false
    @State private var showPauseMenu = false
    @State private var showHandOverlay = false
    @State private var coordinator: GameARView.Coordinator?

    var body: some View {
        ZStack {
            // MARK: - 1. 底層：AR 3D 場景
            GameARView(
                gameVM: gameVM, 
                difficulty: settingsVM.gestureSensitivity,
                coordinator: $coordinator
            )
            .edgesIgnoringSafeArea(.all)

            // MARK: - 2. 遊戲 UI 覆蓋層
            GameUIView(
                score: gameVM.score,
                playTime: gameVM.timer.elapsedTime,
                isPaused: gameVM.isPaused,
                isHandDetected: true, // 這個視圖沒有手部識別，所以設為true
                currentGesture: "No Gesture",
                nextTetromino: gameVM.nextTetromino,
                showHandOverlay: showHandOverlay,
                onPauseResume: {
                    // 直接顯示暫停選單，不管遊戲狀態
                    gameVM.pauseGame()
                    showPauseMenu = true
                },
                onToggleHandOverlay: {
                    // 移除這個功能，移到暫停選單中
                },
                onShowTutorial: {
                    // 移除這個功能，移到暫停選單中
                }
            )
            
            // MARK: - 暫停選單
            if showPauseMenu {
                PauseMenuView(
                    showHandOverlay: showHandOverlay,
                    onResume: {
                        showPauseMenu = false
                        gameVM.resumeGame()
                    },
                    onBackToMain: {
                        showPauseMenu = false
                        // 使用更直接的方式返回主選單
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Constants.Notifications.navigateTo, object: "Main")
                        }
                    },
                    onToggleHandOverlay: {
                        showHandOverlay.toggle()
                    },
                    onShowTutorial: {
                        // 不關閉暫停選單，直接顯示教學
                        showTutorial = true
                    }
                )
            }
        }
        .navigationBarHidden(true) // 隱藏導航欄
        .navigationBarBackButtonHidden(true) // 隱藏返回按鈕
        .gesture(DragGesture().onChanged { _ in }) // 禁止右滑手勢
        .onAppear {
            gameVM.startGame()
        }
        .onChange(of: gameVM.isGameOver) { isOver in
            if isOver {
                showGameOver = true
            }
        }
        .fullScreenCover(isPresented: $showGameOver) {
            GameOverView(
                finalScore: gameVM.score,
                playTime: gameVM.timer.elapsedTime,
                onRestart: {
                    showGameOver = false
                    // 清理AR場景中的方塊實體
                    coordinator?.clearAllBlocks()
                    gameVM.startGame()
                },
                onBackToMain: {
                    showGameOver = false
                    NotificationCenter.default.post(name: Constants.Notifications.navigateTo, object: "Main")
                }
            )
        }
        .sheet(isPresented: $showTutorial) {
            HandGestureTutorialView()
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
