import SwiftUI

/// Pure functions that apply constraints (clamp/snap/minimum distance)
/// to derive a valid range from proposed values.
enum RangeConstraintResolver {
    /// Internal unifier: applies clamp/snap/minimum distance according to
    /// the active thumb.
    private static func resolveInternal<V: BinaryFloatingPoint & Comparable>(
        proposed: V,
        current: ClosedRange<V>,
        bounds: ClosedRange<V>,
        step: V?,
        minimumDistance: V,
        for thumb: ThumbSelector.ActiveThumb
    ) -> ClosedRange<V> {
        switch thumb {
        case .lower:
            var lower = RangeSliderMath.clamp(proposed, to: bounds)
            let upper = current.upperBound
            lower = RangeSliderMath.snap(lower, step: step, lowerBound: bounds.lowerBound)
            let maxLower = upper - minimumDistance
            lower = min(lower, maxLower)
            // Clamp within bounds (relation to upper is enforced via maxLower)
            lower = RangeSliderMath.clamp(lower, to: bounds.lowerBound...bounds.upperBound)
            return lower...upper
        case .upper:
            let lower = current.lowerBound
            var upper = RangeSliderMath.clamp(proposed, to: bounds)
            upper = RangeSliderMath.snap(upper, step: step, lowerBound: bounds.lowerBound)
            let minUpper = lower + minimumDistance
            upper = max(upper, minUpper)
            // Clamp within bounds (relation to lower is enforced via minUpper)
            upper = RangeSliderMath.clamp(upper, to: bounds.lowerBound...bounds.upperBound)
            return lower...upper
        }
    }

    /// Update lower value (returns range after constraints applied)
    static func resolveLower<V: BinaryFloatingPoint & Comparable>(
        to proposedLower: V,
        current: ClosedRange<V>,
        in bounds: ClosedRange<V>,
        step: V?,
        minimumDistance: V
    ) -> ClosedRange<V> {
        resolveInternal(
            proposed: proposedLower,
            current: current,
            bounds: bounds,
            step: step,
            minimumDistance: minimumDistance,
            for: .lower
        )
    }

    /// Update upper value (returns range after constraints applied)
    static func resolveUpper<V: BinaryFloatingPoint & Comparable>(
        to proposedUpper: V,
        current: ClosedRange<V>,
        in bounds: ClosedRange<V>,
        step: V?,
        minimumDistance: V
    ) -> ClosedRange<V> {
        resolveInternal(
            proposed: proposedUpper,
            current: current,
            bounds: bounds,
            step: step,
            minimumDistance: minimumDistance,
            for: .upper
        )
    }

    /// Update with explicit thumb (single entry point during drag)
    static func resolve<V: BinaryFloatingPoint & Comparable>(
        proposed value: V,
        for activeThumb: ThumbSelector.ActiveThumb,
        current: ClosedRange<V>,
        in bounds: ClosedRange<V>,
        step: V?,
        minimumDistance: V
    ) -> ClosedRange<V> {
        resolveInternal(
            proposed: value,
            current: current,
            bounds: bounds,
            step: step,
            minimumDistance: minimumDistance,
            for: activeThumb
        )
    }

    /// Accessibility nudge (lower)
    static func nudgeLower<V: BinaryFloatingPoint & Comparable>(
        by delta: V,
        current: ClosedRange<V>,
        in bounds: ClosedRange<V>,
        step: V?,
        minimumDistance: V
    ) -> ClosedRange<V> {
        let proposed = current.lowerBound + delta
        return resolveLower(
            to: proposed,
            current: current,
            in: bounds,
            step: step,
            minimumDistance: minimumDistance
        )
    }

    /// Accessibility nudge (upper)
    static func nudgeUpper<V: BinaryFloatingPoint & Comparable>(
        by delta: V,
        current: ClosedRange<V>,
        in bounds: ClosedRange<V>,
        step: V?,
        minimumDistance: V
    ) -> ClosedRange<V> {
        let proposed = current.upperBound + delta
        return resolveUpper(
            to: proposed,
            current: current,
            in: bounds,
            step: step,
            minimumDistance: minimumDistance
        )
    }
}

