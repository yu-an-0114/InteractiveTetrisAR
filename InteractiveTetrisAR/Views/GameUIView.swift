import SwiftUI

/// 遊戲UI覆蓋層，具有太空科幻風格
struct GameUIView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @StateObject private var localizationService = LocalizationService.shared
    
    let score: Int
    let playTime: TimeInterval
    let isPaused: Bool
    let isHandDetected: Bool
    let currentGesture: String
    let nextTetromino: Tetromino?
    let showHandOverlay: Bool
    
    let onPauseResume: () -> Void
    let onToggleHandOverlay: () -> Void
    let onShowTutorial: () -> Void
    
    @State private var isAnimating = false
    @State private var scoreScale: CGFloat = 1.0
    @State private var showScoreEffect = false
    @State private var lastScore: Int = 0
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack {
            // 頂部狀態欄 - 往上移動
            topStatusBar
            
            Spacer()
            
            // 右側資訊面板
            HStack {
                Spacer()
                
                // 下一個方塊預覽
                if let next = nextTetromino {
                    VStack(spacing: 12) {
                        Text(localizationService.localizedString(for: .next))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.cyan)
                            .shadow(color: .cyan.opacity(0.8), radius: 4, x: 0, y: 2)
                        
                        NextTetromino2Preview(tetromino: next)
                            .frame(width: 90, height: 90)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.cyan.opacity(0.8), Color.blue.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .shadow(color: .cyan.opacity(0.4), radius: 12, x: 0, y: 6)
                            .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
                    }
                    .padding(.trailing, 20)
                }
            }
            .padding(.top, 100)
            
            Spacer()
            
            // 底部控制區域
            bottomControlArea
        }
        .onAppear {
            isAnimating = true
            pulseAnimation = true
            lastScore = score
        }
        .onChange(of: score) { newScore in
            // 當分數增加時，觸發動畫效果
            if newScore > lastScore {
                triggerScoreEffect()
            }
            lastScore = newScore
        }
    }
    
    // MARK: - 頂部狀態欄
    private var topStatusBar: some View {
        VStack(spacing: 15) {
            // 手勢狀態顯示 - 移到最上方
            HStack(spacing: 10) {
                // 手部檢測指示器
                HStack(spacing: 8) {
                    Circle()
                        .fill(isHandDetected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                        .scaleEffect(isAnimating ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text(isHandDetected ? "手部已檢測" : "未檢測到手部")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(isHandDetected ? .green : .red)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isHandDetected ? Color.green.opacity(0.6) : Color.red.opacity(0.6), lineWidth: 1)
                        )
                )
                
                Spacer()
                
                // 當前手勢
                Text(currentGesture)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.cyan.opacity(0.8), lineWidth: 2)
                            )
                    )
                    .shadow(color: .cyan.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 分數和時間顯示
            HStack(spacing: 20) {
                // 分數顯示
                EnhancedStatusCard(
                    icon: "star.fill",
                    title: localizationService.localizedString(for: .score),
                    value: "\(score)",
                    color: .yellow,
                    gradient: [Color.yellow.opacity(0.8), Color.orange.opacity(0.6)]
                )
                .scaleEffect(scoreScale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scoreScale)
                
                Spacer()
                
                // 時間顯示
                EnhancedStatusCard(
                    icon: "clock.fill",
                    title: localizationService.localizedString(for: .time),
                    value: formatTime(playTime),
                    color: .green,
                    gradient: [Color.green.opacity(0.8), Color.cyan.opacity(0.6)]
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - 底部控制區域
    private var bottomControlArea: some View {
        VStack(spacing: 25) {
            // 控制按鈕 - 只保留暫停按鈕
            HStack(spacing: 40) {
                // 暫停按鈕
                EnhancedControlButton(
                    icon: isPaused ? "play.fill" : "pause.fill",
                    color: isPaused ? .green : .orange,
                    gradient: isPaused ? [Color.green.opacity(0.8), Color.cyan.opacity(0.6)] : [Color.orange.opacity(0.8), Color.red.opacity(0.6)],
                    action: onPauseResume
                )
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 輔助方法
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func triggerScoreEffect() {
        // 觸發分數增加動畫效果
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scoreScale = 1.4
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scoreScale = 1.0
            }
        }
        
        // 顯示分數效果
        showScoreEffect = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showScoreEffect = false
        }
    }
}

// MARK: - 增強狀態卡片組件
struct EnhancedStatusCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let gradient: [Color]
    
    @State private var isGlowing = false
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.8), radius: 4, x: 0, y: 2)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.8), radius: 6, x: 0, y: 3)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        .scaleEffect(isGlowing ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isGlowing)
        .onAppear {
            isGlowing = true
        }
    }
}

