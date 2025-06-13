import SwiftUI
import Combine
import ARKit
import RealityKit
import Vision

/// 整合手部識別和 AR 遊戲的視圖
struct HandGestureGameView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var scoreVM: ScoreViewModel
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var handRecognitionService = HandRecognitionService()
    @StateObject private var localizationService = LocalizationService.shared
    @State private var showGameOver = false
    @State private var showTutorial = false
    @State private var showHandOverlay = true
    @State private var showPauseMenu = false
    @State private var handPoints: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
    @State private var coordinator: HandGestureARView.Coordinator?
    
    var body: some View {
        ZStack {
            // MARK: - AR 遊戲視圖（整合手部識別）
            HandGestureARView(
                gameVM: gameVM,
                handRecognitionService: handRecognitionService,
                difficulty: settingsVM.gestureSensitivity,
                handPoints: $handPoints,
                coordinator: $coordinator
            )
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - 手部骨架覆蓋層
            if showHandOverlay && handRecognitionService.isHandDetected {
                HandOverlay(joints: handPoints)
                    .stroke(Color.green, lineWidth: 3)
                    .opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // MARK: - 遊戲 UI 覆蓋層
            GameUIView(
                score: gameVM.score,
                playTime: gameVM.timer.elapsedTime,
                isPaused: gameVM.isPaused,
                isHandDetected: handRecognitionService.isHandDetected,
                currentGesture: handRecognitionService.currentGesture.rawValue,
                nextTetromino: gameVM.nextTetromino,
                showHandOverlay: showHandOverlay,
                onPauseResume: {
                    // 直接顯示暫停選單，不管遊戲狀態
                    gameVM.pauseGame()
                    showPauseMenu = true
                },
                onToggleHandOverlay: {
                    // 移除這個功能，移到暫停選單中
                },
                onShowTutorial: {
                    // 移除這個功能，移到暫停選單中
                }
            )
            
            // MARK: - 暫停選單
            if showPauseMenu {
                PauseMenuView(
                    showHandOverlay: showHandOverlay,
                    onResume: {
                        showPauseMenu = false
                        gameVM.resumeGame()
                    },
                    onBackToMain: {
                        showPauseMenu = false
                        // 使用更直接的方式返回主選單
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Constants.Notifications.navigateTo, object: "Main")
                        }
                    },
                    onToggleHandOverlay: {
                        showHandOverlay.toggle()
                    },
                    onShowTutorial: {
                        // 不關閉暫停選單，直接顯示教學
                        showTutorial = true
                    }
                )
            }
            
            // MARK: - 教學視圖（在暫停選單上方顯示）
            if showTutorial {
                ZStack {
                    // 半透明背景
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    // 教學內容
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showTutorial = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 4, x: 0, y: 2)
                            }
                            .padding(.trailing, 20)
                            .padding(.top, 20)
                        }
                        
                        Spacer()
                        
                        HandGestureTutorialView()
                            .frame(maxWidth: 400, maxHeight: 600)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.9))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.cyan.opacity(0.6), lineWidth: 2)
                                    )
                            )
                            .shadow(color: .cyan.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Spacer()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showGameOver) {
            GameOverView(
                finalScore: gameVM.score,
                playTime: gameVM.timer.elapsedTime,
                onRestart: {
                    showGameOver = false
                    // 清理AR場景中的方塊實體
                    coordinator?.clearAllBlocks()
                    gameVM.startGame()
                },
                onBackToMain: {
                    showGameOver = false
                    NotificationCenter.default.post(name: Constants.Notifications.navigateTo, object: "Main")
                }
            )
        }
        .navigationBarHidden(true) // 隱藏導航欄
        .navigationBarBackButtonHidden(true) // 隱藏返回按鈕
        .gesture(DragGesture().onChanged { _ in }) // 禁止右滑手勢
        .onAppear {
            // 設置遊戲難度
            gameVM.setDifficulty(settingsVM.gestureSensitivity)
            
            gameVM.startGame()
            handRecognitionService.startRecognition()
        }
        .onDisappear {
            handRecognitionService.stopRecognition()
        }
        .onChange(of: settingsVM.gestureSensitivity) { newDifficulty in
            // 當難度設定改變時，更新遊戲難度
            gameVM.setDifficulty(newDifficulty)
        }
        .onChange(of: gameVM.isGameOver) { isOver in
            if isOver {
                showGameOver = true
            }
        }
        .sheet(isPresented: $showTutorial) {
            HandGestureTutorialView()
        }
    }
}

