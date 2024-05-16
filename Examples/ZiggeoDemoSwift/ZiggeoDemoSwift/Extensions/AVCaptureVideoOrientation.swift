//
//  AVCaptureVideoOrientation.swift
//  ZiggeoDemoSwift
//
//  Created by Severyn-Wsevolod on 16.05.2024.
//

import AVFoundation
import UIKit

extension AVCaptureVideoOrientation {
    init?(orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeRight:       self = .landscapeLeft
        case .landscapeLeft:        self = .landscapeRight
        case .portrait:             self = .portrait
        case .portraitUpsideDown:   self = .portraitUpsideDown
        default: return nil
        }
    }
}
