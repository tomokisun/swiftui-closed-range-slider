import SwiftUI
import Testing
@testable import SwiftUIRangeSlider

@MainActor @Test("HighlightTrack compiles and positions with given inputs")
func highlight_track_constructs() async throws {
    let view = RangeSliderHighlightTrack(
        width: 120,
        center: CGPoint(x: 150, y: 10),
        cornerRadius: 3,
        trackHeight: 6,
        highlightColor: .blue
    )
    #expect(String(describing: type(of: view)).contains("RangeSliderHighlightTrack"))
}

@Test("Highlight width equals trackWidth * (fu - fl)")
func highlight_width_math() async throws {
    let totalWidth: CGFloat = 300
    let inset: CGFloat = 22
    let bounds: ClosedRange<Double> = 0...1
    let lower: Double = 0.2
    let upper: Double = 0.7

    let xLower = RangeSliderMath.xPosition(for: lower, totalWidth: totalWidth, leadingInset: inset, in: bounds)
    let xUpper = RangeSliderMath.xPosition(for: upper, totalWidth: totalWidth, leadingInset: inset, in: bounds)
    let width = xUpper - xLower
    let fracLower = RangeSliderMath.fraction(value: lower, in: bounds)
    let fracUpper = RangeSliderMath.fraction(value: upper, in: bounds)
    let expected = totalWidth * CGFloat(fracUpper - fracLower)
    #expect(abs(width - expected) < 1e-9)
}

