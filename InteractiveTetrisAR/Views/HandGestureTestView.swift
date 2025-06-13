import SwiftUI
import Vision
import RealityKit

struct HandGestureTestView: View {
    @StateObject private var handRecognitionService = HandRecognitionService()
    @Environment(\.dismiss) private var dismiss
    @State private var handPoints: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
    @State private var showHandOverlay = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    colors: [Color.darkGradientStart, Color.darkGradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 手部骨架覆蓋層
                if showHandOverlay && handRecognitionService.isHandDetected {
                    HandOverlay(joints: handPoints)
                        .stroke(Color.green, lineWidth: 3)
                        .opacity(0.8)
                        .edgesIgnoringSafeArea(.all)
                }
                
                VStack(spacing: 30) {
                    // 標題
                    Text("手部識別測試")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // 狀態指示器
                    VStack(spacing: 20) {
                        HStack {
                            Circle()
                                .fill(handRecognitionService.isHandDetected ? Color.green : Color.red)
                                .frame(width: 20, height: 20)
                            Text(handRecognitionService.isHandDetected ? "手部已檢測到" : "未檢測到手部")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Text("當前手勢: \(handRecognitionService.currentGesture.rawValue)")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        
                        Text("手掌X軸位置: \(handRecognitionService.palmXPosition)")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("手掌Z軸旋轉: \(String(format: "%.1f°", handRecognitionService.palmZRotation))")
                            .font(.title2)
                            .foregroundColor(.cyan)
                        
                        Text("檢測置信度: \(String(format: "%.2f", handRecognitionService.detectionConfidence))")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("檢測到的關節點: \(handPoints.count)")
                            .font(.title2)
                            .foregroundColor(.purple)
                        
                        // 調試信息
                        Text(handRecognitionService.debugInfo)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // X 軸控制區域指示
                        HStack {
                            Text("左移區域(1-3): ")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(handRecognitionService.palmXPosition <= 3 ? "●" : "○")
                                .font(.title2)
                                .foregroundColor(handRecognitionService.palmXPosition <= 3 ? .green : .gray)
                            
                            Text("中間區域(4-7): ")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(handRecognitionService.palmXPosition >= 4 && handRecognitionService.palmXPosition <= 7 ? "●" : "○")
                                .font(.title2)
                                .foregroundColor(handRecognitionService.palmXPosition >= 4 && handRecognitionService.palmXPosition <= 7 ? .yellow : .gray)
                            
                            Text("右移區域(8-10): ")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(handRecognitionService.palmXPosition >= 8 ? "●" : "○")
                                .font(.title2)
                                .foregroundColor(handRecognitionService.palmXPosition >= 8 ? .green : .gray)
                        }
                        
                        // Z 軸旋轉指示
                        HStack {
                            Text("左旋轉(<-15°): ")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(handRecognitionService.palmZRotation < -15 ? "●" : "○")
                                .font(.title2)
                                .foregroundColor(handRecognitionService.palmZRotation < -15 ? .green : .gray)
                            
                            Text("無旋轉(-15°~15°): ")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(handRecognitionService.palmZRotation >= -15 && handRecognitionService.palmZRotation <= 15 ? "●" : "○")
                                .font(.title2)
                                .foregroundColor(handRecognitionService.palmZRotation >= -15 && handRecognitionService.palmZRotation <= 15 ? .yellow : .gray)
                            
                            Text("右旋轉(>15°): ")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(handRecognitionService.palmZRotation > 15 ? "●" : "○")
                                .font(.title2)
                                .foregroundColor(handRecognitionService.palmZRotation > 15 ? .green : .gray)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                    
                    // 手勢說明
                    VStack(spacing: 15) {
                        Text("測試手勢")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("• 手掌左右移動 → 觀察X軸位置變化")
                            Text("• 左側區域(1-3) → 方塊左移")
                            Text("• 中間區域(4-7) → 方塊不移動")
                            Text("• 右側區域(8-10) → 方塊右移")
                            Text("• 手掌向左旋轉(<-30°) → 方塊逆時針旋轉")
                            Text("• 手掌向右旋轉(>30°) → 方塊順時針旋轉")
                            Text("• 手掌保持水平(-30°~30°) → 無旋轉動作")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                    }
                    
                    // 控制按鈕
                    HStack {
                        Button(action: {
                            showHandOverlay.toggle()
                        }) {
                            HStack {
                                Image(systemName: showHandOverlay ? "eye.fill" : "eye.slash.fill")
                                Text(showHandOverlay ? "隱藏骨架" : "顯示骨架")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange.opacity(0.8))
                            .cornerRadius(12)
                        }
                        
                        Spacer()
                        
                        // 測試旋轉按鈕
                        Button(action: {
                            print("🧪 手動測試旋轉")
                            
                            // 檢查當前手勢
                            print("🧪 當前手勢: \(handRecognitionService.currentGesture.rawValue)")
                            
                            // 檢查遊戲動作
                            if let action = handRecognitionService.getGameAction() {
                                print("🧪 手動測試 - 遊戲動作: \(action)")
                            } else {
                                print("🧪 手動測試 - 無遊戲動作")
                            }
                        }) {
                            HStack {
                                Image(systemName: "rotate.3d")
                                Text("測試旋轉")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple.opacity(0.8))
                            .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                    
                    // 控制按鈕
                    VStack(spacing: 15) {
                        Button(action: {
                            handRecognitionService.startRecognition()
                        }) {
                            Text("開始識別")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            handRecognitionService.stopRecognition()
                        }) {
                            Text("停止識別")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("返回")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            handRecognitionService.startRecognition()
            // 監聽手部點位變化
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                handPoints = handRecognitionService.getHandPoints()
            }
        }
        .onDisappear {
            handRecognitionService.stopRecognition()
        }
    }
}

#Preview {
    HandGestureTestView()
} 
 