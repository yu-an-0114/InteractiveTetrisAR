//
//  GameARViewCoordinator.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation
import SwiftUI
import RealityKit
import ARKit
import Combine

/// SwiftUI 包裝 RealityKit 的 ARView，並由 Coordinator 負責手勢與 3D 方塊同步
struct GameARView: UIViewRepresentable {
    @ObservedObject var gameVM: GameViewModel
    let difficulty: Double   // 用於設定自動下墜速度或手勢靈敏度
    @Binding var coordinator: GameARView.Coordinator?

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(gameVM: gameVM, difficulty: difficulty)
        DispatchQueue.main.async {
            self.coordinator = coordinator
        }
        return coordinator
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // 1. 配置 AR Session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)

        // 2. 建立 AnchorEntity 作為方塊父節點，放在鏡頭前方 0.5 公尺
        let anchor = AnchorEntity(world: [0, 0, -0.5])
        arView.scene.addAnchor(anchor)
        context.coordinator.boardAnchor = anchor

        // 3. 註冊手勢：水平拖曳、向下滑、旋轉
        registerGestures(on: arView, coordinator: context.coordinator)

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

    // MARK: - 手勢註冊
    private func registerGestures(on arView: ARView, coordinator: Coordinator) {
        // 1. 水平拖曳 (Pan) → 左右移動
        let panGesture = UIPanGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePan(_:)))
        arView.addGestureRecognizer(panGesture)

        // 2. 向下滑 (Swipe down) → 向下移動一格
        let swipeDown = UISwipeGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleSwipeDown(_:)))
        swipeDown.direction = .down
        arView.addGestureRecognizer(swipeDown)

        // 3. 旋轉手勢 (Rotation) → 左／右旋轉
        let rotationGesture = UIRotationGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleRotation(_:)))
        arView.addGestureRecognizer(rotationGesture)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject {
        var gameVM: GameViewModel
        let difficulty: Double

        /// AnchorEntity 作為所有方塊的父節點
        weak var boardAnchor: AnchorEntity?

        private var cancellables = Set<AnyCancellable>()

        /// 已顯示在 AR 場景中的方塊實體 (鎖定方塊)
        private var blockEntities: [UUID: ModelEntity] = [:]

        /// 目前顯示的活動方塊 (currentTetromino) 的 ModelEntity 陣列
        private var currentTetrominoEntities: [ModelEntity] = []

        init(gameVM: GameViewModel, difficulty: Double) {
            self.gameVM = gameVM
            self.difficulty = difficulty
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

        // MARK: - 手勢處理

        /// 水平拖曳：偵測 translation.x，大於閾值則左右移動
        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            let translation = sender.translation(in: arView)
            let threshold: CGFloat = 20.0 * CGFloat(difficulty)

            if abs(translation.x) > threshold {
                if translation.x > 0 {
                    gameVM.moveRight()
                } else {
                    gameVM.moveLeft()
                }
                sender.setTranslation(.zero, in: arView)
            }
        }

        /// 向下滑動：觸發方塊往下移動一格
        @objc func handleSwipeDown(_ sender: UISwipeGestureRecognizer) {
            gameVM.moveDown()
        }

        /// 旋轉手勢結束時：根據 rotation 正／負值來判斷順時針或逆時針
        @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
            if sender.state == .ended {
                let angle = sender.rotation
                if angle > 0 {
                    gameVM.rotateRight()
                } else {
                    gameVM.rotateLeft()
                }
                sender.rotation = 0
            }
        }
    }
}
