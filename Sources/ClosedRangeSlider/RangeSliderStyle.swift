import SwiftUI

/// Visual configuration for `RangeSlider`.
/// Encapsulates styling concerns separate from interaction and math.
struct RangeSliderStyle: Equatable {
    var trackHeight: CGFloat
    var thumbSize: CGSize
    var trackColor: Color
    var thumbColor: Color
    var highlightColor: Color?

    static var `default`: RangeSliderStyle {
        RangeSliderStyle(
            trackHeight: 6,
            thumbSize: CGSize(width: 44, height: 28),
            trackColor: .secondary.opacity(0.6),
            thumbColor: .white,
            highlightColor: nil
        )
    }
}

