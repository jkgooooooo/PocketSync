//
//  SurfaceComponents.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct HeroPanel: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(PocketSyncTheme.accent)

            Text(title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(PocketSyncTheme.ink)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(PocketSyncTheme.secondaryText)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(PocketSyncTheme.line.opacity(0.3), lineWidth: 1)
        }
    }
}

struct SectionBlock<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(PocketSyncTheme.ink)

            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(PocketSyncTheme.line.opacity(0.3), lineWidth: 1)
        }
    }
}

struct InfoCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PocketSyncTheme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct WarningBanner: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(PocketSyncTheme.warning)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(PocketSyncTheme.ink)

                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(PocketSyncTheme.secondaryText)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PocketSyncTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
