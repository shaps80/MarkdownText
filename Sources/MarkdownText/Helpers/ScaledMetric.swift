import SwiftUI

@available(iOS, introduced: 13.0, deprecated: 14.0)
@available(macOS, introduced: 10.5, deprecated: 11.0)
@available(tvOS, introduced: 13.0, deprecated: 14.0)
@available(watchOS, introduced: 6.0, deprecated: 7.0)
extension Backport where Content == Any {

    /// A dynamic property that scales a numeric value.
    @propertyWrapper
    public struct ScaledMetric<Value>: DynamicProperty where Value: BinaryFloatingPoint {

        @Environment(\.sizeCategory) private var sizeCategory

        private let baseValue: Value
        private let metrics: UIFontMetrics

        public var wrappedValue: Value {
            let traits = UITraitCollection(traitsFrom: [
                UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(sizeCategory))
            ])

            return Value(metrics.scaledValue(for: CGFloat(baseValue), compatibleWith: traits))
        }

        /// Creates the scaled metric with an unscaled value and a text style to scale relative to.
        public init(wrappedValue: Value, relativeTo textStyle: Font.TextStyle = .body) {
            self.baseValue = wrappedValue
            self.metrics = .init(forTextStyle: .init(textStyle))
        }

    }

}

private extension UIFont.TextStyle {
    init(_ style: Font.TextStyle) {
        switch style {
        case .largeTitle: self = .largeTitle
        case .title: self = .title1
        case .title2: self = .title2
        case .title3: self = .title3
        case .headline: self = .headline
        case .subheadline: self = .subheadline
        case .body: self = .body
        case .callout: self = .callout
        case .footnote: self = .footnote
        case .caption: self = .caption1
        case .caption2: self = .caption2
        default: self = .body
        }
    }
}

private extension UIContentSizeCategory {
    init(_ sizeCategory: ContentSizeCategory?) {
        switch sizeCategory {
        case .accessibilityExtraExtraExtraLarge: self = .accessibilityExtraExtraExtraLarge
        case .accessibilityExtraExtraLarge: self = .accessibilityExtraExtraLarge
        case .accessibilityExtraLarge: self = .accessibilityExtraLarge
        case .accessibilityLarge: self = .accessibilityLarge
        case .accessibilityMedium: self = .accessibilityMedium
        case .extraExtraExtraLarge: self = .extraExtraExtraLarge
        case .extraExtraLarge: self = .extraExtraLarge
        case .extraLarge: self = .extraLarge
        case .extraSmall: self = .extraSmall
        case .large: self = .large
        case .medium: self = .medium
        case .small: self = .small
        default: self = .unspecified
        }
    }
}
