//
//  UIApplication.swift
//  ZiggeoDemoSwift
//
//  Created by Severyn-Wsevolod on 07.06.2024.
//

import UIKit

extension UIApplication {
    func openWebBrowser(_ urlString: String) {
        guard let url = URL(string: urlString), canOpenURL(url) else {
            fatalError("Can't open URL: \(urlString)")
        }
        open(url)
    }
}
