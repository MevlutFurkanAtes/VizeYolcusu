//
//  AppointmentViewModel.swift
//  VizeYolcusu
//
//  Created by Mevlüt Furkan Ateş on 28.04.2026.
//

import Foundation
import Combine

// MARK: - AppointmentStatus

struct AppointmentStatus: Identifiable {
    let id: UUID
    let countryKey: String          // backend key, e.g. "germany"
    let countryName: String
    let flag: String
    let visaType: String
    var isAvailable: Bool
    var confidenceScore: Double
    var notificationEnabled: Bool
    var lastChecked: Date

    init(
        id: UUID = UUID(),
        countryKey: String = "",
        countryName: String,
        flag: String,
        visaType: String,
        isAvailable: Bool = false,
        confidenceScore: Double = 0,
        notificationEnabled: Bool = true,
        lastChecked: Date = Date()
    ) {
        self.id                  = id
        // Derive key from name if not provided (keeps old callsites valid)
        self.countryKey          = countryKey.isEmpty
                                     ? countryName.lowercased().replacingOccurrences(of: " ", with: "_")
                                     : countryKey
        self.countryName         = countryName
        self.flag                = flag
        self.visaType            = visaType
        self.isAvailable         = isAvailable
        self.confidenceScore     = confidenceScore
        self.notificationEnabled = notificationEnabled
        self.lastChecked         = lastChecked
    }
}

// MARK: - AppointmentViewModel

final class AppointmentViewModel: ObservableObject {
    @Published var appointments: [AppointmentStatus] = []
    @Published var liveAppointments: [AppointmentDTO] = []
    @Published var isLoading:    Bool    = false
    @Published var networkError: String? = nil

    private var notifiedIDs:  Set<UUID>          = []
    private var pendingWork:  DispatchWorkItem?

    init() {
        appointments = Self.defaultAppointments
        NotificationManager.shared.requestPermission()
    }

    // MARK: - Network

    /// Fetches live appointment status from the backend.
    /// Merges results with local state to preserve user preferences (notification toggle).
    func loadAppointments() {
        guard !isLoading else { return }
        isLoading    = true
        networkError = nil

        let snapshot = appointments  // capture for merge before async returns

        AppointmentService.shared.fetchAppointments { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let dtos):
                    self.appointments = dtos.map { dto in
                        // Derive a stable key from the country name ("Germany" → "germany")
                        let key  = dto.country.lowercased().replacingOccurrences(of: " ", with: "_")
                        let prev = snapshot.first { $0.countryKey == key }
                        return AppointmentStatus(
                            id:                  prev?.id ?? UUID(),
                            countryKey:          key,
                            countryName:         prev?.countryName ?? dto.country,
                            flag:                prev?.flag ?? "",
                            visaType:            dto.visaType,
                            isAvailable:         dto.isAvailable,
                            confidenceScore:     dto.confidenceScore,
                            notificationEnabled: prev?.notificationEnabled ?? true,
                            lastChecked:         Self.parseISO(dto.lastChecked)
                        )
                    }
                    self.checkAndFireLocalNotifications()
                case .failure(let error):
                    self.networkError = error.localizedDescription
                }
            }
        }
    }

    /// Sends a crowd availability report, then immediately refreshes live data.
    func reportAppointment(country: String) {
        AppointmentService.shared.sendReport(country: country) { [weak self] result in
            DispatchQueue.main.async {
                if case .success = result {
                    self?.load()
                }
            }
        }
    }

    /// Fetches structured appointment data from the deployed backend.
    func load() {
        isLoading = true
        AppointmentService.shared.fetchAppointments { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let dtos): self.liveAppointments = dtos
                case .failure:           break   // keep last known data on error
                }
            }
        }
    }

    // MARK: - Mock / Dev helpers (kept for offline testing)

    /// Simulates an availability change after a 10–15 second delay.
    func simulateAvailabilityChange() {
        guard !isLoading else { return }
        isLoading = true

        pendingWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.markFirstUnavailableAsOpen()
            }
        }
        pendingWork = work
        DispatchQueue.global(qos: .utility)
            .asyncAfter(deadline: .now() + Double.random(in: 10...15), execute: work)
    }

    /// Reloads live data (or falls back to timestamp bump when offline).
    func refresh() {
        loadAppointments()
    }

    func addAppointment(_ appointment: AppointmentStatus) {
        appointments.append(appointment)
    }

    // MARK: - Private

    private func markFirstUnavailableAsOpen() {
        guard let idx = appointments.firstIndex(where: { !$0.isAvailable }) else { return }
        let id = appointments[idx].id
        guard !notifiedIDs.contains(id) else { return }

        appointments[idx].isAvailable = true
        appointments[idx].lastChecked = Date()

        if appointments[idx].notificationEnabled {
            notifiedIDs.insert(id)
            NotificationManager.shared.sendLocalNotification(
                title: "\(appointments[idx].countryName) Vize Randevusu Açıldı!",
                body:  "Hemen başvurunu yap."
            )
        }
    }

    /// Fires a local notification for any appointment that just became available.
    private func checkAndFireLocalNotifications() {
        for appt in appointments {
            guard appt.isAvailable,
                  !notifiedIDs.contains(appt.id),
                  appt.notificationEnabled else { continue }
            notifiedIDs.insert(appt.id)
            NotificationManager.shared.sendLocalNotification(
                title: "\(appt.countryName) Vize Randevusu Açıldı!",
                body:  "Hemen başvurunu yap."
            )
        }
    }

    private static func parseISO(_ string: String) -> Date {
        ISO8601DateFormatter().date(from: string) ?? Date()
    }
}

// MARK: - Default Data

private extension AppointmentViewModel {
    static let defaultAppointments: [AppointmentStatus] = [
        AppointmentStatus(
            countryKey:          "germany",
            countryName:         "Almanya",
            flag:                "🇩🇪",
            visaType:            "Schengen C Vizesi (iDATA)",
            isAvailable:         false,
            notificationEnabled: true
        )
    ]
}
