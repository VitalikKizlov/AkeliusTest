//
//  ViewController.swift
//  AkeliusTest
//
//  Created by Vitalii Kizlov on 29.11.2023.
//

import UIKit
import WebKit
import Combine

class ViewController: UIViewController {
    
    private var webView: WKWebView!
    private let configuration = WKWebViewConfiguration()
    private let viewModel = ViewModel()
    private var subscriptions: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupBindings()
        viewModel.startDownloading()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let js = """
            window.webkit.messageHandlers.onStart.postMessage("onStart");
            """

        let onStartScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(onStartScript)
    }

    private func setupWebView() {
        WebViewEvent.allCases.forEach { event in
            configuration.userContentController.add(self, name: event.rawValue)
        }

        webView = WKWebView(frame: view.bounds, configuration: configuration)
        view.addSubview(webView)
    }

    private func setupBindings() {
        viewModel.urlSettingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                guard let self = self else { return }
                self.webView.loadFileURL(settings.fileURL, allowingReadAccessTo: settings.folderURL)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - WKScriptMessageHandler

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let event = WebViewEvent(rawValue: message.name) else { return }

        switch event {
        case .start:
            let script = "document.getElementById('the_other_image').src = './cat.jpeg';"

            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error)")
                } else {
                    print("JavaScript executed successfully")
                }
            }
        case .buttonClick:
            let script = "document.getElementById('top_image').src = './cat.jpeg';"

            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error)")
                } else {
                    print("JavaScript executed successfully")
                }
            }
        }
    }
}

