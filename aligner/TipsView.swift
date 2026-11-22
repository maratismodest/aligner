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
        case .schedule: "Режим ношения"
        case .nutrition: "Питание"
        case .hygiene: "Гигиена"
        case .care: "Уход за элайнерами"
        case .comfort: "Дискомфорт"
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
            Tip(title: "22 часа в сутки",
                text: "Элайнеры работают, только если носить их 20–22 часа в день. Каждый лишний час без них замедляет лечение."),
            Tip(title: "Меняйте капы по графику",
                text: "Не переходите на следующую капу раньше срока и не задерживайтесь на текущей без указания ортодонта."),
            Tip(title: "Не пропускайте визиты",
                text: "Приходите к ортодонту в назначенные даты, даже если всё идёт хорошо — врач контролирует движение зубов."),
        ]
        case .nutrition: [
            Tip(title: "Снимайте элайнеры перед едой",
                text: "Ешьте и пейте всё, кроме чистой воды, только без кап: остатки пищи и сахар под капой разрушают эмаль, а сами капы деформируются и окрашиваются."),
            Tip(title: "Планируйте приёмы пищи",
                text: "Три основных приёма пищи по 20–30 минут укладываются в лимит 2 часа. Частые перекусы быстро «съедают» время."),
            Tip(title: "Горячее — только без кап",
                text: "Горячий чай и кофе могут деформировать пластик. Пейте их без элайнеров или дайте остыть."),
            Tip(title: "Осторожно с красящими продуктами",
                text: "Кофе, чай, красное вино, ягоды, свёкла, куркума и соусы окрашивают капы и зубы. После них почистите зубы."),
            Tip(title: "Мягкая еда в первые дни",
                text: "После смены капы зубы чувствительны — выбирайте каши, супы, йогурты, пюре, омлет, рыбу."),
            Tip(title: "Липкое и твёрдое",
                text: "Ириски, жвачка, орехи, сухари и лёд могут повредить аттачменты и вызвать сколы."),
            Tip(title: "Сладкие и кислые напитки",
                text: "Газировка, соки и спортивные напитки под капой создают кислую среду. Пейте их без элайнеров и прополощите рот."),
        ]
        case .hygiene: [
            Tip(title: "Чистите зубы перед надеванием",
                text: "После каждого приёма пищи чистите зубы или хотя бы тщательно прополощите рот водой."),
            Tip(title: "Зубная нить каждый день",
                text: "Остатки пищи между зубами под капой — главная причина кариеса во время лечения."),
            Tip(title: "Дорожный набор",
                text: "Носите с собой футляр, компактную щётку, пасту и нить, чтобы привести себя в порядок где угодно."),
        ]
        case .care: [
            Tip(title: "Чистите капы утром и вечером",
                text: "Мягкой щёткой и прохладной водой. Абразивная паста оставляет царапины — капы мутнеют."),
            Tip(title: "Никакой горячей воды",
                text: "Не мойте и не замачивайте элайнеры в горячей воде — пластик деформируется."),
            Tip(title: "Всегда в футляр",
                text: "Не заворачивайте капы в салфетку — так их чаще всего выбрасывают по ошибке. Храните подальше от домашних животных."),
            Tip(title: "Сохраняйте предыдущую капу",
                text: "Если новая капа потеряется или сломается, предыдущая поможет удержать результат до визита к врачу."),
        ]
        case .comfort: [
            Tip(title: "Меняйте капу вечером",
                text: "Самые неприятные первые часы после смены пройдут во сне."),
            Tip(title: "Жевательные валики",
                text: "Чуйзы помогают плотно посадить капу и ускоряют адаптацию: 5–10 минут несколько раз в день."),
            Tip(title: "Натирает слизистую",
                text: "Наложите ортодонтический воск на острый край и сообщите ортодонту."),
            Tip(title: "Давление — это нормально",
                text: "Ощущение давления 1–3 дня после смены — признак того, что капа работает. Сильная боль — повод позвонить врачу."),
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
                    Text("Советы носят общий характер. Всегда следуйте рекомендациям своего ортодонта.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Советы")
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
