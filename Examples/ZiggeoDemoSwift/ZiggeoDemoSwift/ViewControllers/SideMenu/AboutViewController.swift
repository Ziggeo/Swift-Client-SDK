//
//  AboutViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import WebKit
import MessageUI

final class AboutViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var webView: WKWebView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        let url = Bundle.main.url(forResource: "about", withExtension: "html")! // swiftlint:disable:this force_unwrapping
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }
    
    // MARK: - Actions
    private func sendEmail(_ recipient: String) {
        guard MFMailComposeViewController.canSendMail() else { return }
        let mail = MFMailComposeViewController()
        mail.setToRecipients([recipient])
        mail.mailComposeDelegate = self
        present(mail, animated: true)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension AboutViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            let link = navigationAction.request.url?.absoluteString ?? ""
            if link.contains("mailto:") {
                sendEmail(link.replacingOccurrences(of: "mailto:", with: ""))
            } else {
                Common.openWebBrowser(link)
            }
            decisionHandler(.cancel)
            
        default: decisionHandler(.allow)
        }
    }
}
