// SciFiButton.swift
import SwiftUI

/// 只負責樣式，不處理點擊
struct SciFiButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cyan, lineWidth: 2)
                    .background(Color.black.opacity(0.6).cornerRadius(12))
            )
    }
}

extension View {
    /// 一行調用：.sciFiStyle()
    func sciFiStyle() -> some View {
        modifier(SciFiButtonStyle())
    }
}
