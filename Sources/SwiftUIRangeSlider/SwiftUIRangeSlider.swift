// The Swift Programming Language
// https://docs.swift.org/swift-book
// Module: SwiftUIRangeSlider

import SwiftUI

/// A control for selecting a continuous range of numeric values.
///
/// RangeSlider provides two draggable thumbs to adjust the lower and upper
/// bounds within a specified range. The selected range is highlighted along
/// the track.
///
/// The API mirrors SwiftUI's Slider where it makes sense, following the Swift
/// API Design Guidelines for clarity and progressive disclosure of complexity.
///
/// Example:
/// ```swift
/// struct ContentView: View {
///     @State private var price: ClosedRange<Double> = 20...60
///
///     var body: some View {
///         VStack(spacing: 24) {
///             Text("Price: \(Int(price.lowerBound)) – \(Int(price.upperBound))")
///             RangeSlider($price, in: 0...100, step: 1)
///                 .rangeSliderTint(Color(red: 1.0, green: 0.56, blue: 0.47)) // highlight color
///                 .padding(.horizontal, 24)
///         }
///         .padding()
///     }
/// }
/// ```
///
/// Notes:
/// - Respects environment layout direction. In RTL contexts values are mirrored
///   so that smaller values appear to the right.
public struct RangeSlider<Value>: View where Value: BinaryFloatingPoint & Comparable {
  // MARK: - Public configuration
  
  @Environment(\.layoutDirection) private var layoutDirection

  /// The currently selected range.
  private var value: Binding<ClosedRange<Value>>
  /// The full range of selectable values.
  private let bounds: ClosedRange<Value>
  /// Step interval for discrete increments. If `nil`, values are continuous.
  private let step: Value?
  /// The minimum distance to keep between lower and upper bounds.
  private let minimumDistance: Value
  /// All visual styling bundled together.
  private let style: RangeSliderStyle
  /// Optional value formatter used for accessibility and any future labels.
  /// If not provided, a sensible default formatter is used.
  private let valueFormatter: ((Value) -> String)?
  /// Called when interaction begins and ends.
  private let onEditingChanged: (Bool) -> Void
  
  // Highlight resolves to explicit override or falls back to system tint via `.fill(.tint)`.
  
  // MARK: - Init
  
  /// Creates a range slider.
  /// - Parameters:
  ///   - value: A binding to the selected range.
  ///   - bounds: The full range of selectable values.
  ///   - step: The step increment for discrete values. Pass `nil` for continuous.
  ///   - minimumDistance: The minimum distance to keep between lower and upper bounds.
  ///     Prefer a value less than or equal to the span of `bounds`.
  ///     If larger than the span, updates are clamped to maintain a valid range.
  ///   - onEditingChanged: Called with `true` on drag start and `false` on end.
  public init(
    _ value: Binding<ClosedRange<Value>>,
    in bounds: ClosedRange<Value>,
    step: Value? = nil,
    minimumDistance: Value = .zero,
    onEditingChanged: @escaping (Bool) -> Void = { _ in }
  ) {
    precondition(minimumDistance >= 0, "minimumDistance must be non-negative")
    precondition(bounds.lowerBound <= bounds.upperBound, "bounds must be a valid closed range")
    if let step { precondition(step > 0, "step must be > 0 when provided") }
    self.value = value
    self.bounds = bounds
    self.step = step
    self.minimumDistance = minimumDistance
    // Default visual configuration
    self.style = .default
    self.valueFormatter = nil
    self.onEditingChanged = onEditingChanged
  }

  /// Internal designated initializer used for returning modified copies via helpers.
  /// Not exposed publicly to keep the API surface focused on meaning over appearance.
  init(
    value: Binding<ClosedRange<Value>>,
    bounds: ClosedRange<Value>,
    step: Value?,
    minimumDistance: Value,
    style: RangeSliderStyle,
    valueFormatter: ((Value) -> String)?,
    onEditingChanged: @escaping (Bool) -> Void
  ) {
    self.value = value
    self.bounds = bounds
    self.step = step
    self.minimumDistance = minimumDistance
    self.style = style
    self.valueFormatter = valueFormatter
    self.onEditingChanged = onEditingChanged
  }
  
  // MARK: - Body
  
