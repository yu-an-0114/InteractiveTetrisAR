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
      MainMenuView()
          .environmentObject(settingsVM)
  }
}

#Preview {
    ContentView()
        .environmentObject(SettingsViewModel())
}
