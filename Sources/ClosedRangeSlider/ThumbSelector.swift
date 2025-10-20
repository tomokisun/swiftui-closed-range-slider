import SwiftUI

/// Utility to determine which thumb (lower/upper) should be active.
enum ThumbSelector {
    enum ActiveThumb { case lower, upper }

    /// Selects the thumb closest to the gesture start position
    /// (prefers `lower` when distances are equal).
    static func select(startX: CGFloat, lowerX: CGFloat, upperX: CGFloat) -> ActiveThumb {
        let chooseLower = abs(startX - lowerX) <= abs(startX - upperX)
        return chooseLower ? .lower : .upper
    }
}

