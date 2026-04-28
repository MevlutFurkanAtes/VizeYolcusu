//
//  AppointmentsView.swift
//  VizeYolcusu
//
//  Created by Mevlüt Furkan Ateş on 28.04.2026.
//

import SwiftUI

// MARK: - Toast

private struct ToastMessage: Equatable {
    let text:      String
    let isSuccess: Bool
}

// MARK: - AppointmentsView

struct AppointmentsView: View {
    @StateObject private var viewModel = AppointmentViewModel()
    let themeColor: Color

    @State private var activeToast: ToastMessage? = nil

    var body: some View {
        NavigationStack {
            List {
                if let error = viewModel.networkError {
                    errorBanner(error)
                }
                backendStatusSection
                trackingSection
                testSection
            }
            .navigationTitle("Randevular")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.refresh) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .refreshable {
                viewModel.refresh()
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
            // Load on first appear
            .onAppear {
                viewModel.loadAppointments()
                viewModel.load()
            }
            // Auto-refresh every 60 s while view is visible
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 60_000_000_000)
                    viewModel.loadAppointments()
                }
            }
        }
        // Toast overlay sits outside NavigationStack so it floats above everything
        .overlay(alignment: .bottom) {
            if let toast = activeToast {
                ToastBanner(message: toast)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 24)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: activeToast)
    }

    // MARK: Sections

    private var backendStatusSection: some View {
        Section("Güncel Randevu Durumu") {
            if viewModel.isLoading {
                HStack(spacing: 10) {
                    ProgressView().scaleEffect(0.8)
                    Text("Bağlanıyor…")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            } else if viewModel.liveAppointments.isEmpty {
                Text("Veri yok")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.liveAppointments, id: \.country) { dto in
                    LiveAppointmentRow(dto: dto)
                }
            }
        }
    }

    private var trackingSection: some View {
        Section {
            ForEach($viewModel.appointments) { $appointment in
                AppointmentRow(
                    appointment: $appointment,
                    themeColor: themeColor,
                    onReport: {
                        viewModel.reportAppointment(country: appointment.countryKey)
                        showToast(ToastMessage(text: "Bildirimin alındı 👍", isSuccess: true))
                    }
                )
            }
        } header: {
            Text("Takip Edilen Randevular")
        } footer: {
            Text("Randevu açıldığında bildirim alabilmek için her ülke için bildirimleri açık tutun.")
        }
    }

    private var testSection: some View {
        Section {
            Button(action: viewModel.simulateAvailabilityChange) {
                HStack {
                    Label("Randevu Açılmasını Simüle Et", systemImage: "flask.fill")
                        .foregroundStyle(.orange)
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView().scaleEffect(0.8)
                    }
                }
            }
            .disabled(viewModel.isLoading)
        } header: {
            Text("Test")
        } footer: {
            Text("10–15 saniye içinde bir randevu açılmasını simüle eder. Yalnızca geliştirme amaçlıdır.")
        }
    }

    private func errorBanner(_ message: String) -> some View {
        Section {
            Label(message, systemImage: "wifi.exclamationmark")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: Toast helper

    private func showToast(_ toast: ToastMessage) {
        withAnimation { activeToast = toast }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { activeToast = nil }
        }
    }
}

// MARK: - Live Appointment Row (DTO-backed, from /appointments)

private struct LiveAppointmentRow: View {
    let dto: AppointmentDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dto.country)
                .font(.system(size: 15, weight: .bold))
            Text(dto.visaType)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            HStack {
                Text(dto.isAvailable ? "Randevu Açıldı 🎉" : "Henüz yok")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(dto.isAvailable ? .green : .secondary)
                Spacer()
                Text("%\(Int(dto.confidenceScore * 100))")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(dto.isAvailable ? .green : .orange)
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Appointment Row

private struct AppointmentRow: View {
    @Binding var appointment: AppointmentStatus
    let themeColor: Color
    let onReport: () -> Void

    @State private var cooldownUntil: Date = .distantPast

    private var onCooldown: Bool { cooldownUntil > Date() }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                flagBadge
                infoStack
                Spacer()
                controlStack
            }
            ConfidenceView(
                score:       appointment.confidenceScore,
                isAvailable: appointment.isAvailable
            )
            reportButton
        }
        .padding(.vertical, 4)
    }

    // MARK: Subviews

    private var flagBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(themeColor.opacity(0.12))
                .frame(width: 48, height: 48)
            Text(appointment.flag)
                .font(.system(size: 26))
        }
    }

    private var infoStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(appointment.countryName)
                .font(.system(size: 15, weight: .semibold))
            Text(appointment.visaType)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            statusBadge
                .animation(.easeInOut(duration: 0.3), value: appointment.isAvailable)
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(appointment.isAvailable ? Color.green : Color.red)
                .frame(width: 7, height: 7)
            Text(appointment.isAvailable ? "Randevu Açıldı" : "Randevu Yok")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(appointment.isAvailable ? .green : .red)
        }
    }

    private var controlStack: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Toggle("", isOn: $appointment.notificationEnabled)
                .labelsHidden()
                .tint(themeColor)
            Text(relativeLastChecked)
                .font(.system(size: 10))
                .foregroundStyle(Color(.systemGray3))
                .monospacedDigit()
        }
    }

    private var reportButton: some View {
        Button {
            guard !onCooldown else { return }
            // Lock for 10 s; asyncAfter clears it without needing a per-row Timer.
            cooldownUntil = Date().addingTimeInterval(5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                cooldownUntil = .distantPast
            }
            onReport()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: onCooldown ? "checkmark.circle.fill" : "hand.raised.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text(onCooldown ? "Gönderildi" : "Randevu Gördüm")
                    .font(.system(size: 13, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                onCooldown
                    ? Color(.systemGray5)
                    : themeColor.opacity(0.12),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .foregroundStyle(onCooldown ? Color(.systemGray2) : themeColor)
            .animation(.easeInOut(duration: 0.2), value: onCooldown)
        }
        .buttonStyle(.plain)
        .disabled(onCooldown)
    }

    private var relativeLastChecked: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: appointment.lastChecked, relativeTo: Date())
    }
}

// MARK: - Toast Banner

private struct ToastBanner: View {
    let message: ToastMessage

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: message.isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(message.isSuccess ? .green : .orange)
            Text(message.text)
                .font(.system(size: 14, weight: .medium))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.10), radius: 16, y: 6)
    }
}
