import SwiftUI

/// Highlighted portion of the track between lower/upper thumbs.
struct RangeSliderHighlightTrack: View {
    let width: CGFloat
    let center: CGPoint
    let cornerRadius: CGFloat
    let trackHeight: CGFloat
    let highlightColor: Color?

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        Group {
            if let highlightColor {
                shape.fill(highlightColor)
            } else {
                if #available(iOS 15.0, macOS 12.0, *) {
                    shape.fill(.tint)
                } else {
                    shape.fill(Color.accentColor)
                }
            }
        }
        .frame(width: max(width, 0), height: trackHeight)
        .position(x: center.x, y: center.y)
    }
}

