import SwiftUI
import Testing
@testable import SwiftUIRangeSlider

@Test("Active thumb is chosen by proximity")
func choose_active_thumb() async throws {
    let lowerX: CGFloat = 100
    let upperX: CGFloat = 200
    #expect(ThumbSelector.select(startX: 120, lowerX: lowerX, upperX: upperX) == .lower)
    #expect(ThumbSelector.select(startX: 180, lowerX: lowerX, upperX: upperX) == .upper)
    // When equidistant, prefer the lower thumb
    #expect(ThumbSelector.select(startX: 150, lowerX: lowerX, upperX: upperX) == .lower)
}
