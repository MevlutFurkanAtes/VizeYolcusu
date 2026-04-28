//
//  ContentView.swift
//  VizeYolcusu
//
//  Created by Mevlüt Furkan Ateş on 24.04.2026.
//

import SwiftUI

// MARK: - Category Palette (category-specific, not country-driven)
private let paletteIndigo = Color(red: 0.28, green: 0.18, blue: 0.82)

// MARK: - Root

struct ContentView: View {
    @StateObject private var countryStore = CountryStore()
    @State       private var selectedCountry: VisaCountry = CountryStore.sampleCountries[0]

    var body: some View {
        TabView {
            PreparationView(countryStore: countryStore,
                            selectedCountry: $selectedCountry)
                .tabItem { Label("Hazırlık", systemImage: "doc.badge.checkmark") }
            AppointmentsView(themeColor: selectedCountry.themeColor)
                .tabItem { Label("Randevular", systemImage: "bell.badge.fill") }
            ConsulateView()
                .tabItem { Label("Konsolosluk", systemImage: "map.fill") }
            NotesView()
                .tabItem { Label("Notlarım", systemImage: "note.text") }
        }
        .tint(selectedCountry.themeColor)
        .animation(.easeInOut(duration: 0.3), value: selectedCountry.id)
    }
}

// MARK: - Preparation Tab

struct PreparationView: View {
    @ObservedObject var countryStore: CountryStore
    @Binding        var selectedCountry: VisaCountry
    @Namespace      private var cardNamespace
    @State          private var showCountryPicker = false

    private var theme: Color { selectedCountry.themeColor }

    private var completedCount: Int {
        selectedCountry.requirements.filter(\.isCompleted).count
    }
    private var progress: Double {
        guard !selectedCountry.requirements.isEmpty else { return 0 }
        return Double(completedCount) / Double(selectedCountry.requirements.count)
    }

    var body: some View {
        ZStack {
            backgroundGlow

            ScrollView {
                VStack(spacing: 0) {
                    HeroHeader(country: selectedCountry,
                               progress: progress,
                               completedCount: completedCount,
                               onGlobeTap: { showCountryPicker = true })

                    CountrySelectorStrip(
                        countries: countryStore.countries,
                        selected: $selectedCountry
                    )
                    .padding(.top, 20)
                    .padding(.bottom, 4)

                    VStack(alignment: .leading, spacing: 28) {
                        VisaProgressBar(
                            progress: progress,
                            theme: theme,
                            completed: completedCount,
                            total: selectedCountry.requirements.count
                        )
                        activeBentoGrid
                        if completedCount > 0 { completedSection }
                        if progress == 1      { appointmentButton }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 52)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: completedCount)
        .animation(.easeInOut(duration: 0.55), value: selectedCountry.id)
        .sheet(isPresented: $showCountryPicker) {
            CountrySelectionView(selectedCountry: $selectedCountry,
                                 countryStore: countryStore)
        }
    }

    // MARK: Background glow

    private var backgroundGlow: some View {
        ZStack {
            Color(.systemGroupedBackground)

            Ellipse()
                .fill(theme.opacity(0.22))
                .frame(width: 400, height: 400)
                .blur(radius: 90)
                .offset(x: 130, y: 90)

            Ellipse()
                .fill(theme.opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 75)
                .offset(x: -110, y: 520)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.65), value: selectedCountry.id)
    }

    // MARK: Active grid

    private var activeBentoGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(
                "Bekleyen Evraklar",
                count: selectedCountry.requirements.count - completedCount,
                accent: theme
            )

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12),
                          GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach($selectedCountry.requirements) { $item in
                    if !item.isCompleted {
                        BentoCard(requirement: $item, theme: theme)
                            .matchedGeometryEffect(id: item.id, in: cardNamespace)
                    }
                }
            }
            .id(selectedCountry.id) // force fresh grid on country switch
        }
    }

    // MARK: Completed section

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Tamamlananlar", count: completedCount, accent: .green)

            VStack(spacing: 8) {
                ForEach($selectedCountry.requirements) { $item in
                    if item.isCompleted {
                        CompletedRow(requirement: $item, theme: theme)
                            .matchedGeometryEffect(id: item.id, in: cardNamespace)
                    }
                }
            }
        }
    }

    // MARK: Appointment button

    private var appointmentButton: some View {
        Button { } label: {
            HStack(spacing: 10) {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 17, weight: .semibold))
                Text("Randevuya Hazırsın!")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(theme, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(.white)
            .shadow(color: theme.opacity(0.38), radius: 12, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    // MARK: Helpers

    private func sectionLabel(_ title: String, count: Int, accent: Color) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
            Text("\(count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accent)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(accent.opacity(0.12), in: Capsule())
        }
    }
}

// MARK: - Country Selector Strip

private struct CountrySelectorStrip: View {
    let countries: [VisaCountry]
    @Binding var selected: VisaCountry

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(countries) { country in
                    let isSelected = selected.id == country.id

                    Button {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                            selected = country
                        }
                    } label: {
                        HStack(spacing: 7) {
                            Text(country.flag)
                                .font(.system(size: 17))
                            Text(country.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(isSelected ? .white : .primary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            isSelected
                                ? country.themeColor
                                : Color(.secondarySystemGroupedBackground),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    isSelected ? Color.clear : Color(.systemGray4),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: isSelected ? country.themeColor.opacity(0.35) : .clear,
                            radius: 8, x: 0, y: 3
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Hero Header

private struct HeroHeader: View {
    let country: VisaCountry
    let progress: Double
    let completedCount: Int
    let onGlobeTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: country.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative icon derived from country icon
            Image(systemName: country.icon)
                .font(.system(size: 140, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.07))
                .offset(x: 70, y: -44)

            // Globe button — top-trailing
            Button(action: onGlobeTap) {
                Image(systemName: "globe")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.white.opacity(0.20), in: Circle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, 56)
            .padding(.trailing, 20)

            // Content row
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text(country.flag)
                            .font(.system(size: 14))
                        Text(country.visaType.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.70))
                            .tracking(0.8)
                    }
                    Text("Vize\nHazırlık")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .lineSpacing(2)
                }
                Spacer()
                CircularProgressRing(
                    progress: progress,
                    completedCount: completedCount,
                    total: country.requirements.count
                )
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 30)
        }
        .frame(height: 280)
        .clipShape(BottomRoundedShape(radius: 36))
        .shadow(color: (country.gradientColors.last ?? country.themeColor).opacity(0.40),
                radius: 24, x: 0, y: 12)
        .animation(.easeInOut(duration: 0.4), value: country.id)
    }
}

