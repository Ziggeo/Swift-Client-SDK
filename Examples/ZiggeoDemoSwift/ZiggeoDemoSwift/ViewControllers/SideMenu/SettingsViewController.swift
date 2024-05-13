//
//  SettingsViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var startDelayTextField: UITextField!
    @IBOutlet private weak var customCameraSwitch: UISwitch!
    @IBOutlet private weak var customPlayerSwitch: UISwitch!
    @IBOutlet private weak var useBlurSwtich: UISwitch!
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startDelayTextField.text = UserDefaults.startDelay
        customCameraSwitch.isOn = UserDefaults.isUsingCustomCamera
        customPlayerSwitch.isOn = UserDefaults.isUsingCustomPlayer
        useBlurSwtich.isOn = UserDefaults.isUsingBlurMode
    }
    
    // MARK: - Actions
    @IBAction private func onSave(_ sender: Any) {
        UserDefaults.startDelay = startDelayTextField.text
        UserDefaults.isUsingCustomCamera = customCameraSwitch.isOn
        UserDefaults.isUsingCustomPlayer = customPlayerSwitch.isOn
        UserDefaults.isUsingBlurMode = useBlurSwtich.isOn
        UserDefaults.standard.synchronize()
        
        Common.showAlertView("Settings was saved.")
    }
}
