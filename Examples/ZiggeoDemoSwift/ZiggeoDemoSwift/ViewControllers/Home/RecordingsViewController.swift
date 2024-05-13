//
//  RecordingsViewController.swift
//  ZiggeoDemoSwift
//
//  Created by Dragon on 6/24/22.
//

import UIKit

final class RecordingsViewController: UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Common.subNavigationController = navigationController
    }
}
