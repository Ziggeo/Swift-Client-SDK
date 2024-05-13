//
//  ContactUsViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit

final class ContactUsViewController: UIViewController { }

// MARK: - @IBActions
private extension ContactUsViewController {
    @IBAction func onContactUs(_ sender: Any) {
        Common.ziggeo?.sendEmailToSupport()
    }
    
    @IBAction func onVisitSupoort(_ sender: Any) {
        Common.openWebBrowser("https://support.ziggeo.com")
    }
}
