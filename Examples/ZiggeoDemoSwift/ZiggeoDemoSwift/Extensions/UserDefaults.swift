//
//  UserDefaults.swift
//  ZiggeoDemoSwift
//
//  Created by Severyn-Wsevolod on 11.05.2024.
//

import Foundation

extension UserDefaults {
    private enum Key {
        static let applicationToken = "Application_Token_Key"
        static let startDelay = "Start_Delay_Key"
        static let isUsingCustomCamera = "Custom_Camera_Key"
        static let isUsingCustomPlayer = "Custom_Player_Key"
        static let isUsingBlurMode = "Blur_Mode_Key"
    }
    
    static var applicationToken: String? {
        get { standard.string(forKey: Key.applicationToken) }
        set(newToken) { standard.set(newToken, forKey: Key.applicationToken) }
    }
    static var startDelay: String? {
        get { standard.string(forKey: Key.startDelay) }
        set { standard.set(newValue, forKey: Key.startDelay) }
    }
    static var isUsingCustomCamera: Bool {
        get { standard.bool(forKey: Key.isUsingCustomCamera) }
        set { standard.set(newValue, forKey: Key.isUsingCustomCamera) }
    }
    static var isUsingCustomPlayer: Bool {
        get { standard.bool(forKey: Key.isUsingCustomPlayer) }
        set { standard.set(newValue, forKey: Key.isUsingCustomPlayer) }
    }
    static var isUsingBlurMode: Bool {
        get { standard.bool(forKey: Key.isUsingBlurMode) }
        set { standard.set(newValue, forKey: Key.isUsingBlurMode) }
    }
}
