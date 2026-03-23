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

struct CategoryChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? .white : PocketSyncTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(isSelected ? PocketSyncTheme.accent : PocketSyncTheme.panel)
            .clipShape(Capsule())
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? .white : PocketSyncTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(isSelected ? PocketSyncTheme.ink : PocketSyncTheme.paper)
            .clipShape(Capsule())
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
