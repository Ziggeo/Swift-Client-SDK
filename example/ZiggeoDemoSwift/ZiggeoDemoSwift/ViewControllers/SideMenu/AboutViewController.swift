//
//  AboutViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import WebKit
import MessageUI

class AboutViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        let url = Bundle.main.url(forResource: "about", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }
    
    // MARK: - Actions
    private func sendEmail(_ recipient: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setToRecipients([recipient])
            mail.mailComposeDelegate = self
            present(mail, animated: true)
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - WKNavigationDelegate
extension AboutViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       if navigationAction.navigationType == WKNavigationType.linkActivated {
           let link = navigationAction.request.url?.absoluteString ?? ""
           if link.contains("mailto:") {
               self.sendEmail(link.replacingOccurrences(of: "mailto:", with: ""))
           } else {
               Common.openWebBrowser(link)
           }
           decisionHandler(WKNavigationActionPolicy.cancel)
           return
       }
       decisionHandler(WKNavigationActionPolicy.allow)
    }
}
