import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var plans: [TreatmentPlan]
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "timer", value: 0) {
                TodayView()
            }
            Tab("Schedule", systemImage: "calendar", value: 1) {
                ScheduleView()
            }
            Tab("Tips", systemImage: "lightbulb", value: 2) {
                TipsView()
            }
        }
        .task {
            #if DEBUG
            if UserDefaults.standard.bool(forKey: "demoData") {
                // Screenshot mode: sample data and no permission prompt.
                DemoData.seedIfRequested(context)
                selectedTab = DemoData.initialTab
                return
            }
            #endif
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
