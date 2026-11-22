import Foundation
import SwiftData

/// Maximum time per day the aligners may be out of the mouth.
let dailyOffLimit: TimeInterval = 2 * 60 * 60

/// A period during which the aligners were taken out.
@Model
final class OffSession {
    var start: Date
    /// `nil` while the aligners are still out.
    var end: Date?

    init(start: Date, end: Date? = nil) {
        self.start = start
        self.end = end
    }

    /// Portion of this session (in seconds) that falls inside `interval`.
    /// An ongoing session is counted up to `now`.
    func duration(in interval: DateInterval, now: Date) -> TimeInterval {
        let lower = max(start, interval.start)
        let upper = min(end ?? now, interval.end)
        return max(0, upper.timeIntervalSince(lower))
    }
}

extension Array where Element == OffSession {
    /// Total time without aligners during the calendar day containing `day`.
    /// Sessions crossing midnight are split between the two days.
    func totalOffTime(on day: Date, now: Date) -> TimeInterval {
        guard let interval = Calendar.current.dateInterval(of: .day, for: day) else { return 0 }
        return reduce(0) { $0 + $1.duration(in: interval, now: now) }
    }
}

/// Orthodontist's plan: how many trays and how long each one is worn.
@Model
final class TreatmentPlan {
    /// Day the first tray is put on.
    var startDate: Date
    var totalTrays: Int
    var daysPerTray: Int
    /// Only hour and minute are used — time of the tray change reminder.
    var reminderTime: Date

    init(startDate: Date, totalTrays: Int, daysPerTray: Int, reminderTime: Date) {
        self.startDate = startDate
        self.totalTrays = totalTrays
        self.daysPerTray = daysPerTray
        self.reminderTime = reminderTime
    }
}

extension TreatmentPlan {
    /// First day of wearing tray number `tray` (1-based).
    func firstDay(ofTray tray: Int) -> Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        return calendar.date(byAdding: .day, value: (tray - 1) * daysPerTray, to: start) ?? start
    }

    /// Day after the last tray is finished.
    var endDate: Date { firstDay(ofTray: totalTrays + 1) }

    /// Tray worn on `date`: 0 before treatment starts, `totalTrays + 1` after it ends.
    func currentTray(on date: Date) -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: startDate),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        guard days >= 0 else { return 0 }
        return Swift.min(days / daysPerTray + 1, totalTrays + 1)
    }

    /// Exact moment of the reminder on the day tray `tray` should be put on.
    func reminderDate(forTray tray: Int) -> Date {
        let time = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        return Calendar.current.date(
            bySettingHour: time.hour ?? 9,
            minute: time.minute ?? 0,
            second: 0,
            of: firstDay(ofTray: tray)
        ) ?? firstDay(ofTray: tray)
    }
}

extension TimeInterval {
    /// "1:05:03"-style representation.
    var clockString: String {
        Duration.seconds(Int(self)).formatted(.time(pattern: .hourMinuteSecond))
    }
}
