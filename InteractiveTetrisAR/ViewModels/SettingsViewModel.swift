//
//  SettingsViewModel.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import Foundation
import Combine

/// 管理使用者設定：本地與 Firebase 同步
final class SettingsViewModel: ObservableObject {
    // MARK: - Published 屬性（供 View 綁定）
    @Published var playerName: String
    @Published var isSoundOn: Bool
    @Published var isHapticsOn: Bool
    @Published var isMusicOn: Bool
    @Published var selectedTheme: AppTheme
    @Published var gestureSensitivity: Double

    private let service = SettingsService()
    private var cancellables = Set<AnyCancellable>()
    @Published var availableLanguages: [String] = [
        "繁體中文",
        "English",
        "日本語"
    ]
    @Published var currentLanguage: String = "繁體中文"

    /// 目前的 SettingsData
    var currentData: SettingsData {
        SettingsData(
            playerName: playerName,
            isSoundOn: isSoundOn,
            isHapticsOn: isHapticsOn,
            isMusicOn: isMusicOn,
            selectedTheme: selectedTheme,
            gestureSensitivity: gestureSensitivity
        )
    }

    init() {
        // 從本地（UserDefaults）載入，如果 Firebase 有更新可再同步
        let data = service.load()
        self.playerName = data.playerName
        self.isSoundOn = data.isSoundOn
        self.isHapticsOn = data.isHapticsOn
        self.isMusicOn = data.isMusicOn
        self.selectedTheme = data.selectedTheme
        self.gestureSensitivity = data.gestureSensitivity

        // 監聽本地更動並自動儲存到 UserDefaults
        setupLocalBindings()
    }

    private func setupLocalBindings() {
        $playerName
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)

        $isSoundOn
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)

        $isHapticsOn
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)

        $isMusicOn
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)

        $selectedTheme
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)

        $gestureSensitivity
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)
    }

    /// 儲存至本地（已由綁定自動處理），並且推送到 Firebase
    func saveSettings() {
        // 本地已經自動存入 UserDefaults，這邊只需同步到 Firebase
        FirebaseService.shared.updateUserSettings(currentData)
    }

    /// 從 Firebase 載入使用者設定（若存在）
    func loadFromFirebase(completion: @escaping () -> Void = {}) {
        FirebaseService.shared.fetchUserSettings { [weak self] data in
            guard let data = data else {
                completion()
                return
            }
            DispatchQueue.main.async {
                self?.playerName = data.playerName
                self?.isSoundOn = data.isSoundOn
                self?.isHapticsOn = data.isHapticsOn
                self?.isMusicOn = data.isMusicOn
                self?.selectedTheme = data.selectedTheme
                self?.gestureSensitivity = data.gestureSensitivity
                // 本地同步儲存
                self?.service.save(data)
                completion()
            }
        }
    }
}
