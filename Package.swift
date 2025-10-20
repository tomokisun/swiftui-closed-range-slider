// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "swiftui-range-slider",
  platforms: [
    .iOS("18.0"),
    .macOS("11.0"),
  ],
  products: [
    .library(name: "SwiftUIRangeSlider", targets: ["SwiftUIRangeSlider"]),
  ],
  targets: [
    .target(name: "SwiftUIRangeSlider"),
    .testTarget(name: "SwiftUIRangeSliderTests", dependencies: [
      "SwiftUIRangeSlider"
    ]),
  ]
)
