import SwiftUI

/// Minimal thumb subview used by `RangeSlider`.
struct RangeSliderThumb: View {
    let size: CGSize
    let color: Color

    var body: some View {
        let cornerRadius = size.height / 2
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        _RangeSliderThumbContent(shape: shape, size: size, color: color)
    }

}

private struct _RangeSliderThumbContent: View {
    @Environment(\.colorScheme) private var colorScheme
    let shape: RoundedRectangle
    let size: CGSize
    let color: Color

    var body: some View {
        let shadowPrimary = colorScheme == .dark ? Color.black.opacity(0.6) : Color.black.opacity(0.25)
        let shadowSecondary = colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.15)
        let border = colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)

        shape
            .fill(color)
            .frame(width: size.width, height: size.height)
            .shadow(color: shadowPrimary, radius: 10, x: 0, y: 4)
            .shadow(color: shadowSecondary, radius: 4, x: 0, y: 2)
            .overlay(shape.stroke(border))
    }
}

