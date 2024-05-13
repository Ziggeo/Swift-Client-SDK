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

final class SideMenuViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var applicationTokenLabel: UILabel!
    
    // MARK: - Public variables
    var delegate: MenuActionDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applicationTokenLabel.text = UserDefaults.applicationToken
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - @IBActions
private extension SideMenuViewController {
    @IBAction func onLogout(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            UserDefaults.applicationToken = nil
            self.dismiss(animated: true) {
                self.delegate?.didSelectLogoutMenu()
            }
        }))
        present(alert, animated: true)
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
