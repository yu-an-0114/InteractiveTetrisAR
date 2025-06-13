import Foundation
import AVFoundation
import AudioToolbox
import UIKit

/// 音效服務，負責處理遊戲中的音效播放
class SoundService: ObservableObject {
    static let shared = SoundService()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var isEnabled: Bool = true
    private var isMusicEnabled: Bool = true
    
    private init() {
        setupAudioSession()
    }
    
    /// 設置音頻會話
    private func setupAudioSession() {
        do {
            // 使用安全的音頻會話設置
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("🔊 音頻會話設置失敗: \(error)")
        }
    }
    
    /// 設置音效開關
    /// - Parameter enabled: 是否啟用音效
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            stopAllSounds()
        }
    }
    
    /// 設置背景音樂開關
    /// - Parameter enabled: 是否啟用背景音樂
    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        if !enabled {
            stopBackgroundMusic()
        } else if backgroundMusicPlayer == nil {
            // 如果重新啟用且沒有播放器，嘗試播放背景音樂
            playBackgroundMusic()
        }
    }
    
    /// 播放背景音樂
    func playBackgroundMusic() {
        guard isMusicEnabled else { return }
        
        // 停止現有的背景音樂
        stopBackgroundMusic()
        
        // 嘗試載入背景音樂文件
        let musicFileName = "WE HAVE RETURNED - DARTH MALGUS X OLD REPUBLIC THEME EDM REMIX - STAR WARS MUSIC VIDEO"
        if let url = Bundle.main.url(forResource: musicFileName, withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1 // 無限循環
                backgroundMusicPlayer?.volume = 0.15 // 降低音量到15%
                backgroundMusicPlayer?.prepareToPlay()
                
                // 安全播放
                DispatchQueue.main.async {
                    self.backgroundMusicPlayer?.play()
                }
            } catch {
                print("🔊 播放背景音樂失敗: \(error)")
            }
        }
    }
    
    /// 停止背景音樂
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
    
    /// 暫停背景音樂
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    /// 恢復背景音樂
    func resumeBackgroundMusic() {
        if isMusicEnabled && backgroundMusicPlayer != nil {
            backgroundMusicPlayer?.play()
        }
    }
    
    /// 播放音效
    /// - Parameter soundName: 音效名稱
    func playSound(_ soundName: String) {
        guard isEnabled else { return }
        
        // 如果已經有播放器在播放這個音效，先停止
        if let existingPlayer = audioPlayers[soundName] {
            existingPlayer.stop()
        }
        
        // 嘗試從Bundle載入音效文件
        if let url = Bundle.main.url(forResource: soundName, withExtension: "wav") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 0.8 // 設置音效音量為80%
                player.prepareToPlay()
                
                // 安全播放
                DispatchQueue.main.async {
                    player.play()
                }
                audioPlayers[soundName] = player
            } catch {
                // 如果載入失敗，使用系統音效作為備用
                playSystemSound(soundName)
            }
        } else {
            // 如果找不到音效文件，使用系統音效作為備用
            playSystemSound(soundName)
        }
    }
    
    /// 播放系統音效作為備用
    /// - Parameter soundName: 音效名稱
    private func playSystemSound(_ soundName: String) {
        switch soundName {
        case "move", "rotate":
            AudioServicesPlaySystemSound(1104) // 輕微點擊
        case "land":
            AudioServicesPlaySystemSound(1105) // 較重點擊
        case "clear":
            AudioServicesPlaySystemSound(1106) // 簡潔成功
        case "gameover":
            AudioServicesPlaySystemSound(1107) // 錯誤音效
        case "button":
            AudioServicesPlaySystemSound(1104) // 輕微點擊
        default:
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    /// 播放方塊移動音效
    func playMoveSound() {
        playSound("move")
    }
    
    /// 播放方塊旋轉音效
    func playRotateSound() {
        playSound("rotate")
    }
    
    /// 播放方塊落地音效
    func playLandSound() {
        playSound("land")
    }
    
    /// 播放消行音效
    func playClearSound() {
        playSound("clear")
    }
    
    /// 播放遊戲結束音效
    func playGameOverSound() {
        playSound("gameover")
    }
    
    /// 播放按鈕點擊音效
    func playButtonSound() {
        playSound("button")
    }
    
    /// 停止所有音效
    func stopAllSounds() {
        for player in audioPlayers.values {
            player.stop()
        }
        audioPlayers.removeAll()
    }
    
    /// 停止特定音效
    /// - Parameter soundName: 音效名稱
    func stopSound(_ soundName: String) {
        audioPlayers[soundName]?.stop()
        audioPlayers.removeValue(forKey: soundName)
    }
}

// MARK: - 音效擴展
extension SoundService {
    /// 播放震動回饋（如果設備支持）
    func playVibration() {
        guard isEnabled else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    /// 播放成功震動
    func playSuccessVibration() {
        guard isEnabled else { return }
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// 播放錯誤震動
    func playErrorVibration() {
        guard isEnabled else { return }
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.error)
    }
} 