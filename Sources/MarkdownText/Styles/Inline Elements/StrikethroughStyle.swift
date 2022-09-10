import SwiftUI

/// A type that applies a custom appearance to strikethough markdown elements
public protocol StrikethroughMarkdownStyle {
    /// The properties of a strikethough  markdown element
    typealias Configuration = StrikethroughMarkdownConfiguration
    /// Creates a view that represents the body of a label
    func makeBody(configuration: Configuration) -> Text
}

/// The properties of a strikethrough markdown element
public struct StrikethroughMarkdownConfiguration {
    /// The textual content for this element
    public let content: Text
    /// Returns a default strikethrough markdown representation
    public var label: Text { content.strikethrough() }
}

/// An strikethrough style that applies the `strikethrough` modifier to its textual content
public struct DefaultStrikethroughMarkdownStyle: StrikethroughMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label
    }
}

public extension StrikethroughMarkdownStyle where Self == DefaultStrikethroughMarkdownStyle {
    /// An strikethrough style that applies the `strikethrough` modifier to its textual content
    static var `default`: Self { .init() }
}

private struct StrikethroughMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: StrikethroughMarkdownStyle = DefaultStrikethroughMarkdownStyle()
}

public extension EnvironmentValues {
    /// The current strikethrough markdown style
    var markdownStrikethroughStyle: StrikethroughMarkdownStyle {
        get { self[StrikethroughMarkdownEnvironmentKey.self] }
        set { self[StrikethroughMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for strikethrough markdown elements
    func markdownStrikethroughStyle<S>(_ style: S) -> some View where S: StrikethroughMarkdownStyle {
        environment(\.markdownStrikethroughStyle, style)
    }
}
