import SwiftUI
import Testing
@testable import ClosedRangeSlider

@MainActor @Test("ClosedRangeSlider can be constructed")
func construct_view() async throws {
    var range: ClosedRange<Double> = 0.2...0.7
    let binding = Binding(get: { range }, set: { range = $0 })
    let view = ClosedRangeSlider(binding, in: 0...1, step: 0.1, minimumDistance: 0.05)
    #expect(String(describing: type(of: view)).contains("ClosedRangeSlider"))
}

@MainActor @Test("Construct with formatter and style modifiers")
func construct_with_modifiers() async throws {
    var range: ClosedRange<Double> = 10...20
    let binding = Binding(get: { range }, set: { range = $0 })
    let view = ClosedRangeSlider(binding, in: 0...100)
        .rangeSliderValueFormatter { v in "\(Int(Double(v)))" }
        .rangeSliderTrackHeight(8)
        .rangeSliderThumbSize(CGSize(width: 40, height: 24))
        .rangeSliderTrackColor(.red)
        .rangeSliderThumbColor(.blue)
    #expect(String(describing: type(of: view)).contains("ClosedRangeSlider"))
}

@MainActor @Test("ClosedRangeSlider supports ClosedRange<Int> via convenience init")
func construct_int_view() async throws {
    var intRange: ClosedRange<Int> = 20...60
    let binding = Binding(get: { intRange }, set: { intRange = $0 })
    // Int API (uses Double internally)
    let view = ClosedRangeSlider(binding, in: 0...100, step: 1, minimumDistance: 0)
        .rangeSliderTint(.orange)
    #expect(String(describing: type(of: view)).contains("ClosedRangeSlider"))
}
