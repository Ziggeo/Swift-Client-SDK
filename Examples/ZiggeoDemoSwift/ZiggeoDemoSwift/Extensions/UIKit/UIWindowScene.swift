//
//  UIWindowScene.swift
//  ZiggeoDemoSwift
//
//  Created by Severyn-Wsevolod on 11.05.2024.
//

import UIKit

extension UIWindowScene {
    static var foreground: UIWindowScene? {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        
        return windowScenes.first(where: { $0.activationState == .foregroundActive }) ??
        windowScenes.first(where: { $0.activationState == .foregroundInactive })
    }
}
