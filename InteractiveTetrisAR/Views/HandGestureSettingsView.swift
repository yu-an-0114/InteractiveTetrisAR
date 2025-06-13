import SwiftUI

struct HandGestureSettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationService = LocalizationService.shared
    
    @State private var pinchDistanceThreshold: Double = 0.06
    @State private var fistDistanceThreshold: Double = 0.15
    @State private var fingerExtensionThreshold: Double = 0.7
    @State private var gestureChangeCooldown: Double = 0.8
    @State private var minConfidenceThreshold: Double = 4
    
    var body: some View {
        NavigationView {
            ZStack {
                // 動態背景
                AnimatedBackgroundView()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 標題
                        VStack(spacing: 10) {
                            Text(localizationService.localizedString(for: .handGestureSettings))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .green.opacity(0.8), radius: 10, x: 0, y: 5)
                            
                            Text("調整手勢識別參數")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 40)
                        
                        // 手勢靈敏度設定
                        VStack(spacing: 15) {
                            Text(localizationService.localizedString(for: .gestureSensitivity))
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Slider(value: $settingsVM.gestureSensitivity, in: 0.5...2.0, step: 0.1)
                                .accentColor(.purple)
                            
                            HStack {
                                Text("低")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("高")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .font(.caption)
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                        
                        // 捏合距離閾值
                        SettingSliderCard(
                            title: "捏合距離閾值",
                            value: $pinchDistanceThreshold,
                            range: 0.02...0.15,
                            description: "控制食指與拇指觸碰的識別距離"
                        )
                        
                        // 握拳距離閾值
                        SettingSliderCard(
                            title: "握拳距離閾值",
                            value: $fistDistanceThreshold,
                            range: 0.08...0.25,
                            description: "控制握拳手勢的識別距離"
                        )
                        
                        // 手指伸展閾值
                        SettingSliderCard(
                            title: "手指伸展閾值",
                            value: $fingerExtensionThreshold,
                            range: 0.5...0.9,
                            description: "控制手指伸展程度的識別"
                        )
                        
                        // 手勢切換冷卻時間
                        SettingSliderCard(
                            title: "手勢切換冷卻時間",
                            value: $gestureChangeCooldown,
                            range: 0.3...1.5,
                            description: "防止手勢快速切換的冷卻時間"
                        )
                        
                        // 最小置信度閾值
                        SettingSliderCard(
                            title: "最小置信度閾值",
                            value: $minConfidenceThreshold,
                            range: 2...8,
                            description: "手勢識別的最小置信度要求"
                        )
                        
                        // 重置按鈕
                        Button(action: {
                            resetToDefaults()
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.title3)
                                Text("重置為預設值")
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
                                    .fill(Color.green.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green.opacity(0.6), lineWidth: 2)
                                    )
                            )
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func resetToDefaults() {
        settingsVM.gestureSensitivity = 1.0
        pinchDistanceThreshold = 0.06
        fistDistanceThreshold = 0.15
        fingerExtensionThreshold = 0.7
        gestureChangeCooldown = 0.8
        minConfidenceThreshold = 4
    }
}

struct SettingSliderCard: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(6)
            }
            
            Slider(value: $value, in: range, step: 0.01)
                .accentColor(.purple)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    HandGestureSettingsView()
        .environmentObject(SettingsViewModel())
} 