#if os(iOS)
import ActivityKit
import Foundation

/// Live Activity shown while the aligners are out.
/// Keep in sync with the copy in the app target — ActivityKit matches the two by name and shape.
struct AlignerActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// When the aligners were taken out.
        var offSince: Date
        /// When today's 2-hour limit runs out.
        var limitReachedAt: Date
    }
}
#endif
