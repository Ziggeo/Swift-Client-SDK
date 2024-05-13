//
//  DateFormatter.swift
//  ZiggeoDemoSwift
//
//  Created by Severyn-Wsevolod on 11.05.2024.
//

import Foundation

extension DateFormatter {
    static var dateTime: DateFormatter { .init(format: "yyyy-MM-dd HH:mm:ss") }
    
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}
