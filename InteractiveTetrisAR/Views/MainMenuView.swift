import SwiftUI

struct MainMenuView: View {
    @State private var showHandTutorial = false
    @State private var isAnimating = false
    @StateObject private var localizationService = LocalizationService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 动态背景
                AnimatedBackgroundView()
                
                VStack(spacing: 30) {
                    titleArea
                    Spacer()
                    mainButtons
                    Spacer()
                    bottomInfo
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isAnimating = true
            }
            .sheet(isPresented: $showHandTutorial) {
                HandGestureTutorialView()
            }
        }
    }
    
    // MARK: - 子區塊
    private var titleArea: some View {
        VStack(spacing: 10) {
            Text("Interactive")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .blue.opacity(0.8), radius: 10, x: 0, y: 5)
            
            Text("Tetris AR")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(.cyan)
                .shadow(color: .cyan.opacity(0.8), radius: 15, x: 0, y: 8)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            Text(localizationService.localizedString(for: .futureTechnologyRussianBlock))
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 5)
        }
        .padding(.top, 40)
    }
    
    private var mainButtons: some View {
        VStack(spacing: 25) {
            startGameButton
            settingsButton
            leaderboardButton
            tutorialButton
        }
        .padding(.horizontal, 30)
    }
    
    private var startGameButton: some View {
        NavigationLink(destination: HandGestureGameView()) {
            HStack(spacing: 15) {
                Image(systemName: "hand.raised.fill")
                    .font(.title)
                    .foregroundColor(.cyan)
                    .rotationEffect(.degrees(isAnimating ? 10 : -10))
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                VStack(alignment: .leading, spacing: 5) {
                    Text(localizationService.localizedString(for: .startGame))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(localizationService.localizedString(for: .startGameDescription))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.cyan)
            }
            .padding(20)
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
        .buttonStyle(PlainButtonStyle())
    }
    
    private var settingsButton: some View {
        NavigationLink(destination: SettingsView()) {
            HStack(spacing: 15) {
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(isAnimating ? 5 : -5))
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                VStack(alignment: .leading, spacing: 5) {
                    Text(localizationService.localizedString(for: .settings))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(localizationService.localizedString(for: .settingsDescription))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.red.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                    )
            )
            .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var leaderboardButton: some View {
        NavigationLink(destination: ScoreboardView()) {
            HStack(spacing: 15) {
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isAnimating)
                VStack(alignment: .leading, spacing: 5) {
                    Text(localizationService.localizedString(for: .leaderboard))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(localizationService.localizedString(for: .leaderboardDescription))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                    )
            )
            .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var tutorialButton: some View {
        Button(action: {
            showHandTutorial = true
        }) {
            HStack(spacing: 15) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.purple)
                    .scaleEffect(isAnimating ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: isAnimating)
                VStack(alignment: .leading, spacing: 5) {
                    Text(localizationService.localizedString(for: .tutorial))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(localizationService.localizedString(for: .tutorialDescription))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.6), lineWidth: 2)
                    )
            )
            .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var bottomInfo: some View {
        VStack(spacing: 8) {
            Text(localizationService.localizedString(for: .interactiveTetrisAR))
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            Text(localizationService.localizedString(for: .version) + " 1.0.0")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.bottom, 30)
    }
}

// 动态背景视图
struct AnimatedBackgroundView: View {
    @State private var phase = 0.0
    @State private var particles: [Particle] = []
    @State private var animationTimer: Timer?
    
    var body: some View {
        ZStack {
            // 基础渐变背景
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.02, green: 0.02, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 动态粒子效果
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.cyan.opacity(particle.opacity))
                    .frame(width: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .animation(.linear(duration: 0.1), value: particle.x)
                    .animation(.linear(duration: 0.1), value: particle.y)
            }
        }
        .onAppear {
            initializeParticles()
            startParticleAnimation()
        }
        .onDisappear {
            stopParticleAnimation()
        }
    }
    
    // MARK: - 粒子系統方法
    
    private func initializeParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        particles = (0..<25).map { _ in
            Particle(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight),
                size: CGFloat.random(in: 2...8),
                speedX: CGFloat.random(in: -30...30), // 每秒移動像素
                speedY: CGFloat.random(in: -20...20),
                opacity: Double.random(in: 0.2...0.6)
            )
        }
    }
    
    private func startParticleAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func stopParticleAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let deltaTime: CGFloat = 0.05 // 50ms
        
        for i in particles.indices {
            // 更新位置
            particles[i].x += particles[i].speedX * deltaTime
            particles[i].y += particles[i].speedY * deltaTime
            
            // 邊界檢查和反彈
            if particles[i].x <= 0 || particles[i].x >= screenWidth {
                particles[i].speedX *= -1
                particles[i].x = max(0, min(screenWidth, particles[i].x))
            }
            
            if particles[i].y <= 0 || particles[i].y >= screenHeight {
                particles[i].speedY *= -1
                particles[i].y = max(0, min(screenHeight, particles[i].y))
            }
            
            // 隨機改變透明度，創造閃爍效果
            if Double.random(in: 0...1) < 0.02 { // 2% 機率改變透明度
                particles[i].opacity = Double.random(in: 0.2...0.6)
            }
        }
    }
}

// MARK: - 粒子數據結構
struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speedX: CGFloat
    var speedY: CGFloat
    var opacity: Double
}
