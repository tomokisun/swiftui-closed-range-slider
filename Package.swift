// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "swiftui-closed-range-slider",
  platforms: [
    .iOS("18.0"),
    .macOS("11.0"),
  ],
  products: [
    .library(name: "ClosedRangeSlider", targets: ["ClosedRangeSlider"]),
  ],
  targets: [
    .target(name: "ClosedRangeSlider"),
    .testTarget(name: "ClosedRangeSliderTests", dependencies: [
      "ClosedRangeSlider"
    ]),
  ]
)
