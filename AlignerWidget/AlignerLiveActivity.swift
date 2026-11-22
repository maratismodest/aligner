#if os(iOS)
import ActivityKit
import SwiftUI
import WidgetKit

/// Lock Screen and Dynamic Island timer for the time without aligners.
struct AlignerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlignerActivityAttributes.self) { context in
            LockScreenView(state: context.state, isOverLimit: context.isStale)
                .padding()
                .activityBackgroundTint(Color.black.opacity(0.75))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            let state = context.state
            let isOverLimit = context.isStale
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("Out", systemImage: "mouth.fill")
                        .foregroundStyle(.orange)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    RemainingText(state: state, isOverLimit: isOverLimit)
                        .font(.title2.bold())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        LimitProgress(state: state, isOverLimit: isOverLimit)
                        Text(isOverLimit ? "Limit reached — put your aligners in" : "Until the daily limit")
                            .font(.caption)
                            .foregroundStyle(isOverLimit ? .red : .secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "mouth.fill")
                    .foregroundStyle(isOverLimit ? .red : .orange)
            } compactTrailing: {
                RemainingText(state: state, isOverLimit: isOverLimit)
                    .frame(maxWidth: 52)
            } minimal: {
                Image(systemName: "mouth.fill")
                    .foregroundStyle(isOverLimit ? .red : .orange)
            }
            .keylineTint(.orange)
        }
    }
}

private struct LockScreenView: View {
    let state: AlignerActivityAttributes.ContentState
    let isOverLimit: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Label("Aligners out", systemImage: "mouth.fill")
                        .font(.headline)
                        .foregroundStyle(isOverLimit ? .red : .orange)
                    Text("since \(state.offSince, format: .dateTime.hour().minute()) · \(Text(state.offSince, style: .timer))")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    RemainingText(state: state, isOverLimit: isOverLimit)
                        .font(.title.bold())
                    Text(isOverLimit ? "limit reached" : "left")
                        .font(.caption)
                        .foregroundStyle(isOverLimit ? .red : .white.opacity(0.7))
                }
            }
            LimitProgress(state: state, isOverLimit: isOverLimit)
        }
        .foregroundStyle(.white)
    }
}

/// Countdown to the limit; once it's reached, the system re-renders the
/// activity as stale and this shows how long the limit has been exceeded.
private struct RemainingText: View {
    let state: AlignerActivityAttributes.ContentState
    let isOverLimit: Bool

    var body: some View {
        Group {
            if isOverLimit {
                Text(state.limitReachedAt, style: .timer)
                    .foregroundStyle(.red)
            } else {
                Text(timerInterval: state.offSince...state.limitReachedAt, countsDown: true)
            }
        }
        .monospacedDigit()
        .multilineTextAlignment(.trailing)
    }
}

private struct LimitProgress: View {
    let state: AlignerActivityAttributes.ContentState
    let isOverLimit: Bool

    var body: some View {
        if isOverLimit {
            ProgressView(value: 1)
                .tint(.red)
        } else {
            ProgressView(timerInterval: state.offSince...state.limitReachedAt, countsDown: false) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }
            .tint(.orange)
        }
    }
}

#Preview("Lock Screen", as: .content, using: AlignerActivityAttributes()) {
    AlignerLiveActivity()
} contentStates: {
    AlignerActivityAttributes.ContentState(offSince: .now.addingTimeInterval(-25 * 60), limitReachedAt: .now.addingTimeInterval(50 * 60))
}
#endif
