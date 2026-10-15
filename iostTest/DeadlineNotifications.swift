import Foundation
import Observation
import UserNotifications

@MainActor @Observable
final class DeadlineNotifications {
    static let shared = DeadlineNotifications()
    private(set) var status = "Reminders: 24 hours, 5 hours and 1 hour before each deadline."
    private let center = UNUserNotificationCenter.current()
    private var queued: [WidgetDeadline]?
    private var worker: Task<Void, Never>?
    private var shouldRequestPermission = false

    // Serialize updates so rapid edits cannot leave an older schedule installed last.
    func update(_ deadlines: [WidgetDeadline], requestPermission: Bool) {
        queued = deadlines
        shouldRequestPermission = shouldRequestPermission || requestPermission
        guard worker == nil else { return }
        worker = Task {
            while let latest = queued {
                queued = nil
                let request = shouldRequestPermission
                shouldRequestPermission = false
                await reconcile(latest, requestPermission: request)
            }
            worker = nil
        }
    }

    private func reconcile(_ deadlines: [WidgetDeadline], requestPermission: Bool) async {
        var settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined && requestPermission && !deadlines.isEmpty {
            do {
                _ = try await center.requestAuthorization(options: [.alert, .sound])
                settings = await center.notificationSettings()
            } catch {
                status = "Could not request reminders: \(error.localizedDescription)"
                return
            }
        }
        let pending = await center.pendingNotificationRequests()
        let own = pending.filter { $0.identifier.hasPrefix(DeadlineReminder.prefix) }
        let allowed = [.authorized, .provisional, .ephemeral].contains(settings.authorizationStatus)
        let available = max(0, 64 - (pending.count - own.count))
        let plan = allowed ? DeadlineReminder.plan(for: deadlines, now: Date(), limit: available) : []
        let desired = Set(plan.map(\.identifier))
        center.removePendingNotificationRequests(withIdentifiers: own.map(\.identifier).filter { !desired.contains($0) })

        // Remove delivered reminders for deleted/completed/edited deadlines too.
        let delivered = await center.deliveredNotifications()
        let allReminders = Set(DeadlineReminder.plan(for: deadlines, now: .distantPast, limit: Int.max).map(\.identifier))
        center.removeDeliveredNotifications(withIdentifiers: delivered.map { $0.request.identifier }.filter {
            $0.hasPrefix(DeadlineReminder.prefix) && !allReminders.contains($0)
        })

        guard allowed else {
            status = settings.authorizationStatus == .denied
                ? "Reminders are off. Enable notifications in Settings."
                : "Allow notifications when you add a deadline to receive reminders."
            return
        }
        do {
            for reminder in plan {
                let interval = reminder.fireDate.timeIntervalSinceNow
                guard interval > 0 else { continue }
                let content = UNMutableNotificationContent()
                content.title = reminder.title
                content.sound = .default
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                try await center.add(UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger))
            }
            let total = DeadlineReminder.plan(for: deadlines, now: Date(), limit: Int.max).count
            status = total > available
                ? "The next \(available) reminders are scheduled. Open the app regularly to schedule more."
                : "Reminders on: 24 hours, 5 hours and 1 hour before each deadline."
        } catch {
            status = "Some reminders could not be scheduled: \(error.localizedDescription). Reopen the app to retry."
        }
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
}
