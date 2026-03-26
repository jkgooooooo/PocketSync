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

    var koreanCurrencyText: String {
        guard self > 0 else { return "영원" }

        let groupUnits = ["", "만", "억", "조"]
        var value = self
        var groupIndex = 0
        var parts: [String] = []

        while value > 0 {
            let groupValue = value % 10_000

            if groupValue > 0 {
                let groupText = Self.formatKoreanGroup(groupValue)
                let unit = groupUnits[groupIndex]

                if unit == "만", groupValue == 1 {
                    parts.insert(unit, at: 0)
                } else {
                    parts.insert("\(groupText)\(unit)", at: 0)
                }
            }

            value /= 10_000
            groupIndex += 1
        }

        return parts.joined() + "원"
    }

    private static func formatKoreanGroup(_ number: Int) -> String {
        let digits = ["", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구"]
        let units = ["", "십", "백", "천"]
        let characters = String(number).map(String.init)
        var result = ""

        for (index, character) in characters.enumerated() {
            guard let digit = Int(character), digit > 0 else { continue }

            let unitIndex = characters.count - index - 1
            let digitText = digit == 1 && unitIndex > 0 ? "" : digits[digit]
            result += digitText + units[unitIndex]
        }

        return result
    }
}
