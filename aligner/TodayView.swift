import SwiftUI
import SwiftData

/// Main screen: tracks time without aligners against the 2-hour daily limit.
struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \OffSession.start, order: .reverse) private var sessions: [OffSession]

    private var activeSession: OffSession? { sessions.first { $0.end == nil } }

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                content(now: timeline.date)
            }
            .navigationTitle("Сегодня")
        }
        .task {
            let now = Date.now
            let used = sessions.totalOffTime(on: now, now: now)
            LiveActivityController.sync(
                offSince: activeSession?.start,
                limitReachedAt: now.addingTimeInterval(dailyOffLimit - used)
            )
        }
    }

    private func content(now: Date) -> some View {
        let used = sessions.totalOffTime(on: now, now: now)
        let todaySessions = sessions.filter {
            $0.end == nil || Calendar.current.isDate($0.start, inSameDayAs: now)
        }

        return List {
            Section {
                VStack(spacing: 20) {
                    LimitRing(used: used, isOff: activeSession != nil)

                    if let activeSession {
                        Text("Сняты в \(activeSession.start, format: .dateTime.hour().minute()) · \(now.timeIntervalSince(activeSession.start).clockString)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }

                    toggleButton(used: used)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section("Снятия сегодня") {
                if todaySessions.isEmpty {
                    Text("Сегодня элайнеры ещё не снимались")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(todaySessions) { session in
                        SessionRow(session: session, now: now)
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            if todaySessions[index].end == nil {
                                ReminderScheduler.cancelOffLimitReminders()
                                LiveActivityController.stop()
                            }
                            context.delete(todaySessions[index])
                        }
                    }
                }
            }

            Section("Последние 7 дней") {
                ForEach(0..<7, id: \.self) { offset in
                    let day = Calendar.current.date(byAdding: .day, value: -offset, to: now) ?? now
                    let total = sessions.totalOffTime(on: day, now: now)
                    HStack {
                        Text(day, format: .dateTime.weekday(.wide).day().month())
                        Spacer()
                        Text(total.clockString)
                            .monospacedDigit()
                            .foregroundStyle(total > dailyOffLimit ? .red : .secondary)
                    }
                }
            }

            Section("Совет дня") {
                TipRow(tip: Tip.ofTheDay(now))
            }
        }
    }

    private func toggleButton(used: TimeInterval) -> some View {
        let isOff = activeSession != nil
        return Button {
            isOff ? putOn() : takeOff(used: used)
        } label: {
            Label(isOff ? "Надеть элайнеры" : "Снять элайнеры",
                  systemImage: isOff ? "checkmark.circle.fill" : "mouth")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(isOff ? .green : .orange)
    }

    private func takeOff(used: TimeInterval) {
        let now = Date.now
        context.insert(OffSession(start: now))
        LiveActivityController.start(
            offSince: now,
            limitReachedAt: now.addingTimeInterval(dailyOffLimit - used)
        )
        Task {
            await ReminderScheduler.scheduleOffLimitReminders(remaining: dailyOffLimit - used)
        }
    }

    private func putOn() {
        activeSession?.end = .now
        ReminderScheduler.cancelOffLimitReminders()
        LiveActivityController.stop()
    }
}

/// Circular progress showing how much of today's off-time is left.
struct LimitRing: View {
    let used: TimeInterval
    let isOff: Bool

    private var isOverLimit: Bool { used >= dailyOffLimit }
    private var progress: Double { min(used / dailyOffLimit, 1) }

    private var color: Color {
        if isOverLimit { return .red }
        if used >= dailyOffLimit * 0.75 { return .orange }
        return .green
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 18)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text(isOff ? "Элайнеры сняты" : "Элайнеры надеты")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(isOverLimit
                     ? "+" + (used - dailyOffLimit).clockString
                     : (dailyOffLimit - used).clockString)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(isOverLimit ? .red : .primary)
                Text(isOverLimit ? "сверх лимита" : "осталось из 2 ч")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 240, height: 240)
        .animation(.default, value: progress)
    }
}

private struct SessionRow: View {
    let session: OffSession
    let now: Date

    var body: some View {
        HStack {
            Image(systemName: session.end == nil ? "timer" : "clock")
                .foregroundStyle(session.end == nil ? .orange : .secondary)
            if let end = session.end {
                Text("\(session.start, format: .dateTime.hour().minute()) – \(end, format: .dateTime.hour().minute())")
            } else {
                Text("\(session.start, format: .dateTime.hour().minute()) – сейчас")
            }
            Spacer()
            Text(((session.end ?? now).timeIntervalSince(session.start)).clockString)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [OffSession.self, TreatmentPlan.self], inMemory: true)
}
