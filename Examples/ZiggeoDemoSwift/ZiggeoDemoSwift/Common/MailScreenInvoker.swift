//
//  MailScreenInvoker.swift
//  ZiggeoMediaSwiftSDK
//
//  Created by Severyn-Wsevolod on 18.06.2024.
//  Copyright © 2024 Ziggeo Inc. All rights reserved.
//

import MessageUI

protocol MailScreenInvoker {
    var presenterViewController: UIViewController { get }
    
    func presentMailScreen(to recipientEmail: String)
    func presentMailScreen(to recipientEmail: String, subject: String, body: String)
}

// MARK: - UIViewController
extension MailScreenInvoker where Self: NSObject {
    func presentMailScreen(to recipientEmail: String) {
        presentMailScreen(to: recipientEmail, subject: "", body: "")
    }
    
    func presentMailScreen(to recipientEmail: String, subject: String, body: String) {
        guard MFMailComposeViewController.canSendMail() else {
            let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body)
            return UIApplication.shared.open(emailUrl)
        }
        
        let mail = buildMailComposeDialog(to: recipientEmail, subject: subject, body: body)
        presenterViewController.present(mail, animated: true)
    }
}

// MARK: - Privates
private extension MailScreenInvoker {
    func buildMailComposeDialog(to recipientEmail: String, subject: String, body: String) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self as? any MFMailComposeViewControllerDelegate
        mail.setToRecipients([recipientEmail])
        mail.setSubject(subject)
        mail.setMessageBody(body, isHTML: false)
        
        return mail
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> URL {
        // swiftlint:disable force_unwrapping
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        // swiftlint:enable force_unwrapping
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return defaultUrl! // swiftlint:disable:this force_unwrapping
    }
}
