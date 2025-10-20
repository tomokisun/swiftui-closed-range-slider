import SwiftUI
import Testing
@testable import SwiftUIRangeSlider

@Test("Clamp returns in-range value")
func clamp_basic() async throws {
    #expect(RangeSliderMath.clamp(5, to: 0...10) == 5)
    #expect(RangeSliderMath.clamp(-1, to: 0...10) == 0)
    #expect(RangeSliderMath.clamp(11, to: 0...10) == 10)
}

@Test("Fraction/value mapping round-trips within tolerance")
func mapping_roundtrip() async throws {
    let bounds: ClosedRange<Double> = 0...100
    let values: [Double] = [0, 1, 12.5, 25, 37.5, 50, 62.5, 75, 87.5, 100]
    for v in values {
        let f = RangeSliderMath.fraction(value: v, in: bounds)
        let v2: Double = RangeSliderMath.value(forFraction: f, in: bounds)
        #expect(abs(v2 - v) < 1e-9)
    }
}

@Test("Position/value mapping is invertible")
func position_mapping_roundtrip() async throws {
    let totalWidth: CGFloat = 300
    let inset: CGFloat = 22
    let bounds: ClosedRange<Double> = 0...1
    let candidates: [Double] = stride(from: 0.0, through: 1.0, by: 0.1).map { $0 }
    for v in candidates {
        let x = RangeSliderMath.xPosition(for: v, totalWidth: totalWidth, leadingInset: inset, in: bounds)
        let v2: Double = RangeSliderMath.value(from: x, totalWidth: totalWidth, leadingInset: inset, in: bounds)
        #expect(abs(v2 - v) < 1e-9)
    }
}

@Test("Position to value clamps at edges")
func position_mapping_clamps() async throws {
    let totalWidth: CGFloat = 200
    let inset: CGFloat = 22
    let bounds: ClosedRange<Double> = 0...1
    // Far left
    let vLeft: Double = RangeSliderMath.value(from: -100, totalWidth: totalWidth, leadingInset: inset, in: bounds)
    #expect(abs(vLeft - bounds.lowerBound) < 1e-9)
    // Far right
    let vRight: Double = RangeSliderMath.value(from: inset + totalWidth + 100, totalWidth: totalWidth, leadingInset: inset, in: bounds)
    #expect(abs(vRight - bounds.upperBound) < 1e-9)
}

@Test("Zero track width mapping is safe")
func zero_width_mapping_safe() async throws {
    let bounds: ClosedRange<Double> = 0...1
    let inset: CGFloat = 22
    let width: CGFloat = 0
    let v: Double = RangeSliderMath.value(from: inset, totalWidth: width, leadingInset: inset, in: bounds)
    #expect(abs(v - bounds.lowerBound) < 1e-9)
}

