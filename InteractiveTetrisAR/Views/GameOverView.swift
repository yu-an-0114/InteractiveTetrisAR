import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var scoreVM: ScoreViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationService = LocalizationService.shared
    
    let finalScore: Int
    let playTime: TimeInterval
    let onRestart: () -> Void
    let onBackToMain: () -> Void
    
    @State private var showScoreSaved = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 動態背景 - 與主畫面一致
            AnimatedBackgroundView()
            
            VStack(spacing: 40) {
                // 標題區域
                VStack(spacing: 15) {
                    Text(localizationService.localizedString(for: .gameOver))
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.8), radius: 15, x: 0, y: 8)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("遊戲結束")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 60)
                
                // 分數統計區域
                VStack(spacing: 25) {
                    // 最終分數
                    VStack(spacing: 10) {
                        Text(localizationService.localizedString(for: .finalScore))
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(finalScore)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(.cyan)
                            .shadow(color: .cyan.opacity(0.8), radius: 10, x: 0, y: 5)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.cyan.opacity(0.6), lineWidth: 3)
                            )
                    )
                    
                    // 遊戲時間
                    HStack(spacing: 30) {
                        StatCard(
                            title: localizationService.localizedString(for: .playTime),
                            value: formatTime(playTime),
                            color: .green
                        )
                        
                        StatCard(
                            title: localizationService.localizedString(for: .difficulty),
                            value: getDifficultyText(settingsVM.gestureSensitivity),
                            color: .orange
                        )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // 操作按鈕
                VStack(spacing: 20) {
                    // 重新開始按鈕
                    Button(action: {
                        SoundService.shared.playButtonSound()
                        onRestart()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            Text(localizationService.localizedString(for: .playAgain))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.3), Color.cyan.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.6), lineWidth: 2)
                                )
                        )
                        .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // 返回主畫面按鈕
                    Button(action: {
                        SoundService.shared.playButtonSound()
                        onBackToMain()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "house.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            Text(localizationService.localizedString(for: .backToMain))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                                )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            isAnimating = true
            // 自動保存分數（靜默保存，不顯示提醒）
            saveScoreSilently()
        }
    }
    
    // MARK: - 輔助方法
    
    private func saveScore() {
        let record = ScoreRecord(
            playerName: settingsVM.playerName,
            score: finalScore
        )
        
        // 本地儲存
        scoreVM.addScore(record)
        
        // Firebase 上傳
        FirebaseService.shared.uploadScore(record)
        
        showScoreSaved = true
    }
    
    private func saveScoreSilently() {
        let record = ScoreRecord(
            playerName: settingsVM.playerName,
            score: finalScore
        )
        
        // 本地儲存
        scoreVM.addScore(record)
        
        // Firebase 上傳
        FirebaseService.shared.uploadScore(record)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func getDifficultyText(_ difficulty: Double) -> String {
        switch difficulty {
        case 0.5: return localizationService.localizedString(for: .veryEasy)
        case 0.75: return localizationService.localizedString(for: .easy)
        case 1.0: return localizationService.localizedString(for: .normal)
        case 1.5: return localizationService.localizedString(for: .hard)
        case 2.0: return localizationService.localizedString(for: .veryHard)
        default: return localizationService.localizedString(for: .normal)
        }
    }
}

// MARK: - 統計卡片組件
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView(
            finalScore: 1250,
            playTime: 180.5,
            onRestart: {},
            onBackToMain: {}
        )
        .environmentObject(SettingsViewModel())
        .environmentObject(ScoreViewModel())
    }
} 