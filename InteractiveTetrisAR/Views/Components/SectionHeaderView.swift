//
//  SectionHeaderView.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

/// 區塊標題視圖，搭配深色背景使用
struct SectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.1, green: 0.0, blue: 0.2))
            )
    }
}

struct SectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DarkBackgroundView {
            SectionHeaderView(title: "範例標題")
                .padding(.top, 40)
        }
    }
}
