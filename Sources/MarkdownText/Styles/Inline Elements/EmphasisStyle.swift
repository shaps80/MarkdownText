import SwiftUI

/// A type that applies a custom appearance to italic (emphasis) markdown elements
public protocol EmphasisMarkdownStyle {
    /// The properties of an emphasis markdown element
    typealias Configuration = EmphasisMarkdownConfiguration
    /// Creates a view that represents the body of a label
    func makeBody(configuration: Configuration) -> Text
}

/// The properties of an italic (emphasis) markdown element
public struct EmphasisMarkdownConfiguration {
    /// The textual content for this element
    public let content: Text
    /// Returns a default italic (emphasis) markdown representation
    public var label: Text { content.italic() }
}

/// An italic (emphasis) style that applies the `italic` modifier to its textual content
public struct DefaultEmphasisMarkdownStyle: EmphasisMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label
    }
}

public extension EmphasisMarkdownStyle where Self == DefaultEmphasisMarkdownStyle {
    /// An italic (emphasis) style that applies the `italic` modifier to its textual content
    static var `default`: Self { .init() }
}

private struct EmphasisMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: EmphasisMarkdownStyle = DefaultEmphasisMarkdownStyle()
}

public extension EnvironmentValues {
    /// The current italic (amphasis) markdown style
    var markdownEmphasisStyle: EmphasisMarkdownStyle {
        get { self[EmphasisMarkdownEnvironmentKey.self] }
        set { self[EmphasisMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for italic (emphasis) markdown elements
    func markdownEmphasisStyle<S>(_ style: S) -> some View where S: EmphasisMarkdownStyle {
        environment(\.markdownEmphasisStyle, style)
    }
}
