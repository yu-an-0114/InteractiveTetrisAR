//
//  DarkBackgroundView.swift
//  Interactive3DTetrisAR
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

/// 深色科幻風格背景，可包覆其他內容
struct DarkBackgroundView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        ZStack {
            // 深色漸層背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.05),
                    Color(red: 0.05, green: 0.01, blue: 0.10)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 如果有星空圖可替換下面這段
            // Image("SpaceBackground")
            //     .resizable()
            //     .scaledToFill()
            //     .ignoresSafeArea()

            content()
        }
    }
}

struct DarkBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        DarkBackgroundView {
            Text("示例文字")
                .foregroundColor(.white)
                .padding()
        }
    }
}
