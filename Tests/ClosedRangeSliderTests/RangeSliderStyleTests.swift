import SwiftUI
import Testing
@testable import ClosedRangeSlider

@Test("Default style has expected metrics")
func default_style_metrics() async throws {
    let style = RangeSliderStyle.default
    #expect(style.trackHeight == 6)
    #expect(style.thumbSize.width == 44)
    #expect(style.thumbSize.height == 28)
    #expect(style.highlightColor == nil)
}
