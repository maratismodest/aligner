import SwiftUI
import SwiftData

/// Tray change schedule based on the treatment plan.
struct ScheduleView: View {
    @Query private var plans: [TreatmentPlan]
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            Group {
                if let plan = plans.first {
                    PlanOverview(plan: plan)
                } else {
                    ContentUnavailableView {
                        Label("Нет плана лечения", systemImage: "calendar.badge.plus")
                    } description: {
                        Text("Укажите дату начала, количество кап и срок ношения каждой — приложение напомнит о смене.")
                    } actions: {
                        Button("Настроить план") { isEditing = true }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Расписание")
            .toolbar {
                if !plans.isEmpty {
                    Button("Изменить") { isEditing = true }
                }
            }
            .sheet(isPresented: $isEditing) {
                PlanEditor(plan: plans.first)
            }
        }
    }
}

private struct PlanOverview: View {
    let plan: TreatmentPlan

    var body: some View {
        let now = Date.now
        let current = plan.currentTray(on: now)

        List {
            Section {
                summary(current: current, now: now)
            }

            Section("Капы") {
                ForEach(1...plan.totalTrays, id: \.self) { tray in
                    TrayRow(plan: plan, tray: tray, current: current)
                }
            }
        }
    }

    @ViewBuilder
    private func summary(current: Int, now: Date) -> some View {
        if current == 0 {
            Label {
                Text("Лечение начнётся \(plan.startDate, format: .dateTime.day().month(.wide))")
            } icon: {
                Image(systemName: "hourglass")
            }
        } else if current > plan.totalTrays {
            Label("Лечение по плану завершено 🎉", systemImage: "checkmark.seal.fill")
                .foregroundStyle(.green)
        } else {
            let nextChange = plan.firstDay(ofTray: current + 1)
            let daysLeft = Calendar.current.dateComponents(
                [.day], from: Calendar.current.startOfDay(for: now), to: nextChange
            ).day ?? 0

            VStack(alignment: .leading, spacing: 12) {
                Text("Капа \(current) из \(plan.totalTrays)")
                    .font(.title2.bold())
                ProgressView(value: Double(current - 1), total: Double(plan.totalTrays))
                if current < plan.totalTrays {
                    Text("Смена на капу \(current + 1): \(nextChange, format: .dateTime.day().month(.wide)) (через \(daysLeft) дн.)")
                } else {
                    Text("Последняя капа — до \(nextChange, format: .dateTime.day().month(.wide))")
                }
                Text("Окончание лечения: \(plan.endDate, format: .dateTime.day().month(.wide).year())")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

private struct TrayRow: View {
    let plan: TreatmentPlan
    let tray: Int
    let current: Int

    var body: some View {
        let start = plan.firstDay(ofTray: tray)
        let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: plan.firstDay(ofTray: tray + 1)) ?? start

        HStack {
            icon
            Text("Капа \(tray)")
                .fontWeight(tray == current ? .semibold : .regular)
            Spacer()
            Text("\(start, format: .dateTime.day().month()) – \(lastDay, format: .dateTime.day().month())")
                .foregroundStyle(.secondary)
        }
        .listRowBackground(tray == current ? Color.accentColor.opacity(0.12) : nil)
    }

    @ViewBuilder
    private var icon: some View {
        if tray < current {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        } else if tray == current {
            Image(systemName: "circle.inset.filled").foregroundStyle(.tint)
        } else {
            Image(systemName: "circle").foregroundStyle(.secondary)
        }
    }
}

/// Form to create or edit the treatment plan.
struct PlanEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let plan: TreatmentPlan?

    @State private var startDate: Date
    @State private var totalTrays: Int
    @State private var daysPerTray: Int
    @State private var reminderTime: Date

    init(plan: TreatmentPlan?) {
        self.plan = plan
        _startDate = State(initialValue: plan?.startDate ?? .now)
        _totalTrays = State(initialValue: plan?.totalTrays ?? 20)
        _daysPerTray = State(initialValue: plan?.daysPerTray ?? 14)
        _reminderTime = State(initialValue: plan?.reminderTime
            ?? Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: .now)
            ?? .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Лечение") {
                    DatePicker("Начало (капа 1)", selection: $startDate, displayedComponents: .date)
                    Stepper("Всего кап: \(totalTrays)", value: $totalTrays, in: 1...120)
                    Stepper("Дней на капу: \(daysPerTray)", value: $daysPerTray, in: 1...30)
                }
                Section {
                    DatePicker("Время", selection: $reminderTime, displayedComponents: .hourAndMinute)
                } header: {
                    Text("Напоминание о смене")
                } footer: {
                    Text("Удобнее менять капы вечером — первые, самые чувствительные часы пройдут во сне.")
                }
            }
            .formStyle(.grouped)
            .navigationTitle(plan == nil ? "Новый план" : "План лечения")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { save() }
                }
            }
        }
    }

    private func save() {
        let target: TreatmentPlan
        if let plan {
            plan.startDate = startDate
            plan.totalTrays = totalTrays
            plan.daysPerTray = daysPerTray
            plan.reminderTime = reminderTime
            target = plan
        } else {
            target = TreatmentPlan(
                startDate: startDate,
                totalTrays: totalTrays,
                daysPerTray: daysPerTray,
                reminderTime: reminderTime
            )
            context.insert(target)
        }
        Task { await ReminderScheduler.scheduleTrayChanges(for: target) }
        dismiss()
    }
}

#Preview {
    ScheduleView()
        .modelContainer(for: [OffSession.self, TreatmentPlan.self], inMemory: true)
}
