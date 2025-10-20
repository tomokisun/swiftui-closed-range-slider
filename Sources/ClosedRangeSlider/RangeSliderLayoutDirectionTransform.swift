import SwiftUI

/// 値とx座標をレイアウト方向（LTR/RTL）に沿って相互変換するトランスフォーム。
/// - LTR を基準に、RTL の場合は fraction を `1 - frac` で反転。
/// - クランプやゼロ幅対応は `RangeSliderMath` に委譲。
struct RangeSliderLayoutDirectionTransform<Value: BinaryFloatingPoint & Comparable> {
    let bounds: ClosedRange<Value>
    let totalWidth: CGFloat
    let leadingInset: CGFloat
    let isRTL: Bool

    init(bounds: ClosedRange<Value>, totalWidth: CGFloat, leadingInset: CGFloat, isRTL: Bool) {
        self.bounds = bounds
        self.totalWidth = totalWidth
        self.leadingInset = leadingInset
        self.isRTL = isRTL
    }

    /// Value -> x-position
    func x(for value: Value) -> CGFloat {
        let fracLTR = RangeSliderMath.fraction(value: value, in: bounds)
        let frac = isRTL ? (1 - fracLTR) : fracLTR
        return leadingInset + CGFloat(frac) * totalWidth
    }

    /// x-position -> Value
    func value(at x: CGFloat) -> Value {
        let clampedX = RangeSliderMath.clamp(x, to: leadingInset...(leadingInset + totalWidth))
        let fracLTR = Double((clampedX - leadingInset) / max(totalWidth, 1))
        let frac = isRTL ? (1 - fracLTR) : fracLTR
        return RangeSliderMath.value(forFraction: frac, in: bounds)
    }
}

