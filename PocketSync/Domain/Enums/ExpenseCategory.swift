//
//  ExpenseCategory.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

enum ExpenseCategoryGroup: String, CaseIterable, Codable, Identifiable {
    case living
    case finance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .living:
            "생활비"
        case .finance:
            "금융비용"
        }
    }
}

struct ExpenseCategory: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let group: ExpenseCategoryGroup
    let suggestedMemos: [String]
    let isDefault: Bool

    var groupTitle: String {
        group.title
    }

    var suggestionSeed: String {
        suggestedMemos.first ?? title
    }

    init(
        id: String,
        title: String,
        group: ExpenseCategoryGroup,
        suggestedMemos: [String] = [],
        isDefault: Bool
    ) {
        self.id = id
        self.title = title
        self.group = group
        self.suggestedMemos = suggestedMemos
        self.isDefault = isDefault
    }

    static func custom(title: String, group: ExpenseCategoryGroup) -> ExpenseCategory {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let slug = normalizedTitle
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")

        let fallbackID = UUID().uuidString.lowercased()
        let identifier = slug.isEmpty ? "custom-\(fallbackID)" : "custom-\(group.rawValue)-\(slug)"

        return ExpenseCategory(
            id: identifier,
            title: normalizedTitle,
            group: group,
            suggestedMemos: [normalizedTitle],
            isDefault: false
        )
    }
}

extension ExpenseCategory {
    static let food = ExpenseCategory(
        id: "default-food",
        title: "식비",
        group: .living,
        suggestedMemos: ["장보기", "외식", "마트", "반찬", "식재료"],
        isDefault: true
    )

    static let maintenance = ExpenseCategory(
        id: "default-maintenance",
        title: "관리비",
        group: .living,
        suggestedMemos: ["관리비", "정기 납부", "생활 관리비"],
        isDefault: true
    )

    static let supplies = ExpenseCategory(
        id: "default-supplies",
        title: "생필품",
        group: .living,
        suggestedMemos: ["생활용품", "생필품", "세제", "휴지", "욕실용품"],
        isDefault: true
    )

    static let transport = ExpenseCategory(
        id: "default-transport",
        title: "교통비",
        group: .living,
        suggestedMemos: ["택시", "버스", "지하철", "주유", "주차"],
        isDefault: true
    )

    static let shopping = ExpenseCategory(
        id: "default-shopping",
        title: "쇼핑",
        group: .living,
        suggestedMemos: ["쿠팡", "올리브영", "생활 쇼핑", "온라인 주문"],
        isDefault: true
    )

    static let health = ExpenseCategory(
        id: "default-health",
        title: "의료/건강",
        group: .living,
        suggestedMemos: ["병원", "약국", "검진", "치과", "영양제"],
        isDefault: true
    )

    static let education = ExpenseCategory(
        id: "default-education",
        title: "교육",
        group: .living,
        suggestedMemos: ["수업", "학원", "책", "강의"],
        isDefault: true
    )

    static let leisure = ExpenseCategory(
        id: "default-leisure",
        title: "문화/여가",
        group: .living,
        suggestedMemos: ["영화", "카페", "데이트", "취미", "여가"],
        isDefault: true
    )

    static let phoneBill = ExpenseCategory(
        id: "default-phone-bill",
        title: "핸드폰요금",
        group: .living,
        suggestedMemos: ["통신비", "핸드폰 요금", "알뜰폰 요금"],
        isDefault: true
    )

    static let cardBill = ExpenseCategory(
        id: "default-card-bill",
        title: "카드값",
        group: .living,
        suggestedMemos: ["카드값", "카드 결제", "청구 금액"],
        isDefault: true
    )

    static let otherLiving = ExpenseCategory(
        id: "default-other-living",
        title: "기타",
        group: .living,
        suggestedMemos: ["기타", "예외 지출", "일상 지출"],
        isDefault: true
    )

    static let interestExpense = ExpenseCategory(
        id: "default-interest-expense",
        title: "이자비용",
        group: .finance,
        suggestedMemos: ["대출 이자", "이자 납부"],
        isDefault: true
    )

    static let loanRepayment = ExpenseCategory(
        id: "default-loan-repayment",
        title: "대출상환",
        group: .finance,
        suggestedMemos: ["가계대출 상환", "원금 상환"],
        isDefault: true
    )

    static let defaultCategories: [ExpenseCategory] = [
        .food,
        .maintenance,
        .supplies,
        .transport,
        .shopping,
        .health,
        .education,
        .leisure,
        .phoneBill,
        .cardBill,
        .otherLiving,
        .interestExpense,
        .loanRepayment
    ]

    static let entryOrder: [ExpenseCategory] = defaultCategories
}
