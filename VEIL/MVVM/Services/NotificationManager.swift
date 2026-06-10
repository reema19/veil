//
//  NotificationManager.swift
//  VEIL
//

import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()

    private init() {}

    private let morningReminderIdentifier = "veil.morning.general.reminder"

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    func scheduleMorningReminder() {
        cancelMorningReminder()

        let content = UNMutableNotificationContent()
        content.title = "A quiet moment"
        content.body = "Take a moment to notice what is around you today."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 46

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: morningReminderIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelMorningReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [morningReminderIdentifier]
        )
    }
}
