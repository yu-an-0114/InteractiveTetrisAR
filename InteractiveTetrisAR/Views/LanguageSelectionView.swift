import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject private var settingsVM: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationService = LocalizationService.shared
    
    private let languages = [
        ("🇹🇼", "繁體中文", "Traditional Chinese"),
        ("🇺🇸", "English", "English"),
        ("🇯🇵", "日本語", "Japanese"),
        ("🇰🇷", "한국어", "Korean"),
        ("🇪🇸", "Español", "Spanish"),
        ("🇫🇷", "Français", "French")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // 動態背景 - 與主畫面一致
                AnimatedBackgroundView()
                
                VStack(spacing: 30) {
                    // 標題區域
                    VStack(spacing: 10) {
                        Text(localizationService.localizedString(for: .languageSelection))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .yellow.opacity(0.8), radius: 10, x: 0, y: 5)
                        
                        Text("選擇您偏好的語言")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    // 語言選項
                    VStack(spacing: 15) {
                        ForEach(languages, id: \.1) { language in
                            LanguageCard(
                                flag: language.0,
                                name: language.1,
                                englishName: language.2,
                                isSelected: localizationService.currentLanguage == language.1
                            ) {
                                selectLanguage(language.1)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // 確認按鈕
                    Button(action: {
                        // 更新設定
                        settingsVM.currentLanguage = localizationService.currentLanguage
                        dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text(localizationService.localizedString(for: .confirm))
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                                )
                        )
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - 輔助方法
    private func selectLanguage(_ language: String) {
        localizationService.setLanguage(language)
        print("🌍 語言已切換為: \(language)")
    }
}

// MARK: - 語言卡片組件
struct LanguageCard: View {
    let flag: String
    let name: String
    let englishName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(flag)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(englishName)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? 
                                [Color.yellow.opacity(0.3), Color.yellow.opacity(0.1)] :
                                [Color.black.opacity(0.4), Color.black.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.yellow.opacity(0.6) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.yellow.opacity(0.3) : Color.clear,
                radius: isSelected ? 10 : 0,
                x: 0,
                y: isSelected ? 5 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LanguageSelectionView()
        .environmentObject(SettingsViewModel())
}
