import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    var body: some View {
        NavigationStack {
            DarkBackgroundView {
                VStack(spacing: 30) {
                    // 遊戲難度
                    Button("遊戲難度") {
                        // 切換難度
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sciFiStyle()

                    // 音效開關
                    Toggle(isOn: .constant(true)) {
                        Text("音效")
                    }
                    .toggleStyle(.button)
                    .sciFiStyle()

                    // 語言選擇
                    NavigationLink {
                        LanguageSelectionView()
                    } label: {
                        Text("語言")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sciFiStyle()
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitle("設定", displayMode: .inline)
        }
    }
}
