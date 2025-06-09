//
//  ContentView.swift
//  InteractiveTetrisAR
//
//  Created by 陳昱安 on 2025/6/3.
//

import SwiftUI
import RealityKit

struct ContentView: View {
  @StateObject private var gameVM = GameViewModel(difficulty: .normal)
  var body: some View {
    GameARView(gameVM: gameVM)
      .edgesIgnoringSafeArea(.all)
      .onAppear {
        // 如果你有封裝 startGame、reset 之類方法，在這裡呼叫
        gameVM.pauseGame()   // 先確保是暫停狀態
        gameVM.spawnTetrominoes()
        gameVM.startAutoDrop()
      }
  }
}

#Preview {
    ContentView()
}
