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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }

    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "buttonClickHandler")
        configuration.userContentController.add(self, name: "onStart")

        let js = """
            window.webkit.messageHandlers.onStart.postMessage("onStart");
            """

        let onStartScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(onStartScript)

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
        switch message.name {
        case "onStart":
            let script = "document.getElementById('the_other_image').src = './cat.jpeg';"

            webView.evaluateJavaScript(script) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error)")
                } else {
                    print("JavaScript executed successfully")
                }
            }
        case "buttonClickHandler":
            print("button clicked")
        default:
            break
        }
    }
}

