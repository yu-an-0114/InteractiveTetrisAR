import SwiftUI

struct HandGestureTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationService = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // 動態背景
                AnimatedBackgroundView()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 標題區域
                        VStack(spacing: 10) {
                            Text(localizationService.localizedString(for: .handTutorial))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .cyan.opacity(0.8), radius: 10, x: 0, y: 5)
                            
                            Text("學習手勢控制技巧")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 40)
                        
                        // 手勢說明
                        VStack(spacing: 20) {
                            // 移動控制
                            GestureInstructionCard(
                                icon: "🎮",
                                title: localizationService.localizedString(for: .moveControl),
                                instructions: [
                                    "• 手掌左右移動控制方塊左右移動",
                                    "• 左側區域(1-4)：方塊向左移動",
                                    "• 中間區域(5-6)：方塊不移動",
                                    "• 右側區域(7-10)：方塊向右移動"
                                ],
                                color: .blue
                            )
                            
                            // 旋轉控制
                            GestureInstructionCard(
                                icon: "🔄",
                                title: localizationService.localizedString(for: .rotationControl),
                                instructions: [
                                    "• 手掌向左旋轉(超過40°)：方塊逆時針旋轉",
                                    "• 手掌向右旋轉(超過40°)：方塊順時針旋轉",
                                    "• 手掌保持水平(-40°~40°)：無旋轉動作",
                                    "• 需要先恢復到正常角度才能再次旋轉"
                                ],
                                color: .green
                            )
                            
                            // 快速下降
                            GestureInstructionCard(
                                icon: "🤏",
                                title: localizationService.localizedString(for: .quickDrop),
                                instructions: [
                                    "• 手指併攏：所有指尖點距離中心小於0.07",
                                    "• 手掌位置：必須在中間區域(3-7)",
                                    "• 同時滿足以上條件觸發快速下降"
                                ],
                                color: .yellow
                            )
                            
                            // 使用技巧
                            GestureInstructionCard(
                                icon: "💡",
                                title: localizationService.localizedString(for: .tips),
                                instructions: [
                                    "• 保持手掌在攝像頭視野內",
                                    "• 手掌移動要平滑，避免突然動作",
                                    "• 旋轉時保持手掌穩定",
                                    "• 手指併攏時要確保所有指尖都靠近",
                                    "• 可以通過測試頁面練習手勢"
                                ],
                                color: .purple
                            )
                        }
                        .padding(.horizontal, 30)
                        
                        // 開始遊戲按鈕
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.cyan)
                                
                                Text(localizationService.localizedString(for: .startGame))
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
                                            colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.cyan.opacity(0.6), lineWidth: 2)
                                    )
                            )
                            .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 手勢說明卡片組件
struct GestureInstructionCard: View {
    let icon: String
    let title: String
    let instructions: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.title)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(instructions, id: \.self) { instruction in
                    Text(instruction)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                }
            }
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
                        .stroke(color.opacity(0.6), lineWidth: 2)
                )
        )
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HandGestureTutorialView()
} 