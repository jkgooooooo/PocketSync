//
//  CurrencyFormatting.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

extension Int {
    var currency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let value = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "\(value)원"
    }
}
