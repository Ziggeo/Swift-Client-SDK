//
//  AuthViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import ActiveLabel
import ZiggeoMediaSwiftSDK

final class AuthViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var descriptionLabel: ActiveLabel!
    @IBOutlet private weak var tokenTextField: UITextField!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var changeModeButton: UIButton!
    
    // MARK: - Private variables
    private enum LoginMode {
        case qr
        case manual
    }
    private var loginMode: LoginMode = .qr
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customType = ActiveType.custom(pattern: "\\sziggeo.com/quickstart\\b")
        descriptionLabel.numberOfLines = 0
        descriptionLabel.enabledTypes = [customType]
        descriptionLabel.text = "Please go to ziggeo.com/quickstart on your desktop or laptop and scan QR code. This will allow you to connect your desktop and mobile demo experience."
        descriptionLabel.textColor = .black
        descriptionLabel.customColor[customType] = .blue
        descriptionLabel.handleCustomTap(for: customType) { _ in
            UIApplication.shared.openWebBrowser("https://ziggeo.com/quickstart")
        }
        
        refreshUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let applicationToken = UserDefaults.applicationToken, !applicationToken.isEmpty {
            login(applicationToken)
        }
    }
}

// MARK: - @IBActions
private extension AuthViewController {
    @IBAction func onConfirm(_ sender: Any) {
        switch loginMode {
        case .qr: scanQRCode()
            
        case .manual:
            guard let applicationToken = tokenTextField.text, !applicationToken.isEmpty else {
                return Common.showAlertView("Please input application token.")
            }
            login(applicationToken)
        }
    }
    
    @IBAction func onChangeMode(_ sender: Any) {
        switch loginMode {
        case .qr: loginMode = .manual
        case .manual: loginMode = .qr
        }
        refreshUI()
    }
}

// MARK: - Privates
private extension AuthViewController {
    func refreshUI() {
        switch loginMode {
        case .qr:
            tokenTextField.isHidden = true
            confirmButton.setTitle("Scan QR Code", for: .normal)
            changeModeButton.setTitle("or Enter Manually", for: .normal)
            
        case .manual:
            tokenTextField.isHidden = false
            confirmButton.setTitle("Use Entered", for: .normal)
            changeModeButton.setTitle("or Use Scanner", for: .normal)
        }
    }
    
    func scanQRCode() {
        let ziggeo = Ziggeo()
        ziggeo.qrScannerDelegate = self
        ziggeo.startQrScanner()
    }
    
    func login(_ applicationToken: String) {
        UserDefaults.applicationToken = applicationToken
        if let vc = Common.getStoryboardViewController(type: HomeViewController.self) {
            Common.ziggeo = Ziggeo(token: applicationToken)
            navigationController?.setViewControllers([vc], animated: true)
        }
    }
}

// MARK: - ZiggeoQRScannerDelegate
extension AuthViewController: ZiggeoQRScannerDelegate {
    func qrCodeScaned(_ qrCode: String) {
        login(qrCode)
    }
    
    func qrCodeScanCancelledByUser() {
    }
}
