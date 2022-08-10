//
//  RecordingsViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit


class RecordingsViewController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Common.subNavigationController = self.navigationController
    }
}

