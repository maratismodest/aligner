import Foundation
import UserNotifications

/// Schedules local notifications for the off-time limit and tray changes.
enum ReminderScheduler {
    private static let center = UNUserNotificationCenter.current()
    private static let offWarningID = "off.warning"
    private static let offLimitID = "off.limit"
    private static let trayPrefix = "tray."

    static func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    // MARK: - Off-time limit

    /// Called when aligners are taken out. `remaining` is today's unused off-time.
    static func scheduleOffLimitReminders(remaining: TimeInterval) async {
        cancelOffLimitReminders()

        let warningLead: TimeInterval = 15 * 60
        if remaining > warningLead {
            await add(
                id: offWarningID,
                title: "15 minutes left",
                body: "Your daily time without aligners is almost up.",
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: remaining - warningLead, repeats: false)
            )
        }
        await add(
            id: offLimitID,
            title: "Put your aligners back in",
            body: "You've used up today's 2 hours without aligners.",
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: max(remaining, 1), repeats: false)
        )
    }

    static func cancelOffLimitReminders() {
        center.removePendingNotificationRequests(withIdentifiers: [offWarningID, offLimitID])
    }

    // MARK: - Tray changes

    /// Replaces all pending tray change reminders according to `plan`.
    static func scheduleTrayChanges(for plan: TreatmentPlan) async {
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(
            withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix(trayPrefix) }
        )

        let now = Date.now
        let nextTray = plan.currentTray(on: now) + 1
        guard nextTray <= plan.totalTrays else { return }

        // iOS keeps at most 64 pending notifications, so only schedule the nearest ones.
        for tray in nextTray...min(plan.totalTrays, nextTray + 29) {
            let date = plan.reminderDate(forTray: tray)
            guard date > now else { continue }
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            await add(
                id: "\(trayPrefix)\(tray)",
                title: "Time to switch aligners",
                body: "Put in tray \(tray) of \(plan.totalTrays) today.",
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            )
        }
    }

    // MARK: - Helpers

    private static func add(id: String, title: String, body: String, trigger: UNNotificationTrigger) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
