import Combine
import SwiftUI
import WebKit

@MainActor
final class KarotterBrowserController: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
    @Published private(set) var canGoBack = false
    @Published private(set) var isLoading = true
    @Published private(set) var estimatedProgress = 0.0
    @Published private(set) var currentURL: URL?
    @Published private(set) var errorMessage: String?

    let webView: WKWebView
    private var progressObservation: NSKeyValueObservation?

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.alwaysBounceVertical = true

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 0.39, green: 0.67, blue: 0.96, alpha: 1)
        refreshControl.addTarget(self, action: #selector(refreshFromPull), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        progressObservation = webView.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] view, _ in
            let progress = view.estimatedProgress
            DispatchQueue.main.async {
                self?.estimatedProgress = progress
            }
        }

        let home = URL(string: "https://karotter.com/")!
        currentURL = home
        webView.load(URLRequest(url: home, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30))
    }

    func goBack() {
        guard webView.canGoBack else { return }
        webView.goBack()
        updateNavigationState()
    }

    func reload() {
        errorMessage = nil
        if webView.url == nil, let currentURL {
            webView.load(URLRequest(url: currentURL))
        } else {
            webView.reload()
        }
    }

    @objc private func refreshFromPull() {
        errorMessage = nil
        webView.reload()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        errorMessage = nil
        isLoading = true
        updateNavigationState()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        updateNavigationState()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        errorMessage = nil
        isLoading = false
        webView.scrollView.refreshControl?.endRefreshing()
        updateNavigationState()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        finishWith(error: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        finishWith(error: error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url,
              let scheme = url.scheme?.lowercased() else {
            decisionHandler(.cancel)
            return
        }

        if ["https", "http", "about", "blob", "data"].contains(scheme) {
            // Keep web-based sign-in and service navigation in the same persistent session.
            decisionHandler(.allow)
            return
        }

        if ["mailto", "tel", "sms"].contains(scheme) {
            UIApplication.shared.open(url)
        }
        decisionHandler(.cancel)
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        webView.load(navigationAction.request)
        return nil
    }

    @available(iOS 15.0, *)
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        decisionHandler(.prompt)
    }

    private func finishWith(error: Error) {
        let nsError = error as NSError
        guard !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) else {
            isLoading = false
            webView.scrollView.refreshControl?.endRefreshing()
            updateNavigationState()
            return
        }

        isLoading = false
        errorMessage = "通信状態を確認して、もう一度お試しください。"
        webView.scrollView.refreshControl?.endRefreshing()
        updateNavigationState()
    }

    private func updateNavigationState() {
        canGoBack = webView.canGoBack
        currentURL = webView.url ?? currentURL
    }
}
