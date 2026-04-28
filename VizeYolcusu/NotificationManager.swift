//
//  NotificationManager.swift
//  VizeYolcusu
//
//  Created by Mevlüt Furkan Ateş on 28.04.2026.
//

import UserNotifications

// MARK: - NotificationManager

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // Local notification — drop-in replacement point for FCM remote push.
    // When FCM is integrated, call FCM's messaging API here instead of
    // (or in addition to) scheduling a local trigger.
    func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content:    content,
            trigger:    trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
