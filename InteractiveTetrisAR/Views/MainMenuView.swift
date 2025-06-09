import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationStack {
            DarkBackgroundView {
                VStack(spacing: 40) {
                    // 開始遊戲
                    NavigationLink(destination: GameARContainerView()) {
                        Text("開始遊戲")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sciFiStyle()

                    // 分數排行
                    NavigationLink(destination: ScoreboardView()) {
                        Text("分數排行")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sciFiStyle()

                    // 設定
                    NavigationLink(destination: SettingsView()) {
                        Text("設定")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sciFiStyle()
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true)
        }
    }
}
