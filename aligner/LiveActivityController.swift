import Foundation
#if os(iOS)
import ActivityKit
#endif

/// Starts and ends the Lock Screen / Dynamic Island timer. No-op outside iOS.
enum LiveActivityController {
    /// Shows the timer for aligners taken out at `offSince`.
    static func start(offSince: Date, limitReachedAt: Date) {
        #if os(iOS)
        Task {
            await endAll()
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            // Timer views need a non-empty range even if the limit is already used up.
            let state = AlignerActivityAttributes.ContentState(
                offSince: offSince,
                limitReachedAt: max(limitReachedAt, offSince.addingTimeInterval(1))
            )
            // Past `staleDate` the widget switches to its "limit exceeded" look.
            _ = try? Activity.request(
                attributes: AlignerActivityAttributes(),
                content: .init(state: state, staleDate: state.limitReachedAt)
            )
        }
        #endif
    }

    static func stop() {
        #if os(iOS)
        Task { await endAll() }
        #endif
    }

    /// Brings the activity in line with the stored state, e.g. after a relaunch.
    static func sync(offSince: Date?, limitReachedAt: Date) {
        #if os(iOS)
        guard let offSince else {
            stop()
            return
        }
        if Activity<AlignerActivityAttributes>.activities.isEmpty {
            start(offSince: offSince, limitReachedAt: limitReachedAt)
        }
        #endif
    }

    #if os(iOS)
    private static func endAll() async {
        for activity in Activity<AlignerActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
    #endif
}
