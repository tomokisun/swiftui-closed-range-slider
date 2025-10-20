import SwiftUI

/// Int用のコンビニエンス初期化子。
/// 内部では `Double` ベースの `RangeSlider` を使用し、値変換（Int <> Double）を透過的に行います。
public extension RangeSlider where Value == Double {
    /// Intレンジに対応した初期化子。
    /// - Parameters:
    ///   - value: 選択中レンジ（Int）のバインディング。
    ///   - bounds: 選択可能な全体レンジ（Int）。
    ///   - step: 刻み幅。既定は `1`。
    ///   - minimumDistance: 下限と上限の最小距離。既定は `0`。
    ///   - onEditingChanged: ドラッグ開始/終了で呼び出されます。
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

        // Int <-> Double のブリッジ
        let doubleBounds = Double(bounds.lowerBound)...Double(bounds.upperBound)
        let doubleStep: Double = Double(step)
        let doubleMinDistance: Double = Double(minimumDistance)

        let doubleBinding = Binding<ClosedRange<Double>>(
            get: {
                let r = value.wrappedValue
                return Double(r.lowerBound)...Double(r.upperBound)
            },
            set: { newRange in
                // 近傍の整数へ丸め、Intレンジへ反映（境界も念のためクランプ）
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

