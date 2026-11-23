# Reply to App Review — Guideline 2.1 Information Needed

Вставьте текст ниже (на английском) в ответ в App Store Connect **и** в поле
App Review Information → Notes. Видеозапись экрана приложите к ответу.

---

Hello, and thank you for reviewing SmileTrack.

**1. Screen recording**
The attached recording was made on a physical iPhone running the latest iOS. It begins with launching the app and shows the typical flow: starting and stopping the off-time timer, the Live Activity on the Lock Screen / Dynamic Island, creating a treatment plan, and the Tips tab.
- SmileTrack has no account registration, login, or account deletion, because it has no accounts.
- It has no user-generated content shared with other users.
- It has no paid content, subscriptions, or In-App Purchases. The app is completely free.

**2. Purpose and target audience**
SmileTrack is for people in clear aligner orthodontic treatment (e.g. Invisalign-style trays). Aligners usually have to be worn about 22 hours a day, so there are only about 2 hours a day for eating, drinking, and cleaning. The trays are also switched on a fixed schedule, often every 7–14 days. Patients often lose track of how long their aligners have been out and when the next tray is due, and that can slow down treatment. SmileTrack solves this with:
- a one-tap timer that tracks today's time without aligners against the 2-hour limit, shown in the app and as a Live Activity
- local reminders 15 minutes before the limit and when the limit is reached
- a tray schedule that shows the current tray, the next switch date, and the end of treatment, with a reminder on each switch day
- general tips about eating, cleaning, and comfort during aligner treatment

The app is not a medical device and does not give diagnoses or treatment advice. It helps the user follow the plan from their own orthodontist.

**3. Setup and access instructions**
No login, credentials, or sample files are needed.
1. Launch the app. Allow notifications when prompted (optional, needed for reminders).
2. **Today tab:** Tap "Take Aligners Out". The ring starts counting down today's 2 hours, and a Live Activity appears on the Lock Screen / Dynamic Island. Tap "Put Aligners In" to stop the timer. Today's removals and the last 7 days are listed below.
3. **Schedule tab:** Tap "Set Up Plan". Enter a start date, the number of trays, days per tray, and a reminder time, then tap "Save". The app shows the current tray, the next switch date, and the treatment end date, and schedules the tray-change reminders.
4. **Tips tab:** Browse the tips by category. A tip of the day also appears on the Today tab.

**4. External services**
None. SmileTrack does not connect to any server, third-party SDK, analytics, advertising, authentication, payment, or AI service. All data is stored only on the device (SwiftData). Reminders are local notifications (UserNotifications), and the timer uses Live Activities (ActivityKit). No data is collected.

**5. Regional differences**
None. The app works the same way and shows the same content in every region.

**6. Regulated industry / third-party material**
SmileTrack has no third-party protected material. It does not provide medical services, diagnosis, or treatment, and it does not connect to any healthcare provider or medical device. It is a personal timer and reminder tool. The app and its description both state that it does not replace advice from an orthodontist, so no medical credentials or regulatory documents apply.

Best regards,
Marat Faizerakhmanov
maratismodest@gmail.com

---

## Чек-лист записи видео (реальный iPhone, последняя iOS)

1. Удалите приложение и установите **Release/TestFlight**-сборку (не Debug с демо-данными).
2. Пункт управления → Запись экрана. Начните запись на домашнем экране.
3. Запустите SmileTrack → разрешите уведомления.
4. Today: нажмите «Take Aligners Out», подождите несколько секунд. **Не блокируйте телефон**, иначе запись экрана остановится. Вместо этого:
   - смахните вверх на домашний экран — таймер виден в Dynamic Island (на iPhone 14 Pro и новее);
   - смахните вниз от верхнего края (Центр уведомлений) — Live Activity показывается так же, как на экране блокировки;
   - вернитесь в приложение и нажмите «Put Aligners In».
5. Schedule: «Set Up Plan» → заполните поля → Save → покажите результат → Edit.
6. Tips: пролистайте категории.
7. Остановите запись (1–2 минуты) и приложите её к ответу.