// MARK: - 增強控制按鈕組件
struct EnhancedControlButton: View {
    let icon: String
    let color: Color
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    private let soundService = SoundService.shared
    
    var body: some View {
        Button(action: {
            isPressed = true
            soundService.playButtonSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [color.opacity(0.8), color.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                )
                .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
                .scaleEffect(isPressed ? 0.9 : (isHovered ? 1.1 : 1.0))
                .animation(.easeInOut(duration: 0.2), value: isPressed)
                .animation(.easeInOut(duration: 0.3), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - 保留原有組件以兼容性
struct StatusCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        EnhancedStatusCard(
            icon: icon,
            title: title,
            value: value,
            color: color,
            gradient: [color.opacity(0.8), color.opacity(0.6)]
        )
    }
}

struct ControlButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        EnhancedControlButton(
            icon: icon,
            color: color,
            gradient: [color.opacity(0.8), color.opacity(0.6)],
            action: action
        )
    }
}

struct GameUIView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            GameUIView(
                score: 1250,
                playTime: 180.5,
                isPaused: false,
                isHandDetected: true,
                currentGesture: "Move Right",
                nextTetromino: Tetromino(type: .I),
                showHandOverlay: true,
                onPauseResume: {},
                onToggleHandOverlay: {},
                onShowTutorial: {}
            )
        }
        .environmentObject(SettingsViewModel())
    }
}

// MARK: - 暫停選單視圖
struct PauseMenuView: View {
    let showHandOverlay: Bool
    let onResume: () -> Void
    let onBackToMain: () -> Void
    let onToggleHandOverlay: () -> Void
    let onShowTutorial: () -> Void
    
    @StateObject private var localizationService = LocalizationService.shared
    @State private var isAnimating = false
    private let soundService = SoundService.shared
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // 暫停選單內容
            VStack(spacing: 25) {
                // 標題
                VStack(spacing: 10) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 60, weight: .light, design: .rounded))
                        .foregroundColor(.orange)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("遊戲暫停")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .orange.opacity(0.8), radius: 10, x: 0, y: 5)
                }
                
                // 按鈕選項
                VStack(spacing: 15) {
                    // 繼續遊戲按鈕
                    PauseMenuButton(
                        icon: "play.fill",
                        title: "繼續遊戲",
                        color: .green,
                        gradient: [Color.green.opacity(0.8), Color.cyan.opacity(0.6)],
                        action: {
                            soundService.playButtonSound()
                            onResume()
                        }
                    )
                    
                    // 手部覆蓋開關按鈕
                    PauseMenuButton(
                        icon: showHandOverlay ? "eye.fill" : "eye.slash.fill",
                        title: showHandOverlay ? "隱藏手部骨架" : "顯示手部骨架",
                        color: showHandOverlay ? .blue : .gray,
                        gradient: showHandOverlay ? [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)] : [Color.gray.opacity(0.6), Color.black.opacity(0.4)],
                        action: {
                            soundService.playButtonSound()
                            onToggleHandOverlay()
                        }
                    )
                    
                    // 教學按鈕
                    PauseMenuButton(
                        icon: "questionmark.circle.fill",
                        title: "遊戲說明",
                        color: .purple,
                        gradient: [Color.purple.opacity(0.8), Color.pink.opacity(0.6)],
                        action: {
                            soundService.playButtonSound()
                            onShowTutorial()
                        }
                    )
                    
                    // 返回主選單按鈕
                    PauseMenuButton(
                        icon: "house.fill",
                        title: "返回主選單",
                        color: .red,
                        gradient: [Color.red.opacity(0.8), Color.orange.opacity(0.6)],
                        action: {
                            soundService.playButtonSound()
                            onBackToMain()
                        }
                    )
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.8), Color.black.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.8), Color.yellow.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
            )
            .shadow(color: .orange.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - 暫停選單按鈕組件
struct PauseMenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [color.opacity(0.8), color.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.05 : 1.0))
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .animation(.easeInOut(duration: 0.3), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
} 