  public var body: some View {
    GeometryReader { proxy in
      let width = max(0, proxy.size.width - style.thumbSize.width)
      let leadingInset = style.thumbSize.width / 2
      let centerY = proxy.size.height / 2
      
      let mapper = RangeSliderLayoutDirectionTransform<Value>(
        bounds: bounds,
        totalWidth: width,
        leadingInset: leadingInset,
        isRTL: layoutDirection == .rightToLeft
      )
      let lowerX = mapper.x(for: value.wrappedValue.lowerBound)
      let upperX = mapper.x(for: value.wrappedValue.upperBound)
      
      ZStack(alignment: .leading) {
        // Base track
        RoundedRectangle(cornerRadius: trackCornerRadius)
          .fill(style.trackColor)
          .frame(height: style.trackHeight)
          .frame(maxWidth: .infinity, alignment: .center)
        
        // Highlighted selected range
        highlightTrack(lowerX: lowerX, upperX: upperX, centerY: centerY)
        
        // Lower thumb
        thumb
          .position(x: lowerX, y: centerY)
        
        // Upper thumb
        thumb
          .position(x: upperX, y: centerY)
      }
      .contentShape(Rectangle())
      // Allow dragging from the entire control area for ease of use
      // (thumbs also have expanded hit areas).
      .gesture(makeDragGesture(mapper: mapper))
      .animation(.default, value: value.wrappedValue)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("Range")
      .accessibilityValue(Text("\(formatDisplay(value.wrappedValue.lowerBound)) to \(formatDisplay(value.wrappedValue.upperBound))"))
      .accessibilityAdjustableAction { direction in
        let delta = accessibilityStep
        switch direction {
        case .increment:
          nudgeLower(by: delta)
          nudgeUpper(by: delta)
        case .decrement:
          nudgeLower(by: -delta)
          nudgeUpper(by: -delta)
        @unknown default: break
        }
      }
    }
    .frame(height: intrinsicHeight)
  }
  
  // MARK: - Subviews
  
  private var thumb: some View {
    RangeSliderThumb(size: style.thumbSize, color: style.thumbColor)
  }

  /// Highlighted range view
  @ViewBuilder
  private func highlightTrack(lowerX: CGFloat, upperX: CGFloat, centerY: CGFloat) -> some View {
    let width = max(upperX - lowerX, 0)
    let center = CGPoint(x: (lowerX + upperX) / 2, y: centerY)
    RangeSliderHighlightTrack(
      width: width,
      center: center,
      cornerRadius: trackCornerRadius,
      trackHeight: style.trackHeight,
      highlightColor: style.highlightColor
    )
  }

  // highlightTrack moved to dedicated small View
  
  // MARK: - Gesture handling
  
  @GestureState private var activeThumb: ThumbSelector.ActiveThumb? = nil
  @State private var isEditing: Bool = false
  
  private func makeDragGesture(mapper: RangeSliderLayoutDirectionTransform<Value>) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .updating($activeThumb) { value, state, _ in
        // Decide which thumb to grab based on touch start proximity (once per gesture).
        if state == nil {
          let startX = value.startLocation.x
          let lowerX = mapper.x(for: self.value.wrappedValue.lowerBound)
          let upperX = mapper.x(for: self.value.wrappedValue.upperBound)
          state = ThumbSelector.select(startX: startX, lowerX: lowerX, upperX: upperX)
        }
      }
      .onChanged { drag in
        if !isEditing { isEditing = true; onEditingChanged(true) }
        guard let activeThumb else { return }
        let newVal: Value = mapper.value(at: drag.location.x)
        let updated = RangeConstraintResolver.resolve(
          proposed: newVal,
          for: activeThumb,
          current: value.wrappedValue,
          in: bounds,
          step: step,
          minimumDistance: minimumDistance
        )
        value.wrappedValue = updated
      }
      .onEnded { _ in
        isEditing = false
        onEditingChanged(false)
      }
  }
  
  private func nudgeLower(by delta: Value) {
    value.wrappedValue = RangeConstraintResolver.nudgeLower(
      by: delta,
      current: value.wrappedValue,
      in: bounds,
      step: step,
      minimumDistance: minimumDistance
    )
  }
  
  private func nudgeUpper(by delta: Value) {
    value.wrappedValue = RangeConstraintResolver.nudgeUpper(
      by: delta,
      current: value.wrappedValue,
      in: bounds,
      step: step,
      minimumDistance: minimumDistance
    )
  }
  
  // MARK: - Geometry & mapping
  
  // Mapping now delegated to RangeSliderMath for testability
  
  // Mapping is delegated to RangeSliderLayoutDirectionTransform

  // MARK: - Utilities
  
  // No-op helper retained for minimal surface; resolution handled inline.
  
  private var intrinsicHeight: CGFloat {
    // Enough room for thumbs and shadows. Tuned to feel like a control.
    max(style.thumbSize.height, style.trackHeight) + 16
  }
  
  private var trackCornerRadius: CGFloat { style.trackHeight / 2 }
  
  // Default accessibility increment step (1/20 of range when `step` is unspecified)
  private var accessibilityStep: Value {
    step ?? ((bounds.upperBound - bounds.lowerBound) / 20)
  }
  
  // snapping delegated to RangeSliderMath
  
  private func format(_ value: Value) -> String {
    // Simple formatting for accessibility
    let v = Double(value)
    if abs(v.rounded(.towardZero) - v) < 0.000_001 {
      return String(Int(v))
    } else {
      return String(format: "%.2f", v)
    }
  }

  private func formatDisplay(_ value: Value) -> String {
    if let valueFormatter { return valueFormatter(value) }
    return format(value)
  }
}

