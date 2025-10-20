# SwiftUIRangeSlider

A polished, two-thumb range slider for SwiftUI. Bind a `ClosedRange<Value>`, drag the lower/upper thumbs, and get a highlighted selection along the track. The API mirrors SwiftUI’s `Slider` where it makes sense—simple by default, configurable when needed.

## Features
- Generic value type: `Value: BinaryFloatingPoint & Comparable` (e.g. `Double`, `CGFloat`)
- Step increments (`step`) and minimum distance between thumbs (`minimumDistance`)
- Automatic RTL mirroring using the environment layout direction
- Customizable appearance: track, thumb, and highlight with sensible defaults
- Accessibility-friendly: adjustable action support; default increment is 1/20 of the bounds span when `step` is `nil`
- Testable internals with unit tests for math and constraints

## Requirements
- Swift tools 6.2+
- Platforms (as declared in `Package.swift`):
  - iOS 18.0+
  - macOS 11.0+

Note: The implementation uses APIs that gracefully fall back when tint is unavailable (`.fill(.tint)` guarded with `#available`). If you lower platform versions in your own fork, the code path still compiles with the provided fallback.

## Installation (Swift Package Manager)
### Xcode UI
1. File > Add Packages…
2. Enter: `https://github.com/tomokisun/swiftui-range-slider.git`
3. Add the product `SwiftUIRangeSlider` to your target

### `Package.swift`
```swift
// Add to dependencies (example using the main branch)
.package(url: "https://github.com/tomokisun/swiftui-range-slider.git", branch: "main"),

// Add product to your target dependencies
.target(
  name: "YourApp",
  dependencies: [
    .product(name: "SwiftUIRangeSlider", package: "swiftui-range-slider")
  ]
)
```

## Quick Start
```swift
import SwiftUI
import SwiftUIRangeSlider

struct ContentView: View {
    @State private var price: ClosedRange<Double> = 20...60

    var body: some View {
        VStack(spacing: 24) {
            Text("Price: \(Int(price.lowerBound)) – \(Int(price.upperBound))")
            RangeSlider($price, in: 0...100, step: 1)
                .rangeSliderTint(Color(red: 1.0, green: 0.56, blue: 0.47)) // highlight color
                .padding(.horizontal, 24)
        }
        .padding()
    }
}
```

## API
### Initializer
```swift
RangeSlider(
  _ value: Binding<ClosedRange<Value>>,
  in bounds: ClosedRange<Value>,
  step: Value? = nil,
  minimumDistance: Value = .zero,
  onEditingChanged: @escaping (Bool) -> Void = { _ in }
)
// Value: BinaryFloatingPoint & Comparable
```

- `value`: Binding to the currently selected range (e.g. `@State var range: ClosedRange<Double>`)
- `bounds`: The full range of selectable values
- `step`: Optional step increment; when provided it must be `> 0` (continuous if `nil`)
- `minimumDistance`: Minimum distance to maintain between lower and upper values (non‑negative)
- `onEditingChanged`: Called with `true` on drag start and `false` on drag end

Preconditions enforce invariants (e.g. non‑negative `minimumDistance`, positive `step` when set).

### Styling Modifiers
- `.rangeSliderTint(_ color: Color)`: highlight color for the selected range
- `.rangeSliderValueFormatter(_ formatter: (Value) -> String)`: value string for accessibility (and future labels)
- `.rangeSliderTrackHeight(_ height: CGFloat)`: track height
- `.rangeSliderThumbSize(_ size: CGSize)`: thumb size
- `.rangeSliderTrackColor(_ color: Color)`: base (unselected) track color
- `.rangeSliderThumbColor(_ color: Color)`: thumb fill color

```swift
RangeSlider($range, in: 0...1, step: 0.01, minimumDistance: 0.05)
  .rangeSliderTint(.pink)
  .rangeSliderTrackHeight(8)
  .rangeSliderThumbSize(CGSize(width: 40, height: 24))
  .rangeSliderTrackColor(.secondary.opacity(0.5))
  .rangeSliderThumbColor(.white)
```

## Layout & Interaction
- Honors environment layout direction; values are mirrored in RTL (smaller values appear on the right)
- The entire control is draggable; the nearer thumb is selected automatically
- Values clamp to `bounds`, and snap to `step` when provided

## Accessibility
- Exposes an adjustable action with label "Range"
- Default incremental step is 1/20 of the bounds span when `step` is `nil`; otherwise uses `step`

## Testing
- Ships with unit tests using SwiftPM’s `Testing`
- Run:
  - CLI: `swift test`
  - Xcode: Product > Test

## FAQ
- Q: Which platforms are supported?
  - A: As declared in `Package.swift`: iOS 18.0+ and macOS 11.0+.

## License
No explicit license file is included. Before using or distributing this package, please confirm the author’s intended licensing.

## Acknowledgements
Inspired by the interaction model of SwiftUI’s `Slider`, with an emphasis on clarity and a minimal, cohesive API surface.