// MARK: - Circular Progress Ring

private struct CircularProgressRing: View {
    let progress: Double
    let completedCount: Int
    let total: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.18), lineWidth: 7)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.white, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.9, dampingFraction: 0.7), value: progress)
            VStack(spacing: 0) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                Text("%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(width: 86, height: 86)
    }
}

// MARK: - Visa Progress Bar

private struct VisaProgressBar: View {
    let progress: Double
    let theme: Color
    let completed: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Hazırlık Durumu")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(completed)/\(total) tamamlandı")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [theme, theme.opacity(0.65)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * progress), height: 8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Bento Card

private struct BentoCard: View {
    @Binding var requirement: VisaRequirement
    let theme: Color
    @State private var glowing   = false
    @State private var expanded  = false

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            pulseGlow()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                requirement.isCompleted = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    ZStack {
                        Circle()
                            .fill(requirement.category.accentColor.opacity(0.16))
                            .frame(width: 42, height: 42)
                        Image(systemName: requirement.category.icon)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(requirement.category.accentColor)
                    }
                    Spacer()
                    Text(requirement.category.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(requirement.category.accentColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(requirement.category.accentColor.opacity(0.12), in: Capsule())
                }

                Text(requirement.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let tip = requirement.tip {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: expanded ? "lightbulb.fill" : "lightbulb")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                            Text(expanded ? "Gizle" : "İpucu")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    if expanded {
                        Text(tip)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Spacer(minLength: 0)

                HStack(alignment: .bottom) {
                    if !requirement.isMandatory {
                        Text("Opsiyonel")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5), in: Capsule())
                    }
                    Spacer()
                    Image(systemName: "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(.systemGray3))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .background(.ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 25, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .strokeBorder(.white.opacity(0.35), lineWidth: 1)
            )
            .shadow(
                color: requirement.category.accentColor.opacity(glowing ? 0.55 : 0.12),
                radius: glowing ? 22 : 8,
                x: 0, y: glowing ? 0 : 5
            )
            .scaleEffect(glowing ? 0.95 : 1)
        }
        .buttonStyle(.plain)
    }

    private func pulseGlow() {
        withAnimation(.spring(response: 0.15, dampingFraction: 0.55)) { glowing = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { glowing = false }
        }
    }
}

// MARK: - Completed Row

private struct CompletedRow: View {
    @Binding var requirement: VisaRequirement
    let theme: Color

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                requirement.isCompleted = false
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
                Text(requirement.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .strikethrough(true, color: .secondary)
                    .lineLimit(1)
                Spacer()
                Text(requirement.category.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(requirement.category.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(requirement.category.accentColor.opacity(0.10), in: Capsule())
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(.ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.green.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Consulate Tab

private struct ConsulateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "map.fill")
                .font(.system(size: 52))
                .foregroundStyle(.secondary.opacity(0.4))
            Text("Konsolosluk Bilgileri")
                .font(.title2.bold())
            Text("Yakın çevrenizdeki konsoloslukları\nve randevu bilgilerini göreceksiniz.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Notes Tab

private struct NotesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "note.text")
                .font(.system(size: 52))
                .foregroundStyle(.secondary.opacity(0.4))
            Text("Vize Notlarım")
                .font(.title2.bold())
            Text("Başvuruya dair kişisel notlarınızı\nburada saklayabileceksiniz.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Bottom-only Rounded Shape

private struct BottomRoundedShape: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: .init(x: rect.minX, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX, y: rect.maxY - radius))
            p.addQuadCurve(
                to:      .init(x: rect.maxX - radius, y: rect.maxY),
                control: .init(x: rect.maxX,           y: rect.maxY)
            )
            p.addLine(to: .init(x: rect.minX + radius, y: rect.maxY))
            p.addQuadCurve(
                to:      .init(x: rect.minX,           y: rect.maxY - radius),
                control: .init(x: rect.minX,           y: rect.maxY)
            )
            p.closeSubpath()
        }
    }
}

// MARK: - RequirementCategory Appearance

extension RequirementCategory {
    var accentColor: Color {
        switch self {
        case .personal: return paletteIndigo
        case .work:     return .purple
        case .finance:  return .orange
        case .travel:   return .teal
        }
    }

    var icon: String {
        switch self {
        case .personal: return "idcard.fill"
        case .work:     return "briefcase.fill"
        case .finance:  return "banknote.fill"
        case .travel:   return "airplane"
        }
    }
}

#Preview {
    ContentView()
}
