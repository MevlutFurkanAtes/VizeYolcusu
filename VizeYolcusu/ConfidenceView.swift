//
//  ConfidenceView.swift
//  VizeYolcusu
//
//  Created by Mevlüt Furkan Ateş on 28.04.2026.
//

import SwiftUI

// MARK: - ConfidenceView

/// Compact confidence indicator: thin progress bar + label + percentage.
/// Designed to sit below country info without dominating the row.
struct ConfidenceView: View {
    let score: Double
    let isAvailable: Bool

    // When available the bar is always full regardless of raw score.
    private var displayScore: Double {
        isAvailable ? 1.0 : min(max(score, 0), 1)
    }

    private var tier: Tier {
        if isAvailable          { return .open   }
        if displayScore >= 0.7  { return .high   }
        if displayScore >= 0.3  { return .medium }
        return .low
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Label row
            HStack(alignment: .firstTextBaseline) {
                Text(tier.label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(tier.color)
                Spacer()
                Text("%\(Int(displayScore * 100))")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(tier.color)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }

            // Progress bar
            ConfidenceTrack(score: displayScore, color: tier.color)
        }
        .animation(.easeInOut(duration: 0.4), value: displayScore)
        .animation(.easeInOut(duration: 0.4), value: tier.color)
    }
}

// MARK: - Track

/// Geometry-aware progress track — isolated to avoid re-rendering the label on size changes.
private struct ConfidenceTrack: View {
    let score: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 4)
                Capsule()
                    .fill(color)
                    // Minimum 6 pt so the rounded cap stays visible at low scores.
                    .frame(width: score > 0 ? max(6, geo.size.width * score) : 0,
                           height: 4)
                    .animation(.easeInOut(duration: 0.4), value: score)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Tier

private extension ConfidenceView {
    enum Tier: Equatable {
        case low, medium, high, open

        var label: String {
            switch self {
            case .low:    "Düşük ihtimal"
            case .medium: "Hareketlenme var"
            case .high:   "Yüksek ihtimal"
            case .open:   "Randevu Açıldı 🎉"
            }
        }

        var color: Color {
            switch self {
            case .low:          Color(.systemGray3)
            case .medium:       .orange
            case .high, .open:  .green
            }
        }
    }
}

// MARK: - Preview

#Preview("Confidence States") {
    VStack(spacing: 20) {
        ConfidenceView(score: 0.0,  isAvailable: false)
        ConfidenceView(score: 0.15, isAvailable: false)
        ConfidenceView(score: 0.45, isAvailable: false)
        ConfidenceView(score: 0.75, isAvailable: false)
        ConfidenceView(score: 0.3,  isAvailable: true)
    }
    .padding(24)
}
