import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject private var settingsVM: SettingsViewModel

    var body: some View {
        DarkBackgroundView {
            List {
                ForEach(settingsVM.availableLanguages, id: \.self) { lang in
                    HStack {
                        Text(lang)
                            .foregroundColor(.white)
                        Spacer()
                        if settingsVM.currentLanguage == lang {
                            Image(systemName: "checkmark")
                                .foregroundColor(.cyan)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        settingsVM.currentLanguage = lang
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationBarTitle("語言選擇", displayMode: .inline)
    }
}
