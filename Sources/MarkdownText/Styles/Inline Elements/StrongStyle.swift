import SwiftUI

/// A type that applies a custom appearance to bold (strong) markdown elements
public protocol StrongMarkdownStyle {
    /// The properties of a bold (strong) markdown element
    typealias Configuration = StrongMarkdownConfiguration
    /// Creates a view that represents the body of a label
    func makeBody(configuration: Configuration) -> Text
}

/// The properties of a bold (strong) markdown element
public struct StrongMarkdownConfiguration {
    /// The textual content for this element
    public let content: Text
    /// Returns a default bold (strong) markdown representation
    public var label: Text { content.bold() }
}

/// An bold (strong) style that applies the `bold` modifier to its textual content
public struct DefaultStrongMarkdownStyle: StrongMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label
    }
}

public extension StrongMarkdownStyle where Self == DefaultStrongMarkdownStyle {
    /// An bold (strong) style that applies the `bold` modifier to its textual content
    static var `default`: Self { .init() }
}

private struct StrongMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: StrongMarkdownStyle = DefaultStrongMarkdownStyle()
}

public extension EnvironmentValues {
    /// The current bold (strong) markdown style
    var markdownStrongStyle: StrongMarkdownStyle {
        get { self[StrongMarkdownEnvironmentKey.self] }
        set { self[StrongMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for bold (strong) markdown elements
    func markdownStrongStyle<S>(_ style: S) -> some View where S: StrongMarkdownStyle {
        environment(\.markdownStrongStyle, style)
    }
}
