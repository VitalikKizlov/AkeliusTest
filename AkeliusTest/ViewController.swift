//
//  ViewController.swift
//  AkeliusTest
//
//  Created by Vitalii Kizlov on 29.11.2023.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    private var webView: WKWebView!
    private let configuration = WKWebViewConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
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
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
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
            print("button clicked")
        }
    }
}

