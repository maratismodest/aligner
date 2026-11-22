import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var plans: [TreatmentPlan]

    var body: some View {
        TabView {
            Tab("Сегодня", systemImage: "timer") {
                TodayView()
            }
            Tab("Расписание", systemImage: "calendar") {
                ScheduleView()
            }
            Tab("Советы", systemImage: "lightbulb") {
                TipsView()
            }
        }
        .task {
            await ReminderScheduler.requestAuthorization()
            // Only the nearest tray changes are scheduled, so refresh them on every launch.
            if let plan = plans.first {
                await ReminderScheduler.scheduleTrayChanges(for: plan)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [OffSession.self, TreatmentPlan.self], inMemory: true)
}
