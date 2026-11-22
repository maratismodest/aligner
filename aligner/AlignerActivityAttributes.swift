#if os(iOS)
import ActivityKit
import Foundation

/// Live Activity shown while the aligners are out.
/// Keep in sync with the copy in the AlignerWidget extension — ActivityKit matches the two by name and shape.
/// `nonisolated` because the app target defaults to MainActor isolation and ActivityKit uses this type off the main actor.
nonisolated struct AlignerActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// When the aligners were taken out.
        var offSince: Date
        /// When today's 2-hour limit runs out.
        var limitReachedAt: Date
    }
}
#endif
