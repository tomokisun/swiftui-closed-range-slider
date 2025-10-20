import SwiftUI
import Testing
@testable import SwiftUIRangeSlider

@Test("Range update logic enforces min distance and snapping")
func resolver_update_rules() async throws {
    let bounds: ClosedRange<Double> = 0...10
    let step: Double = 0.5
    let minDistance: Double = 2
    var current: ClosedRange<Double> = 2...6

    current = RangeConstraintResolver.resolveLower(
        to: 5.1,
        current: current,
        in: bounds,
        step: step,
        minimumDistance: minDistance
    )
    #expect(abs(current.lowerBound - 4.0) < 1e-9)

    current = RangeConstraintResolver.resolveUpper(
        to: 3.0,
        current: current,
        in: bounds,
        step: step,
        minimumDistance: minDistance
    )
    #expect(abs(current.upperBound - (current.lowerBound + minDistance)) < 1e-9)
}

@Test("Negative step behaves as no snapping")
func negative_step_ignored() async throws {
    let bounds: ClosedRange<Double> = 0...10
    let step: Double = -0.5
    let minDistance: Double = 0
    let current: ClosedRange<Double> = 2.0...6.0

    let updated = RangeConstraintResolver.resolveLower(
        to: 2.34,
        current: current,
        in: bounds,
        step: step,
        minimumDistance: minDistance
    )
    #expect(abs(updated.lowerBound - 2.34) < 1e-9)
}

@Test("Excessive minimumDistance yields clamped, valid range")
func excessive_min_distance() async throws {
    let bounds: ClosedRange<Double> = 0...10
    let step: Double? = 0.5
    let minDistance: Double = 100
    var current: ClosedRange<Double> = 2...9

    current = RangeConstraintResolver.resolveLower(
        to: 5,
        current: current,
        in: bounds,
        step: step,
        minimumDistance: minDistance
    )
    #expect(current.lowerBound >= bounds.lowerBound)
    #expect(current.upperBound <= bounds.upperBound)
    #expect(current.lowerBound <= current.upperBound)

    current = RangeConstraintResolver.resolveUpper(
        to: 15,
        current: current,
        in: bounds,
        step: step,
        minimumDistance: minDistance
    )
    #expect(current.lowerBound >= bounds.lowerBound)
    #expect(current.upperBound <= bounds.upperBound)
    #expect(current.lowerBound <= current.upperBound)
}

@Test("Nudge helpers respect step, min distance and bounds")
func nudge_helpers_behavior() async throws {
    let bounds: ClosedRange<Double> = 0...10
    let step: Double? = 0.5
    let minDistance: Double = 2

    var current: ClosedRange<Double> = 2...6
    current = RangeConstraintResolver.nudgeLower(by: 0.76, current: current, in: bounds, step: step, minimumDistance: minDistance)
    #expect(abs(current.lowerBound - 3.0) < 1e-9)
    #expect(current.upperBound == 6.0)

    current = RangeConstraintResolver.nudgeUpper(by: -2.2, current: current, in: bounds, step: step, minimumDistance: minDistance)
    #expect(abs(current.upperBound - 5.0) < 1e-9)

    current = 0.5...1.0
    let current2 = RangeConstraintResolver.nudgeLower(by: -1.0, current: current, in: bounds, step: 0.1, minimumDistance: 0)
    #expect(abs(current2.lowerBound - bounds.lowerBound) < 1e-9)
}

@Test("Resolve(for:) equals resolveLower/resolveUpper")
func resolve_unified_equals_specific() async throws {
    let bounds: ClosedRange<Double> = 0...10
    let step: Double = 0.5
    let minDistance: Double = 1
    let current: ClosedRange<Double> = 3...7

    let lowerSpecific = RangeConstraintResolver.resolveLower(to: 2.8, current: current, in: bounds, step: step, minimumDistance: minDistance)
    let lowerUnified = RangeConstraintResolver.resolve(proposed: 2.8, for: .lower, current: current, in: bounds, step: step, minimumDistance: minDistance)
    #expect(abs(lowerSpecific.lowerBound - lowerUnified.lowerBound) < 1e-12)
    #expect(abs(lowerSpecific.upperBound - lowerUnified.upperBound) < 1e-12)

    let upperSpecific = RangeConstraintResolver.resolveUpper(to: 8.2, current: current, in: bounds, step: step, minimumDistance: minDistance)
    let upperUnified = RangeConstraintResolver.resolve(proposed: 8.2, for: .upper, current: current, in: bounds, step: step, minimumDistance: minDistance)
    #expect(abs(upperSpecific.lowerBound - upperUnified.lowerBound) < 1e-12)
    #expect(abs(upperSpecific.upperBound - upperUnified.upperBound) < 1e-12)
}

