//
//  SideMenuViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit

@objc public protocol MenuActionDelegate: AnyObject {
    func didSelectLogoutMenu()
    func didSelectRecordingMenu()
    func didSelectVideoEditorMenu()
    func didSelectSettingsMenu()
    func didSelectAvailableSdksMenu()
    func didSelectTopClientsMenu()
    func didSelectContactUsMenu()
    func didSelectAboutMenu()
    func didSelectLogMenu()
    func didSelectPlayVideoFromUrlMenu()
    func didSelectPlayLocalVideoMenu()
}

class SideMenuViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var applicationTokenLabel: UILabel!
    
    // MARK: - Public variables
    var delegate: MenuActionDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let applicationToken = UserDefaults.standard.string(forKey: Common.Application_Token_Key)
        applicationTokenLabel.text = applicationToken
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Actions
    @IBAction func onLogout(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: { (action) in
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            UserDefaults.standard.setValue(nil, forKey: Common.Application_Token_Key)
            self.dismiss(animated: true) {
                self.delegate?.didSelectLogoutMenu()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onRecording(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectRecordingMenu()
        }
    }
    
    @IBAction func onVideoEditor(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectVideoEditorMenu()
        }
    }
    
    @IBAction func onSettings(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectSettingsMenu()
        }
    }
    
    @IBAction func onAvailableSdks(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectAvailableSdksMenu()
        }
    }
    
    @IBAction func onTopClients(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectTopClientsMenu()
        }
    }
    
    @IBAction func onContactUs(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectContactUsMenu()
        }
    }
    
    @IBAction func onAbout(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectAboutMenu()
        }
    }
    
    @IBAction func onLog(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectLogMenu()
        }
    }
    
    @IBAction func onPlayVideoFromUrl(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectPlayVideoFromUrlMenu()
        }
    }
    
    @IBAction func onPlayLocalVideo(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didSelectPlayLocalVideoMenu()
        }
    }
}

