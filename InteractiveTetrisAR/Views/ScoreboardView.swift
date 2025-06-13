//
//  ScoreboardView.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct ScoreboardView: View {
    @EnvironmentObject var scoreVM: ScoreViewModel
    @StateObject private var localizationService = LocalizationService.shared
    @State private var isRefreshing = false

    var body: some View {
        DarkBackgroundView {
            VStack(spacing: 16) {
                SectionHeaderView(title: localizationService.localizedString(for: .leaderboard))
                    .padding(.top, 40)

                List {
                    ForEach(scoreVM.records.prefix(10)) { record in
                        ScoreRowView(record: record)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { idx in
                            let rec = scoreVM.records[idx]
                            scoreVM.deleteScore(rec)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await reloadFromFirebase()
                }

                Spacer()

                // 底部按鈕
                HStack(spacing: 20) {
                    Button(action: {
                        Task {
                            await reloadFromFirebase()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                            Text(localizationService.localizedString(for: .reload))
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                                )
                        )
                    }
                    .disabled(isRefreshing)

                    Button(action: {
                        // 返回主畫面
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "house.fill")
                                .font(.title3)
                            Text(localizationService.localizedString(for: .back))
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.6), lineWidth: 2)
                                )
                        )
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }

    private func reloadFromFirebase() async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        // 從 Firebase 重新載入分數
        scoreVM.fetchTopScores()
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView()
            .environmentObject(ScoreViewModel())
    }
}
