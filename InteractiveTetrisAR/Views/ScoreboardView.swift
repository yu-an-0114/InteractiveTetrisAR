//
//  ScoreboardView.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct ScoreboardView: View {
    @EnvironmentObject var scoreVM: ScoreViewModel
    @State private var isRefreshing = false

    var body: some View {
        DarkBackgroundView {
            VStack(spacing: 16) {
                SectionHeaderView(title: "排行榜")
                    .padding(.top, 40)

                List {
                    ForEach(scoreVM.records.prefix(10)) { record in
                        ScoreRowView(record: record)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { idx in
                            let rec = scoreVM.records[idx]
                            scoreVM.deleteScore(rec)                  // 本地刪除
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await reloadFromFirebase()
                }

                Spacer()

                Button(action: {
                    scoreVM.clearAll()
                }) {
                    Text("清除所有紀錄")
                        .foregroundColor(.red)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal)
        }
        .navigationBarTitle("", displayMode: .inline)
    }

    private func reloadFromFirebase() async {
        isRefreshing = true
        await FirebaseService.shared.fetchTopScores { records in
            DispatchQueue.main.async {
                scoreVM.replaceAll(with: records)
                isRefreshing = false
            }
        }
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView()
            .environmentObject(ScoreViewModel())
    }
}
