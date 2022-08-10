//
//  ContactUsViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit

class ContactUsViewController: UIViewController {
    
    // MARK: - Actions
    @IBAction func onContactUs(_ sender: Any) {
        Common.ziggeo?.sendEmailToSupport()
    }
    
    @IBAction func onVisitSupoort(_ sender: Any) {
        Common.openWebBrowser("https://support.ziggeo.com")
    }
}
