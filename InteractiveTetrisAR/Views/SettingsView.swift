import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showHandGestureSettings = false
    @State private var showLanguageSelection = false
    @State private var showDifficultySelection = false
    @State private var showPlayerNameEdit = false
    @State private var showAudioSettings = false
    @StateObject private var localizationService = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // 動態背景 - 與主畫面一致
                AnimatedBackgroundView()
                
                VStack(spacing: 30) {
                    // 標題區域
                    VStack(spacing: 10) {
                        Text(localizationService.localizedString(for: .settings))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .blue.opacity(0.8), radius: 10, x: 0, y: 5)
                        
                        Text("遊戲配置與偏好設定")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 5)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // 設定選項
                    VStack(spacing: 25) {
                        // 玩家名稱設定
                        SettingsCard(
                            icon: "person.circle.fill",
                            title: localizationService.localizedString(for: .playerName),
                            subtitle: settingsVM.playerName,
                            color: .blue
                        ) {
                            showPlayerNameEdit = true
                        }
                        
                        // 遊戲難度設定
                        SettingsCard(
                            icon: "speedometer",
                            title: localizationService.localizedString(for: .gameDifficulty),
                            subtitle: "\(localizationService.localizedString(for: .gestureSensitivity)): \(String(format: "%.1f", settingsVM.gestureSensitivity))x",
                            color: .orange
                        ) {
                            showDifficultySelection = true
                        }

                    // 手部控制設定
                        SettingsCard(
                            icon: "hand.raised.fill",
                            title: localizationService.localizedString(for: .handGestureSettings),
                            subtitle: "調整手勢識別參數",
                            color: .green
                        ) {
                        showHandGestureSettings = true
                    }
                        
                        // 音效設定（整合）
                        SettingsCard(
                            icon: "speaker.wave.2.fill",
                            title: localizationService.localizedString(for: .audioSettings),
                            subtitle: getAudioSettingsSummary(),
                            color: .purple
                        ) {
                            showAudioSettings = true
                        }

                    // 語言選擇
                        SettingsCard(
                            icon: "globe",
                            title: localizationService.localizedString(for: .languageSelection),
                            subtitle: settingsVM.currentLanguage,
                            color: .yellow
                        ) {
                            showLanguageSelection = true
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()

                    // 底部按鈕
                    VStack(spacing: 15) {
                        Button(action: {
                            settingsVM.saveSettings()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text(localizationService.localizedString(for: .save))
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green.opacity(0.6), lineWidth: 2)
                                    )
                            )
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.title3)
                                Text(localizationService.localizedString(for: .back))
                                    .font(.headline)
                }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 12)
                .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
            .sheet(isPresented: $showHandGestureSettings) {
                HandGestureSettingsView()
                    .environmentObject(settingsVM)
            }
        .sheet(isPresented: $showLanguageSelection) {
            LanguageSelectionView()
                .environmentObject(settingsVM)
        }
        .sheet(isPresented: $showDifficultySelection) {
            DifficultySelectionView()
                .environmentObject(settingsVM)
        }
        .sheet(isPresented: $showPlayerNameEdit) {
            PlayerNameEditView()
                .environmentObject(settingsVM)
        }
        .sheet(isPresented: $showAudioSettings) {
            AudioSettingsView()
                .environmentObject(settingsVM)
        }
    }
    
    // MARK: - 輔助方法
    private func getAudioSettingsSummary() -> String {
        let soundStatus = settingsVM.isSoundOn ? "\(localizationService.localizedString(for: .soundEffects))✓" : "\(localizationService.localizedString(for: .soundEffects))✗"
        let hapticsStatus = settingsVM.isHapticsOn ? "\(localizationService.localizedString(for: .vibrationFeedback))✓" : "\(localizationService.localizedString(for: .vibrationFeedback))✗"
        let musicStatus = settingsVM.isMusicOn ? "\(localizationService.localizedString(for: .backgroundMusic))✓" : "\(localizationService.localizedString(for: .backgroundMusic))✗"
        return "\(soundStatus) \(hapticsStatus) \(musicStatus)"
    }
}

