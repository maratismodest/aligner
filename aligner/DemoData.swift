#if DEBUG
import Foundation
import SwiftData

/// Sample data for App Store screenshots.
/// Launch with `-demoData YES`, optionally `-initialTab 1` to open another tab.
enum DemoData {
    static var initialTab: Int { UserDefaults.standard.integer(forKey: "initialTab") }

    static func seedIfRequested(_ context: ModelContext) {
        guard UserDefaults.standard.bool(forKey: "demoData") else { return }
        try? context.delete(model: OffSession.self)
        try? context.delete(model: TreatmentPlan.self)

        let calendar = Calendar.current
        let now = Date.now
        let today = calendar.startOfDay(for: now)

        // 20 trays of 14 days, started 60 days ago — currently on tray 5.
        context.insert(TreatmentPlan(
            startDate: calendar.date(byAdding: .day, value: -60, to: today) ?? today,
            totalTrays: 20,
            daysPerTray: 14,
            reminderTime: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: now) ?? now
        ))

        // Past days: three meals each, one day slightly over the limit.
        let minutesPerDay = [95, 110, 80, 135, 100, 90]
        for (offset, total) in minutesPerDay.enumerated() {
            guard let day = calendar.date(byAdding: .day, value: -(offset + 1), to: today) else { continue }
            let meals = [(8, total * 3 / 10), (13, total * 4 / 10), (19, total - total * 7 / 10)]
            for (hour, minutes) in meals {
                let start = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) ?? day
                context.insert(OffSession(start: start, end: start.addingTimeInterval(Double(minutes * 60))))
            }
        }

        // Today: breakfast and lunch done, aligners out right now.
        for (hour, minutes) in [(8, 25), (13, 35)] {
            let start = calendar.date(bySettingHour: hour, minute: 5, second: 0, of: today) ?? today
            if start.addingTimeInterval(Double(minutes * 60)) < now {
                context.insert(OffSession(start: start, end: start.addingTimeInterval(Double(minutes * 60))))
            }
        }
        context.insert(OffSession(start: now.addingTimeInterval(-12 * 60)))
    }
}
#endif
