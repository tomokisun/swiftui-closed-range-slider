import SwiftUI
import Testing
@testable import ClosedRangeSlider

@MainActor @Test("Thumb view can be constructed")
func thumb_view_constructs() async throws {
    let thumb = RangeSliderThumb(size: CGSize(width: 40, height: 24), color: .white)
    #expect(String(describing: type(of: thumb)).contains("RangeSliderThumb"))
}
