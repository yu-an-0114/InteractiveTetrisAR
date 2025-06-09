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

    /// 日期格式化器
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        HStack {
            // 玩家名稱
            Text(record.playerName)
                .font(.body)
                .foregroundColor(.white)

            Spacer()

            // 得分
            Text("\(record.score)")
                .font(.headline)
                .foregroundColor(.yellow)

            Spacer()

            // 日期顯示
            Text(dateFormatter.string(from: record.date))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.15))
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
