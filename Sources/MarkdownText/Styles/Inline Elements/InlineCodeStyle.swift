import SwiftUI

/// A type that applies a custom appearance to inline code markdown elements
public protocol InlineCodeMarkdownStyle {
    /// The properties of an inline code markdown element
    typealias Configuration = InlineCodeMarkdownConfiguration
    /// Creates a view that represents the body of a label
    func makeBody(configuration: Configuration) -> Text
}

/// The properties of an inline code markdown element
public struct InlineCodeMarkdownConfiguration {
    /// The code for this element
    public let code: String
    internal let font: Font?

    /// Returns a default inline code markdown representation
    public var label: Text {
        if #available(iOS 15, *) {
            return Text(code)
                .font(font?.monospaced() ?? .system(.body, design: .monospaced))
        } else {
            return Text(code)
                .font(.system(.body, design: .monospaced))
        }
    }
}

/// An inline code style that applies the `monospaced` modifier to its textual content
public struct DefaultInlineCodeMarkdownStyle: InlineCodeMarkdownStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> Text {
        configuration.label
    }
}

public extension InlineCodeMarkdownStyle where Self == DefaultInlineCodeMarkdownStyle {
    /// An inline code style that applies the `monospaced` modifier to its textual content
    static var `default`: Self { .init() }
}

private struct InlineCodeMarkdownEnvironmentKey: EnvironmentKey {
    static let defaultValue: InlineCodeMarkdownStyle = DefaultInlineCodeMarkdownStyle()
}

public extension EnvironmentValues {
    /// The current inline code markdown style
    var markdownInlineCodeStyle: InlineCodeMarkdownStyle {
        get { self[InlineCodeMarkdownEnvironmentKey.self] }
        set { self[InlineCodeMarkdownEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets the style for inline code markdown elements
    func markdownInlineCodeStyle<S>(_ style: S) -> some View where S: InlineCodeMarkdownStyle {
        environment(\.markdownInlineCodeStyle, style)
    }
}
