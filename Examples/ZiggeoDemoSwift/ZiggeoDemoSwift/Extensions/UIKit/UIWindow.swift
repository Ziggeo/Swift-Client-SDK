//
//  UIWindow.swift
//  ZiggeoDemoSwift
//
//  Created by Severyn-Wsevolod on 11.05.2024.
//

import UIKit

extension UIWindow {
    static var key: UIWindow? {
        UIWindowScene.foregroundActive?.windows.first(where: \.isKeyWindow)
    }
}
