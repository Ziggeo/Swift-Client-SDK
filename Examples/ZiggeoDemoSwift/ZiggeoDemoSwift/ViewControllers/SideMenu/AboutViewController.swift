//
//  AboutViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import WebKit
import MessageUI

final class AboutViewController: UIViewController, MailScreenInvoker {
    
    // MARK: - Outlets
    @IBOutlet private weak var webView: WKWebView!
    
    var presenterViewController: UIViewController { self }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        let url = Bundle.main.url(forResource: "about", withExtension: "html")! // swiftlint:disable:this force_unwrapping
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension AboutViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            let link = navigationAction.request.url?.absoluteString ?? ""
            if link.contains("mailto:") {
                presentMailScreen(to: link.replacingOccurrences(of: "mailto:", with: ""))
            } else {
                UIApplication.shared.openWebBrowser(link)
            }
            decisionHandler(.cancel)
            
        default: decisionHandler(.allow)
        }
    }
}
