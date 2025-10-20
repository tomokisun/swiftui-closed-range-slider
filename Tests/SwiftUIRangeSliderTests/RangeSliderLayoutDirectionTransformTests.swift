import SwiftUI
import Testing
@testable import SwiftUIRangeSlider

@Test("RTL: value/x round-trip is stable")
func rtl_roundtrip_mapping() async throws {
    let bounds: ClosedRange<Double> = 0...1
    let width: CGFloat = 300
    let inset: CGFloat = 22
    let mapper = RangeSliderLayoutDirectionTransform<Double>(
        bounds: bounds,
        totalWidth: width,
        leadingInset: inset,
        isRTL: true
    )
    for v in stride(from: 0.0, through: 1.0, by: 0.1) {
        let x = mapper.x(for: v)
        let v2 = mapper.value(at: x)
        #expect(abs(v2 - v) < 1e-9)
    }
}

@Test("RTL: endpoints map to mirrored edges")
func rtl_endpoints_mirrored() async throws {
    let bounds: ClosedRange<Double> = 0...1
    let width: CGFloat = 300
    let inset: CGFloat = 22
    let mapper = RangeSliderLayoutDirectionTransform<Double>(
        bounds: bounds,
        totalWidth: width,
        leadingInset: inset,
        isRTL: true
    )
    let xLower = mapper.x(for: bounds.lowerBound) // -> right edge
    let xUpper = mapper.x(for: bounds.upperBound) // -> left edge
    #expect(abs(Double(xLower - (inset + width))) < 1e-9)
    #expect(abs(Double(xUpper - inset)) < 1e-9)
}

@Test("RTL: out-of-track positions clamp to bounds (upper on left, lower on right)")
func rtl_clamp_behavior() async throws {
    let bounds: ClosedRange<Double> = 0...1
    let width: CGFloat = 300
    let inset: CGFloat = 22
    let mapper = RangeSliderLayoutDirectionTransform<Double>(
        bounds: bounds,
        totalWidth: width,
        leadingInset: inset,
        isRTL: true
    )
    // Outside to the left => clamp to inset => fracLTR=0 => becomes 1 in RTL => upper bound
    let vLeft = mapper.value(at: -100)
    #expect(abs(vLeft - bounds.upperBound) < 1e-9)
    // Outside to the right => clamp to inset+width => fracLTR=1 => becomes 0 in RTL => lower bound
    let vRight = mapper.value(at: inset + width + 100)
    #expect(abs(vRight - bounds.lowerBound) < 1e-9)
}

@Test("RTL: absolute distance of x matches trackWidth * (fu - fl)")
func rtl_highlight_width_equivalence() async throws {
    let bounds: ClosedRange<Double> = 0...1
    let width: CGFloat = 300
    let inset: CGFloat = 22
    let lower: Double = 0.2
    let upper: Double = 0.7
    let mapper = RangeSliderLayoutDirectionTransform<Double>(
        bounds: bounds,
        totalWidth: width,
        leadingInset: inset,
        isRTL: true
    )
    let xLower = mapper.x(for: lower)
    let xUpper = mapper.x(for: upper)
    let dist = abs(xUpper - xLower)
    let fu = RangeSliderMath.fraction(value: upper, in: bounds)
    let fl = RangeSliderMath.fraction(value: lower, in: bounds)
    let expected = width * CGFloat(fu - fl)
    #expect(abs(Double(dist - expected)) < 1e-9)
}
