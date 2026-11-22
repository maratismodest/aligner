import SwiftUI

struct Tip: Identifiable {
    let title: String
    let text: String
    var id: String { title }

    /// Rotates through all tips, one per calendar day.
    static func ofTheDay(_ date: Date) -> Tip {
        let all = TipCategory.allCases.flatMap(\.tips)
        let day = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        return all[day % all.count]
    }
}

enum TipCategory: String, CaseIterable, Identifiable {
    case schedule, nutrition, hygiene, care, comfort

    var id: Self { self }

    var title: String {
        switch self {
        case .schedule: "Wear Schedule"
        case .nutrition: "Food & Drinks"
        case .hygiene: "Oral Hygiene"
        case .care: "Aligner Care"
        case .comfort: "Discomfort"
        }
    }

    var icon: String {
        switch self {
        case .schedule: "clock"
        case .nutrition: "fork.knife"
        case .hygiene: "bubbles.and.sparkles"
        case .care: "shield.lefthalf.filled"
        case .comfort: "cross.case"
        }
    }

    var tips: [Tip] {
        switch self {
        case .schedule: [
            Tip(title: "22 hours a day",
                text: "Aligners only work if you wear them 20–22 hours a day. Every extra hour without them slows down treatment."),
            Tip(title: "Switch trays on schedule",
                text: "Don't move to the next tray early or stay on the current one longer unless your orthodontist tells you to."),
            Tip(title: "Keep your appointments",
                text: "See your orthodontist on the scheduled dates even if everything is going well — they track how your teeth are moving."),
        ]
        case .nutrition: [
            Tip(title: "Take aligners out to eat",
                text: "Eat and drink anything other than plain water only without aligners: food and sugar trapped under the tray damage enamel, and the trays warp and stain."),
            Tip(title: "Plan your meals",
                text: "Three main meals of 20–30 minutes each fit within the 2-hour limit. Frequent snacking eats up the time quickly."),
            Tip(title: "Hot drinks without aligners",
                text: "Hot tea and coffee can warp the plastic. Drink them with aligners out or let them cool down."),
            Tip(title: "Watch out for staining foods",
                text: "Coffee, tea, red wine, berries, beets, turmeric and sauces stain both trays and teeth. Brush after having them."),
            Tip(title: "Soft food for the first days",
                text: "Teeth are sensitive after switching trays — choose porridge, soups, yogurt, mashed potatoes, eggs and fish."),
            Tip(title: "Sticky and hard foods",
                text: "Toffee, gum, nuts, crackers and ice can damage attachments and chip teeth."),
            Tip(title: "Sugary and acidic drinks",
                text: "Soda, juice and sports drinks create an acidic environment under the tray. Drink them without aligners and rinse your mouth."),
        ]
        case .hygiene: [
            Tip(title: "Brush before putting aligners in",
                text: "Brush your teeth after every meal, or at least rinse your mouth thoroughly with water."),
            Tip(title: "Floss every day",
                text: "Food stuck between teeth under the tray is the main cause of cavities during treatment."),
            Tip(title: "Carry a travel kit",
                text: "Keep a case, compact toothbrush, toothpaste and floss with you so you can freshen up anywhere."),
        ]
        case .care: [
            Tip(title: "Clean trays morning and evening",
                text: "Use a soft brush and cool water. Abrasive toothpaste leaves scratches and makes trays cloudy."),
            Tip(title: "No hot water",
                text: "Never rinse or soak aligners in hot water — the plastic will warp."),
            Tip(title: "Always use the case",
                text: "Don't wrap trays in a napkin — that's how they most often get thrown away by mistake. Keep them away from pets."),
            Tip(title: "Keep your previous tray",
                text: "If a new tray gets lost or breaks, the previous one helps hold your progress until you see your orthodontist."),
        ]
        case .comfort: [
            Tip(title: "Switch trays in the evening",
                text: "The most uncomfortable first hours after switching will pass while you sleep."),
            Tip(title: "Use chewies",
                text: "Aligner chewies help seat the tray properly and speed up adjustment: 5–10 minutes a few times a day."),
            Tip(title: "Sore gums or cheeks",
                text: "Put orthodontic wax on the sharp edge and let your orthodontist know."),
            Tip(title: "Pressure is normal",
                text: "Feeling pressure for 1–3 days after switching means the tray is working. Severe pain is a reason to call your doctor."),
        ]
        }
    }
}

struct TipsView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(TipCategory.allCases) { category in
                    Section {
                        ForEach(category.tips) { tip in
                            TipRow(tip: tip)
                        }
                    } header: {
                        Label(category.title, systemImage: category.icon)
                    }
                }

                Section {
                    Text("These tips are general. Always follow your orthodontist's advice.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Tips")
        }
    }
}

struct TipRow: View {
    let tip: Tip

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tip.title)
                .font(.headline)
            Text(tip.text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    TipsView()
}