// MARK: - 設定卡片組件
struct SettingsCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.4), Color.black.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 難度選擇視圖
struct DifficultySelectionView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationService = LocalizationService.shared
    
    private var difficultyLevels: [(Double, LocalizationKey, String)] {
        [
            (0.5, .veryEasy, "適合初學者，方塊下落緩慢"),
            (0.8, .easy, "手勢寬鬆，方塊下落較慢"),
            (1.0, .normal, "標準難度，方塊下落速度適中"),
            (1.3, .hard, "手勢精確，方塊下落較快"),
            (1.6, .veryHard, "高精度要求，方塊下落快速"),
            (2.0, .extreme, "專業玩家，方塊下落極快")
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 動態背景
                AnimatedBackgroundView()
                
                VStack(spacing: 30) {
                    // 標題
                    VStack(spacing: 10) {
                        Text(localizationService.localizedString(for: .gameDifficulty))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .orange.opacity(0.8), radius: 10, x: 0, y: 5)
                        
                        Text("調整手勢識別靈敏度與方塊下落速度")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    // 難度選項
                    VStack(spacing: 15) {
                        ForEach(difficultyLevels, id: \.0) { level in
                            DifficultyCard(
                                value: level.0,
                                title: localizationService.localizedString(for: level.1),
                                description: level.2,
                                dropInterval: getDropInterval(for: level.0),
                                isSelected: settingsVM.gestureSensitivity == level.0
                            ) {
                                settingsVM.gestureSensitivity = level.0
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // 確認按鈕
                    Button(action: {
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
                                .fill(Color.orange.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange.opacity(0.6), lineWidth: 2)
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
    private func getDropInterval(for difficulty: Double) -> String {
        let baseInterval: TimeInterval = 1.0
        let interval = baseInterval / difficulty
        return "\(localizationService.localizedString(for: .dropInterval)): \(String(format: "%.1f", interval))秒"
    }
}

// MARK: - 難度卡片組件
struct DifficultyCard: View {
    let value: Double
    let title: String
    let description: String
    let dropInterval: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", value))x")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundColor(.cyan)
                        
                        Text("落下間隔: \(dropInterval)")
                            .font(.caption)
                            .foregroundColor(.cyan)
                    }
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
                                [Color.orange.opacity(0.3), Color.orange.opacity(0.1)] :
                                [Color.black.opacity(0.4), Color.black.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.orange.opacity(0.6) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.orange.opacity(0.3) : Color.clear,
                radius: isSelected ? 10 : 0,
                x: 0,
                y: isSelected ? 5 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}

// MARK: - 玩家名稱編輯視圖
struct PlayerNameEditView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var playerName: String = ""
    @StateObject private var localizationService = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // 動態背景
                AnimatedBackgroundView()
                
                VStack(spacing: 30) {
                    // 標題
                    VStack(spacing: 10) {
                        Text("編輯\(localizationService.localizedString(for: .playerName))")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .blue.opacity(0.8), radius: 10, x: 0, y: 5)
                        
                        Text("輸入您的遊戲暱稱")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    // 輸入框
                    VStack(spacing: 20) {
                        TextField("輸入\(localizationService.localizedString(for: .playerName))", text: $playerName)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                                    )
                            )
                            .onAppear {
                                playerName = settingsVM.playerName
                            }
                        
                        Text("名稱將顯示在排行榜中")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // 按鈕
                    VStack(spacing: 15) {
                        Button(action: {
                            if !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                settingsVM.playerName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
                                dismiss()
                            }
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
                                    .fill(Color.blue.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                                    )
                            )
                        }
                        .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                Text(localizationService.localizedString(for: .cancel))
                                    .font(.headline)
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 音效設定視圖
struct AudioSettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationService = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // 動態背景
                AnimatedBackgroundView()
                
                VStack(spacing: 30) {
                    // 標題
                    VStack(spacing: 10) {
                        Text(localizationService.localizedString(for: .audioSettings))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .purple.opacity(0.8), radius: 10, x: 0, y: 5)
                        
                        Text("調整遊戲音效與回饋")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    // 音效選項
                    VStack(spacing: 20) {
                        AudioToggleCard(
                            icon: "speaker.wave.2.fill",
                            title: localizationService.localizedString(for: .soundEffects),
                            description: "方塊移動、消除等音效",
                            isOn: $settingsVM.isSoundOn,
                            color: .purple
                        )
                        
                        AudioToggleCard(
                            icon: "iphone.radiowaves.left.and.right",
                            title: localizationService.localizedString(for: .vibrationFeedback),
                            description: "手勢操作時的震動提示",
                            isOn: $settingsVM.isHapticsOn,
                            color: .pink
                        )
                        
                        AudioToggleCard(
                            icon: "music.note",
                            title: localizationService.localizedString(for: .backgroundMusic),
                            description: "遊戲進行時的背景音樂",
                            isOn: $settingsVM.isMusicOn,
                            color: .cyan
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // 確認按鈕
                    Button(action: {
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
                                .fill(Color.purple.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.purple.opacity(0.6), lineWidth: 2)
                                )
                        )
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 音效開關卡片組件
struct AudioToggleCard: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: color))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.4), Color.black.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}
