//
//  CountrySelectionView.swift
//  VizeYolcusu
//
//  Created by Mevlüt Furkan Ateş on 24.04.2026.
//

import SwiftUI

// MARK: - CountrySelectionView

struct CountrySelectionView: View {
    @Binding var selectedCountry: VisaCountry
    @ObservedObject var countryStore: CountryStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(countryStore.countries) { country in
                        CountryRow(
                            country: country,
                            isSelected: country.id == selectedCountry.id
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                selectedCountry = country
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Ülke Seç")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Country Row

private struct CountryRow: View {
    let country: VisaCountry
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {

                // Gradient flag badge
                ZStack {
                    LinearGradient(
                        colors: country.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Text(country.flag)
                        .font(.system(size: 28))
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: country.themeColor.opacity(0.28), radius: 8, x: 0, y: 4)

                // Country info
                VStack(alignment: .leading, spacing: 4) {
                    Text(country.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(country.visaType)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Right indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: isSelected ? 22 : 14, weight: .medium))
                    .foregroundStyle(isSelected ? country.themeColor : Color(.systemGray3))
                    .symbolEffect(.bounce, value: isSelected)
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? country.themeColor : Color(.systemGray5),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected
                    ? country.themeColor.opacity(0.15)
                    : .black.opacity(0.05),
                radius: isSelected ? 10 : 5, x: 0, y: 3
            )
        }
        .buttonStyle(PressScaleButtonStyle())
    }
}

// MARK: - Button Style

private struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7),
                       value: configuration.isPressed)
    }
}

// MARK: - Visa Type Grouping (Feature 4 — future-safe)
// Countries with the same visaType share structural compatibility.
// Requirements are always country-specific; visaTypeGroup enables
// future sectioning, filtering, or template reuse without hardcoding.

extension VisaCountry {
    var visaTypeGroup: String { visaType }
}
