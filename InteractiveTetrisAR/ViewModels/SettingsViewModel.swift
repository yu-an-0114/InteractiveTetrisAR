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
    private let soundService = SoundService.shared
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
        // 檢查是否為首次安裝
        let isFirstInstall = UserDefaults.standard.object(forKey: "GameSettings") == nil
        
        if isFirstInstall {
            // 首次安裝：使用預設值，音樂開啟
            self.playerName = "Player"
            self.isSoundOn = true
            self.isHapticsOn = true
            self.isMusicOn = true // 強制音樂開啟
            self.selectedTheme = .default
            self.gestureSensitivity = 1.0
            
            // 立即保存預設設定到本地
            let defaultData = SettingsData(
                playerName: "Player",
                isSoundOn: true,
                isHapticsOn: true,
                isMusicOn: true,
                selectedTheme: .default,
                gestureSensitivity: 1.0
            )
            service.save(defaultData)
            
            print("🔊 首次安裝，音樂已預設開啟並保存到本地")
        } else {
            // 非首次安裝：從本地載入，但確保音樂開啟
            let data = service.load()
            self.playerName = data.playerName
            self.isSoundOn = data.isSoundOn
            self.isHapticsOn = data.isHapticsOn
            self.isMusicOn = true // 強制音樂開啟，不管本地設定如何
            self.selectedTheme = data.selectedTheme
            self.gestureSensitivity = data.gestureSensitivity
            
            // 如果本地設定中音樂是關閉的，更新本地設定
            if !data.isMusicOn {
                let updatedData = SettingsData(
                    playerName: data.playerName,
                    isSoundOn: data.isSoundOn,
                    isHapticsOn: data.isHapticsOn,
                    isMusicOn: true, // 強制開啟
                    selectedTheme: data.selectedTheme,
                    gestureSensitivity: data.gestureSensitivity
                )
                service.save(updatedData)
                print("🔊 檢測到音樂設定為關閉，已強制重置為開啟")
            }
        }
        
        // 載入語言設定
        self.currentLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "繁體中文"

        // 初始化音效服務設定
        soundService.setEnabled(isSoundOn)
        soundService.setMusicEnabled(isMusicOn)

        // 監聽本地更動並自動儲存到 UserDefaults
        setupLocalBindings()
    }

    private func setupLocalBindings() {
        $playerName
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)

        $isSoundOn
            .sink { [weak self] enabled in 
                self?.service.save(self!.currentData)
                self?.soundService.setEnabled(enabled)
            }
            .store(in: &cancellables)

        $isHapticsOn
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)

        $isMusicOn
            .sink { [weak self] enabled in 
                self?.service.save(self!.currentData)
                self?.soundService.setMusicEnabled(enabled)
            }
            .store(in: &cancellables)

        $selectedTheme
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)

        $gestureSensitivity
            .sink { [weak self] _ in self?.service.save(self!.currentData) }
            .store(in: &cancellables)
            
        $currentLanguage
            .sink { [weak self] _ in 
                // 語言設定保存到 UserDefaults
                UserDefaults.standard.set(self!.currentLanguage, forKey: "SelectedLanguage")
            }
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
            
            // 檢查是否為首次安裝
            let isFirstInstall = UserDefaults.standard.object(forKey: "GameSettings") == nil
            
            DispatchQueue.main.async {
                // 如果是首次安裝，保持音樂開啟
                let musicSetting = isFirstInstall ? true : data.isMusicOn
                
                self?.playerName = data.playerName
                self?.isSoundOn = data.isSoundOn
                self?.isHapticsOn = data.isHapticsOn
                self?.isMusicOn = musicSetting
                self?.selectedTheme = data.selectedTheme
                self?.gestureSensitivity = data.gestureSensitivity
                
                // 更新音效服務設定
                self?.soundService.setEnabled(data.isSoundOn)
                self?.soundService.setMusicEnabled(musicSetting)
                
                // 本地同步儲存
                let updatedData = SettingsData(
                    playerName: data.playerName,
                    isSoundOn: data.isSoundOn,
                    isHapticsOn: data.isHapticsOn,
                    isMusicOn: musicSetting,
                    selectedTheme: data.selectedTheme,
                    gestureSensitivity: data.gestureSensitivity
                )
                self?.service.save(updatedData)
                completion()
            }
        }
    }
}
