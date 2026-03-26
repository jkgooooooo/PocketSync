//
//  FormComponents.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct KeypadKey: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .foregroundStyle(PocketSyncTheme.ink)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(PocketSyncTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(PocketSyncTheme.line, lineWidth: 1)
            }
    }
}

struct FlexibleChipLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }

    private var rows: [[String]] {
        var result: [[String]] = []
        var current: [String] = []

        for item in items {
            if current.count == 3 {
                result.append(current)
                current = []
            }
            current.append(item)
        }

        if !current.isEmpty {
            result.append(current)
        }

        return result
    }
}

struct ChipFlowLayout: Layout {
    var spacing: CGFloat = 10
    var rowSpacing: CGFloat = 10

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 0
        guard maxWidth > 0 else {
            let widths = subviews.map { $0.sizeThatFits(.unspecified).width }
            let heights = subviews.map { $0.sizeThatFits(.unspecified).height }
            return CGSize(
                width: widths.max() ?? 0,
                height: heights.reduce(0, +)
            )
        }

        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let itemWidth = min(size.width, maxWidth)

            if lineWidth > 0, lineWidth + spacing + itemWidth > maxWidth {
                totalHeight += lineHeight + rowSpacing
                lineWidth = itemWidth
                lineHeight = size.height
            } else {
                lineWidth += (lineWidth > 0 ? spacing : 0) + itemWidth
                lineHeight = max(lineHeight, size.height)
            }
        }

        totalHeight += lineHeight

        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let itemWidth = min(size.width, bounds.width)

            if x > bounds.minX, x + itemWidth > bounds.maxX {
                x = bounds.minX
                y += lineHeight + rowSpacing
                lineHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: itemWidth, height: size.height)
            )

            x += itemWidth + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? .white : PocketSyncTheme.ink)
            .padding(.horizontal, 16)
            .frame(minHeight: 42)
            .background(isSelected ? PocketSyncTheme.positive : PocketSyncTheme.card.opacity(0.88))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? .clear : PocketSyncTheme.line.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: isSelected ? PocketSyncTheme.positive.opacity(0.16) : PocketSyncTheme.shadow.opacity(0.35), radius: 8, y: 4)
    }
}

struct CategoryAddChip: View {
    let isExpanded: Bool

    init(isExpanded: Bool = false) {
        self.isExpanded = isExpanded
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isExpanded ? "minus" : "plus")
                .font(.footnote.weight(.bold))
            Text(isExpanded ? "닫기" : "추가")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(PocketSyncTheme.accent)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(PocketSyncTheme.card.opacity(0.88))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(PocketSyncTheme.accent.opacity(0.25), lineWidth: 1)
        }
        .shadow(color: PocketSyncTheme.shadow.opacity(0.35), radius: 8, y: 4)
    }
}

struct SuggestionChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(PocketSyncTheme.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(PocketSyncTheme.card.opacity(0.82))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(PocketSyncTheme.line.opacity(0.16), lineWidth: 1)
            }
            .shadow(color: PocketSyncTheme.shadow.opacity(0.25), radius: 6, y: 3)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let tint: Color

    init(title: String, isSelected: Bool, tint: Color = PocketSyncTheme.accent) {
        self.title = title
        self.isSelected = isSelected
        self.tint = tint
    }

    var body: some View {
        HStack(spacing: 6) {
            if isSelected {
                Circle()
                    .fill(tint)
                    .frame(width: 6, height: 6)
            }

            Text(title)
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(isSelected ? tint : PocketSyncTheme.ink)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(isSelected ? PocketSyncTheme.card : PocketSyncTheme.panel)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(isSelected ? tint.opacity(0.28) : PocketSyncTheme.line.opacity(0.10), lineWidth: 1)
        }
        .shadow(color: isSelected ? PocketSyncTheme.shadow.opacity(0.08) : .clear, radius: 10, y: 5)
    }
}

struct QuickRepeatRow: View {
    let title: String

    var body: some View {
        HStack {
            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                .foregroundStyle(PocketSyncTheme.ink.opacity(0.7))

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.ink)

            Spacer()

            Image(systemName: "arrow.up.left")
                .foregroundStyle(PocketSyncTheme.ink.opacity(0.5))
        }
        .padding(16)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct OptionRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(PocketSyncTheme.ink)
            Spacer()
            Text(value)
                .foregroundStyle(PocketSyncTheme.ink.opacity(0.68))
        }
        .font(.subheadline)
        .padding(14)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
