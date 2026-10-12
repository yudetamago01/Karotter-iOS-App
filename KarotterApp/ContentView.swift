import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var browser = KarotterBrowserController()

    private let background = Color(red: 0.055, green: 0.078, blue: 0.118)
    private let accent = Color(red: 0.39, green: 0.67, blue: 0.96)

    var body: some View {
        ZStack {
            KarotterWebView(controller: browser)

            if let message = browser.errorMessage {
                connectionError(message)
                    .transition(.opacity)
            }
        }
        .background(background.ignoresSafeArea())
    }

    private func connectionError(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(accent)

            Text("Karotterに接続できません")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Color.white.opacity(0.68))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: browser.reload) {
                Label("再読み込み", systemImage: "arrow.clockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(accent, in: Capsule())
            }
            .padding(.top, 2)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background)
    }
}

private struct KarotterWebView: UIViewRepresentable {
    @ObservedObject var controller: KarotterBrowserController

    func makeUIView(context: Context) -> WKWebView {
        controller.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
