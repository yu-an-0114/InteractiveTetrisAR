//
//  ScoreRowView.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

/// 分數列表中，每一列的視圖
struct ScoreRowView: View {
    let record: ScoreRecord
    @StateObject private var localizationService = LocalizationService.shared

    /// 日期格式化器
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.playerName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(dateFormatter.string(from: record.date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text("\(localizationService.localizedString(for: .score)): \(record.score)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.cyan)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ScoreRowView_Previews: PreviewProvider {
    static var previews: some View {
        DarkBackgroundView {
            VStack {
                ScoreRowView(record: ScoreRecord(playerName: "測試玩家", score: 1234, date: Date()))
                    .padding(.horizontal)
            }
            .padding(.top, 40)
        }
    }
}