/// 整合手部識別的 AR 視圖
struct HandGestureARView: UIViewRepresentable {
    @ObservedObject var gameVM: GameViewModel
    @ObservedObject var handRecognitionService: HandRecognitionService
    let difficulty: Double
    @Binding var handPoints: [VNHumanHandPoseObservation.JointName: CGPoint]
    @Binding var coordinator: HandGestureARView.Coordinator?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(gameVM: gameVM, handRecognitionService: handRecognitionService, difficulty: difficulty, handPoints: $handPoints)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 1. 配置 AR Session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        // 2. 建立 AnchorEntity 作為方塊父節點
        let anchor = AnchorEntity(world: [0, 0, -0.5])
        arView.scene.addAnchor(anchor)
        context.coordinator.boardAnchor = anchor
        
        // 3. 設置 AR Session 代理以處理手部識別
        arView.session.delegate = context.coordinator
        
        // 4. 綁定coordinator
        DispatchQueue.main.async {
            self.coordinator = context.coordinator
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 同步已鎖定與當前方塊
        context.coordinator.syncBlocks()
        context.coordinator.syncCurrentTetromino()
        
        // 更新coordinator綁定
        DispatchQueue.main.async {
            self.coordinator = context.coordinator
        }
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, ARSessionDelegate {
        var gameVM: GameViewModel
        var handRecognitionService: HandRecognitionService
        let difficulty: Double
        @Binding var handPoints: [VNHumanHandPoseObservation.JointName: CGPoint]
        
        /// AnchorEntity 作為所有方塊的父節點
        weak var boardAnchor: AnchorEntity?
        
        private var cancellables = Set<AnyCancellable>()
        
        /// 已顯示在 AR 場景中的方塊實體 (鎖定方塊)
        private var blockEntities: [UUID: ModelEntity] = [:]
        
        /// 目前顯示的活動方塊 (currentTetromino) 的 ModelEntity 陣列
        private var currentTetrominoEntities: [ModelEntity] = []
        
        // 添加移動防抖機制
        private var lastMoveTime: TimeInterval = 0
        private let moveCooldown: TimeInterval = 0.1 // 移動冷卻時間
        private var lastMoveAction: GameAction?
        
        init(gameVM: GameViewModel, handRecognitionService: HandRecognitionService, difficulty: Double, handPoints: Binding<[VNHumanHandPoseObservation.JointName: CGPoint]>) {
            self.gameVM = gameVM
            self.handRecognitionService = handRecognitionService
            self.difficulty = difficulty
            self._handPoints = handPoints
            super.init()
            
            // 監聽 placedBlocks 變化
            gameVM.$placedBlocks
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.syncBlocks()
                }
                .store(in: &cancellables)
            
            // 監聽 currentTetromino 變化
            gameVM.$currentTetromino
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.syncCurrentTetromino()
                }
                .store(in: &cancellables)
            
            // 監聽手部識別服務的變化
            handRecognitionService.$currentGesture
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.handleGameAction()
                }
                .store(in: &cancellables)
            
