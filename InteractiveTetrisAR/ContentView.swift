//
//  ContentView.swift
//  InteractiveTetrisAR
//
//  Created by 陳昱安 on 2025/6/3.
//

import SwiftUI
import RealityKit

struct ContentView: View {
  @EnvironmentObject var settingsVM: SettingsViewModel
  @StateObject private var gameVM = GameViewModel()
  var body: some View {
      GameARView(gameVM: gameVM, difficulty: settingsVM.gestureSensitivity)
      .edgesIgnoringSafeArea(.all)
      .onAppear {
        // 啟動遊戲並開始自動下落
        gameVM.startGame()
      }
  }
}

#Preview {
    ContentView()
        .environmentObject(SettingsViewModel())
}
