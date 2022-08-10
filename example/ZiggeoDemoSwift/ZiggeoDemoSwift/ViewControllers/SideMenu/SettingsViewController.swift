//
//  SettingsViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var startDelayTextField: UITextField!
    @IBOutlet weak var customCameraSwitch: UISwitch!
    @IBOutlet weak var customPlayerSwitch: UISwitch!
    @IBOutlet weak var useBlurSwtich: UISwitch!
    
    
    // MARK: - Public variables
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startDelayTextField.text = UserDefaults.standard.string(forKey: Common.Start_Delay_Key)
        customCameraSwitch.isOn = UserDefaults.standard.bool(forKey: Common.Custom_Camera_Key)
        customPlayerSwitch.isOn = UserDefaults.standard.bool(forKey: Common.Custom_Player_Key)
        useBlurSwtich.isOn = UserDefaults.standard.bool(forKey: Common.Blur_Mode_Key)
    }
    
    // MARK: - Actions
    @IBAction func onSave(_ sender: Any) {
        UserDefaults.standard.setValue(startDelayTextField.text, forKey: Common.Start_Delay_Key)
        UserDefaults.standard.setValue(customCameraSwitch.isOn, forKey: Common.Custom_Camera_Key)
        UserDefaults.standard.setValue(customPlayerSwitch.isOn, forKey: Common.Custom_Player_Key)
        UserDefaults.standard.setValue(useBlurSwtich.isOn, forKey: Common.Blur_Mode_Key)
        UserDefaults.standard.synchronize()
        
        Common.showAlertView("Settings was saved.")
    }
}