            // 監聽手掌位置變化
            handRecognitionService.$palmXPosition
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.handleGameAction()
                }
                .store(in: &cancellables)
        }
        
        // MARK: - ARSessionDelegate
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // 處理每一幀進行手部識別
            handRecognitionService.processFrame(frame)
            
            // 更新手部點位數據
            DispatchQueue.main.async {
                self.handPoints = self.handRecognitionService.getHandPoints()
            }
        }
        
        // MARK: - 遊戲動作處理
        private func handleGameAction() {
            guard let action = handRecognitionService.getGameAction() else { 
                print("🎮 無遊戲動作")
                return 
            }
            guard !gameVM.isPaused && !gameVM.isGameOver else { 
                print("🎮 遊戲暫停或結束，忽略動作: \(action)")
                return 
            }
            
            print("🎮 執行遊戲動作: \(action)")
            
            let currentTime = CACurrentMediaTime()
            
            // 為不同動作設置不同的防抖策略
            switch action {
            case .moveLeft, .moveRight:
                // 移動動作需要更頻繁的響應，但避免重複
                if currentTime - lastMoveTime < moveCooldown {
                    if let lastAction = lastMoveAction, lastAction == action {
                        print("🎮 忽略重複移動動作: \(action)")
                        return
                    }
                }
                lastMoveTime = currentTime
                lastMoveAction = action
                
            case .rotateLeft, .rotateRight:
                // 旋轉動作有手勢檢測器自己的防抖，這裡不需要額外防抖
                lastMoveAction = action
                
            case .moveDown:
                // 下降動作也需要防抖
                if currentTime - lastMoveTime < moveCooldown {
                    if let lastAction = lastMoveAction, lastAction == action {
                        print("🎮 忽略重複下降動作: \(action)")
                        return
                    }
                }
                lastMoveTime = currentTime
                lastMoveAction = action
            }
            
            switch action {
            case .moveLeft:
                gameVM.moveLeft()
                print("🎮 執行左移")
            case .moveRight:
                gameVM.moveRight()
                print("🎮 執行右移")
            case .moveDown:
                gameVM.moveDown()
                print("🎮 執行下降")
            case .rotateLeft:
                gameVM.rotateLeft()
                print("🎮 執行逆時針旋轉")
            case .rotateRight:
                gameVM.rotateRight()
                print("🎮 執行順時針旋轉")
            }
        }
        
        /// 同步已鎖定的方塊 (placedBlocks) 到 AR 場景
        func syncBlocks() {
            guard let anchor = boardAnchor else { return }
            
            // 獲取當前placedBlocks的ID集合
            let currentBlockIds = Set(gameVM.placedBlocks.map { $0.id })
            
            // 移除不再存在的方塊實體
            let blockIdsToRemove = blockEntities.keys.filter { !currentBlockIds.contains($0) }
            for blockId in blockIdsToRemove {
                if let entity = blockEntities[blockId] {
                    entity.removeFromParent()
                }
                blockEntities.removeValue(forKey: blockId)
            }
            
            // 添加新的方塊實體
            for block in gameVM.placedBlocks {
                // 如果尚未建立該方塊的 Entity，就建立並加入場景
                if blockEntities[block.id] == nil {
                    let mesh = MeshResource.generateBox(size: 0.05)
                    let material = SimpleMaterial(
                        color: UIColor(
                            red: CGFloat(block.color.x),
                            green: CGFloat(block.color.y),
                            blue: CGFloat(block.color.z),
                            alpha: CGFloat(block.color.w)
                        ),
                        roughness: 0.3,
                        isMetallic: false
                    )
                    let entity = ModelEntity(mesh: mesh, materials: [material])
                    entity.position = block.position
                    anchor.addChild(entity)
                    blockEntities[block.id] = entity
                }
            }
        }
        
        /// 同步當前正在下落的方塊 (currentTetromino) 到 AR 場景
        func syncCurrentTetromino() {
            guard let anchor = boardAnchor else { return }
            
            // 移除舊的臨時方塊實體
            currentTetrominoEntities.forEach { $0.removeFromParent() }
            currentTetrominoEntities.removeAll()
            
            // 如果沒有 currentTetromino，直接返回
            guard let tetro = gameVM.currentTetromino else { return }
            
            // 根據 tetro.blocks 與 gridPosition 計算每個小方塊的世界座標，並建立新的 ModelEntity
            let color = gameVM.randomColor(for: tetro.type)
            for (dr, dc) in tetro.blocks {
                let r = tetro.gridPosition.row - dr
                let c = tetro.gridPosition.col + dc
                let worldPos = gameVM.convertGridPositionToWorld(r: r, c: c)
                
                let mesh = MeshResource.generateBox(size: 0.05)
                let material = SimpleMaterial(
                    color: UIColor(
                        red: CGFloat(color.x),
                        green: CGFloat(color.y),
                        blue: CGFloat(color.z),
                        alpha: CGFloat(color.w)
                    ),
                    roughness: 0.2,
                    isMetallic: true
                )
                let entity = ModelEntity(mesh: mesh, materials: [material])
                entity.position = worldPos
                anchor.addChild(entity)
                currentTetrominoEntities.append(entity)
            }
        }
        
        /// 清理所有AR場景中的方塊實體
        func clearAllBlocks() {
            guard let anchor = boardAnchor else { return }
            
            // 移除所有鎖定的方塊實體
            for entity in blockEntities.values {
                entity.removeFromParent()
            }
            blockEntities.removeAll()
            
            // 移除當前活動方塊實體
            currentTetrominoEntities.forEach { $0.removeFromParent() }
            currentTetrominoEntities.removeAll()
        }
    }
}

#Preview {
    HandGestureGameView()
        .environmentObject(SettingsViewModel())
        .environmentObject(ScoreViewModel())
} 
 