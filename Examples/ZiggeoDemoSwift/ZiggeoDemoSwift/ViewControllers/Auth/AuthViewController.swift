//
//  AuthViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit
import ActiveLabel
import ZiggeoMediaSwiftSDK


class AuthViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var changeModeButton: UIButton!
    
    // MARK: - Private variables
    private enum LoginMode {
        case QR
        case Manual
    }
    private var loginMode = LoginMode.QR

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let customType = ActiveType.custom(pattern: "\\sziggeo.com/quickstart\\b")
        descriptionLabel.numberOfLines = 0
        descriptionLabel.enabledTypes = [customType]
        descriptionLabel.text = "Please go to ziggeo.com/quickstart on your desktop or laptop and scan QR code. This will allow you to connect your desktop and mobile demo experience."
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.customColor[customType] = UIColor.blue
        descriptionLabel.handleCustomTap(for: customType) { element in
            Common.openWebBrowser("https://ziggeo.com/quickstart")
        }
        
        refreshUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let applicationToken = UserDefaults.standard.string(forKey: Common.Application_Token_Key), applicationToken != "" {
            login(applicationToken)
        }
    }
    
    // MARK: - Actions
    @IBAction func onConfirm(_ sender: Any) {
        if loginMode == LoginMode.QR {
            self.scanQRCode()
        } else {
            let applicationToken = tokenTextField.text ?? ""
            if applicationToken == "" {
                Common.showAlertView("Please input application token.")
                return
            }
            login(applicationToken)
        }
    }
    
    @IBAction func onChangeMode(_ sender: Any) {
        if loginMode == LoginMode.QR {
            loginMode = LoginMode.Manual
        } else {
            loginMode = LoginMode.QR
        }
        refreshUI()
    }
    
    // MARK: - Private functions
    private func refreshUI() {
        if loginMode == LoginMode.QR {
            tokenTextField.isHidden = true
            confirmButton.setTitle("Scan QR Code", for: UIControl.State.normal)
            changeModeButton.setTitle("or Enter Manually", for: UIControl.State.normal)
        } else {
            tokenTextField.isHidden = false
            confirmButton.setTitle("Use Entered", for: UIControl.State.normal)
            changeModeButton.setTitle("or Use Scanner", for: UIControl.State.normal)
        }
    }
    
    private func scanQRCode() {
        let ziggeo = Ziggeo(qrCodeReaderDelegate: self)
        ziggeo.startQrScanner()
    }
    
    private func login(_ applicationToken: String) {
        UserDefaults.standard.setValue(applicationToken, forKey: Common.Application_Token_Key)
        if let vc = Common.getStoryboardViewController("HomeViewController") as? HomeViewController {
            Common.ziggeo = Ziggeo(token: applicationToken, delegate: vc)
            self.navigationController?.setViewControllers([vc], animated: true)
        }
    }
}

// MARK: - ZiggeoQRCodeReaderDelegate
extension AuthViewController: ZiggeoQRCodeReaderDelegate {
    func ziggeoQRCodeScaned(_ qrCode: String) {
        self.login(qrCode)
    }
}
