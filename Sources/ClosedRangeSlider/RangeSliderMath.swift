import SwiftUI

/// Internal math helpers used by `RangeSlider`.
/// Exposed as `internal` to allow testing.
///
/// Mapping functions are designed to be inverse within numeric tolerance:
/// - `fraction(value:in:)` and `value(forFraction:in:)` round-trip for in-range inputs.
/// - `xPosition(for:totalWidth:leadingInset:in:)` and
///   `value(from:totalWidth:leadingInset:in:)` round-trip for inputs within
///   the drawable track. Out-of-range positions are clamped to bounds.
enum RangeSliderMath {
    static func clamp<T: Comparable>(_ value: T, to range: ClosedRange<T>) -> T {
        min(max(value, range.lowerBound), range.upperBound)
    }

    static func fraction<V: BinaryFloatingPoint & Comparable>(value: V, in bounds: ClosedRange<V>) -> Double {
        let span = Double(bounds.upperBound - bounds.lowerBound)
        guard span > 0 else { return 0 }
        let v = Double(value - bounds.lowerBound)
        return clamp(v / span, to: 0...1)
    }

    static func value<V: BinaryFloatingPoint & Comparable>(forFraction fraction: Double, in bounds: ClosedRange<V>) -> V {
        let frac = clamp(fraction, to: 0...1)
        let span = bounds.upperBound - bounds.lowerBound
        return bounds.lowerBound + V(frac) * span
    }

    static func xPosition<V: BinaryFloatingPoint & Comparable>(for value: V, totalWidth: CGFloat, leadingInset: CGFloat, in bounds: ClosedRange<V>) -> CGFloat {
        let frac = fraction(value: value, in: bounds)
        return leadingInset + CGFloat(frac) * totalWidth
    }

    static func value<V: BinaryFloatingPoint & Comparable>(from locationX: CGFloat, totalWidth: CGFloat, leadingInset: CGFloat, in bounds: ClosedRange<V>) -> V {
        let clampedX = clamp(locationX, to: leadingInset...(leadingInset + totalWidth))
        let frac = (clampedX - leadingInset) / max(totalWidth, 1)
        return value(forFraction: Double(frac), in: bounds)
    }

    static func snap<V: BinaryFloatingPoint & Comparable>(_ value: V, step: V?, lowerBound: V) -> V {
        guard let step, step > 0 else { return value }
        let base = Double(lowerBound)
        let s = Double(step)
        let v = Double(value)
        let snapped = base + (round((v - base) / s) * s)
        return V(snapped)
    }
}