// MARK: - Styling helpers

public extension RangeSlider {
  /// Sets the highlight color for the selected range.
  /// - Parameter color: The highlight color to use.
  /// - Returns: A modified `RangeSlider`.
  func rangeSliderTint(_ color: Color) -> RangeSlider { reconfigured(highlightColor: color) }
  
  /// Sets a custom value formatter used for accessibility (and future labels).
  /// - Parameter formatter: Closure that converts values to strings.
  func rangeSliderValueFormatter(_ formatter: @escaping (Value) -> String) -> RangeSlider { reconfigured(valueFormatter: formatter) }

  /// Sets track height.
  func rangeSliderTrackHeight(_ height: CGFloat) -> RangeSlider { reconfigured(trackHeight: height) }

  /// Sets thumb size.
  func rangeSliderThumbSize(_ size: CGSize) -> RangeSlider { reconfigured(thumbSize: size) }

  /// Sets base (unselected) track color.
  func rangeSliderTrackColor(_ color: Color) -> RangeSlider { reconfigured(trackColor: color) }

  /// Sets thumb fill color.
  func rangeSliderThumbColor(_ color: Color) -> RangeSlider { reconfigured(thumbColor: color) }
}
// MARK: - Internal helpers

private extension RangeSlider {
  /// Returns a copy with updated style-related parameters.
  func reconfigured(
    trackHeight: CGFloat? = nil,
    thumbSize: CGSize? = nil,
    trackColor: Color? = nil,
    thumbColor: Color? = nil,
    highlightColor: Color? = nil,
    valueFormatter: ((Value) -> String)? = nil
  ) -> RangeSlider {
    var newStyle = self.style
    if let trackHeight { newStyle.trackHeight = trackHeight }
    if let thumbSize { newStyle.thumbSize = thumbSize }
    if let trackColor { newStyle.trackColor = trackColor }
    if let thumbColor { newStyle.thumbColor = thumbColor }
    if let highlightColor { newStyle.highlightColor = highlightColor }

    return RangeSlider(
      value: value,
      bounds: bounds,
      step: step,
      minimumDistance: minimumDistance,
      style: newStyle,
      valueFormatter: valueFormatter ?? self.valueFormatter,
      onEditingChanged: onEditingChanged
    )
  }
}

// Generic clamp helpers provided by RangeSliderMath

// MARK: - Preview (for development)

#if DEBUG
struct RangeSlider_Previews: PreviewProvider {
  struct Demo: View {
    @State private var values: ClosedRange<Double> = 0.2...0.7
    var body: some View {
      VStack(spacing: 32) {
        RangeSlider($values, in: 0...1, step: 0.01, minimumDistance: 0.05)
          .rangeSliderTint(Color(red: 0.98, green: 0.55, blue: 0.46))
        Text("\(values.lowerBound, specifier: "%.2f") – \(values.upperBound, specifier: "%.2f")")
      }
      .padding()
    }
  }
  static var previews: some View { Demo() }
}
#endif
