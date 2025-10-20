import SwiftUI

/// Convenience initializer for Int ranges.
/// Uses a `Double`-based `RangeSlider` internally and transparently handles Int <> Double conversions.
public extension RangeSlider where Value == Double {
    /// Creates a range slider for Int ranges.
    /// - Parameters:
    ///   - value: Binding to the selected Int range.
    ///   - bounds: The overall selectable Int range.
    ///   - step: Step increment. Defaults to `1`.
    ///   - minimumDistance: Minimum distance between lower and upper bounds. Defaults to `0`.
    ///   - onEditingChanged: Called when dragging starts or ends.
    init(
        _ value: Binding<ClosedRange<Int>>,
        in bounds: ClosedRange<Int>,
        step: Int = 1,
        minimumDistance: Int = 0,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        precondition(minimumDistance >= 0, "minimumDistance must be non-negative")
        precondition(bounds.lowerBound <= bounds.upperBound, "bounds must be a valid closed range")
        precondition(step > 0, "step must be > 0")

        // Bridge Int <-> Double
        let doubleBounds = Double(bounds.lowerBound)...Double(bounds.upperBound)
        let doubleStep: Double = Double(step)
        let doubleMinDistance: Double = Double(minimumDistance)

        let doubleBinding = Binding<ClosedRange<Double>>(
            get: {
                let r = value.wrappedValue
                return Double(r.lowerBound)...Double(r.upperBound)
            },
            set: { newRange in
                // Round to nearest integer and map back to Int range (with clamping to bounds)
                let l = Int(newRange.lowerBound.rounded())
                let u = Int(newRange.upperBound.rounded())
                let clampedLower = max(bounds.lowerBound, min(bounds.upperBound, l))
                let clampedUpper = max(bounds.lowerBound, min(bounds.upperBound, u))
                value.wrappedValue = clampedLower...clampedUpper
            }
        )

        self.init(
            doubleBinding,
            in: doubleBounds,
            step: doubleStep,
            minimumDistance: doubleMinDistance,
            onEditingChanged: onEditingChanged
        )
    }
}

